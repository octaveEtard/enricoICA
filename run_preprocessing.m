%
% filter, downsample, and save EEG files
%

%%
% subject IDs
allSID = arrayfun(@(i) sprintf('sub%i',i),1,'UniformOutput',false);

% conditions
conditions = {...
    '00',...
%     '1e_AV',...
%     '1e_V0',...
%     '1m_V0',...
%     '4v_AV',...
%     '4v_V0',...
%     'bw_AV',...
%     'bw_V0',...
%     'nh_AV',...
%     'nh_V0',...
    };

% file part indices
parts = 0:4;

% original files
inFile = [];
inFile.Fs = 1000;
inFile.proc = 'none';
inFile.ext = '.fif';

opt = [];
% ---- filter options
% cortical
opt.filt = [];
opt.filt.resample.do = true;
opt.filt.resample.Fr = 200;
%
opt.filt.LP.do = true;
opt.filt.LP.Fc = 90;
opt.filt.LP.TBW = 20;
opt.filt.LP.causal = false;
%
opt.filt.HP.do = true;
opt.filt.HP.Fc = 0.5;
opt.filt.HP.TBW = 1;
opt.filt.HP.passbandRipples = 2e-3;
opt.filt.HP.causal = false;

% ---- ASR options
% NB: ASR will run for each subject x condition on the data concatenated
% over all parts. TODO does this make sense? How was the data recorded?
% Which part are contiguous in time?
%
opt.ASR.do = true;
% options to pass to 'clean_artifacts' ; comment out or set to {} to use
% default values
% high-pass:off > already taken care of
% WindowCriterion:off > keep irreparable windows to avoid creating holes in
% the dataset
opt.ASR.opt = {'Highpass','off','WindowCriterion','off'};

% ---- interpolate missing or removed channels (based on 64 channels)
opt.interpolate.do = true;

% ---- do average reference
opt.averageReference.do = true;

% ---- run all this
enICA.preProc(allSID,conditions,parts,inFile,opt)
%
%