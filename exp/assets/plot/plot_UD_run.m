function plot_UD_run(UD)
%   plot_UD_run(UD) creates a figure of the applied intensities over the 
%   run of the up/down method block.
%
%   Additionally, the figure indicates 'yes' responses.
%
%   Input:
%   UD      - output structure by up/down method (PAL_AMUD_updateUD.m)
%
%   Author:           Martin Grund
%   Last update:      January 5, 2016

Fig_UD = figure;
hold on;
set(Fig_UD,'Name','Up/down method trials');

plot(1:length(UD.x),UD.x);

bar(1:length(UD.x),UD.response/2,'FaceColor',[.6 .6 .6],'LineStyle','none');

hold off;