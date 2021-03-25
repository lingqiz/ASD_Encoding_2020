%% Add path
addpath('CircStat/');
addpath('cbrewer/');
addpath('Figure_1_S7_S8/');

%% Construct prior
domain = 0 : 0.01 : 2 * pi;
vonmPrior = @(x) vonmpdf(x, pi, 0.5);

figure();
plot(convertAxis(domain), vonmPrior(domain), 'k', 'LineWidth', 2);

xlabel('Angle (deg)');
ylabel('Probability density');
ylim([0, 0.3]);

set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');

%% Construct estimator
estimator = BayesianEstimator(0.5, 5.0, 'PriorHandle', vonmPrior);
estimator.computeEstimator();

% Measurement distribution
[stimDomain, msmtDomain, densityGrid] = estimator.visualizeMeasurement('StepSize', 0.005);
[X, Y] = meshgrid(stimDomain, msmtDomain);

% imagesc flip
imagesc(stimDomain, msmtDomain, flip(densityGrid));
colormap gray;
colorbar;

xticks(0 : 0.5 * pi : 2 * pi);
xticklabels(0 : 45 : 180);

yticks(0 : 0.5 * pi : 2 * pi);
yticklabels(0 : 45 : 180);

axis square;
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');

xlabel('Stimulus');
ylabel('Measurement');

%% Estimator mapping
figure();
% plot(estimator.snsSpc(2:end), estimator.estimates(2:end), 'k', 'LineWidth', 2);
plot(estimator.ivsStmSpc(2:end), estimator.estimates(2:end), 'k', 'LineWidth', 2);
hold on;
xlim([0, 2 * pi]); ylim([0, 2 * pi]);
plot(xlim, ylim, '--k');

xlabel('Measurement');
ylabel('Estimate');

% Arbitrarily change the mapping
caseId = 1;
switch caseId
    case 0
        
    case 1
        hold on;
        estimator.estimates = estimator.snsSpc;
        plot(estimator.ivsStmSpc, estimator.estimates, 'r', 'LineWidth', 2);
    case 2
        mappingValue = interp1(estimator.estimates(2:end), estimator.snsSpc(2:end), estimator.snsSpc, 'linear', 'extrap');
        
        hold on;
        plot(estimator.ivsStmSpc, mappingValue, 'r', 'LineWidth', 2);
        estimator.estimates = mappingValue;
    case 3
        mappingValue = estimator.snsSpc + 0.25 * cos(estimator.snsSpc);
        
        hold on;
        plot(estimator.ivsStmSpc, mappingValue, 'r', 'LineWidth', 2);
        estimator.estimates = mappingValue;
    case 4
        mappingValue = estimator.snsSpc + 0.25 * sin(estimator.snsSpc + 1);
        
        hold on;
        plot(estimator.ivsStmSpc, mappingValue, 'r', 'LineWidth', 2);
        estimator.estimates = mappingValue;
    case 5
        mappingValue = estimator.estimates();
        mappingValue = (mappingValue - estimator.snsSpc) * 1.25 + estimator.snsSpc;
        mappingValue = interp1(estimator.snsSpc(2:end), mappingValue(2:end), estimator.snsSpc, 'linear', 'extrap');
        
        plot(estimator.ivsStmSpc, mappingValue, 'r', 'LineWidth', 2);
        estimator.estimates = mappingValue;
    case 6
        mappingValue = estimator.snsSpc + 0.1 * cos(3 * estimator.snsSpc);
        
        hold on;
        plot(estimator.ivsStmSpc, mappingValue, 'r', 'LineWidth', 2);
        estimator.estimates = mappingValue;      
end

axis square;
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');

xticks(0 : 0.5 * pi : 2 * pi)
xticklabels(0 : 45 : 180);

yticks(0 : 0.5 * pi : 2 * pi)
yticklabels(0 : 45 : 180);

xlabel('Measurement');
ylabel('Estimate');

%% Grid representation
figure();
stepSize = 0.01;
[thetas, bias, densityGrid] = estimator.visualizeGrid('StepSize', stepSize, 'ShowPlot', false);

thetas = thetas / 180 * (2 * pi);
bias   = bias / 180 * (2 * pi);

imagesc(thetas, bias, densityGrid);
colormap gray;
colorbar;

%% Add homogeneous motor noise (convolution)
motorNoise = false;
if motorNoise
    delta = 0.01;
    kappa = 10;
    domain = -pi : delta : pi;
    vonmKernel = vonmpdf(domain, 0, kappa) * delta;
    
    densityGrid = convGrid(densityGrid, vonmKernel);
    
    figure();
    imagesc(thetas, bias, densityGrid);
    colormap gray;
    colorbar;
    
end
%% Bias and variance of the estimator
expBias = zeros(size(thetas));
varBias = zeros(size(thetas));

for idx = 1:length(thetas)
    density = densityGrid(:, idx);
    
    thisBias = trapz(bias, bias' .* density);
    expBias(idx) = thisBias;
    
    thisVar  = trapz(bias, ((bias - thisBias) .^ 2)' .* density);
    varBias(idx) = thisVar;
end

% Plot
plotColor = 'k';

figure(); subplot(1, 2, 1);
plot(convertAxis(thetas), convertAxis(expBias), plotColor, 'LineWidth', 2);
hold on;
plot([0, 180], [0, 0], '--k', 'LineWidth', 2);

set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');
title('bias');
xlabel('Angle (deg)');
ylim([-15, 15]);

xticks(0 : 45 : 180)
xticklabels(0 : 45 : 180);

subplot(1, 2, 2);
plot(convertAxis(thetas), convertAxis(sqrt(varBias)), plotColor, 'LineWidth', 2);
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');
title('variance');
set(gcf, 'Position',  [0, 0, 900, 300]);
xlabel('Angle (deg)');
ylim([6, 24]);

xticks(0 : 45 : 180)
xticklabels(0 : 45 : 180);

derivative = diff(expBias) / stepSize;

figure(); subplot(1, 2, 1);
fisher = ((1 + derivative) .^ 2) ./ varBias(2:end);
sqrtFI = sqrt(fisher);
plot(convertAxis(thetas(2:end)), sqrtFI, plotColor, 'LineWidth', 2);
set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');
title('Fisher Information');
xlabel('Angle (deg)');

subplot(1, 2, 2);
normCnst = trapz(thetas(2:end), sqrtFI);
plot(convertAxis(thetas(2:end)), sqrt(fisher) ./ normCnst, plotColor, 'LineWidth', 2);

hold on;
plot(convertAxis(thetas(2:end)), vonmPrior(thetas(2:end)), '--r', 'LineWidth', 2);

title('Normalized');
xlabel('Angle (deg)');

set(gca, 'box', 'off')
set(gca, 'TickDir', 'out');
set(gcf, 'Position',  [0, 0, 900, 300]);

%% Helper function
function support = convertAxis(support)
support = support / (2 * pi) * 180;
end

function densityGrid = convGrid(densityGrid, convKernel)
for idx = 1:size(densityGrid, 2)
    densityGrid(:, idx) = conv(densityGrid(:, idx), convKernel, 'same');
end
end
