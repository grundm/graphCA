#!/bin/bash
# gppi2.sh $ID

# AFNI Tutorial: https://afni.nimh.nih.gov/sscc/gangc/CD-CorrAna.html

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

#CPUs=$(( $(nproc) - 1))
CPUs=1

onset_shift=-7.5 # due to removing 10 initial TRs
TR=0.750
resp_model='GAM'

### TIME SERIES
pnum=6 # -polort

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES
mri_path=/data/pt_nro150/mri

epi_path_wo_bnum=$mri_path/ID$ID/epi_pre_2018/epi_*

anat_path=$mri_path/ID$ID/T1_2018
atlas_path=$mri_path/atlas

#onsets_path=$mri_path/ID$ID/onsets/new
onsets_path=$mri_path/ID$ID/onsets/new3/shift${onset_shift}

gppi_path=$mri_path/ID$ID/gppi/gppi_power_all_cond2 # EDIT #

PPI_approach=FSL # EDIT #
#PPI_approach=SPM

ts_path=$gppi_path/ts

cond_labels=(CR \
			 near_miss \
			 near_hit \
			 supra_hit)

#cond_labels=(CR_conf \
#			 near_miss_conf \
#			 near_hit_conf \
#			 supra_hit_conf)

### EPIs
valid_blocks_txt=$onsets_path/$ID\_valid_blocks.1D

epi_file_wildcard=denoised/epi_*_denoised.nii.gz # EDIT #

mc_enorm_wildcard=mc/epi_*mc_enorm.1D
mc_censor_wildcard=mc/epi_*mc_censor.1D

# 3dDeconvolve can take multi-column 1D time series file (time along rows)
input_files=($ts_path/ts_*_mean.1D)

### NUISANCE REGRESSORS
nuisance_reg_wildcard=denoised/epi_*nuisance_reg.1D

### ATLAS
ROI_r=4 # EDIT #
atlas=$atlas_path/power_2011_MNI_r${ROI_r}_epi.nii.gz # EDIT #

### BRAIN MASK
epi_brain_mask=$anat_path/MNI_bmask_epi_d.nii.gz

#GLM_mask=$epi_brain_mask # EDIT #
GLM_mask=$atlas

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### MOTION DATA
mc_enorm_valid=$gppi_path/mc_enorm_valid.1D

mc_censor_valid=$gppi_path/mc_censor_valid.1D

mc_censor_valid_TRnum=$gppi_path/mc_censor_valid_TRnum.1D

### NUISANCE REGRESSOR
nuisance_reg_valid=$gppi_path/nuisance_reg_valid.1D

### GLMs
glm_path=$gppi_path/glm_${PPI_approach} # EDIT #

# ================================================================================
# PREPARE gPPI (only for "valid" blocks)
# --------------------------------------------------------------------------------

if [ -f "$valid_blocks_txt" ]; then

printf "\nRUN gPPI: ID%s\n\n" "$ID"

mkdir $glm_path

# ================================================================================
# VALID EPIs
# --------------------------------------------------------------------------------

# Get valid blocks (see "onset_t.R")
read -a valid_blocks -d '\t' < $valid_blocks_txt

# Get valid EPI files
epi_valid=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$epi_file_wildcard; done))

# ================================================================================
# MOTION DATA
# --------------------------------------------------------------------------------

# Valid blocks (see "onset_t.R")
read -a valid_blocks -d '\t' < $valid_blocks_txt

# Motion parameters of valid EPIs
mc_enorm_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$mc_enorm_wildcard; done))

cat ${mc_enorm_valid_files[@]} > $mc_enorm_valid

# Motion censor vectors of valid EPIs
mc_censor_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$mc_censor_wildcard; done))

cat ${mc_censor_valid_files[@]} > $mc_censor_valid

# Number of censored TR
3dTstat -zcount -prefix stdout: $mc_censor_valid\' > $mc_censor_valid_TRnum

# ================================================================================
# NUISANCE REGRESSORS
# --------------------------------------------------------------------------------

# Valid blocks (see "onset_t.R")
read -a valid_blocks -d '\t' < $valid_blocks_txt

# Nuisance regressors of valid EPIs
nuisance_reg_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$nuisance_reg_wildcard; done))

cat ${nuisance_reg_valid_files[@]} > $nuisance_reg_valid

# ================================================================================
# RUN gPPI
# --------------------------------------------------------------------------------

# Loop ROIs
for ((i=0; i<$(3dinfo -ni ${input_files[0]}); i++)); do
#for ((i=0; i<1; i++)); do

	case $((i + 1)) in

	[0-9]) ID_str=00$((i + 1)) ;;

	[1-9][0-9]) ID_str=0$((i + 1)) ;;

	*) ID_str=$((i + 1)) ;;

	esac

	glm_outdir=$glm_path/ROI_${ID_str}

	mkdir $glm_outdir

#	cond_labels=(null \
#				 near_miss_conf \
#				 near_miss_unconf \
#				 near_hit_unconf \
#				 near_hit_conf \
#				 supra)

#	3dDeconvolve -input ${epi_valid[@]} \
	3dDeconvolve -force_TR $TR \
				 -input ${input_files[@]} \
				 -jobs $CPUs \
				 -censor $mc_censor_valid \
				 -polort $pnum \
				 -local_times \
				 -num_stimts 9 \
				 -stim_times 1 $onsets_path/${ID}_${cond_labels[0]}_t_shift${onset_shift}.1D $resp_model -stim_label 1 ${cond_labels[0]} \
				 -stim_times 2 $onsets_path/${ID}_${cond_labels[1]}_t_shift${onset_shift}.1D $resp_model -stim_label 2 ${cond_labels[1]} \
				 -stim_times 3 $onsets_path/${ID}_${cond_labels[2]}_t_shift${onset_shift}.1D $resp_model -stim_label 3 ${cond_labels[2]} \
				 -stim_times 4 $onsets_path/${ID}_${cond_labels[3]}_t_shift${onset_shift}.1D $resp_model -stim_label 4 ${cond_labels[3]} \
				 -stim_file 5 $ts_path/ts_${ID}_dt.1D{$i}\' -stim_label 5 ROI \
				 -stim_file 6 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[0]}.1D{$i}\' -stim_label 6 ${cond_labels[0]}_I \
				 -stim_file 7 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[1]}.1D{$i}\' -stim_label 7 ${cond_labels[1]}_I \
				 -stim_file 8 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[2]}.1D{$i}\' -stim_label 8 ${cond_labels[2]}_I \
				 -stim_file 9 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[3]}.1D{$i}\' -stim_label 9 ${cond_labels[3]}_I \
				 -ortvec $nuisance_reg_valid nuisance_reg \
				 -x1D $glm_outdir/${ID}_${ID_str}_gppi.xmat.1D \
				 -x1D_stop

#				 -stim_times 5 $onsets_path/${ID}_${cond_labels[4]}_t_shift${onset_shift}.1D $resp_model -stim_label 5 ${cond_labels[4]} \
#				 -stim_times 6 $onsets_path/${ID}_${cond_labels[5]}_t_shift${onset_shift}.1D $resp_model -stim_label 6 ${cond_labels[5]} \
#				 -stim_times 7 $onsets_path/${ID}_${cond_labels[6]}_t_shift${onset_shift}.1D $resp_model -stim_label 7 ${cond_labels[6]} \
#				 -stim_times 8 $onsets_path/${ID}_${cond_labels[7]}_t_shift${onset_shift}.1D $resp_model -stim_label 8 ${cond_labels[7]} \
#				 -stim_times 9 $onsets_path/${ID}_resp2_t_shift${onset_shift}.1D $resp_model -stim_label 9 resp2 \


#				 -num_glt 18 \
#				 -gltsym 'SYM: '"${cond_labels[4]}"'_I -'"${cond_labels[1]}"'_I' -glt_label 1 ${cond_labels[4]}_I-${cond_labels[1]}_I \
#				 -gltsym 'SYM: '"${cond_labels[1]}"'_I -'"${cond_labels[0]}"'_I' -glt_label 2 ${cond_labels[1]}_I-${cond_labels[0]}_I \
#				 -gltsym 'SYM: '"${cond_labels[2]}"'_I -'"${cond_labels[0]}"'_I' -glt_label 3 ${cond_labels[2]}_I-${cond_labels[0]}_I \
#				 -gltsym 'SYM: '"${cond_labels[3]}"'_I -'"${cond_labels[0]}"'_I' -glt_label 4 ${cond_labels[3]}_I-${cond_labels[0]}_I \
#				 -gltsym 'SYM: '"${cond_labels[4]}"'_I -'"${cond_labels[0]}"'_I' -glt_label 5 ${cond_labels[4]}_I-${cond_labels[0]}_I \
#				 -gltsym 'SYM: '"${cond_labels[5]}"'_I -'"${cond_labels[0]}"'_I' -glt_label 6 ${cond_labels[5]}_I-${cond_labels[0]}_I \
#				 -gltsym 'SYM: '"${cond_labels[4]}"' -'"${cond_labels[1]}"'' -glt_label 7 ${cond_labels[4]}-${cond_labels[1]} \
#				 -gltsym 'SYM: '"${cond_labels[1]}"' -'"${cond_labels[0]}"'' -glt_label 8 ${cond_labels[1]}-${cond_labels[0]} \
#				 -gltsym 'SYM: '"${cond_labels[2]}"' -'"${cond_labels[0]}"'' -glt_label 9 ${cond_labels[2]}-${cond_labels[0]} \
#				 -gltsym 'SYM: '"${cond_labels[3]}"' -'"${cond_labels[0]}"'' -glt_label 10 ${cond_labels[3]}-${cond_labels[0]} \
#				 -gltsym 'SYM: '"${cond_labels[4]}"' -'"${cond_labels[0]}"'' -glt_label 11 ${cond_labels[4]}-${cond_labels[0]} \
#				 -gltsym 'SYM: '"${cond_labels[5]}"' -'"${cond_labels[0]}"'' -glt_label 12 ${cond_labels[5]}-${cond_labels[0]} \
#				 -gltsym 'SYM: '"${cond_labels[5]}"' -'"${cond_labels[4]}"'' -glt_label 13 ${cond_labels[5]}-${cond_labels[4]} \
#				 -gltsym 'SYM: 0.5*'"${cond_labels[4]}"'_I +0.5*'"${cond_labels[1]}"'_I -0.5*'"${cond_labels[3]}"'_I -0.5*'"${cond_labels[2]}"'_I' -glt_label 14 near_conf_I-near_unconf_I \
#				 -gltsym 'SYM: 0.5*'"${cond_labels[4]}"'_I +0.5*'"${cond_labels[3]}"'_I -0.5*'"${cond_labels[2]}"'_I -0.5*'"${cond_labels[1]}"'_I' -glt_label 15 near_hit_I-near_miss_I \
#				 -gltsym 'SYM: 0.25*'"${cond_labels[1]}"' +0.25*'"${cond_labels[2]}"' +0.25*'"${cond_labels[3]}"' +0.25*'"${cond_labels[4]}"'' -glt_label 16 stim_mean \
#				 -gltsym 'SYM: 0.25*'"${cond_labels[1]}"' +0.25*'"${cond_labels[2]}"' +0.25*'"${cond_labels[3]}"' +0.25*'"${cond_labels[4]}"' -'"${cond_labels[0]}"'' -glt_label 17 stim_mean-null \
#				 -gltsym 'SYM: '"${cond_labels[7]}"'_I -'"${cond_labels[6]}"'_I' -glt_label 18 ${cond_labels[7]}_I-${cond_labels[6]}_I \


#				 -stim_file 15 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[4]}.1D{$i}\' -stim_label 15 ${cond_labels[4]}_I \
#				 -stim_file 16 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[5]}.1D{$i}\' -stim_label 16 ${cond_labels[5]}_I \
#				 -stim_file 17 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[6]}.1D{$i}\' -stim_label 17 ${cond_labels[6]}_I \
#				 -stim_file 18 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[7]}.1D{$i}\' -stim_label 18 ${cond_labels[7]}_I \


#				 -stim_file 10 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[0]}.1D{$i}\' -stim_label 10 ${cond_labels[0]}_I \
#				 -stim_file 11 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[1]}.1D{$i}\' -stim_label 11 ${cond_labels[1]}_I \
#				 -stim_file 12 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[2]}.1D{$i}\' -stim_label 12 ${cond_labels[2]}_I \
#				 -stim_file 13 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[3]}.1D{$i}\' -stim_label 13 ${cond_labels[3]}_I \
#				 -stim_file 14 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[4]}.1D{$i}\' -stim_label 14 ${cond_labels[4]}_I \
#				 -stim_file 15 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[5]}.1D{$i}\' -stim_label 15 ${cond_labels[5]}_I \
#				 -stim_file 16 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[6]}.1D{$i}\' -stim_label 16 ${cond_labels[6]}_I \
#				 -stim_file 17 $ts_path/ts_${ID}_${PPI_approach}_${cond_labels[7]}.1D{$i}\' -stim_label 17 ${cond_labels[7]}_I \




#					 -mask $atlas \
#					 -xjpeg $glm_path/$glm_model/${ID}_glm_xmat.png \
#					 -gltsym 'SYM: '"$base_model_valid"'' -glt_label 1 baseline \


	# Model Serial Correlations in the Residuals

#		3dREMLfit -input "`echo ${input_files[@]}`" \
	3dREMLfit -input "`echo ${epi_valid[@]}`" \
			  -mask $GLM_mask \
			  -matrix $glm_outdir/${ID}_${ID_str}_gppi.xmat.1D \
			  -tout -nobout \
			  -Rbuck $glm_outdir/${ID}_${ID_str}_gppi_REML.nii.gz

#			  -Rerrts $glm_outdir/${ID}_${ID_str}_gppi_errts_REML.nii.gz \

#			  -Rvar $glm_outdir/${ID}_${ID_str}_gppi_REMLvar.nii.gz \
#			  -Obuck $glm_outdir/${ID}_${ID_str}_gppi_OLSQ.nii.gz
#				  -Rfitts $glm_path/$glm_model/${ID}_glm_fitts_REML.nii.gz \
#				  -Rerrts $glm_path/$glm_model/${ID}_glm_errts_REML.nii.gz \

done # Loop - ROIs

# ================================================================================
# END
# --------------------------------------------------------------------------------

fi # if [ -f "$valid_blocks_txt" ]; then

