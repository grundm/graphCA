#!/bin/bash
# fmri_pre.sh $ID $epi_file

# #############################
# # PREPROCESSING - EPI FILES #
# #############################
#
# AFNI Preprocessing - OHBM 2016: http://www.humanbrainmapping.org/files/2016/ED/Course%20Materials/Preprocessing_Cox_Robert.pdf
#
# ### REMOVE INITIAL TRs ###
#
# Allows to remove initial TRs. Additionally it creates a regressor to censor TRs 
# with outliers above threshold.
#
#
# ### DESPIKING ###
#
# Despikes the EPI and counts outliers before and after with "3dToutcount".
#
#
# ### SLICE TIMING CORRECTION ###
#		
# Uses the slice timing files generated with "get_slicetime.sh".
#
#	
# ### MOTION CORRECTION ###
#
# Realigns all EPI volumes to the mean EPI. Additionally, it summarizes the 
# movement parameters to a single value (euclidian norm) and checks for volumes
# that exceeded a certain threshold (TR censor list).
#
#
# ### FIELDMAP CORRECTION & COREGISTRATION ###
#
# Entails the settings/arguments for "fmap_coreg.sh" that preprocesses the fieldmap
# to unwarp the EPI and coregister it with the anatomical scan.
#
#
# ### NORMALIZATION ###
#
# Combines the coregistration matrix of "fmap_coreg.sh" (EPI -> BANAT) with the warping
# matrix to normalize the anatomical scan to MNI template (BANAT -> MNI, "anat_pre.sh").
#
#
# ### PREPARES MASKS ###
#
# Dilates and aligns white matter and ventricle masks to normalized EPI
#
#
# ### NOISE PCA ###
#
# Extracts principal components in white matter and ventricle masks from normalized EPI
#
#
# ### SMOOTHING & BRAIN MASKING - Normalized EPI ###
#
# Smoothes and skull-strips the normalized EPI with the normalized skull-stripped anatomical scan
#
#
# ### SCALING ###
#
# Scales each voxel's time series to mean of 100 with maximum of 200
#
#
# ### NUISANCE REGRESSION ###
#
# Regressing out
# - 6 motion parameters and their derivatives & all squared
# - fraction of outliers and derivative
# - white matter principal components
# - ventricles principal components
#
#

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

# Processing steps
proc_steps=(rm_initTRs \
			despiking \
			slice_timing_corr \
			motion_corr \
			fmap_coreg \
			normalize \
			prep_masks \
			noise_pca \
			smooth \
			scale \
			nuisance_reg)

proc_steps=(smooth \
			scale \
			nuisance_reg)

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}
epi_file=${2}

### DIRECTORIES
code_path=/nobackup/curie2/mgrund/code/graphca/mri

mri_path=/data/pt_nro150/mri

anat_path=$mri_path/ID$ID/T1

nii_path=$mri_path/ID$ID/nii

epi_path=`dirname $epi_file`
#epi_path=$mri_path/ID$ID/nii/epi


### FILES
in_file=$epi_file

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### DIRECTORIES

epi_base=`basename $epi_file .nii.gz`

proc_path=$mri_path/ID$ID/epi_pre/$epi_base

mkdir -p $proc_path

# ================================================================================
# PREPROCESSING
# --------------------------------------------------------------------------------

# Loop processing steps
for p_step in ${proc_steps[@]}; do

	case $p_step in

	rm_initTRs)

		in_file=$epi_file

		### REMOVE INITIAL TRs ###

		printf "\nREMOVE INITIAL TRs: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS		
		rmTRs=10
		pnum=6
		censor_out_thr=0.1

		# OUTPUT
		rm_path=$proc_path/rm
		mkdir $rm_path

		epi_rm=$rm_path/$epi_base\_rm.nii.gz
		epi_rm_out=$rm_path/$epi_base\_rm_out.1D
		epi_rm_out_minTR=$rm_path/$epi_base\_rm_out_minTR.1D
		epi_rm_out_censorTR=$rm_path/$epi_base\_rm_out_censorTR.1D

		# Removie intial TRs
		3dTcat -prefix $epi_rm \
				$in_file[${rmTRs}..$]

		# Count outliers
    	3dToutcount -automask \
					-fraction \
					-polort $pnum \
					-legendre \
                	$epi_rm \
					> $epi_rm_out

		# Outlier minimum TR
		echo `3dTstat -argmin -prefix - ${epi_rm_out}\'` > $epi_rm_out_minTR

		# Censor outlier TRs
	    1deval -a $epi_rm_out \
			   -expr "1-step(a-${censor_out_thr})" \
			   > $epi_rm_out_censorTR

		in_file=$epi_rm
	;;

	despiking)

		in_file=$proc_path/rm/$epi_base\_rm.nii.gz

		### DESPIKING ###

		printf "\nDESPIKING: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		pnum=6

		# OUTPUT
		ds_path=$proc_path/ds
		mkdir $ds_path

		epi_ds=$ds_path/$epi_base\_ds.nii.gz

		outlier_pre=$ds_path/`basename $in_file .nii.gz`\_out.1D
		outlier_post=$ds_path/`basename $epi_ds .nii.gz`\_out.1D

		# Count outliers BEFORE
		3dToutcount -automask \
					-fraction \
					-polort $pnum \
					-legendre $in_file \
					> $outlier_pre

		# Remove Spikes
		# For time series more than 500 points long, the '-OLD' algorithm is tremendously slow. -> TRUE THAT (1.5h for 1 epi)
		# You should use the '-NEW' algorith in such cases.
		3dDespike -NEW \
				  -prefix $epi_ds \
				  $in_file

		# Count outliers AFTER
		3dToutcount -automask \
					-fraction \
					-polort $pnum \
					-legendre $in_file \
					> $outlier_post

		#rm -f $in_file # delete NIfTI output of previous step
		in_file=$epi_ds

	;;

	slice_timing_corr)

		in_file=$proc_path/ds/$epi_base\_ds.nii.gz

		### SLICE TIMING CORRECTION ###

		printf "\nSLICE TIME CORRECTION: ID%s %s\n\n" "$ID" "$in_file"
	
		# SETTINGS		
		TR=750

		# INPUT
		slice_t_file=$epi_path/slice_t/$epi_base\_slice_t.txt		

		# OUTPUT
		epi_stc=$proc_path/$epi_base\_stc.nii.gz

		# Slice timing correction
		3dTshift -TR $TR \
				 -tzero 0 \
				 -Fourier \
			     -tpattern @$slice_t_file \
				 -prefix $epi_stc $in_file

		in_file=$epi_stc

	;;

	motion_corr)

		in_file=$proc_path/$epi_base\_stc.nii.gz

		### MOTION CORRECTION ###

		printf "\nMOTION CORRECTION: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		block_num=1
		censor_motion_limit=0.3

		# INPUT
		epi_rm_out_minTR=$proc_path/rm/${epi_base}_rm_out_minTR.1D

		# OUTPUT		
		mc_path=$proc_path/mc
		mkdir $mc_path

		epi_mc_base=$mc_path/${epi_base}_mc

		mc_base=${epi_mc_base}_ref.nii.gz
		
		# --------------------------------------------------------------------------------

		# Create reference image for coregistration
		read -a out_minTR < $epi_rm_out_minTR

		3dbucket -prefix $mc_base \
				 $in_file[$out_minTR]

		# Coregistration
		# try w/o "-twopass"				
		3dvolreg -Fourier -twopass \
				 -base $mc_base \
				 -1Dfile $epi_mc_base\_par.1D \
				 -1Dmatrix_save $epi_mc_base\_mat.aff12.1D \
				 -maxdisp1D $epi_mc_base\_maxdisp.1D \
				 -prefix $epi_mc_base\.nii.gz \
				 $in_file

		# Compute euclidean_norm
		# Alternative to Framewise Displacement (FD) by Power et al. (2012, NeuroImage)
		# Interesting debate: https://afni.nimh.nih.gov/afni/community/board/read.php?1,148852,148852
		# + https://afni.nimh.nih.gov/afni/community/board/read.php?1,143809,144115#msg-144115
	    1d_tool.py -infile $epi_mc_base\_par.1D -set_nruns $block_num \
	               -derivative -collapse_cols euclidean_norm  \
	               -write $epi_mc_base\_enorm.1D

		# Compute derivatives
	    1d_tool.py -infile $epi_mc_base\_par.1D -set_nruns $block_num \
	               -derivative \
	               -write $epi_mc_base\_deriv.1D

		# Concatenate motion parameters and their derivatives
		1dcat $epi_mc_base\_par.1D $epi_mc_base\_deriv.1D > $epi_mc_base\_par_deriv.1D


		# Check for TRs with movement above threshold
		1d_tool.py -infile $epi_mc_base\_par.1D \
				   -set_nruns $block_num \
				   -show_censor_count \
				   -censor_motion $censor_motion_limit $epi_mc_base \
				   -censor_prev_TR -overwrite

		in_file=$epi_mc_base\.nii.gz

	;;

	fmap_coreg)

		in_file=$proc_path/mc/$epi_base\_mc.nii.gz

		### FIELDMAP CORRECTION & COREGISTRATION ###

		printf "\nFIELDMAP CORRECTION & COREGISTRATION: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		erode_factor=5
		deltaTE=2.46
		echo_spacing=0.00066
		phase_dir=y-

		# INPUT

		in_file_ref=`dirname $in_file`/*_ref.nii.gz

		# Created in advance a list that assigns EPI and fieldmap files
		# (for 4 participants 2 fieldmaps were acquired)
		epi_fmap_list_file=$mri_path/epi_fmap_list_curated.txt

		# epi fmap_mag fmap_phase
		epi_fmap_files=($(cat $epi_fmap_list_file | grep $epi_base))

		banat=$anat_path/banat.nii.gz

		# --------------------------------------------------------------------------------

		# Order of arguments relevant
		# fmap_coreg.sh $epi $epi_ref $fmap_mag $fmap_phase $proc_path $erode_factor $deltaTE $echo_spacing $phase_dir $banat
		$code_path/fmap_coreg.sh $in_file \
								 $in_file_ref \
								 $nii_path/${epi_fmap_files[1]} \
								 $nii_path/${epi_fmap_files[2]} \
								 $proc_path \
								 $erode_factor \
								 $deltaTE \
								 $echo_spacing \
								 $phase_dir \
								 $banat

	;;

	normalize)

		in_file=$proc_path/fmap_coreg/${epi_base}_mc_fmap_unwarp.nii.gz

		### NORMALIZATION ###

		printf "\nNORMALIZATION: ID%s %s\n\n" "$ID" "$in_file"

		# INPUT		

		# Transformation matrices
		# epi_mean_fmap_unwarp -> banat
		epi2banat_mat=($proc_path/fmap_coreg/*_2banat_mat.1D)
		# banat -> norm
		banat2norm_mat=($anat_path/warp/*aff12.1D)
		banat_norm_warp=($anat_path/warp/*_WARP.nii.gz)

		# Reference image
		banat_norm_epi=$anat_path/banat_norm_epi.nii.gz

		# Mask
		brain_mask_norm_epi_d=$anat_path/MNI_bmask_epi_d.nii.gz

		# OUTPUT
		norm_path=$proc_path/norm
		mkdir $norm_path

		epi_norm_tmp=$norm_path/`basename $in_file .nii.gz`_norm_tmp.nii.gz
		epi_norm=$norm_path/`basename $in_file .nii.gz`_norm.nii.gz

		# --------------------------------------------------------------------------------
		
		# Normalize
 		3dNwarpApply -nwarp ''"$banat_norm_warp"' '"$banat2norm_mat"' '"$epi2banat_mat"'' \
					 -interp wsinc5 \
					 -source $in_file \
					 -master $banat_norm_epi \
					 -prefix $epi_norm_tmp

		# Mask with dilated MNI brain mask
		3dcalc -a $epi_norm_tmp \
			   -b $brain_mask_norm_epi_d \
			   -expr 'a*b' \
			   -prefix $epi_norm

		rm -f $epi_norm_tmp

		in_file=$epi_norm

	;;

	prep_masks)

		### PREPARE FREESURFER MASKS ###

		# Erode masks (white matter, ventricles) to cover only "core" voxels
		# Align masks to normalized EPI

		printf "\nPREPARE FREESURFER MASKS: ID%s %s\n\n" "$ID"

		# SETTINGS
			# Sphere size to erode masks in original anatomical space (1x1x1 mm)
			WM_mask_dilate=-5
			vent_mask_dilate=-1 # -2 already let to zero masks for 13/150 blocks

		# INPUT

			# Directories
			FS_path=$anat_path/../FS

			# Transformation matrices
			# FreeSurfer -> anat
			FS2anat_mat=$FS_path/SurfVol2anat_mat.1D
			# banat -> norm
			banat2norm_mat=($anat_path/warp/*aff12.1D)
			banat_norm_warp=($anat_path/warp/*_WARP.nii.gz)

			# Reference image
			banat_norm_epi=$anat_path/banat_norm_epi.nii.gz

			# Masks
			WM_mask=$FS_path/FT_WM.nii.gz
			vent_mask=$FS_path/FT_vent.nii.gz

		# OUTPUT

			# Directories
			masks_path=$proc_path/masks
			mkdir $masks_path

			# Masks
			WM_mask_e=$masks_path/WM_e.nii.gz
			vent_mask_e=$masks_path/vent_e.nii.gz
			WM_mask_norm=$masks_path/WM_norm.nii.gz
			vent_mask_norm=$masks_path/vent_norm.nii.gz

		# --------------------------------------------------------------------------------

		# Erode masks
		3dmask_tool -input $WM_mask \
					-dilate_input $WM_mask_dilate \
					-prefix $WM_mask_e

		3dmask_tool -input $vent_mask \
					-dilate_input $vent_mask_dilate \
					-prefix $vent_mask_e

		# Transform masks
		# White matter (WM) mask
 		3dNwarpApply -nwarp ''"$banat_norm_warp"' '"$banat2norm_mat"' '"$FS2anat_mat"'' \
					 -interp wsinc5 \
					 -source $WM_mask_e \
					 -master $banat_norm_epi \
					 -prefix $WM_mask_norm

		# Ventricle (vent) mask
 		3dNwarpApply -nwarp ''"$banat_norm_warp"' '"$banat2norm_mat"' '"$FS2anat_mat"'' \
					 -interp wsinc5 \
					 -source $vent_mask_e \
					 -master $banat_norm_epi \
					 -prefix $vent_mask_norm

	;;

	noise_pca)

		in_file=($proc_path/norm/*_norm.nii.gz)

		### PCA - WHITE MATTER & VENTRICLES ###

		printf "\nPCA - WHITE MATTER & VENTRICLES: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		pcnum=3 # Number of extracted principal components in white matter and ventricles

		# INPUT
		masks_path=$proc_path/masks
		WM_mask=$masks_path/WM_norm.nii.gz
		vent_mask=$masks_path/vent_norm.nii.gz

		# OUTPUT
		noise_pca_path=$proc_path/noise_pca
		mkdir $noise_pca_path

		WM_pc_prefix=$noise_pca_path/`basename $in_file .nii.gz`_WM_pc
		vent_pc_prefix=$noise_pca_path/`basename $in_file .nii.gz`_vent_pc

		WM_pc=${WM_pc_prefix}_vec.1D
		vent_pc=${vent_pc_prefix}_vec.1D

		noise_reg=$noise_pca_path/`basename $in_file .nii.gz`_noise_reg.1D

		# --------------------------------------------------------------------------------

		# White matter
		3dpc -vmean \
			 -mask $WM_mask \
			 -pcsave $pcnum \
			 -prefix $WM_pc_prefix \
			 $in_file

		# Ventricle
		3dpc -vmean \
			 -mask $vent_mask \
			 -pcsave $pcnum \
			 -prefix $vent_pc_prefix \
			 $in_file

		# Concatenate
		1dcat $WM_pc $vent_pc > $noise_reg

	;;

	smooth)

		in_file=($proc_path/norm/*_norm.nii.gz)

		### SMOOTHING & SKULL-STRIPPING ###

		printf "\nSMOOTHING & BRAIN MASKING - NORM: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		FWHM=7

		# INPUT
		brain_mask_norm_epi_d=$anat_path/MNI_bmask_epi_d.nii.gz

		# OUTPUT
		norm_path=$proc_path/norm
		mkdir $norm_path

		epi_norm_sm_tmp=$norm_path/$epi_base\_norm_sm_tmp.nii.gz
		epi_norm_sm=$norm_path/$epi_base\_norm_sm.nii.gz

		# --------------------------------------------------------------------------------

		# Alternative smoothing in mask
#		3dBlurInMask -input $in_file \
#					 -FWHM $FWHM \
#					 -mask $brain_mask_norm_epi_d \
#					 -prefix $epi_norm_sm

		# Smoothing					
		3dmerge -1blur_fwhm $FWHM \
				-doall \
				-prefix $epi_norm_sm_tmp \
				$in_file

		3dcalc -a $epi_norm_sm_tmp \
			   -b $brain_mask_norm_epi_d \
			   -expr 'a*b' \
			   -prefix $epi_norm_sm

		rm -f $epi_norm_sm_tmp


		# Outliers after smoothing
		3dToutcount -fraction \
					-mask $brain_mask_norm_epi_d \
					$epi_norm_sm \
					> $norm_path/`basename $epi_norm_sm .nii.gz`_out.1D

		in_file=$epi_norm_sm

	;;

	scale)

		in_file=($proc_path/norm/*_sm.nii.gz)

		### SCALING ###

		printf "\nSCALING - NORM: ID%s %s\n\n" "$ID" "$in_file"

		# INPUT
		brain_mask_norm_epi_d=$anat_path/MNI_bmask_epi_d.nii.gz

		# OUTPUT
		norm_path=$proc_path/norm
		mkdir $norm_path

		epi_sm_mean=$norm_path/$epi_base\_norm_sm_mean.nii.gz
		epi_scl=$norm_path/$epi_base\_norm_scl.nii.gz

		# --------------------------------------------------------------------------------

		# Calculate mean
		3dTstat -prefix $epi_sm_mean \
				$in_file

		# Scale each voxel time series to mean 100 with maximum of 200
		# Recommend by AFNI: https://afni.nimh.nih.gov/pub/dist/edu/2009_11_taiwan/afni06_decon/afni06_decon.pdf
		3dcalc -a $in_file \
			   -b $epi_sm_mean \
			   -c $brain_mask_norm_epi_d \
			   -expr 'c * min(200, a/b*100)*step(a)*step(b)' \
			   -prefix $epi_scl

		in_file=$epi_scl

	;;

	nuisance_reg)

		in_file=($proc_path/norm/*_norm_scl.nii.gz)

		### NUISANCE REGRESSION ###

		printf "\nNUISANCE REGRESSION: ID%s %s\n\n" "$ID" "$in_file"

		# SETTINGS
		#CPUs=$(( $(nproc) - 1))
		CPUs=60
		TR=0.750
		pnum=6 # -polort; AFNI recommendation's for 1110 volumes (~high pass filter: (6-2)/TR*vol= 0.0046 Hz)

#		fbot=0.008 #
#		ftop=0.25 # 9999 # 0.09 # 0.666 = (.5*(1/.75))1/2 TR (Nyquist frequency)
#		# Longer TRs not so prone to breathing, because TR of 2s -> 0.25 Hz Nyquist frequency

		# INPUT

		# Brain mask
		brain_mask_norm_epi_d=$anat_path/MNI_bmask_epi_d.nii.gz

		# Nuisance regressors						
		mc_par_deriv=$proc_path/mc/${epi_base}_mc_par_deriv.1D		# Motion parameters and derivatives			
		outlier=$proc_path/rm/${epi_base}_rm_out.1D					# Outliers (fractional of EPI after removing initial volumes)
		noise_pc=($proc_path/noise_pca/${epi_base}*_noise_reg.1D)	# White matter & ventricles principal components


		# OUTPUT
		denoised_path=$proc_path/denoised
		mkdir $denoised_path

		epi_denoised=$denoised_path/`basename $in_file .nii.gz`_denoised.nii.gz

		# --------------------------------------------------------------------------------

		# Nuisance regression
		$code_path/nuisance_reg.sh $in_file \
								   $TR \
								   $CPUs \
								   $pnum \
								   $brain_mask_norm_epi_d \
								   $mc_par_deriv \
								   $outlier \
								   $noise_pc \
 								   $epi_denoised

#								   $fbot \
#								   $ftop


	;;
		

	esac # switch - processing steps


done # 1st loop - processing steps
