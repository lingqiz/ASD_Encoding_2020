function [scale, noise, average, spread, prior, range, total, rmse] = extractPriorLegacy(target, response, nBins, showPlot)

% convert to [0, 2 pi] range
target = target / 180 * (2 * pi);
response = response / 180 * (2 * pi);

delta = (2*pi / nBins) / 2;
range = 0: 0.05: 2*pi;

average = zeros(1, length(range));
spread  = zeros(1, length(range));
rmse = zeros(1, length(range));

for idx = 1:length(range)
    binLB = range(idx) - delta;
    binUB = range(idx) + delta;
    
    if binLB < 0
        binLB = wrapTo2Pi(binLB);
        binData = response(target >= binLB | target <= binUB);
        binTarget = target(target >= binLB | target <= binUB);
    elseif binUB > 2 * pi
        binUB = wrapTo2Pi(binUB);
        binData = response(target >= binLB | target <= binUB);
        binTarget = target(target >= binLB | target <= binUB);
    else
        binData = response(target >= binLB & target <= binUB);
        binTarget = target(target >= binLB & target <= binUB);
    end
        
    meanRes = circ_mean(binData);
    average(idx) = wrapToPi(meanRes - range(idx));
    spread(idx)  = circ_kappa(binData);
        
    rmse(idx) = sqrt(1/length(binData)*(sum((wrapToPi(binData - binTarget)) .^ 2)));
end

% calculate fisher information
spread = 1 ./ spread;
fisher = (1 + gradient(average, range)) ./ sqrt(abs(spread));
total = trapz(range, fisher);
prior = fisher ./ total;

% noise = trapz(range, fisher);
% loss  = @(priorScale) priorLoss(priorScale, range, prior);
% scale = fmincon(loss, 1, [], [], [], [], 0, 1);
noise = 0; scale = 0;

if showPlot    
    figure();
    subplot(3, 1, 1);
    plot(range, average, 'k', 'LineWidth', 2);
    grid on; xlim([0, 2 * pi]);
    title('Bias');
    
    subplot(3, 1, 2);
    plot(range, sqrt(abs(spread)), 'k', 'LineWidth', 2);
    grid on; xlim([0, 2 * pi]);
    title('SD');
    
    subplot(3, 1, 3);        
    plot(range, prior, 'k', 'LineWidth', 2);
    grid on; hold on; xlim([0, 2 * pi]);
        
    priorDist = priorHandle(scale);
    domain = 0 : 0.025 : 2 * pi;
    plot(domain, priorDist(domain), '--k', 'LineWidth', 2);
    title('Sqrt Fisher');        
end    

    function loss = priorLoss(priorScale, center, value)
        priorFunc = priorHandle(priorScale);
        loss = norm(priorFunc(center) - value);
    end

end

