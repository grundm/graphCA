%% FUNCTIONS
cd('/data/pt_nro150/graphca/graph')

addpath(genpath('../assets/'));

%% LOAD ORIGINAL

mat = load_conmat;

%% LOAD
mri_path = '/data/pt_nro150/mri';
% gppi_group_path = [mri_path '/group/gppi_power_all_cond_conf/glm_FSL'];
gppi_group_path = [mri_path '/group/gppi_power_all_cond2/glm_FSL'];
% gppi_group_path = [mri_path '/group/gppi_power_r4/glm_FSL'];

load([gppi_group_path '/conmat.mat'])

%% SAVE

mkdir(gppi_group_path);

save([gppi_group_path '/conmat.mat']', 'mat');

%% COMPUTE NORMALIZED GRAPH METRICS FOR MULTIPLE THRESHOLDS

mat_thr = 0.05:0.05:0.40;

rnd_iter = 100;
rnd_rewire_i = 5;

d = parrun_graph(mat,mat_thr,rnd_iter,rnd_rewire_i);

save([gppi_group_path '/graph_metrics_conmat_r100_05-40.mat'], 'd', '-v7.3');

%% COMPARE CONDITIONS

cond_ind = 1:3;
CI_width = 0.95;
wo_BC_WD = 1; % 1 - false for data without betweenness centrality and within-module degree; 0 - true

c = cmp_cond(d, cond_ind, CI_width, wo_BC_WD);

%% SAVE GRAPH ANALYTICAL RESULTS

load([gppi_group_path '/graph_metrics_conmat_r100_05-40.mat']);

%% PLOT GRAPH METRICS

plot_metrics(c);


%% FDR-correction

combinations = [1 2; 1 3; 2 3];

wo_BC_WD = 1;

for j = 1:size(combinations,1)
    for i = 1:8
        p_Q(j,i) = c.signrank(i).Q(combinations(j,1),combinations(j,2));
        p_P(j,i) = c.signrank(i).P_mean(combinations(j,1),combinations(j,2));
        p_C(j,i) = c.signrank(i).C_mean(combinations(j,1),combinations(j,2));
        p_L(j,i) = c.signrank(i).L(combinations(j,1),combinations(j,2));
        
        if wo_BC_WD == 0
            p_BC_norm_mean(j,i) = c.signrank(i).BC_norm_mean(combinations(j,1),combinations(j,2));
            p_WD_mean(j,i) = c.signrank(i).WD_mean(combinations(j,1),combinations(j,2));
        end
        
    end
end

[h.Q, crit_p.Q, adj_ci_cvrg.Q, adj_p.Q] = fdr_bh(p_Q);
[h.P, crit_p.P, adj_ci_cvrg.P, adj_p.P] = fdr_bh(p_P);
[h.C, crit_p.C, adj_ci_cvrg.C, adj_p.C] = fdr_bh(p_C);
[h.L, crit_p.L, adj_ci_cvrg.L, adj_p.L] = fdr_bh(p_L);

if wo_BC_WD == 0
    [h.BC_norm_mean, crit_p.BC_norm_mean, adj_ci_cvrg.BC_norm_mean, adj_p.BC_norm_mean] = fdr_bh(p_BC_norm_mean);
    [h.WD_mean, crit_p.WD_mean, adj_ci_cvrg.WD_mean, adj_p.WD_mean] = fdr_bh(p_WD_mean);
end

%% Bayes Factor

prior=sqrt(2)/2;
%prior=.4;

for i = 1:length(d)
    
    [bf10.Q(i),p.Q(i)] = bf.ttest(d(i).group.gGraph.all.Q(:,3),d(i).group.gGraph.all.Q(:,2),'scale',prior);
    
    [bf10.P_mean(i),p.P_mean(i)] = bf.ttest(d(i).group.gGraph.all.P_mean(:,3), d(i).group.gGraph.all.P_mean(:,2),'scale',prior);
    
    [bf10.C_mean(i),p.C_mean(i)] = bf.ttest(d(i).group.gGraph.all.C_mean(:,3), d(i).group.gGraph.all.C_mean(:,2),'scale',prior);
    
    [bf10.L(i),p.L(i)] = bf.ttest(d(i).group.gGraph.all.L(:,3), d(i).group.gGraph.all.L(:,2),'scale',prior);        
    
end

%%

fig1 = figure;

BF_boundaries = [1,3];
BF_label_str = {'Anecdotal', 'Moderate'};

BF_max = 6;

subplot(1,4,1);

plot(c.thr*100,1./bf10.Q);

hline(BF_boundaries,'r-',BF_label_str)

ylim([0 BF_max])

subplot(1,4,2);

plot(c.thr*100,1./bf10.P_mean);

hline(BF_boundaries,'r-',BF_label_str)

ylim([0 BF_max])

subplot(1,4,3);

plot(c.thr*100,1./bf10.C_mean);

hline(BF_boundaries,'r-',BF_label_str)

ylim([0 BF_max])

subplot(1,4,4);

plot(c.thr*100,1./bf10.L);

hline(BF_boundaries,'r-',BF_label_str)

ylim([0 BF_max])


%bf01 = 1./bf10

%% Probability of superiority PS

TOI = .6; % Threshold of interest

% Index for TOI in structure c
TOI_ind = find(round(c.thr,4) == TOI);

inds = (1:2) + length(c.cond)*(TOI_ind-1);

% Modularity
PS_Q = sum( (c.all.Q(:,inds(2)) - c.all.Q(:,inds(1))) > 0 ) / length(c.all.Q(:,inds(2)))

PS_L = sum( (c.all.L(:,inds(2)) - c.all.L(:,inds(1))) > 0 ) / length(c.all.L(:,inds(2)))


%% Save beta files

beta_dir = [gppi_group_path '/conmat19'];

dlmwrite([beta_dir '/beta_miss_' num2str(TOI*100) '_mean.edge'],...
          d(TOI_ind).group.mat_mean{1,1},...
          'delimiter','\t',...
          'precision','%.4f');

dlmwrite([beta_dir '/beta_hit_' num2str(TOI*100) '_mean.edge'],...
          d(TOI_ind).group.mat_mean{1,2},...
          'delimiter','\t',...
          'precision','%.4f');
      
dlmwrite([beta_dir '/beta_CR_' num2str(TOI*100) '_mean.edge'],...
          d(TOI_ind).group.mat_mean{1,3},...
          'delimiter','\t',...
          'precision','%.4f');
      
%% Save beta files with proportional threshold

beta_dir = [gppi_group_path '/conmat19'];

thr = 0.60;

dlmwrite([beta_dir '/beta_miss_' num2str(TOI*100) '_mean_t' num2str(thr*100) '.edge'],...
          threshold_proportional(d(TOI_ind).group.mat_mean{1,1},thr),...
          'delimiter','\t',...
          'precision','%.4f');

dlmwrite([beta_dir '/beta_hit_' num2str(TOI*100) '_mean_t' num2str(thr*100) '.edge'],...
          threshold_proportional(d(TOI_ind).group.mat_mean{1,2},thr),...
          'delimiter','\t',...
          'precision','%.4f');
      
dlmwrite([beta_dir '/beta_CR_' num2str(TOI*100) '_mean_t' num2str(thr*100) '.edge'],...
          threshold_proportional(d(TOI_ind).group.mat_mean{1,3},thr),...
          'delimiter','\t',...
          'precision','%.4f');
