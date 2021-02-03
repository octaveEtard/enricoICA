function job = batchRunICA(allSID,parts,allConditions,ICAopt,opt)

% where is the EEG data
baseFolderEEG = enICA.getPath('EEG','processed');

% generate paths to EEG files
nSub = numel(allSID);
nParts = numel(parts);
nCond = numel(allConditions);

fileNames = cell(nSub,nCond,nParts);

EEGfolder = enICA.makePathEEGFolder(baseFolderEEG,opt.in.proc,opt.in.Fs);

for iPart = 1:nParts
    idxPart = parts(iPart);
    for iCond = 1:nCond
        condition = allConditions{iCond};
        for iSub = 1:nSub
            SID = allSID{iSub};
            fileNames{iSub,iCond,iPart} = enICA.makeNameEEGDataFile(SID,condition,idxPart,'.set');
        end
    end
end

if opt.concatenateConditions
    fileNames = fileNames(:,:);
end


%% Creating job
job = [];
if opt.job.runParallel
    clust = parcluster('local');
    clust.NumWorkers = opt.job.nParMax;
    
    additionalPaths = [];
    job = createJob(clust,'AdditionalPaths',additionalPaths);
end


%% creating tasks inside this job
iTask = 1;
for iSub = 1:nSub
    SID = allSID{iSub};
    
    if opt.concatenateConditions
        % create one task per subject pooled over conditions x parts
        inputs = {fileNames(iSub,:),EEGfolder,ICAopt,opt};
        if opt.job.runParallel
            createTask(job,@enICA.concatenateAndRunICA,0,inputs,'CaptureDiary',true,'Name',[SID,'_',condition]);
            fprintf('ICA added (%i): %s %i cond pooled\n',iTask,SID,nCond);
            iTask = iTask + 1;
        else
            enICA.concatenateAndRunICA(inputs{:});
        end
    else
        for iCond = 1:nCond
            % create one task per subject x condition
            condition = allConditions{iCond};
            
            inputs = {fileNames(iSub,iCond,:),EEGfolder,ICAopt,opt};
            
            if opt.job.runParallel
                createTask(job,@enICA.concatenateAndRunICA,0,inputs,'CaptureDiary',true,'Name',[SID,'_',condition]);
                fprintf('ICA added (%i): %s %s (%i)\n',iTask,SID,condition);
                iTask = iTask + 1;
            else
                enICA.concatenateAndRunICA(inputs{:});
            end
        end
    end
end

end
%
%