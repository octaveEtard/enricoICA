%
% Script demonstrating how to read in EEG data containg ICA information and
% classification **(but with no IC rejected)**, apply some IC rejection
% based on the classification, and save the new EEG dataset.
%
% This way the original EEG data is untouched, and several cleaning methods
% can be experimented with, without having to rerun the ICA algorithm
SID = 'sub1';
condition = '00';
parts = 0:4;

Fs = 200;

% define rejection parameters to use, see MEEGtools.rejectICs
rejectIC = [];
rejectIC.do = true;         % otherwise this won't do anything
rejectIC.rok = 'reject';	% reject or keep
rejectIC.thresholds = [...
    0   0;... % 'Brain'
    0.8 1;... % 'Muscle'
    0.8 1;... % 'Eye'
    0.8 1;... % 'Heart'
    0.8 1;... % 'Line Noise'
    0.8 1;... % 'Channel Noise'
    0   0];   % 'Other'


baseFolderEEG = enICA.getPath('EEG','processed');

% folder containing input EEG data with ICA info
proc = 'BP-1-80-ASR-INTP-AVR-ICA';

% where to save the EEG data
saveFolder = enICA.makePathEEGFolder(baseFolderEEG,'BP-1-80-ASR-INTP-AVR-someICAcleaningName',Fs);


%%
if ~exist(saveFolder,'dir')
    mkdir(saveFolder);
end

% folder containing input EEG data with ICA info
EEGfolder = enICA.makePathEEGFolder(baseFolderEEG,proc,Fs);

assert(~strcmp(EEGfolder,saveFolder),'This will overwrite the original data');

nParts = numel(parts);

for iPart = 1:nParts
    idxPart = parts(iPart);

    fileName = enICA.makeNameEEGDataFile(SID,condition,idxPart,'.set');
    % load EEG
    EEG = enICA.loadEEG(EEGfolder,fileName);
    
    % IC rejection
    EEG = enICA.applyICAcleaning(EEG,rejectIC);

    % save
    EEG = enICA.saveEEG(EEG,fileName,saveFolder);
end
%
%