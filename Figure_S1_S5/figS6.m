%% Change of parameter due to noise
stepSize = 0.01; 
stmSpc = 0 : stepSize : 2 * pi;
prior = priorHandle(0.71);

FI = 16.5 * prior(stmSpc);
estVar = 1 ./ FI;

angle = stmSpc / (2 * pi) * 180;
figure();
subplot(1, 2, 1);
plot(angle, prior(stmSpc), 'k', 'LineWidth', 2);
set(gca,'TickDir','out');
xticks([0, 45, 90, 135, 180]);

subplot(1, 2, 2);
plot(angle, FI, 'k', 'LineWidth', 2);
trapz(stmSpc, FI)

noiseVar = estVar + 0.18 * mean(estVar);
noiseFI = 1 ./ noiseVar;
noisePrior = noiseFI ./ trapz(stmSpc, noiseFI);

subplot(1, 2, 1); hold on;
plot(angle, noisePrior, '--k', 'LineWidth', 2);
set(gca,'TickDir','out');
xlim([0, 180]);
xticks([0, 45, 90, 135, 180]);

prior = priorHandle(0.6);
plot(angle, prior(stmSpc), 'r', 'LineWidth', 2);

subplot(1, 2, 2); hold on;
plot(angle, noiseFI, '--k', 'LineWidth', 2);
trapz(stmSpc, noiseFI)
xticks([0, 45, 90, 135, 180]);
xlim([0, 180]);

%% Search procedure
para_woFB = fmincon(@(x) lossFunc(x, 0.59, 16.75, 0.18), 0.5, [], [], [], [], 0, 1);
para_wFB1 = fmincon(@(x) lossFunc(x, 0.55, 16.75, 0.18), 0.5, [], [], [], [], 0, 1);
para_wFB2 = fmincon(@(x) lossFunc(x, 0.51, 16.75, 0.18), 0.5, [], [], [], [], 0, 1);

figure(); subplot(1, 2, 1); hold on;
errorbar(0.8, mean(scale_woFB_td, 2), std(scale_woFB_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(2.0, mean(scale_wFB1_td, 2), std(scale_wFB1_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(3.2, mean(scale_wFB2_td, 2), std(scale_wFB2_td, 0, 2), '--ob', 'LineWidth', 2);

l1 = plot([0.8, 2, 3.2], mean([scale_woFB_td; scale_wFB1_td; scale_wFB2_td], 2), '--b', 'LineWidth', 2);

errorbar(0.8, mean(scale_woFB_asd, 2), std(scale_woFB_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(2.0, mean(scale_wFB1_asd, 2), std(scale_wFB1_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(3.2, mean(scale_wFB2_asd, 2), std(scale_wFB2_asd, 0, 2), '--or', 'LineWidth', 2);

l2 = plot([0.8, 2, 3.2], mean([scale_woFB_asd; scale_wFB1_asd; scale_wFB2_asd], 2), '--r', 'LineWidth', 2);

errorbar(0.8, para_woFB, std(scale_woFB_asd, 0, 2), '--ok', 'LineWidth', 2);
errorbar(2.0, para_wFB1, std(scale_wFB1_asd, 0, 2), '--ok', 'LineWidth', 2);
errorbar(3.2, para_wFB2, std(scale_wFB2_asd, 0, 2), '--ok', 'LineWidth', 2);

l3 = plot([0.8, 2, 3.2], [para_woFB; para_wFB1; para_wFB2], '--k', 'LineWidth', 2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]); ylim([0.25, 0.8]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
legend([l1, l2, l3], {'TD', 'ASD', 'Simulation'});

subplot(1, 2, 2); hold on;

errorbar(0.8, mean(noise_woFB_td, 2), std(noise_woFB_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(2.0, mean(noise_wFB1_td, 2), std(noise_wFB1_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(3.2, mean(noise_wFB2_td, 2), std(noise_wFB2_td, 0, 2), '--ob', 'LineWidth', 2);

l1 = plot([0.8, 2, 3.2], mean([noise_woFB_td; noise_wFB1_td; noise_wFB2_td], 2), '--b', 'LineWidth', 2);

errorbar(0.8, mean(noise_woFB_asd, 2), std(noise_woFB_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(2.0, mean(noise_wFB1_asd, 2), std(noise_wFB1_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(3.2, mean(noise_wFB2_asd, 2), std(noise_wFB2_asd, 0, 2), '--or', 'LineWidth', 2);

l2 = plot([0.8, 2, 3.2], mean([noise_woFB_asd; noise_wFB1_asd; noise_wFB2_asd], 2), '--r', 'LineWidth', 2);

errorbar(0.8, 16.75, std(scale_woFB_asd, 0, 2), '-ok', 'LineWidth', 2);
errorbar(2.0, 16.75, std(scale_wFB1_asd, 0, 2), '-ok', 'LineWidth', 2);
errorbar(3.2, 16.75, std(scale_wFB2_asd, 0, 2), '-ok', 'LineWidth', 2);

l3 = plot([0.8, 2, 3.2], [16.75, 16.75, 16.75], '--k', 'LineWidth', 2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
legend([l1, l2, l3], {'TD', 'ASD', 'Simulation'});

%% For control group
para_woFB = fmincon(@(x) lossFunc(x, 0.54, 18.83, 0.085), 0.5, [], [], [], [], 0, 1);
para_wFB1 = fmincon(@(x) lossFunc(x, 0.40, 18.83, 0.085), 0.5, [], [], [], [], 0, 1);
para_wFB2 = fmincon(@(x) lossFunc(x, 0.34, 18.83, 0.0), 0.5, [], [], [], [], 0, 1);

figure(); subplot(1, 2, 1); hold on;
errorbar(0.8, mean(scale_woFB_td, 2), std(scale_woFB_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(2.0, mean(scale_wFB1_td, 2), std(scale_wFB1_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(3.2, mean(scale_wFB2_td, 2), std(scale_wFB2_td, 0, 2), '--ob', 'LineWidth', 2);

l1 = plot([0.8, 2, 3.2], mean([scale_woFB_td; scale_wFB1_td; scale_wFB2_td], 2), '--b', 'LineWidth', 2);

errorbar(0.8, mean(scale_woFB_asd, 2), std(scale_woFB_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(2.0, mean(scale_wFB1_asd, 2), std(scale_wFB1_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(3.2, mean(scale_wFB2_asd, 2), std(scale_wFB2_asd, 0, 2), '--or', 'LineWidth', 2);

l2 = plot([0.8, 2, 3.2], mean([scale_woFB_asd; scale_wFB1_asd; scale_wFB2_asd], 2), '--r', 'LineWidth', 2);

errorbar(0.8, para_woFB, std(scale_woFB_asd, 0, 2), '--ok', 'LineWidth', 2);
errorbar(2.0, para_wFB1, std(scale_wFB1_asd, 0, 2), '--ok', 'LineWidth', 2);
errorbar(3.2, para_wFB2, std(scale_wFB2_asd, 0, 2), '--ok', 'LineWidth', 2);

l3 = plot([0.8, 2, 3.2], [para_woFB; para_wFB1; para_wFB2], '--k', 'LineWidth', 2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]); ylim([0.25, 0.8]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
legend([l1, l2, l3], {'TD', 'ASD', 'Simulation'});

subplot(1, 2, 2); hold on;

errorbar(0.8, mean(noise_woFB_td, 2), std(noise_woFB_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(2.0, mean(noise_wFB1_td, 2), std(noise_wFB1_td, 0, 2), '--ob', 'LineWidth', 2);
errorbar(3.2, mean(noise_wFB2_td, 2), std(noise_wFB2_td, 0, 2), '--ob', 'LineWidth', 2);

l1 = plot([0.8, 2, 3.2], mean([noise_woFB_td; noise_wFB1_td; noise_wFB2_td], 2), '--b', 'LineWidth', 2);

errorbar(0.8, mean(noise_woFB_asd, 2), std(noise_woFB_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(2.0, mean(noise_wFB1_asd, 2), std(noise_wFB1_asd, 0, 2), '--or', 'LineWidth', 2);
errorbar(3.2, mean(noise_wFB2_asd, 2), std(noise_wFB2_asd, 0, 2), '--or', 'LineWidth', 2);

l2 = plot([0.8, 2, 3.2], mean([noise_woFB_asd; noise_wFB1_asd; noise_wFB2_asd], 2), '--r', 'LineWidth', 2);

errorbar(0.8, 18.83, std(scale_woFB_asd, 0, 2), '-ok', 'LineWidth', 2);
errorbar(2.0, 18.83, std(scale_wFB1_asd, 0, 2), '-ok', 'LineWidth', 2);
errorbar(3.2, 18.83, std(scale_wFB2_asd, 0, 2), '-ok', 'LineWidth', 2);

l3 = plot([0.8, 2, 3.2], [18.83, 18.83, 18.83], '--k', 'LineWidth', 2);

xlim([0.5, 3.5]); xticks([0.8, 2, 3.2]);
xticklabels({'woFB', 'wFB1', 'wFB2'});
legend([l1, l2, l3], {'TD', 'ASD', 'Simulation'});

%% Helper function

function loss = lossFunc(priorNoNoise, priorData, totalFI, noiseRatio)

stepSize = 0.01; 
stmSpc = 0 : stepSize : 2 * pi;
prior = priorHandle(priorNoNoise);

FI = totalFI * prior(stmSpc);
estVar = 1 ./ FI;

noiseVar = estVar + noiseRatio * mean(estVar);
noiseFI = 1 ./ noiseVar;
noisePrior = noiseFI ./ trapz(stmSpc, noiseFI);

dataPrior = priorHandle(priorData);

loss = norm(noisePrior - dataPrior(stmSpc));

end