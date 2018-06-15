%% Psychometric function

plot_PM_PF(PM,psi_data);

%% Plot threshold and slope estimation

plot_PM_run(PM);

%% Course whole experiment

figure
hold on

plot(1:length(psi_data.intensity),psi_data.intensity,'k+');

bar(1:length(psi_data.resp),psi_data.resp,'FaceColor',[.6 .6 .6],'LineStyle','none');

hold off

%% Course of up/down method

figure
hold on;

plot(1:UD.stopRule,UD.x);

bar(1:UD.stopRule,UD.response,'FaceColor',[.6 .6 .6],'LineStyle','none');

hold off;

disp(['UD_range (UD_meanNumber): ' num2str(psi_data.UD_range(1)) '-' num2str(psi_data.UD_range(2))]);


%% Estimate and plot psychometric function based up/down method

x_resp_freq_UD = count_resp([UD.x' UD.response']);

grid2.alpha = psi_data.UD_range(1)*.90:psi.priorAlphaSteps:psi_data.UD_range(1)*1.1;
grid2.beta = 0:.1:1.4;
grid2.gamma = .05;%.01:.01:.05;
grid2.lambda = .05;%.01:.01:.05;

[PF_params_UD, posterior_UD] = PAL_PFBA_Fit_new(x_resp_freq_UD(:,1),x_resp_freq_UD(:,2),x_resp_freq_UD(:,3),grid2,@PAL_Quick);

PF_params_UD(:,2) = 10.^PF_params_UD(:,2);

plot(PF_stims,PAL_Quick(PF_params_UD(1,:)',PF_stims),'b-.');

hold on

% Plot constant for p = .5
plot(get(gca,'xlim'),[.5 .5],'c-');

hold off

%% Distribution of slope priors

figure
hold on;

for i = 1:length(psi.priorBetaRange)
    plot(0:.1:7,PAL_Quick([3.5 10^psi.priorBetaRange(i) .05 .05],0:.1:7));
end

hold off;