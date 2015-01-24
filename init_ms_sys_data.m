function d = init_ms_sys_data()
%
% init a data structure with default values 
% needed to construct a mass-spring systems as used in
%  
% Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "The role of feedback in morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2012, 106, 595-613
% http://www.springerlink.com/content/d54t39qh28561271/
%
% and
%
% Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
% "Towards a theoretical foundation for morphological computation with compliant bodies"
% Biological Cybernetics, Springer Berlin / Heidelberg, 2011, 105, 355-370 
% http://www.springerlink.com/content/j236312507300638/
%
% helmut.hauser@bristol.ac.uk



% basic simulation data
d.time_step = 0.001;  	% time step (should be really small to have a stable integration)
d.show_steps = 1000;   	% shows every "show_steps" steps on the disp where the simulation is at

% define type and amplitude of noise 
% needed to improve stability when learning generators (e.g. limit cycles)
d.pos_noise = 0;    	% noise on the position sensors sim_data.Sx and sim_data.Sy
d.dist_noise = 0; 		% adding noise to the distance d (internal noise)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defining structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d.num = 10;   		% number of mass points
% ranges for random values
d.p_xlim =[0 10];  	% x-positions of of mass points
d.p_ylim =[0 10];  	% y-positions of of mass points
%  d.m_lim  =[0.1 1];  % masses NOT used right now
% nonlinear factors
% example [c1; c2] => c1*x^3 + c2*x
d.k_lim  =[100 200; 1 10];     % k spring constants range
d.d_lim  =[100 200; 1 10];     % d damping constants range


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input and output connections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d.nInputs = 1; 				% number of inputs
d.in_conn  = 0.2; 		 	% input connectivity procentage
d.w_in_range = [-1 +1]; 	% range of random input connections
d.nOutputs = 1; 			% number of inputs
d.out_conn  = 1; 		 	% output connectivity (1=100% all nodes)
d.w_out_range = [-1 +1]; 	% range of output connections
d.w_fb_range = [-1 +1];     % range for feedback weights
d.fb_conn  = 0.0;  			% feedback connectivity 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d.show_plot = 1;  		% show a plot of the structure after initialisation
d.save_sim_data = 0; 	% simulation data should be saved during simulation (0 -> speed up simulation)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d.readout_type = 'LENGTHS'; % type of readout - either POSITIONS or LENGTHS
							


