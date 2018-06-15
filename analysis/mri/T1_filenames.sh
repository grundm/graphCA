#!/bin/bash
# Get T1 file names

########################################
### SETTINGS ###########################
########################################

ID_base=ID
ID_min=01
ID_max=47

T1_wildcards=(*_mprage_* *_MPRAGE_* *_mpr_*)
#T1_wildcards=(*mp2rage*)

output_file=mprage.txt
#output_file=mp2rage.txt

### DIRECTORIES

mri_path=/nobackup/curie2/mgrund/GraphCA/mri

bdb_path=/afs/cbs.mpg.de/probands/bdb

########################################
### GET FILENAMES FROM DATABASE ########
########################################

# Redirect stdout & stderr to output file
exec > $mri_path/$output_file 2>&1

# Loop IDs
for ID in $(eval echo "{$ID_min..$ID_max}"); do

    ID_path=$mri_path/$ID_base$ID

    if [ -d "$ID_path" ]; then

		# Get participant's database ID

		mri_dir_tmp=`basename $(ls -d $ID_path/*PRISMA)`

		bdb_ID=$(echo ${mri_dir_tmp#../} | cut -d_ -f1)		

		printf "\n### ID%s %s ###\n\n" "$ID" "$bdb_ID"

		# Get files corresponding to wildcard

		for wildcard in ${T1_wildcards[@]}; do			

			echo $wildcard
			ls $bdb_path/$bdb_ID/$wildcard

		done
        
    fi
done
