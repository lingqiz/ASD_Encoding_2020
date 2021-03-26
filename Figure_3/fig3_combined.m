%% TD Group - Bias Plot
addpath('./CircStat');
addpath('./cbrewer/');
addpath('./Figure_3/');

%% Number of bootstrap, we used 5,000 our analysis
% Statistical tests are based on bootstrap samples
nBootstrap = 5000;

nBins = 30; 
errScale = 1;
colormap = cbrewer('seq', 'YlGnBu', 9);

color1 = colormap(9, :); 
color2 = colormap(7, :); 
color3 = colormap(5, :);

%% Plot for control subject
load('woFB_td.mat');
[~, allBias_woFB, allVariance_woFB, allFisher_woFB, allTotal_woFB, allRMSE_woFB] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB1_td.mat');
[~, allBias_wFB1, allVariance_wFB1, allFisher_wFB1, allTotal_wFB1, allRMSE_wFB1] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB2_td.mat');
[range, allBias_wFB2, allVariance_wFB2, allFisher_wFB2, allTotal_wFB2, allRMSE_wFB2] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

%% Plot
figure(1);
l1 = plotExtract(range, allBias_woFB, allVariance_woFB, allFisher_woFB, allRMSE_woFB, 1, color1, true, errScale, 1);
l2 = plotExtract(range, allBias_wFB1, allVariance_wFB1, allFisher_wFB1, allRMSE_wFB1, 1, color2, true, errScale, 2);
l3 = plotExtract(range, allBias_wFB2, allVariance_wFB2, allFisher_wFB2, allRMSE_wFB2, 1, color3, true, errScale, 3);
set(gcf,'Position',[0, 0, 900, 400]);

%% histogram of total fisher
figure(2);
h1 = histogram(allTotal_woFB, 'Normalization', 'probability'); hold on;
h2 = histogram(allTotal_wFB1, 'Normalization', 'probability');
h3 = histogram(allTotal_wFB2, 'Normalization', 'probability');

h1.FaceColor = color1; h1.EdgeColor = color1;
h2.FaceColor = color2; h2.EdgeColor = color2;
h3.FaceColor = color3; h3.EdgeColor = color3;
xlim([10, 18]); ylim([0, 0.12]);

xlabel('$$ \int \sqrt{I_{F}(\theta)} d \theta $$', 'interpreter', 'latex');
set(gca,'ytick',[])
set(gca,'yticklabel',[])

%% ASD Group
% Number of bootstrap, we used 5,000 our analysis
% Statistical tests are based on bootstrap samples
nBootstrap = 5000;

nBins = 30;
errScale = 1;
colormap = cbrewer('seq', 'YlOrRd', 9);

color1 = colormap(9, :); 
color2 = colormap(7, :); 
color3 = colormap(5, :); 

load('woFB_asd.mat');
[~, allBias_woFB, allVariance_woFB, allFisher_woFB, allTotal_woFB, allRMSE_woFB] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB1_asd.mat');
[~, allBias_wFB1, allVariance_wFB1, allFisher_wFB1, allTotal_wFB1, allRMSE_wFB1] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB2_asd.mat');
[range, allBias_wFB2, allVariance_wFB2, allFisher_wFB2, allTotal_wFB2, allRMSE_wFB2] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

%% Plot for asd group
figure(1);

l1 = plotExtract(range, allBias_woFB, allVariance_woFB, allFisher_woFB, allRMSE_woFB, 2, color1, true, errScale, 1);
l2 = plotExtract(range, allBias_wFB1, allVariance_wFB1, allFisher_wFB1, allRMSE_wFB1, 2, color2, true, errScale, 2);
l3 = plotExtract(range, allBias_wFB2, allVariance_wFB2, allFisher_wFB2, allRMSE_wFB2, 2, color3, true, errScale, 3);

%% histogram of total fisher
figure(3);
h1 = histogram(allTotal_woFB, 'Normalization', 'probability'); hold on;
h2 = histogram(allTotal_wFB1, 'Normalization', 'probability');
h3 = histogram(allTotal_wFB2, 'Normalization', 'probability');

h1.FaceColor = color1; h1.EdgeColor = color1;
h2.FaceColor = color2; h2.EdgeColor = color2;
h3.FaceColor = color3; h3.EdgeColor = color3;
xlim([10, 18]); ylim([0, 0.12]);

xlabel('$$ \int \sqrt{I_{F}(\theta)} d \theta $$', 'interpreter', 'latex');
set(gca,'ytick',[])
set(gca,'yticklabel',[])

%% Format
figure(1);
subplot(2, 4, 1); ylabel('bias $$ (^{\circ}) $$', 'interpreter', 'latex');
subplot(2, 4, 2); ylabel('variance $$ (1/\kappa) $$', 'interpreter', 'latex');
yticks(0.05 : 0.1 : 0.45);
subplot(2, 4, 3); ylabel('$$ \sqrt{I_{F}(\theta)} / \int \sqrt{I_{F}(\theta)} d \theta $$', 'interpreter', 'latex');
yticks(0.0 : 0.1 : 0.4);
subplot(2, 4, 4); ylabel('$$ RMSE $$', 'interpreter', 'latex');

subplot(2, 4, 5); xlabel('target $ \theta (^{\circ}) $', 'interpreter', 'latex');
subplot(2, 4, 6); xlabel('target $ \theta (^{\circ}) $', 'interpreter', 'latex');
yticks(0.05 : 0.1 : 0.45);
subplot(2, 4, 7); xlabel('target $ \theta (^{\circ}) $', 'interpreter', 'latex');
yticks(0.0 : 0.1 : 0.4);

%% Helper function
function [range, bias, variance, fisher, total, rmse] = extractData(allTarget, allResponse, nBins)

showPlot = false;
[~, ~, average, spread, prior, range, total, rmse] = extractPriorLegacy(allTarget, allResponse, nBins, showPlot);

% smooth the pattern for plotting
bias     = smooth(average);
variance = smooth(spread, 0.1);
fisher   = smooth(prior, 0.1);
rmse     = smooth(rmse, 0.1);
end

function [range, allBias, allVariance, allFisher, allTotal, allRMSE] = bootstrap(allTarget, allResponse, nBootstrap, nBins)
[range, bias, variance, fisher, total, rmse] = extractData(allTarget, allResponse, nBins);

allBias = zeros(length(bias), nBootstrap);
allVariance = zeros(length(variance), nBootstrap);
allFisher = zeros(length(fisher), nBootstrap);
allTotal  = zeros(length(total),  nBootstrap);
allRMSE   = zeros(length(rmse),   nBootstrap);
parfor idx = 1:nBootstrap
    [target, response] = resample(allTarget, allResponse);
    [~, bias, variance, fisher, total, rmse] = extractData(target, response, nBins);
    
    allBias(:, idx) = bias;
    allVariance(:, idx) = variance;
    allFisher(:, idx) = fisher;
    allTotal(idx) = total;
    allRMSE(:, idx) = rmse;
end
end

function pltLine = plotExtract(range, allBias, allVariance, allFisher, allRMSE, rowIdx, pltColor, shaded, errScale, offSet)
xAxisMax = 185;
xAxisShift = 182;
% plot 1
subplot(2, 4, (rowIdx - 1) * 4 + 1); hold on;

yPlot = mean(allBias, 2) / pi * 90;
yStd  = std(allBias, 0, 2) / pi * 90;

lineWidth = 1.5;
pltLine = plot(range / (2 * pi) * 180, yPlot, 'Color', pltColor, 'LineWidth', lineWidth);
plotCore(range, yPlot, yStd, pltColor, shaded, errScale);

xlim([0, xAxisMax]); ylim([-12, 12]); % ylabel('deg', 'interpreter', 'latex');
xticks([0 45 90 135 180]);

ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'off';

hold on;
plot(xlim, [0, 0], 'k', 'LineWidth', 1);
plot([45, 45], ylim, 'k--', 'LineWidth', 1);
plot([90, 90], ylim, 'k--', 'LineWidth', 1);
plot([135, 135], ylim, 'k--', 'LineWidth', 1);

avgVal = mean(abs(allBias), 1);
avgStd = std(avgVal) / pi * 90;
avgVal = mean(avgVal) / pi * 90;
errorbar(xAxisShift + offSet, avgVal, avgStd, 'o', 'Color', pltColor, 'LineWidth', 2);

% plot 2
subplot(2, 4, (rowIdx - 1) * 4 + 2); hold on;

yPlot = mean(allVariance, 2);
yStd  = std(allVariance, 0, 2);

plot(range / (2 * pi) * 180, yPlot, 'Color', pltColor, 'LineWidth', lineWidth);
plotCore(range, yPlot, yStd, pltColor, shaded, errScale)

xlim([0, xAxisMax]); ylim([0.05, 0.45]); % ylabel('rad $$ ^{2} $$', 'interpreter', 'latex');
xticks([0 45 90 135 180]);

ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'off';

hold on;
plot([45, 45], ylim, 'k--', 'LineWidth', 1);
plot([90, 90], ylim, 'k--', 'LineWidth', 1);
plot([135, 135], ylim, 'k--', 'LineWidth', 1);

avgVal = mean(allVariance, 1);
avgStd = std(avgVal);
avgVal = mean(avgVal);
errorbar(xAxisShift + offSet, avgVal, avgStd, 'o', 'Color', pltColor, 'LineWidth', 2);

% plot 3
subplot(2, 4, (rowIdx - 1) * 4 + 3); hold on;

yPlot = mean(allFisher, 2);
yStd  = std(allFisher, 0, 2);

plot(range / (2 * pi) * 180, yPlot, 'Color', pltColor, 'LineWidth', lineWidth);
plotCore(range, yPlot, yStd, pltColor, shaded, errScale)

xlim([0, 180]); ylim([0, 0.4]); % ylabel('rad $$ ^{-2} $$', 'interpreter', 'latex');
xticks([0 45 90 135 180]);

ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'off';

hold on;
plot([45, 45], ylim, 'k--', 'LineWidth', 1);
plot([90, 90], ylim, 'k--', 'LineWidth', 1);
plot([135, 135], ylim, 'k--', 'LineWidth', 1);

% plot 4
subplot(2, 4, (rowIdx - 1) * 4 + 4); hold on;

yPlot = mean(allRMSE, 2) / pi * 90;
yStd  = std(allRMSE, 0, 2) / pi * 90;

lineWidth = 1.5;
pltLine = plot(range / (2 * pi) * 180, yPlot, 'Color', pltColor, 'LineWidth', lineWidth);
plotCore(range, yPlot, yStd, pltColor, shaded, errScale);

xlim([0, xAxisMax]); ylim([5, 25]);
xticks([0 45 90 135 180]);

ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'off';

hold on;
plot([45, 45], ylim, 'k--', 'LineWidth', 1);
plot([90, 90], ylim, 'k--', 'LineWidth', 1);
plot([135, 135], ylim, 'k--', 'LineWidth', 1);

avgVal = mean(allRMSE, 1);
avgStd = std(avgVal) / pi * 90;
avgVal = mean(avgVal) / pi * 90;
errorbar(xAxisShift + offSet, avgVal, avgStd, 'o', 'Color', pltColor, 'LineWidth', 2);

end

function plotCore(range, yPlot, yStd, pltColor, shaded, errScale)

if(shaded)
    shadedplot(range / (2 * pi) * 180, (yPlot - errScale*yStd)', (yPlot + errScale*yStd)', pltColor, pltColor);
else
    errorbar(range / (2 * pi) * 180, yPlot, errScale*yStd, 'LineWidth', 2, 'Color', pltColor);
end

end

