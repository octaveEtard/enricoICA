function eegFolder = makePathEEGFolder(baseFolder,proc,Fs)
%
%

% raw data
if isempty(proc) || strcmp(proc,'none')
    eegFolder = baseFolder;
else
    % Generate path to EEG folder according to the following convention:
    eegFolder = fullfile(baseFolder,sprintf('Fs-%i',Fs),proc);
end
end
%
%