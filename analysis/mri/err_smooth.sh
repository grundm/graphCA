#!/bin/bash
# err_smooth.sh $ID

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

glm_models=(ROI_001)
#glm_models=(stim_conf_NEW12)

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES

mri_path=/data/pt_nro150/mri

anat_path=$mri_path/ID$ID/T1

#glm_path=$mri_path/ID$ID/glm # EDIT #
glm_path=$mri_path/ID$ID/gppi/gppi_cS1_NEW12/glm_FSL # EDIT #

### BRAIN MASK

epi_brain_mask=$anat_path/MNI_bmask_epi_d.nii.gz

### RESIDUALS

glm_errts=*gppi_errts_REML.nii.gz # EDIT #
#glm_errts=*glm_errts_REML.nii.gz

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

out_path=$glm_path

out_dirname=acf

out_filename=acf_out_REML.1D

# ================================================================================
# COMPUTE ERROR SMOOTHNESS
# --------------------------------------------------------------------------------

for glm_model in ${glm_models[@]}; do

	glm=$glm_path/$glm_model

	# Check if GLM exists
	if [ -d $glm ]; then

		printf "\nRUN SPATIAL SMOOTHNESS: ID%s %s\n\n" "$ID" "$glm_model"

		out_dir=$out_path/$glm_model/$out_dirname
		mkdir -p $out_dir

		# Spatial error smoothness
		acf_out=$(3dFWHMx -dset $glm/$glm_errts -mask $epi_brain_mask -acf $out_dir/3dFWHMx)

		echo $acf_out > $out_dir/$out_filename

		# Do this for all participants (http://blog.cogneurostats.com/?p=196) and average results

	fi

done
