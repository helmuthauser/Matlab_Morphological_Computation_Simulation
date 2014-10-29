function f = rhs_mass_sym(t,x,xd,F);
% RHS of ODE for the mass systems
% used with rk4ode (runge kutta 4th order for
% two dimensional systems)
%
%  hhauser@ifi.uzh.ch
 
% 
m=1; 
f = 1/m*F;

