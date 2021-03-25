% combine data into the same file

dataDir = {'TD_woFB', 'TD_wFB1', 'TD_wFB2', 'ASD_woFB', 'ASD_wFB1', 'ASD_wFB2'};
for sesID = 1:length(dataDir)
    
    targetData = {};
    responseData = {};
    
    fullDir = strcat('./DataMat/', dataDir{sesID}, '/*.mat');
    files = dir(fullDir);
    
    for file = files'
        data = load(fullfile(file.folder, file.name));
        target = data.all_data(1, :);
        response = data.all_data(2, :);
        
        validIdx = target > 0;
        target = wrapOrientation(target(validIdx));
        response = wrapOrientation(response(validIdx));
        
        targetData{end + 1} = target;
        responseData{end + 1} = response;
    end
    
    save(dataDir{sesID}, 'targetData', 'responseData');
    
end

function input = wrapOrientation(input)

assert(sum(input > 360) == 0 && sum(input < 0) == 0);
input(input > 180) = input(input > 180) - 180;

end
