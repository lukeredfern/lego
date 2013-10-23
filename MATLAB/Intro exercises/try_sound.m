% Establish connection with the NXT brick
MyNXT = COM_OpenNXT();
COM_SetDefaultNXT(MyNXT);

% Establish connection to a sound sensor (microphone) connected to sensor port 1
% Use DB mode (i.e. decibels, a logarithmic scale for the sound intensity)
OpenSound(SENSOR_1, 'DB');

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
    % current sound sensor reading (second column)
    results = [results; toc  GetSound(SENSOR_1)];
end

% Display a message on the console
disp('Stopping recording');

% Close connection to the sound sensor
CloseSensor(SENSOR_1);

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);

% Plot the results
plot(results(:,1), results(:,2));
grid on;
xlabel('time (s)');
ylabel('sound sensor reading');

% Display some information about the results
size_results = size(results);
disp('The size of the results vector is:');
disp(size_results);
disp('The recording rate (samples per second) was:');
disp(size_results(1) / 5);
