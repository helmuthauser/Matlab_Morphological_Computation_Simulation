% plot one period of quad equations
% 
% Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "Towards a theoretical foundation for morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2011, 105, 355-370 
% http://www.springerlink.com/content/j236312507300638/
%
% 
% helmut.hauser@bristol.ac.uk


close all;

nth=100;

len = 15000;
load('vanderPol.mat')
x=tr_dat.Y(1:len,:);
t = nth_point(linspace(0,len*0.001,len),nth);

figure;plot(t,nth_point(x,nth),'LineWidth',3);
f1=gcf;a1=gca;
set(a1,'FontSize',24);
xlabel('time [s]');
ylabel ('[ ]');
legend('x_1','x_2')
ylim([-3 3]);
title('one period of both state variables')

figure;plot(nth_point(x(:,1),nth),nth_point(x(:,2),nth),'r','LineWidth',3);
f2=gcf;a2=gca;
set(a2,'FontSize',24);
xlabel('x_1');
ylabel ('x_2');
xlim([-3 3])
title('phase plot')

