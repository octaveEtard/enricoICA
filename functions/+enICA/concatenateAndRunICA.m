function EEG = concatenateAndRunICA(filesWithExt,dataBaseFolder,ICAopt,opt)
%
% get all the EEG data to be submitted to ICA
% remove data before stim
% remove unwanted channels
EEG = enICA.concatenateEEG(filesWithExt,dataBaseFolder);
EEG = MEEGtools.runAndClassifyICA(EEG,ICAopt,opt);

end
%
%