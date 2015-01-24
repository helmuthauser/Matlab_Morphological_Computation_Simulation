function [x_]=nth_point(x,nth)
% just take every nth point 
% input:	x	vector to plot
%			nth	take every nth point
% output:	x_ new now smaller vector
% used to make plots smaller
%
% used for the function plot_one_period
%
% helmut.hauser@bristol.ac.uk

if(size(x,2)>size(x,1))
	x=x';
end

idx=0;

for i=1:nth:length(x)
	idx=idx+1;
	x_(idx,:) = x(i,:);
end
	