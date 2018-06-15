#!/bin/bash
# FS_afni_proc.sh $ID
#
# In accordance with "FREESURFER NOTE" in afni_proc.py (https://afni.nimh.nih.gov/pub/dist/doc/program_help/afni_proc.py.html)
#
# Author: Martin Grund <mgrund@cbs.mpg.de>

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

ID=${1}

ID_path=/nobackup/curie2/mgrund/GraphCA/mri/ID${ID}

anat=$ID_path/T1/anat.nii.gz

if [ "$ID" -eq "38" ]; then
	anat=$ID_path/T1/banat.nii.gz
fi
# Only MP2RAGE available for ID38,
# but recon-all worked with a skull-stripped image,
# despite they describe a more complex approach:
# https://surfer.nmr.mgh.harvard.edu/fswiki/UserContributions/FAQ#Q.Ihavealreadyskull-strippeddata.CanIsubmitittorecon-all.3F


# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

FS_path=$ID_path/FS

mkdir $FS_path

ventricle_mask=$FS_path/FT_vent.nii.gz
WM_mask=$FS_path/FT_WM.nii.gz
GM_mask=$FS_path/FT_GM.nii.gz

# ================================================================================
# RUN FREESURFER & CREATE MASKS
# --------------------------------------------------------------------------------

# Run (complete) FreeSurfer
recon-all -all \
		  -i $anat \
		  -sd $FS_path \
		  -subject $ID

# Import to AFNI, in NIFTI format
@SUMA_Make_Spec_FS -NIFTI \
				   -fspath $FS_path/$ID \
				   -sid $ID

gzip $FS_path/$ID/SUMA/*.nii

# Create ventricle and white matter masks
#
# ** warning: it would be good to convert these indices to labels
#             in case the output from FreeSurfer is changed

# fs_table.niml.lt:
# 4		Left-Lateral-Ventricle
# 43	Right-Lateral-Ventricle
3dcalc -a $FS_path/$ID/SUMA/aparc+aseg.nii.gz \
	   -datum byte \
       -expr 'amongst(a,4,43)' \
	   -prefix $ventricle_mask

# White matter mask
3dcalc -a $FS_path/$ID/SUMA/aparc+aseg.nii.gz \
	   -datum byte \
       -expr 'amongst(a,2,7,41,46,251,252,253,254,255)' \
	   -prefix $WM_mask

# Grey matter mask
#3dcalc -a $FS_path/$ID/SUMA/aparc+aseg.nii.gz \
#	   -datum byte \
#      -expr 'amongst(a,3,8,10,11,12,13,16,17,18,19,20,26,27,28,42,47,49,50,51,52,53,54,55,56,58,59,60)' \
#	   -prefix $GM_mask
#-> Did not work: was missing the actual cerebral grey matter (e.g., 3 & 42)

#19	Left-Insula
#20	Left-Operculum
#27	Left-Substancia-Nigra
#55	Right-Insula
#56	Right-Operculum
#59	Right-Substancia-Nigra

# Alternatively: https://searchcode.com/codesearch/view/75234151/
#3dcalc -prefix WM   -a aseg_RPI+orig -expr 'amongst(a,2,7,41,46,77,78,79)'            
#3dcalc -prefix Vent -a aseg_RPI+orig -expr 'amongst(a,4,5,14,15,43,44)'               
#3dcalc -prefix GM_L -a aseg_RPI+orig -expr 'amongst(a,3,8,10,11,12,13,17,18,26,28)'   
#3dcalc -prefix GM_R -a aseg_RPI+orig -expr 'amongst(a,42,47,49,50,51,52,53,54,58,60)' 
#3dcalc -prefix BS   -a aseg_RPI+orig -expr 'amongst(a,16)'  

# Align FreeSurfer ANAT (SurfVol) to ANAT
3dAllineate -warp shr \
			-source $FS_path/$ID/SUMA/*_SurfVol.nii* \
			-base $anat \
			-prefix $FS_path/SurfVol_anat.nii.gz \
			-final wsinc5 \
			-1Dmatrix_save $FS_path/SurfVol2anat_mat.1D

