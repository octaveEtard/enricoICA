function downsampleBP(allSID,conditions,parts,inFile,filtOpt)
%
% Load EEG data, filter & resample
%
nSub = numel(allSID);
nCond = numel(conditions);

% where to save processed EEG data
baseFolder_save = enICA.getPath('EEG','processed');

saveOpt.do = false;

% string describing processing
if isempty(inFile.proc) || strcmp(inFile.proc,'none')
    proc = makeProcString(filtOpt);
    % where is the original data
    baseFolder_load = enICA.getPath('EEG','raw');
else
    % stacking with previous processing if any
    proc = [inFile.proc,'-',makeProcString(filtOpt)];
    baseFolder_load = baseFolder_save;
    
    % TODO if loading processed file, log file should be loaded as well
    % to append relevant info
end

% new Fs
if filtOpt.resample.do
    Fs_ = filtOpt.resample.Fr;
else
    Fs_ = inFile.Fs;
end
saveFolder = enICA.makePathEEGFolder(baseFolder_save,proc,Fs_);

if ~exist(saveFolder,'dir')
    mkdir(saveFolder);
end

for iCond = 1:nCond
    condition = conditions{iCond};
    
    for iSub = 1:nSub
        SID = allSID{iSub};
        
        for iPart = parts
            % load raw data
            folderPath = enICA.makePathEEGFolder(baseFolder_load,inFile.proc,inFile.Fs);
            % no extension
            fileName = enICA.makeNameEEGDataFile(inFile.proc,inFile.Fs,SID,condition,iPart);
            filePath = fullfile(folderPath,[fileName,inFile.ext]);
            
            if ~exist(filePath,'file')
                warning('%s could not be found, skipping.',fileName);
                continue;
            end
            
            EEG = pop_fileio(filePath,'dataformat','auto');
            
            saveOpt.folder = MEGTFS.makePathMEGFolder(baseFolder_save,proc,Fs_,SID);
            EEG = MEEGtools.downsampleBP(EEG,filtOpt,saveOpt);
            
            EEG = pop_saveset(EEG, 'filename', [fileName,'.set'], 'filepath', saveFolder);
            
            % print comments to stand alone log file
            log = cellstr(EEG.comments);
            fileID = fopen(fullfile(saveFolder,[fileName,'.log']),'w');
            fprintf(fileID,'%s\n',log{:});
            fclose(fileID);
        end
    end
end
end
%
%
