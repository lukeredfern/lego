function [toc_time] = matlab_toc(tic_time)
% Replicates the Matlab toc function with one argument
%  
% Syntax
%   matlab_toc(tic_time) 

if nargin ~= 1
    error('MATLAB:RWTHMindstormsNXT:matlab_toc', ['matlab_toc requires one argument']);
end

toc_time = (double (tic ()) - double (tic_time)) * 1e-6;

end%function

