#!/bin/bash
# get_slictime.sh reads the DICOM header to get slice timing data and prints it to a single-column text file.
# Additionally, it prints the slice acquisitions times as fractions of the TR in another text file.
#
# Since some EPI runs were stopped or failed, there is some editing necessary that I documented in "ID*/nii/epi/slice_t_README.md".
#
# Author: Martin Grund <mgrund@cbs.mpg.de>

# SETTINGS
mri_path=/scr/curie3/mgrund/GraphCA/mri
slice_t_dir=nii/epi/slice_t

epi_run_label=cmrr_mbep2d_bold_mb3_fkt

TR=750 # in ms
vol_num=1120

# Loop DICOM paths
for dicom_path in $mri_path/ID*/*PRISMA/DICOM; do

	# Get current ID
	ID=${dicom_path:$(( `expr index $dicom_path ID` + 1 )):2}

	echo $ID
	
	# Slice timing directory
	slice_t_path=$mri_path/ID$ID/$slice_t_dir

	mkdir $slice_t_path

	# Get EPI run IDs from Scans.txt
	epi_run_IDs=($(grep -E $epi_run_label $dicom_path/../Scans.txt | cut -d' ' -f1))

	i=1

	# Loop EPI runs
	for epi_run in ${epi_run_IDs[@]}; do

		echo $epi_run

		# Read slice timing from DICOM header in first DICOM file
		# Select everything after "-- Siemens timing (36 entries): "
		slice_t=($(dicom_hdr -slice_times $dicom_path/$epi_run\0001 | cut -d':' -f2))

		# Write into file
		printf "%s\n" "${slice_t[@]}" > $slice_t_path/epi_$ID\_0$i\_slice_t.txt

		# Prepare slice timing file for FSL slicetimer

		# --tcustom	filename of single-column slice timings, in fractions of TR, +ve values shift slices forwards in time.
		# mapfile -t slice_t < $slice_t_file

		for (( j=0; j < ${#slice_t[@]}; j++)); do 
			slice_t_TR[j]=$(echo "${slice_t[j]} / $TR" | bc -l)
		done

		printf "%s\n" "${slice_t_TR[@]}" > $slice_t_path/epi_$ID\_0$i\_slice_t_TR.txt

		dicom_vol=($(ls $dicom_path/$epi_run*))

		if (( ${#dicom_vol[@]} < $vol_num )); then

			mkdir $slice_t_path/aborted

			mv $slice_t_path/epi_$ID\_0$i* $slice_t_path/aborted/
		fi

		(( i++ ))

	done # loop EPI runs

done # loop DICOM paths (participants)

