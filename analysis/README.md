# GraphCA - Data analysis

## Behavioral data analysis 

Directory: behavior/

- nt_trials.txt - behavioral data (1 trial each row)
- behav.R - main script to preprocess behavioral data and create stimulus onset files
- plot_detection.R - script to plot detection rates
- plot_conf.R - script to plot confidence ratings
- intensity.R - script to analyze applied intensity of electrical pulses

## MRI data analysis

Directory: mri/

### Software requirements

- AFNI
- FSL
- FreeSurfer

### Preprocessing

#### Anatomical MRI

1. T1_filenames.sh - get available structural MRI data from database
2. anat_pre2.sh - skull-stripping and non-linear normalization of anatomical T1 image
3. FS_afni_proc.py - run FreeSurfer recon-all segmentation to create white matter and ventricle masks

#### Functional MRI

1. epi_dcm2nii.sh - DICOM to NIfTI conversion
2. rename_fmap.sh - separates and renames fieldmap's phase and magnitude image
3. get_slicetime.sh - gets slice timing from DICOM header
4. run_fmri_pre.sh<sup>*</sup> - main preprocessing script of functional MRI
5. shift_onsets.sh<sup>*</sup> - adapts onset times for initially removed volumes

### GLM

#### Individual level

1. glm.sh<sup>*</sup> - model BOLD amplitude contrasts and signal time course
2. err_smooth.sh<sup>*</sup> - determine spatial error smoothness

#### Group level

1. grouptest.sh - mixed-effects meta analysis (3dMEMA) of BOLD amplitude contrasts
2. monte_carlo.sh - Monte Carlo simulation based on spatial error smoothness
3. clusterize.sh - filter for cluster size threshold

### BOLD signal time course

1. plot_signal_course.R - plots signal time course for multiple ROIs

### gPPI (generalized Psychophysiological Interaction)

1. atlas.sh - creates mask volume with numbered ROIs based on list of coordinates 
2. gppi_pre.sh<sup>*</sup> - creates regressors for each ROI's gPPI
3. gppi2.sh<sup>*</sup> - run gPPI for each ROI
4. beta_mat.sh - extract beta weights for gPPI interaction regressor for each ROI's gPPI at every other ROI

<sup>*</sup> run via x.run_condor.sh on condor or in parallel

## Graph theory analysis

Directory: graph/

### Software requirements

- Brain Connectivity Toolbox 2017-01-15 (https://sites.google.com/site/bctnet/)<sup>1</sup>
- boundedline.m (https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m)<sup>1</sup>

<sup>1</sup>Part of repository (see "assets/")

### Graph metrics & connectivity matrix

1. graph_metrics.m - main script to run graph theory analysis
2. plot_NOI.m - plots matrix of network of interest
