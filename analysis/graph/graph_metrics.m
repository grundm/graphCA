%% FUNCTIONS
cd('/data/pt_nro150/graphca/graph')

addpath(genpath('../assets/'));

%% LOAD ORIGINAL

mat = load_conmat;

%% LOAD
mri_path = '/data/pt_nro150/mri';

% Task-relevant network:
gppi_group_path = [mri_path '/group/gppi_NOI_NEW/glm_FSL'];
load([gppi_group_path '/conmat19.mat'])

% Whole-brain network:

% gppi_group_path = [mri_path '/group/gppi_power_r4/glm_FSL'];
% load([gppi_group_path '/conmat.mat'])

%% SAVE

mkdir(gppi_group_path);

save([gppi_group_path '/conmat.mat']', 'mat');

%% COMPUTE NORMALIZED GRAPH METRICS FOR MULTIPLE THRESHOLDS

mat_thr = 0.20:0.05:0.95;

% Whole-brain network:
% mat_thr = 0.10:0.10:0.9;

rnd_iter = 100;
rnd_rewire_i = 5;

d = parrun_graph(mat,mat_thr,rnd_iter,rnd_rewire_i);

save([gppi_group_path '/graph_metrics_conmat19_r100_20-95.mat'], 'd', '-v7.3');

%% COMPARE CONDITIONS

cond_ind = 1:3;
CI_width = 0.95;

c = cmp_cond(d, cond_ind, CI_width);

%% SAVE GRAPH ANALYTICAL RESULTS

load([gppi_group_path '/graph_metrics_conmat19_r100_20-95.mat'])

%% PLOT GRAPH METRICS

plot_metrics(c);

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
