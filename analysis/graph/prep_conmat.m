function mat_prep = prep_conmat(mat, thr)
% mat_prep = prep_conmat(mat, thr) prepares each participant's connectivity
% matrix (from load_conmat) for graph metrics. It keeps only the strongest
% connections as specified proporionally with "thr" (e.g., 0.1 -> 10 %
% strongest connections)
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 21, 2017

%% 
% Loop participants
for i = 1:length(mat)

    mat_prep(i).thr = thr;
    mat_prep(i).ID = mat(i).ID;
    mat_prep(i).cond = mat(i).cond;
    
    % Loop conditions
    for k = 1:length(mat_prep(i).cond)
        
        mat_prep(i).mat{1,k} = prep_mat(mat(i).beta_mat{1,k}, thr);
    end
    
end
