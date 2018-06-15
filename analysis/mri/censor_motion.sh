#!/bin/bash
# censor_motion.sh
#
# Script for running again the censoring motion function

########################################
### SETTINGS ###########################
########################################

block_num=1
censor_motion_limit=0.3

### DIRECTORIES

mri_path=/nobackup/curie2/mgrund/GraphCA/mri

### MOTION PARAMETER FILES

mc_par_suffix=_par.1D

mc_par_files=($mri_path/ID*/epi_pre/epi*/mc/*$mc_par_suffix)


########################################
### COMPUTE CENSOR TRs #################
########################################

for mc_par_file in ${mc_par_files[@]}; do

	echo `basename ${mc_par_file%*$mc_par_suffix}`

	1d_tool.py -infile $mc_par_file \
			   -set_nruns $block_num \
			   -show_censor_count \
			   -censor_motion $censor_motion_limit ${mc_par_file%*$mc_par_suffix} \
			   -censor_prev_TR \
			   -overwrite

#	# Derivatives
#	1d_tool.py -infile $mc_par_file \
#			   -set_nruns $block_num \
#			   -derivative \
#			   -write ${mc_par_file%*$mc_par_suffix}_deriv.1D \
#			   -overwrite
#
#	1dcat $mc_par_file ${mc_par_file%*$mc_par_suffix}_deriv.1D > ${mc_par_file%*$mc_par_suffix}_par_deriv.1D

done
