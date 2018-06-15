#!/bin/bash
# fmap_coreg.sh $epi $epi_ref $fmap_mag $fmap_phase $proc_path $erode_factor $deltaTE $echo_spacing $phase_dir $banat
# 
# Requires FSL & AFNI
#
# Unfortunately, it does not combine the linear transformation (EPI -> fmap) and unwarping in one interpolation step.
#
# Processing steps:
#
# (1) 	Preparing fieldmap
# 1.1	Extract first volume of magnitude image (fieldmap)
# 1.2	Skull-strip magnitude image from 1.1
# 1.3	Erode skull-stripped magnitude image from 1.2 and create mask (brain mask)
# 1.4	Compute fieldmap radians with fsl_prepare_fieldmap
# 1.5	Create mask of fieldmap from 1.4
# 1.6	Unmask fieldmap from 1.4
#
# (2)	Unwarp EPI
# 2.1	Coregister EPI reference image (e.g., mean EPI) to fieldmap magnitude image from 1.1
# 2.2	Unwarp EPI reference image
# 2.3	Apply coregistration matrix from 2.1 to EPI
# 2.4	Unwarp fieldmap aligned EPI
#
# (3)	Coregister unwarped EPI reference image to anatomical scan
#
# Informed by https://github.com/NeuroanatomyAndConnectivity/pipelines/blob/master/src/lsd_lemon/func_preproc/fieldmap_coreg.py
#
# Author: Martin Grund <mgrund@cbs.mpg.de>

########################################
### INPUT ##############################
########################################

epi=$1 				# recommendation: motion corrected EPI
epi_ref=$2 			# reference image EPI is aligned to (reference image for motion correction)
fmap_mag=$3
fmap_phase=$4
proc_path=$5

erode_factor=$6		# specifies sphere kernel for eroding skull-stripped fieldmap magnitude image
deltaTE=$7			# echo time difference of the fieldmap sequence (see DICOM dir "parameters4SPM/)
echo_spacing=$8		# effective echo spacing
phase_dir=$9		# phase encoding direction

banat=${10}

# deltaTE=?
# <deltaTE> is the echo time difference of the fieldmap sequence - find this out form the operator (defaults are *usually* 2.46ms on SIEMENS )
# 0003 gre_field_map_32
# 0004 gre_field_map_32
# > dicom_hinfo -tag 0018,0081 ID01/*PRISMA/DICOM/00030001
# ID01/13061.30_20160127_074141.PRISMA/DICOM/00030001 4.92
# > dicom_hinfo -tag 0018,0081 ID01/*PRISMA/DICOM/00040001
# ID01/13061.30_20160127_074141.PRISMA/DICOM/00040001 7.38

# echo_spacing=?
# Protocol: Echoabstand=0.66ms=0.00066s (~echo spacing)
# effective echo spacing = total EPI readout time / matrix size
# dwell time = 1/bandwidth = 1/1816 Hz/Px = 0.00055s
# Echo spacing == dwell time per phase-encode line ??? (fungue help: --dwell	set the EPI dwell time per phase-encode line - same as echo spacing - (sec))
# However, here it is different: http://support.brainvoyager.com/functional-analysis-preparation/27-pre-processing/459-epi-distortion-correction-echo-spacing.html 

# phase_dir=?
# unwarp_dir = phase_dir = shift_dir?
# ACQ Phase Encoding Direction//COL -> protocol (A>>P)
# A>>P: y-; P>>A: y

########################################
### OUTPUT DIRECTORY & FILENAMES #######
########################################

fmap_path=$proc_path/fmap_coreg

mkdir -p $fmap_path

fmap_mag_base=$fmap_path/`basename $fmap_mag .nii.gz`

epi_ref_base=`basename $epi_ref .nii.gz`

########################################
### PREPARE FIELDMAP ###################
########################################

## Get, strip & erode first magnitude image
fslroi $fmap_mag $fmap_mag_base\_01.nii.gz 0 1

bet $fmap_mag_base\_01.nii.gz $fmap_mag_base\_01_b.nii.gz -R -m

## zeroing non-zero voxels when zero voxels found in kernel
fslmaths $fmap_mag_base\_01_b.nii.gz -kernel sphere $erode_factor -ero $fmap_mag_base\_01_b_ero.nii.gz

fslmaths $fmap_mag_base\_01_b_ero.nii.gz -abs -bin $fmap_mag_base\_01_b_ero_mask.nii.gz

## Prepare fieldmap (phase image & preprocessed magnitude image)
fsl_prepare_fieldmap SIEMENS $fmap_phase $fmap_mag_base\_01_b_ero.nii.gz $fmap_path/fmap_rads.nii.gz $deltaTE

## Create fieldmap mask
fslmaths $fmap_path/fmap_rads.nii.gz -abs -bin $fmap_path/fmap_rads_mask.nii.gz

## Unmask fieldmap
fugue --unmaskfmap \
	  --unwarpdir=$phase_dir \
	  --loadfmap=$fmap_path/fmap_rads.nii.gz \
	  --mask=$fmap_path/fmap_rads_mask.nii.gz \
	  --savefmap=$fmap_path/fmap_rads_unmask.nii.gz

########################################
### UNWARP EPI #########################
########################################

# Register EPI reference to fieldmap

flirt -in $epi_ref \
	  -ref $fmap_mag_base\_01.nii.gz \
	  -dof 6 \
	  -interp spline \
	  -omat $fmap_path/$epi_ref_base\_2fmap.1D \
	  -out $fmap_path/$epi_ref_base\_fmap.nii.gz

# Unwarp EPI reference

fugue --in=$fmap_path/$epi_ref_base\_fmap.nii.gz \
	  --loadfmap=$fmap_path/fmap_rads_unmask.nii.gz \
	  --mask=$fmap_path/fmap_rads_mask.nii.gz \
	  --dwell=$echo_spacing \
	  --unwarpdir=$phase_dir \
	  --saveshift=$fmap_path/$epi_ref_base\_fmap_shift.nii.gz \
	  --unwarp=$fmap_path/$epi_ref_base\_fmap_unwarp.nii.gz
# Outcome almost independent of unmasking fieldmap before

# Register EPI to fieldmap
# Applies transformation from EPI reference to fieldmap

flirt -applyxfm \
	  -in $epi \
	  -ref $fmap_mag_base\_01.nii.gz \
	  -init $fmap_path/$epi_ref_base\_2fmap.1D \
	  -interp spline \
	  -out $fmap_path/`basename $epi .nii.gz`_fmap.nii.gz \

# Unwarp EPI

fugue --in=$fmap_path/`basename $epi .nii.gz`_fmap.nii.gz \
	  --loadfmap=$fmap_path/fmap_rads_unmask.nii.gz \
	  --mask=$fmap_path/fmap_rads_mask.nii.gz \
	  --dwell=$echo_spacing \
	  --unwarpdir=$phase_dir \
	  --unwarp=$fmap_path/`basename $epi .nii.gz`_fmap_unwarp.nii.gz \

# MAKE WARPFIELD AND APPLY
# THIS DOES NOT TO WORK PROPERLY

#convertwarp --ref=$fmap_mag_base\_01.nii.gz \
#			--premat=$fmap_path/$epi_ref_base\_2fmap.1D \
#			--shiftmap=$fmap_path/$epi_ref_base\_fmap_shift.nii.gz \
#			--shiftdir=$phase_dir \
#			--relout \
#			--out=$fmap_path/$epi_ref_base\_2fmap_unwarp.nii.gz

#applywarp --in=$epi_ref \
#		  --ref=$fmap_mag_base\_01.nii.gz \
#		  --warp=$fmap_path/$epi_ref_base\_2fmap_unwarp.nii.gz \
#		  --rel \
#		  --interp=spline \
#		  --out=$fmap_path/$epi_ref_base\_fmap_unwarp2.nii.gz
       
# Why are ... so different?
# - $fmap_path/$epi_ref_base\_fmap_unwarp.nii.gz
# - $fmap_path/$epi_ref_base\_fmap_unwarp2.nii.gz
#
# Coregistration -> Hmm, but I used coregistered EPI
# Best guess: Combination of matrix and shift is strange

########################################
### COREGISTER EPI to BANAT ############
########################################

3dAllineate -EPI \
			-warp shr \
			-source $fmap_path/$epi_ref_base\_fmap_unwarp.nii.gz \
			-base $banat \
			-prefix $fmap_path/$epi_ref_base\_banat.nii.gz \
			-final wsinc5 \
			-1Dmatrix_save $fmap_path/$epi_ref_base\_fmap_unwarp_2banat_mat.1D

