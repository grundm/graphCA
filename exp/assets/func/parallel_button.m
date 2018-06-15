function [button,respTime,port] = parallel_button(maxRespTime,startTime,timeWindow,dio,adr)
% [button,respTime,port] = parallel_button(maxRespTime,startTime,timeWindow,dio,address)
% monitors the parallel data port for a specified time frame (maxRespTime) 
% since the specified start time (startTime).
%
% It returns the data port pin that changed from 1 to 0, response time in
% s and the status of the parallel data, status, control and extended
% control register port. For special cases the variable "button" is assigned:
% 0  - no button press
% -1 - nonstop button press starting before with parallel part monitoring
% 9  - multiple button presses
%
% Optional: Set timeWindow = 'fixed' if you want no break after the first 
% button press and want to consider only the last pressed button.
%
% Input:
%   maxRespTime     - response window in seconds (e.g., 1.500)
%   startTime       - real system time in seconds (e.g., GetSecs)
%   timeWindow      - 'fixed' or 'variable' (see above for details)
%   dio             - io32 interface (returned by dio_setup)
%   adr             - parallel data port address in decimal (returned by
%                     dio_setup)
%
% Author:           Martin Grund
% Last update:      February 3, 2016

% Set bidirectional bit
set_bi_bit(dio,adr)

button = 0;

% Continue if no buttons are pressed
data_port = get_lpt(dio,adr);
while data_port ~= 255 && (GetSecs-startTime <= maxRespTime)
    % Set bidirectional bit if not 1 anymore
    set_bi_bit(dio,adr)
    
    data_port = get_lpt(dio,adr);
    button = -1;
end

while GetSecs-startTime <= maxRespTime

    % Set bidirectional bit if not 1 anymore
    set_bi_bit(dio,adr)
    
    data_port = get_lpt(dio,adr);
    
    if data_port ~= 255
    	% all data pins low suggests unidirectional mode
    	if data_port ~= 0
	        respTime = GetSecs-startTime;
        
    	    % Get zero data bit
        	button = find(bitget(data_port,1:8)==0);
        
	        if strcmp(timeWindow,'variable') && length(button) == 1
    	        break
        	end
        end
    end    
end

% Save parallel ports: data - status - control - ecr
port = [data_port get_lpt(dio,adr+1) get_lpt(dio,adr+2) get_lpt(dio,adr+1024+2)];

if length(button) > 1
    disp(datestr(now));
    disp(['button = ' num2str(button)]);
    disp(['respTime = ' num2str(respTime)]);
    disp(['port = ' num2str(port)]);
    
    button = 9;
end

% If no button (0) was pressed or signal with request onset that stayed nonstop or no button press followed (-1)
% assign maximum response time
if button == 0 || button == -1
    respTime = maxRespTime;
    disp(datestr(now));
    disp(['button = ' num2str(button)]);
    disp(['port = ' num2str(port)]);
end

function lpt_status = get_lpt(dio,adr)
    lpt_status = uint8(io32(dio,adr));
    
function set_bi_bit(dio,adr)
    ctrl_port = get_lpt(dio,adr+2);
    if bitget(ctrl_port,6) == 0
        io32(dio,adr+2,bitset(ctrl_port,6,1));
    end