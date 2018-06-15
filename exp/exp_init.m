function [p_data,ao,ai] = exp_init
% [p_data,ao,ai] = exp_init runs initial procedures for 
% experiment:
%   - set paths
%   - starts diary
%   - participant_data
%	- aio_setup
%
% Author:           Martin Grund
% Last update:      December 15, 2015

%%
% Make all assets available (e.g., Palamedes toolbox)
addpath(genpath([pwd, '/nt']))
addpath(genpath([pwd, '/psi_1AFC']))
addpath(genpath([pwd, '/assets']))

%% Particpant data
p_data = participant_data('data/ID');

%% Diary logfile   
diary([p_data.dir 'exp_' p_data.ID '_log.txt']);

%% Setup analog output (ao) and input (ai)
[ao,ai] = aio_setup;
