%% Add path
addpath('CircStat/');
addpath('cbrewer/');
addpath('Figure_S1_S5/');

%% Simulation
[domain1, fisher1] = fisherPlot(0.5, 5.0, 1);

figure();
plot(domain1, fisher1, 'LineWidth', 2);
hold on;

[domain2, fisher2] = fisherPlot(0.5, 5.0, 0);
plot(domain2, fisher2, 'LineWidth', 2);
hold on;

[domain3, fisher3] = fisherPlot(0.5, 5.0, 4);
plot(domain3, fisher3, 'LineWidth', 2);

xticks(0 : 45 : 180)
xticklabels(0 : 45 : 180);
ylim([0, 4]);

set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');

function [domain, fisher] = fisherPlot(priorPara, noisePara, caseID)

vonmPrior = @(x) vonmpdf(x, pi, priorPara);

estimator = BayesianEstimator(1.0, noisePara, 'PriorHandle', vonmPrior);
estimator.computeEstimator();

switch caseID
    case 0
        
    case 1
        estimator.estimates = estimator.snsSpc;
    case 2
        mappingValue = interp1(estimator.estimates(2:end), estimator.snsSpc(2:end), estimator.snsSpc, 'linear', 'extrap');
        estimator.estimates = mappingValue;
    case 3
        mappingValue = estimator.snsSpc + 0.5 * sin(estimator.snsSpc);
        estimator.estimates = mappingValue;
    case 4
        mappingValue = estimator.snsSpc + 0.25 * sin(estimator.snsSpc + 1.0);
        estimator.estimates = mappingValue;
end

stepSize = 0.01;
[thetas, bias, densityGrid] = estimator.visualizeGrid('StepSize', stepSize, 'ShowPlot', false);

thetas = thetas / 180 * (2 * pi);
bias   = bias / 180 * (2 * pi);

expBias = zeros(size(thetas));
varBias = zeros(size(thetas));

for idx = 1:length(thetas)
    density = densityGrid(:, idx);
    
    thisBias = trapz(bias, bias' .* density);
    expBias(idx) = thisBias;
    
    thisVar  = trapz(bias, ((bias - thisBias) .^ 2)' .* density);
    varBias(idx) = thisVar;
end

derivative = diff(expBias) / stepSize;
fisher = ((1 + derivative) .^ 2) ./ varBias(2:end);
sqrtFI = sqrt(fisher);

domain = convertAxis(thetas(2:end));
fisher = sqrtFI;

end

function support = convertAxis(support)

support = support / (2 * pi) * 180;

end
