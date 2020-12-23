%% Add path
addpath('./CircStat');
addpath('./cbrewer/');
addpath('./Figure_4/');

%% TD Group Level
nBootstrap = 5e2; nBins = 45;
load('woFB_td.mat');
[scale_woFB_td, noise_woFB_td] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB1_td.mat');
[scale_wFB1_td, noise_wFB1_td] = bootstrap(allTarget', allResponse', nBootstrap, nBins);
 
load('wFB2_td.mat');
[scale_wFB2_td, noise_wFB2_td] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

%% ASD Group Level
nBootstrap = 5e2; nBins = 45;
load('woFB_asd.mat');
[scale_woFB_asd, noise_woFB_asd] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB1_asd.mat');
[scale_wFB1_asd, noise_wFB1_asd] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

load('wFB2_asd.mat');
[scale_wFB2_asd, noise_wFB2_asd] = bootstrap(allTarget', allResponse', nBootstrap, nBins);

%% Plot Parameter Change - Prior
figure; subplot(1, 2, 1);
hold on;
white = ones(1, 3);

% Control
colormap = cbrewer('seq', 'YlGnBu', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);

errorbar(0.8, mean(scale_woFB_td, 2), std(scale_woFB_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color1);
errorbar(2.0, mean(scale_wFB1_td, 2), std(scale_wFB1_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color2);
errorbar(3.2, mean(scale_wFB2_td, 2), std(scale_wFB2_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color3);

plot([0.8, 2, 3.2], mean([scale_woFB_td; scale_wFB1_td; scale_wFB2_td], 2), '--', 'LineWidth', 2, 'Color', color2);

% ASD
colormap = cbrewer('seq', 'YlOrRd', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);

errorbar(0.8, mean(scale_woFB_asd, 2), std(scale_woFB_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color1);
errorbar(2.0, mean(scale_wFB1_asd, 2), std(scale_wFB1_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color2);
errorbar(3.2, mean(scale_wFB2_asd, 2), std(scale_wFB2_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color3);

plot([0.8, 2, 3.2], mean([scale_woFB_asd; scale_wFB1_asd; scale_wFB2_asd], 2), '--', 'LineWidth', 2, 'Color', color2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]); ylim([0.25, 0.75]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
xlabel('FB block ', 'interpreter', 'latex');

ylabel('$ \omega $', 'interpreter', 'latex'); yticks(10 : 2 : 20); yticks(0.2:0.1:0.7);
title('$$ \omega $$ - ``Prior"', 'interpreter', 'latex');

hold on;
plot(xlim, [0.5, 0.5], 'Color', 0.75*ones(1, 3), 'LineWidth', 1);

%% Plot Parameter Change - Fisher Information
subplot(1, 2, 2);
hold on;

% Control
colormap = cbrewer('seq', 'YlGnBu', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);

errorbar(0.8, mean(noise_woFB_td, 2), std(noise_woFB_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color1);
errorbar(2.0, mean(noise_wFB1_td, 2), std(noise_wFB1_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color2);
errorbar(3.2, mean(noise_wFB2_td, 2), std(noise_wFB2_td, 0, 2), '--o', 'LineWidth', 2, 'Color', color3);

l1 = plot([0.8, 2, 3.2], mean([noise_woFB_td; noise_wFB1_td; noise_wFB2_td], 2), '--', 'LineWidth', 2, 'Color', color2);

% ASD
colormap = cbrewer('seq', 'YlOrRd', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);

errorbar(0.8, mean(noise_woFB_asd, 2), std(noise_woFB_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color1);
errorbar(2.0, mean(noise_wFB1_asd, 2), std(noise_wFB1_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color2);
errorbar(3.2, mean(noise_wFB2_asd, 2), std(noise_wFB2_asd, 0, 2), '--o', 'LineWidth', 2, 'Color', color3);

l2 = plot([0.8, 2, 3.2], mean([noise_woFB_asd; noise_wFB1_asd; noise_wFB2_asd], 2), '--', 'LineWidth', 2, 'Color', color2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]); ylim([10, 20]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
xlabel('FB block ', 'interpreter', 'latex');

ylabel('$ \lambda $', 'interpreter', 'latex'); yticks(10 : 2 : 20);
title('$$ \lambda $$ - Total $$ \sqrt{I_{F}(\theta)} $$', 'interpreter', 'latex');

legend([l1, l2], {'Control', 'ASD'});

%% Helper (bootstrap) function
function [scale, noise] = bootstrap(allTarget, allResponse, nBootstrap, nBins)
    scale = zeros(1, nBootstrap);
    noise = zeros(1, nBootstrap);
    
    parfor idx = 1:nBootstrap
        [target, response] = resample(allTarget, allResponse);
        [scale(idx), noise(idx)] = fitExtract(target, response, nBins);
    end
end