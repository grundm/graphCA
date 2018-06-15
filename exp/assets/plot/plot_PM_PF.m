function PM_PF_params = plot_PM_PF(PM,psi_data)
%   plot_PM_PF(PM,psi_data) estimates and plots the psychometric function  
%   (PF) based on the psi method (PM) used in psi_1AFC.m
%
%   It creates a figure with the PF and maps the actual applied intensities
%   while the PM and test block on the PF, plus the measured performance of
%   the test intensities.
%
%   Input:
%   PM              - output structure by psi method (PAL_AMPM_updatePM.m)
%   psi_data        - output structure by psi_1AFC.m
%
%   Output:
%   PM_PF_params    - vector of PF threshold, slope, guess and lapse rate
%
%   Author:           Martin Grund
%   Last update:      November 5, 2015

%% Psychometric function

PM_PF_params = [PM.threshold(end); 10.^PM.slope(end); PM.guess(end); PM.lapse(end);]; % [alpha beta gamma lambda]
PF_stims = 0:.01:max([psi_data.supra; psi_data.intensity])+1; % PM.stimRange

% Create intensities x responses matrices
x_resp = [psi_data.intensity psi_data.resp];
x_resp_psi = [PM.x(1:end-1)' PM.response'];
x_resp_test = x_resp(end-length(psi_data.seq_test)+1:end,:);

% Compute response frequencies
x_resp_freq_psi = count_resp(x_resp_psi);
x_resp_freq_test = count_resp(x_resp_test)

% Prepare figure
Fig_PF = figure;
set(Fig_PF,'Name','Psychometric function');
ylabel('Proportion of "yes"');
xlabel('Intensity in mA');
ylim([0 1]);
xlim([min(PF_stims) max(PF_stims)]);
hold on;

% Plot psychometric function (PF)
plot(PF_stims,PAL_Quick(PM_PF_params,PF_stims));

% Plot applied psi method intensities on psychometric function
plot(PM.x,PAL_Quick(PM_PF_params,PM.x),'k+');

% Plot test intensities on psychometric function
plot(x_resp_freq_test(:,1),PAL_Quick(PM_PF_params,x_resp_freq_test(:,1)),'r+');

% Plot real performance of test intensities
plot(x_resp_freq_test(:,1),x_resp_freq_test(:,4),'ro');

% Plot constant for p = .5
plot(get(gca,'xlim'),[.5 .5],'Color',[.7 .7 .7]);

% Plot constant for estimated threshold
plot([PM_PF_params(1) PM_PF_params(1)],get(gca,'ylim'),'g-');

% Plot constant for supra-threshold intensity
plot([psi_data.supra psi_data.supra],get(gca,'ylim'),'m-');


legend('Psychometric function (Quick)',...
       'Applied intensities',...
       'Test intensities',...
       'Performance test intensities',...
       '50%',...
       'Threshold estimation',...
       ['Supra-threshold (~' num2str(PAL_Quick(psi_data.PF_params_PM,psi_data.supra)*100) '%)'],...
       'Location','NorthWest');

hold off;