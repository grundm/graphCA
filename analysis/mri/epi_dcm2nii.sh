#!/bin/bash
# epi_dcm2nii.sh $ID_min $ID_max

# DICOM to NIfTI conversion

# Input
ID_min=${1}
ID_max=${2}

mri_dir=/nobackup/curie2/mgrund/GraphCA/mri
dicom_dir=*.PRISMA/DICOM
nii_dir=nii
ID_base=ID

epi_dir=epi
epi_base_org=cmrrmbep2dboldmb3fkts


for ID in $(eval echo "{$ID_min..$ID_max}"); do  

    ID_path=$mri_dir/$ID_base$ID

    if [ -d "$ID_path" ]; then
        echo $ID

		# Make NIfTI directory
        nii_path=$ID_path/$nii_dir
        mkdir $nii_path

		# Convert DICOM directory to NIfTI files
        dcm2nii -d N -o $nii_path $ID_path/$dicom_dir

		# Rename epi files and move to extra directory

		mkdir $nii_path/$epi_dir

        j=0
        for i in $nii_path/$epi_base_org*
        do
            (( j++ ))       
            mv $i $nii_path/$epi_dir/epi_$ID\_0$j.nii.gz
        done                
		
    fi
done
