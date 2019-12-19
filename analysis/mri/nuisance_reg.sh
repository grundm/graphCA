#!/bin/bash
# nuisance_reg.sh $input_file $TR $CPUs $pnum $brainmask $mc_par_deriv $outlier $WM_pc $vent_pc $output_file

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

input_file=${1}		# normalized, smoothed and scaled EPI
TR=${2}				# TR in seconds of input file
CPUs=${3}			# number of CPUs
pnum=${4}			# degrees of polynomials corresponding to the null hypothesis
brainmask=${5}		# brain mask of EPI (input_file)
mc_par_deriv=${6}	# motion parameters and derivatives
outlier=${7}		# number of outliers (fractional) of EPI after removing initial volumes
noise_pc=${8}		# white matter & ventricles principal components before smoothing & scaling EPI
output_file=${9}	# 'corrected' time series

#	fbot=${10}			# exclude frequencies below $fbot
#	ftop=${11}			# exclude frequencies above $ftop

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

outdir=`dirname $output_file`

motion_reg=$outdir/`basename $mc_par_deriv .1D`_sqr.1D

outlier_deriv=$outdir/`basename $input_file .nii.gz`_out_deriv.1D

#bandpass_reg=$outdir/bandpass_reg.1D

nuisance_reg=$outdir/`basename $mc_par_deriv _mc_par_deriv.1D`_nuisance_reg.1D

#nuisance_reg_bandpassed=$outdir/`basename $nuisance_reg .1D`_bandpassed.1D

output_outlier=$outdir/`basename $output_file .nii.gz`_out.1D

outxmat=$outdir/`basename $output_file .nii.gz`.xmat.1D

outbucketOLSQ=$outdir/`basename $output_file .nii.gz`_OLSQ.nii.gz
outbucket_errts=$outdir/`basename $output_file .nii.gz`_errts.nii.gz
#outbetaREML=$outdir/`basename $output_file .nii.gz`_beta_REML.nii.gz


# ================================================================================
# MOTION REGRESSOR
# --------------------------------------------------------------------------------

# Square motion parameters and its derivaties (Friston 24 motion regression)
for i in `seq $(3dinfo -nv $mc_par_deriv)`; do

	1deval -a $mc_par_deriv[$((i-1))] -expr 'a^2' > $outdir/motion_sqr_${i}.1D

done

1dcat $mc_par_deriv $outdir/motion_sqr_*.1D > $motion_reg

rm $outdir/motion_sqr_*.1D

# ================================================================================
# OUTLIER REGRESSOR
# --------------------------------------------------------------------------------

# AFNI Rick Reynolds:
# "In my opinion, the outliers do a better job of capturing motion than the motion
# parameters. It is not restricted to the success of volume registration."
# https://afni.nimh.nih.gov/afni/community/board/read.php?1,93196,93203#msg-93203

# And their derivatives
1d_tool.py -infile $outlier \
		   -derivative \
		   -write $outlier_deriv

# ================================================================================
# BANDPASS REGRESSORS
# --------------------------------------------------------------------------------

#	1dBport -nodata `3dinfo -nv $input_file` $TR \
#			-band $fbot $ftop \
#			-invert \
#			-nozero \
#			> $bandpass_reg

# ================================================================================
# CONCATENATE NUISANCE REGRESSORS (W/O BANDPASS)
# --------------------------------------------------------------------------------

1dcat $motion_reg \
	  $outlier \
	  $outlier_deriv \
	  $noise_pc \
	  > $nuisance_reg

#	# Bandpass nuisance regressors
#	3dBandpass -input $nuisance_reg \
#			   -dt $TR \
#			   -band $fbot $ftop \
#			   -prefix $nuisance_reg_bandpassed

# ================================================================================
# GLM WITH NUISANCE REGRESSORS (W/O BANDPASS)
# --------------------------------------------------------------------------------
# Enormous slowdown by ~971 bandpass regressors

# Setup design matrix
3dDeconvolve -force_TR $TR \
			 -input $input_file \
			 -mask $brainmask \
			 -polort $pnum \
			 -jobs $CPUs \
			 -ortvec $nuisance_reg nuisance_reg \
			 -x1D $outxmat \
			 -x1D_stop

#			 -bout -rout -fout -tout \
#			 -bucket $outbucketOLSQ

#			 -errts $outbucket_errts \


# ================================================================================
# PROJECT OUT NUISANCE REGRESSORS
# --------------------------------------------------------------------------------

3dTproject -input $input_file \
		   -TR $TR \
		   -mask $brainmask \
		   -polort 0 \
		   -ort $outxmat \
		   -prefix $output_file

# (WITH BANDPASS)
#		   -passband $fbot $ftop \

# Calculate outliers after nuisance regression
3dToutcount -fraction \
			-mask $brainmask \
			$output_file \
			> $output_outlier
