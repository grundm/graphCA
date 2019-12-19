#!/bin/bash
# grouptest.sh
#
# Start AFNI & R before

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

### GLM MODELS
glm_models=(all_cond2)

#CPUs=$(( $(nproc) - 1))
CPUs=60 # EDIT #

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### GLM LABELS

glm_label=REML
#glm_label=OLSQ
glm_file_suffix=*_glm_$glm_label.nii.gz
#glm_file_suffix=*_gppi_$glm_label.nii.gz # EDIT #

coef_brick_wildcard=Coef
coef_brick_anticard=baseline

tstat_label=_Tstat
# If TENT: number x codes steps in "#x_Tstat"

### DIRECTORIES

#mri_path=/nobackup/curie2/mgrund/GraphCA/mri
mri_path=/data/pt_nro150/mri

glm_paths=$mri_path/ID*/glm # EDIT #
#glm_paths=$mri_path/ID*/gppi/gppi_cS1_NEW12/glm_SPM

### BRAIN MASK

# Brain mask file relative to GLM path
epi_brain_mask_rel2glm=../../T1_2018/MNI_bmask_epi_d.nii.gz # EDIT #  - GLM
#epi_brain_mask_rel2glm=../../../../T1/MNI_bmask_epi_d.nii.gz #  - gPPI


### MODEL R^2

full_label_str=Full
R2_label_suffix=_R^2

R2_available=FALSE # use "TRUE" if it should work

### COVARIATES

cov_file=$mri_path/group/cov_file.txt
cov_file_ttest=$mri_path/group/cov_file_ttest.txt
# 2 files because 3dttest++ is looking for different subj IDs with *_glm_REML

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### DIRECTORIES

group_path=$mri_path/group
#group_path=$mri_path/group/gppi_cS1_NEW12/glm_SPM # EDIT #

out_dirname_ttest=ttest2 # EDIT #
#out_dirname_ttest=ttest_2nd_half

out_dirname_MEMA=MEMA2 # EDIT #
out_dirname_MEMA_cmd=cmd
out_dirname_R2=R2


### BRAIN MASK

group_mask_filename=banat_norm_epi_groupmask.nii.gz

### MODEL R²

R2_mean_suffix=_R2_mean_$glm_label.nii.gz

### GROUP TESTS

out_file_suffix_ttest=_ttest_$glm_label.nii.gz

suffix_ttest_clustsim=_ttest_${glm_label}_clustsim
out_file_suffix_ttest_clustsim=_ttest_${glm_label}_clustsim.nii.gz
out_file_suffix_ttest_resid=_ttest_${glm_label}_resid.nii.gz

cmd_suffix_MEMA=_3dMEMA_${glm_label}_cmd.sh
out_file_suffix_MEMA=_MEMA_$glm_label.nii.gz


# ================================================================================
# GROUP MASK
# --------------------------------------------------------------------------------

mkdir -p $group_path

#if [ ! -f $group_mask ]; then
#
#	# Combine all dilated normalized brain mask
#	3dmask_tool -input ${epi_brain_masks[@]} \
#				-prefix $group_mask
#fi


# ================================================================================
# TEST GLMs
# --------------------------------------------------------------------------------

# Loop GLM models
for glm_model in ${glm_models[@]}; do

	# Create output directory
	out_dir_ttest=$group_path/$glm_model/$out_dirname_ttest

	mkdir -p $out_dir_ttest

	out_dir_MEMA=$group_path/$glm_model/$out_dirname_MEMA

	out_dir_MEMA_cmd=$out_dir_MEMA/$out_dirname_MEMA_cmd

	mkdir -p $out_dir_MEMA_cmd

	if [ "$R2_available" = "TRUE" ]; then

		out_dir_R2=$group_path/$glm_model/$out_dirname_R2

		mkdir -p $out_dir_R2
	fi

	# Combine all dilated normalized brain mask
	epi_brain_masks=(${glm_paths[@]/%//$glm_model/$epi_brain_mask_rel2glm})

	group_mask=$group_path/$glm_model/$group_mask_filename

	3dmask_tool -input ${epi_brain_masks[@]} \
				-prefix $group_mask

	# Get all GLM files of the respective model
	glm_files=($glm_paths/$glm_model/$glm_file_suffix)

	#echo ${glm_files[@]}

	# Average Full Model R²
	if [ "$R2_available" = "TRUE" ]; then
		glm_files_full_R2=(${glm_files[@]/%/[$full_label_str$R2_label_suffix]})

		3dMean -prefix $out_dir_R2/$full_label_str$R2_mean_suffix \
				${glm_files_full_R2[@]}
	fi

	# Create array with GLM labels
	IFS='|' read -ra glm_labels <<< $(3dinfo -label ${glm_files[0]})

	# Loop array with GLM labels and filter for specified wildcard and "anticard"
	coef_labels=($(for i in ${glm_labels[@]}; do echo $i | grep $coef_brick_wildcard | grep -v $coef_brick_anticard; done))


	# Loop GLM labels
	for coef_label in ${coef_labels[@]}; do
		
		# Remove everything from label with "#" onwards
		# (e.g., "stim-null_GLT#0_Coef" -> "stim-null_GLT")
		
		#coef_label_str=${coef_label%#*}
		# Deletes shortest match of substring ('_*') from back of string $coef_label
		# Keeps information about basis tent position
		coef_label_str=${coef_label%_*}
		coef_label_str=${coef_label_str/'#'/_} # 3dMEMA seems to be not able to handle


		printf "\nGROUPTEST GLM: %s [%s]\n\n" "$glm_model" "$coef_label"

		# Appand file names by GLM label
		glm_files_coef=(${glm_files[@]/%/[$coef_label]})

		echo $coef_label
#		printf "%s \n" ${glm_files_coef[@]}

		# Average Regressor R²
		if [ "$R2_available" = "TRUE" ]; then

			glm_files_coef_R2=(${glm_files[@]/%/[${coef_label%#*}$R2_label_suffix]})

			3dMean -prefix $out_dir_R2/$coef_label_str$R2_mean_suffix \
					${glm_files_coef_R2[@]}

		fi

		########################################
		### T-TEST #############################
		########################################

		ttest_file=$out_dir_ttest/$coef_label_str$out_file_suffix_ttest

		# Run t-test
		3dttest++ -dupe_ok \
				  -setA ${glm_files_coef[@]} \
				  -mask $group_mask \
				  -prefix $ttest_file \
				  -Clustsim \
	 			  -prefix_clustsim $coef_label_str$suffix_ttest_clustsim \
				  -covariates $cov_file_ttest \
				  -tempdir $out_dir_ttest

		mv $coef_label_str$suffix_ttest_clustsim* $out_dir_ttest

		########################################
		### MEMA ###############################
		########################################

		MEMA_cmd_file=$out_dir_MEMA_cmd/$coef_label_str$cmd_suffix_MEMA

		MEMA_file=$out_dir_MEMA/$coef_label_str$out_file_suffix_MEMA

		gen_group_command.py -command 3dMEMA \
							 -dsets ${glm_files[@]} \
							 -set_labels $coef_label_str \
							 -subs_betas $coef_label \
							 -subs_tstats ${coef_label%_*}$tstat_label \
							 -options \
								-mask $group_mask \
							 	-jobs $CPUs \
								-missing_data 0 \
								-model_outliers \
								-residual_Z \
							    -covariates $cov_file \
							    -covariates_center mean \
							    -covariates_model center=different slope=different \
							 -prefix $MEMA_file \
							 -write_script $MEMA_cmd_file

		# Removing "-missing_data 0" only creates significant voxels 
		# along the skull outside the brain, but does not change clusters inside the brain
		#
		# see 3dMEMA -help for details
		#
		# -max_zeros MM [...] The default value is 0 (no missing values allowed).
		# -missing_data 0: With this format the zero value at a voxel of each subject will be interpreted as missing data.
		#
		# Since with removed "-missing_data 0" it still showed a value for each value within the brain.
		# There are no missing data and zeros.

		# Requires R 'snow' package
		# R+
		# install.packages("snow")
		csh $MEMA_cmd_file

#		3drefit -addFDR -FDRmask $group_mask $MEMA_file

	done # loop - GLM labels

done # loop - GLMs
