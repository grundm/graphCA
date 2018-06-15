#!/bin/bash
# monte_carlo.sh $glm_models

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

### MONTE CARLOE SETTINGS (3dClustSim)

# 100k interations: 5.5-8 h (20-30k seconds)
# [default = 10000]
iterations=10000

# Uncorrected (per voxel) p-values
# [default = 0.05 0.02 0.01 0.005 0.002 0.001 0.0005 0.0002 0.0001]
pu=(0.05 0.02 0.01 0.005 0.002 0.001 0.0005 0.0002 0.0001)
#pu=(0.005 0.001 0.0005 0.0001 0.00005 0.00001)

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
glm_models=${1}

### DIRECTORIES

mri_path=/data/pt_nro150/mri

group_path=$mri_path/group

glm_dirname=gppi #/gppi_cS1_NEW12/glm_FSL # EDIT #
#glm_dirname=glm

### ERROR SMOOTHNESS FILES

err_smooth_file=acf/acf_out_REML.1D

### GROUP MASK

group_mask_filename=banat_norm_epi_groupmask.nii.gz

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

acf_values=acf_REML.1D

err_mean_out=acf_REML_mean.1D

out_dirname=carlo

clust_sim_prefix=clustSim

# ================================================================================
# SIMULATION
# --------------------------------------------------------------------------------

# Loop GLMs
for glm_model in ${glm_models[@]}; do

	printf "\nCLUSTER SIMULATION: GLM - %s \n\n" "$glm_model"

	# Group mask
	group_mask=$group_path/$glm_model/$group_mask_filename

	# Output directory
	out_dir=$group_path/$glm_model/$out_dirname

	mkdir -p $out_dir

	# Concatenate all acf values
	# FWHM_x FWHM_y FHWM_z FWHM_combined
	# a,b,c parameters, plus the combined estimated FWHM
	cat $mri_path/ID*/$glm_dirname/$glm_model/$err_smooth_file | cut -d' ' -f5-7 > $out_dir/$acf_values

	# Average acf values	
	for ((i=1; i<=3; i++)); do 
		acf_mean[(($i -1))]=$(awk -v N=$i '{ sum += $N } END { if (NR > 0) print sum / NR }' $out_dir/$acf_values); 
	done

	echo ${acf_mean[@]} > $out_dir/$err_mean_out	

	# Simulate cluster sizes
	3dClustSim -mask $group_mask \
			   -acf $(cat $out_dir/$err_mean_out) \
			   -iter $iterations \
			   -pthr ${pu[@]} \
			   -prefix $out_dir/$clust_sim_prefix

done
