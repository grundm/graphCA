function data = psi_1AFC(psi,ao,ai,ID,file_end)
% psi_1AFC(psi,ao,ai) starts the threshold estimation for a 
% one-alternative forced choice (1AFC) paradigm (yes/no procedure).
%   
% It relies on the Palamedes toolbox by Prins & Kingdom (2009), see
% http://www.palamedestoolbox.org
%
% % Input variables %
%   psi             - settings structure (doc psi_1AFC_setup)
%   ao              - analog output object
%   ai              - analog input object
%   ID              - participant ID as string (e.g., p_data.ID)
%   file_end        - string that defines end of filename
%
% % Output variables %
%   data            - output structure (e.g., sequence, responses, ...)
%
% Author:           Martin Grund
% Last update:      February 1, 2016

try

%% SETUP %%    
    
%% Input device
[dio,lpt_adr] = dio_setup(psi.lpt_adr,psi.lpt_dir);


%% Screen

% Open window
window = Screen('OpenWindow',0,psi.window_color);
HideCursor;

% Get screen frame rate
Priority(1); % recommended by Mario Kleiner's Perfomance & Timing How-to
flip_t = Screen('GetFlipInterval',window,200);
Priority(0);
data.flip_t = flip_t;

% Set font
Screen('TextFont',window,psi.txt_font);

% Compute response text location
[data.window(1),data.window(2)] = Screen('WindowSize',window);
resp1_x = WindowCenter(window) - psi.resp1_offset;


%% Random number generator
data.rng_state = set_rng_state(psi);


%% Response-button mapping

% nt_exp: 2 responses -> 4 conditions
% 1: JN & 1234
% 2: JN & 4321
% 3: NJ & 1234
% 4: NJ & 4321

data.resp_btn_map = mod(str2double(ID)-1,4)+1;

switch data.resp_btn_map
    case {1,2}
        data.resp_txt = psi.resp_txt;
    case {3,4}
        data.resp_txt = flipud(psi.resp_txt);
end


%% Up/down method

UD = PAL_AMUD_setupUD('up', psi.UD_up, ...
                      'down', psi.UD_down, ...
                      'stepSizeUp', psi.UD_stepSizeUp, ...
                      'stepSizeDown', psi.UD_stepSizeDown, ...
                      'stopCriterion', psi.UD_stopCriterion, ...
                      'stopRule', psi.UD_stopRule, ...
                      'startValue', psi.UD_startValue, ...
                      'xMax', psi.UD_xMax, ...
                      'xMin', psi.UD_xMin);
                  

%% Sequence

% Compute number of null trials based on specified rate
data.trials_psi_null = round(psi.trials_psi * (psi.psi_null_rate/(1-psi.psi_null_rate)) );

% Shuffle sequence of psi method target and non-target (null) trials
data.seq_psi = Shuffle([ones(psi.trials_psi,1); zeros(data.trials_psi_null,1);]);

% Test block
data.seq_test = [];

for i = 1:length(psi.trials_test)
	data.seq_test = [data.seq_test; psi.stim_test(i)*ones(psi.trials_test(i),1)];
end

data.seq_test = Shuffle(data.seq_test);

% Create complete sequence block vector
% 1 - UD; 2 - PM; 3 - Test
data.block = [ones(UD.stopRule,1); 2*ones(length(data.seq_psi),1); 3*ones(length(data.seq_test),1)];
data.seq = [-1*ones(UD.stopRule,1); data.seq_psi; data.seq_test;];
 
% Random stimlus delays
% data.stim_delay = round( psi.stim_delay(1) +
data.stim_delay = Shuffle(round_dec(linspace(psi.stim_delay(1),psi.stim_delay(2),size(data.seq,1)),4))';

% Random inter trial intervals (ITI)
data.ITI = Shuffle(round_dec(linspace(psi.ITI(1),psi.ITI(2),size(data.seq,1)),4))';
% Make ITI divisible by flip time
data.ITI = data.ITI - mod(data.ITI, flip_t);


%% Stimulus

% Generate default waveform vector
[data.stim_wave, data.stim_offset] = rectpulse(psi.pulse_t,1,ao.sampleRate,psi.wave_t);


%% Timing

% Screen flips
[data.onset_fix,...
 data.onset_cue,...
 data.onset_resp,...
 data.onset_ITI] = deal(cell(size(data.seq,1),5));

% Analog input trigger
data.ao_events = cell(size(data.seq,1),1);

% Stimulus trigger
[data.ao_trigger_pre,...
 data.ao_trigger,...
 data.ao_trigger_post] = deal(zeros(size(data.seq,1),1));

% Response tracking
[data.resp_btn,...
data.resp_t,...
data.resp] = deal(zeros(size(data.seq,1),1));


%% EXPERIMENTAL PROCEDURE %%
% Priority(1) seems to cause DataMissed events for analog input

%% Instructions

% Get directory of instruction images for response-button mapping condition
instr_dir = [fileparts(mfilename('fullpath')) psi.instr_dir];
instr_subdir = dir([instr_dir psi.instr_subdir_wildcard num2str(data.resp_btn_map) '*']);

% Load image data
instr_images = load_images([instr_dir instr_subdir.name '/'],psi.instr_img_wildcard);

% Show images
[data.btn_instr, data.onset_instr] = show_instr_img(instr_images,window,dio,lpt_adr);

% Delete image data from memory
clear instr_images img_texture


%% Analog output

% Accelerate analog output control essentially (see nt_exp for details)

ao_udd = daqgetfield(ao,'uddobject');


%% Analog input recording

ai.LogFileName = [tempdir psi.file_prefix ID '_ai_' file_end];

flushdata(ai);
start(ai);

% Save logfilename
data.ai_logfile{1,1} = ai.LogFileName;
data.ai_trigger = datenum(ai.InitialTriggerTime); 

WaitSecs(2);

%% Threshold assesment

for i = 1:size(data.seq,1);
    
    % Set font size for symbols
    Screen('TextSize',window,psi.cue_size);

    %%% FIX %%%
    
    DrawFormattedText(window,psi.fix,'center','center',psi.txt_color);
    
    % 2nd condition shall account for longer procedures after up/down and psi method
    % trials (i == 1 + UD.stopRule || i == 1 + UD.stopRule + length(data.seq_psi))
    if i == 1 || GetSecs-data.onset_ITI{i-1,1}+flip_t > data.ITI(i-1)
        [data.onset_fix{i,:}] = Screen('Flip',window);
    else
        [data.onset_fix{i,:}] = Screen('Flip',window,data.onset_ITI{i-1,1}+data.ITI(i-1)-flip_t);
    end
    
    
    %%% CUE %%%
    
    DrawFormattedText(window,psi.cue,'center','center',psi.txt_color);
    [data.onset_cue{i,:}] = Screen('Flip',window,data.onset_fix{i,1}+psi.fix_t-flip_t);   
    
    
    %%% STIMULUS %%%
    
    % Select intensity
    
    if data.seq(i) == 0;                     % Null trial
      
        data.intensity(i,1) = 0;
                        
    elseif data.seq(i) == -1;                % Up/down method trial
        
        data.intensity(i,1) = UD.xCurrent;
            
    elseif (data.seq(i) > 0) && ~PM.stop     % Psi method trial
        
        data.intensity(i,1) = PM.xCurrent;
        
    elseif (data.seq(i) > 0) && PM.stop      % Test trials        
                
        data.intensity(i,1) = round_dec(PAL_Quick(data.PF_params_PM,data.seq(i),'Inverse'),psi.stim_dec);        
        
        % Check if test intensity would exceed stimulus range
        if abs(data.intensity(i,1)) > max(psi.stim_range)
            data.intensity(i,1) = max(psi.stim_range);            
        end                
    end
    
    % Buffer waveform
    
    if data.intensity(i,1) == 0
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.stim_wave*-1]);
    else
        putdata(ao_udd,[data.stim_wave*data.intensity(i,1) data.stim_wave*data.intensity(i,1)]);
    end
                
    % Random stimulus delay
    data.ao_trigger_pre(i,1) = WaitSecs('UntilTime',data.onset_cue{i,1}+data.stim_delay(i));
    
    % Start analog output (triggers waveform immediately)
    start(ao_udd);
    wait(ao_udd,.5);
    
    data.ao_trigger_post(i,1) = GetSecs;
    data.ao_events{i,1} = ao.EventLog;
    data.ao_trigger(i,1) = datenum(data.ao_events{i,1}(2).Data.AbsTime);
    
    %%% RESPONSE %%%
    
    % Response options
    Screen('TextSize',window,psi.txt_size);
    resp1_nx = DrawFormattedText(window,data.resp_txt(1),resp1_x,'center',psi.txt_color);
               DrawFormattedText(window,data.resp_txt(2),data.window(1)-resp1_nx,'center',psi.txt_color);
    [data.onset_resp{i,:}] = Screen('Flip',window,data.onset_cue{i,1}+psi.cue_t-flip_t);
    
    
    % Wait for key press
    [data.resp_btn(i,1),data.resp_t(i,1),data.resp_port(i,:)] = parallel_button(psi.maxRespTime,data.onset_resp{i,1},psi.resp_window,dio,lpt_adr);
    
    
    %%% ITI %%%
    
    % Pause screen
    Screen('TextSize',window,psi.cue_size);
    DrawFormattedText(window,psi.pause,'center','center',psi.txt_color);
    [data.onset_ITI{i,:}] = Screen('Flip',window);

    if i == size(data.seq,1)
        data.last_trial = WaitSecs('UntilTime',data.onset_ITI{i,1}+data.ITI(i));
    end
    
    % Evaluate response
    switch data.resp_btn(i,1)
        case num2cell(psi.btn)
            switch data.resp_txt(psi.btn==data.resp_btn(i,1))
                case psi.resp_txt(1)
                    data.resp(i,1) = 1; % yes
                case psi.resp_txt(2)
                    data.resp(i,1) = 0; % no
            end
%         case psi.btn_esc
%             break
        otherwise
            data.resp(i,1) = 0;
    end   
    
    % Update UD or PM structure with response (1: correct, 0: incorrect)
    if data.seq(i) == -1;
        
        UD = PAL_AMUD_updateUD(UD, data.resp(i));
        
        if UD.stop
            
            %% Analyze up/down method %%
            
            % Compute mean from up/down method
            data.UD_mean = PAL_AMUD_analyzeUD(UD,psi.UD_stopCriterion,psi.UD_meanNumber);
            
            % Compute intensity range of trials used for mean
            data.UD_range = [min(UD.x(end-psi.UD_meanNumber-1:end)) max(UD.x(end-psi.UD_meanNumber-1:end))];            
            
            % Define prior alpha range ± psi.UD_range_factor of up/down mean range
            tmp_priorAlphaRange = data.UD_range(1)*psi.UD_range_factor(1):psi.priorAlphaSteps:data.UD_range(2)*psi.UD_range_factor(2);

            % Define priors for psychometric function fitting
            grid.alpha = tmp_priorAlphaRange;
            grid.beta = psi.priorBetaRange;
            grid.gamma = psi.priorGammaRange;
            grid.lambda = psi.priorLambdaRange;
            
            % Compute intensity - response frequency matrix of up/down
            % method
            data.x_resp_freq_UD = count_resp([UD.x' UD.response']);

            % Fit psychometric function to up/down method data
            [data.PF_params_UD, data.posterior_UD] = PAL_PFBA_Fit(data.x_resp_freq_UD(:,1),data.x_resp_freq_UD(:,2),data.x_resp_freq_UD(:,3),grid,@PAL_Quick);
                       
            % ??? MAYBE USE THE THRESHOLD ESTIMATION            
            
            %% Prepare psi method %%
            
            % Shift prior alpha range
            tmp_priorAlphaRange = tmp_priorAlphaRange + (data.PF_params_UD(1,1)-mean(tmp_priorAlphaRange));
            
            % Restrict stimulus range to prior alpha
%             tmp_stim_range = psi.stim_range(psi.stim_range>=min(tmp_priorAlphaRange));
%             tmp_stim_range = tmp_stim_range(tmp_stim_range<=max(tmp_priorAlphaRange));
            tmp_stim_range = psi.stim_range;
            
            PM = PAL_AMPM_setupPM('numtrials', psi.trials_psi, ...
                      'stimRange', tmp_stim_range, ...
                      'PF', psi.PF, ...
                      'priorAlphaRange', tmp_priorAlphaRange, ...
                      'priorBetaRange', psi.priorBetaRange, ...
                      'priorGammaRange', psi.priorGammaRange, ...
                      'priorLambdaRange', psi.priorLambdaRange, ...
                      'prior', data.posterior_UD);            
        end
    
    elseif (data.seq(i) > 0) && ~PM.stop
        PM = PAL_AMPM_updatePM(PM, data.resp(i));
        if PM.stop
            data.near = PM.threshold(end);
            data.PF_params_PM = [PM.threshold(end); 10.^PM.slope(end); PM.guess(end); PM.lapse(end);];
            data.supra = PAL_Quick(data.PF_params_PM, psi.supra_p, 'Inverse');
        end
    end

end


%% End procedures

% Stop analog input recording
stop(ai);

% Save up/down method and psi method structures
data.UD = UD;
data.PM = PM;

% Compute intervals
data = psi_1AFC_intervals(data);

% Close window
Screen('Close',window);
ShowCursor;


%% Error handling

catch lasterr
    stop(ai);
    sca;
    rethrow(lasterr);
end

end