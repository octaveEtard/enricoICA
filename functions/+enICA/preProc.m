function preProc(allSID,conditions,parts,inFile,opt)
%
% Load EEG data, filter & resample
%
nSub = numel(allSID);
nCond = numel(conditions);
nParts = numel(parts);

% where to save processed EEG data
baseFolder_save = enICA.getPath('EEG','processed');

% loach chanLocs info
chanLocs = load(enICA.getPath('chanLocs'));
chanLocs = chanLocs.chanLocs;

if opt.ASR.do && ~isfield(opt.ASR,'opt')
    opt.ASR.opt = {}; % use default values
end

% required input to the MEEGtools.dowsampleBP function, saving will be done
% outside of it
saveOpt = [];
saveOpt.do = false;

% string describing processing
if isempty(inFile.proc) || strcmp(inFile.proc,'none')
    proc = makeProcString(opt.filt);
    % where is the original data
    baseFolder_load = enICA.getPath('EEG','raw');
else
    % stacking with previous processing if any
    proc = [inFile.proc,'-',makeProcString(opt.filt)];
    baseFolder_load = baseFolder_save;
    
    % TODO if loading processed file, log file should be loaded as well
    % to append relevant info
end

% new Fs
if opt.filt.resample.do
    Fs_ = opt.filt.resample.Fr;
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
        
        ALLEEG = [];
        
        for iiPart = 1:nParts
            
            idxPart = parts(iiPart);
            
            % load raw data
            folderPath = enICA.makePathEEGFolder(baseFolder_load,inFile.proc,inFile.Fs);
            % no extension
            fileName = enICA.makeNameEEGDataFile(SID,condition,idxPart);
            
            EEG = enICA.loadEEG(folderPath, [fileName,inFile.ext]);
            
            % add markers of stimulus begin / end
            [iB,iE] = enICA.getLatencyStimulus(EEG);
            EEG = MEEGtools.addEvents(EEG,iB,'stimBegin',condition);
            EEG = MEEGtools.addEvents(EEG,iE,'stimEnd',condition);
            
            % % if chanLocs are missing, add them back in
            % EEG = MEEGtools.addMissingChanLocations(EEG,chanLocs);
            % EEG.chanlocs & chanLocs do not appear to be consistent.
            % Replacing EEG.chanLocs by chanLocs instead.
            warning('Replacing all channel locations');
            EEG = MEEGtools.replaceChanLocs(EEG,chanLocs);
            
            % filter / resample
            EEG = MEEGtools.downsampleBP(EEG,opt.filt,saveOpt);
            
            if opt.ASR.do
                [ALLEEG, ~, ~] = eeg_store( ALLEEG, EEG, iiPart );
            else
                if opt.interpolate.do
                    EEG = MEEGtools.interpolateMissingChannels(EEG,chanLocs);
                end
                if opt.averageReference.do
                    EEG = MEEGtools.averageReReference(EEG,{},false);
                end
                % save
                EEG = pop_saveset(EEG, 'filename', [fileName,'.set'], 'filepath', saveFolder);
                % print comments to standalone log file
                log = cellstr(EEG.comments);
                fileID = fopen(fullfile(saveFolder,[fileName,'.log']),'w');
                fprintf(fileID,'%s\n',log{:});
                fclose(fileID);
            end
        end
        
        if ~opt.ASR.do
            continue;
        end
        comments = cell(3+nParts,1);
        nPnts = arrayfun(@(e) e.pnts,ALLEEG);
        
        % ---- merge data sets
        EEG = pop_mergeset( ALLEEG, 1:nParts, 0);
        comments{1} = 'Merged datasets:';
        [comments{2:(nParts+1)}] = deal(ALLEEG.filename);
        
        % ---- run ASR
        [EEG,~,~,removed_channels] = clean_artifacts(EEG,opt.ASR.opt{:});
        nRem = sum(removed_channels);
        % original chan info in urchanlocs
        remChan = {EEG.urchanlocs(removed_channels).labels};
        % TODO store percent data too dirty
        
        % add comments
        asropt = cell(numel(opt.ASR.opt),1);
        [asropt{:}] = MEEGtools.printArgs('%.2e',opt.ASR.opt{:});

        comments{nParts+2} = sprintf('Run ASR, opt:%s',sprintf(' %s',asropt{:}));
        comments{nParts+3} = sprintf('%i removed channels:%s',nRem,sprintf(' %s',remChan{:}));
        
        % ---- add commens for the last operations
        EEG = MEEGtools.addComments(EEG,comments);
        
        % ---- interpolate removed / missing channels
        if opt.interpolate.do
            EEG = MEEGtools.interpolateMissingChannels(EEG,chanLocs);
        end
        
        % ---- average re-reference
        if opt.averageReference.do
            EEG = MEEGtools.averageReReference(EEG,{},false);
        end
        
        % ---- split data sets and save
        iBoundaries = MEEGtools.findLatencyEvent(EEG,'type','boundary',nParts-1);
        iBoundaries = [ 1, ceil(iBoundaries) ; ...
            floor(iBoundaries), EEG.pnts]';
        
        for iiPart = 1:nParts
            EEGtmp = pop_select(EEG,'point',iBoundaries(iiPart,:));
            EEGtmp = MEEGtools.addComments(EEGtmp,'Split from merged dataset');
            % sanity check
            assert(nPnts(iiPart) == EEGtmp.pnts);
            
            % visual check
            % iChan = 2; % make sure this corresponds to the same channel
            % and was not interpolated!
            % figure; hold on; plot(ALLEEG(3).data(2,:)); plot(EEGtmp.data(2,:));
            
            % save
            idxPart = parts(iiPart);
            fileName = enICA.makeNameEEGDataFile(SID,condition,idxPart);
            EEGtmp = pop_saveset(EEGtmp, 'filename', [fileName,'.set'], 'filepath', saveFolder); %#ok<NASGU>
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
