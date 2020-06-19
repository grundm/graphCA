#!/bin/bash
# Get T1 scan properties
#
# Author: Martin Grund
# Last update: June 19, 2020

# ================================================================================
# SETINGS
# --------------------------------------------------------------------------------

prop_tags=(ManufacturersModelName \
			ReceiveCoilName \
			RepetitionTime \
			EchoTime \
			InversionTime \		   
			FlipAngle \
			PixelBandwidth \
			ProtocolName)


# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

# mriqc path
prop_path=/data/pt_nro150/BIDS/clean-output/derivatives/mriqc

# Property file wildcard
prop_file_wildcard=sub-*/anat/sub-*_T1w.json

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

output_dir=/data/pt_nro150/mri

output_file=mprage_properties.txt # EDIT #
#output_file=mp2rage.txt

# ================================================================================
# GET PROPERTIES
# --------------------------------------------------------------------------------

prop_files=($prop_path/$prop_file_wildcard)

for f in ${prop_files[@]}; do

	#echo `basename $f`

	props=(`basename $f`)

	for p in ${prop_tags[@]}; do
		#cat $f | jq '.bids_meta.EchoTime'
		props+=($(cat $f | jq '.bids_meta.'$p''))
	done

	echo ${props[@]}

	echo ${props[@]} >> $output_dir/$output_file

done
