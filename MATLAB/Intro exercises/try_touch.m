% Establish connection with the NXT brick
MyNXT = COM_OpenNXT();
COM_SetDefaultNXT(MyNXT);

% Establish connection to a touch sensor connected to sensor port 1
OpenSwitch(SENSOR_1);

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
    % current touch sensor reading (second column)
    results = [results; toc  GetSwitch(SENSOR_1)];
end

% Display a message on the console
disp('Stopping recording');

% Close connection to the touch sensor
CloseSensor(SENSOR_1);

% Close connection to the NXT brick
COM_CloseNXT(MyNXT);

% Plot the results - with a dot per sample, so it is possible to
% zoom in and look for signs of switch bounce, for example
plot(results(:,1), results(:,2));
hold on; % lock the current graph, subsequent plots add to the existing graph
plot(results(:,1), results(:,2),'r.'); % plot the same data as red dots
hold off; % unlock the current graph
grid on;
xlabel('time (s)');
ylabel('touch sensor reading');

% Display some information about the results
size_results = size(results);
disp('The size of the results vector is:');
disp(size_results);
disp('The recording rate (samples per second) was:');
disp(size_results(1) / 5);
