% Establish connection with the NXT brick
MyNXT = COM_OpenNXT();
COM_SetDefaultNXT(MyNXT);

% Set up parameters for driving the motor forward
mA = NXTMotor('A'); % associate mA with the motor connected to port A
mA.Power = -40; % drive the motor at 40% power
mA.TachoLimit = 1000; % set the tacho limit to 1000 degrees
mA.ActionAtTachoLimit = 'Brake'; % brake to stop precisely at the tacho limit
% Establish connection to a light sensor connected to sensor port 1
% Use active mode (i.e. LED on)
OpenLight(SENSOR_1, 'ACTIVE');

% Create an empty vector to store the light sensor readings
results = [];

% Send the information in mA to the motor - it will now start turning
mA.SendToNXT();

% Read the current motor status
data = mA.ReadFromNXT(); % data now contains information about the motor's current state

% Keep iterating while the motor is running
while data.IsRunning
    % Add a new row to results
    % Each row stores the current light sensor reading
    results = [results; GetLight(SENSOR_1)];
    % Read the current motor status
    data = mA.ReadFromNXT(); % overwrite data with updated information about the motor's current state
end

% Wait until the motor has completely stopped
mA.WaitFor();

% Set up parameters for driving the motor back to its start position
mA.Power = 40; % all other parameters remain unchanged

% Send the information in mA to the motor - it will now turn the other way
mA.SendToNXT();

% Wait until the motor has completely stopped
mA.WaitFor();

% Close connection to the light sensor, power down LED
CloseSensor(SENSOR_1);

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);

% Set the threshold for black/white discrimination
thresh = 320;

% Plot the raw sensor readings and the threshold
figure(1);
plot(results);
hold on;
plot(thresh * ones(size(results)), 'g--');
hold off;

% On a second graph, display the detected bar code
figure(2);
colormap('gray');
image( 255 * (results > thresh) );
