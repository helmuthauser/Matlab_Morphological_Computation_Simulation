% demonstration of learning to emulate a NARMA system
% as in publications
%
% [1] Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "The role of feedback in morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2012, 106, 595-613
% http://www.springerlink.com/content/d54t39qh28561271/
%
%
% helmut.hauser@bristol.ac.uk
%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  constructing network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init data structure with default values
data = init_ms_sys_data;  


% change values to fit the task
	
data.num = 30; 			% number of masses
data.show_steps = 1000; % show simulation step every 5000 steps


% range for randomly initialized input weights
data.in_range = [-1 1];  

% defined area for the masses to be places
data.px_lim = [0 10];
data.py_lim = [0 10];

%  defining parameter ranges for
%  spring properties (
%  i.e., nonlinear stiffness and damping functions
data.k_lim = [1 100; 10 100];  
data.d_lim = [1 100; 10 100];



data.show_plot = 0;
data.readout_type = 'LENGTHS'; % using lengths as readout


%  randomly initialize a network 
%  with the given parameter
net = init_ms_sys_net(data); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading data for learning and testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data_NARMA/NARMA-L2.mat');


% defines data length of learning data, testing data and washout time
wash_out = 60000;		
start = 50000; 
len = 260000;
len_test = 15000;
U = dat.un(start:len,1);  
Y = dat.yn(start:len,1); 

% testing data is taken from another part of the data set
dat_test = dat;  
U_test = dat_test.un(len+1:len+len_test,1);  % use later data for testing
Y_test = dat_test.yn(len+1:len+len_test,1);  

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  simulating network 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[net2,sim_data] = simulate_ms_sys(net,U);
 
% calculate optimal output weights with linear regression
if (strcmp(net.readout_type,'LENGTHS'))
	X = sim_data.D(wash_out:end,:);  % throw washout away
else
	X = sim_data.Sx(wash_out:end,:);  % throw washout away
end

Yw = Y(wash_out:end,:);
W_out=X\Yw;

 
% start testing with the state right after the learning phase
net_test = net2;

% set output weights to the optimal ones.
net_test.W_out = W_out;

% this can be used to check how good the learned, optimal weights
% represent the learned data
%  o = X*W_out;
%  figure;plot(o); hold on;plot(Yw,'r')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[net_test_out,sim_data_test] = simulate_ms_sys(net_test,U_test);

% plot results
figure;plot(Y_test,'r','LineWidth',1);
hold on;plot(sim_data_test.O,'--','LineWidth',1);
f1=gcf;a1=gca;
set(a1,'FontSize',14);
xlabel('timestep [ ]');
ylabel('[ ]');
title('Performance comparison')
legend('target output','system output')


disp(['MSE: ',num2str(mean_squared_error(Y_test,sim_data_test.O))])



% plot the structure of the produced network
plot_graph(net_test)



