function metric_rnd = rnd_graph(net, rnd_iter, rewire_iter)
% metric_rnd = rnd_graph(m, rnd_iter, rewire_iter) creates "rnd_iter"
% random networks based on the degree distribution in network "m". Each
% network is rewired "rewire_iter" times. The function returns the graph
% metrics modularity, community index, participation coefficient, 
% clustering, and characteristic path length of each random network and 
% their average in a structure.
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      February 14, 2017

    metric_rnd.rnd_iter = rnd_iter;
    metric_rnd.rewire_iter = rewire_iter;

    % Random network
    % Godwin et al. (2015) created 100 networks or did they rewire them 100 times?
    % did it 100 times and averaged value

    for j = 1:rnd_iter

        % Create random network
        [net_rnd, metric_rnd.rewire_iter_eff(j,1)] = randmio_und(net, rewire_iter);

        % Modularity
        [Ci_rnd, metric_rnd.Q(j,1)] = modularity_und(net_rnd);

        % Number of communities
        metric_rnd.Ci_max(j,1) = max(Ci_rnd);

        % Participation coefficient
        metric_rnd.P(j,:) = participation_coef(net_rnd, Ci_rnd);
        
        metric_rnd.P_mean(j,1) = mean(metric_rnd.P(j,:));
        metric_rnd.P_std(j,1) = std(metric_rnd.P(j,:));
        
        % Clustering coefficient
        metric_rnd.C(j,:) = clustering_coef_wu(net_rnd);
        
        metric_rnd.C_mean(j,1) = mean(metric_rnd.C(j,:));
        metric_rnd.C_std(j,1) = std(metric_rnd.C(j,:));
        
        % Average path length (does not include infinite distances)
        metric_rnd.L(j,1) = charpath(distance_wei(net_rnd),0,0);
        
    end

    % Average all metrics
    metric_rnd.mean.Q = mean(metric_rnd.Q);
    
    metric_rnd.mean.Ci_max_range = [min(metric_rnd.Ci_max) max(metric_rnd.Ci_max)];
    metric_rnd.mean.Ci_max = mean(metric_rnd.Ci_max);
    
    metric_rnd.mean.P_mean = mean(metric_rnd.P_mean);
    
    metric_rnd.mean.C_mean = mean(metric_rnd.C_mean);
    
    metric_rnd.mean.L = mean(metric_rnd.L);