function downsampleBP(allSID,conditions,parts,inFile,filtOpt)
%
% Load EEG data, filter & resample
%
nSub = numel(allSID);
nCond = numel(conditions);

% where to save processed EEG data
baseFolder_save = enICA.getPath('EEG','processed');

% loach chanLocs info
chanLocs = load(enICA.getPath('chanLocs'));
chanLocs = chanLocs.chanLocs;

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
            fileName = enICA.makeNameEEGDataFile(SID,condition,iPart);
            
            % load
            try
                EEG = enICA.loadEEG(folderPath, [fileName,inFile.ext]);
            catch
                warning('%s could not be found, skipping.',fileName);
                continue;
            end
            
            % add markers of stimulus begin / end
            [iB,iE] = enICA.getLatencyStimulus(EEG);
            EEG = MEEGtools.addEvents(EEG,iB,'stimBegin',condition);
            EEG = MEEGtools.addEvents(EEG,iE,'stimEnd',condition);
            
            % EEG.chanlocs & chanLocs do not appear to be consistent.
            % Replacing EEG.chanLocs by chanLocs instead.
            % % if chanLocs are missing, add them back in
            % EEG = MEEGtools.addMissingChanLocations(EEG,chanLocs);
%             error('fix me');
            
            % filter / resample
            EEG = MEEGtools.downsampleBP(EEG,filtOpt,saveOpt);
            % save
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
