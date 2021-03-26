% Plot bias & fit curve from two example subject
% Method figure
%% Add path
addpath('./CircStat/');
addpath('./cbrewer/');
addpath('./Figure_2/');

%% Plot individual data - TD
% Control, Subject #1
% Color for woFB, wFB1, wFB2
colormap = cbrewer('seq', 'YlGnBu', 9);
color1 = colormap(9, :); 
color2 = colormap(7, :);
color3 = colormap(5, :);
plotColor = [color1; color2; color3];

subID = 1;
plotSubject('./woFB/TD/*.mat', './wFB1/TD/*.mat', './wFB2/TD/*.mat', 'Control-', './SubjectPlot/TD', plotColor, subID, false, true);

%% Plot individual data - ASD
% ASD - Subject #6
colormap = cbrewer('seq', 'YlOrRd', 9);
color1 = colormap(9, :); 
color2 = colormap(7, :);
color3 = colormap(5, :);
plotColor = [color1; color2; color3];

subID = 6;
plotSubject('./woFB/ASD/*.mat', './wFB1/ASD/*.mat', './wFB2/ASD/*.mat', 'ASD-', './SubjectPlot/ASD', plotColor, subID, true, false)

%% Helper function
function plotSubject(dirWoFB, dirWFB1, dirWFB2, titleStr, saveBaseDir, colors, targetIdx, ~, showTitle)

    function input = wrapOrientation(input)
        assert(sum(input > 360) == 0 && sum(input < 0) == 0);
        input(input > 180) = input(input > 180) - 180;
    end

    function noise = loadPlot(fileDir, plotOrder, ~, ~, colors)
        count = 1;
        files = dir(fileDir);
        plotIdx = [1 5; 2 6; 3 7];
        
        for file = files'
            if count == targetIdx
                data = load(fullfile(file.folder, file.name));
                target   = data.all_data(1, :);
                response = data.all_data(2, :);
                
                data_idx = target > 0;
                target = wrapOrientation(target(data_idx));
                response = wrapOrientation(response(data_idx));
                
                figure(count);
                subplot(2, 4, plotIdx(plotOrder, :));
                
                nBins = 8;
                [scale, noise, l1, l2] = fitExtract(target', response', nBins, true, false, true, colors(plotOrder, :));
                
                xticks([0, 0.5 * pi, pi, 1.5 * pi, 2 * pi]);
                xticklabels({'0', '45', '90', '135', '180'});
                xlabel('target $ \theta (^{\circ}) $', 'interpreter', 'latex');
                
                yTarget = -30 : 10 : 30;
                yticks(yTarget / 90 * pi);
                yticklabels(yTarget);
                ylabel('bias $$ (^{\circ}) $$', 'interpreter', 'latex');
                
                ax = gca;
                ax.XGrid = 'off';
                ax.YGrid = 'off';
                ax.GridLineStyle = '-';
                
                hold on;
                plot(xlim, [0, 0], 'k', 'LineWidth', 1);
                plot([0.5 * pi, 0.5 * pi], ylim, 'k--', 'LineWidth', 1);
                plot([pi, pi], ylim, 'k--', 'LineWidth', 1);
                plot([1.5 * pi, 1.5 * pi], ylim, 'k--', 'LineWidth', 1);                                
                
                if(plotOrder == 1)
                    legend([l1, l2], {'data', 'model'})
                end
                
                if(plotOrder ~= 1)
                    ylabel('');
                    set(gca,'ytick',[])
                    set(gca,'yticklabel',[])
                end
                
                if(showTitle)
                    switch plotOrder
                        case 1
                            title('woFB', 'interpreter', 'latex');
                        case 2
                            title('wFB1', 'interpreter', 'latex');
                        case 3
                            title('wFB2', 'interpreter', 'latex');
                    end
                else
                    title('');
                end
                
                subplot(2, 4, 4); hold on; grid on;
                priorDist = priorHandle(scale);
                domain = 0 : 0.025 : 2 * pi;
                if(plotOrder == 3 && targetIdx == 6)
                    plot(domain, priorDist(domain), '--', 'Color', colors(plotOrder, :), 'LineWidth', 2);
                else
                    plot(domain, priorDist(domain), 'Color', colors(plotOrder, :), 'LineWidth', 2);
                end
                
                if(plotOrder == 3)
                    % legend({'woFB', 'wFB1', 'wFB2'});
                end
                
                xticks([0, 0.5 * pi, pi, 1.5 * pi, 2 * pi]);
                xticklabels({'0', '45', '90', '135', '180'});
                xlabel('target $ \theta (^{\circ}) $', 'interpreter', 'latex');
                ylabel('$$ p(\theta) $$', 'interpreter', 'latex');
                xlim([0, 2 * pi]); ylim([0, 0.35]);
                title('$ \omega $ - ``Prior"', 'interpreter', 'latex');
                
                ax = gca;
                ax.XGrid = 'off';
                ax.YGrid = 'off';
                ax.GridLineStyle = '-';
                
                hold on;                
                plot([0.5 * pi, 0.5 * pi], ylim, 'k--', 'LineWidth', 1);
                plot([pi, pi], ylim, 'k--', 'LineWidth', 1);
                plot([1.5 * pi, 1.5 * pi], ylim, 'k--', 'LineWidth', 1); 
                
            end
            count = count + 1;
        end
    end

n1 = loadPlot(dirWoFB, 1, titleStr, saveBaseDir, colors);
n2 = loadPlot(dirWFB1, 2, titleStr, saveBaseDir, colors);
n3 = loadPlot(dirWFB2, 3, titleStr, saveBaseDir, colors);

subplot(2, 4, [8]); hold on;
plot([0.8, 2, 3.2], [n1, n2, n3], '-o', 'Color', colors(2, :), 'LineWidth', 2);

xlabel('FB block ', 'interpreter', 'latex');
ylabel(' $ \int \sqrt{I_{F}(\theta)} d \theta $)', 'interpreter', 'latex');
ylim([12, 20]); title('$ \lambda $ - Total $ \sqrt{I_{F}(\theta)} $', 'interpreter', 'latex')
xticks([0.8, 2, 3.2]); xticklabels({'woFB', 'wFB1', 'wFB2'});

end
