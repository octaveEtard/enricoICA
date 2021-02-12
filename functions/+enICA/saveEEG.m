function EEG = saveEEG(EEG,fileName,saveFolder)
% save EEG & print comments to standalone log file

% fileName now without extension
[~,fileName,ext] = fileparts(fileName);

if isempty(ext)
    ext = '.set';
end

if ~exist(saveFolder,'dir')
    mkdir(saveFolder);
end

% save
EEG = pop_saveset(EEG, 'filename', [fileName,ext], 'filepath', saveFolder);

% print comments to standalone log file
log = cellstr(EEG.comments);
fileID = fopen(fullfile(saveFolder,[fileName,'.log']),'w');
fprintf(fileID,'%s\n',log{:});
fclose(fileID);
end
%
%