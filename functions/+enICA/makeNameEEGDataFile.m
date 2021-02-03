function eegFileName = makeNameEEGDataFile(proc,Fs,SID,condition,iPart,ext)
%
%

% Generate name of EEG dataset according to the following convention:
if isempty(proc) || strcmp(proc,'none')
        eegFileName = sprintf('%s_%s_%i',SID,condition,iPart);
else
%     megFileName = sprintf('%s-Fs-%i-%s_%s_%i',proc,Fs,SID,condition,iPart);
end

if 5 < nargin
    eegFileName = sprintf('%s%s',eegFileName,ext);
end
    
end
%
%