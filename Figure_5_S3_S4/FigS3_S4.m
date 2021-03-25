%% Add path
addpath('./cbrewer/');
addpath('./CircStat/');
addpath('./Figure_5_S3_S4/');

%% Prepare data for correlation analysis
[prior_td, noise_td]   = collectFit('./woFB/TD/*.mat', './wFB1/TD/*.mat', './wFB2/TD/*.mat', 25);
[prior_asd, noise_asd] = collectFit('./woFB/ASD/*.mat', './wFB1/ASD/*.mat', './wFB2/ASD/*.mat', 17);

%% Plot figures S3
% Note for convenience, we saved all the paramters extracted with the function above 
% together with the clinical data in the .mat file below
load('para_clinical.mat');
scoreID = 5;

figure(); 
set(gcf,'Position',[0, 0, 1000, 1000]);

%% prior woFB
subplot(2, 2, 3);
sessionID = 2; % Before learning
corrPlotPrior(prior_td, prior_asd, sessionID, scoreID, 'AQ', 'Prior woFB', [0.0, 1.0], 0 : 0.2 : 1);

%% prior wFB2
subplot(2, 2, 4);
sessionID = 4; % After learning
corrPlotPrior(prior_td, prior_asd, sessionID, scoreID, 'AQ', 'Prior wFB2', [0.0, 1.0], 0 : 0.2 : 1);

%% FI woFB
subplot(2, 2, 1);
sessionID = 2; % Before learning
corrPlotFI(noise_td, noise_asd, sessionID, scoreID, 'AQ', 'FI woFB', [5, 30], 5 : 5 : 30);

%% FI wFB2
subplot(2, 2, 2);
sessionID = 4; % After learning
corrPlotFI(noise_td, noise_asd, sessionID, scoreID, 'AQ', 'FI wFB2', [5, 30], 5 : 5 : 30);

%% Plot figures S4
% Note for convenience, we saved all the paramters extracted with the function above 
% together with the clinical data in the .mat file below
load('para_clinical.mat');
scoreID = 6;

figure(); 
set(gcf,'Position',[0, 0, 1000, 1000]);

%% prior woFB
subplot(2, 2, 3);
sessionID = 2; % Before learning
corrPlotPrior(prior_td, prior_asd, sessionID, scoreID, 'SCQ', 'Prior woFB', [0.0, 1.0], 0 : 0.2 : 1);

%% prior wFB2
subplot(2, 2, 4);
sessionID = 4; % After learning
corrPlotPrior(prior_td, prior_asd, sessionID, scoreID, 'SCQ', 'Prior wFB2', [0.0, 1.0], 0 : 0.2 : 1);

%% FI woFB
subplot(2, 2, 1);
sessionID = 2; % Before learning
corrPlotFI(noise_td, noise_asd, sessionID, scoreID, 'SCQ', 'FI woFB', [5, 30], 5 : 5 : 30);

%% FI wFB2
subplot(2, 2, 2);
sessionID = 4; % After learning
corrPlotFI(noise_td, noise_asd, sessionID, scoreID, 'SCQ', 'FI wFB2', [5, 30], 5 : 5 : 30);

%% Helper functions
function corrPlotPrior(td, asd, sID, cID, xStr, yStr, ylimArray, ytickArray)

colormap = cbrewer('seq', 'YlGnBu', 9);
color_td = colormap(7, :);

colormap = cbrewer('seq', 'YlOrRd', 9);
color_asd = colormap(7, :);

scatter(td(:, cID), td(:, sID), 40, color_td, 'filled');
hold on;
scatter(asd(:, cID), asd(:, sID), 40, color_asd, 'filled');
xlabel(xStr);
ylabel(yStr);

lm = fitlm([td(:, cID); asd(:, cID)], [td(:, sID); asd(:, sID)], ...
    'linear', 'RobustOpts', 'on')
% lm.Coefficients

line = plot(xlim(), xlim() * lm.Coefficients.Estimate(2) + lm.Coefficients.Estimate(1), '--k', 'LineWidth', 2);
ylim(ylimArray);
yticks(ytickArray);

errorbar(min(xlim()) + 1, median(td(:, sID)), std(td(:, sID)) ...
    / sqrt(length(td(:, sID))), 'o', 'Color', color_td, 'LineWidth', 1.5);

errorbar(max(xlim()) - 1, median(asd(:, sID)), std(asd(:, sID)) ...
    / sqrt(length(asd(:, sID))), 'o', 'Color', color_asd, 'LineWidth', 1.5);

ylim(ylimArray);
yticks(ytickArray);

end

function corrPlotFI(td, asd, sID, cID, xStr, yStr, ylimArray, ytickArray)

colormap = cbrewer('seq', 'YlGnBu', 9);
color_td = colormap(7, :);

colormap = cbrewer('seq', 'YlOrRd', 9);
color_asd = colormap(7, :);

scatter(td(:, cID), td(:, sID), 40, color_td, 'filled');
hold on;
scatter(asd(:, cID), asd(:, sID), 40, color_asd, 'filled');
xlabel(xStr);
ylabel(yStr);

lm = fitlm([td(:, cID); asd(:, cID)], [td(:, sID); asd(:, sID)])
% lm.Coefficients

line = plot(xlim(), xlim() * lm.Coefficients.Estimate(2) + lm.Coefficients.Estimate(1), '--k', 'LineWidth', 2);
ylim(ylimArray);
yticks(ytickArray);

errorbar(min(xlim()) + 1, median(td(:, sID)), std(td(:, sID)) ...
    / sqrt(length(td(:, sID))), 'o', 'Color', color_td, 'LineWidth', 1.5);

errorbar(max(xlim()) - 1, median(asd(:, sID)), std(asd(:, sID)) ...
    / sqrt(length(asd(:, sID))), 'o', 'Color', color_asd, 'LineWidth', 1.5);

ylim(ylimArray);
yticks(ytickArray);

end

function [priorPara, noisePara] = collectFit(dirWoFB, dirWFB1, dirWFB2, nSubject)

    function input = wrapOrientation(input)
        assert(sum(input > 360) == 0 && sum(input < 0) == 0);
        input(input > 180) = input(input > 180) - 180;
    end

    function idx = extractID(strName)
        idx = str2double(strName(2:3));
        if isnan(idx)
            idx = str2double(strName(2));
        end
    end

    function loadPlot(fileDir, plotOrder)
        count = 1;
        files = dir(fileDir);
        
        for file = files'
            data = load(fullfile(file.folder, file.name));
            target   = data.all_data(1, :);
            response = data.all_data(2, :);
            
            data_idx = target > 0;
            target = wrapOrientation(target(data_idx));
            response = wrapOrientation(response(data_idx));
            
            [thisScale, thisNoise] = fitExtract(target', response', 8, false, true, false, zeros(1, 3));
            priorPara(count, plotOrder + 1) = thisScale;
            noisePara(count, plotOrder + 1) = thisNoise;
            
            if plotOrder == 3
                idx = extractID(file.name);
                priorPara(count, 1) = idx;
                noisePara(count, 1) = idx;
            end
            
            count = count + 1;
        end
    end

priorPara = zeros(nSubject, 4);
noisePara = zeros(nSubject, 4);

loadPlot(dirWoFB, 1);
loadPlot(dirWFB1, 2);
loadPlot(dirWFB2, 3);

end

