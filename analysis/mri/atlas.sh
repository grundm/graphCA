#!/bin/bash
# atlas.sh

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

ROI_r=4 # EDIT #

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### DIRECTORIES
mri_path=/data/pt_nro150/mri

atlas_path=$mri_path/atlas

### ATLAS
#atlas_coords_mni=$atlas_path/power_2011_coords_MNI.1D # EDIT #
atlas_coords_mni=$atlas_path/all_cond_coords.1D # EDIT #

group_mask=$mri_path/group/all_cond/banat_norm_epi_groupmask.nii.gz # Atlas master (MNI space in EPI resolution)


# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### ATLAS
#atlas=$atlas_path/power_2011_MNI_r${ROI_r}_epi.nii.gz # EDIT #
atlas=$atlas_path/all_cond_r${ROI_r}_epi.nii.gz # EDIT #

atlas_vol=$atlas_path/`basename $atlas .nii.gz`_vol.1D

# ================================================================================
# ATLAS
# --------------------------------------------------------------------------------

if [ ! -f $atlas ]; then

	# Draw ROIs
	3dUndump -xyz \
			 -srad $ROI_r \
			 -master $group_mask \
			 -prefix $atlas \
			 $atlas_coords_mni

	# Save ROIs' volume
	3dhistog $atlas > $atlas_vol

fi
