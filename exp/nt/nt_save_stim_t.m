function nt_save_stim_t(nt_data_file)
% nt_save_stim_t(nt_data) creates a separate txt file with the stimulus 
% onsets for each condition
%
% % Input variables %
%   nt_data_file    - path-filename string to output of nt_exp
%
% Author:           Martin Grund
% Last update:      July 6, 2016

% Settings
[nt_data_path,nt_data_name] = fileparts(nt_data_file);
file_prefix = [nt_data_path '/' nt_data_name];
file_suffix = '_t.txt';

% Create stimulus onset files for each condition

load(nt_data_file);

%block = nt_data.seq(1,1);

% How may conditions are there?

cond = unique(nt_data.seq(:,2))';

% prepare files
for j = 1:size(cond,2)
    f(j) = fopen([file_prefix '_' num2str(cond(1,j)) file_suffix],'a');
end

% Compute stimulus onsets in seconds

stim_t = (nt_data.ao_trigger-nt_data.mri_trigger_date{1})*24*60*60;

for i = 1:size(nt_data.seq,1)
    
    % Note: for AFNI timing_tool.py the input file has 1 run per row and
    % hence stimlus onsets per run in 1 line
    
    switch nt_data.seq(i,2)
        case cond(1)
            fprintf(f(1),'%.6f\t',stim_t(i,1));
        case cond(2)
            fprintf(f(2),'%.6f\t',stim_t(i,1));
        case cond(3)
            fprintf(f(3),'%.6f\t',stim_t(i,1));
    end
end
    
for j = 1:size(cond,2)
    fclose(f(j));
end