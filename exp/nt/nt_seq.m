function [seq,nt] = nt_seq(nt)
% [seq,nt] = nt_seq(nt) returns a sequence matrix (seq) that is shuffled 
% per block as well as the random number generator state that was set.
%
%   seq: block x stimulus type x stimulus step x stimulus delay
%
% The number of stimulus delays is equal the number of trials per block,
% defined as sum(nt.stim_types_num) and lineraly spaced between the minimum
% and maximim of the defined stimulus delay interval (nt.stim_delay).
%
% Relevant settings in nt_setup (doc nt_setup):
%   nt.rng_state
%   nt.blocks
%   nt.stim_types
%   nt.stim_types_num
%   nt.stim_steps
%   nt.stim_delay
%
% Author:           Martin Grund
% Last update:      December 10, 2015

%%

% Set random number generator state
nt.rng_state = set_rng_state(nt);

seq = [];

for i = 1:nt.blocks
    
    seq_type_tmp = [];
    seq_step_tmp = [];
    
    % Loop stimulus types
    for j = 1:numel(nt.stim_types)
        seq_type_tmp = [seq_type_tmp; ones(nt.stim_types_num(j),1)*nt.stim_types(j);];   
    
        % Vector stimulus steps
        if nt.stim_types(j) == 0
            steps = zeros(nt.stim_types_num(j),1);
        else
            if i == 1 && mod(nt.stim_types_num(j),numel(nt.stim_steps)) ~= 0
                warning('nt_exp:trialNum',...
                        ['Sequence generation - No equal stimulus step distribution ',...
                         'for stimulus type "' num2str(nt.stim_types(j)) '", because the ',...
                         'frequency of this stimulus type (' num2str(nt.stim_types_num(j)) ') ',...
                         'is not a multiple of the number of stimulus steps (',...
                         num2str(numel(nt.stim_steps)) ').']);
            end            
            steps = repmat(nt.stim_steps',ceil(nt.stim_types_num(j)/numel(nt.stim_steps)),1);
        end

        seq_step_tmp = [seq_step_tmp; steps(1:nt.stim_types_num(j))];

    end
    
    % Shuffle stimulus types
    seq_ind = Shuffle(1:sum(nt.stim_types_num));
    
    % Shuffle stimlus delays (rounded on ms)
    seq_stim_delay = Shuffle(round_dec(linspace(nt.stim_delay(1),nt.stim_delay(2),sum(nt.stim_types_num)),4))';
    
    % Sequence matrix: block - type - step - delay
    seq = [seq; i*ones(sum(nt.stim_types_num),1) seq_type_tmp(seq_ind) seq_step_tmp(seq_ind) seq_stim_delay];        
end