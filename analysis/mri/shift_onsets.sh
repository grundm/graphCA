#!/bin/bash
# shift_onsets.sh $ID
#
# Script to account for offset in timing files due to removing initial TRs

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

shift=-7.5

### DIRECTORIES
mri_path=/data/pt_nro150/mri

onsets_path=$mri_path/ID$ID/onsets/new3

### FILES
valid_blocks_file=${ID}_valid_blocks.1D

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

shifted_onsets_path=$onsets_path/shift${shift}

onsets_shift_suffix=_shift${shift}.1D

# ================================================================================
# OFFSET ONSET DATA
# --------------------------------------------------------------------------------

mkdir $shifted_onsets_path

for onset_file in $onsets_path/*.1D; do

	if [ "`basename $onset_file`" != "$valid_blocks_file" ]; then
		
		timing_tool.py -timing $onset_file \
					   -add_offset $shift \
					   -write_timing $shifted_onsets_path/`basename $onset_file .1D`${onsets_shift_suffix}
	else

		echo $onset_file
		cp $onset_file $shifted_onsets_path

	fi

done
