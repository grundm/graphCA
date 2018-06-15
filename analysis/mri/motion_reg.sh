#!/bin/bash
# motion_reg.sh $input_file $mc_par_deriv $brainmask $output_file

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

#CPUs=$(( $(nproc) - 1))
CPUs=4

TR=0.750

### TIME SERIES
pnum=1 # -polort

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
input_file=${1}		# normalized but not smoothed EPI
mc_par_deriv=${2}	# motion parameters and derivatives
brainmask=${3}		# brain mask of input file
output_file=${4}	# residual time series

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

outdir=`dirname $output_file`

input_outlier=$outdir/`basename $input_file .nii.gz`_out.1D
input_outlier_deriv=$outdir/`basename $input_file .nii.gz`_out_deriv.1D

motion_outlier=$outdir/`basename $mc_par_deriv .1D`_out.1D

output_outlier=$outdir/`basename $output_file .nii.gz`_out.1D

outxmat=$outdir/`basename $output_file .nii.gz`.xmat.1D
#outbucket=$outdir/`basename $output_file .nii.gz`_GLM.nii.gz
outbucket=$outdir/`basename $output_file .nii.gz`_REML.nii.gz

# ================================================================================
# PREPARE NUISANCE REGRESSORS
# --------------------------------------------------------------------------------

# AFNI Rick Reynolds:
# "In my opinion, the outliers do a better job of capturing motion than the motion
# parameters. It is not restricted to the success of volume registration."
# https://afni.nimh.nih.gov/afni/community/board/read.php?1,93196,93203#msg-93203

# Calculate input outliers
3dToutcount -fraction \
			-mask $brainmask \
			$input_file \
			> $input_outlier

## And their derivatives
#1d_tool.py -infile $input_outlier \
#		   -derivative \
#		   -write $input_outlier_deriv		
#
## Concatenate motion & outliers & their derivatives
#1dcat $mc_par_deriv \
#	  $input_outlier \
#	  $input_outlier_deriv \
#	  > $motion_outlier

# ================================================================================
# GLM WITH MOTION PARAMETERS & DERIVATIVES
# --------------------------------------------------------------------------------

3dDeconvolve -input $input_file \
			 -mask $brainmask \
			 -jobs $CPUs \
			 -force_TR $TR \
			 -polort $pnum \
			 -ortvec $mc_par_deriv mc_par_deriv \
			 -x1D $outxmat \
			 -x1D_stop
#			 -bout -rout -fout -tout \
#     		 -bucket $outbucket \
#			 -errts $output_file

#			 -ortvec $motion_outlier motion_outlier \

# Model serial correlations in the residuals

3dREMLfit -input $input_file \
		  -mask $brainmask \
		  -matrix $outxmat \
		  -Rbeta $outbucket \
		  -Rerrts $output_file

# Calculate output outliers

3dToutcount -fraction \
			-mask $brainmask \
			$output_file \
			> $output_outlier
