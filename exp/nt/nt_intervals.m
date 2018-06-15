function data = nt_intervals(nt,data)
% data = nt_intervals(data) computes the actual time intervals between
% screen onsets (e.g., fixation to cue) and between scanner trigger that
% initiates the trial and analog output trigger in nt_exp.
%
% Input:
%   nt       - nt_exp settings structure (doc nt_setup)
%   data     - nt_exp output data structure (e.g., nt_data)
%   
% Author:           Martin Grund
% Last update:      November 19, 2015

%%
for i = 1:size(data.seq,1)

%% SCREEN ONSET INTERVALS

    data.t_mri_fix(i,1) = (data.onset_fix{i,1}-data.mri_trigger{i}(end))*1000;
    data.t_fix_cue(i,1) = (data.onset_cue{i,1}-data.onset_fix{i,1})*1000; % fix to cue interval
    data.t_cue_stim_p(i,1) = (data.onset_stim_p{i,1}-data.onset_cue{i,1})*1000; % cue to stimulus pause screen interval
    data.t_stim_p_resp1(i,1) = (data.onset_resp1{i,1}-data.onset_stim_p{i,1})*1000;
    data.t_resp1_resp2(i,1) = (data.onset_resp2{i,1}-data.onset_resp1{i,1})*1000; % response 1 to response 2 screen interval
    data.t_resp2_ITI(i,1) = (data.onset_ITI{i,1}-data.onset_resp2{i,1})*1000; % response 2 to pause screen interval
    % ITI
%     if i < size(data.seq,1) && mod(i,size(data.seq,1)/nt.blocks) == 0 
% %         data.t_ITI(i,1) = (data.onset_pause{data.seq(i,1),1}-data.onset_ITI{i,1})*1000;
%     elseif i < size(data.seq,1)
    if i < size(data.seq,1)
        data.t_ITI(i,1) = (data.onset_fix{i+1,1}-data.onset_ITI{i,1})*1000;
    else
        data.t_ITI(i,1) = (data.wait_trial_end(i,1)-data.onset_ITI{i,1})*1000;
    end
    % Trial
    if i > 1
        data.t_trial_mri(i,1) = (data.mri_trigger{i}(end)-data.mri_trigger{i-1}(end))*1000;
        data.t_trial_fix(i,1) = (data.onset_fix{i,1}-data.onset_fix{i-1,1})*1000;
    end
    
%% MRI TRIGGER TO AO TRIGGER    
    % MRI trigger to analog output (AO) trigger [based on date vectors]
    data.t_mri_ao_trigger(i,1) = (data.ao_trigger(i,1)-data.mri_trigger_date{i}(end))*24*60*60*1000;
    
    % (Cue onset to pre AO trigger) - stimulus delay [pre AO trigger is MRI trigger locked]
    data.t_cue_ao_trigger_pre_diff_stim_delay(i,1) = (data.ao_trigger_pre(i,1)-data.onset_cue{i,1}-data.seq(i,4))*1000;    
end

% (MRI trigger to AO trigger) - MRI trigger to fix - fix duration - stimulus delay
data.t_mri_ao_trigger_diff_stim_delay = (data.t_mri_ao_trigger/1000-nt.trigger2fix-nt.fix_t-data.seq(:,4))*1000;

% Stimulus onset [best guess based on MRI and AO trigger]
data.t_mri_stim_onset = data.t_mri_ao_trigger + data.stim_offset;

data.t_trigger_ao = data.ao_trigger_post - data.ao_trigger_pre;