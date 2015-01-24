function n = rand_in_range_EXP(range,a)
% returns rand values within a given range
% distrubated exponentially
% exmaple: range = [0.1 10]
%	--> exp = [-1 2] --> draw out of that 
%	and n = exp() of that
% input: range	[lower,upper]  bound
%		 a	    [OPTIONAL] size needed 
%  
% output: n either one value or vector of random values 
%
% helmut.hauser@bristol.ac.uk

 range(:);
 up = range(1,2);
 lo = range(1,1);
 

if (nargin==1)
 n = (up-lo)*rand(1,1)+lo;
else
 range(:);
 up = log10(range(1,2));
 lo = log10(range(1,1));
%   n1 = (up-lo)*rand(size(a,1))+lo
 n = 10.^((up-lo)*rand(a,1)+lo);
 
end

