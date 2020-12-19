sessionID = 1;
dataDir = {'TD_woFB', 'TD_wFB1', 'TD_wFB2', 'ASD_woFB', 'ASD_wFB1', 'ASD_wFB2'};
fullDir = strcat('./DataMat/', dataDir{sessionID}, '/*.mat');

files = dir(fullDir);

targetData = {[], []};
responseData = {[], []};

for file = files'
    data = load(fullfile(file.folder, file.name));
    
    targetBlock   = data.all_data(1, :);
    responseBlock = data.all_data(2, :);
    
    nData = length(targetBlock);
    assert(nData == length(responseBlock));
    
    nData = floor(nData / 2);
    for idx = 1:2
        target = targetBlock((idx - 1) * nData + 1 : idx * nData);
        response = responseBlock((idx - 1) * nData + 1 : idx * nData);
        
        data_idx = target > 0;
        target = wrapOrientation(target(data_idx));
        response = wrapOrientation(response(data_idx));
        
        targetData{idx} = [targetData{idx}, target];
        responseData{idx} = [responseData{idx}, response];
    end
end

block = {'_FH', '_SH'};
for idx = 1:2
    allTarget = targetData{idx};
    allResponse = responseData{idx};
    
    save(strcat(dataDir{sessionID}, block{idx}), 'allTarget', 'allResponse');
end

function input = wrapOrientation(input)
assert(sum(input > 360) == 0 && sum(input < 0) == 0);
input(input > 180) = input(input > 180) - 180;
end
