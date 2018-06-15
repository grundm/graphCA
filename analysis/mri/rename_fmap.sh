#!/bin/bash

# Rename fieldmap files

fmap_base_org=grefieldmap32s

fmap_base_phase=fmap_phase_
fmap_base_magnitude=fmap_mag_

mri_path=/SCR2/mgrund/GraphCA/mri/
nii_dir=nii/

ID_base=ID
ID_min=43
ID_max=43

for ID in $(eval echo "{$ID_min..$ID_max}"); do

    nii_path=$mri_path$ID_base$ID/$nii_dir
    echo $ID

    if [ -d "$nii_path" ] # actually not necessary
    then
        fmap_phase_counter=0
        fmap_mag_counter=0

        for i in $nii_path$fmap_base_org*; do
	    # fieldmap NIfTIs can be distinguished based on the number of volumes
	    # 2 volumes indicate magnitude fieldmap, 1 volume indicate phase fieldmap
            dim4=`fslval $i dim4`
            if [ "$dim4" -eq "1" ]; then
                    (( fmap_phase_counter++ ))
                    mv $i $nii_path$fmap_base_phase$ID\_0$fmap_phase_counter.nii.gz
            elif [ "$dim4" -eq "2" ]; then
                    (( fmap_mag_counter++ ))
                    mv $i $nii_path$fmap_base_magnitude$ID\_0$fmap_mag_counter.nii.gz
            fi
        done                
    fi
done
