% Establish connection with the NXT brick
MyNXT = COM_OpenNXT();
COM_SetDefaultNXT(MyNXT);

% Switch on a lamp connected to motor port A
SwitchLamp(MOTOR_A, 'on');

% Wait five seconds
pause(5);

% Switch the lamp off
SwitchLamp(MOTOR_A, 'off');

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);
