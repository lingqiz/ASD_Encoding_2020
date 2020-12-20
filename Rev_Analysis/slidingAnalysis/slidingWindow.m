function [allPrior, allFisher] = slidingWindow(targetData, responseData, varargin)

nSubject = length(targetData);
assert(nSubject == length(responseData));

p = inputParser;
p.addParameter('binSize', 0.40);
p.addParameter('delta', 0.02);
p.addParameter('nBootstrap', 500);
p.addParameter('nBins', 20);
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
    
    [prior, fisher] = bootstrap(target', response', nBootstrap, nBins);
        
    allPrior = [allPrior, prior'];
    allFisher = [allFisher, fisher'];
end

