function data = psi_1AFC_intervals(data)
% data = psi_1AFC_intervals(data) computes the actual time intervals
% between screen onsets (e.g., fixation to cue) and analog output trigger 
% in psi_1AFC.
%
% Input:
%   data     - psi_1AFC output data structure (e.g., psi_data)
%   
% Author:           Martin Grund
% Last update:      November 25, 2015

for i = 1:size(data.seq,1)

%% SCREEN ONSET INTERVALS

    data.t_fix_cue(i,1) = (data.onset_cue{i,1}-data.onset_fix{i,1})*1000; % fix to cue interval
    data.t_cue_resp(i,1) = (data.onset_resp{i,1}-data.onset_cue{i,1})*1000; % cue to response screen    
    if i < size(data.seq,1)
        data.t_ITI(i,1) = (data.onset_fix{i+1,1}-data.onset_ITI{i,1})*1000; % ITI
        data.t_trial_fix(i,1) = (data.onset_fix{i+1,1}-data.onset_fix{i,1})*1000; % Trial
    else
        data.t_ITI(i,1) = (data.last_trial-data.onset_ITI{i,1})*1000; % ITI
        data.t_trial_fix(i,1) = (data.last_trial-data.onset_fix{i,1})*1000; % Trial
    end
    
%% AO TRIGGER    
    % MRI trigger to analog output (AO) trigger [based on date vectors]
%     data.t_mri_ao_trigger(i,1) = (data.ao_trigger(i,1)-data.mri_trigger_date{i}(end))*24*60*60*1000;
    
    % (Cue onset to pre AO trigger) - stimulus delay [pre AO trigger is MRI trigger locked]
    data.t_cue_ao_trigger_pre_diff_stim_delay(i,1) = (data.ao_trigger_pre(i,1)-data.onset_cue{i,1}-data.stim_delay(i))*1000;    
end

data.t_trigger_ao = data.ao_trigger_post - data.ao_trigger_pre;