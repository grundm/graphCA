#!/bin/bash
# beta_mat.sh $ID

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES
mri_path=/data/pt_nro150/mri

gppi_path=$mri_path/ID$ID/gppi/gppi_power_all_cond2 # EDIT #

### ATLAS
ROI_r=4
atlas=$mri_path/atlas/power_2011_MNI_r${ROI_r}_epi.nii.gz # EDIT #
#atlas=$mri_path/atlas/stim_conf_NEW12_extended_r${ROI_r}_epi.nii.gz

### ROI GLMs

GLMs_dirname=glm_FSL # EDIT #

ROI_GLMs=($gppi_path/$GLMs_dirname/ROI*/*_REML.nii.gz)

#beta_labels=(CR_conf_I near_miss_conf_I near_hit_conf_I supra_hit_conf_I ROI) # EDIT #
beta_labels=(CR_I near_miss_I near_hit_I supra_hit_I ROI) # EDIT #

beta_label_suffix=#0_Coef

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

output_dir=$gppi_path/$GLMs_dirname

output_file_suffix=beta_mean_mat.1D

# ================================================================================
# BETA MATRIXES
# --------------------------------------------------------------------------------

if [ -d "$gppi_path" ]; then

	for beta_label in ${beta_labels[@]}; do

		ROI_GLM_files=(${ROI_GLMs[@]/%/[$beta_label$beta_label_suffix]})

		3dROIstats -mask $atlas ${ROI_GLM_files[@]} > $output_dir/${ID}_${beta_label}_${output_file_suffix}
	
	done

fi
