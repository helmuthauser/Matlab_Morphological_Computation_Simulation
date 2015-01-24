function n = rand_in_range(range,a)
% returns rand values within a given range
% Note: uniformly distributed
% input: range	[lower,upper]  bound
%		 a	    [OPTIONAL] either a scalar or vector with the needed size 
%  			
% output: n     either one random value or a column vector of random values 
%  				and size a
% 
% helmut.hauser@bristol.ac.uk

 range(:);
 up = range(1,2);
 lo = range(1,1);
 
if (nargin==1)
 n = (up-lo)*rand(1,1)+lo;
else
 if(isscalar(a))
 	n = (up-lo)*rand(a,1)+lo;
 else
 	n = (up-lo)*rand(size(a))+lo*ones(size(a));
 end
end