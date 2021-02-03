function mods = concatenateAndRunICA(filesWithExt,dataBaseFolder,outDir,AMICAopt,saveOpt,opt)
%
% get all the EEG data to be submitted to ICA
EEG = concatenateData(filesWithExt,dataBaseFolder);


%% ------number of PCs to keep ------
if strcmp(opt.rank,'full')
    r = rank(EEG.data);
elseif strcmp(opt.rank,'var')
% with % or variance
    s = svd(EEG.data).^2;
    r = find(cumsum(s)/sum(s) >= opt.keepVar,1);
end

iPCAkeep = find( strcmp('pcakeep',AMICAopt) );

if isempty(iPCAkeep)
    PCAkeep = [];
else
    PCAkeep = AMICAopt{iPCAkeep+1};
end

if isempty(PCAkeep) || PCAkeep <= 0
    PCAkeep = r;
elseif PCAkeep > r
    warning('pcaKeep = %i, but data rank = %i. Changing pcaKeep to %i',PCAkeep,r,r);
    PCAkeep = r;
end

if isempty(iPCAkeep)
    AMICAopt = [AMICAopt,'pcakeep',PCAkeep];
else
    AMICAopt{iPCAkeep+1} = PCAkeep;
end


%% ------ run ICA ------
switch opt.ICAflavour
    
    case 'AMICA'
        mods = callAMICAinFolder(EEG.data,outDir,AMICAopt);
    case 'runICA'
        % TODO
end


%% ------ check AMICA result ------
if strcmp(opt.ICAflavour,'AMICA')
    [nanProduced,iter,cancelled] = checkAMICAout(outDir);

    if cancelled
        warning('AMICA cancelled (iteration %i)',iter);
    elseif nanProduced
        warning('NaN produced after %i iterations',iter);
    % elseif iter ~= maxIter
    %     warning('AMICA stopped early (%i / %i iterations)',iter,maxIter);
    end
end


%% ------ run classification -----
if opt.doICLabel
    EEG.icaweights = mods.W;
    EEG.icasphere = mods.S(1:PCAkeep,:);
    EEG.icachansind = 1:EEG.nbchan;

    EEG = eeg_checkset(EEG);

    EEG = iclabel(EEG);
    classification = EEG.etc.ic_classification;
end


%% ------
if saveOpt.do
    ICAresults.mods = mods;
    ICAresults.pcaKeep = PCAkeep;
    ICAresults.ranOnFiles = filesWithExt;
    ICAresults.ranOnChan = {EEG.chanlocs(:).labels};
    ICAresults.AMICAopt = AMICAopt;
    ICAresults.iter = iter;
    
    if opt.doICLabel
        ICAresults.ic_classification = classification;
    end
    
    LM.save(ICAresults,saveOpt.fileName,saveOpt.folder);
end


end