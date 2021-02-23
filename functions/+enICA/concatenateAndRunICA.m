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
    saveFolder = [dataBaseFolder,'-ICr']; % IC rejection
else
    saveFolder = [dataBaseFolder,'-ICA']; % ICA info but not rejection
end

icaweights = EEG.icaweights;
icasphere = EEG.icasphere;
icachansind = EEG.icachansind;
% ICLabel info
ic_classification = EEG.etc.ic_classification;

for iFile = 1:nFiles
    % load EEG
    EEGtmp = enICA.loadEEG(dataBaseFolder,filesWithExt{iFile});
    % add comments about copy
    EEGtmp.comments = EEG.comments;
    EEGtmp = MEEGtools.addComments(EEGtmp,'Split from merged datasets');
    
    EEGtmp = enICA.applyICAcleaning(EEGtmp,opt.rejectIC,icaweights,icasphere,icachansind,ic_classification);

    % save
    EEGtmp = enICA.saveEEG(EEGtmp,filesWithExt{iFile},saveFolder); %#ok<NASGU>
end
end
%
%