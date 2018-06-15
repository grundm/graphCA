%% Input directories

mri_path = '/data/pt_nro150/mri';
gppi_group_path = [mri_path '/group/gppi_NOI_NEW/glm_FSL'];

% Get connectivity data
load([gppi_group_path '/conmat.mat']);

% Get information about network of interest regions (NOI ROI)
NOI = readtable([mri_path '/atlas/stim_conf_NEW12_coords_extended.1D'],'FileType','text');


%% Output files

mat_filtered = [gppi_group_path '/conmat19.mat'];

node_atlas = [mri_path '/atlas/stim_conf_NEW12_coords_conmat19.node'];

%% Settings
% ROI selection

% 'lPCUN1'  1
% 'lIPL1'   2
% 'lSOG'    3
% 'rSPL'    4
% 'lPCC'    5
% 'rIOG'    6
% 'lINS1'   7
% 'cS2a'    8
% 'lACC'    9
% 'iS2a'    10
% 'rMTG'    11
% 'lIPL2'   
% 'cS1'     13
% 'rCUN'    14
% 'rMFG'    15
% 'rIFG'    16
% 'rCERB'   17
% 'lPALL'   18
% 'lPCUN2'
% 'iS2b'
% 'rINS'    21
% 'cS2b'
% 'rSFG'    23
% 'lINS2'
% 'lIPL3'

%ROI_ind = [1:11, 13:18, 21, 23];

% Define selection and order with labels
ROIs = {'cS1'; 'cS2a'; 'iS2a';...
        'rCERB'; 'rIOG'; 'rMTG';...
        'lPCUN1'; 'lPCC'; 'lIPL1'; 'rCUN'; 'rSPL';...        
        'rINS'; 'lINS1'; 'lPALL';...
        'lACC'; 'rIFG'; 'rMFG'; 'rSFG'; 'lSOG';};

% Create indices based on label array "ROIs"
ROI_ind = zeros(1,length(ROIs));
    
for k = 1:length(ROIs)
    
    ROI_ind(k) = find(strcmp(NOI.ROI_name, ROIs(k)));
end

%% Create node file for BrainNet Viewer

f = fopen(node_atlas,'w');

radius = 4;

for i = 1:length(ROI_ind)

    fprintf(f,'%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%s\n',NOI.x(ROI_ind(i)),NOI.y(ROI_ind(i)),NOI.z(ROI_ind(i)),i,radius,NOI.ROI_name{ROI_ind(i)});
  
end

fclose(f);

%% Filter 'mat' for nodes of interest

mat_new = mat;

for i = 1:length(mat)
   
    for j = 1:length(mat(i).beta_mat)
                
        mat_new(i).beta_mat{1,j} = mat(i).beta_mat{1,j}(ROI_ind,ROI_ind);
    end
    
    for j = 1:length(mat(i).beta_files)
                
        mat_new(i).beta_files{1,j} = mat(i).beta_files{1,j}(ROI_ind);
    end
    
end

mat = mat_new;

save(mat_filtered, 'mat', 'ROI_ind');