function d = parrun_graph(mat,thr,rnd_iter,rnd_rewire_i)
% d = parrun_graph(mat,thr,rnd_iter,rnd_rewire_i) runs graph analytical
% analysis for different thresholds (thr) and all participants in parallel.
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 3, 2017

num_cores = feature('NumCores');

pool = parpool(num_cores);

for i = 1:length(thr)
    
    d(i) = run_graph(mat,thr(i),rnd_iter,rnd_rewire_i);
end

delete(pool);

function d_tmp = run_graph(mat,thr,rnd_iter,rnd_rewire_i)

    d_tmp.thr = thr;

    d_tmp.mat_prep = prep_conmat(mat, d_tmp.thr);

    d_tmp.mat_prep = graph_conmat(d_tmp.mat_prep, rnd_iter, rnd_rewire_i);
    
    d_tmp.group = groupstats(d_tmp.mat_prep);