%
% filter, downsample, and save EEG files
%

%%
% subject IDs
allSID = arrayfun(@(i) sprintf('sub%i',i),1:15,'UniformOutput',false);

% conditions
conditions = {...
    '00',...
    '1e_AV',...
    '1e_V0',...
    '1m_V0',...
    '4v_AV',...
    '4v_V0',...
    'bw_AV',...
    'bw_V0',...
    'nh_AV',...
    'nh_V0',...
    };

% file part indices
parts = 0:4;

% original files
inFile = [];
inFile.Fs = 1000;
inFile.proc = 'none';
inFile.ext = '.fif';

% filter options

% cortical
filtOpt = [];
filtOpt.resample.do = true;
filtOpt.resample.Fr = 200;
%
filtOpt.LP.do = true;
filtOpt.LP.Fc = 90;
filtOpt.LP.TBW = 20;
filtOpt.LP.causal = false;
%
filtOpt.HP.do = true;
filtOpt.HP.Fc = 0.5;
filtOpt.HP.TBW = 1;
filtOpt.HP.passbandRipples = 2e-3;
filtOpt.HP.causal = false;

enICA.downsampleBP(allSID,conditions,parts,inFile,filtOpt)
%
%