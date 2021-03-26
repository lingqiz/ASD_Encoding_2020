%% SETUP
stepSize = 0.01; 
stmSpc = 0 : stepSize : 2 * pi;
prior = priorHandle(0.6);

natural = 2 - abs(sin(stmSpc));
natural = natural / trapz(stmSpc, natural);

FI = 15 * prior(stmSpc);

estVar = 1 ./ FI;
addNoise = [0, 0.05, 0.2, 0.5, 1, 2];
colorSeq = [0, 0.2, 0.4, 0.6, 0.8, 0.9];

%% SIM
figure();
angle = stmSpc / (2 * pi) * 180;
for idx = 1:length(addNoise)
    noiseVar = estVar + mean(estVar) * addNoise(idx);
    noiseFI = 1 ./ noiseVar;
    noisePrior = noiseFI ./ trapz(stmSpc, noiseFI);
    
    subplot(1, 2, 1); hold on;
    plot(angle, noiseFI, 'LineWidth', 2, 'Color', ones(1, 3) * colorSeq(idx));
    ylim([0, 5.5]);
    set(gca,'TickDir','out');
    xticks([0, 45, 90, 135, 180]);
    
    subplot(1, 2, 2); hold on;
    plot(angle, noisePrior, 'LineWidth', 2, 'Color', ones(1, 3) * colorSeq(idx));
    ylim([0, 0.35]);
    xticks([0, 45, 90, 135, 180]);
    set(gca,'TickDir','out');
end
