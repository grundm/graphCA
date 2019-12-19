function mat = load_conmat
% mat = load_conmat loads the averaged regression weights for each ROI's
% the specified interaction regressor (e.g., hit or miss) in all other ROIs
% for all participants.
%
% Author:           Martin Grund (mgrund@cbs.mpg.de)
% Last Update:      September 24, 2019

%% SETTINGS

% Input
mri_path = '/data/pt_nro150/mri';
ID_wildcard = '/ID*';

gppi_glm_dir = '/gppi/gppi_power_all_cond2/glm_FSL';
 
cond_file_suffix = {'_CR_I_beta_mean_mat.1D',...
                    '_near_miss_I_beta_mean_mat.1D',...
                    '_near_hit_I_beta_mean_mat.1D',...                    
                    '_supra_hit_I_beta_mean_mat.1D',...
                    '_ROI_beta_mean_mat.1D'};
                
% cond_file_suffix = {'_CR_conf_I_beta_mean_mat.1D',...
%                     '_near_miss_conf_I_beta_mean_mat.1D',...
%                     '_near_hit_conf_I_beta_mean_mat.1D',...                    
%                     '_supra_hit_conf_I_beta_mean_mat.1D',...
%                     '_ROI_beta_mean_mat.1D'};                
                
cond = {'CR',...
        'near_miss',...
        'near_hit',...
        'supra_hit',...
        'ROI'};

% cond = {'CR_conf',...
%         'near_miss_conf',...
%         'near_hit_conf',...
%         'supra_hit_conf',...
%         'ROI'};

j = 0;

%% LOAD gPPI BETA FILES

ID_dir = dir([mri_path, ID_wildcard]);

% Loop all ID*/ directories in mri_path
for i = 1:length(ID_dir)
    
    gppi_path = [mri_path '/' ID_dir(i).name gppi_glm_dir];
    
    % Check if gPPI directory for ID exists    
    if exist(gppi_path,'dir') == 7
        
        j = j + 1;
        
        mat(j).ID = strrep(ID_dir(i).name,'ID','');
        
        mat(j).cond = cond;

        for k = 1:length(cond)
            
            % Read
            beta_mat = readtable([gppi_path '/' mat(j).ID cond_file_suffix{k}],'FileType','text');

            % Transform to array
            mat(j).beta_mat{1,k} = table2array(beta_mat(:,3:end));

            % Save file names
            mat(j).beta_files{1,k} = beta_mat.File;

        end
    end
end
