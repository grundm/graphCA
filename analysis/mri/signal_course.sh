#!/bin/bash
# signal_course.sh $ID

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

glm_model=stim_conf_TENT2 # EDIT #

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
glm_file=$glm_path/${ID}_glm_REML.nii.gz

coef_brick_wildcard=*_Coef

### CONDITION LABELS
cond_labels=(CR_conf \
			 near_miss_conf \
			 near_hit_conf)

### ROI
sphere_r=4 # EDIT #

atlas_coords=$mri_path/atlas/stim_conf_NEW12_coords.1D

ROIs=(cS1 \
	  cS2a \
	  lPCUN1 \
	  lIPL1 \
	  lIFG \
	  rSPL \
	  lPCC \
	  rIOG \
	  lINS1 \
	  lACC \
	  iS2 \
	  rMTG \
	  rIFG \
	  rMFG)

ROIs=(rINS \
	  cS1b \
	  raINS \
	  rpINS \
	  A4b \
	  A11 \
	  A4a \
	  A12)

ROIs=(lPCUN2)

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
			coef_labels=($(for i in ${glm_labels[@]}; do echo $i | grep $cond_label#* | grep -v \\- | grep *$coef_brick_wildcard; done))

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
