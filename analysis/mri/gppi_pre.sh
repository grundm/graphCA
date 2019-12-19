#!/bin/bash
# gppi_pre.sh $ID

# AFNI Tutorial: https://afni.nimh.nih.gov/sscc/gangc/CD-CorrAna.html

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

TR=0.750
resp_model='GAM'

block_max=4

### Condition regressor
onset_shift=-7.5 # due to removing 10 initial TRs
#block_t=840
block_t=832.5
min_TR_frac=0.3		# stimulus onset (2.0 s) falls into TR #3 (1.5-2.25) and covers 1/3 of TR
reg_SPM_t=2.00 		# 2.00 ->  4.00 -> 1/3 of TR #6 -> covers 4 TRs (#3-#6)
reg_BIN_t=8			# 2.00 -> 10.00 -> first 3rd of TR #14 -> covers 12 TRs (#3-#14)
#reg_BIN_t=9.10		# 2.00 -> 11.10 -> last 3rd of TR #15 -> covers 13 TRs (#3-#15) -> TOO LONG FOR RESP1 REGRESSORS

# TR	t			time2stim	event			onset_event
# 1		0.00-0.75	-1.25		fix 			0.1
# 2		0.75-1.50	-0.75		cue				1.1
# 3		1.50-2.25	+0.25		stimulus; pause	2.0; 2.1
# 4		2.25-3.00	+1.00		pause			
# 5		3.00-3.75	+1.75		pause			
# 6		3.75-4.50	+2.50		pause
# 7		4.50-5.25	+3.25		pause
# 8		5.25-6.00	+4.00		pause
# 9		6.00-6.75	+4.75		pause
# 10	6.75-7.50	+5.50		pause
# 11	7.50-8.25	+6.25		pause
# 12	8.25-9.00	+7.00		pause
# 13	9.00-9.75	+7.75		pause
# 14	9.75-10.50	+8.50		pause
# 15	10.50-11.25	+9.25		pause; resp1	11.1

# response screen 1 onset (11.1 s) falls into 15th TR (10.50-11.25 s), but covers only 0.2 of TR
#	post_stim_t=9.1 	# stimulus onset locked (0.1 s stimulus onset to pause screen onset + 9.0 s pause screen to response 1 screen)
#						# -> results in 13 TRs: 1.50-11.25

# The -min_frac option may be applied to give a minimum cutoff for the
# fraction of a TR occupied by a stimulus required to label that TR as a
# 1. If not, the default cutoff is 0.3.
#
# https://afni.nimh.nih.gov/pub/dist/doc/program_help/timing_tool.py.html

### HRF
hrf_resp_model=$resp_model
hrf_len=16 # Number of 0.75s TRs that HRF takes from 0 to 0
#hrf_len=28 # in TRs (21s Trial / 0.75s TRs = 28)

### TIME SERIES
#pnum=6 # -polort
# Since we use EPIs after nuisance regression, there is no detrending necessary


# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES
mri_path=/data/pt_nro150/mri

atlas_path=$mri_path/atlas

anat_path=$mri_path/ID$ID/T1_2018

#onsets_path=$mri_path/ID$ID/onsets/new # EDIT #
onsets_path=$mri_path/ID$ID/onsets/new3/shift${onset_shift}

epi_path_wo_bnum=$mri_path/ID$ID/epi_pre_2018/epi_*

### ATLAS
ROI_r=4
atlas=$atlas_path/power_2011_MNI_r${ROI_r}_epi.nii.gz # EDIT #


### EPIs
valid_blocks_txt=$onsets_path/${ID}_valid_blocks.1D

#epi_file_wildcard=norm/epi_*_ns.nii.gz # EDIT #
epi_file_wildcard=denoised/epi_*_denoised.nii.gz

### ONSETS
cond_labels=(CR \
			 near_miss \
			 near_hit \
			 supra_hit)

cond_labels=(CR_conf \
			 near_miss_conf \
			 near_hit_conf \
			 supra_hit_conf)

run_SPM_BIN=FALSE # EDIT # runs if "TRUE"

for j in ${!cond_labels[@]}; do

	cond_onsets[$j]=$onsets_path/${ID}_${cond_labels[$j]}_t_shift${onset_shift}.1D # EDIT #
done

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### DIRECTORIES
#gppi_path=$mri_path/ID$ID/gppi/gppi_cS1_NEW12 # EDIT #
gppi_path=$mri_path/ID$ID/gppi/gppi_power_all_cond2

reg_path=$gppi_path/reg
ts_path=$gppi_path/ts

### HRF

hrf=$gppi_path/gammaHRF.1D

### REGRESSORS

IDEAL_label=_IDEAL

for j in ${!cond_labels[@]}; do

	reg_cond_prefix[j]=$reg_path/reg_${cond_labels[j]}_${ID}
done

### TIME SERIES

ts_prefix_ID=$ts_path/ts_${ID}

ts_mean_suffix=_mean.1D
ts_dt_suffix_wo1D=_dt
ts_dt_t_suffix=_dt_t.1D

ts_deconv_suffix_wo1D=_deconv

SPM_label=_SPM
FSL_label=_FSL
BIN_label=_BIN

for j in ${!cond_labels[@]}; do

	ts_cond_suffix[j]=_${cond_labels[j]}.1D

done

# ================================================================================
# PREPARE gPPI (only for "valid" blocks)
# --------------------------------------------------------------------------------

if [ -f "$valid_blocks_txt" ]; then

printf "\nPREPARE gPPI: ID%s\n\n" "$ID"

mkdir $gppi_path

mkdir $reg_path

mkdir $ts_path

# ================================================================================
# EPIs
# --------------------------------------------------------------------------------

# Get valid blocks (see "onset_t.R")
read -a valid_blocks -d '\t' < $valid_blocks_txt

# Get valid EPI files
epi_valid=($(for block in ${valid_blocks[@]}; do ls ${epi_path_wo_bnum}$block/$epi_file_wildcard; done))


# ================================================================================
# HRF
# --------------------------------------------------------------------------------

3dDeconvolve -nodata $hrf_len $TR \
			 -polort -1 \
			 -force_TR $TR \
			 -global_times \
			 -num_stimts 1 \
			 -stim_times 1 '1D: 0' $hrf_resp_model -stim_label 1 gammaHRF \
			 -x1D $hrf \
			 -x1D_stop


# ================================================================================
# REGRESSORS (Psychological, physiological, & interaction)
# --------------------------------------------------------------------------------

block_i=0

for epi in ${epi_valid[@]}; do

	((block_i++))

	block=${valid_blocks[((block_i - 1))]}

	TR_num=$(3dinfo -nv $epi)

	# LOGIC
	# - We loop over valid blocks "${epi_valid[@]}".
	# - Only valid blocks have a line in the onset files (3 valid blocks -> 3 lined in the onset file).
	# - That is why "$block" (actual block number) does not mirror the corresponding line in the onset file.
	# - Thus there is a second counter variable "$block_i".
	# - If there are no onsets for the particular condition, then there is an asterisk * in the corresponding line.

	# ================================================================================
	# (1) "PSYCHOLOGICAL" REGRESSORS
	# --------------------------------------------------------------------------------

	# SPM approach (McLaren et al., 2012, NeuroImage)
	# + BINARY approach (Cole et al., 2014, Nature Neurosci)
	# --------------------------------------------------------------------------------

	if [ "$run_SPM_BIN" = "TRUE" ]; then

		for j in ${!cond_labels[@]}; do

			# Output file names
			reg_cond_SPM[j]=${reg_cond_prefix[j]}_0${block}${SPM_label}.1D
			reg_cond_BIN[j]=${reg_cond_prefix[j]}_0${block}${BIN_label}.1D

			cond_onsets_t[j]=${reg_cond_prefix[j]}_0${block}_t.1D

			# Since timing_tool.py can't index .1D files' lines with {},
			# we need a workaround (alternative: -per_run_file)
			sed "${block_i}q;d" ${cond_onsets[j]} > ${cond_onsets_t[j]}

			# SPM approach - Create binary "psychological" regressor
			timing_tool.py -timing ${cond_onsets_t[j]} \
				   		   -tr $TR \
						   -min_frac $min_TR_frac \
						   -run_len $block_t \
						   -stim_dur $reg_SPM_t \
				   		   -timing_to_1D ${reg_cond_SPM[j]}

			# Binary approach - Create binary "psychological" regressor
			timing_tool.py -timing ${cond_onsets_t[j]} \
				   		   -tr $TR \
						   -min_frac $min_TR_frac \
						   -run_len $block_t \
						   -stim_dur $reg_BIN_t \
				   		   -timing_to_1D ${reg_cond_BIN[j]}
		done

	fi

	# FSL approach (O'Reilly et al., 2012, SCAN)
	# --------------------------------------------------------------------------------

	for j in ${!cond_labels[@]}; do

		# Output file names
		reg_cond_IDEAL[j]=${reg_cond_prefix[j]}_0${block}${IDEAL_label}.1D

		reg_cond_FSL[j]=${reg_cond_prefix[j]}_0${block}${FSL_label}.1D

		# Signal HRF regressors
		3dDeconvolve -nodata $TR_num $TR \
					 -polort -1 \
					 -force_TR $TR \
					 -local_times \
					 -num_stimts 1 \
					 -stim_times 1 '1D: '"`sed "${block_i}q;d" ${cond_onsets[j]}`"'' $resp_model -stim_label 1 ${cond_labels[j]} \
				     -x1D ${reg_cond_IDEAL[j]} \
					 -x1D_stop

		1dcat ${reg_cond_IDEAL[j]} > ${reg_cond_FSL[j]}
	done

	# ================================================================================
	# OUTPUT FILES
	# --------------------------------------------------------------------------------

	# Section - "Neural" Timeseries
	ts_prefix=${ts_prefix_ID}_0${block}

	ts_mean=${ts_prefix}${ts_mean_suffix}
	ts_dt=${ts_prefix}${ts_dt_suffix_wo1D} 			# detrended mean # w/o '.1D' ending 
	ts_dt_t=${ts_prefix}${ts_dt_t_suffix} 			# detrended mean transposed

	ts_deconv=${ts_prefix}${ts_deconv_suffix_wo1D} 	# w/o '.1D' ending

	for j in ${!cond_labels[@]}; do

	if [ "$run_SPM_BIN" = "TRUE" ]; then

		# Section - Interaction Regressors
		ts_deconv_cond[$j]=${ts_prefix}${ts_deconv_suffix_wo1D}${ts_cond_suffix[$j]} # Masked deconvolved time series

		ts_cond_SPM[$j]=${ts_prefix}${SPM_label}${ts_cond_suffix[$j]} # Convolved with HRF

		# Section - Interaction Regressors (without deconvolution)
		# Binary approach
		ts_cond_BIN[$j]=${ts_prefix}${BIN_label}${ts_cond_suffix[$j]}
	fi				

		# FSL approach		
		ts_cond_FSL[$j]=${ts_prefix}${FSL_label}${ts_cond_suffix[$j]}

	done

	# ================================================================================
	# "NEURAL" TIMESERIES
	# --------------------------------------------------------------------------------

	# Extract average time course for each ROI
	3dNetCorr -inset $epi \
			  -in_rois $atlas \
			  -prefix $ts_prefix \
			  -ts_out

#	# Way to visualize
#	fat_mat_sel.py -m $ts_prefix*.netcc \
#				   -P CC \
#				   -d 300

	# Detrend time course

	# -> wants to have *.1D file?
	# at least it does not work with *.netts or *.3D
	# Rename 3dNetCorr output for 3dDetrend
	mv $ts_prefix*.netts $ts_mean

#	# 3dDetrend takes rows as input ($ts_mean -> ROI x TR)
#	3dDetrend -polort $pnum \
#			  -prefix $ts_dt.1D \
#			  $ts_mean

	3dTcat -tr $TR -prefix $ts_dt.1D $ts_mean

	# Transpose
	1dtranspose $ts_dt.1D $ts_dt_t

	# Deconvolution of seed time series (Tutorial code example)
	if [ "$run_SPM_BIN" = "TRUE" ]; then
		3dTfitter -RHS $ts_dt_t \
				  -FALTUNG $hrf $ts_deconv 012 -1
	fi

	# (-FALTUNG fset fpre pen fac) -> see https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html

	### DECONVOLUTION APPROACHES ###

	# 2017-03-20: Strong difference between no deconvolution and "-FALTUNG $hrf $ts_deconv 012 -1 -l2sqrtlasso 2"

	# VARIOUS RECOMMENDATIONS:

	# 3dTfitter (https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTfitter.html)
	# -> does not work as intended and zero almost the whole time series and leave only a few spikes.
	#		  -FALTUNG $hrf $ts_deconv 012 -2 \
	#		  -l2lasso -6

	# AFNI forum (https://afni.nimh.nih.gov/afni/community/board/read.php?1,142819,142831#msg-142831):
	# -> seems to work, but no modulated connectivity compared to "without deconvolution"
	#		  -FALTUNG $hrf $ts_deconv 012 -1 \
	#		  -l2sqrtlasso 2

	# Cisler et al. (2014, NeuroImage) used deconvolution algorithm described in Bush & Cisler (2012)
	# -> 2017-03-21: Trying implementation currently

	# AFNI tutorial (https://afni.nimh.nih.gov/CD-CorrAna):
	# 		3dTfitter -RHS Seed_ts.1D -FALTUNG GammaHR.1D Seed_Neur 012 0
	# Code example:
	# 		3dTfitter -RHS Seed_ts${cc}${sd}.1D -FALTUNG GammaHR.1D Seed_Neur${cc}${sd} 012 -1

	# Both use the default "-lsqfit" option, whereas the first example use "fac=0"
	# "-l2sqrtlasso 2" makes deconvolved times series much smoother
	#
	# fac = 0 is a special case: the program chooses a range
    #            of penalty factors, does the deconvolution regression
    #            for each one, and then chooses the fit it likes best
	#
	# If run on ID01/gppi_conf_cS2/ts/ts_01_01_dt_t.1D
	# -> + Optimal penfac_used#3 = -1.62991

	# cmp.ppi.2.make.regs:
	#   3dTfitter -RHS $pprev.seed.$TRnup.r$rind.1D                  \
    #         -FALTUNG $hrf_file temp.1D 012 -2  \
    #         -l2lasso -6
	
	# "012 -1 -l2lasso 1" and "012 -1 -l2sqrtlasso 2" lead to similar results
  

	# ================================================================================
	# INTERACTION REGRESSOR - SPM APPROACH
	# --------------------------------------------------------------------------------

	# Mask "neural" time series with condition regressor

	if [ "$run_SPM_BIN" = "TRUE" ]; then

		# 3dcalc wants *.3D input
		cp $ts_deconv.1D $ts_deconv.3D
		
		for j in ${!cond_labels[@]}; do

			3dcalc -a $ts_deconv.3D -b ${reg_cond_SPM[$j]} -expr 'a*b' -prefix ${ts_deconv_cond[$j]}
		done

		# Convolve with HRF to interaction regressor for each ROI

		rm -rf ${ts_cond_SPM[@]}

		# Loop conditions
		for j in ${!cond_labels[@]}; do

			# waver takes 1 column (t across rows) as input and gives same format as output
			# Output is saved in a single array element
			# Array element is written to file (1 ROI per row and t across columns)
			
			# Loop ROIs
			for ((i=0; i<$(3dinfo -ni ${ts_deconv}.3D); i++)); do

				int_cond_SPM[$i]=$(waver -input ${ts_deconv_cond[$j]}{$i}\' \
									 	 -FILE $TR $hrf \
									 	 -TR $TR \
									 	 -numout $TR_num)

				echo ${int_cond_SPM[$i]} >> ${ts_cond_SPM[$j]}
			done

		done

	fi

	# ================================================================================
	# INTERACTION REGRESSORS (WITHOUT DECONVOLUTION) - FSL & BINARY APPROACH
	# --------------------------------------------------------------------------------

	# Mask detrended time series with condition regressor

	cp $ts_dt.1D $ts_dt.3D

	# Loop conditions
	for j in ${!cond_labels[@]}; do

		if [ "$run_SPM_BIN" = "TRUE" ]; then

			# Binary approach
			3dcalc -a $ts_dt.3D -b ${reg_cond_BIN[$j]} -expr 'a*b' -prefix ${ts_cond_BIN[$j]}

		fi
		
		# FSL approach
		3dcalc -a $ts_dt.3D -b ${reg_cond_FSL[$j]} -expr 'a*b' -prefix ${ts_cond_FSL[$j]}

	done

done # Loop - EPIs / Blocks

# ================================================================================
# CONCATENATE SEED AND "INTERACTION TIME SERIES
# --------------------------------------------------------------------------------

# "Psychological" regressors
# --------------------------------------------------------------------------------

for reg_cond_pre in ${reg_cond_prefix[@]}; do

	if [ "$run_SPM_BIN" = "TRUE" ]; then

		# SPM approach
		cat ${reg_cond_pre}_0[1-${block_max}]${SPM_label}.1D > ${reg_cond_pre}${SPM_label}.1D

		# Binary approach
		cat ${reg_cond_pre}_0[1-${block_max}]${BIN_label}.1D > ${reg_cond_pre}${BIN_label}.1D

	fi

	# FSL approach
	cat ${reg_cond_pre}_0[1-${block_max}]${FSL_label}.1D > ${reg_cond_pre}${FSL_label}.1D
done


# Seed time series (detrended)
# --------------------------------------------------------------------------------

3dTcat -TR $TR \
	   -prefix ${ts_prefix_ID}${ts_dt_suffix_wo1D}.1D \
		${ts_prefix_ID}_0[1-${block_max}]${ts_dt_suffix_wo1D}.1D


# Interaction regressors
# --------------------------------------------------------------------------------

for ts_cond_suf in ${ts_cond_suffix[@]}; do

	if [ "$run_SPM_BIN" = "TRUE" ]; then

		# SPM approach (Deconvolved)
		3dTcat -TR $TR \
			   -prefix ${ts_prefix_ID}${SPM_label}${ts_cond_suf} \
				${ts_prefix_ID}_0[1-${block_max}]${SPM_label}${ts_cond_suf}

		# Binary approach (Without deconvolution)
		3dTcat -TR $TR \
			   -prefix ${ts_prefix_ID}${BIN_label}${ts_cond_suf} \
				${ts_prefix_ID}_0[1-${block_max}]${BIN_label}${ts_cond_suf}

	fi

	# FSL approach (Without deconvolution)
	3dTcat -TR $TR \
		   -prefix ${ts_prefix_ID}${FSL_label}${ts_cond_suf} \
			${ts_prefix_ID}_0[1-${block_max}]${FSL_label}${ts_cond_suf}

done

# ================================================================================
# END
# --------------------------------------------------------------------------------

fi # if [ -f "$valid_blocks_txt" ]; then
