function EEG = concatenateAndRunICA(filesWithExt,dataBaseFolder,ICAopt,opt)
%
% ------ get all the EEG data to be submitted to ICA ------
% remove data before stim
% remove unwanted channels
EEG = enICA.concatenateEEG(filesWithExt,dataBaseFolder);


%% ------ run ICA -----
[EEG,~] = MEEGtools.runICA(EEG,ICAopt);


%% ------ run classification -----
if opt.doICLabel
    EEG = iclabel(EEG);
    EEG = MEEGtools.addComments(EEG,'ICs classified with ICLabel');
end


%% ------ Apply ICA cleaning to the original files & save
nFiles = length(filesWithExt);

if opt.rejectIC.do
    saveFolder = [dataBaseFolder,'-ICr'];
end

for iFile = 1:nFiles
    % load EEG
    EEGtmp = enICA.loadEEG(dataBaseFolder,filesWithExt{iFile});
    
    % % --- removing EOG, Sound channels, etc.
    % % is this necessary?
    % chanLabels = {EEG.chanlocs.labels};
    % removeChan = [];
    %
    % for chan = {'EOGV','EOGH','Sound','Diode'}
    %   chan = chan{1}; %#ok<FXSET>
    %   if any(ismember(chanLabels,chan))
    %       removeChan = [removeChan,chan]; %#ok<AGROW>
    %   end
    % end
    % if ~isempty(removeChan)
    %   EEG = pop_select(EEG,'nochannel',removeChan);
    % end
    % % ----
    
    % note: if EEGmtp contains channels not used during ICA, this may need
    % to be edited.
    
    % copy ICA weights
    EEGtmp.icaweights = EEG.icaweights;
    EEGtmp.icasphere = EEG.icasphere;
    EEGtmp.icachansind = EEG.icachansind;
    
    % flushing icaact and icawinv for consistency in case they already
    % existed in EEGtmp
    EEGtmp.icaact = [];
    EEGtmp.icawinv = [];
    
    % ICLabel info
    EEGtmp.etc.ic_classification = EEG.etc.ic_classification;
    
    % add comments about copy
    EEGtmp.comments = EEG.comments;
    EEGtmp = MEEGtools.addComments(EEGtmp,'Split from merged datasets');
    % the checkset will compute icawinv ...
    EEGtmp = eeg_checkset(EEGtmp);
    
    if opt.rejectIC.do
        EEGtmp = MEEGtools.rejectICs(EEGtmp,opt.rejectIC.rok,opt.rejectIC.thresholds);
    end
    % save
    EEGtmp = enICA.saveEEG(EEGtmp,filesWithExt{iFile},saveFolder); %#ok<NASGU>
end
end
%
%