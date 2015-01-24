% producing data for the Volterra task as in 
% W_out=X\Yw;W_out=X\Yw;tr_dattr_dattr_datrewrite volterra series
% making data with gauss kernel with mu not being at zero
% which means there is a delay
%
% helmut.hauser@bristol.ac.uk


clear all;
close all;


time_step = 0.001; 

len_h = 0.2; % in seconds (length of the total kernel)
t=linspace(0,len_h,len_h/time_step);

h2=zeros(size(t));


% producing a discretized verions
% of the kernel 
for i=1:length(t)
	for j= 1:length(t)
		h2(i,j) = gauss_kernel_2D(time_step,t(1,i),t(1,j),[0.1 0.1],[0.05 0.05]);
	end 
end


%  plotting the resulting kernel 
%  figure;surf(h2);
%  return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   convolution with the kernel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = 500; % in seconds

t  = linspace(0,len,len/time_step);
f1 = 2.11; % Hz
f2 = 3.73;
f3 = 4.33;
x = sin(2*pi*f1*t).*sin(2*pi*f2*t).*sin(2*pi*f3*t);
% add zeros to avoid problems with the indices
x = horzcat(zeros(1,len_h/time_step),x); 


y = zeros(1,length(x));

% VOLTERRA loop
for i=len_h/time_step+1:length(x)  % time loop
	sum_1 = 0;
	if(mod(i,1000)==0)
 	  disp([' i = ' ,num2str(i),' of ',num2str(length(x))]);
 	end	
	for m1 = 0:len_h/time_step-1
		sum_2 =0;
 		for m2 = 0:len_h/time_step-1
			sum_2 = sum_2 + h2(1+m1,1+m2)*x(1,i-m1)*x(1,i-m2);
 		end
 		sum_1 = sum_1+sum_2;
 	end
 	y(1,i) = sum_1;
end



% interpolate to get a time step of 1ms
y_ = interp(y,time_step/0.001);
x_ = 0.2*interp(x,time_step/0.001);
% normalize output data
yn_ = (mapstd(y_'))'; 


% pack data into one data structure
dat.info = 'three sinus';
dat.u = x_';
dat.y = y_';
dat.yn = (mapstd(dat.y'))'; 

% plot results
t_ = linspace(0,length(x_)*0.001,length(x_));
figure;plot(t_,x_)
hold on;plot(t_,y,'r')
f1=gcf;a1=gca;
set(a1,'FontSize',24);
title('Volterra series')
legend('input','output')
xlim([0,200]);xlabel('time [s]');ylabel('[ ]')


