function [target, response] = resample(target, response)
nData = length(target);
assert(length(target) == length(response))

index = 1:nData;
sampleIdx = datasample(index, nData);

target = target(sampleIdx);
response = response(sampleIdx);
end