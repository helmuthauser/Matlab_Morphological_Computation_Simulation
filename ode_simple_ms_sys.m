function x_new = ode_simple_ms_sys(time_step,x,u)
%  
%  
% defining nonlinear spring damper function
% adapted for 2D
% just using a simple discretizing algorithm
%  x(1) = x
%  x(2) = y
%  x(3) = x_dot
%  x(4) = y_dot
%
% helmut.hauser@bristol.ac.uk

% first system x-dimension
x_new(1) = time_step*x(3) + x(1);   
x_new(3) = x(3)+time_step*u(1);     

x_new(2) = time_step*x(4) + x(2);   
x_new(4) = x(4)+time_step*u(2);     

