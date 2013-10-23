% Establish connection with the NXT brick
MyNXT = COM_OpenNXT('');
COM_SetDefaultNXT(MyNXT);

% Establish connection to an ultrasonic range sensor connected to sensor port 1
OpenUltrasonic(SENSOR_1);

% Reset the stopwatch
tic;

% Create an empty matrix to store the results
results = [];

% Display a message on the console
disp('Starting recording');

% Keep iterating while the stopwatch reads less than five seconds
while toc < 5
    % Add a new row to results
    % Each row stores the current time (first column) and the
    % current ultrasonic sensor reading (second column)
    results = [results; toc  GetUltrasonic(SENSOR_1)];
end

% Display a message on the console
disp('Stopping recording');

% Close connection to the ultrasonic sensor
CloseSensor(SENSOR_1);

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);

% Plot the results
plot(results(:,1), results(:,2));
grid on;
xlabel('time (s)');
ylabel('ultrasonic sensor reading');

% Display some information about the results
size_results = size(results);
disp('The size of the results vector is:');
disp(size_results);
disp('The recording rate (samples per second) was:');
disp(size_results(1) / 5);
