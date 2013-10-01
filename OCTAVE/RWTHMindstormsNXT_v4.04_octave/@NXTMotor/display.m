function display(N)
   fprintf ("%s = \n{\n", inputname(1));

   val = N.Port;
   if numel(val) <= 2
     fprintf("  Port = %d\n", val); 
   else
     fprintf("  Port = [ ");
     separator = '';
     for i = val
       fprintf("%s%d", separator, i);
       separator = ', ';
     endfor
     fprintf(" ]\n");
   end 

   fprintf ("  Power = %d\n", N.Power);
   fprintf ("  SpeedRegulation = %d\n", N.SpeedRegulation);
   fprintf ("  TachoLimit = %d\n", N.TachoLimit);
   fprintf ("  ActionAtTachoLimit = %s\n", N.ActionAtTachoLimit);
   fprintf ("  SmoothStart = %d\n", N.SmoothStart);
   fprintf (" [TachoCount = %d]\n", N.TachoCount); 
   fprintf (" [Position = %d]\n", N.Position);
   fprintf (" [IsRunning = %d]\n", N.IsRunning); 
   fprintf ("}\n");
end%function
