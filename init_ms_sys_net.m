function net = init_ms_sys_net(d)
%  
%   inits a mass-spring net with values from a data_structure
%  
%   input:	d [OPTIONAL] 	data structure which defines values of the net 
%  							(see init_ms_sys_data in same directory)%
%   output: net				ready to simulate mass-spring net
%  
% helmut.hauser@bristol.ac.uk
% for more info see paper
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

if nargin==0
    % with no specific data structure default values are used
	d = init_ms_sys_data();
end

% copy init data information to the net structure
% to have data available later if changes are made
net.init_data = d; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% random initialisation values and find
% connections with delaunay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRUCTURE of P (information of the point)
net.P.states(:,1) = rand_in_range(d.p_xlim,d.num);
net.P.states(:,2) = rand_in_range(d.p_ylim,d.num);
net.P.states(:,3) = zeros(d.num,1);
net.P.states(:,4) = zeros(d.num,1);
net.P.force       = zeros(d.num,2);  % force acting on the point fx,fy 
net.P.fixed       = zeros(d.num,1);

% saving initial position and velocities of P (for reseting)
net.init_data.P = net.P;


%%%%%%%%%%%%%%%%%%%%%
% different noises
%%%%%%%%%%%%%%%%%%%%%
net.pos_noise = d.pos_noise;  	% noise on the position sensors sim_data.Sx and sim_data.Sy
net.dist_noise = d.dist_noise;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixing points (which ones ??)
% find the most left one (maybe some more)
min_idx = find(net.P.states(:,1)==min(net.P.states(:,1)));   % most left one min(x)
max_idx = find(net.P.states(:,1)==max(net.P.states(:,1)));   % most right on max(x)
net.P.fixed(min_idx,1)=1; % fix the most left on
net.P.fixed(max_idx,1)=1; % fix the most right on




% triangulation with Delaunay
% avoids crossing springs
tri=delaunay(net.P.states(:,1),net.P.states(:,2));


net.init_data.tri = tri;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% connection input to liquid and liquid to output
% not yet done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% making a list of connection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tri_s = sort(tri,2); % sorting
R = zeros(d.num,d.num);
for i=1:size(tri,1)
  from = tri_s(i,1);to   = tri_s(i,2);  % 1 --> 2
  R(from,to)=1;
  from = tri_s(i,2);to   = tri_s(i,3);  % 2 --> 3
  R(from,to)=1;
  from = tri_s(i,1);to   = tri_s(i,3);  % 1 --> 3
  R(from,to)=1;
end
%  figure;imagesc(R);
w_num = sum(sum(R));
net.W.from = zeros(w_num,1);	  % index of from point
net.W.to   = zeros(w_num,1);    % index of from point
net.W.k1   = rand_in_range_exp(d.k_lim(2,:),w_num); % random spring constants
net.W.k3   = rand_in_range_exp(d.k_lim(1,:),w_num); % random spring constants
net.W.d1   = rand_in_range_exp(d.d_lim(2,:),w_num); % random damping constants
net.W.d3   = rand_in_range_exp(d.d_lim(1,:),w_num); % random damping constants
%  W.k    = 10*ones(3,1);  % for debuggin reasons
%  W.d    = 3*ones(3,1);   % for debuggin reasons
net.W.l0   = zeros(w_num,1);
net.W.dist_old = zeros(w_num,1);
w_idx=0;
for i=1:d.num
   for j=1:d.num
     if(R(i,j)==1)
        % assuming starting positions as point of equilibrium
        w_idx = w_idx+1;
        net.W.from(w_idx,1) = i; 
        net.W.to(w_idx,1)   = j;
        net.W.l0(w_idx,1) = e_distance(net.P.states(i,1:2)',net.P.states(j,1:2)');
     end % if   
   end
end
net.W.dist_old(:,1) = net.W.l0(:,1); % no velocity to begin with (= no damping)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   finished making unique connection list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data (getting from outside)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  in_conn  = 0.2; % input connectivity procentage
net.W_in = zeros(d.num,d.nInputs);
nmax = ceil(d.num*d.in_conn);
for nI = 1:d.nInputs
   Idx = randperm(d.num);	% get random input connections
   Idx(nmax+1:end) = [];
   net.W_in(Idx,nI) = rand_in_range(d.w_in_range,nmax);	% between -iScale and +iScale
end
% check for input vs. fixed points
%  TODO!!
for i=1:d.num
     if net.P.fixed(i,1)==1
      net.W_in(i,1)=0;
     end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% feedback connections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %  in_conn  = 0.2; % input connectivity procentage
net.W_fb = zeros(d.num,d.nOutputs);
nmax = ceil(d.num*d.fb_conn);
for nI = 1:d.nOutputs
   Idx = randperm(d.num);	% get random input connections
   Idx(nmax+1:end) = [];
   net.W_fb(Idx,nI) = rand_in_range(d.w_fb_range,nmax);	
end
%  % check for input vs. fixed points
%  %  TODO!!
%  for i=1:d.num
%       if net.P.fixed(i,1)==1
%        net.W_in(i,1)=0;
%       end
%  end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output connectivity (getting from outside)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch d.readout_type

	case 'POSITIONS'

		net.W_out = zeros(d.num,d.nOutputs);
		nmax = ceil(d.num*d.out_conn);
		for nO = 1:d.nOutputs
   			Odx = randperm(d.num);	% get random input connections
   			Odx(nmax+1:end) = [];
   			net.W_out(Odx,nO) = rand_in_range(d.w_out_range,nmax);	% between -iScale and +iScale
		end
		net.readout_type = d.readout_type;
		
	case 'LENGTHS'
		net.W_out = zeros(size(net.W.l0,1),d.nOutputs);
		nmax = ceil(size(net.W.l0,1)*d.out_conn);
		for nO = 1:d.nOutputs
   			Odx = randperm(size(net.W.l0,1));	% get random input connections
   			Odx(nmax+1:end) = [];
   			net.W_out(Odx,nO) = rand_in_range(d.w_out_range,nmax);	% between -iScale and +iScale
		end
		net.readout_type = d.readout_type;
		
	otherwise
		disp('ERROR - unkown output choosen');
	
end % case		
		
		



net.fixed_idx = find(net.P.fixed==1);  			 % indices of fixed points  (red)
net.input_idx  = find(sum(net.W_in,2)~=0);       % indices of input neurons (green) - 
net.output_idx  = find(sum(net.W_out,2)~=0);     % indices of input neurons (green) - 
												 % for multiple inputs, green if at least on input goes there 

                                                 
% if desired by user the produced networks is shown
if (d.show_plot == 1)
	plot_graph(net);
end


