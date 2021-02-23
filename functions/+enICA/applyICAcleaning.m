function EEG = applyICAcleaning(EEG,rejectIC,icaweights,icasphere,icachansind,ic_classification)
%
% Use the ICA info (icaweights,icasphere,icachansind,ic_classification) to
% apply ICA cleaning to EEG file. Note that rejectIC.do == false, this
% will only copy the info into EEG, but not reject any components.
%
% If EEG already contains the required fields, just not pass any other
% arguments beyond opt, or pass [] for(icaweights,icasphere,icachansind,
% ic_classification) and the cleaning  will be run based on the info in
% EEG.
%
% See MEEGtools.rejectICs for rejectIC parameters

% % --- removing EOG, Sound channels, etc.
% % is this necessary?
% chanLabels = {EEG.chanlocs.labels};
% removeChan = [];
%
% for chan = {'EOGV','EOGH','Sound','Diode'}
%   chan = chan{1}; %#ok<FXSET>
%   if any(ismember(chanLabels,chan))
%       removeChan = [removeChan,chan]; %#ok<AGROW>
%   end
% end
% if ~isempty(removeChan)
%   EEG = pop_select(EEG,'nochannel',removeChan);
% end
% % ----

% note: if EEG contains channels not used during ICA, this may need
% to be edited.

% copy ICA weights
if 2 < nargin && ~isempty(icaweights)
    EEG.icaweights = icaweights;
    EEG.icasphere = icasphere;
    EEG.icachansind = icachansind;
    
    % ICLabel info
    EEG.etc.ic_classification = ic_classification;
    
    % flushing icaact and icawinv for consistency in case they already
    % existed in EEGtmp
    EEG.icaact = [];
    EEG.icawinv = [];
    
    % the checkset will compute icawinv ...
    EEG = eeg_checkset(EEG);
end

if rejectIC.do
    EEG = MEEGtools.rejectICs(EEG,rejectIC.rok,rejectIC.thresholds);
end

end
%
%