function plot_trial(nt)
% plot_trial(nt) uses the setting structure ofr nt_exp to plots the trial 
% sections as rectangles and the MRI pulses.

%% Settings

trigger_num = 21;

% Trial section rectangles 
section_y = 1; % y offset
section_h = 1; % height
section_c = [.9 .9 .9]; % color
section_l = '-'; % line style

txt_offset = -.15;

%%
fig = figure;
set(fig,'Name','Trial procedure');

hold on;

xlim([-1 trigger_num+2]);
ylim([0 3]);

%% Trial sections

% Fix              
fix_rect = rectangle('Position',[nt.trigger2fix section_y nt.fix_t section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
fix_pos = get(fix_rect,'Position');

fix_txt = text(fix_pos(1)+fix_pos(3)/2+txt_offset,section_y+section_h/2,'F');
fix_txt_pos = get(fix_txt,'Position');
      
% Cue
cue_rect = rectangle('Position',[fix_pos(1)+fix_pos(3) section_y nt.cue_t section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
cue_pos = get(cue_rect,'Position');

text(cue_pos(1)+cue_pos(3)/2+txt_offset,fix_txt_pos(2),'C');

% Pause
pause_rect = rectangle('Position',[cue_pos(1)+cue_pos(3) section_y nt.stim2resp section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
pause_pos = get(pause_rect,'Position');

text(pause_pos(1)+pause_pos(3)/2+txt_offset,fix_txt_pos(2),'P');

% Response 1
resp1_rect = rectangle('Position',[pause_pos(1)+pause_pos(3) section_y nt.resp1_max_t section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
resp1_pos = get(resp1_rect,'Position');

text(resp1_pos(1)+resp1_pos(3)/2+txt_offset,fix_txt_pos(2),'R1');

% Response 2
resp2_rect = rectangle('Position',[resp1_pos(1)+resp1_pos(3) section_y nt.resp2_max_t section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
resp2_pos = get(resp2_rect,'Position');

text(resp2_pos(1)+resp2_pos(3)/2+txt_offset,fix_txt_pos(2),'R2');

% ITI
ITI_rect = rectangle('Position',[resp2_pos(1)+resp2_pos(3) section_y nt.ITI section_h],...
          'FaceColor',section_c,...
          'LineStyle',section_l);
ITI_pos = get(ITI_rect,'Position');

text(ITI_pos(1)+ITI_pos(3)/2+txt_offset,fix_txt_pos(2),'ITI');

%% Trigger

trigger = 0:nt.TR:trigger_num;

bar(trigger,repmat([0 section_y],numel(trigger),1),'FaceColor',[.6 .6 .6],'LineStyle','none');