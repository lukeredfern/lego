% Establish connection with the NXT brick
MyNXT = COM_OpenNXT();
COM_SetDefaultNXT(MyNXT);

% Set up parameters for driving the motor
mA = NXTMotor('A'); % associate mA with the motor connected to port A
mA.SmoothStart = 0; % do not use the smooth start option
mA.SpeedRegulation = 0; % do not use the speed regulation option
mA.Power = 50; % drive the motor at 50% power

% Reset the stopwatch
tic;

% Create an empty matrix to store the results
results = [];

% Display a message on the console
disp('Starting recording');

% Send the information in mA to the motor - it will now start turning
mA.ResetPosition(); % establish the motor's current position as the zero position
mA.SendToNXT(); % start the motor
motor_running = true; % this is a variable we use to keep track of the motor's state

% Keep iterating while the stopwatch reads less than five seconds
while toc < 5

    % Read the current status of motor A
    data = mA.ReadFromNXT();

    % Add a new row to results
    % Each row stores the current time (first column) and the
    % current motor position (second column)
    results = [results; toc  data.Position];
    
    % After 2.5 seconds, apply the brakes. This will only happen once,
    % because on the next iteration the motor will no longer be running.
    % && means "AND", so we only apply the brakes if the stopwatch reads
    % more than 2.5 seconds and the motor is still running.
    if (motor_running && toc > 2.5) 
        mA.Stop('brake'); % stop the motor
        motor_running = false; % keep track of the fact that the motor has stopped
    end

end

% The brake is still applied at this point (try to turn the motor manually),
% consuming a lot of power, so now we will really turn it off
mA.Stop('off');

% Display a message on the console
disp('Stopping recording');

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);

% Get an estimate of the motor's rotation speed, by subtracting the previous position
% from the current position at each instance, and multiplying by the recording rate
size_results = size(results);
recording_rate = size_results(1) / 5;
motor_speed = [0; diff(results(:,2))];
motor_speed = motor_speed * recording_rate;

% The speed estimate will be noisy - this command will smooth it out
motor_speed = supsmu([1 : max(size(motor_speed))], motor_speed);

% Plot the results
plot(results(:,1), [results(:,2) motor_speed]);
grid on;
xlabel('time (s)');
ylabel('motor position/speed');
legend('position', 'speed');

% Display some information about the results
disp('The size of the results vector is:');
disp(size_results);
disp('The recording rate (samples per second) was:');
disp(recording_rate);

