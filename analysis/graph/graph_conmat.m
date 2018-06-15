function mat_prep = graph_conmat(mat_prep, rnd_iter, rewire_iter)
% mat_prep = graph_conmat(mat_prep, rnd_iter, rewire_iter) expands participants' 
% connectivity structure with graph metrics (modularity, community index, 
% participation coefficient, clustering, and characteristic path length) 
% and normalizes them based on the mean metrics in "rnd_iter" random 
% networks that have the same degree distribution (see rnd_graph.m).
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 20, 2017

%%

% Loop conditions
for k = 1:length(mat_prep(1).cond)

    % Loop participants in parallel
    parfor i = 1:length(mat_prep)

        disp(['graph_conmat.m - ID' mat_prep(i).ID ' (thr = ' num2str(mat_prep(i).thr) ') - ' mat_prep(i).cond{1,k}])

        metric_tmp(i) = analyze_graph(mat_prep(i).mat{1,k}, rnd_iter, rewire_iter);

    end
    
    for i = 1:length(mat_prep)
    
        mat_prep(i).metric{1,k} = metric_tmp(i);
        
    end
    
end