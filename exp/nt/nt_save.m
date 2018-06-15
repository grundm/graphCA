function nt_save(p_data,nt_data,nt,file_name_end)
% nt_save(p_data,nt_data,nt,file_name_end)) saves the output (nt_data) of 
% the near-threshold experiment (nt_exp), as well as the settings for 
% nt_exp (nt).
%
% Additionally, it creates a table with the single trial data in each line.
%
% % Input variables %
%   p_data          - output of participant_data
%   nt              - output of nt_setup (setting structure)
%   nt_data         - output of nt_exp
%   file_name_end   - string that defines end of filename
%
% Author:           Martin Grund
% Last update:      January 13, 2016

% Setup data logging
file_name = [nt.file_prefix p_data.ID];

% Create participant data directory
if ~exist(p_data.dir,'dir');
    mkdir('.',p_data.dir);
end

% Compute time intervals
% nt_data = nt_intervals(nt,nt_data);

% Save Matlab variables
save([p_data.dir file_name '_data_' file_name_end '.mat'],'p_data','nt_data','nt');

% Copy DAQ file (analog input recording)
% for i = 1:length(nt_data.ai_logfile)
%     copyfile(nt_data.ai_logfile{i,1},p_data.dir);
%     delete(nt_data.ai_logfile{i,1});
% end
copyfile(nt_data.ai_logfile,p_data.dir);
delete(nt_data.ai_logfile);


%% Save trial data

% Make nt_data easily accessbile
d = nt_data;

% Get current date
date_str = datestr(now,'yyyy/mm/dd');

% Open file
data_file = fopen([p_data.dir file_name '_trials_' file_name_end '.txt'],'a');

% Write header
fprintf(data_file,'ID\tage\tgender\tdate\tblock\ttrial\tstim_type\tstim_step\tintensity\tresp1\tresp1_t\tresp1_btn\tresp2\tresp2_t\tresp2_btn\tstim_delay\tmri_trigger\tt_mri_stim_onset\tonset_fix\tonset_cue\tonset_stim_p\tonset_resp1\tonset_resp1_p\tonset_resp2\tonset_ITI\n');

for i = 1:length(d.seq)
   fprintf(data_file,'%s\t%s\t%s\t%s\t%.0f\t%.0f\t%.0f\t%.2f\t%.6f\t%.0f\t%.4f\t%.0f\t%.0f\t%.4f\t%.0f\t%.4f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\n',p_data.ID,p_data.age,p_data.gender,date_str,d.seq(i,1),i,d.seq(i,2),d.seq(i,3),d.intensity(i),d.resp1(i),d.resp1_t(i),d.resp1_btn(i),d.resp2(i),d.resp2_t(i),d.resp2_btn(i),d.seq(i,4),d.mri_trigger{i}(end),d.t_mri_stim_onset(i),d.onset_fix{i,1},d.onset_cue{i,1},d.onset_stim_p{i,1},d.onset_resp1{i,1},d.onset_resp1_p{i,1},d.onset_resp2{i,1},d.onset_ITI{i,1});
end

fclose(data_file);