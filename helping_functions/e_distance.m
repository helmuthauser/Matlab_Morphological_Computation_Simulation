function [d,norm_dir]= e_distance(p1,p2)
%
% calculate euclidian distance between to 2D points
% 
% helmut.hauser@bristol.ac.uk

d = sqrt(  (p2(1,1)-p1(1,1))* (p2(1,1)-p1(1,1)) +  (p2(2,1)-p1(2,1))* (p2(2,1)-p1(2,1)));
if (d==0)
  norm_dir = zeros(size(p1));
else
 norm_dir = 1/d * (p2-p1);
end