function data = nt_exp(nt,ao,ai,p_data,PF_params,seq)
% nt_exp(threshold,supra) starts the near-threshold experiment.
% 
% % Input variables %
%   nt              - settings structure (doc nt_setup)
%   ao              - analog output object
%   ai              - analog input object
%   p_data          - participant data (output of participant_data)
%   PF_params       - psychometric function parameters (e.g., psi_data.PF_params_PM)
% 
% % Output variables %
%   data            - data output structure
% 
% Author:           Martin Grund
% Last update:      February 1, 2016


%% Intensity input dialog %%
[data.near,data.supra] = dlg_intensities(PF_params,nt.near_p,nt.supra_p,nt.stim_steps,nt.stim_max,nt.stim_dec);


%% SETUP %%    
try


%% Random number generator
data.rng_state = set_rng_state(nt);


%% Analog output

% daqgetfield(dio,'uddobject'); can accelerate putvalue/getvalue from ~1ms to ~20us 
% (see https://github.com/Psychtoolbox-3/Psychtoolbox-3/wiki/FAQ:-TTL-Triggers-in-Windows)

ao_udd = daqgetfield(ao,'uddobject');


%% Response-button mapping

% 2 responses -> 4 conditions:
% 1: JN & 1234
% 2: JN & 4321
% 3: NJ & 1234
% 4: NJ & 4321

data.resp_btn_map = mod(str2double(p_data.ID)-1,4)+1;

switch data.resp_btn_map
    case 1
        data.resp1_txt = nt.resp1_txt;
        data.resp2_txt = nt.resp2_txt;
    case 2
        data.resp1_txt = nt.resp1_txt;
        data.resp2_txt = flipud(nt.resp2_txt);
    case 3
        data.resp1_txt = flipud(nt.resp1_txt);
        data.resp2_txt = nt.resp2_txt;
    case 4
        data.resp1_txt = flipud(nt.resp1_txt);
        data.resp2_txt = flipud(nt.resp2_txt);
end


%% Instruction directory (based on response-button mapping)
instr_dir = [fileparts(mfilename('fullpath')) nt.instr_dir];
instr_subdir = dir([instr_dir nt.instr_subdir_wildcard num2str(data.resp_btn_map) '*']);


%% Sequence (doc nt_seq)

data.seq = seq;


%% Stimulus

% Generate default waveform vector
[data.stim_wave, data.stim_offset] = rectpulse(nt.pulse_t,1,ao.sampleRate,nt.wave_t);


%% Timing

data.trial_t = nt.fix_t + nt.cue_t + nt.stim2resp + nt.resp1_max_t ...
               + nt.resp2_max_t + nt.ITI;

% Trial screen flips
[data.onset_fix,...
 data.onset_cue,...
 data.onset_stim_p,...
 data.onset_resp1,...
 data.onset_resp1_p,...
 data.onset_resp2,...
 data.onset_ITI] = deal(cell(size(data.seq,1),5));

% End of wait for trial end
data.wait_trial_end = zeros(size(data.seq,1),1);

% Before block screen flips
[data.btn_instr,...
data.onset_instr,...
data.onset_start_mri] = deal(cell(1,5));

% Pause screen flips
% data.onset_pause = cell(nt.blocks-1,5);

% Analog input trigger
data.ao_events = cell(size(data.seq,1),1);
data.ai_trigger = zeros(1,5);

% Scanner trigger
[data.mri_trigger,...
 data.mri_trigger_date] = deal(cell(size(data.seq,1),1));

data.mri_wait = zeros(size(data.seq,1),2);

% Stimulus trigger
[data.ao_trigger_pre,...
 data.ao_trigger,...
 data.ao_trigger_post] = deal(zeros(size(data.seq,1),1));

% Response tracking
[data.resp1_btn,...
data.resp1_t,...
data.resp1,...
data.resp2_btn,...
data.resp2_t,...
data.resp2] = deal(zeros(size(data.seq,1),1));


%% Parallel port
[dio,lpt_adr] = dio_setup(nt.lpt_adr,nt.lpt_dir);


%% Screen

window = Screen('OpenWindow',0,nt.window_color);
HideCursor;

Screen('TextFont',window,nt.txt_font);               
             
% Get screen frame rate
Priority(1); % recommended by Mario Kleiner's Perfomance & Timing How-to
flip_t = Screen('GetFlipInterval',window,nt.get_flip_i);
Priority(0);
data.flip_t = flip_t;

% Compute response text location
[data.window(1),data.window(2)] = Screen('WindowSize',window);
resp1_x1 = WindowCenter(window) - nt.resp1_offset;
resp2_x1 = WindowCenter(window) - nt.resp1_offset*3;                                

    
%% EXPERIMENTAL PROCEDURE %%
% Priority(1) seems to cause DataMissed events for analog input
block = data.seq(1,1);


%% Instructions

% Load image data
instr_images = load_images([instr_dir instr_subdir.name '/'],nt.instr_img_wildcard);

% Show images
[data.btn_instr, data.onset_instr] = show_instr_img(instr_images,window,dio,lpt_adr);

% Delete image data from memory
clear instr_images img_texture


%% Analog input

ai.LogFileName = [tempdir nt.file_prefix p_data.ID '_ai_0' num2str(block)];

flushdata(ai);
start(ai);

data.ai_logfile = ai.LogFileName;        
data.ai_trigger = datenum(ai.InitialTriggerTime);        

WaitSecs(2);


%% Prompt - Start scanner

Screen('TextSize',window,nt.txt_size);
DrawFormattedText(window,nt.scanner_msg,'center','center',nt.txt_color);
[data.onset_start_mri{1,:}] = Screen('Flip',window);

%% Trial loop

for i = 1:size(data.seq,1)    
    
    %%% WAIT FOR SCANNER %%%
    
    [data.mri_trigger{i},data.mri_trigger_date{i},data.mri_wait(i,1),data.mri_wait(i,2)] = wait_for_scanner(dio,lpt_adr,nt.TR,nt.trigger_bit,nt.trigger_max);
    
    
    %%% FIX %%%
    
    % Set font size for symbols
    Screen('TextSize',window,nt.cue_size);
    DrawFormattedText(window,nt.fix,'center','center',nt.txt_color);
    
    [data.onset_fix{i,:}] = Screen('Flip',window,data.mri_trigger{i}(end)+nt.trigger2fix-flip_t);
    
    
    %%% CUE %%%
    
    DrawFormattedText(window,nt.cue,'center','center',nt.txt_color);
    [data.onset_cue{i,:}] = Screen('Flip',window,data.onset_fix{i,1}+nt.fix_t-flip_t);   
    
    
    %%% STIMULUS %%%
    
    % Select intensity
    
    switch data.seq(i,2)
        case 0 % null
            data.intensity(i,1) = 0;
        case 1 % near
            data.intensity(i,1) = round_dec(data.near*data.seq(i,3),nt.stim_dec);
        case 2 % supra
            data.intensity(i,1) = round_dec(data.supra*data.seq(i,3),nt.stim_dec);
    end
    
    % Buffer waveform
    
    if data.intensity(i,1) == 0
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.stim_wave*-1]);
    else
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.stim_wave*data.intensity(i,1)]);
    end
    
    % Start analog output (5.7-7.7 ms)
%     start(ao_udd);
    
    % Random stimulus delay (locked to scanner trigger)
    data.ao_trigger_pre(i,1) = WaitSecs('UntilTime',data.mri_trigger{i}(end)+nt.trigger2fix+nt.fix_t+data.seq(i,4));
    
    % Trigger waveform with ao_udd (14-19 ms) and with ao (17-20)
    start(ao_udd);
    wait(ao_udd,.5);
    
    data.ao_trigger_post(i,1) = GetSecs;
    data.ao_events{i,1} = ao.EventLog;
    data.ao_trigger(i,1) = datenum(data.ao_events{i,1}(2).Data.AbsTime);
    
    
    %%% PAUSE AFTER STIMULUS %%%
    
    DrawFormattedText(window,nt.fix,'center','center',nt.txt_color);
    [data.onset_stim_p{i,:}] = Screen('Flip',window,data.onset_cue{i,1}+nt.cue_t-flip_t);
    
    
    %%% RESPONSE 1 - DETECTION %%%
    
    % Response options
    % 28 ms
    Screen('TextSize',window,nt.txt_size);
    resp1_nx1 = DrawFormattedText(window,data.resp1_txt(1,:),resp1_x1,'center',nt.txt_color);
                DrawFormattedText(window,data.resp1_txt(2,:),data.window(1)-resp1_nx1,'center',nt.txt_color);

    [data.onset_resp1{i,:}] = Screen('Flip',window,data.onset_stim_p{i,1}+nt.stim2resp-flip_t);
        
    % Wait for key press
    [data.resp1_btn(i,1),data.resp1_t(i,1),data.resp1_port(i,:)] = parallel_button(nt.resp1_max_t,data.onset_resp1{i,1},nt.resp_window,dio,lpt_adr);        

    % RT dependent fix between responses
    if nt.resp1_max_t-data.resp1_t(i,1) > nt.resp_p_min_t
        Screen('TextSize',window,nt.cue_size);
        DrawFormattedText(window,nt.ITI_cue,'center','center',nt.txt_color);
        [data.onset_resp1_p{i,:}] = Screen('Flip',window);
    end        
    
    
    %%% RESPONSE 2 - CONFIDENCE %%%
    
    % Response options
    % Screen('TextSize') takes ~10 ms
    % DrawFormattedText takes ~42 ms
    Screen('TextSize',window,nt.txt_size);
    resp2_nx1 = DrawFormattedText(window,data.resp2_txt(1),resp2_x1,'center',nt.txt_color);
                DrawFormattedText(window,data.resp2_txt(2),resp1_x1,'center',nt.txt_color);
                DrawFormattedText(window,data.resp2_txt(3),data.window(1)-resp1_nx1,'center',nt.txt_color);
                DrawFormattedText(window,data.resp2_txt(4),data.window(1)-resp2_nx1,'center',nt.txt_color);
    
    if GetSecs > data.onset_resp1{i,1}+nt.resp1_max_t-2*flip_t %GetSecs-resp1_onset(i,1)-nt.resp1_max_t+2*flip_t > 0
        [data.onset_resp2{i,:}] = Screen('Flip',window);
    else
        [data.onset_resp2{i,:}] = Screen('Flip',window,data.onset_resp1{i,1}+nt.resp1_max_t-flip_t);
    end
        
    % Wait for key press
    [data.resp2_btn(i,1),data.resp2_t(i,1),data.resp2_port(i,:)] = parallel_button(nt.resp2_max_t,data.onset_resp2{i,1},nt.resp_window,dio,lpt_adr);   
    
    
    %%% ITI %%%
    
    Screen('TextSize',window,nt.cue_size);
    DrawFormattedText(window,nt.ITI_cue,'center','center',nt.txt_color);
    [data.onset_ITI{i,:}] = Screen('Flip',window);

    
    %%% RESPONSE EVALUATION %%% (0.2-5.8 ms)
    
    % Response 1
    switch data.resp1_btn(i,1)
        case num2cell(nt.btn_resp1)
            switch data.resp1_txt(nt.btn_resp1==data.resp1_btn(i,1))
                case nt.resp1_txt(1)
                    data.resp1(i,1) = 1; % yes
                case nt.resp1_txt(2)
                    data.resp1(i,1) = 0; % no
            end
%         case nt.btn_esc
%             break
        otherwise
            data.resp1(i,1) = 0;
    end             

    % Response 2
    switch data.resp2_btn(i,1)
        case num2cell(nt.btn_resp2)
            data.resp2(i,1) = str2double(data.resp2_txt(nt.btn_resp2==data.resp2_btn(i,1)));
%         case nt.btn_esc
%             break
        otherwise
            data.resp2(i,1) = 0;
    end
    
    
    %%% WAIT UNTIL TRIAL END - TR/2 %%%

    if i < size(data.seq,1)
        data.wait_trial_end(i,1) = WaitSecs('UntilTime',data.mri_trigger{i}(end)+nt.trigger2fix+data.trial_t-nt.TR/2);
    else
        data.wait_trial_end(i,1) = WaitSecs('UntilTime',data.mri_trigger{i}(end)+nt.trigger2fix+data.trial_t);
    end
    
end


%% End procedures

% Stop analog input recording
stop(ai);

% Close all screens
sca;


%% Error handling

catch lasterr
    stop(ai);
    sca;
    rethrow(lasterr);
end