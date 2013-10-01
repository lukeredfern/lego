function obj = subsasgn(obj, idx, val)

if (isempty (idx))
   error ("NXTMotor: missing index");
endif

switch (idx(1).type)
   case "()"
      error("NXTMotor: () indexing not supported");
   case "{}"
      error("NXTMotor: {} indexing not supported");
   case "."
      fld = idx.subs;
      switch (fld)
        case "Port"
            if numel(val) <= 2
                % Convert to numeric representation (65 == 'A')
                if ischar(val)
                    val = double(upper(val)) - 65;
                end

                % Check, if any port is out of the alt range
                if any(val < 0) || any (val > 2)
                    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort',...
                        'One or more of the given ports are invalid.');
                end

                % Check, if ports are given in ascending order by
                % taking the difference of successive values. If any
                % of them is lower zero they are not in ascending order
                if (numel(val) == 2) && (val(1) >= val(2))
                    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort',...
                        'Two ports must not be the same and must be given in ascending order.');
                end

                % check for non-integer values
                if any(rem(val,1) > 0)
                    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort',...
                        'Port is not an integer or port label.');
                end

                obj.Port = val;
                
%                 % disable SpeedRegulation if two motors are addressed
%                 %  synchron modus --> disable SpeedRegulation
%                 % note: silent changing, warning is not appropriate, since the default value of
%                 % SpeedRegulation is true. Thus, any constructor command with two motors would
%                 % throw a warning.
%                 if numel(val) > 1
%                     obj.SpeedRegulation = false;
%                 end
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort',...
                    'No more than two ports may be specified.');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        case "Power"
            % Power must be a scalar, be numeric, be an integer and be in the range [-100 100]
            if isscalar(val) && isnumeric(val) && abs(val) <= 100 && all(rem(val,1) == 0)
                obj.Power = val;
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidPower',...
                    'Power must be a numeric scalar and integer in the range [-100, 100].');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case "SpeedRegulation"
            % SpeedRegulation must be a scalar and numeric or a boolean
            if isscalar(val) && (isnumeric(val) || islogical(val))
                obj.SpeedRegulation = logical(val);
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidSpeedRegulation',...
                    'SpeedRegulation must be a boolean.');
            end
%             % check if more than one port is addressed (synchron modus)
%             if (numel(obj.Port) > 1) && (val)
%                 error('MATLAB:RWTHMindstormsNXT:InvalidSpeedRegulation',...
%                     'SpeedRegulation can only applied to one motor (no synchron motors).');
%             end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case "TachoLimit"
            % TachoLimit must be a scalar, be numeric and be an integer
            if isscalar(val) && isnumeric(val) && val >= 0 && all(rem(val,1) == 0) && (val < 999999)
                obj.TachoLimit = val;
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidTachoLimit',...
                    ['TachoLimit must be a non-negative numeric scalar and an integer < 999999.', ...
                    ' Zero means running forever.']);
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case "ActionAtTachoLimit"
            % ActionAtTachoLimit must be a string
            if ischar(val) && (strcmpi(val, 'coast') || strcmpi(val, 'brake') || strcmpi(val, 'holdbrake'))
                obj.ActionAtTachoLimit = val;
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidActionAtTachoLimit',...
                    'Possible values for ActionAtTachoLimit are ''Coast'' (turn off motor at TachoLimit), ''Brake'' (brake until motor has stopped at TachoLimit, then turn it off), ''HoldBrake'' (same as ''Brake'', but keep active brake enabled).');
            end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        case "SmoothStart"
            % SmoothStart must be a scalar and numeric or a boolean
            if isscalar(val) && (isnumeric(val) || islogical(val))
                obj.SmoothStart = logical(val);
            else
                error('MATLAB:RWTHMindstormsNXT:Motor:invalidSmoothStart',...
                    'SmoothStart must be a boolean.');
            end

# non-public properties
        case "TachoCount"
            obj.TachoCount = val;
        case "Position"
            obj.Position = val;
        case "IsRunning"
            obj.IsRunning = val;

        otherwise 
	    error ("trying to set invalid property %s of NXTMotor type", fld);
        
   end%switch
end
