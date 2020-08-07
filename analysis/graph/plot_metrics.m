function plot_metrics(c)

%% Settings
cond_ind = 1:length(c.cond);
cond_ind = 1:4; %[1,3];
cond_ind = [3,1,2,4];
cond_ind = [2,1,3];
cond_ind = [3,2,1];

% Significance asteriks
cond_pair = [2,3];
p_thr = .01;

metric_str = {'Q', 'P_mean', 'C_mean', 'L'};

fig_titles = {'Modularity', 'Participation', 'Clustering', 'Path Length'};

title_size = 13;
title_weight = 'normal';

x_axis_label = 'Threshold in %';

axis_label_size = 10;

axis_size = 8;

legend_location = 'SouthEast';

legend_labels = {'Miss','Hit','CR','Supra','Seed'};
legend_labels = {'Unaware','Aware','Control','Supra','Seed'};
legend_labels = {'CR', 'Miss', 'Hit', 'Supra', 'Baseline'};
legend_labels = legend_labels(cond_ind);

legend_size = 9;

trans = 0.6;

line_width = 2;

% Axis range

% Power (5-40%; N = 31)
y_range = [1.03 1.37;...
           0.85 1.00;...
           0.83 1.05;...
           0.995 1.017];


% % NOI
% y_range = [0.80 1.08;...
%            0.80 1.15;...
%            0.85 1.20;...
%            0.97 1.04];

% % Power (5-30%)
% y_range = [1.05 1.35;...
%            0.82 1.00;...
%            0.80 1.03;...
%            0.995 1.015];
%        
% % Power (5-90%)
% y_range = [1.05 1.40;...
%            0.82 1.00;...
%            0.80 1.03;...
%            0.995 1.015];  
%        
% % Power (10-90%)
% y_range = [1.13 1.39;...
%            0.83 1.01;...
%            0.94 1.02;...
%            0.997 1.007];         

% % http://colorbrewer2.org/#type=qualitative&scheme=Dark2&n=3
% col = [27,158,119;...
%        217,95,2;...
%        117,112,179]./255;

% http://colorbrewer2.org/#type=qualitative&scheme=Set3&n=4
% col = [255,255,179;         % Miss
%        190,186,218;         % Hit
%        141,211,199;         % CR
%        251,128,114]./255;   % Supra

col = [102,194,165;         % CR
       141,160,203;         % Miss      
       252,141,98;          % Hit       
       251,128,114;         % Supra
       0,0,0]./255;         % ROI  
   

col = col(cond_ind,:);

% x_tick_rotation = 55;
x_tick_rotation = 0;

%% Plot sub-figures

for i = 1:length(metric_str)

    fig1 = subplot(1,length(fig_titles),i);
    
    %set(fig1, 'color', [0.9 0.9 0.9])
    set(fig1, 'FontSize', axis_size) % Because axis tick label cannot be adressed directly
    set(fig1, 'DefaultLineLineWidth', line_width)

    % Lines with CI
    %boundedline(c.thr, c.(metric_str{i})(:,cond_ind), c.CI.(metric_str{i})(:,:,cond_ind), '-', 'alpha', 'cmap', colormap(col), 'transparency', trans, fig1);
    boundedline(c.thr*100, c.(metric_str{i})(:,cond_ind), c.CI.(metric_str{i})(:,:,cond_ind), '-', 'alpha', 'transparency', trans, 'cmap', col, fig1);
%     boundedline(c.thr*100, c.(metric_str{i})(:,cond_ind), c.SEM.(metric_str{i})(:,:,cond_ind), '-', 'alpha', 'transparency', trans, 'cmap', col, fig1);
    title(fig1,fig_titles{i},...
          'FontSize', title_size,...
          'FontWeight', title_weight);
      
    ax = gca;
    
    xlabel(ax, x_axis_label,...
           'FontSize', axis_label_size)

    hold(fig1,'on');

    % Significance asteriks
    plot_pval(fig1,c,metric_str{i},cond_pair,p_thr)
    
    % Legend
    if i == 1%length(metric_str)
        
        legend(fig1,legend_labels,...
               'Location', legend_location,...
               'FontSize', legend_size)
        legend(fig1,'boxoff');
    end
    
    % Axis range       
    axis(fig1,[min(c.thr*100)-5 max(c.thr*100)+5 y_range(i,:)]);
    
    ylim('auto');
    
    % X-axis ticks    
    set(ax,...
        'XTick', c.thr*100)
    
    set(ax,'XTickLabelRotation',x_tick_rotation)

end

%% Sub-function to plot asteriks between significant conditions

function plot_pval(fig,c,metric_str,cond_pair,p_thr)

    for i = 1:length(c.thr)
        pval = c.signrank(i).(metric_str)(cond_pair(1),cond_pair(2));
        
        if pval <= p_thr
            % Plot asterik for current threshold (x) between condition
            % pairs (y)
            plot(fig,c.thr(i)*100,mean(c.(metric_str)(i,[cond_pair(1),cond_pair(2)])),'k*','LineWidth',1);
        end
    end
