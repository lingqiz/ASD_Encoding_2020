%% Figure format
try 
    plotlabOBJ = plotlab();
    plotlabOBJ.applyRecipe(...
        'figureWidthInches', 15, ...
        'figureHeightInches', 10);
catch EXP
    fprintf('plotlab not available, use default MATLAB style \n');
end
    
%% Plot histogram of RT data
nPlot = 6;
dataDir = {'TD woFB', 'TD wFB1', 'TD wFB2', 'ASD woFB', 'ASD wFB1', 'ASD wFB2'};
for idx = 1:nPlot
    subplot(2, 3, idx);
    RT = extractRT(idx);
    histogram(RT, 45, 'Normalization', 'probability');
    title(dataDir(idx));
    
    xlim([0, 25]);
    ylim([0, 0.16]);
    box off;
    
    RT = sort(RT);
    avgRT = median(RT);
    
    % bootstrap for getting +/- SD
    nResample = 1e3;
    allRT = zeros(1, nResample);
    for idy = 1:nResample
        index = 1:length(RT);
        sampleIdx = datasample(index, length(RT));
        allRT(idy) = median(RT(sampleIdx));
    end
    
    avgLine = xline(avgRT, '--k', 'LineWidth', 2);
    text(avgRT + 1, max(ylim) * 0.95, sprintf('%.2f +/- %.3f', avgRT, std(allRT)));
    
    xlabel('RT (sec)');
    ylabel('Probability');
end

%% Test for differences
[~, p1] = kstest2(extractRT(1), extractRT(4));
fprintf('woFB, p value: %.10f \n', p1);

[~, p2] = kstest2(extractRT(2), extractRT(5));
fprintf('wFB1, p value: %.10f \n', p2);

[~, p3] = kstest2(extractRT(3), extractRT(6));
fprintf('wFB2, p value: %.10f \n', p3);