# Threshold assesment #

The repository 

## Approach ##

1. Up/down method for coarse estimation of threshold range
2. Psi method informed by up/down method
3. Test block with threshold intensities

## Code structure ##

### Main functions ###
* psi_1AFC.m - runs threshold assesment
* psi_1AFC_setup.m - contains all possible setting, creates neccessary structure to run psi_1AFC

### Support functions ###
* daq_setup - creates interface for analog input and output
* dio_setup - creates interface to parallel port and controls port direction
* parallel_button - monitors parallel port for butto presses
* rect_pulse - creates waveform with rectangular pulse
* load_images - loads (instruction) images files
* show_instr_img - displays (instruction) image files
* count_resp - creates intensity and response frequency matrix from raw intensity and response data

### Toolboxes ###
* Data Acquisition Toolbox
* Palamedes Toolbox (Prins & Kingdom (2009), http://www.palamedestoolbox.org)
* Psychotoolbox
* io32.dll - Matlab parallel port interface by Frank Schieber (http://apps.usd.edu/coglab/psyc770/IO32.html)
* inpout.dll - Windows parallel port driver by logix4u (http://logix4u.net/parallel-port/16-inpout32dll-for-windos-982000ntxp)