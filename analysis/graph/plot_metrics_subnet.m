%% Plot mean graph metrics per subnetwork
%
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      July 1, 2020

%% Load data

cd('/data/pt_nro150/graphca/graph')

addpath(genpath('../assets/'));

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

%% Edit subnetwork labels

net_label = {'Sensory/somatomotor hand'...
             'Sensory/somatomotor mouth'...
             'Cingulo-opercular task control'...
             'Auditory'...
             'Default mode'...
             'Memory retrieval'...
             'Visual'...
             'Fronto-parietal task control'...
             'Salience'...
             'Subcortical'...
             'Ventral attention'...
             'Dorsal attention'...
             'Cerebellar'...
             'Uncertain'};


%% Average for each participant for each network the participation and
% clustering coefficient

% NOTE: These are not normalized graph metrics

thr_ind = 2; % 2 = 10%

% Loop conditions mean
for k = 1:5
    
    % Loop subnetworks
    for i = 1:max(power.net_i)

        P_net_mean{1,k}(i,:) = mean(d(thr_ind).group.gGraph.all.P{1,k}(power.net_i==i,:),1);
        
        C_net_mean{1,k}(i,:) = mean(d(thr_ind).group.gGraph.all.C{1,k}(power.net_i==i,:),1);
        
        BC_net_mean{1,k}(i,:) = mean(d(thr_ind).group.gGraph.all.BC_norm{1,k}(power.net_i==i,:),1);
        
        WD_net_mean{1,k}(i,:) = mean(d(thr_ind).group.gGraph.all.WD{1,k}(power.net_i==i,:),1);

    end

end

%% Average nodal graph metrics of random networks

% Loop conditions
for k = 1:5

    % Loop subnetworks
    for i = 1:max(power.net_i)

        % Loop participants
        for id = 1:length(d(thr_ind).mat_prep)
            % For 100 random networks 264 nodal graph metrics (100 x 264)
            % Select the nodes of the one subnetworks
            % Average across the 100 random networks
            % Average across the subnetwork
            P_net_rnd_mean{1,k}(i,id) = mean(mean(d(thr_ind).mat_prep(id).metric{1,k}.rnd.P(:,power.net_i==i),1));
            
            C_net_rnd_mean{1,k}(i,id) = mean(mean(d(thr_ind).mat_prep(id).metric{1,k}.rnd.C(:,power.net_i==i),1));
            
            BC_net_rnd_mean{1,k}(i,id) = mean(mean(d(thr_ind).mat_prep(id).metric{1,k}.rnd.BC_norm(:,power.net_i==i),1));
            
            WD_net_rnd_mean{1,k}(i,id) = mean(mean(d(thr_ind).mat_prep(id).metric{1,k}.rnd.WD(:,power.net_i==i),1));
        end
    end
end

%% Normalize graph metrics with random network graph metrics

% Loop conditions
for k = 1:5
    
    P_net_mean_norm{1,k} = P_net_mean{1,k}./P_net_rnd_mean{1,k};
    C_net_mean_norm{1,k} = C_net_mean{1,k}./C_net_rnd_mean{1,k};
    BC_net_mean_norm{1,k} = BC_net_mean{1,k}./BC_net_rnd_mean{1,k};
    WD_net_mean_norm{1,k} = WD_net_mean{1,k}./WD_net_rnd_mean{1,k};
end


%% Test subnetwork means

for k = 1:5

    for i = 1:max(power.net_i)

        %unique(power.net_label{power.net_i_order})

        P_net_mean_signrank(i,k) = signrank(P_net_mean_norm{1,1}(i,:),P_net_mean_norm{1,k}(i,:))
        
        %[~,P_net_mean_ttest(i,k)] = ttest(P_net_mean{1,1}(i,:),P_net_mean{1,k}(i,:))
        
        P_net_mean_mean(i,k) = mean(P_net_mean_norm{1,k}(i,:),2)
        
        
        C_net_mean_signrank(i,k) = signrank(C_net_mean_norm{1,1}(i,:),C_net_mean_norm{1,k}(i,:))
        
        %[~,C_net_mean_ttest(i,k)] = ttest(C_net_mean{1,1}(i,:),C_net_mean{1,k}(i,:))
        
        C_net_mean_mean(i,k) = mean(C_net_mean_norm{1,k}(i,:),2)
        
        
        BC_net_mean_signrank(i,k) = signrank(BC_net_mean_norm{1,1}(i,:),BC_net_mean_norm{1,k}(i,:))
        
        BC_net_mean_mean(i,k) = mean(BC_net_mean_norm{1,k}(i,:),2)
        
        WD_net_mean_signrank(i,k) = signrank(WD_net_mean_norm{1,1}(i,:),WD_net_mean_norm{1,k}(i,:))
        
        WD_net_mean_mean(i,k) = mean(WD_net_mean_norm{1,k}(i,:),2)

    end

end


%%

% http://colorbrewer2.org/#type=qualitative&scheme=Dark2&n=3
col = [141 211 199;...
       255 255 179;...
       190 186 218;...
       251 128 114]./255;

%%

P_mean_CR = mean(d(thr_ind).group.gGraph.all.P{1,1},1);
P_mean_miss = mean(d(thr_ind).group.gGraph.all.P{1,2},1);
P_mean_hit = mean(d(thr_ind).group.gGraph.all.P{1,3},1);

signrank(P_mean_CR, P_mean_miss)
signrank(P_mean_miss, P_mean_hit)

C_mean_CR = mean(d(thr_ind).group.gGraph.all.C{1,1},1);
C_mean_miss = mean(d(thr_ind).group.gGraph.all.C{1,2},1);
C_mean_hit = mean(d(thr_ind).group.gGraph.all.C{1,3},1);

signrank(C_mean_CR, C_mean_miss)
signrank(C_mean_miss, C_mean_hit)
   
%% Test "paired" boxplot

C_miss_hit = zeros(31,14*2);

C_miss_hit(:,1:2:end) = C_net_mean{:,2}';
C_miss_hit(:,2:2:end) = C_net_mean{:,3}';

boxplot(C_miss_hit)

%% Clustering

%bar(C_net_mean_mean(:,1)-C_net_mean_mean(:,2))

b = bar(C_net_mean_mean(:,1:3),...
        'EdgeColor', [0 0 0]); % 'none'
    
%b = boxplot(C_net_mean_mean(:,1:2));

b(1).FaceColor = col(1,:);
b(2).FaceColor = col(3,:);
b(3).FaceColor = col(4,:);

b(1).BarWidth = 1;
b(2).BarWidth = 1;
b(3).BarWidth = 1;

title('Clustering per subnetwork');

ax = gca;

ylabel(ax, 'Mean clustering coefficient')

set(ax,'XTick', 1:length(net_label))
         
% set labels
set(ax,'XTickLabel', net_label)

set(ax,'XTickLabelRotation',45)

legend({'Confident CR','Confident miss','Confident hit'}, 'Location', 'SouthEastOutside');
legend('boxoff');

for i = 1:max(power.net_i)
    C_net_mean_signrank_miss_CR(i) = signrank(C_net_mean_norm{1,2}(i,:),C_net_mean_norm{1,1}(i,:));
    C_net_mean_signrank_miss_hit(i) = signrank(C_net_mean_norm{1,2}(i,:),C_net_mean_norm{1,3}(i,:));
    C_net_mean_signrank_hit_CR(i) = signrank(C_net_mean_norm{1,3}(i,:),C_net_mean_norm{1,1}(i,:));
end

[h, crit_p, adj_ci_cvrg, adj_p_miss_CR] = fdr_bh(C_net_mean_signrank_miss_CR,0.05);
adj_p_miss_CR

[h, crit_p, adj_ci_cvrg, adj_p_miss_hit] = fdr_bh(C_net_mean_signrank_miss_hit,0.05);
adj_p_miss_hit

[h, crit_p, adj_ci_cvrg, adj_p_hit_CR] = fdr_bh(C_net_mean_signrank_hit_CR,0.05);
adj_p_hit_CR

[h, crit_p, adj_ci_cvrg, adj_p_all] = fdr_bh([C_net_mean_signrank_miss_CR; C_net_mean_signrank_miss_hit; C_net_mean_signrank_hit_CR;],0.05);
adj_p_all

%% Participation

b = bar(P_net_mean_mean(:,1:3),...
        'EdgeColor', [0 0 0]);

b(1).FaceColor = col(1,:);
b(2).FaceColor = col(3,:);
b(3).FaceColor = col(4,:);

b(1).BarWidth = 1;
b(2).BarWidth = 1;
b(3).BarWidth = 1;

title('Participation per subnetwork');

ax = gca;

ylabel(ax, 'Mean participation coefficient')

set(ax,'XTick', 1:length(net_label));
         
% set labels
set(ax,'XTickLabel', net_label)

set(ax,'XTickLabelRotation',45)

legend({'Confident CR','Confident miss','Confident hit'}, 'Location', 'SouthEastOutside');
legend('boxoff');


for i = 1:max(power.net_i)
    P_net_mean_signrank_miss_CR(i) = signrank(P_net_mean_norm{1,2}(i,:),P_net_mean_norm{1,1}(i,:));
    P_net_mean_signrank_miss_hit(i) = signrank(P_net_mean_norm{1,2}(i,:),P_net_mean_norm{1,3}(i,:));
    P_net_mean_signrank_hit_CR(i) = signrank(P_net_mean_norm{1,3}(i,:),P_net_mean_norm{1,1}(i,:));
end

[h, crit_p, adj_ci_cvrg, adj_p_miss_CR] = fdr_bh(P_net_mean_signrank_miss_CR,0.05);
adj_p_miss_CR

[h, crit_p, adj_ci_cvrg, adj_p_miss_hit] = fdr_bh(P_net_mean_signrank_miss_hit,0.05);
adj_p_miss_hit

[h, crit_p, adj_ci_cvrg, adj_p_hit_CR] = fdr_bh(P_net_mean_signrank_hit_CR,0.05);
adj_p_hit_CR

%% Betweenness centrality

b = bar(BC_net_mean_mean(:,1:3),...
        'EdgeColor', [0 0 0]);

b(1).FaceColor = col(1,:);
b(2).FaceColor = col(3,:);
b(3).FaceColor = col(4,:);

b(1).BarWidth = 1;
b(2).BarWidth = 1;
b(3).BarWidth = 1;

title('Betweenness centrality per subnetwork');

ax = gca;

ylabel(ax, 'Mean betweenness centrality')

set(ax,'XTick', 1:length(net_label));
         
% set labels
set(ax,'XTickLabel', net_label)

set(ax,'XTickLabelRotation',45)

legend({'Confident CR','Confident miss','Confident hit'}, 'Location', 'SouthEastOutside');
legend('boxoff');


for i = 1:max(power.net_i)
    BC_net_mean_signrank_miss_CR(i) = signrank(BC_net_mean_norm{1,2}(i,:),BC_net_mean_norm{1,1}(i,:));
    BC_net_mean_signrank_miss_hit(i) = signrank(BC_net_mean_norm{1,2}(i,:),BC_net_mean_norm{1,3}(i,:));
    BC_net_mean_signrank_hit_CR(i) = signrank(BC_net_mean_norm{1,3}(i,:),BC_net_mean_norm{1,1}(i,:));
end

[h, crit_p, adj_ci_cvrg, adj_p_miss_CR] = fdr_bh(BC_net_mean_signrank_miss_CR,0.05);
adj_p_miss_CR

[h, crit_p, adj_ci_cvrg, adj_p_miss_hit] = fdr_bh(BC_net_mean_signrank_miss_hit,0.05);
adj_p_miss_hit

[h, crit_p, adj_ci_cvrg, adj_p_hit_CR] = fdr_bh(BC_net_mean_signrank_hit_CR,0.05);
adj_p_hit_CR

[h, crit_p, adj_ci_cvrg, adj_p_all] = fdr_bh([BC_net_mean_signrank_miss_CR; BC_net_mean_signrank_miss_hit; BC_net_mean_signrank_hit_CR;],0.05);
adj_p_all