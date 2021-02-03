function eegFileName = makeNameEEGDataFile(SID,condition,iPart,ext)
%
%

% Generate name of EEG dataset according to the following convention:
eegFileName = sprintf('%s_%s_%i',SID,condition,iPart);

if 3 < nargin
    eegFileName = sprintf('%s%s',eegFileName,ext);
end
    
end
%
%