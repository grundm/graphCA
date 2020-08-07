function WD = module_degree_bu(A,Ci)
%MODULE_DEGREE       Within-module degree - binary undirected network
%
%   Z = module_degree_bu(A,Ci);
%
%   The within-module degree is a within-module version of degree
%   centrality, adapted by Sadaghiani et al. (2015) for binary 
%   undirected networks without z-transformation.
%
%   Inputs:     A,      binary undirected connection matrix
%               Ci,     community affiliation vector
%
%   Output:     WD,     within-module degree.
%
%   Reference:  Guimera R, Amaral L. Nature (2005) 433:895-900.
%
%
%   Author:           Martin Grund (mgrund@cbs.mpg.de)
%   Last Update:      July 22, 2020


n = length(A);                            % number of vertices

WD = zeros(n,1);

for i = 1:max(Ci)
    k_mi = sum(A(Ci == i, Ci == i),2);    % number of edges between node i and all other nodes in module mi
    n_mi = sum(Ci == i);                  % number of nodes in module mi
    WD(Ci == i) = k_mi / n_mi;
end

WD(isnan(WD)) = 0;
