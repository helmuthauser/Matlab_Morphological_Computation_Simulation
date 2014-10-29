% plot one period of quad equations
% 
% Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "Towards a theoretical foundation for morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2011, 105, 355-370 
% http://www.springerlink.com/content/j236312507300638/
%
% 
%hhauser@ifi.uzh.ch


close all;

nth=100;

len = 15000;
load('quad_e=7.mat')
x=tr_dat.Y(1:len,:);
t = nth_point(linspace(0,len*0.001,len),nth);
%  x2=tr_dat.Y(1:15000,1);
%  x1=tr_dat.Y(1:155,2);
%  figure;plot(x2);
%  figure;plot(x1);

figure;plot(t,nth_point(x,nth),'LineWidth',3);
f1=gcf;a1=gca;
set(a1,'FontSize',24);
xlabel('time [s]');
ylabel ('[ ]');
legend('x_1','x_2')
ylim([-0.8 0.8]);
title('one period of both state variables')

figure;plot(nth_point(x(:,1),nth),nth_point(x(:,2),nth),'r','LineWidth',3);
f2=gcf;a2=gca;
set(a2,'FontSize',24);
xlabel('x_1');
ylabel ('x_2');
xlim([-0.45 0.45])
title('phase plot')

