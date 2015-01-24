function [h] = gauss_kernel_2D_zeromu(A,x1,x2,mu,sigma)
% 2-dimensional Gaussian kernel 
% used to produce the Volterra series
%
% helmut.hauser@bristol.ac.uk


h = A*exp( - ((x1-mu(1,1))^2/(2*sigma(1,1)^2) + (x2-mu(1,2))^2/(2*sigma(1,2)^2)) );

