function EEG = loadEEG(inFolder, inFileName)

% handling extension
[~,baseName,ext] = fileparts(inFileName);

% try .set then .fif before giving up
if isempty(ext)
    try
        EEG = loadEEG(inFolder, [inFileName,'.set']);
        return;
    catch
        try
            EEG = loadSetOrVhdr(inFolder, [inFileName,'.fif']);
            return;
        catch
            error('Could not find %s in %s',inFileName,inFolder);
        end
    end
end

if strcmp(ext, '.set')
    EEG = pop_loadset(inFileName, inFolder);
    EEG.filename = baseName;
    
elseif strcmp(ext, '.fif')
    EEG = pop_fileio(fullfile(inFolder,inFileName),'dataformat','auto');
    
else
    error('Incorrect extension provided');
end

% do not use EEG.setname as EEGLab also messes with it
EEG.filename = baseName;

end
%
%