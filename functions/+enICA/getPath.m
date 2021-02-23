function topFolder = getPath(varargin)
%
%
% This functions defines the base folder where the data to load, or results
% to save are located.
%
% quick switch between different machines
if ispc()
    % windows machine, octave's assumed
    dataFolder = 'D:\dataEnrico';
elseif ismac()
    % mac machine, Enrico!
    dataFolder = ''; % Enrico set this to your favourite folder
elseif isunix()
    % linux machinen octave's # assumed
    dataFolder = '/run/media/octave/MEGdataBKP/enricoData';
else

end
%
%
switch varargin{1}
    
    case 'EEG'
        % where the EEG data is located
        % varargin{2}: 'raw' or 'processed'
        topFolder = fullfile(dataFolder,varargin{2});
        
    case 'chanLocs'
        % full path to montage file
        topFolder = fullfile(dataFolder,'chanLocs-64.mat');
        
    otherwise
        error('Unrecognised option.')
end
end
%
%