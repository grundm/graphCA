function mp = prep_mat(m,thr)
% mp = prep_mat(m,thr) creates thresholded symmetric connectivity matrix 
% for Brain Connectivity Toolbox from interaction regressor beta weights by
% ignoring directionality, averaging reciprocal connections, thresholding
% and normalizing all values by maximum.
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 21, 2017

%%
% Remove directionality
mp = abs(m);

% Average reciprocal connection
mp = (mp + triu(mp,0)' + tril(mp,0)') * 0.5;

% Threshold matrix (takes all networks - binary/wighted un-/directed)
% Zeros diagonal (initial idea from http://stackoverflow.com/questions/3963565/how-to-assign-values-on-the-diagonal: mp(logical(eye(size(mp)))) = 0;)
mp = threshold_proportional(mp, thr);

% Rescale thresholded matrix to [0, 1]
% Godwin et al. (2015) did so, because ...
mp = mp / max(max(mp));