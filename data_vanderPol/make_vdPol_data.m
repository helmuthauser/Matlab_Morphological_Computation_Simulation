% make data with van der Pol
% can be adapated to make your own 
% limit cycle data set
%
% helmut.hauser@bristol.ac.uk
close all;


% defining a time vector 
time_step = 0.001;
init_phase = 20; %part that will be remove later 
data_time = 500;
total_time = data_time+init_phase;
t = linspace(0,total_time,total_time/time_step);

% initialize the matrix
X = zeros(2,length(t));
X(:,1) = [3;3]; % intial values
idx = 1;


% simulate van der Pol equations
for i=1:length(t)-1
	idx = idx+1;
    X(:,idx) = ode_van_der_Pol_sd(X(:,idx-1),0.8,time_step,0.0);
end

% get rid of initial phase
X_trunc = X(:,init_phase/time_step+1:end);

% plot results
figure,plot(X_trunc(1,:)',X_trunc(2,:)');
f1=gcf;a1=gca;
set(a1,'FontSize',24);
title('phase portrait')
xlabel('x_1');
ylabel ('x_2');
ylim([-3 3]);


figure,plot(X_trunc');
f2=gcf;a2=gca;
set(a2,'FontSize',24);
xlabel('timesteps []');
ylabel ('[ ]');
legend('x_1','x_2')
ylim([-3 3]);
title('state variables x_1 and x_2')


% put data input into useable format 
tr_dat.U = zeros(size(X_trunc,2),1);
tr_dat.Y = X_trunc';


% to save data
% save('vanderPol.mat','tr_dat')

