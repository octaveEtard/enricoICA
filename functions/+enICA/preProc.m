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

% --- string describing processing
proc = MEEGtools.makeFiltString(opt.filt);
if opt.ASR.do
    proc = [proc,'-ASR'];
end
if opt.interpolate.do
    proc = [proc,'-INTP'];
end
if opt.averageReference.do
    proc = [proc,'-AVR'];
end

if isempty(inFile.proc) || strcmp(inFile.proc,'none')
    % where is the original data
    baseFolder_load = enICA.getPath('EEG','raw');
else
    % stacking with previous processing if any
    proc = [inFile.proc,'-',proc];
    baseFolder_load = baseFolder_save;
end

% new Fs
if opt.filt.resample.do
    Fs_ = opt.filt.resample.Fr;
else
    Fs_ = inFile.Fs;
end

saveFolder = enICA.makePathEEGFolder(baseFolder_save,proc,Fs_);
% raw data folder
folderPath = enICA.makePathEEGFolder(baseFolder_load,inFile.proc,inFile.Fs);

for iCond = 1:nCond
    condition = conditions{iCond};
    
    for iSub = 1:nSub
        SID = allSID{iSub};
        
        ALLEEG = [];
        
        for iiPart = 1:nParts
            % load raw data
            idxPart = parts(iiPart);
            % no extension
            fileName = enICA.makeNameEEGDataFile(SID,condition,idxPart);
            
            EEG = enICA.loadEEG(folderPath, [fileName,inFile.ext]);
            EEG.setname = fileName;
            
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
            EEG = MEEGtools.downsampleBP(EEG,opt.filt);
            
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
                EEG = enICA.saveEEG(EEG,fileName,saveFolder); %#ok<NASGU>
            end
        end
        
        if ~opt.ASR.do
            continue;
        end
        comments = cell(4+nParts,1);
        nPnts = arrayfun(@(e) e.pnts,ALLEEG);
        
        % ---- merge data sets
        EEG = pop_mergeset( ALLEEG, 1:nParts, 0);
        comments{1} = 'Merged datasets:';
        [comments{2:(nParts+1)}] = deal(ALLEEG.setname);
        
        % ---- run ASR
        chanLocs_beforeASR = EEG.chanlocs;
        [EEG_,~,EEG,removed_channels] = clean_artifacts(EEG,opt.ASR.opt{:});
        
        nRem = sum(removed_channels);
        if 0 < nRem
            % original chan info in urchanlocs
            remChan = {chanLocs_beforeASR(removed_channels).labels};
        else
            remChan = {};
        end
        
        % add comments
        asropt = cell(numel(opt.ASR.opt),1);
        [asropt{:}] = MEEGtools.printArgs('%.2e',opt.ASR.opt{:});
        
        comments{nParts+2} = sprintf('Run ASR, opt:%s',sprintf(' %s',asropt{:}));
        comments{nParts+3} = sprintf('%i removed channels:%s',nRem,sprintf(' %s',remChan{:}));
        
        % EEG_ will contain info on data judged 'irrecoverable' by ASR
        % we do not remove these data portions, but store the fraction of
        % 'irrecoverable' data:
        if(isfield(EEG_.etc,'clean_sample_mask'))
            f = 1 - sum(EEG_.etc.clean_sample_mask) / numel(EEG_.etc.clean_sample_mask);
            comments{nParts+4} = sprintf('ASR irrecoverable data (on pooled data): %.2f %%',100*f);
            EEG.etc.ASRirrecoverableFractionPooledData = f;
        else
            comments{nParts+4} = 'ASR not run to identify the % of irrecoverable data.';
            EEG.etc.ASRirrecoverableFractionPooledData = NaN;
        end
        
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
            
            % 'irrecoverable' data fraction for this dataset
            if(isfield(EEG_.etc,'clean_sample_mask'))
                f = 1 - sum(EEG_.etc.clean_sample_mask(iBoundaries(iiPart,1):iBoundaries(iiPart,2))) / EEGtmp.pnts;
                EEG.etc.ASRirrecoverableFraction = f;
            else
                EEG.etc.ASRirrecoverableFraction = NaN;
            end
            
            % sanity check
            assert(nPnts(iiPart) == EEGtmp.pnts);
            
            % visual check
            % iChan = 2; % make sure this corresponds to the same channel
            % and was not interpolated!
            % figure; hold on; plot(ALLEEG(3).data(2,:)); plot(EEGtmp.data(2,:));
            
            % save
            idxPart = parts(iiPart);
            fileName = enICA.makeNameEEGDataFile(SID,condition,idxPart);
            
            % save
            EEGtmp.setname = [fileName,'-',proc];
            EEGtmp = enICA.saveEEG(EEGtmp,fileName,saveFolder); %#ok<NASGU>
        end
    end
end
end
%
%
