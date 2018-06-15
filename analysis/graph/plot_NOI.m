%% Input directories

mri_path = '/data/pt_nro150/mri';
gppi_group_path = [mri_path '/group/gppi_NOI_NEW/glm_FSL'];

%% Get ROI labels

node_atlas = [mri_path '/atlas/stim_conf_NEW12_coords_conmat19.node'];

NOI = readtable(node_atlas,'FileType','text');

labels = NOI.Var6;

%% Get NOI data

load([gppi_group_path '/graph_metrics_conmat19_r1_1.mat'])

% load([gppi_group_path '/graph_metrics_conmat19_r100_20-95.mat'])

%% Evaluate range

hit_miss_min_max = [min(min(d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,1})), max(max(d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,1}))];
hit_CR_min_max = [min(min(d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,3})), max(max(d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,3}))];
miss_CR_min_max = [min(min(d(1).group.mat_mean{1,1}-d(1).group.mat_mean{1,3})), max(max(d(1).group.mat_mean{1,1}-d(1).group.mat_mean{1,3}))];

min_max = [min([hit_miss_min_max(1); hit_CR_min_max(1); miss_CR_min_max(1)]) max([hit_miss_min_max(2); hit_CR_min_max(2); miss_CR_min_max(2)])]
% -> clims = [-0.2, 0.2]; for conmat19 100%

%% Plot connectivity matrix

% clims = [-0.45, 0.45];

clims = [-0.2, 0.2];
% clims = [-1, 1];

% Actual beta contrast
beta_diff = d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,3};
% beta_diff = d(1).group.mat_mean{1,2};
% beta_diff = threshold_proportional(beta_diff, .50);

%pvalues = d(1).group.mat_test.signrank{1,1}{1,2}; % 1st vs. 2nd condition
pvalues = d(1).group.mat_test.ttest{1,2}{1,3}; % 1st vs. 2nd condition
pvalues = pvalues.*double(pvalues < .05);

% beta_diff(beta_diff == 0) = nan;
pvalues(pvalues == 0) = nan;

% Plot beta values
fig = imagesc(beta_diff,clims);

alpha_val = ones(size(beta_diff));
alpha_val(isnan(pvalues)) = 0.1; % below significance threshold
alpha_val(eye(size(alpha_val))==1) = .7; % diagonal
alpha_val(eye(size(alpha_val))==1) = .0; % diagonal

alpha(fig,alpha_val);

colorbar
% colorbar('Direction','reverse')
axis ij

ax = gca;

ax.XAxisLocation = 'top';

set(ax,'XTick', (1:length(labels))+.3);
         
set(ax,'XTickLabel',labels)

set(ax,'XTickLabelRotation',55)

set(ax,'YTick', 1:length(labels));
         
set(ax,'YTickLabel',labels)

%%

%% Save mean "betas" contrast for p-threshold

beta_dir = [gppi_group_path '/conmat19'];

p_thr = 0.05;

dlmwrite([beta_dir '/beta_hit-miss_mean_p0' num2str(p_thr*100) '.edge'],...
          (d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,1}).*double(d(1).group.mat_test.ttest{1,1}{1,2} < p_thr),...
          'delimiter','\t',...
          'precision','%.4f');

dlmwrite([beta_dir '/beta_hit-CR_mean_p0' num2str(p_thr*100) '.edge'],...
          (d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,3}).*double(d(1).group.mat_test.ttest{1,2}{1,3} < p_thr),...
          'delimiter','\t',...
          'precision','%.4f');
      
dlmwrite([beta_dir '/beta_miss-CR_mean_p0' num2str(p_thr*100) '.edge'],...
          (d(1).group.mat_mean{1,1}-d(1).group.mat_mean{1,3}).*double(d(1).group.mat_test.ttest{1,1}{1,3} < p_thr),...
          'delimiter','\t',...
          'precision','%.4f');

%% Save mean "betas" contrast

beta_dir = [gppi_group_path '/conmat19'];

dlmwrite([beta_dir '/beta_hit-miss_mean.edge'],...
          (d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,1}),...
          'delimiter','\t',...
          'precision','%.4f');

dlmwrite([beta_dir '/beta_hit-CR_mean.edge'],...
          (d(1).group.mat_mean{1,2}-d(1).group.mat_mean{1,3}),...
          'delimiter','\t',...
          'precision','%.4f');
      
dlmwrite([beta_dir '/beta_miss-CR_mean.edge'],...
          (d(1).group.mat_mean{1,1}-d(1).group.mat_mean{1,3}),...
          'delimiter','\t',...
          'precision','%.4f');
            