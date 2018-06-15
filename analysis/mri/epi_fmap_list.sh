#!/bin/bash

mri_path=/scr/curie3/mgrund/GraphCA/mri

for ID in $mri_path/ID*/; do

	for epi in $ID\nii/epi/*.nii.gz; do
			echo $(echo $epi | xargs -n 1 basename) $(ls $ID\nii/fmap* | xargs -n 1 basename) >> $mri_path/epi_fmap_list.txt
	done
done
