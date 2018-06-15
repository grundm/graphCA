function nt_result_log(psi_data,nt_data)
% nt_result_log(psi_data,nt_data) displays the applied intensities and 
% their detection rate in the experimental block, as well as the expected
% detection rate based on the estimated psychometric function in psi_1AFC.
%
% Input:
%   psi_data        - output of threshold assessment psi_1AFC
%   nt_data         - output of experimental block (nt_exp)
%
% Author:           Martin Grund
% Last update:      January 14, 2016

disp(['Block #' num2str(nt_data.seq(1,1))]);
disp(['PF(' num2str(nt_data.near) ' mA) = ' num2str(PAL_Quick(psi_data.PF_params_PM,nt_data.near))]);
disp(['PF(' num2str(nt_data.supra) ' mA) = ' num2str(PAL_Quick(psi_data.PF_params_PM,nt_data.supra))]);

nt_detection = count_resp([nt_data.intensity nt_data.resp1])