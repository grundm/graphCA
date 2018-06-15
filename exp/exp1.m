%% Forced-choice experiment with near-threshold somatosensory stimulation
% 
% Author:           Martin Grund
% Last update:      January 15, 2015

%% PREPARE

%% Initialize experiment

% cd('F:/ds5_control/');
cd('C:/Dokumente und Einstellungen/willi/Desktop/GraphCA');
[p_data,ao,ai] = exp_init;


%% Test DAQ card

psi = psi_1AFC_setup(0:.02:5);

ai_rec_test = aio_test(ao,ai,rectpulse(psi.pulse_t,1,ao.SampleRate,psi.wave_t));

clear ai_rec_test psi

% Note: same settings for analog output data vector as for psi_1AFC and 
% nt_exp, because if subsequently the analog output is started with an 
% increased data vector, Matlab crashes (reported to Data Translation 
% Support on Dec 9, 2015, who will test this bug)

%% EXPERIMENT
%% Settings for experiment

nt = nt_setup;
[exp_seq,nt] = nt_seq(nt);
save([p_data.dir nt.file_prefix 'settings_seq.mat'],'p_data','exp_seq','nt');


%%
%% ThA 1
block = 1;

psi = psi_1AFC_setup(0:.02:5);
% psi = psi_1AFC_setup(4:.01:6);

% Initial ThA with more trials and coarser steps
psi.UD_stopRule = 50;
psi.UD_meanNumber = 15;
psi.UD_startValue = 1.0;
psi.trials_psi = 35;
% psi.UD_stepSizeUp = 0.2;
% psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi_data1 = psi_loop(psi,p_data,ao,ai,block,1);

% If repetition necessary:
% (1) Narrow stimulus range
% psi = psi_1AFC_setup(0:.02:5);
% (2) Use last threshold estimate as start value
% psi.UD_startValue = psi_data1.near;
% (3) Indicate another run with last input - psi_loop(...,block,run)
% psi_data1 = psi_loop(psi,p_data,ao,ai,block,2); 


%% BLOCK 1
block = 1;

nt_data1 = nt_exp(nt,ao,ai,p_data,psi_data1.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

nt_data1 = nt_intervals(nt,nt_data1);

nt_save(p_data,nt_data1,nt,['0' num2str(block)]);

nt_result_log(psi_data1,nt_data1);


%%
%% ThA 2
block = 2;

psi = psi_1AFC_setup(0:.02:5);
psi.UD_stepSizeUp = 0.1;
psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi.UD_startValue = nt_data1.near(end,1);

psi_data2 = psi_loop(psi,p_data,ao,ai,block,1);
% psi_data2 = psi_loop(psi,p_data,ao,ai,block,2);


%% BLOCK 2
block = 2;

nt_data2 = nt_exp(nt,ao,ai,p_data,psi_data2.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

nt_data2 = nt_intervals(nt,nt_data2);

nt_save(p_data,nt_data2,nt,['0' num2str(block)]);

nt_result_log(psi_data2,nt_data2);


%%
%% ThA 3
block = 3;

psi.UD_startValue = nt_data2.near(end,1);
% psi.UD_stepSizeUp = 0.2;
% psi.UD_stepSizeDown = psi.UD_stepSizeUp;

psi_data3 = psi_loop(psi,p_data,ao,ai,block,1);
% psi.UD_startValue = psi_data3.near; %nt_data2.near(end,1);
% psi_data3 = psi_loop(psi,p_data,ao,ai,block,2);


%% BLOCK 3
block = 3;

nt_data3 = nt_exp(nt,ao,ai,p_data,psi_data3.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

nt_data3 = nt_intervals(nt,nt_data3);

nt_save(p_data,nt_data3,nt,['0' num2str(block)]);

nt_result_log(psi_data3,nt_data3);


%%
%% ThA 4
block = 4;

psi.UD_startValue = nt_data3.near(end,1);

psi_data4 = psi_loop(psi,p_data,ao,ai,block,1);
% psi_data4 = psi_loop(psi,p_data,ao,ai,block,2);
% psi_data4 = psi_loop(psi,p_data,ao,ai,block,3);


%% BLOCK 4
block = 4;

nt_data4 = nt_exp(nt,ao,ai,p_data,psi_data4.PF_params_PM,exp_seq(exp_seq(:,1)==block,:));

nt_data4 = nt_intervals(nt,nt_data4);

nt_save(p_data,nt_data4,nt,['0' num2str(block)]);

nt_result_log(psi_data4,nt_data4);


%% CLOSE

diary off
clear all