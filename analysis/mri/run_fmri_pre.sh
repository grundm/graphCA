#!/bin/bash
# run_fmri_pre.sh $ID

# Input variable
ID=${1}

mri_path=/data/pt_nro150/mri
epi_path=${mri_path}/ID$ID/nii/epi

code_path=/data/pt_nro150/graphca/mri

for epi_file in $epi_path/epi*.nii.gz; do

	$code_path/fmri_pre.sh $ID $epi_file &

done
