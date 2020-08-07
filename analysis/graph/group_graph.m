function gGraph = group_graph(mat_prep)
% gGraph = group_graph(mat_prep) combines graph metrics by analyze_graph.m
% across participants and test conditions against each other

% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      July 23, 2020

%% Combine graph metrics across conditions and participants
% 1 vector per graph metric and condition for all participants

% Loop participants
for i = 1:length(mat_prep)
        
    % Loop conditions
    for k = 1:length(mat_prep(1).cond)

        gGraph.all.Ci_max(i,k) = mat_prep(i).metric{1,k}.Ci_max;
        gGraph.all.Ci_max_rnd(i,k) = mat_prep(i).metric{1,k}.rnd.mean.Ci_max;

        gGraph.all.Q(i,k) = mat_prep(i).metric{1,k}.norm.Q;
        gGraph.all.P_mean(i,k) = mat_prep(i).metric{1,k}.norm.P_mean;
        gGraph.all.C_mean(i,k) = mat_prep(i).metric{1,k}.norm.C_mean;
        gGraph.all.L(i,k) = mat_prep(i).metric{1,k}.norm.L;
        
        gGraph.all.BC_norm_mean(i,k) = mat_prep(i).metric{1,k}.norm.BC_norm_mean;
        gGraph.all.WD_mean(i,k) = mat_prep(i).metric{1,k}.norm.WD_mean;
        
        % Participation and clustering coefficient for each node
        gGraph.all.P{k}(:,i) = mat_prep(i).metric{1,k}.P;
        gGraph.all.C{k}(:,i) = mat_prep(i).metric{1,k}.C;
        
        % Between centrality and within-module degree for each node
        gGraph.all.BC_norm{k}(:,i) = mat_prep(i).metric{1,k}.BC_norm;
        gGraph.all.WD{k}(:,i) = mat_prep(i).metric{1,k}.WD;
    end

end

%% Group average - graph metrics

gGraph.Ci_max = mean(gGraph.all.Ci_max, 1);
gGraph.Ci_max_rnd = mean(gGraph.all.Ci_max_rnd, 1);

gGraph.Q = mean(gGraph.all.Q, 1);
gGraph.P_mean = mean(gGraph.all.P_mean, 1);
gGraph.C_mean = mean(gGraph.all.C_mean, 1);
gGraph.L = mean(gGraph.all.L, 1);

gGraph.BC_norm_mean = mean(gGraph.all.BC_norm_mean, 1);
gGraph.WD_mean = mean(gGraph.all.WD_mean, 1);

%% Wilcoxon signed rank test

% Loop conditions
for k1 = 1:length(mat_prep(1).cond)

    for k2 = 1:length(mat_prep(1).cond)

        if k1 ~= k2
            gGraph.signrank.Ci_max(k1,k2) = signrank(gGraph.all.Ci_max(:,k1), gGraph.all.Ci_max(:,k1));
            gGraph.signrank.Ci_max_rnd(k1,k2) = signrank(gGraph.all.Ci_max_rnd(:,k1), gGraph.all.Ci_max_rnd(:,k2));

            gGraph.signrank.Q(k1,k2) = signrank(gGraph.all.Q(:,k1), gGraph.all.Q(:,k2));
            gGraph.signrank.P_mean(k1,k2) = signrank(gGraph.all.P_mean(:,k1), gGraph.all.P_mean(:,k2));
            gGraph.signrank.C_mean(k1,k2) = signrank(gGraph.all.C_mean(:,k1), gGraph.all.C_mean(:,k2));
            gGraph.signrank.L(k1,k2) = signrank(gGraph.all.L(:,k1), gGraph.all.L(:,k2));
            
            gGraph.signrank.BC_norm_mean(k1,k2) = signrank(gGraph.all.BC_norm_mean(:,k1), gGraph.all.BC_norm_mean(:,k2));
            gGraph.signrank.WD_mean(k1,k2) = signrank(gGraph.all.WD_mean(:,k1), gGraph.all.WD_mean(:,k2));
        end
    end
end
