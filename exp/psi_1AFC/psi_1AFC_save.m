function psi_1AFC_save(p_data,psi_data,psi,file_name_end)
% psi_1AFC_save(p_data,psi_data,psi,file_name_end) saves the output of the 
% threshold assesment with psi_1AFC (psi_data, incl. Palamedes up/down 
% method and psi method structures), as well as the settings for psi_1AFC 
% (psi).
%
% Additionally, it creates a table with the single trial data in each line.
%
% % Input variables %
%   p_data          - output of participant_data
%   psi             - output of psi_1AFC_setup (setting structure)
%   psi_data        - output of psi_1AFC (threshold assesment data)
%   file_name_end   - string that defines end of filename
%
% Author:           Martin Grund
% Last update:      January 13, 2016

% Setup data logging
file_name = [psi.file_prefix p_data.ID];

% Create participant data directory
if ~exist(p_data.dir,'dir');
    mkdir('.',p_data.dir);
end

% Save Matlab variables
save([p_data.dir file_name '_data_' file_name_end '.mat'],'p_data','psi_data','psi');

% Copy DAQ file (analog input recording)
copyfile(psi_data.ai_logfile{1},p_data.dir);

delete(psi_data.ai_logfile{1});


%% Save trial data

% Make psi_data easily accessbile
d = psi_data;

% Get current date
date_str = datestr(now,'yyyy/mm/dd');

% Open file
data_file = fopen([p_data.dir file_name '_trials_' file_name_end '.txt'],'a');

% Write header
fprintf(data_file,'ID\tage\tgender\tdate\tblock\ttrial\tstim_type\tintensity\tresp\tresp_t\tresp_btn\tstim_delay\n');

for i = 1:length(d.seq)
   fprintf(data_file,'%s\t%s\t%s\t%s\t%.0f\t%.0f\t%.0f\t%.6f\t%.0f\t%.4f\t%.0f\t%.4f\n',p_data.ID,p_data.age,p_data.gender,date_str,d.block(i),i,d.seq(i,1),d.intensity(i),d.resp(i),d.resp_t(i),d.resp_btn(i),d.stim_delay(i));
end

fclose(data_file);