#!/bin/bash
# glm.sh $ID

# https://afni.nimh.nih.gov/pub/dist/edu/2012_0326_lister_hill/afni_handouts/RegressionHandsOn.pdf
# https://afni.nimh.nih.gov/pub/dist/HOWTO/howto/ht02_DDmb/html/AFNI_howto.html

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

### GLM MODELS
glm_models=(stim_conf stim_conf_TENT) # EDIT #

### GLM SETTINGS
#CPUs=$(( $(nproc) - 1))
CPUs=1

TR=0.750

onset_shift=-7.5 # due to removing 10 initial TRs
#block_TR=1120
block_TR=1110

pnum=6 # -polort

# Response model
#resp_model='GAM'
#resp_model='TENT(0,12,9)'
# HRF starts 0s after stimulus/response onset, lasts for 12s and has 9 basis tents (12/(9-1)=1.5s spaced) 
resp_model='TENT(-6,12,13)'
# starts 6s before stimulus/response onset, lasts for 12s after stimulus onset and has 13 basis tents (18/(13-1)=1.5s spaced) 


# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES

#mri_path=/nobackup/curie2/mgrund/GraphCA/mri
mri_path=/data/pt_nro150/mri

anat_path=$mri_path/ID$ID/T1

epi_path_wo_bnum=$mri_path/ID$ID/epi_pre/epi_*

#onsets_path=$mri_path/ID$ID/onsets/new
onsets_path=$mri_path/ID$ID/onsets/new/shift${onset_shift}

### EPI FILES

#epi_file_wildcard=norm2/epi_*_sm.nii.gz # EDIT #
epi_file_wildcard=denoised/epi_*_denoised.nii.gz

valid_blocks_txt=$onsets_path/$ID\_valid_blocks.1D

# Motion data
mc_enorm_wildcard=mc/epi_*mc_enorm.1D
mc_censor_wildcard=mc/epi_*mc_censor.1D

# Nuisance regressors
nuisance_reg_wildcard=denoised/epi_*nuisance_reg.1D # EDIT #
#nuisance_reg_wildcard=denoised2/epi_*nuisance_reg_bandpassed.1D

### BRAIN MASK

epi_brain_mask=$anat_path/MNI_bmask_epi_d.nii.gz

# AFNI recommends for 3dMEMA no masking

# "(3) no masking be applied at individual subject analysis level 
# so that no data is lost at group level along the edge of (and 
# sometimes inside) the brain." https://afni.nimh.nih.gov/sscc/gangc/MEMA.html
#
# -> Individual brain masks were dilated

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### DIRECTORIES

glm_path=$mri_path/ID$ID/glm

### MOTION DATA

# FOR ALL EPIs
mc_enorm_all=$glm_path/mc_enorm_all.1D

mc_censor_all=$glm_path/mc_censor_all.1D

mc_censor_all_TRnum=$glm_path/mc_censor_all_TRnum.1D

# FOR 'VALID' EPIs
mc_enorm_valid=$glm_path/mc_enorm_valid.1D

mc_censor_valid=$glm_path/mc_censor_valid.1D

mc_censor_valid_TRnum=$glm_path/mc_censor_valid_TRnum.1D

### NUISANCE REGRESSORS (incl. motion parameters & derivatives, mc_par_deriv*)
nuisance_reg_all=$glm_path/nuisance_reg_all.1D

nuisance_reg_valid=$glm_path/nuisance_reg_valid.1D

# ================================================================================
# EPIs
# --------------------------------------------------------------------------------

### ALL EPIs

epi_all=($epi_path_wo_bnum/$epi_file_wildcard)

### "VALID" EPIs

if [ -f "$valid_blocks_txt" ]; then

	# Get valid blocks (see "onset_t.R")
	read -a valid_blocks -d '\t' < $valid_blocks_txt

	# Get valid EPI files
	epi_valid=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$epi_file_wildcard; done))

fi

# ================================================================================
# MOTION DATA
# --------------------------------------------------------------------------------

### FOR ALL EPIs

# Motion files (euclidian norm)
mc_enorm_all_files=(${epi_path_wo_bnum}/$mc_enorm_wildcard)

cat ${mc_enorm_all_files[@]} > $mc_enorm_all

# Motion censor files
mc_censor_all_files=(${epi_path_wo_bnum}/$mc_censor_wildcard)

cat ${mc_censor_all_files[@]} > $mc_censor_all

# Number of censored TR
3dTstat -zcount -prefix stdout: $mc_censor_all\' > $mc_censor_all_TRnum

### FOR "VALID" EPIs

if [ -f "$valid_blocks_txt" ]; then

	# Valid blocks (see "onset_t.R")
	read -a valid_blocks -d '\t' < $valid_blocks_txt

	# Motion files (euclidian norm) of valid EPIs
	mc_enorm_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$mc_enorm_wildcard; done))

	cat ${mc_enorm_valid_files[@]} > $mc_enorm_valid

	# Motion censor files of valid EPIs
	mc_censor_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$mc_censor_wildcard; done))

	cat ${mc_censor_valid_files[@]} > $mc_censor_valid

	# Number of censored TR
	3dTstat -zcount -prefix stdout: $mc_censor_valid\' > $mc_censor_valid_TRnum

fi

# ================================================================================
# NUISANCE REGRESSORS
# --------------------------------------------------------------------------------

### FOR ALL EPIs

# Nuisance regressors of valid EPIs
nuisance_reg_all_files=(${epi_path_wo_bnum}/$nuisance_reg_wildcard)

cat ${nuisance_reg_all_files[@]} > $nuisance_reg_all

### FOR "VALID" EPIs

if [ -f "$valid_blocks_txt" ]; then

	# Valid blocks (see "onset_t.R")
	read -a valid_blocks -d '\t' < $valid_blocks_txt

	# Nuisance regressors of valid EPIs
	nuisance_reg_valid_files=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$nuisance_reg_wildcard; done))

	cat ${nuisance_reg_valid_files[@]} > $nuisance_reg_valid

fi

# ================================================================================
# CREATE BASELINE MODEL
# --------------------------------------------------------------------------------

function create_base_model {

	block_num=${1}
	pnum=${2} 		# degree of polynomial (3dDeconvolve -polort)

	base_factor=$(bc <<< "scale=3; 1 / $block_num")

	for ((i=0; i<$block_num; i++)); do

		base_model[$i]='+0'"$base_factor"'*Ort['"$(($i * ($pnum+1)))"']'
		# http://www.personal.reading.ac.uk/~sxs07itj/web/AFNI_GLM_SS.html

	done

	echo ${base_model[@]}
}

base_model_all=$(create_base_model ${#epi_all[@]} $pnum)

if [ -f "$valid_blocks_txt" ]; then

	base_model_valid=$(create_base_model ${#epi_valid[@]} $pnum)
fi


# ================================================================================
# RUN GLMs
# --------------------------------------------------------------------------------

for glm_model in ${glm_models[@]}; do

	printf "\nRUN GLM: ID%s %s\n\n" "$ID" "$glm_model"

	case $glm_model in

	stim_conf)

		# 1 regressor for each stimulus condition (near splitted by confidence) (CR_conf, miss_conf, miss_unconf, hit_unconf, hit_conf, supra_hit_conf)
		# 1 regressor for each response onset (resp1, resp2)

		if [ -f "$valid_blocks_txt" ]; then

		mkdir $glm_path/$glm_model

		3dDeconvolve -force_TR $TR \
					 -input ${epi_valid[@]} \
					 -jobs $CPUs \
					 -mask $epi_brain_mask \
					 -censor $mc_censor_valid \
					 -polort $pnum \
					 -local_times \
					 -num_stimts 8 \
					 -stim_times 1 $onsets_path/${ID}_CR_conf_t_shift${onset_shift}.1D $resp_model -stim_label 1 CR_conf \
					 -stim_times 2 $onsets_path/${ID}_near_miss_conf_t_shift${onset_shift}.1D $resp_model -stim_label 2 near_miss_conf \
					 -stim_times 3 $onsets_path/${ID}_near_miss_unconf_t_shift${onset_shift}.1D $resp_model -stim_label 3 near_miss_unconf \
					 -stim_times 4 $onsets_path/${ID}_near_hit_unconf_t_shift${onset_shift}.1D $resp_model -stim_label 4 near_hit_unconf \
					 -stim_times 5 $onsets_path/${ID}_near_hit_conf_t_shift${onset_shift}.1D $resp_model -stim_label 5 near_hit_conf \
					 -stim_times 6 $onsets_path/${ID}_supra_hit_conf_t_shift${onset_shift}.1D $resp_model -stim_label 6 supra_hit_conf \
					 -stim_times 7 $onsets_path/${ID}_resp1_t_shift${onset_shift}.1D $resp_model -stim_label 7 resp1 \
					 -stim_times 8 $onsets_path/${ID}_resp2_t_shift${onset_shift}.1D $resp_model -stim_label 8 resp2 \
					 -ortvec $nuisance_reg_valid nuisance_reg \
					 -num_glt 17 \
					 -gltsym 'SYM: near_hit_conf -near_miss_conf' -glt_label 1 near_hit_conf-near_miss_conf \
					 -gltsym 'SYM: supra_hit_conf -near_hit_conf' -glt_label 2 supra_hit_conf-near_hit_conf \
					 -gltsym 'SYM: near_hit_conf -near_hit_unconf' -glt_label 3 near_hit_conf-near_hit_unconf \
					 -gltsym 'SYM: near_hit_unconf -near_miss_unconf' -glt_label 4 near_hit_unconf-near_miss_unconf \
					 -gltsym 'SYM: near_miss_unconf -near_miss_conf' -glt_label 5 near_miss_unconf-near_miss_conf \
					 -gltsym 'SYM: supra_hit_conf -CR_conf' -glt_label 6 supra_hit_conf-CR_conf \
					 -gltsym 'SYM: near_hit_conf -CR_conf' -glt_label 7 near_hit_conf-CR_conf \
					 -gltsym 'SYM: near_hit_unconf -CR_conf' -glt_label 8 near_hit_unconf-CR_conf \
					 -gltsym 'SYM: near_miss_unconf -CR_conf' -glt_label 9 near_miss_unconf-CR_conf \
					 -gltsym 'SYM: near_miss_conf -CR_conf' -glt_label 10 near_miss_conf-CR_conf \
					 -gltsym 'SYM: 0.25*near_hit_conf +0.25*near_hit_unconf +0.25*near_miss_unconf +0.25*near_miss_conf' -glt_label 11 near_mean \
					 -gltsym 'SYM: 0.5*near_hit_conf +0.5*near_hit_unconf -0.5*near_miss_unconf -0.5*near_miss_conf' -glt_label 12 near_hit_mean-near_miss_mean \
					 -gltsym 'SYM: 0.5*near_hit_conf +0.5*near_miss_conf -0.5*near_hit_unconf -0.5*near_miss_unconf' -glt_label 13 near_conf_mean-near_unconf_mean \
					 -gltsym 'SYM: 0.2*near_hit_conf +0.2*near_hit_unconf +0.2*near_miss_unconf +0.2*near_miss_conf +0.2*supra_hit_conf' -glt_label 14 stim_mean \
					 -gltsym 'SYM: 0.2*near_hit_conf +0.2*near_hit_unconf +0.2*near_miss_unconf +0.2*near_miss_conf +0.2*supra_hit_conf -CR_conf' -glt_label 15 stim_mean-CR_conf \
					 -gltsym 'SYM: 0.5*resp1 +0.5*resp2' -glt_label 16 resp_mean \
					 -gltsym 'SYM: '"$base_model_valid"'' -glt_label 17 baseline \
					 -x1D $glm_path/$glm_model/${ID}_glm.xmat.1D \
					 -x1D_stop


		# Model Serial Correlations in the Residuals

		3dREMLfit -input "`echo ${epi_valid[@]}`" \
				  -mask $epi_brain_mask \
				  -matrix $glm_path/$glm_model/${ID}_glm.xmat.1D \
				  -rout -fout -tout \
				  -Rbuck $glm_path/$glm_model/${ID}_glm_REML.nii.gz \
				  -Rerrts $glm_path/$glm_model/${ID}_glm_errts_REML.nii.gz \
				  -Rvar $glm_path/$glm_model/${ID}_glm_REMLvar.nii.gz \
				  -Obuck $glm_path/$glm_model/${ID}_glm_OLSQ.nii.gz

		fi

	;;

	stim_conf_TENT)

		# 1 regressor for each stimulus condition (near splitted by confidence) (CR_conf, miss_conf, miss_unconf, hit_unconf, hit_conf, supra_hit_conf)

		if [ -f "$valid_blocks_txt" ]; then

		mkdir $glm_path/$glm_model

		3dDeconvolve -force_TR $TR \
					 -input ${epi_valid[@]} \
					 -jobs $CPUs \
					 -mask $epi_brain_mask \
					 -censor $mc_censor_valid \
					 -polort $pnum \
					 -local_times \
					 -num_stimts 6 \
					 -stim_times 1 $onsets_path/${ID}_CR_conf_t_shift${onset_shift}.1D $resp_model -stim_label 1 CR_conf \
					 -stim_times 2 $onsets_path/${ID}_near_miss_conf_t_shift${onset_shift}.1D $resp_model -stim_label 2 near_miss_conf \
					 -stim_times 3 $onsets_path/${ID}_near_miss_unconf_t_shift${onset_shift}.1D $resp_model -stim_label 3 near_miss_unconf \
					 -stim_times 4 $onsets_path/${ID}_near_hit_unconf_t_shift${onset_shift}.1D $resp_model -stim_label 4 near_hit_unconf \
					 -stim_times 5 $onsets_path/${ID}_near_hit_conf_t_shift${onset_shift}.1D $resp_model -stim_label 5 near_hit_conf \
					 -stim_times 6 $onsets_path/${ID}_supra_hit_conf_t_shift${onset_shift}.1D $resp_model -stim_label 6 supra_hit_conf \
					 -ortvec $nuisance_reg_valid nuisance_reg \
					 -num_glt 9 \
					 -gltsym 'SYM: near_hit_conf[4..13] -near_miss_conf[4..13]' -glt_label 1 near_hit_conf-near_miss_conf \
					 -gltsym 'SYM: supra_hit_conf[4..13] -near_hit_conf[4..13]' -glt_label 2 supra_hit_conf-near_hit_conf \
					 -gltsym 'SYM: supra_hit_conf[4..13] -CR_conf[4..13]' -glt_label 3 supra_hit_conf-CR_conf \
					 -gltsym 'SYM: near_hit_conf[4..13] -CR_conf[4..13]' -glt_label 4 near_hit_conf-CR_conf \
					 -gltsym 'SYM: near_miss_conf[4..13] -CR_conf[4..13]' -glt_label 5 near_miss_conf-CR_conf \
					 -gltsym 'SYM: 0.5*near_hit_conf[4..13] +0.5*near_miss_conf[4..13]' -glt_label 6 near_conf_mean \
					 -gltsym 'SYM: 0.5*near_hit_conf[4..13] +0.5*near_miss_conf[4..13] -CR_conf[4..13]' -glt_label 7 near_conf_mean \
					 -gltsym 'SYM: 0.2*near_hit_conf[4..13] +0.2*near_hit_unconf[4..13] +0.2*near_miss_unconf[4..13] +0.2*near_miss_conf[4..13] +0.2*supra_hit_conf[4..13]' -glt_label 8 stim_mean \
					 -gltsym 'SYM: 0.2*near_hit_conf[4..13] +0.2*near_hit_unconf[4..13] +0.2*near_miss_unconf[4..13] +0.2*near_miss_conf[4..13] +0.2*supra_hit_conf[4..13] -CR_conf[4..13]' -glt_label 9 stim_mean-CR_conf \
					 -x1D $glm_path/$glm_model/${ID}_glm.xmat.1D \
					 -x1D_stop

# Pre-stimulus TENTs: [0..3]
# Post-stimulus TENTs: [4..13]
# Excluded response/button onsets, because I want to model the pre-stimulus time that would overlap with these regressors:
#					 -stim_times 7 $onsets_path/${ID}_resp1_t_shift${onset_shift}.1D $resp_model -stim_label 7 resp1 \
#					 -stim_times 8 $onsets_path/${ID}_resp2_t_shift${onset_shift}.1D $resp_model -stim_label 8 resp2 \



		# Model Serial Correlations in the Residuals

		3dREMLfit -input "`echo ${epi_valid[@]}`" \
				  -mask $epi_brain_mask \
				  -matrix $glm_path/$glm_model/${ID}_glm.xmat.1D \
				  -rout -fout -tout \
				  -Rbuck $glm_path/$glm_model/${ID}_glm_REML.nii.gz


		fi

	;;





	esac

done # LOOP - GLM MODELS

