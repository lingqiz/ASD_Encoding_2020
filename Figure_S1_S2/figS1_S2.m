%% path and variable
dataDir = './woFB/TD/*.mat';
addpath('CircStat/');
addpath('cbrewer/');
addpath('Figure_S1_S2/');

%% Plot individual data - TD
% Control
colormap = cbrewer('seq', 'YlGnBu', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);
plotColor = [color1; color2; color3];

RSqr_Ctr = plotSubject('./woFB/TD/*.mat', './wFB1/TD/*.mat', './wFB2/TD/*.mat', plotColor, true);
set(gcf, 'Position',  [0, 0, 2000, 1000])

fprintf('average R-square: %.3f, ', mean(RSqr_Ctr));
fprintf('SEM: %.3f \n', std(RSqr_Ctr) / sqrt(length(RSqr_Ctr)));

%% Plot individual data - ASD
colormap = cbrewer('seq', 'YlOrRd', 9);
color1 = colormap(9, :);
color2 = colormap(7, :);
color3 = colormap(5, :);
plotColor = [color1; color2; color3];

RSqr_ASD = plotSubject('./woFB/ASD/*.mat', './wFB1/ASD/*.mat', './wFB2/ASD/*.mat', plotColor, false);
set(gcf, 'Position',  [0, 0, 2000, 1000])

fprintf('average R-square: %.3f, ', mean(RSqr_ASD));
fprintf('SEM: %.3f \n', std(RSqr_ASD) / sqrt(length(RSqr_ASD)));

%% Helper functions
function RSqr = plotSubject(dirWoFB, dirWFB1, dirWFB2, plotColor, control)
figure();
    function input = wrapOrientation(input)
        assert(sum(input > 360) == 0 && sum(input < 0) == 0);
        input(input > 180) = input(input > 180) - 180;
    end

    function allRSqr = loadPlot(fileDir, plotOrder)
        count = 1;
        files = dir(fileDir);
        
        allRSqr = [];
        for file = files'
            data = load(fullfile(file.folder, file.name));
            target   = data.all_data(1, :);
            response = data.all_data(2, :);
            
            data_idx = target > 0;
            target = wrapOrientation(target(data_idx));
            response = wrapOrientation(response(data_idx));
            
            plotIdx = (count - 1) * 3;
            subplot(5, 15, plotIdx + plotOrder);
            colors = plotColor;
            
            [~, ~, ~, ~, rSqr] = fitExtract(target', response', 10, true, true, true, colors(plotOrder, :));
            allRSqr = [allRSqr, rSqr];            
            
            if(mod(count, 5) == 1 && plotOrder == 1)
                yTarget = -30 : 10 : 30;
                yticks(yTarget / 90 * pi);
                yticklabels(yTarget);
            else
                yticks([]);
            end
            
            if control
                if(count > 20)
                    xticks([0, 0.5 * pi, pi, 1.5 * pi, 2 * pi]);
                    xticklabels({'0', '45', '90', '135', '180'});
                else
                    xticks([]);
                end
                
                if plotOrder == 2
                    title(strcat('Control - ', num2str(count)));
                else
                    title(' ');
                end
            else
                if(count > 12)
                    xticks([0, 0.5 * pi, pi, 1.5 * pi, 2 * pi]);
                    xticklabels({'0', '45', '90', '135', '180'});
                else
                    xticks([]);
                end
                
                if plotOrder == 2
                    title(strcat('ASD - ', num2str(count)));
                else
                    title(' ');
                end                
            end
            
            grid off;
            count = count + 1;
        end
    end

RSqr1 = loadPlot(dirWoFB, 1);
RSqr2 = loadPlot(dirWFB1, 2);
RSqr3 = loadPlot(dirWFB2, 3);

RSqr = [RSqr1, RSqr2, RSqr3];

end
