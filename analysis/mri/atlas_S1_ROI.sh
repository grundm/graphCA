#!/bin/bash
# atlas_S1_ROI.sh

# Get Area 1, 2, 3a & 3b from Eickhoff-Zilles MPM atlas (CA_MPM_22_MNI)
# [Maximum probability map from cytoarchitectonic probabilistic atlas]

# BA 3a, BA 3b, BA 1 BA 2----------------------------------------- Geyer et al., NeuroImage, 1999, 2000
#                                                                  Grefkes et al., NeuroImage 2001

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

#atlas=/a/sw/afni/19.1.05/ubuntu-bionic-amd64/MNIa_caez_mpm_22+tlrc

atlas_name=CA_MPM_22_MNI

atlas_name=MNI_Glasser_HCP_v1.0

# whereami -omask MNI_Glasser_HCP_v1.0:right:R_Area_1

#Intersection of ROI (valued 1) with atlas CA_MPM_22_MNI (sb0):
#   25.2 % overlap with Area_1, code 106
#   12.7 % overlap with Area_4a, code 160
#   4.6  % overlap with Area_OP4_(PV), code 173
#   1.9  % overlap with Area_3b, code 187
#   0.1  % overlap with Area_5L_(SPL), code 159
#   0.0  % overlap with Area_2, code 243
#   -----
#   44.5 % of cluster accounted for.


hemi=right

atlas_area=(Area_1 \
			Area_2 \
			Area_3a \
			Area_3b)

# Glasser "R_Area_3b" does not exist and results in R_Area_V3B in occipital cortex
# Area 3b is "R_Primary_Sensory_Cortex"

atlas_area=(R_Primary_Sensory_Cortex \
			R_Area_1 \
			R_Area_2 \
			R_Area_3a)

T1_epi_space_sample=/data/pt_nro150/mri/ID01/T1_2018/banat_norm_epi.nii


# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

atlas_dir=/data/pt_nro150/mri/atlas/Glasser_S1


# ================================================================================
# CREATE ROIs
# --------------------------------------------------------------------------------

mkdir $atlas_dir

for ROI in ${atlas_area[@]}; do

	# Create ROI nifti
	whereami -mask_atlas_region $atlas_name:$hemi:$ROI \
			 -prefix $atlas_dir/$ROI.nii.gz

	# Sample down to EPI space
	3dresample -dxyz 3 3 3.51 \
			   -master $T1_epi_space_sample \
			   -inset $atlas_dir/$ROI.nii.gz \
			   -prefix $atlas_dir/${ROI}_epi.nii.gz


done
