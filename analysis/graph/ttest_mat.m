function mt = ttest_mat(mat_prep)
% mt = ttest_mat(mat_prep) creates a cell matrix per condition in mat_prep
% that contains the connectivity values of all participants per 
% cell/condition. Each condition's cell is then tested against the
% corresponding cell in all other conditions with a t-test and Wilcoxon
% signrank test

% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      March 21, 2017

%% 
% Loop rows
for i = 1:size(mat_prep(1).mat{1,1},1)

    % Loop columns
    for j = 1:size(mat_prep(1).mat{1,1},2)

        % PREPARE CONNECTIVITY CELL MATRIX
        % for each condition with all participant's values in each cell
        
        % Loop participants
        for p = 1:length(mat_prep)

            % Loop conditions
            for k = 1:length(mat_prep(1).cond)

                mt.all{1,k}{i,j}(p) = mat_prep(p).mat{1,k}(i,j);
            end
            
        end
        
        % TEST THE CONDITIONS
                    
        % Loop conditions
        for k1 = 1:length(mat_prep(1).cond)

            for k2 = k1:length(mat_prep(1).cond)

                if k1 == k2
                    [~, mt.ttest{1,k1}{1,k2}(i,j)] = ttest(mt.all{1,k1}{i,j});
                    mt.signrank{1,k1}{1,k2}(i,j) = signrank(mt.all{1,k1}{i,j});                    
                else
                    [~, mt.ttest{1,k1}{1,k2}(i,j)] = ttest(mt.all{1,k1}{i,j}, mt.all{1,k2}{i,j});
                    mt.signrank{1,k1}{1,k2}(i,j) = signrank(mt.all{1,k1}{i,j}, mt.all{1,k2}{i,j});
                end
            end
        end
    end
end
