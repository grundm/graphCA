%% Plot mean connectivity matrices
%
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      July 1, 2020

%% Load data

mri_path = '/data/pt_nro150/mri';

% gppi_group_path = [mri_path '/group/gppi_power_all_cond2_limPre/glm_FSL'];
gppi_group_path = [mri_path '/group/gppi_power_all_cond_conf_limPre/glm_FSL'];

load([gppi_group_path '/graph_metrics_conmat_r100_05-40.mat']);


%% Load subnetwork labels for nodes

power.xlsx = [mri_path '/atlas/2011_Neuron_data_updated/2011_Neuron_data/Neuron_consensus_264.xlsx'];

power.net_i = xlsread(power.xlsx,1,'AF3:AF266');            % ROI Master Assignment
[~, power.net_label] = xlsread(power.xlsx,1,'AK3:AK266');   % Suggested System
[~, power.net_col] = xlsread(power.xlsx,1,'AI3:AI266');     % Suggested Color

% not ordered yet?
% Replace "Uncertain" = -1 with 14
power.net_i(power.net_i == -1) = max(power.net_i) + 1;
% Order
[~, power.net_i_order] = sort(power.net_i);

%% Plot colorbar

% http://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12
% + 4th & 2nd last color of:
% http://colorbrewer2.org/#type=diverging&scheme=BrBG&n=11

col = [166,206,227;...
        31,120,180;...
        178,223,138;...
          51,160,44;...
        251,154,153;...
        227,26,28;...
        253,191,111;...
        255,127,0;...
        202,178,214;...
        106,61,154;...
        255,255,153;...
        177,89,40;...
        223,194,125;...
        1,102,94];

imagesc(power.net_i(power.net_i_order))

colorbar('Direction','reverse',...
         'Ticks',1:max(power.net_i),...
         'YTickLabel', unique(power.net_label(power.net_i_order),'stable'))
     
colormap(col./255)    


%% Group average - connectivity matrices (beta estimates)

% Loop conditions
for k = 1:length(mat(1).cond)

    % Take first participant's matrix
    group_mat{1,k} = mat(1).beta_mat{1,k};
    
    % Add all other participant's matrices
    for i = 2:length(mat)
        group_mat{1,k} = group_mat{1,k} + mat(i).beta_mat{1,k};
    end

    % Devide by number of participants
    group_mat{1,k} = group_mat{1,k}./length(mat);
    
end

%%

cond_str = {'CR', 'near_miss', 'near_hit'};
cond_str = {'CR_conf', 'near_miss_conf', 'near_hit_conf'};
thr_ind = 2; % 10%
clims = [0 .32];

figure

for i = 1:length(cond_str)
   
    fig1 = subplot(1,length(cond_str),i);
    
    %betas = group_mat{1,find(strcmp(mat(1).cond,'near_miss'))};
    betas = d(thr_ind).group.mat_mean{1,find(strcmp(d(thr_ind).mat_prep(1).cond,cond_str{i}))};
    
    max(max(betas))
    
    imagesc(fig1,betas(power.net_i_order,power.net_i_order),clims);

    title(cond_str{i})
    
    
    colorbar
    
    %colorbar('Direction','reverse')
    %axis ij
    colormap(hot)

end