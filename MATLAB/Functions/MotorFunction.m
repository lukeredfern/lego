% Function to simplify use of motors
% e.g.   MotorFunction(90,50,'A')


function MotorFunction(Degrees,Power,MotorPort)



% Set up parameters for driving the motor
m = NXTMotor(MotorPort);
m.SmoothStart = 0; 
m.SpeedRegulation = 0; 
m.Power = Power;
m.TachoLimit = Degrees;
m
end