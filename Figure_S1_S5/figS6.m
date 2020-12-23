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
para = fmincon(@(x) lossFunc(x, 0.59), 0.5, [], [], [], [], 0, 1)
para = fmincon(@(x) lossFunc(x, 0.55), 0.5, [], [], [], [], 0, 1)
para = fmincon(@(x) lossFunc(x, 0.51), 0.5, [], [], [], [], 0, 1)

%% Helper function

function loss = lossFunc(priorNoNoise, priorData)

stepSize = 0.01; 
stmSpc = 0 : stepSize : 2 * pi;
prior = priorHandle(priorNoNoise);

FI = 16.5 * prior(stmSpc);
estVar = 1 ./ FI;

noiseVar = estVar + 0.18 * mean(estVar);
noiseFI = 1 ./ noiseVar;
noisePrior = noiseFI ./ trapz(stmSpc, noiseFI);

dataPrior = priorHandle(priorData);

loss = norm(noisePrior - dataPrior(stmSpc));

end