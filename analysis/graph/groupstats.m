function group = groupstats(mat_prep)
% group = groupstats(mat_prep) averages connectivity matrices per 
% condition across participants; t-test and signrank test each edge across
% condition; and summarizes the graph metrics across participants for each 
% condition, and tests the conditions against each other.
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 24, 2017

%% Connectivity matrices - Average per condition across participants

group.mat_mean = mean_mat(mat_prep);

%% T-test & signrank tests per condition across participants
%  incl. cell matrix per condition with all participant's values per cell

group.mat_test = ttest_mat(mat_prep);

%% Combine graph metrics and signrank test conditions

group.gGraph = group_graph(mat_prep);