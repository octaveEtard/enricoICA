%
% AMICA info
% https://sccn.ucsd.edu/~jason/amica_help.html
%

% --- Input data
allSID = arrayfun(@(i) sprintf('sub%i',i),1,'UniformOutput',false);
allConditions = {...
    '00'};

parts = 0:4;

opt.in.proc = 'BP-1-80-ASR-INTP-AVR'; % processing of the data to use
opt.in.Fs = 200; % sampling rate of the data to use

% if true, run one ICA per subject, on the data pooled accross conditions
% and parts; otherwise run one ICA per subject x condition, on the data
% pooled across parts
opt.concatenateConditions = false;


% --- parallel options
% run multiple jobs in parallel on the local machine
opt.job.runParallel = false;
% max number of independent jobs (ICAs) to run in parallel
% if using AMICA, total nb of threads = nParMax * max_threads
% N.B: 'binica' does not appear to be multi-threaded
opt.job.nParMax = 4;


% --- IC classification
% run ICLabel after ICA (only classification method implemented atm)
opt.doICLabel = true;


% --- IC rejection
% reject IC based on classfication by ICLabel ; if false, the EEG datasets
% with ICA info will simply be saved, rejection can be done later. See e.g.
% 'run_reject_ICs.m'
opt.rejectIC.do = false;
% rejection parameters, see MEEGtools.rejectICs ; only used if
% opt.rejectIC.do == true;
opt.rejectIC.rok = 'reject';
opt.rejectIC.thresholds = [...
    0   0;... % 'Brain'
    0.8 1;... % 'Muscle'
    0.8 1;... % 'Eye'
    0.8 1;... % 'Heart'
    0.8 1;... % 'Line Noise'
    0.8 1;... % 'Channel Noise'
    0   0];   % 'Other'


% --- where to save the EEG data with ICA rejection / ICA info
% this can be changed, e.g. to run several ICAs with different options
% e.g. concatenate over conditions or not, etc.
if opt.rejectIC.do
    saveFolder = [dataBaseFolder,'-ICr']; % IC rejection
else
    saveFolder = [dataBaseFolder,'-ICA']; % ICA info but not rejection
end

if opt.rejectIC.do
    proc = [opt.in.proc,'-ICr']; % IC rejection
else
    proc = [opt.in.proc,'-ICA']; % ICA info but not rejection
end
opt.saveFolder = enICA.makePathEEGFolder(enICA.getPath('EEG','processed'),proc,opt.in.Fs);


%% Set ICA options
ICAopt.type = 'binica';
% where binica / AMICA should write their tmp files
ICAopt.tmpdir = '/home/octave/icaouttmp';


% whether to reduce rank before ICA, these will be passed to ICA algo
% This may need some adjusting if ICA produces NaN of identical ICs with
% opposite polarities
% 'full': keep the rank of the data (potentially less than nb channel)
% 'conservative': same but with more conservative estimate of rank
% 'var' : keep fraction of var, in this case opt.keepVar = fraction of var
% to keep
ICAopt.rank = 'conservative'; % 'full' or 'conservative' or 'var'
ICAopt.keepVar = 0.9999; % used only if opt.rank == var
% ------

% other parameters to pass directly to ICA algo; see e.g. binica or AMICA
% for options
switch ICAopt.type
    
    case {'runica','binica'}
        % for runica / binica
        ICAopt.algParams = {'interrupt','off','maxsteps',2000};
        
    case 'AMICA'
        % ------ options for AMICA
        ICAopt.algParams = {...
            'max_threads',4,...         % number of threads to allocate per ICA
            'max_iter',2000,...
            'pcakeep',[],...
            'use_grad_norm',true,...	% convergence options
            'min_grad_norm',1e-5,...
            'use_min_dll',true,...
            'min_dll',1e-6};
        
        % path for the required things to run if using parallel jobs
        AMICApath = [getDefaultPath('eeglab'),...
            makeEEGLABpath(getDefaultPath('eeglab'), {'AMICA15','ICLabel0.1'})];
        
end


% Get-Process amica* | select starttime, id

%%
job = enICA.batchRunICA(allSID,parts,allConditions,ICAopt,opt);

