function [average, spread, range] = extractPrior(target, response, nBins, mirror, plotData, plotColor)

if ~exist('mirror','var')
    mirror = false;
end

% convert to [0, 2 pi] range
target = target / 180 * (2 * pi);
response = response / 180 * (2 * pi);

if plotData
    scatter(target, wrapToPi(response - target), 10, plotColor);
end

% mirroring the data
if mirror
    target_lh   = target(target <= pi) + pi;
    response_lh = response(target <= pi) + pi;
    
    target_hh   = target(target > pi) - pi;
    response_hh = response(target > pi) - pi;
    
    target   = wrapTo2Pi([target; target_lh; target_hh]);
    response = wrapTo2Pi([response; response_lh; response_hh]);
end

% bias & variance calculation
delta = (2*pi / nBins) / 2;
range = 0: 0.025: 2*pi;

average = zeros(1, length(range));
spread  = zeros(1, length(range));

for idx = 1:length(range)
    binLB = range(idx) - delta;
    binUB = range(idx) + delta;
    
    if binLB < 0
        binLB = wrapTo2Pi(binLB);
        binData = response(target >= binLB | target <= binUB);
    elseif binUB > 2 * pi
        binUB = wrapTo2Pi(binUB);
        binData = response(target >= binLB | target <= binUB);
    else
        binData = response(target >= binLB & target <= binUB);
    end
    
    meanRes = circ_mean(binData);
    average(idx) = wrapToPi(meanRes - range(idx));
    spread(idx)  = circ_kappa(binData);
end

spread = 1 ./ spread;

end

