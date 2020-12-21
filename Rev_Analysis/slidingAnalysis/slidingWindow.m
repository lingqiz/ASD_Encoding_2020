function [allPrior, allFisher, allBias, allVariance] = slidingWindow(targetData, responseData, varargin)

nSubject = length(targetData);
assert(nSubject == length(responseData));

p = inputParser;
p.addParameter('binSize', 0.30);
p.addParameter('delta', 0.025);
p.addParameter('nBootstrap', 500);
p.addParameter('nBins', 15);
parse(p, varargin{:});

% sliding window through temporal data
binSize = p.Results.binSize;
delta = p.Results.delta;

% analysis for each temporal window
nBootstrap = p.Results.nBootstrap;
nBins = p.Results.nBins;

% run analysis
allPrior = [];
allFisher = [];
allBias = [];
allVariance = [];
for binEdge = 0 : delta : (1 - binSize)
    target = [];
    response = [];
        
    for idx = 1 : nSubject
        subTarget = targetData{idx};
        subResponse = responseData{idx};
        
        nData = length(subTarget);
        assert(nData == length(subResponse));
        
        idxLB = floor(binEdge * nData);
        if(idxLB == 0)
            idxLB = 1;
        end
        
        idxUB = floor((binEdge + binSize) * nData);
        
        target = [target, subTarget(idxLB : idxUB)];
        response = [response, subResponse(idxLB : idxUB)];
    end
    
    [prior, fisher, bias, variance] = bootstrap(target', response', nBootstrap, nBins);
        
    allPrior = [allPrior, prior'];
    allFisher = [allFisher, fisher'];
    allBias = [allBias, bias'];
    allVariance = [allVariance, variance'];
end

allBias = allBias ./ (2 * pi) * 180.0;
allVariance = allVariance ./ (2 * pi) * 180.0;
