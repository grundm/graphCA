function nt = nt_setup
% nt = nt_setup returns the settings for nt_exp.
%
% % Settings %
%
%   % General
%   nt.rng_state    - state of random number generator (not mandatory)
%   nt.file_prefix  - prefix for saving files (e.g., analog input recording)
%   nt.pause_num    - number of pauses (+ 1 = number of blocks)
%
%   % Scanner trigger
%   nt.TR           - repetition time (TR) of MRI sequence in s
%   nt.trigger_bit  - bit reflecting hardware pin with MRI trigger input
%   nt.trigger_max  - number of triggers to wait after start of scanner
%
%   % Stimuli   
%   nt.stim_types   - stimulus typ labels (0 - none; 1 - near; 2 - supra)
%   nt.stim_types_num - number of stimulus types (should be a multiple of nt.stim_steps)
%   nt.near_p       - performance level for stimulus nt.stim_types(2)
%   nt.supra_p      - performance level for stimulus nt.stim_types(3)
%   nt.stim_steps   - intensity steps as factors of near- and supra-threshold intensity
%   % nt.stim_p_steps - perfomance level steps in relation to nt.near_p and nt.supra_p
%   nt.pulse_t      - duration of stimuls (rectangular pulse) in ms
%   nt.wave_t       - duration of waveform with rectangular pulse in ms
%   nt.stim_dec     - number of decimal digits of intensity in mA (doc dlg_intensities)
%   nt.stim_max     - maximum possible stimulus intensity in mA
% 
%   % Trial
%   nt.get_flip_i	- number of samples for initial flip interval estimation with Screen('GetFlipInterval')
%   nt.trigger2fix  - duration of scanner trigger to fixation cross onset in s
%   nt.fix_t        - duration of fixation cross in s
%   nt.cue_t        - duration of stimulus cue in s
%   nt.stim_delay   - min/max vector for pseudo-randomized stimulus delay in s
%   nt.stim2resp    - pause between stimulus cue and response screen in s
%   nt.resp_window  - 'variable'/'fixed' - stop/continue after first button press
%   nt.resp1_max_t  - maximum response time 1 in s
%   nt.resp2_max_t  - maximum response time 2 in s
%   nt.resp_p_min_t - minimum time left to show response pause screen in s
%   nt.ITI          - inter trial interval (ITI) in s
%
%   % Screen design
%   nt.window_color - screen background rgb color vector
% 
%   % Text
%   nt.txt_color    - text rgb color vector
%   nt.txt_font     - font type
%   nt.txt_size     - font size for response screens
%   nt.cue_size     - font size for fix, cue and pause screens
% 
%   % Messages
%   nt.fix          - fixation symbol (e.g., '+')
%   nt.cue          - stimulus cue symbol (e.g., '~+~')
%   nt.resp1_txt    - yes/no response text options, yes-no-order important, e.g. ['J'; 'N']
%   nt.resp2_txt    - confidence response text options
%   nt.resp1_offset - 1st response text offset left from screen center
%   nt.ITI_cue      - inter trial interval symbol
%   nt.pause_msg    - message on pause screen
%   nt.scanner_msg  - prompt to start scanner
% 
%   % Buttons
%   nt.lpt_adr      - parallel port address (see device manager - LPT1 details - resources)
%   nt.lpt_dir      - parallel port direction ('bi' or 'uni')
%   nt.btn_resp1    - button codes for yes/no response
%   nt.btn_resp2    - button codes for confidence response
%   nt.btn_esc      - button code for quiting experiment
%
%   % Instruction
%   nt.instr_dir    - instruction directory with condition subdirectories
%                     (relative to directory of nt_exp.m)
%   nt.instr_subdir_wildcard    - instruction subdirectory wildcard
%   nt.instr_img_wildcard       - filename wildcard of instruction image files
%
%
% Author:           Martin Grund
% Last update:      January 26, 2016

%% Settings

%% General
% nt.rng_state = sum(100*clock); % If not defined, generated by nt_exp
nt.file_prefix = 'nt_';
nt.blocks = 4;

%% Scanner trigger
nt.TR = 0.750;
nt.trigger_bit = 7;
nt.trigger_max = 1;

%% Stimuli
nt.stim_types = [0 1 2];
nt.stim_types_num = [10 25 5];
% nt.stim_types_num = [14 12 12]; % 2nd and 3rd should be a multiple of nt.stim_steps
nt.near_p = .45;
nt.supra_p = .95;
nt.stim_steps = 1; % [.95 1 1.05];
nt.pulse_t = 0.2; % = psi.pulse_t [IMPORTANT FOR DT9812, see exp1 for bug]
nt.wave_t = 10; % = psi.wave_t [IMPORTANT FOR DT9812, see exp1 for bug]
nt.stim_dec = 2;
nt.stim_max = 5;

%% Trial
nt.get_flip_i = 200;
nt.trigger2fix = 0.100;
nt.fix_t = 1.000;
nt.cue_t = 1.000;
nt.stim_delay = [0.885 0.885];
nt.stim2resp = 9.000;
nt.resp_window = 'variable';
nt.resp1_max_t = 1.500;
nt.resp2_max_t = 1.500;
nt.resp_p_min_t = 0.300;
nt.ITI = 7.000;

%% Screen design
nt.window_color = [200 200 200];%[250 250 250]; % grey98 (very light grey)

%% Text
nt.txt_color = [40 40 40]; % grey15-16 (anthracite)
nt.txt_font = 'Arial';
nt.txt_size = 30;
nt.cue_size = 50;

%% Messages
nt.fix = '+';
nt.cue = '~+~';
nt.resp1_txt = ['J'; 'N'];
nt.resp2_txt = ['1'; '2'; '3'; '4'];
nt.resp1_offset = 75;
nt.ITI_cue = '+';
nt.pause_msg = '# Pause #\n\n\nWeiter mit beliebiger Taste';
nt.scanner_msg = 'Start scanner';

%% Buttons
nt.lpt_adr = '378';
nt.lpt_dir = 'bi';
nt.btn_resp1 = [6 7];
nt.btn_resp2 = [5 6 7 8];
nt.btn_esc = 1;

%% Instruction
nt.instr_dir = '/instr/';
nt.instr_subdir_wildcard = 'condition_*';
nt.instr_img_wildcard = 'instruction.*.png';