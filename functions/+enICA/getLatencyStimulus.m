function [iB,iE] = getLatencyStimulus(EEG)
%
% Return the index in the EEG data when stimulus begins / end
iB = MEEGtools.findLatencyEvent(EEG,'type','stimBegin');
iE = MEEGtools.findLatencyEvent(EEG,'type','stimEnd');

if ( isempty(iB) || isempty(iE) )
    if EEG.srate == 1000
        % in the raw-cut EEG at Fs = 1kHz 2999 samples were added before /
        % after stimulus begins / ends
        iB = 3000;
        iE = EEG.pnts - 2999;
        warning('Guessing stimulus latency!');
    else
        error('Could not determine stimulus latency');
    end
end
end
%
%