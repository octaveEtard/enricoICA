%
% AMICA info
% https://sccn.ucsd.edu/~jason/amica_help.html
%

%% Set ICA options
% options to use in AMICA
AMICAopt = {...
    'max_threads',4,...         % number of threads to allocate per ICA
    'max_iter',2000,...
    'pcakeep',[],...
    'use_grad_norm',true,...	% convergence options
    'min_grad_norm',1e-5,...
    'use_min_dll',true,...
    'min_dll',1e-6};

% where AMICA should output tmp files
baseOutDir = 'C:\Users\oe411\amicaouttmp';

% batch run ICAs:
% max number of independent ICA to run at once (total nb of threads = 
% nICAmax * max_threads
nICAmax = 4;

% whether to reduce rank before ICA
% 'full': keep the rank of the data (potentially less than nb channel)
% 'var' : keep fraction of var, in this case opt.var = fraction of var to
% keep
opt.rank = 'full'; % 'full' or 'conservative' or 'var' (in this case )
opt.var = 0.999; % used only if opt.rank == var

% run ICLabel after ICA
opt.doICLabel = true;

% path for the required things to run
AMICApath = [getDefaultPath('eeglab'),...
    makeEEGLABpath(getDefaultPath('eeglab'), {'AMICA15','ICLabel0.1'})];

% Get-Process amica* | select starttime, id

%%
jobICA = batchRunICApooledConditions2(subjectsConditions,AMICApath,dataFolder,preProc,Fs,nICAmax,baseOutDir,AMICAopt,doRemoveChan,doRemovePnts,doRemoveExcludeEvents,opt);


