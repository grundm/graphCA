#!/bin/bash
# signal_course.sh $ID

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

glm_model=all_cond_conf2_TENT # EDIT #

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES
mri_path=/data/pt_nro150/mri

glm_path=$mri_path/ID$ID/glm/$glm_model

group_path=$mri_path/group

### GLM FILE
#glm_file=$glm_path/${ID}_glm_REML.nii.gz
glm_file=$glm_path/${ID}_glm_REML_betas.nii.gz # EDIT #

#coef_brick_wildcard="_Coef"
coef_brick_wildcard="#" # EDIT #

### CONDITION LABELS
cond_labels=(CR \
			 near_miss \
			 near_hit)

cond_labels=(CR_conf \
			 near_miss_conf \
			 near_miss_unconf \
			 near_hit_unconf \
			 near_hit_conf \
			 supra_hit_conf)

### ROI
sphere_r=4 # EDIT #

#atlas_coords=$mri_path/atlas/all_cond3_coords.1D # EDIT #
atlas_coords=$mri_path/atlas/all_cond_conf2_coords.1D

# all_cond3_coords.1D
ROIs=(lINS1 \
		lIPS1 \
		rPCUN \
		lNAC \
		lIFG \
		rINS \
		rIPS \
		lPCUN \
		cS2a \
		lIPS2 \
		cS2b \
		lINS2 \
		iS2 \
		lSMA)

# all_cond_conf2_coords.1D
ROIs=(PCUN \
	  lINS \
	  lIPS1 \
	  lNAC \
	  lIPS2 \
	  rACC \
	  lPu \
	  rPu)

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### DIRECTORIES
output_path=$glm_path/signal_course_r${sphere_r} # EDIT #

# ================================================================================
# CREATE SIGNAL TIME COURSE
# --------------------------------------------------------------------------------

# Check if GLM exists
if [ -d "$glm_path" ]; then

	mkdir $output_path

	# Create array with GLM labels
	IFS='|' read -ra glm_labels <<< $(3dinfo -label $glm_file)

	# Loop ROIs
	for ROI_name in ${ROIs[@]}; do

		ROI_coords=($(grep $ROI_name $atlas_coords))

		echo $ROI_name ${ROI_coords[0]} ${ROI_coords[1]} ${ROI_coords[2]}

		# Loop conditions
		for cond_label in ${cond_labels[@]}; do

			# Create brick label array for current condition
			# Loops array with GLM labels and filters for current condition label and beta coefficient brick
			coef_labels=($(for i in ${glm_labels[@]}; do echo $i | grep $cond_label | grep -v \\- | grep $coef_brick_wildcard; done))

			echo ${coef_labels[@]}

			# Loop coefficients (TENT functions)
			for j in ${!coef_labels[@]}; do
						   
				betas[$j]=$(3dmaskave -nball ${ROI_coords[0]} ${ROI_coords[1]} ${ROI_coords[2]} $sphere_r \
						 	 		  -q \
						  			  $glm_file[${coef_labels[j]}])

			done

			# Write out betas
			signal_course_file=$output_path/${ROI_name}_${cond_label}.1D

			echo ${betas[@]} > $signal_course_file

		done # Condition - loop

	done # ROI - loop
		  
fi
