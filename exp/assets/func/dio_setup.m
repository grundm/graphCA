function [dio,adr] = dio_setup(address,direction)
% dio_setup creates an digital input object for the parallel port and
% controls the directionality of the data port.
%
% The parallel port must be an extended capabilities port (ECP).
% 
% Input:
% address       - parallel data port address in hexadecimal (e.g., '378')
% direction     - parallel data port mode ('uni' or 'bi')
%
% This function builds on io32.dll and inpout32.dll (for installation
% details see http://apps.usd.edu/coglab/psyc770/IO32.html)
%
% Administrator privileges are required.
%
% The Data Acquisition Toolbox does not support to control the 
% bidirectional mode of the parallel port and hence a modification of the 
% source code of the parallel adaptor would be necessary
% (cd([matlabroot '\toolbox\daq\daq\src\mwparallel\'])).
%
% Author:           Martin Grund
% Last update:      September 29, 2015

%% Create IO32 interface
clear io32;
dio = io32;

%% Install inpout32.dll driver

status = io32(dio);

if status == 0
    disp('Successful installation of inpout32.dll'); 
else
    error('Failed installation of inpout32.dll');
end

%% En- or disable bidirectional port

% Define address of control port
% see https://en.wikipedia.org/wiki/Parallel_port#Port_addresses
% see http://retired.beyondlogic.org/ecp/ecp.htm#9
adr = hex2dec(address);
ctrl_adr = adr+2; % control port address
ecr = adr+1024+2; % extended control register (ECR)

% Get ECR state
ecr_state = get_lpt(dio,ecr);

% Set mode and bidirectional bit
% For modes http://retired.beyondlogic.org/ecp/ecp.htm#10)
if strcmp('uni',direction)
    % Set standard mode (bits 7:5 -> 000)
    io32(dio,ecr,set_bits(ecr_state,6:8,[0 0 0]));
    % NOT NECESSARY: Turn of bidirectional bit
    % io32(dio,ctrl_adr,bitset(get_lpt(dio,ctrl_adr),6,0));
    
    if bitget(get_lpt(dio,ctrl_adr),6) == 1
        error('Failed setup of parallel port unidirectional mode');
    end
elseif strcmp('bi',direction)
    % Set byte mode (bits 7:5 -> 001)
    io32(dio,ecr,set_bits(ecr_state,6:8,[1 0 0]));
    % Set bidirectional mode
    io32(dio,ctrl_adr,bitset(get_lpt(dio,ctrl_adr),6,1));
    
    if bitget(get_lpt(dio,ctrl_adr),6) == 0
        error('Failed setup of parallel port bidirectional mode');
    end
else
    error('Input argument direction has to be string with "uni" or "bi".')
end

%% Set all data pins high
io32(dio,adr,255);

function lpt_status = get_lpt(dio,adr)
    lpt_status = uint8(io32(dio,adr));
    
function A = set_bits(A,bits,values)
    for i = 1:length(bits)
        A = bitset(A,bits(i),values(i));
    end