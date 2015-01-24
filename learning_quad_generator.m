% learning to emulate the quadrdatic limit of [1] (figure 5e, page 604) 
%
%
% [1] Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "The role of feedback in morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2012, 106, 595-613
% http://www.springerlink.com/content/d54t39qh28561271/

% helmut.hauser@bristol.ac.uk

 
close all;
clear all;
% initialize a data struture that describes my range of possible networks
data = init_ms_sys_data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here you change different values of the data structure
% if you want them different from te default values
% See init_ms_sys_data in subfolder helping_files for more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change values for specific task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.timestep = 0.001;
data.num = 30;                  % total amount of masses 
data.w_fb_range = 10* [-1 +1];  % range for the feedback weights  
data.fb_conn  = 0.2;            % feedback connectivity 0.2 => 20% 

% size of the rectangle area to procduce 
data.p_xlim = [0 100];  
data.p_ylim = [0 100];

% amplitude of noise added to the position readout
data.pos_noise = 0.001; 

% we have no inputs, output should be produced autonomously
% we have two outputs (state variables x1 and x2)
data.nInputs  = 0;  
data.nOutputs  = 2;     

% every 1000 steps a log line is shown (
data.show_steps = 1000; 

%%%%%%%%%%%%% 
% defined range for the parameters of the polynomial function
% describing nonlinear stiffness and damping
data.d_lim = [100 200;0.1 2]; % damping constant (min max values)
data.k_lim = [100 200;1 10]; % spring constant (min max values)
%%%%%%%%%%%%%%%%%%

data.readout_type = 'LENGTHS'; % note if POSITIONS
data.show_plot = 0;  % don't show plot --> simulation is faster

% intialize randomly a network with the values of the given data structure
net = init_ms_sys_net(data);




%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading learning data
%%%%%%%%%%%%%%%%%%%%%%%%%%%

len = 80000; % amount of data points used

% loading data learning data (target)
load ('data_quad/quad_e=7.mat');         

% extract input and output data
U = tr_dat.U(1:len,1);
Y = tr_dat.Y(1:len,:);

% add noise to the output to increase stability of the learned 
% limit cycle
Yn= Y + 0.2*randn(size(Y));  
% this noise is necessary otherwise the system drifts away
% from the attractor when running freely

% data used to compare the compare the performance of the
% closed lo
len_val = 30000;
U_val = tr_dat.U(len:(len+len_val),1);
Y_val = tr_dat.Y(len:(len+len_val),:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  simulation of network   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% simulate the network with the given input 
% and collexct data in data structure sim_data
% net1 is the network in the final state right after simulation
% Note that systems runs in open loop as we provide target outputs 
% These are fed back instead of the actual ouput 
% This is called "teacher forcing"
[net1,sim_data] = simulate_ms_sys(net,U,Yn);

% definfe amount of washout
% to get rid if initial transitions
wash_out = 30000; 

% different internal signals are fetched depeding on the readout_type
if (strcmp(net.readout_type,'LENGTHS'))
	X = sim_data.D(wash_out:end,:);  % throw first steps away
else
	X = sim_data.Sx(wash_out:end,:);  % throw first steps away
end


% caculated the optimal readout weitghs Wo
% based on the calen data, i.e. without the washout data
% For linear regression the "\" operator is used to instead 
% of "inv", since this is more efficient and more robust.
Yw = Y(wash_out:end,:);
Wo=X\Yw;


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  testing by closing the loop   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

net1.pos_noise = 0.0; % switch off noise now 
net1.W_out = Wo;      % set the output weights to the optimal ones

% simulated the network starting with the latest state right after 
% learning, i.e., we use net1
% no output is provided -> output produced by the network 
% is fed back (loop is closed, system runs freely)
[net2,sim_data_2] = simulate_ms_sys(net1,U_val);


% plot outputs produced by the network vs. desired output Y_val
figure;plot(Y_val,'r','LineWidth',2);
hold on;plot(sim_data_2.O,'--','LineWidth',2);
f1=gcf;a1=gca;
set(a1,'FontSize',14);
xlabel('timestep []');
ylabel('[ ]');
title('Systems runs freely in closed loop')
legend('system output x_1','system output x_2','target x_1','target x_2')

% plot the structure of the produced network
plot_graph(net2)






