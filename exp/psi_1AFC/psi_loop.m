function psi_data = psi_loop(psi,p_data,ao,ai,block,run)
% psi_data = psi_loop(psi,p_data,ao,ai,block,run) runs threshold assessment 
% with psi_1AFC, saves its output (psi_data) to the participants data 
% directory and plots the results of the assessment on the modelled 
% psychometric function.
%
% Input:
%   psi             - settings structure (doc psi_1AFC_setup)
%   p_data          - output of participant_data
%   ao              - analog output object
%   ai              - analog input object
%   block           - block number for filename end
%   run             - run number for filename end
%
% Author:           Martin Grund
% Last update:      January 15, 2016


%%

    % Run threshold assessment
    psi_data = psi_1AFC(psi,ao,ai,p_data.ID,['0' num2str(block) '_0' num2str(run)]);

    % Save threshold assessment data
    psi_1AFC_save(p_data,psi_data,psi,['0' num2str(block) '_0' num2str(run)]);
    
    % Plot up/down trials
    plot_UD_run(psi_data.UD);
    
    disp(sprintf(['\nThA #' num2str(block) '-' num2str(run) '\n']));
    disp(['UD range: ' num2str(psi_data.UD_range(1)) '-' num2str(psi_data.UD_range(2))]);
    disp(['UD mean: ' num2str(psi_data.UD_mean)]);
    disp(['UD PF 50%: ' num2str(psi_data.PF_params_UD(1))]);
    disp(psi_data.x_resp_freq_UD);
    disp(['PM PF 50%: ' num2str(psi_data.PF_params_PM(1))]);
    
    % Plot psi method trials
    plot_PM_run(psi_data.PM);
    
    % Plot estimated psychometric function with test results
    plot_PM_PF(psi_data.PM,psi_data);