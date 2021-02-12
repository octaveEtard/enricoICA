function EEG = concatenateEEG(filesWithExt,dataBaseFolder)

nFiles = length(filesWithExt);
ALLEEG = [];

for iFile = 1:nFiles
    % load EEG
    EEG = enICA.loadEEG(dataBaseFolder,filesWithExt{iFile});
    
    % --- removing EOG, Sound channels, etc.
    chanLabels = {EEG.chanlocs.labels};
    removeChan = [];
    
    for chan = {'EOGV','EOGH','Sound','Diode'}
        chan = chan{1}; %#ok<FXSET>
        if any(ismember(chanLabels,chan))
            removeChan = [removeChan,chan]; %#ok<AGROW>
        end
    end
    if ~isempty(removeChan)
        EEG = pop_select(EEG,'nochannel',removeChan);
    end
    % ----
    
    % --- only keep data during stimulus
    [iB,iE] = enICA.getLatencyStimulus(EEG);
    
    if isempty(iB) || isempty(iE)
        warning('Stimulus latency not found!');
    end
    EEG = pop_select(EEG,'point',[iB,iE]);
    % ---

    [ALLEEG, ~, ~] = eeg_store( ALLEEG, EEG, 0 );
end

% merge data sets
EEG = pop_mergeset( ALLEEG, 1:nFiles, 0);
%
comments = cell(1+nFiles,1);
comments{1} = 'Keep only data during stimulus & merge datasets:';
[comments{2:(nFiles+1)}] = deal(ALLEEG.setname);
EEG = MEEGtools.addComments(EEG,comments);

end
%
%