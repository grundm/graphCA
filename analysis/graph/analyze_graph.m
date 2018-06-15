function metric = analyze_graph(net, rnd_iter, rewire_iter)
% metric = analyze_graph(net, rnd_iter, rewire_iter) computes graph
% metrics (modularity, community index, participation coefficient, 
% clustering, and characteristic path length) and normalizes them based on 
% the mean metrics in "rnd_iter" random networks that have the same degree 
% distribution (see rnd_graph.m).
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 20, 2017

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

% Normalize    
metric.norm.Q = metric.Q / metric.rnd.mean.Q;
metric.norm.P_mean = metric.P_mean / metric.rnd.mean.P_mean;
metric.norm.C_mean = metric.C_mean / metric.rnd.mean.C_mean;
metric.norm.L = metric.L / metric.rnd.mean.L;