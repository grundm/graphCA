function [trigger_t,trigger_date,start_wait,stop_wait] = wait_for_scanner(dio,adr,TR,trigger_bit,trigger_max)
% [trigger_t,trigger_date,start_wait,stop_wait] = wait_for_scanner(dio,adr,TR,trigger_bit,trigger_max)
% waits for a specified number of triggers send by the scanner.
%
% For this, it enables interrupt requests (IRQ) by setting the control port
% bit 5 on 1, and disables IRQs at the end again. For details see:
% http://retired.beyondlogic.org/spp/parallel.htm#5
%
% Input:
%   dio             - io32 interface (returned by dio_setup)
%   adr             - parallel data port address in decimal
%   TR              - MRI repetition time in s
%   trigger_bit     - status port bit reflecting hardware pin with MRI trigger input
%   trigger_max     - number of triggers to wait
%
% Author:           Martin Grund
% Last update:      November 16, 2015


%% Setup
% 2.531 ms (Knut tic toc result)
start_wait = GetSecs;

trigger_count = 0;
trigger_t = zeros(trigger_max,1);
trigger_date = trigger_t;

% Prepare parallel port handling
status_adr = adr+1;
ctrl_adr = adr+2;

% Enable interrupt request (IRQ)
io32(dio,ctrl_adr,bitset(get_lpt(dio,ctrl_adr),5,1));


%% Monitor

while 1
    % 0.046 ms (Knut tic toc result)
    if bitget(get_lpt(dio,status_adr),trigger_bit) == 0
        trigger_count = trigger_count + 1;
        trigger_t(trigger_count) = GetSecs;
        trigger_date(trigger_count) = now;
        if trigger_count == trigger_max
           break 
        end
        WaitSecs('UntilTime',trigger_t(end)+TR/2);
    end
end

%% Close
% 0.145 ms (Knut tic toc result)
% Disable interrupt request (IRQ)
io32(dio,ctrl_adr,bitset(get_lpt(dio,ctrl_adr),5,0));

stop_wait = GetSecs;


%% Subfunctions

function lpt_status = get_lpt(dio,adr)
    lpt_status = uint8(io32(dio,adr));