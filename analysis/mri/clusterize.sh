#!/bin/bash
# clusterize.sh ${glm_models[@]}

# ================================================================================
# SETINGS
# --------------------------------------------------------------------------------

### FILTER CRITERIA

pu=0.005000 	# as written in $clustSim_filename
#pu=1.000e-5 	# 0.00001 uncorrected (per voxel) p-values
p_clust_col=3 	# indicates column (5 -> .01)

# -NN 1  | alpha = Prob(Cluster >= given size)
#  pthr  | .10000 .05000 .02000 .01000

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
glm_models=${1}

### DIRECTORIES
mri_path=/data/pt_nro150/mri
group_path=$mri_path/group

### MONTE CARLO SIMULATION
clustSim_filename=carlo/clustSim.NN1_bisided.1D

# See (https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dClustSim.html):
# bi-sided: where positive values and negative values above the
#           threshold are clustered SEPARATELY (with the 2-sided threshold)


### GROUPTEST FILESs
grouptest_dirname=MEMA
grouptest_file_wildcard=*_MEMA_REML.nii.gz

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

out_dirname=clust.005_k15


# ================================================================================
# FILTER FOR CLUSTER
# --------------------------------------------------------------------------------

# Loop GLMs
for glm_model in ${glm_models[@]}; do

	group_glm_path=$group_path/$glm_model

	grouptest_files=($group_glm_path/$grouptest_dirname/$grouptest_file_wildcard)

	# Create clustering directory
	out_dir=$group_glm_path/$out_dirname

	mkdir $out_dir

	# Loop grouptests
	for grouptest_file in ${grouptest_files[@]}; do

		grouptest_label=`basename ${grouptest_file%$grouptest_file_wildcard}`

		printf "\nCLUSTERING: GLM - %s (%s) \n\n" "$glm_model" "$grouptest_file"

		output_prefix=$out_dir/$grouptest_label\_clust

		
		# GET T-VALUE & CLUSTER SIZE FOR GIVEN P-VALUE
		
		# Get degree of freedom (last number of output)
		brick_stats=($(3dAttribute BRICK_STATAUX $grouptest_file))

		df=${brick_stats[${#brick_stats[@]}-1]}

		# Get t-value
		t_value_str=$(cdf -p2t fitt $pu $df)
		t_value=${t_value_str#*=}

		# Search for line with specified p-value and take last (5th) value for 0.01 alpha = Prob(Cluster >= given size)
		clust_sizes=($(grep $pu $group_glm_path/$clustSim_filename))
		
		clust_size=${clust_sizes[$p_clust_col-1]}
		clust_size=15
		printf "t-value >= %s; cluster size >= %s \n\n" "$t_value" "$clust_size"

		# FILTER T-TEST DATA

# 3dclust -1Dformat -nosum -1dindex 1 -1tindex 1 -2thresh -3.153 3.153 -dxyz=1 1.01 49 /data/pt_nro150/mri/group/stim_conf_NEW12/MEMA/near_hit_conf-near_miss_conf_0_MEMA_REML.nii.gz


		3dclust -1thresh $t_value \
				-1dindex 1 \
				-1tindex 1 \
				-dxyz=1 \
				-orient LPI \
				-prefix $output_prefix.nii.gz \
				-savemask $output_prefix\_order.nii.gz \
				1.01 \
				$clust_size \
				$grouptest_file \
				> $output_prefix\_table.1D

		# Interactive cluster report
		# 3dclust -1Dformat -nosum -1dindex 1 -1tindex 1 -2thresh -5.511 5.511 -dxyz=1 1.01 11 /nobackup/curie2/mgrund/GraphCA/mri/group/stim_resp3/MEMA/null_MEMA_REML.nii.gz

	done # Loop - Grouptests

done # Loop - GLMs
