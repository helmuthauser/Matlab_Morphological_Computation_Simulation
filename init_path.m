disp('Adding necessary paths')
% adapt this to your local paths
% this allows Matlab to find the used functions
current_script_path = mfilename('fullpath');
[script_dir,~,~] = fileparts(current_script_path);
addpath(script_dir);
addpath(fullfile(script_dir, 'helping_functions'));
addpath(fullfile(script_dir, 'data_vanderPol'));
addpath(fullfile(script_dir, 'data_Volterra'));
addpath(fullfile(script_dir, 'data_quad'));
addpath(fullfile(script_dir, 'data_NARMA'));
