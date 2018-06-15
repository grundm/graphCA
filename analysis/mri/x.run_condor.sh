#!/bin/bash
# ./x.run_condor.sh $script $ID_min $ID_max $cluster

# to run:
# AFNI
# FSL
# ./x.run_condor.sh run_fmri_pre.sh 01 01 local

# Input variables
script=${1}
ID_min=${2}
ID_max=${3}
cluster=${4} # allows to run script with and without condor (local & global)

########################################
### SETTINGS ###########################
########################################

condor_file_prefix=condor

### DIRECTORIES

#hard_drive=/nobackup/curie2
#hard_drive=/data/t_condortemp

code_dir=/data/pt_nro150/graphca/mri

data_dir=/data/pt_nro150/mri # check for existing ID

out_path=$data_dir
#out_path=/data/t_condortemp/mgrund/GraphCA/mri # for condor output

condor_dir=$out_path/condor

# Create condor directory
#rm -rf $local_dir/condor
mkdir -p $condor_dir


for ID in $(eval echo "{$ID_min..$ID_max}"); do

	# Only pursue if ID directory exists, formerly: "onsets" directory indicating enough valid blocks (see behav.R & onset_t.R)
	if [ -d "$data_dir/ID${ID}" ]; then

		printf "\n${script}: ID%s\n\n" "$ID"		

		case $cluster in

		condor)

			# Create condor file name with $ID and $script name
			condor_file=$condor_dir/${condor_file_prefix}_${ID}_${script//.sh}

			# Delete all such files
			rm -f $condor_file*

			# Create condor file
			echo "executable = ${code_dir}/${script}"		>> $condor_file
			echo "arguments = ${ID}"						>> $condor_file
			echo "universe = vanilla"						>> $condor_file
			echo "output = ${condor_file}.out"    			>> $condor_file
			echo "error = ${condor_file}.error"   			>> $condor_file
			echo "log = ${condor_file}.log"					>> $condor_file
			echo "request_memory = 2000"					>> $condor_file
			echo "request_cpus = 1"							>> $condor_file
			echo "getenv = True"							>> $condor_file
			echo "notification = Error"						>> $condor_file
			echo "queue"									>> $condor_file
			echo ""											>> $condor_file

			# Submit condor file
			condor_submit $condor_file

			# Set rights for condor directory and all files
			# DOES NOT WORK AS SUPPOSED TO
			# chmod -R 777 $condor_dir

		;;

		local)

			$code_dir/$script $ID

		;;

		parallel)

			$code_dir/$script $ID &

		;;

		esac

	fi # if - ID directory existence

done # 1st loop - participants
