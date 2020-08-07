function metric = analyze_graph(net, rnd_iter, rewire_iter)
% metric = analyze_graph(net, rnd_iter, rewire_iter) computes graph
% metrics (modularity, community index, participation coefficient, 
% clustering, and characteristic path length) and normalizes them based on 
% the mean metrics in "rnd_iter" random networks that have the same degree 
% distribution (see rnd_graph.m).
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      July 22, 2020

%%
% Random network graph metrics
metric.rnd = rnd_graph(net, rnd_iter, rewire_iter);

% Input network

% Modularity
[metric.Ci, metric.Q] = modularity_und(net);

metric.Ci_max = max(metric.Ci);

% Participation coefficient
metric.P = participation_coef(net, metric.Ci);

metric.P_mean = mean(metric.P);
metric.P_std = std(metric.P);

% Clustering coefficient
metric.C = clustering_coef_wu(net);

metric.C_mean = mean(metric.C);
metric.C_std = std(metric.C);

% Average path length (does not include infinite distances)
metric.L = charpath(distance_wei(net),0,0);

% Betweeness centrality (input: connection-length matrix)
metric.BC = betweenness_wei(weight_conversion(net,'lengths'));

% Betweenness centrality may be normalised to the range [0,1] as
% BC/[(N-1)(N-2)], where N is the number of nodes in the network.
metric.BC_norm = metric.BC/((length(net)-1)*(length(net)-2));
metric.BC_norm_mean = mean(metric.BC_norm);

%% Within-module degree (adaptation by Sadaghiani et al., 2015)

metric.WD = module_degree_bu(weight_conversion(net,'binarize'),metric.Ci);

metric.WD_mean = mean(metric.WD);

%% Normalize    
metric.norm.Q = metric.Q / metric.rnd.mean.Q;
metric.norm.P_mean = metric.P_mean / metric.rnd.mean.P_mean;
metric.norm.C_mean = metric.C_mean / metric.rnd.mean.C_mean;
metric.norm.L = metric.L / metric.rnd.mean.L;
metric.norm.BC_norm_mean = metric.BC_norm_mean / metric.rnd.mean.BC_norm_mean;
metric.norm.WD_mean = metric.WD_mean / metric.rnd.mean.WD_mean;
