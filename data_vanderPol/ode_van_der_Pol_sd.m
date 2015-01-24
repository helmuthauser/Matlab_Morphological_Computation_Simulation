function [x_new] = ode_van_der_Pol_sd(x,epsilon,dt,u)
% numerical integration
% implementation of van der Pol equation 
%  
% input:	x			current state of the system
%			epsilon		constant -> shapes the limit cycle (see, e.g, Figure 2.19 in Kahlil "Nonlinear systems")
%			dt			time step delta t
%  			u			input (if necessary)
%
% output: 	x		state of the system after the integration step
%
% This code can be easily adapted to produce data for your own nonlinear
% limit cycles
%
% helmut.hauser@bristol.ac.uk


% if there is no input defined, set it to zero
if(nargin==3)
  u = 0;
end

x = x(:);

% diff equations
x_new(1,1) = x(1,1) + dt*x(2,1);
x_new(2,1) = x(2,1) - dt*x(1,1) + dt*epsilon*(1-x(1,1)^2)*x(2,1) + dt*u; 



