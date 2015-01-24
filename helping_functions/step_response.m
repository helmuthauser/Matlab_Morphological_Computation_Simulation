function [sim_data] = step_response(net,len,factor,show_plot)
%  general step response for real mass-srping networks
%  input:	net			net structure
%			len			number of data points to simulate
%			factor  	multiplicative factor for the constant input
%  						factor = 1		step response
%						factor = 0 		input is IMPULSE response
%			[show_plot]	showing plots of the result [optional] - default is yes
%
% helmut.hauser@bristol.ac.uk
% 13th Jan. 2009
% adapted: multiple inputs are now possible
%
if nargin == 1 
   len = 10000;
   factor = 1;
   show_plot = 1;
end
if nargin == 3
	show_plot = 1;
end

if factor==0
	disp('impulse response')
	[net,sim_data] = simulate_ms_sys(net,[ones(size(net.W_in,2));zeros(len-1,size(net.W_in,2))]);
else
    disp('step response')
	[net,sim_data] = simulate_ms_sys(net,factor*ones(len,size(net.W_in,2)));
end

if(show_plot==1)
	disp('plotting');
	figure;plot(sim_data.O);
end
