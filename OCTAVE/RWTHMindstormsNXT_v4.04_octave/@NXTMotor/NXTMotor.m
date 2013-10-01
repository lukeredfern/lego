function obj = NXTMotor(varargin)
% Constructs an NXTMotor object
%
% Syntax
% M = NXTMotor()
%
% M = NXTMotor(PORT)
%
% M = NXTMotor(PORT, 'PropName1', PropValue1, 'PropName2', PropValue2, ...)
%
% Description
%     M = NXTMotor(PORT) constructs an NXTMotor object with motor
%     port PORT and default attributes. PORT may be either the port
%     number (0, 1, 2 or MOTOR_A, MOTOR_B, MOTOR_C) or a string
%     specifying the port ('A', 'B', 'C'). To have two motors
%     synchronized PORT may be a vector of two ports in ascending
%     order. 
%
%     M = NXTMotor(PORT, 'PropName1', PropValue1, 'PropName2', PropValue2, ...)
%     constructs an NXTMotor object with motor port(s) PORT in which the given
%     Property name/value pairs are set on the object. All properties can also be set after
%     creation by dot-notation (see example). 
%
%     Available properties are:
% 
% * Port - the motor port(s) being used, either a string composed of the
%          letters 'A', 'B', 'C', or a single value or array of the
%          numbers 0, 1, 2. A maximum of 2 motors is allowed. If 2 motors
%          are specified, the bot will drive in sync mode, good for driving
%          straight ahead.
%
% * Power - integer from -100 to 100, sets power level and direction of rotation (0 to 100%)
%
% * SpeedRegulation - if set to true (default), the motor will try to hold a
%           constant speed by adjusting power output according to load (e.g.
%           friction) - this is only valid for single motors. It must be
%           deactivated when using two motors! If you'd like to have motor movement
%           with preferrably constant torque, it's advisable to disable
%           this option.
%     SpeedRegulation must be false for "normal", unregulated motor
%     control. If set to true, single motors will be operated in speed
%     regulation mode. This means that the motor will increase its internal
%     power setting to reach a constant turning speed. Use this option when
%     working with motors under varying load. If you'd like to have motor movement
%           with preferrably constant torque, it's advisable to disable
%           this option.
%     In conjunction with multiple motors 
%     (i.e. when Port is an array of 2 ports), you have to disable
%     SpeedRegulation! Multiple motors will enable synchronization between the two
%     motors. They will run at the same speed as if they were connected
%     through and axle, leading to straight movement for driving bots.
%
% * TachoLimit - integer from 0 to 999999, specifies the angle in degrees
%               the motor will try to reach, set 0 to run forever. Note
%               that direction is specified by the sign of Power.
%
% <html>
%  <ul>
%  <li> <code>ActionAtTachoLimit</code> is a string parameter with valid options
%   <code>'Coast'</code>, <code>'Brake'</code> or <code>'HoldBrake'</code>.
%   It specifies how the motor(s) should react
%   when their position counter reaches the set
%   <code>TachoLimit</code>.<br><br>
%   <ul>
%   <li> In COAST
%     mode, the motor(s) will simply be turned of when the <code>TachoLimit</code> is
%     reached, leading to free movement until slowly stopping (called
%     coasting). The <code>TachoLimit</code> won't be met, the motor(s) move way too far
%    (overshooting), depending on their angular momentum.<br><br>
%   <li> Use BRAKE mode (default) to let the motor(s) automatically
%     slow down nice and smoothly shortly before the <code>TachoLimit</code>. This leads
%     to a very high precision, usually the <code>TachoLimit</code> is met within +/- 1
%     degree (depending on the motor load and speed of course). After this
%     braking, power to the motor(s) is turned off when they are at
%     rest.<br><br>
%   <li> HOLDBRAKE is similar to BRAKE, but in this case, the active brake of
%     the motors stays enabled (careful, this consumes a lot of battery
%     power), causing the motor(s) to actively keep holding their
%     position.<br>
%   </ul>
%  </ul>
% </html>
%
% * SmoothStart can be set to true to smoothly accelerate movement.
%   This "manual ramp up" of power will occur fairly quickly. It's
%   comfortable for driving robots so that they don't loose traction when
%   starting to move. If used in conjunction with SpeedRegulation for
%   single motors, after accleration is finished and the full power is
%   applied, the speed regulation can possibly even accelerate a bit more.
%   This option is only available for TachoLimit > 0 and
%   ActionAtTachoLimit = 'Brake' or 'HoldBrake'.
%
%   For a list of valid methods, see the "See also" section below.
%
% Note:
% 
%   When using a motor object with two ports set, the motors will be
%   operated in synchronous mode. This means an internal regulation of the
%   NXT firmware tries to move both motors at the same speed and to the
%   same position (so that driving robots can go a straight line for example). With ActionAtTachoLimit == 'Coast' the sync mode will stay
%   enabled during coasting, allowing for the firmware to correct the
%   robot's position (align it straight ahead again). If you want to use
%   those motors again, you must reset/stop the synchonization before by
%   sending a .Stop() to the motors!
%
%
% Limitations 
%   If you send a command to the NXT without waiting for the previous motor
%   operation to have finished, the command will be dropped (the NXT
%   indicates this with a high and low beep tone). Use the classes method WaitFor
%   to make sure the motor is ready for new  commands, or stop the motor
%   using the method .Stop.
%
%   The option SmoothStart in conjunction with ActionAtTachoLimit ==
%   'Coast' is not available. As a workaround, disable SmoothStart for
%   this mode. SmoothStart will generally only work when TachoLimit > 0
%   is set.
%
%   With ActionAtTachoLimit = 'Coast' and synchronous driving (two motors),
%   the motors will stay synced after movement (even after .WaitFor() has
%   finished). This is by design. To disable the synchonization, just use
%   .Stop('off').
%
%
%   SpeedRegulation = true does not always produce the expected result.
%   Due to internal PID regulation, the actually achieved speed can vary or
%   oscillate when using very small values for Power. This happens
%   especially when using the motor with a heavy load for small speeds. In
%   this case it can be better to disable SpeedRegulation. In general,
%   speed regulation should only be enabled if a constant rotational
%   velocity is desired. For constant torque, better disable this feature.
%
%   
% Example:
%      % Construct a NXTMotor object on port 'B' with a power of
%      % 60, disabled speed regulation, a TachoLimit of 360 and
%      % send the motor settings to the NXT brick.
%      motorB = NXTMotor('B', 'Power', 60)
%
%      motorB.SpeedRegulation     = false;
%      motorB.TachoLimit          = 360;
%      motorB.ActionAtTachoLimit  = 'Brake'; % this is the default anyway
%      motorB.SmoothStart         = true;
%
%      % enough setting up params, let's go!
%      motorB.SendToNXT();
%      % let MATLAB wait until the motor has stopped moving
%      motorB.WaitFor();
%
%      % Play tone when motor is ready to be used again
%      NXT_PlayTone(400,500);
%
%
%      % let's use a driving robot
%      m = NXTMotor('BC', 'Power', 60);
%      m.TachoLimit         = 1000;
%      m.SmoothStart        = true,    % start soft
%      m.ActionAtTachoLimit = 'coast'; % we want very smooth "braking", too :-)
%      m.SendToNXT();                  % go!
%
%      m.WaitFor();                    % are we there yet?
%
%      % we're here, motors are still moving / coasting, so give the bot time!
%      pause(3);
%
%      % you can still hear the synchronization (high noisy beeping)
%      % before we go back, we have to disable the synchronization quickly
%      m.Stop();
%
%      % reverse direction
%      m.Power = -m.Power;
%      m.SendToNXT();
%      m.WaitFor();
%      pause(3);
%      m.Stop();
%
%      NXT_PlayTone(500, 100); % all done
%
%
% See also: SendToNXT, ReadFromNXT, WaitFor, Stop, ResetPosition,
% DirectMotorCommand
%
%
% Signature
%   Author: Linus Atorf, Aulis Telle, Alexander Behrens (see AUTHORS)
%   Date: 2009/08/24
%   Copyright: 2007-2010, RWTH Aachen University
%
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

            obj.Port               = 0;
            obj.Power              = 0;
            obj.SpeedRegulation    = 1;
            obj.TachoLimit         = 0;
            obj.ActionAtTachoLimit = 'Brake';
            obj.SmoothStart        = 0;
            obj.TachoCount         = 0;
            obj.Position           = 0;
            obj.IsRunning          = 0; 

            obj = class(obj, "NXTMotor");
            
            propertyArgIn = varargin;

            % check, whether first argument is a port specification
            if nargin > 0
                idx.type = '.';
                idx.subs = "Port";
                obj = subsasgn(obj, idx, propertyArgIn{1});
                
                % disable SpeedRegulation if two motors are addressed
                %  synchron modus --> disable SpeedRegulation
                if numel(propertyArgIn{1}) > 1
                    idx.type = '.';
                    idx.subs = "SpeedRegulation";
                    obj = subsasgn(obj, idx, false);
                end

                if nargin >= 2
                    propertyArgIn = propertyArgIn(2:end);
                else
                    propertyArgIn = {};
                end
                
                while length(propertyArgIn) >= 2
                    prop = propertyArgIn{1};
                    val  = propertyArgIn{2};
                    if length(propertyArgIn) >= 3
                        propertyArgIn = propertyArgIn(3:end);
                    else
                        propertyArgIn = {};
                    end
                    
%                    switch prop
%                        case 'Power'
%                            obj.Power = val;
%                        case 'SpeedRegulation'
%                            obj.SpeedRegulation = val;
%                        case 'TachoLimit'
%                            obj.TachoLimit = val;
%                        case 'ActionAtTachoLimit'
%                            obj.ActionAtTachoLimit = val;
%                        case 'SmoothStart'
%                            obj.SmoothStart = val;
%                        otherwise
%                            error('MATLAB:RWTHMindstormsNXT:invalidStringParameter',...
%                                'Unsupported parameter %s',...
%                                varargin{argIterator});
%                    end % end switch
                    idx.type = '.';
                    idx.subs = prop;
                    obj = subsasgn(obj, idx, val);

                end % end while
            end % end if nargin > 0
        end % end function
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
