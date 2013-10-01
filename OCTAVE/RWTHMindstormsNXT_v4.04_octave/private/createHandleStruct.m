function h = createHandleStruct()
% Main part of the toolbox's NXT handle concept, creates a handle
%
% Syntax
%   h = createHandleStruct()
%
% Description
%   Various information concerning the NXT brick and the toolbox's way of
%   communicating with it is stored inside this handle: Bluetooth and USB
%   parameters, the actual handle to the hardware drivers, but also data
%   about the current motor status and transmission statistics.
%
%   To store dynamic information, we create this struct with function
%   handles to nested functions of this m-file, using the concept of
%   function closures. They enable us to keep variables as if they were
%   global or persistent, and work around the limitation of MATLAB that
%   passing variables/objects by reference is not possible...
%
%   For documentation of the provided "member functions" (function handles
%   to nested functions) see either this sourcecode or the "RWTH -
%   Mindstorms NXT Toolbox Developer's Guide" document (to be published)
% 
% Notes
%   Special thanks to Eckhard Lehmann (The MathWorks, Germany) for pointing
%   out and explaining the concept of function closures in MATLAB, as well
%   as thanks to Jim Hunziker for his example on this topic (from MATLAB
%   Central File Exchange).
%   Another good introductory example can be found here (especially comments
%   #3 and #6):
%   http://blogs.mathworks.com/loren/2007/08/09/a-way-to-create-reusable-tools
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/01
%   Copyright: 2007-2010, RWTH Aachen University
%
% ***********************************************************************************************
% *  This file is part of the RWTH - Mindstorms NXT Toolbox.                                    *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is free software: you can redistribute it and/or modify  *
% *  it under the terms of the GNU General Public License as published by the Free Software     *
% *  Foundation, either version 3 of the License, or (at your option) any later version.        *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is distributed in the hope that it will be useful,       *
% *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *
% *  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.             *
% *                                                                                             *
% *  You should have received a copy of the GNU General Public License along with the           *
% *  RWTH - Mindstorms NXT Toolbox. If not, see <http://www.gnu.org/licenses/>.                 *
% ***********************************************************************************************
 
%% Initialize member variables
    % we store "private" member information in variables, here prefixed
    % with v_. Due to function closures, they will keep their state for
    % each handle "object".
    
    global cHSinstance_counter = 0;

    global v_HandleStructArray;
    
    cHSinstance_counter = cHSinstance_counter + 1;
    
    h.instance = cHSinstance_counter;

    v_HandleStructArray{h.instance}.Handle = [];
    
    v_HandleStructArray{h.instance}.BytesSent = 0;
    v_HandleStructArray{h.instance}.BytesReceived = 0;
    v_HandleStructArray{h.instance}.PacketsSent = 0;
    v_HandleStructArray{h.instance}.PacketsReceived = 0;
    v_HandleStructArray{h.instance}.TransmissionErrors = 0;
    
    v_HandleStructArray{h.instance}.LastSendTime = [];
    v_HandleStructArray{h.instance}.LastReceiveTime = [];

    v_HandleStructArray{h.instance}.NXTMOTOR_State = initializeGlobalMotorStateVar();
    v_HandleStructArray{h.instance}.NXTMOTOR_CurrentMotor = NaN;
   
    v_HandleStructArray{h.instance}.ReceivedPacketQueue = [];

    % init gyro sensor offset to hardcoded default value
    % tested with two different devices, offset was 592 and 597,
    % the internet says defaults are around 600. we use 595
    % doesnt really matter anyway, but better to have a fitting default
    % value than a totally wrong one
    % format: 1st column offsets, 2nd column flag if already calibrated
    v_HandleStructArray{h.instance}.GyroSensorOffset = [ones(4,1) * 595, zeros(4, 1)];
    % format: [nearDist nearEOPD; farDist farEOPD] 
    tmpNaN = [NaN NaN; NaN NaN];
    v_HandleStructArray{h.instance}.EOPDSensorMatrix = {tmpNaN tmpNaN tmpNaN tmpNaN};
    
    v_HandleStructArray{h.instance}.LastGetUSTime = [tic; tic; tic; tic];
    
    v_HandleStructArray{h.instance}.Connected = false;
    
    
%% Create & initialize handle struct
    % Here we use the struct's fields for the first time.
    % Whenever we've got dynamic information, we will set the field
    % to its according function handle, that can later be called from the
    % outside...
    

    h.OSName                = '';  % String, 'Windows' or 'Linux'
    h.OSValue            	= NaN; % Windows = 1, Linux = 2
    h.ConnectionTypeName    = '';  % String, 'USB' or 'Bluetooth'
    h.ConnectionTypeValue 	= NaN; % USB = 1, Bluetooth = 2

    h.Handle                = (@(varargin) @ActualHandle(h.instance, [varargin{:}]));
    % actual handle to driver / serial ...

    % Infos taken from bluetooth.ini file
    h.IniFilename           = '';
    h.ComPort               = '';
    h.BaudRate            	= NaN;
    h.DataBits            	= NaN;
    h.Timeout             	= NaN;

    h.SendSendPause       	= NaN;
    h.SendReceivePause      = NaN;

    % Timestamps needed for automatic wait-time between consecutive
    % bluetooth-data transmissions
    h.LastSendTime        	= (@(varargin) @LastSendTime(h.instance, [varargin{:}]));
    h.LastReceiveTime     	= (@(varargin) @LastReceiveTime(h.instance, [varargin{:}]));

    % NXT info, Name might be added in the future
    %h.NXTName               = '';
    h.NXTMAC                = '';

    % NXTMOTOR_State is its own struct to store information about the 3
    % motors of each NXT. Needed for functions like SetPower etc, to
    % automatically form 2 packets when working with synchronized motors,
    % but also to keep state in certain circumstances...
    h.NXTMOTOR_getState    	= (@(varargin) @NXTMOTOR_getState(h.instance, [varargin{:}]));
    h.NXTMOTOR_setState    	= (@(varargin) @NXTMOTOR_setState(h.instance, [varargin{:}]));
    h.NXTMOTOR_resetRegulationState  = (@(varargin) @NXTMOTOR_resetRegulationState(h.instance, [varargin{:}]));
    h.NXTMOTOR_getCurrentMotor = (@(varargin) @NXTMOTOR_getCurrentMotor(h.instance, [varargin{:}]));
    h.NXTMOTOR_setCurrentMotor = (@(varargin) @NXTMOTOR_setCurrentMotor(h.instance, [varargin{:}]));
    
    % In Windows-USB (Fantom), we cannot transmit and receive packets
    % seperately. Whenever we send a direct command, we directly get the
    % reply packet at once. To emulate (or "fake") they way how we send and
    % collect packets in different functions, we create this queue that
    % temporarily stores data until we collect them (think of it as a
    % classic read-buffer for serial connections)
    h.getReceivedPacketQueue    = (@(varargin) @getReceivedPacketQueue(h.instance, [varargin{:}]));
    h.setReceivedPacketQueue    = (@(varargin) @setReceivedPacketQueue(h.instance, [varargin{:}]));
    h.addtoReceivedPacketQueue  = (@(varargin) @addtoReceivedPacketQueue(h.instance, [varargin{:}]));

    % The HiTechnic Gyro sensor needs to be calibrated manually.
    % The offset must be stored inside the handle (for each NXT, and for
    % each sensor). 
    h.GyroSensorOffset = (@(varargin) @GyroSensorOffset(h.instance, [varargin{:}]));
    % similar to Gyro calibration, we store EOPD calibration values
    h.EOPDSensorMatrix = (@(varargin) @EOPDSensorMatrix(h.instance, [varargin{:}]));
    
    % avoid polling the US too frequently
    h.LastGetUSTime    = (@(varargin) @LastGetUSTime(h.instance, [varargin{:}]));
    
    
    % Statistics! We update these packet and byte counters when
    % appropriate. If performance is an issue, we could leave this out, but
    % it might be very comfortable to have this easy overview about packet
    % rate and data rate...
    h.BytesSent = (@(varargin) @BytesSent(h.instance, [varargin{:}]));
    h.BytesReceived = (@(varargin) @BytesReceived(h.instance, [varargin{:}]));
    h.PacketsSent         	= (@(varargin) @PacketsSent(h.instance, [varargin{:}]));
    h.PacketsReceived     	= (@(varargin) @PacketsReceived(h.instance, [varargin{:}]));
    % Transmission error is defined as a reply packet containing a
    % statusbyte ~= 0. The only exception is I2C traffic, where we
    % sometimes except those packet-error-messages (usually
    % DontCheckStatusByte is then set to true for COM_CollectPacket)
    h.TransmissionErrors  	= (@(varargin) @TransmissionErrors(h.instance, [varargin{:}]));

    % Creation-Time is just a gimmick, timestamp how old this handle is
    h.CreationTime       	= NaN;
    % We need this flag, it basically signals success or failure of
    % connection establishment
    h.Connected             = (@(varargin) @Connected(h.instance, [varargin{:}]));
    
    % An index to a global cell-array of all handles ever constructed. We
    % keep track of them ("keep a copy") so that COM_CloseNXT('all') can
    % really close all outstanding USB handles...
    h.Index                 = NaN;
    
    h.DeleteMe              = (@(varargin) @DeleteMe(h.instance, [varargin{:}]));
    
    h.UseNXCMotorControl    = 0;
    
%% *** Statistics functions
% They either return the current value or INCREMENT it by the specified
% value, so h.BytesSent(5) will add 5 sent bytes (not set to 5!).

%% --- NESTED FUNCTION BytesSent
    function ret = BytesSent(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.BytesSent = v_HandleStructArray{instance}.BytesSent + n;
      endif
      ret = v_HandleStructArray{instance}.BytesSent;
    endfunction

%% --- NESTED FUNCTION BytesReceived
    function ret = BytesReceived(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.BytesReceived = v_HandleStructArray{instance}.BytesReceived + n;
      endif
      ret = v_HandleStructArray{instance}.BytesReceived;
    endfunction

%% --- NESTED FUNCTION PacketsSent
    function ret = PacketsSent(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.PacketsSent = v_HandleStructArray{instance}.PacketsSent + n;
      endif
      ret = v_HandleStructArray{instance}.PacketsSent;
    endfunction

%% --- NESTED FUNCTION PacketsReceived
    function ret = PacketsReceived(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.PacketsReceived = v_HandleStructArray{instance}.PacketsReceived + n;
      endif
      ret = v_HandleStructArray{instance}.PacketsReceived;
    endfunction

%% --- NESTED FUNCTION TransmissionErrors
    function ret = TransmissionErrors(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.TransmissionErrors = v_HandleStructArray{instance}.TransmissionErrors + n;
      endif
      ret = v_HandleStructArray{instance}.TransmissionErrors;
    endfunction

%% *** Connected flag
%% --- NESTED FUNCTION Connected
    function ret = Connected(instance, n)
      global v_HandleStructArray
      if length(n) ~= 0
        v_HandleStructArray{instance}.Connected = n;
      endif
      ret = v_HandleStructArray{instance}.Connected;
    endfunction

%% *** Bluetooth send- and receive-timestamps
%% --- NESTED FUNCTION LastSendTime
    function ret = LastSendTime(instance, in)
      global v_HandleStructArray
      if length(in) ~= 0
        v_HandleStructArray{instance}.LastSendTime = in;
      endif
      ret = v_HandleStructArray{instance}.LastSendTime;
    endfunction

%% --- NESTED FUNCTION LastReceiveTime
    function ret = LastReceiveTime(instance, in)
      global v_HandleStructArray
      if length(in) ~= 0
        v_HandleStructArray{instance}.LastReceiveTime = in;
      endif
      ret = v_HandleStructArray{instance}.LastReceiveTime;
    endfunction

%% *** The actual handle-value (for fantom/libusb etc.)
%% --- NESTED FUNCTION ActualHandle
    function ret = ActualHandle(instance, hIn)
      global v_HandleStructArray
      if length(hIn) ~= 0
        v_HandleStructArray{instance}.Handle = hIn;
      endif
      ret = v_HandleStructArray{instance}.Handle;
    endfunction

%% *** Windows-USB (Fantom) receive queue management
% These functions provide easy access to modify the queue. Of course one
% could've done this with one single function, but I chose these 3 variants
% for performance reasons (all very simple and hence fast)!

%% --- NESTED FUNCTION getReceivedPacketQueue
    function ret = getReceivedPacketQueue(instance)
      global v_HandleStructArray
      ret = v_HandleStructArray{instance}.ReceivedPacketQueue;
    endfunction

%% --- NESTED FUNCTION setReceivedPacketQueue
    function setReceivedPacketQueue(instance, in)
      global v_HandleStructArray
      v_HandleStructArray{instance}.ReceivedPacketQueue = in;
    endfunction

%% --- NESTED FUNCTION addtoReceivedPacketQueue
    function addtoReceivedPacketQueue(instance, in)
      global v_HandleStructArray
      v_HandleStructArray{instance}.ReceivedPacketQueue = vertcat(v_HandleStructArray{instance}.ReceivedPacketQueue, in);
    endfunction

%% *** NXT Motor State struct
% What was formerly a single global variable is now attached to the handle.
% Since the struct is not exactly small, performance is an issue here, but
% this is the most obvious, easy to follow implementation...

%% --- NESTED FUNCTION NXTMOTOR_getState
    function ret = NXTMOTOR_getState(instance)
      global v_HandleStructArray
      ret = v_HandleStructArray{instance}.NXTMOTOR_State;
    endfunction

%% --- NESTED FUNCTION NXTMOTOR_setState
    function NXTMOTOR_setState(instance, in)
      global v_HandleStructArray
      v_HandleStructArray{instance}.NXTMOTOR_State = in;
    endfunction

%% --- NESTED FUNCTION NXTMOTOR_resetRegulationState
    function NXTMOTOR_resetRegulationState(instance, motor)
      % formerly known as resetMotorRegulation.m
      global v_HandleStructArray
      if motor ~= 255
            
        % note the usage of index + 1, it is necessary!!
        if v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor ~= -1
          % reset the synced-to motor as well
          v_HandleStructArray{instance}.NXTMOTOR_State(v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor + 1).SyncedToMotor = -1;
          v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor = -1;
        endif

        v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToSpeed = false;    

      else % == 255

        for motor = 0 : 2 % 0 : 2 because we add 1 later down

          % note the usage of index + 1, it is necessary!!    
          if v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor ~= -1
	    % reset the synced-to motor as well
            v_HandleStructArray{instance}.NXTMOTOR_State(v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor + 1).SyncedToMotor = -1;
            v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToMotor = -1;
          endif

          v_HandleStructArray{instance}.NXTMOTOR_State(motor + 1).SyncedToSpeed = false;    

        endfor
      endif

    endfunction


%% *** Current Active Motor (for highlevel motor functions)
% We use this as fast internal handler (quicker than global vars) instead
% of GetMotor and SetMotor...

%% --- NESTED FUNCTION NXTMOTOR_getCurrentMotor
    function ret = NXTMOTOR_getCurrentMotor(instance)
      global v_HandleStructArray
      if isnan(v_HandleStructArray{instance}.NXTMOTOR_CurrentMotor)
        error('MATLAB:RWTHMindstormsNXT:Motor:noMotorSet', 'Current motor number not set, must use SetMotor() first. Or did you accidently use CLEAR?');
      endif
      ret = v_HandleStructArray{instance}.NXTMOTOR_CurrentMotor;
    endfunction

%% --- NESTED FUNCTION NXTMOTOR_setCurrentMotor
    function NXTMOTOR_setCurrentMotor(instance, n)
      global v_HandleStructArray
      v_HandleStructArray{instance}.NXTMOTOR_CurrentMotor = n;
    endfunction


%% --- NESTED FUNCTION GyroSensorOffset
    function ret = GyroSensorOffset(instance, port, offset)
      global v_HandleStructArray
      if length(port) ~= 0
        v_HandleStructArray{instance}.GyroSensorOffset(port+1, 1) = offset;
        v_HandleStructArray{instance}.GyroSensorOffset(port+1, 2) = true;            
      endif
      ret = v_HandleStructArray{instance}.GyroSensorOffset(port+1, :);
    endfunction


%% --- NESTED FUNCTION EOPDSensorMatrix
    function ret = EOPDSensorMatrix(instance, port, matrix)
      global v_HandleStructArray
      if length(port) ~= 0
        v_HandleStructArray{instance}.EOPDSensorMatrix{port+1} = matrix;
      endif
      ret = v_HandleStructArray{instance}.EOPDSensorMatrix{port+1};
    endfunction


%% --- NESTED FUNCTION LastGetUSTime
    function ret = LastGetUSTime(instance, in)
      global v_HandleStructArray
      if length(in) ~= 0
        v_HandleStructArray{instance}.LastGetUSTime = in;
      endif
      ret = v_HandleStructArray{instance}.LastGetUSTime;
    endfunction



%% *** Clean up
% Since we cannot delete all external "outside" references (function handles)
% to these internal nested functions, we have to free the memory by using
% clear in here...
% See here, review Nr. 6:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=18223&objectType=file

%% --- NESTED FUNCTION DeleteMe
    function DeleteMe(instance)
      global v_HandleStructArray
      v_HandleStructArray{instance} = [];
    endfunction

endfunction
