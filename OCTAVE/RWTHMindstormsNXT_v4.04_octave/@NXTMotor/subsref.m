function ret = subsref(n, s)
   if (isempty (s))
      error ("NXTMotor: missing index");
   endif

   switch (s(1).type)
      case "()"
         error("NXTMotor: () indexing not supported");
      case "{}"
         error("NXTMotor: {} indexing not supported");
      case "."
         fld = s(1).subs;
         switch (fld)
            case "Port"
	       ret = n.Port;
            case "Power"
               ret = n.Power;
            case "SpeedRegulation"
               ret = n.SpeedRegulation;
            case "TachoLimit"
               ret = n.TachoLimit;
            case "ActionAtTachoLimit"
               ret = n.ActionAtTachoLimit;
            case "SmoothStart"
               ret = n.SmoothStart;

# non-public properties
            case "TachoCount"
               ret = n.TachoCount;
            case "Position"
               ret = n.Position;
            case "IsRunning"
               ret = n.IsRunning;

            otherwise 
               if ((ismethod(n, fld)) && (s(2).type == "()")) 
                  if (strcmp(fld, "ReadFromNXT") || strcmp(fld, "WaitFor")) 
                     needsret = 1;
                  else 
                     needsret = 0;
                  end%if
                  switch (columns(s(2).subs))
                     case 0
                          if (needsret == 1)
                             ret = feval(fld, n);
                          else
                             feval(fld, n);
                             ret = 0;
                          end%if
                     case 1
                          if (needsret == 1)
                             ret = feval(fld, n, s(2).subs{1}); 
                          else
                             feval(fld, n, s(2).subs{1}); 
                             ret = 0;
                          end%if
                     case 2
                          if (needsret == 1)
                             ret = feval(fld, n, s(2).subs{1}, s(2).subs{2}); 
                          else
                             feval(fld, n, s(2).subs{1}, s(2).subs{2}); 
                             ret = 0;
                          end%if
                     otherwise
                       error("currently do not support methods with >2 args!");                  end%switch   
               else
                  error ("trying to view invalid property %s of NXTMotor type", fld);
               end
          endswitch
       otherwise
          error ("invalid subscript type");
    endswitch
end%function
