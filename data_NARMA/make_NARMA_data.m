%  making the same examples as in the NARMA-L2 paper
%  Article (Narendra97) Narendra, K. S. & Mukhopadhyay, S. 
%  "Adaptive Control Using Neural Networks and Approximate Models" 
%  IEEE TRANSACTIONS ON NEURAL NETWORKS, 1997, 8, 475-485
% 
% helmut.hauser@bristol.ac.uk

close all;
clear all;


range = [-1 1]; % drive goes from 1 to 5

total_time = 500;
cuttoff = 1000; 
time_step = 0.001;
len = total_time/time_step;

t=linspace(0,total_time,total_time/time_step)';

TYPE = 'NARMA-L2';
disp(['type = ',TYPE]);

switch TYPE


	case 'NARMA-L2'
		f1 = 2.11; % Hz
		f2 = 3.73;
		f3 = 4.33;
		u = 0.1*(sin(2*pi*f1*t).*sin(2*pi*f2*t).*sin(2*pi*f3*t));
		
		y = zeros(size(u));
		u(1:10,1) = zeros(10,1);
		for k=11:len			
			y(k,1) = 0.3*y(k-1,1) + 0.05*y(k-1,1)*(sum(y(k-10:k-1,1))) + 1.5*u(k-10,1)*u(k-1,1) + 0.1;
        end
		
 % place for other NARMA systems
  
	
end

% cuttoff 
% and normalize

un = mapstd(u(cuttoff:end,1)')';
yn = mapstd(y(cuttoff:end,1)')';

dat.un = un;
dat.yn = yn;
dat.type  = TYPE;

figure;plot(dat.un);hold on;plot(dat.yn,'r')
legend('input','output')
