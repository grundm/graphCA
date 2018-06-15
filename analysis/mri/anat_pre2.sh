#/!bin/bash
# anat_pre2.sh $ID
#
# (1) Coping T1 scan from brain database to local directory*
# (2) Conversion DICOM to NIfTI
# (3) Skull stripping
# (4) Non-linear normalization (MNI)
# (5) Dilation of brain masks on T1 and EPI grid
#
# * builds on T1_filenames.sh + hand editing
#
#
# Author: Martin Grund <mgrund@cbs.mpg.de>

# ================================================================================
# SETTINGS
# --------------------------------------------------------------------------------

bmask_orig_dilation=3
bmask_norm_dilation=1

bmask_orig_erode=2
# Tested also 1 (not enough) and 3 (too much)

minpatch=11 # minimum patch size for 3dQwarp (default 25), @SSwarper's default 11

# ================================================================================
# INPUT
# --------------------------------------------------------------------------------

### INPUT ARGUMENT
ID=${1}

### DIRECTORIES
bdb_path=/a/probands/bdb
mri_path=/nobackup/curie2/mgrund/GraphCA/mri
ID_path=$mri_path/ID$ID

### FILES
bdbID_file=$mri_path/GRAPHCA_ID_dbID.txt

T1_files=$mri_path/mprage_selected.txt

mp2rage_wildcard=*mp2rage*_INV2.tar.gz

MNI_bmask=`@FindAfniDsetPath MNI152_2009_template.nii.gz`/MNI152_2009_template.nii.gz[3]

# ================================================================================
# OUTPUT
# --------------------------------------------------------------------------------

### DIRECTORIES
T1_path=$ID_path/T1

warp_path=$T1_path/warp

### FILES
T1_new_filename=anat.nii.gz

banat=$T1_path/banat.nii.gz
# Name as FSL bet would do with input $banat and flag -m
banat_mask=$T1_path/banat_mask.nii.gz
banat_mask_d=$T1_path/banat_mask_d.nii.gz

banat_norm=$T1_path/banat_norm.nii.gz

banat_norm_epi=$T1_path/banat_norm_epi.nii.gz

MNI_bmask_epi=$T1_path/MNI_bmask_epi.nii.gz
MNI_bmask_epi_d=$T1_path/MNI_bmask_epi_d.nii.gz

# Only used if MP2RAGE
INV2_suffix=_INV2
UNI_suffix=_UNI_Images
banat_mask_e=$T1_path/banat_mask_e.nii.gz

# ================================================================================
# FUNCTIONS
# --------------------------------------------------------------------------------

function create_db_nii {

	T1_dicom=$1
	T1_new_file=$2

	echo $T1_dicom

	# Create temporary directory
	T1_tmp_path=`dirname $T1_new_file`/tmp

	mkdir $T1_tmp_path

	# Unpack T1 file
	tar -xzf $T1_dicom -C $T1_tmp_path

	# DICOM -> NIfTI
	dcm2nii -d N -x N -o $T1_tmp_path $T1_tmp_path/`basename $T1_dicom .tar.gz`
    
	# Get reoriented NIfTI (but not cropped to keep dimensions the same)
	T1_tmp=($T1_tmp_path/o*.nii.gz)

	# Rename reoriented T1
	mv $T1_tmp $T1_new_file

	# Clean up (remove temporary directory)
	rm -rf $T1_tmp_path

}

# ================================================================================
# PREPROCESS ANATOMICAL IMAGE
# --------------------------------------------------------------------------------

if [ -d "$ID_path" ]; then

	### 1. COPYING FROM BRAIN DATA BASE ###

	# Make T1 directory
    mkdir $T1_path		

	# Get participant's database ID
	bdb_ID=$(grep ID${ID} $bdbID_file | cut -d';' -f2)

	printf "\n### ID%s %s ###\n\n" "$ID" "$bdb_ID"

	# Get selected T1 filename
	T1_dicom=$(grep -v "^#\|^$" $T1_files | grep $bdb_ID)		

	### 2. CONVERSION DICOM -> NIfTI ###
	T1_nii=$T1_path/$T1_new_filename

	create_db_nii $T1_dicom $T1_nii
	

	### 3./4. SKULL STRIPPING & NORMALIZATION ###

	# Decided for bet based on comparing AFNI & FSL brain masks
	bet $T1_nii $banat -R -m

	if [[ $T1_dicom == $mp2rage_wildcard ]]; then

		# If only MP2RAGE available in database (e.g., ID38)
		# INV2 image is used to generate a brain mask (bet only works on this)
		# that is then eroded to peel the UNI image

		# Rename files	
		mv $T1_nii $T1_path/`basename $T1_nii .nii.gz`$INV2_suffix.nii.gz
		mv $banat $T1_path/`basename $banat .nii.gz`$INV2_suffix.nii.gz
				
		# DICOM -> NIfTI (MP2RAGE T1_Image)
		T1_dicom2=$(grep $bdb_ID $T1_files | grep $UNI_suffix)
		T1_dicom2=${T1_dicom2//#}

		create_db_nii $T1_dicom2 $T1_nii

		# Erode brain mask
		fslmaths $banat_mask -kernel sphere $bmask_orig_erode -ero $banat_mask_e

		# Apply eroded brain_mask
		3dcalc -a $T1_nii \
			   -b $banat_mask_e \
			   -expr 'a*b' \
			   -prefix $banat

		# Normalization
      	auto_warp.py -base MNI152_T1_2009c+tlrc \
					 -input $banat \
					 -skull_strip_input no \
					 -output_dir $warp_path

		# Gzip output
		gzip $warp_path/*.nii

		# Copy normalized brain
		cp $warp_path/*.aw.nii.gz $banat_norm

	else

		mkdir $warp_path

		cd $warp_path # @SSwarper output goes into current directory

		@SSwarper $T1_nii $ID $minpatch

		# Gzip output
		gzip $warp_path/*.nii

		# Rename
		mv $warp_path/*QQ.$ID.nii.gz $banat_norm

	fi

	# -> "auto_warp.py" much faster than "@SSwarper" with default -min_patch (11)

	# Create banat_norm with EPI grid spacing
	3dresample -dxyz 3 3 3.51 \
			   -inset $banat_norm \
			   -prefix $banat_norm_epi


	### 5. DILATION OF BRAIN MASKS ###

	# Dilate mask from banat
	3dmask_tool -dilate_input $bmask_orig_dilation \
				-input $banat_mask \
				-prefix $banat_mask_d

	# MNI template brain mask to EPI grid
	3dresample -dxyz 3 3 3.51 \
			   -inset $MNI_bmask \
			   -prefix $MNI_bmask_epi

	# Dilate MNI brain mask
	3dmask_tool -dilate_input $bmask_norm_dilation \
				-input $MNI_bmask_epi \
				-prefix $MNI_bmask_epi_d

fi
