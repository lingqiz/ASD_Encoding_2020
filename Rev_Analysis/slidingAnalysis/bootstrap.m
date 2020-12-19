function [scale, noise] = bootstrap(allTarget, allResponse, nBootstrap, nBins)
    scale = zeros(1, nBootstrap);
    noise = zeros(1, nBootstrap);
    
    parfor idx = 1:nBootstrap
        [target, response] = resample(allTarget, allResponse);
        [scale(idx), noise(idx)] = fitExtract(target, response, nBins);
    end
end