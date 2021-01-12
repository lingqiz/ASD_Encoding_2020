%% Add path
addpath('../CircStat');
addpath('../cbrewer/');
addpath('./slidingAnalysis/');

%% Run sliding window analysis: TD
paraPlot = figure();
statPlot = figure();

colormap = cbrewer('seq', 'YlGnBu', 9);
dataSet = {'TD_woFB.mat', 'TD_wFB1.mat', 'TD_wFB2.mat'};

analysisPlot(dataSet, colormap, paraPlot, statPlot);

% Run sliding window analysis: ASD
colormap = cbrewer('seq', 'YlOrRd', 9);
dataSet = {'ASD_woFB.mat', 'ASD_wFB1.mat', 'ASD_wFB2.mat'};

analysisPlot(dataSet, colormap, paraPlot, statPlot);

%% Add labels
figure(paraPlot);
subplot(1, 2, 1);
xticks([0.75, 2.75, 4.75]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
xlabel('FB block');
ylim([0.0, 0.8]);
title('Prior Omega');

subplot(1, 2, 2);
xticks([0.75, 2.75, 4.75]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
xlabel('FB block');
yticks(10:2:20);
ylim([10, 20]);
title('Fisher Lambda');

figure(statPlot);
subplot(1, 2, 1);
xticks([0.75, 2.75, 4.75]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
ylim([2, 9]);
title('Bias');

subplot(1, 2, 2);
xticks([0.75, 2.75, 4.75]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
ylim([8, 17]);
title('Variance');

%% Sliding window through entire dataset: TD
paraPlot = figure();
statPlot = figure();

load('TD_woFB.mat');
dataSet = {'TD_wFB1.mat', 'TD_wFB2.mat'};
colormap = cbrewer('seq', 'YlGnBu', 9);
pltColor = colormap(7, :);

for nDataset = 1:length(dataSet)
    dataset = load(dataSet{nDataset});
    
    for idx = 1:length(targetData)
        targetData{idx} = [targetData{idx}, dataset.targetData{idx}];
        responseData{idx} = [responseData{idx}, dataset.responseData{idx}];
    end
end

binSize = 0.20;
[allPrior, allFisher, allBias, allVariance] = ...
    slidingWindow(targetData, responseData, 'binSize', binSize, ...
    'delta', 0.01, 'nBootstrap', 500, 'nBins', 30);

figure(paraPlot);
xLB = 0; xUB = 6;
plotTemporal(allPrior, allFisher, pltColor, xLB, xUB);

figure(statPlot);
plotTemporal(allBias, allVariance, pltColor, xLB, xUB);

%% Sliding window through entire dataset: ASD
load('ASD_woFB.mat');
dataSet = {'ASD_wFB1.mat', 'ASD_wFB2.mat'};
colormap = cbrewer('seq', 'YlOrRd', 9);
pltColor = colormap(7, :);

for nDataset = 1:length(dataSet)
    dataset = load(dataSet{nDataset});
    
    for idx = 1:length(targetData)
        targetData{idx} = [targetData{idx}, dataset.targetData{idx}];
        responseData{idx} = [responseData{idx}, dataset.responseData{idx}];
    end
end

[allPrior, allFisher, allBias, allVariance] = ...
    slidingWindow(targetData, responseData, 'binSize', binSize, ...
    'delta', 0.01, 'nBootstrap', 500, 'nBins', 30);

figure(paraPlot);
plotTemporal(allPrior, allFisher, pltColor, xLB, xUB);

figure(statPlot);
plotTemporal(allBias, allVariance, pltColor, xLB, xUB);

%% Format figure
figure(paraPlot);
subplot(1, 2, 1); hold on;
xticks([]); xlim([xLB-0.2, xUB+0.2]);
xlabel('Trial Order');
xline((1/3 - binSize) * xUB, '--');
xline((2/3 - binSize) * xUB, '--');
ylim([0.2, 0.7]);
yticks(0.2:0.1:0.7);
title('Prior Omega');

subplot(1, 2, 2); hold on;
xticks([]); xlim([xLB-0.2, xUB+0.2]);
xlabel('Trial Order');
xline((1/3 - binSize) * xUB, '--');
xline((2/3 - binSize) * xUB, '--');
yticks(10:2:20); ylim([10, 20]);
title('Fisher Lambda');

figure(statPlot);
subplot(1, 2, 1);
xticks([]); xlim([xLB-0.2, xUB+0.2]);
xlabel('Trial Order');
ylim([2, 9]);
title('Bias');

subplot(1, 2, 2);
xticks([]); xlim([xLB-0.2, xUB+0.2]);
xlabel('Trial Order');
ylim([8, 17]);
title('Variance');

%% Helper function
function analysisPlot(dataSet, colormap, paraPlot, statPlot)

for idx = 1:length(dataSet)
    load(dataSet{idx});
    [allPrior, allFisher, allBias, allVariance] = slidingWindow(targetData, responseData);    
    
    figure(paraPlot);
    pltColor = colormap(11-2*idx, :);
    plotTemporal(allPrior, allFisher, pltColor, 2*idx-2, 2*idx-0.5)    
    
    figure(statPlot);
    plotTemporal(allBias, allVariance, pltColor, 2*idx-2, 2*idx-0.5)    
end

end

function plotTemporal(allPrior, allFisher, pltColor, xLB, xUB)

nPoint = size(allPrior, 2);

subplot(1, 2, 1); hold on;
meanVal = mean(allPrior, 1);
stdVal = std(allPrior);

shadedplot(linspace(xLB, xUB, nPoint), meanVal - stdVal, meanVal + stdVal, pltColor, pltColor);
plot(linspace(xLB, xUB, nPoint), meanVal, 'LineWidth', 1.5, 'Color', pltColor);

subplot(1, 2, 2); hold on;
meanVal = mean(allFisher, 1);
stdVal = std(allFisher);

shadedplot(linspace(xLB, xUB, nPoint), meanVal - stdVal, meanVal + stdVal, pltColor, pltColor);
plot(linspace(xLB, xUB, nPoint), meanVal, 'LineWidth', 1.5, 'Color', pltColor);

end
