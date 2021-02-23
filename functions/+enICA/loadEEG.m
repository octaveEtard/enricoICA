function EEG = loadEEG(inFolder, inFileName)

% handling extension
[~,baseName,ext] = fileparts(inFileName);

% try .set then .fif before giving up
if isempty(ext)
    try
        EEG = enICA.loadEEG(inFolder, [inFileName,'.set']);
        return;
    catch
        try
            EEG = enICA.loadEEG(inFolder, [inFileName,'.fif']);
            return;
        catch
            error('Could not find %s in %s',inFileName,inFolder);
        end
    end
end

if ~exist(fullfile(inFolder, inFileName),'file')
    error('Could not find %s in %s',inFileName,inFolder);
end

if strcmp(ext, '.set')
    EEG = pop_loadset(inFileName, inFolder);
    
elseif strcmp(ext, '.fif')
    EEG = pop_fileio(fullfile(inFolder,inFileName),'dataformat','auto');
else
    error('Incorrect extension provided');
end
end
%
%