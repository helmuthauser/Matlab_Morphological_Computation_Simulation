% learning pendulum equation
% helmut.hauser@bristol.ac.uk 
 
 % load data
close all;
clear all;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  making net 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = init_ms_sys_data;

% change parameters from default
% to ones that are appropiate for this task
data.num = 30; 		
data.show_steps = 1000;

% define ranges for the randomly intialized
% dynamic parameters of the springs
data.k_lim = [1 100;1 200];  
data.d_lim = [1 100;1 200];


data.show_plot = 0;
%  data.readout_type = 'POSITIONS';
data.readout_type = 'LENGTHS';


% initialize a random net with given values
net = init_ms_sys_net(data); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data_Volterra/volterra.mat');
 
% prepare learning data
wash_out = 60000;
start = 80000-wash_out; 
len = 200000+start;
len_test = 15000;
U = dat.u(start:len,1);  
Y = dat.yn(start:len,1); % using normalized data
Y = dat.y(start:len,1);
un = (mapstd(U'))';
yn = (mapstd(Y'))';

% prepare testing data
U_test = dat.u(len+1:len+len_test,1);  
Y_test = dat.yn(len+1:len+len_test,1); % using normalized data
un_test = (mapstd(U_test'))';
yn_test = (mapstd(Y_test'))';

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  simulating net 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[net2,sim_data] = simulate_ms_sys(net,U);
 
% learn output weights with linear regression
if (strcmp(net.readout_type,'LENGTHS'))
	X = sim_data.D(wash_out:end,:);  % throw first 100 steps away
else
	X = sim_data.Sx(wash_out:end,:);  % throw first 100 steps away
end

Yw = Y(wash_out:end,:);

W_out=X\Yw;


net_test = net2;
net_test.W_out = W_out;
o = X*W_out;

% in case you want to test how good the weights 
% represent the learnign dat
% figure;plot(o); hold on;plot(Yw,'r')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[net_test_out,sim_data_test] = simulate_ms_sys(net_test,U_test);



% plot results
figure;plot(yn_test,'r','LineWidth',1);
hold on;plot((mapstd(sim_data_test.O'))','--','LineWidth',1);
f1=gcf;a1=gca;
set(a1,'FontSize',14);
xlabel('timestep [ ]');
ylabel('[ ]');
title('Performance comparison')
legend('target output','system output')


% caculate and print MSE
disp(['MSE: ',num2str(mean_squared_error(yn_test,(mapstd(sim_data_test.O'))'))])


% plot the structure of the used network
plot_graph(net_test)




