

% Constants
SpringOriginalLength = 0.03;  % m
SpringConstant = 250;         % N/m
BeamWidth = 0.03;             % m
BeamDepth = 0.001;            % m

% Calibration
MotorCalibration = 0.0365/1300; % m/deg
BeamLength = 0.25;              % m

% Prelim Calcs
SecondMomentArea = (BeamDepth^3*BeamWidth)/12; % m^4

% Call peak finding routine
% Load data
load results.dat

% We expect five peaks/valleys in the results trace
halfwidth = max(size(results))/20;

% Find peaks and valleys
P = findvalleys([1:size(results)], -results, Inf, -Inf, halfwidth, halfwidth, 3);
peaks = P(:,2);
P = findvalleys([1:size(results)], results, -Inf, -Inf, halfwidth, halfwidth, 3);
valleys = P(:,2);

% Display results
figure(1);
plot(results, 'b');
hold on;
for i=1:size(peaks)
   plot([peaks(i) peaks(i)], [min(results) max(results)],'r');
end
for i=1:size(valleys)
   plot([valleys(i) valleys(i)], [min(results) max(results)],'m');
end
hold off
grid on
xlabel('Motor Rotations (degs)')
ylabel('Light Intensity')
title('Light sensor readings with peaks and valleys shown')

% Merge peak and valley data
Intervals=[peaks;valleys];
Intervals=sort(Intervals);


% Create empty vectors for storing data
BeamDeflection = [];
SpringForce = [];

% Offset motor Rotation
MotorOffset = Intervals(1);

% 1st peak - Assume that the there is no deflection at first reading.
% This is OK as we are only looking at gradients
BeamDeflection(1) = 0;
BottomSpring = 0;
LengthChangeSpring = BottomSpring - BeamDeflection(1);
SpringForce(1) = LengthChangeSpring * SpringConstant;

% Other Peaks
for i=2:length(Intervals)

BeamDeflection(i) = 0.0005*(i-1);   % m
BottomSpring = (Intervals(i) - MotorOffset) * MotorCalibration;
LengthChangeSpring = BottomSpring - BeamDeflection(i);
SpringForce(i) = LengthChangeSpring * SpringConstant;

end%for


% Calculate Gradient of line
LineOfBestFit = fit(BeamDeflection', SpringForce',  'poly1');
LineGradient = LineOfBestFit.p1;

% Plot line of best fit
figure(2)
scatter(BeamDeflection,SpringForce);
hold on
plot(BeamDeflection,LineOfBestFit.p1 * BeamDeflection + LineOfBestFit.p2, 'r')
hold off
xlabel('Beam Deflection (m)')
ylabel('Spring Force (N)')
title('Force-Deflection graph with line of best fit shown')
grid on

% Beam Calc
YoungsModulous = (LineGradient * BeamLength^3) / (48 * SecondMomentArea);
format short
text(0.00025,4.5,['Youngs modulous = ',num2str(YoungsModulous/(1e+9)),' GPa'])

