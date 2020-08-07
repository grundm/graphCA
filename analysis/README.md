# GraphCA - Data analysis

## Behavioral data analysis

Directory: behavior/

- nt_trials.txt - behavioral data (1 trial each row)
- behav.R - main script to preprocess behavioral data and create stimulus onset files
- plot_detection.R - script to plot detection rates
- plot_conf_bar.R - script to plot confidence ratings
- intensity.R - script to analyze applied intensity of electrical pulses

## MRI data analysis

Directory: mri/

### Software requirements

- dcm2nii 20160222
- AFNI 18.2.17 (Preprocessing) & 19.1.05 (GLM)
- FSL 5.0.11
- FreeSurfer 6.0.0
- R 3.6.0
- R package: snow 0.4-3; reshape


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

#### Group level

1. grouptest.sh - mixed-effects meta analysis (3dMEMA) of BOLD amplitude contrasts
2. clusterize.sh - filter for cluster size threshold

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
- fdr_bh.m (https://www.mathworks.com/matlabcentral/fileexchange/27418-fdr_bh)<sup>1</sup>
- bayesFactor (https://klabhub.github.io/bayesFactor/)<sup>1</sup>
- hline_vline (https://www.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline)<sup>1</sup>

<sup>1</sup>Part of repository (see "assets/")

### Graph metrics

1. graph_metrics.m - main script to run graph theory analysis
2. Nested functions: parrun_graph.m -> graph_conmat.m -> analyze_graph.m -> rnd_graph.m
