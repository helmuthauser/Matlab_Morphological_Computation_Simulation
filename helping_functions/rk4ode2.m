function [t,x,v] = rk4ode2(func, a, b, x0, xd0, h, F);
% Solution of 2nd order ODE using Runge-Kutta 4th order
% with constant step size.  ODE solved is converted to
% two 1st order equations.  The RHS of the system is
%      dv/dt = func(t, x, v)
%      dx/dt = v
% See for example rhs_smd.m for forced spring-mass-damper
%
% USAGE:  [t, x, v] = rk4ode2(func,a,b,x0,xd0,h)
%
% input  func = name of external function to evaluate the RHS
%                  of the ODE (eg 'rhs_smd')
%        a, b = limits of integration
%        x0   = initial condition (position)
%        xd0  = initial condition (velocity)
%        h    = stepsize
%
% output [t, x, v]  = solution vectors
%
%  helmut.hauser@bristol.ac.uk

t = [a];
x = [x0];
v = [xd0];
i = 1;

while t(i) < b

   k1x = v(i);
   k1v = feval(func, t(i)    , x(i)         , v(i)        ,F );

   k2x = v(i)+k1v*h/2;
   k2v = feval(func, t(i)+h/2, x(i)+k1x*h/2 , v(i)+k1v*h/2 ,F);

   k3x = v(i)+k2v*h/2;
   k3v = feval(func, t(i)+h/2, x(i)+k2x*h/2 , v(i)+k2v*h/2 ,F);

   k4x = v(i)+k3v*h;
   k4v = feval(func, t(i)+h  , x(i)+k3x*h   , v(i)+k3v*h   ,F);

   i = i+1;
   t(i) = t(i-1) + h;

   x(i) = x(i-1) + (k1x + 2*k2x + 2*k3x + k4x)*h/6;
   v(i) = v(i-1) + (k1v + 2*k2v + 2*k3v + k4v)*h/6;

end

