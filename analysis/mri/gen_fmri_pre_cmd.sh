#!/bin/bash
# gen_fmri_pre_cmd.sh $ID

ID=${1}

ID_path=/nobackup/curie2/mgrund/GraphCA/mri/ID${ID}
epis=($ID_path/nii/epi/epi_01_01.nii.gz)

# If I submit multiple runs, I can only use one $slice_t_file, or?
slice_t_file=($ID_path/nii/epi/slice_t/epi_*_slice_t.txt)

afni_proc.py -subj_id $ID \
			 -blocks despike tshift align tlrc volreg mask blur scale regress \
			 -copy_anat $ID_path/T1/anat.nii.gz \
			 -anat_follower_ROI aaseg anat aparc.a2009s+aseg.nii \
			 -anat_follower_ROI aeseg epi  aparc.a2009s+aseg.nii \
			 -anat_follower_ROI FSvent epi FT_vent.nii \
			 -anat_follower_ROI FSWe epi FT_white.nii \
			 -anat_follower_erode FSvent FSWe \
			 -dsets ${epis[@]} \
			 -tcat_remove_first_trs 10 \
			 -tshift_align_to -tzero 0 \
			 -tshift_interp -Fourier \
			 -tshift_opts_ts -TR 750 -tpattern @${slice_t_file[@]} \
			 -tlrc_base MNI152_T1_2009c+tlrc \
			 -tlrc_NL_warp \
			 -volreg_align_to MIN_OUTLIER \
			 -volreg_align_e2a \
			 -volreg_tlrc_warp \
			 -blur_filter -1blur_fwhm \
			 -blur_size 6 \
			 -regress_ROI_PC_per_run FSevent 5 \
			 -regress_make_corr_vols aeseg FSvent \
			 -regress_anaticor_fast \
			 -regress_anaticor_fwhm 30 \
			 -regress_anaticor_label FSWe \
			 -regress_censor_motion 0.2 \
			 -regress_censor_outliers 0.1 \
			 -regress_bandpass 0.01 0.1 \
			 -regress_apply_mot_types demean deriv \
			 -regress_est_blur_epits \
			 -regress_est_blur_errts \
			 -regress_run_clustsim no

# BLIP option?
