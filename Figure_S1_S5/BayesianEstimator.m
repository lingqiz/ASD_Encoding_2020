classdef BayesianEstimator < handle
    % Bayesian estimator with efficient encoding for modeling (circular) orientation estimate.
    
    properties (Access = public)
        prior;     % Prior distribution p(theta)
        intNoise;  % Size of internal noise (kappa)
        stmSpc;    % Stimulus space [0, 2 * pi]
        snsSpc;    % Sensory space [0, 2 * pi]
    end
    
    properties (Access = public)
        stepSize;  % Increments for discretization
        
        mapping;   % Mapping from stimulus space to sensory space
        estimates; % Estimates as a function of measurements
        
        ivsStmSpc; % Points in the stimulus space corresponds to the uniform sensory space
        ivsPrior;  % Prior defined on the vector ivsStmSpc
    end
    
    methods (Access = public)
        function this = BayesianEstimator(priorScale, intNoise, varargin)
            % Constructor for the Bayesian estimator with prior and noise parameter
            
            % Prase and save input parameters
            p = inputParser;
            p.addParameter('StepSize', 0.01, @(x)(isnumeric(x) && numel(x) == 1));
            p.addParameter('PriorHandle', priorHandle(priorScale), @(x) isa(x, 'function_handle'))
            
            parse(p, varargin{:});
            this.stepSize = p.Results.StepSize;
            this.stmSpc = 0 : this.stepSize : 2 * pi;
            this.snsSpc = 0 : this.stepSize : 2 * pi;
            this.prior = p.Results.PriorHandle;
            this.intNoise = intNoise;
        end
        
        function this = computeEstimator(this)
            % Compute the estimator mapping theta_hat(measurement) for the entire domain
            % Should recalculate after changing the prior or the noise parameter
            priorDnst = this.prior(this.stmSpc);
            this.mapping   = cumtrapz(this.stmSpc, priorDnst) * 2 * pi;
            this.ivsStmSpc = interp1(this.mapping, this.stmSpc, this.snsSpc, 'linear', 'extrap');
            this.ivsPrior  = this.prior(this.ivsStmSpc);
            
            % Calculate an estimate for the entire sensory space
            this.estimates = zeros(1, length(this.snsSpc));
            for idx = 1:length(this.snsSpc)
                this.estimates(idx) = this.thetaEstimator(this.snsSpc(idx));
            end
        end
        
        function estimate = thetaEstimator(this, snsMsmt)
            % Calculate theta_hat given the sensory measurement
            likelihood = vonmpdf(this.snsSpc, snsMsmt, this.intNoise);
            score = likelihood .* this.ivsPrior;
            
            stmScore = interp1(this.ivsStmSpc, score, this.stmSpc, 'linear', 'extrap');
            
            % L2 loss, posterior mean
            posteriorDist = stmScore / trapz(this.stmSpc, stmScore);
            posteriorMass = posteriorDist * this.stepSize;
            
            % Calculate circular mean with helper function
            estimate = circularMean(this.stmSpc, posteriorMass);
        end
        
        function [domain, probDnst] = estimatePDF(this, theta)
            % Return the distribution of estimate p(theta_hat | theta)
            % Measurement distribution
            thetaTilde = interp1(this.stmSpc, this.mapping, theta, 'linear', 'extrap');
            msmtDist = vonmpdf(this.snsSpc, thetaTilde, this.intNoise);
            
            % Change of variable from measurement to estimate
            probDnst = abs(gradient(this.snsSpc, this.estimates)) .* msmtDist;
            
            domain = this.stmSpc; validIdx = 3:(length(probDnst)-2);
            probDnst = interp1(this.estimates(validIdx), probDnst(validIdx), domain, 'linear', 'extrap');
        end
        
        function [thetas, bias, densityGrid] = computeGrid(this, varargin)
            % Compute a grid representation of orientation - bias PDF
            p = inputParser;
            p.addParameter('StepSize', 0.05, @(x)(isnumeric(x) && numel(x) == 1));
            parse(p, varargin{:});
            
            biasLB = -pi; biasUB = pi; bias = biasLB : p.Results.StepSize : biasUB;
            thetas = 0 : p.Results.StepSize : 2 * pi;
            
            densityGrid = zeros(length(bias), length(thetas));
            for idx = 1:length(thetas)
                [ests, prob] = this.estimatePDF(thetas(idx));
                [biasEstimate, sortIdx] = sort(wrapToPi(ests - thetas(idx)));
                prob = prob(sortIdx);
                
                densityGrid(:, idx) = interp1(biasEstimate, prob, bias, 'linear', 'extrap');
            end
        end
        
        function [thetas, bias, densityGrid] = visualizeGrid(this, varargin)
            p = inputParser;
            p.addParameter('StepSize', 0.05, @(x)(isnumeric(x) && numel(x) == 1));
            p.addParameter('ShowPlot', true, @(x) islogical(x));
            parse(p, varargin{:});
            
            [thetas, bias, densityGrid] = computeGrid(this, 'StepSize', p.Results.StepSize);
            
            thetas = this.convertAxis(thetas);
            bias = this.convertAxis(bias);
            [X, Y] = meshgrid(thetas, bias);
            
            if p.Results.ShowPlot
                surf(X, Y, densityGrid); view([0, 90]);
                xlim([0, 180]); ylim([-90, 90]);
                xlabel('Orientation'); ylabel('Bias');
            end
        end
        
        function [stimDomain, msmtDomain, densityGrid] = visualizeMeasurement(this, varargin)
            p = inputParser;
            p.addParameter('StepSize', 0.05, @(x)(isnumeric(x) && numel(x) == 1));
            parse(p, varargin{:});
            
            stimDomain = 0 : p.Results.StepSize : 2 * pi;
            msmtDomain = 0 : p.Results.StepSize : 2 * pi;
            
            densityGrid = zeros(length(stimDomain), length(msmtDomain));
            for idx = 1:length(stimDomain)
                theta = stimDomain(idx);
                
                thetaTilde = interp1(this.stmSpc, this.mapping, theta, 'linear', 'extrap');
                msmtDist = vonmpdf(this.snsSpc, thetaTilde, this.intNoise);
                
                % Change of variable from sensory space to stimulus
                probDist = abs(gradient(this.snsSpc, this.ivsStmSpc)) .* msmtDist;
                probDist = interp1(this.ivsStmSpc, probDist, msmtDomain);
                
                densityGrid(:, idx) = probDist;
            end
        end
        
        function [thetas, estimate, biasLB, biasUB] = visualization(this, varargin)
            % Visualize the bias and distribution of estimates pattern
            p = inputParser;
            p.addParameter('StepSize', 0.05, @(x)(isnumeric(x) && numel(x) == 1));
            p.addParameter('Interval', 0.68, @(x)(isnumeric(x) && numel(x) == 1));
            parse(p, varargin{:});
            delta = p.Results.StepSize;
            
            [thetas, bias, densityGrid] = this.computeGrid('StepSize', delta);
            
            estimate = zeros(1, length(thetas));
            biasLB = zeros(1, length(thetas));
            biasUB = zeros(1, length(thetas));
            
            for idx = 1:length(thetas)
                probDnst = densityGrid(:, idx);
                estimate(idx) = circularMean(wrapTo2Pi(bias), probDnst' * delta);
                [biasLB(idx), biasUB(idx)] = ...
                    this.intervalEstimate(bias, probDnst, p.Results.Interval);
            end
            
            thetas = this.convertAxis(thetas); estimate = this.convertAxis(wrapToPi(estimate));
            biasLB = this.convertAxis(biasLB); biasUB = this.convertAxis(biasUB);
        end
        
        function [thetas, estimate, biasLB, biasUB] = visualizeCurve(this, varargin)
            [thetas, estimate, biasLB, biasUB] = this.visualization(varargin{:});
            errorbar(thetas, estimate, estimate - biasLB, biasUB - estimate, 'LineWidth', 1.0);
            
            xlim([0, 180]); ylim([-90, 90]);
            xlabel('Orientation'); ylabel('Bias');
        end
        
    end
    
    methods (Access = public)
        
        function [estLB, estUB] = intervalEstimate(~, support, probDnst, ci)
            % Helper function for plotting the distribution of estimates
            [cdf, uIdx] = unique(cumtrapz(support, probDnst), 'stable');
            quantileLB = (1 - ci) / 2;
            quantileUB = 1 - quantileLB;
            
            estLB = interp1(cdf, support(uIdx), quantileLB, 'linear', 'extrap');
            estUB = interp1(cdf, support(uIdx), quantileUB, 'linear', 'extrap');
        end
        
        function support = convertAxis(~, support)
            support = support / (2 * pi) * 180;
        end
        
    end
    
end