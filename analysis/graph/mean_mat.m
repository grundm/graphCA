function group_mat = mean_mat(mat_prep)
% group_mat = mean_mat(mat_prep) averages the participant's connectivity 
% matrices for each condition
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 21, 2017

%% Group average - connectivity matrices

% Loop conditions
for k = 1:length(mat_prep(1).cond)

    % Take first participant's matrix
    group_mat{1,k} = mat_prep(1).mat{1,k};
    
    % Add all other participant's matrices
    for i = 2:length(mat_prep)
        group_mat{1,k} = group_mat{1,k} + mat_prep(i).mat{1,k};
    end

    % Devide by number of participants
    group_mat{1,k} = group_mat{1,k}./length(mat_prep);
    
end