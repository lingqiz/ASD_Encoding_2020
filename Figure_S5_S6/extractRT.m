function RT = extractRT(index)

dataDir = {'TD_woFB', 'TD_wFB1', 'TD_wFB2', 'ASD_woFB', 'ASD_wFB1', 'ASD_wFB2'};
fullDir = strcat('./DataMat/', dataDir{index}, '/*.mat');

files = dir(fullDir);

RT = [];
for file = files'
    data = load(fullfile(file.folder, file.name));
    
    rt = data.all_data(3, :);
    rt = rt(rt < 2.5e4);
    
    RT = [RT, rt];
end

% ms -> sec
RT = RT ./ 1000;
end

