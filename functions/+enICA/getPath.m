function topFolder = getPath(varargin)
%
%
% This functions defines the base folder where the data to load, or results
% to save are located.
%
% quick switch between different machines
if isunix()
    dataFolder = '/run/media/octave/MEGdataBKP/enricoData';
else
    dataFolder = 'C:\Users\oe411\dataEnrico';
end
%
%
switch varargin{1}
    
    case 'EEG'
        % where the EEG data is located
        % varargin{2}: 'raw' or 'processed'
        topFolder = fullfile(dataFolder,varargin{2});
        
    otherwise
        error('Unrecognised option.')
end
end
%
%