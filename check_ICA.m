fileName = 'sub1_00_0.set';
folder = '/run/media/octave/MEGdataBKP/enricoData/processed/Fs-200/BP-1-80-ASR-INTP-AVR-ICr';
EEG = pop_loadset(fileName,folder);


%%
% visual check;
idx = 1:20;
spec_opt = {'freqrange',[0.5 80] };
erp_opt = {};
[com] = pop_viewprops( EEG, 0, idx, spec_opt, erp_opt, 1, 'ICLabel');


%% inspect a component
i0 = 1;
pop_prop_extended(EEG, 0, i0, NaN, spec_opt, erp_opt, 1, 'ICLabel')