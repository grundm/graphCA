function c = cmp_cond(d,cond_ind,CI_width,wo_BC_WD)
% c = cmp_cond(d,CI_width) combines the group statistics (see groupstats.m) 
% for the conditions defined with "cond_ind" (column index, since the 
% structure is thresholds across rows and conditions across columns) and 
% calculates the within-group standard error of mean and confidence 
% intervalls for the width defined in "CI_width" (e.g., 0.95 for 95%).

% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      July 30, 2020

%% Combine group data of each condition

% Thresholds
c.thr = [d.thr]';
% Conditions
c.cond = d(1).mat_prep(1).cond(cond_ind);
cond_num = length(c.cond);

for i = 1:length(d)
    
    % Group statistics
    %   Rows    = Thresholds
    %   Columns = Conditions
    c.Q(i,:) = d(i).group.gGraph.Q(cond_ind);
    c.P_mean(i,:) = d(i).group.gGraph.P_mean(cond_ind);
    c.C_mean(i,:) = d(i).group.gGraph.C_mean(cond_ind);
    c.L(i,:) = d(i).group.gGraph.L(cond_ind);
    
    c.Ci_max(i,:) = d(i).group.gGraph.Ci_max(cond_ind);
    c.Ci_max_rnd(i,:) = d(i).group.gGraph.Ci_max_rnd(cond_ind);
    
    if wo_BC_WD == 0
        c.BC_norm_mean(i,:) = d(i).group.gGraph.BC_norm_mean(cond_ind);
        c.WD_mean(i,:) = d(i).group.gGraph.WD_mean(cond_ind);
    end
    
    c.signrank(:,i) = d(i).group.gGraph.signrank;
    
    % Participant data
    %   Rows    = Participants
    %   Columns = Conditions grouped by thresholds
    %   -> Thr01_CondA, Thr01_CondB , ..., Thr02_CondA
    %   (Optimal structure for within-group confidence intervals)
    % E.g. "d(i).group.gGraph.all.Q" = Particpants x conditions
        
    % Group participant's data for each threshold across conditions        

    % Get column indices of all conditions for 1 threshold (thr_ind)
    % by shifting 1:cond_num by threshold counter
    thr_ind = (1:cond_num) + cond_num*(i-1);

    c.all.Q(:,thr_ind) = d(i).group.gGraph.all.Q(:,cond_ind);
    c.all.P_mean(:,thr_ind) = d(i).group.gGraph.all.P_mean(:,cond_ind);
    c.all.C_mean(:,thr_ind) = d(i).group.gGraph.all.C_mean(:,cond_ind);
    c.all.L(:,thr_ind) = d(i).group.gGraph.all.L(:,cond_ind);
    
    if wo_BC_WD == 0
        c.all.BC_norm_mean(:,thr_ind) = d(i).group.gGraph.all.BC_norm_mean(:,cond_ind);
        c.all.WD_mean(:,thr_ind) = d(i).group.gGraph.all.WD_mean(:,cond_ind);
    end
end

% Small-worldness (true if S >> 1)
c.S = c.C_mean./c.L;

%% Within-group CI (across conditions and thresholds)
[c.SEM.Q, c.CI.Q] = SEM_CI(c.all.Q, CI_width, cond_num);
[c.SEM.P_mean, c.CI.P_mean] = SEM_CI(c.all.P_mean, CI_width, cond_num);
[c.SEM.C_mean, c.CI.C_mean] = SEM_CI(c.all.C_mean, CI_width, cond_num);
[c.SEM.L, c.CI.L] = SEM_CI(c.all.L, CI_width, cond_num);

if wo_BC_WD == 0
    [c.SEM.BC_norm_mean, c.CI.BC_norm_mean] = SEM_CI(c.all.BC_norm_mean, CI_width, cond_num);
    [c.SEM.WD_mean, c.CI.WD_mean] = SEM_CI(c.all.WD_mean, CI_width, cond_num);
end

function [SEM, CI] = SEM_CI(metric_mat, CI_w, cond_num)

    % Within-group SEM: Participant's value - mean(participant) + mean(mean(participant))
    SEM_tmp = std(bsxfun(@minus, metric_mat, mean(metric_mat, 2)) - mean2(metric_mat)) / sqrt(size(metric_mat, 2));
    CI_tmp = SEM_tmp * norminv(1 - 0.5*(1-CI_w));
    
    thr_num = length(SEM_tmp)/cond_num;
    
%     % Correction factor from Morey (2008)
%     % Adapted from http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/#helper-functions
%     n_within_groups = cond_num * thr_num;
%     
%     corr_factor = sqrt( n_within_groups / (n_within_groups - 1) );
    
    % Restructure output
    %   Rows    = Thresholds
    %   Columns = Conditions
    
    for k = 1:thr_num
        thr_ind = (1:cond_num) + cond_num*(k-1);
        SEM(k,1,:) = SEM_tmp(thr_ind);
        CI(k,1,:) = CI_tmp(thr_ind);
    end
