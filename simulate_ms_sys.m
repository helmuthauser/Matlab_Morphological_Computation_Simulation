function [net_after,sim_data] = simulate_ms_sys (net,input,output)
% simulating mass-spring networks as used in [1] and [2]
%
% if output is given too, assumes teacher forcing is wanted
% Note: reads from net.init_dat.readout_type what readout to choose
%  
%  input: net		net_structure - has to be initialized by init_real_sd_net
%         input 	num_of_timesteps x num_of_input  input matrix to the system
%  		  output	used for teacher forcing 
%  output:
%  		 net_after	net structure after simulation (e.g. when m-file used at every single step)
%  		 sim_data  	data structure with all data harvested during simulation
%  
% 
%  helmut.hauser@bristol.ac.uk
%
%  [1] Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
%  "Towards a theoretical foundation for morphological computation with compliant bodies"
%  Biological Cybernetics, Springer Berlin / Heidelberg, 2011, 105, 355-370 
%  http://www.springerlink.com/content/j236312507300638/
% 
%  [2] Hauser, H.; Ijspeert, A.; Füchslin, R.; Pfeifer, R. & Maass, W.
%  "The role of feedback in morphological computation with compliant bodies"
%  Biological Cybernetics, Springer Berlin / Heidelberg, 2012, 106, 595-613
%  http://www.springerlink.com/content/d54t39qh28561271/




% check which type of setup  
% is used
TEACHER_FORCING = 0; % no teacher forcing is applied 
if nargin == 3
  disp('teacher forcing')
  TEACHER_FORCING = 1;
end


if(isfield(net, 'tansig'))
 disp('using TANSIG springs instead of 3rd order polynom')
end


if(isfield(net, 'rk_steps'))
 disp('using 4th order Runge-Kutta algorithm')
end

% check if we have the case of a symmetric net_after

SYMMETRIC = 0;
THREE_REGIONS = 0;
if (isfield(net,'info')) % right now assuming that symmetric is the only special case we deal here with
  if (strcmp(net.info,'symmetric_net')) 
  	SYMMETRIC = 1;
  	disp('symmetric net !')
  	% this assumes then we have two inputs: one vertical and the other one horizontal
	% W_in(:,1) => horizontal
	% W_in(:,2) => vertical input
  end
  if (strcmp(net.info,'three_regions'))
  	THREE_REGIONS = 1;
  	disp('three regions net !')  
  	% this assumes then we have two inputs: one vertical and the other one horizontal
	% W_in(:,1) => horizontal from the left
	% W_in(:,2) => horizontal from the right
  end
end

% indices of input nodes
in_idx = find(net.W_in~=0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getting necessary out net data structure
P = net.P;
W = net.W;
%  output_idx = net.output_idx;  %
time_step = net.init_data.time_step;
show_steps = net.init_data.show_steps;
sim_time = size(input,1)*time_step;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num = net.init_data.num;  % for the size of the data matrices
len = size(input,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (net.init_data.save_sim_data==1)
	% data matrices over time all together in sim_data structure
	sim_data.Fx = zeros(len,num);
	sim_data.Fy = zeros(len,num);

	sim_data.Sx_off = zeros(len,num);  % minus the offset
	sim_data.Sy = zeros(len,num);
	sim_data.Sxd = zeros(len,num);
	sim_data.Syd = zeros(len,num);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% now init values with values from the net
	sim_data.Sx(1,:) = P.states(:,1)';	% positions
	sim_data.Sy(1,:) = P.states(:,2)';
	sim_data.Sxd(1,:) = P.states(:,3)';	% velocities
	sim_data.Syd(1,:) = P.states(:,4)';
end
	% this data is put out in any way
	sim_data.O = zeros(len,net.init_data.nOutputs);
	% internal state - either D or Sx depending on "readout_type"
	sim_data.D  = zeros(len,size(W.k1,1));
	sim_data.Sx = zeros(len,num);
%  	sim_data.O_off = zeros(len,net.init_data.nOutputs); % without offset 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Simulation loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx=0;  
for i=1:len
 	idx=idx+1; 	
 	
 	if(mod(idx,show_steps)==0) % when to show steps
 	  disp([' i = ' ,num2str(idx) , ' of ' , num2str(sim_time/time_step) ]);
 	end
 	
 	% set all old forces to zero (to get no unwanted acculumation)
 	P.force(:,1:2) = zeros(num,2);
 	
 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   	% go trough all connections and calculate force
   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for c=1:size(W.k1,1)
	   % get actual points wich are connected by this spring    
       from = W.from(c,1);
       to   = W.to(c,1);
       % actual distance with normed direction
       p_from = [ P.states(from,1) , P.states(from,2) ]';
       p_to   = [ P.states(to,1) , P.states(to,2) ]';
       [d,ndir] = e_distance( p_from,p_to);
	   %adding noise to the distance
%  	   d = d + net.dist_noise*rand(1,1);%-net.dist_noise*0.5;
	   if (net.init_data.save_sim_data==1 | strcmp(net.readout_type,'LENGTHS'))
			sim_data.D(idx,c)= d + net.dist_noise*rand(1,1);
	   end
       
      
	   % force amplitudes (LINEAR)
%  	   Fk = -W.k1(c,1)*(d-W.l0(c,1))  ;
%  	   Fd = -W.d1(c,1)*((d-W.dist_old(c,1))/time_step);
	   
%  	   pause
%  	   Fd=0; %no damping
	   if(isfield(net, 'tansig'))
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%  TANSIG VERSION!!!!!!!!!!!!!!!!
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   	A_k = W.k1(c,1);
	   	k_k = W.k3(c,1);
	   	A_d = W.d1(c,1);
	   	k_d = W.d3(c,1);
	   
	   	% tansig with a additional linear component 
	   	if(net.tansig == 1)
	   		Fk = -1+(2*A_k)/(1+exp(-2*abs(k_k)*(d-W.l0(c,1)))) + (d-W.l0(c,1));
	   		Fd = -1+(2*A_d)/(1+exp(-2*abs(k_d)*(d-W.dist_old(c,1))/time_step)) + (d-W.dist_old(c,1))/time_step;
	   	else
			Fk = -1+(2*A_k)/(1+exp(-2*abs(k_k)*(d-W.l0(c,1))));
	   		Fd = -1+(2*A_d)/(1+exp(-2*abs(k_d)*(d-W.dist_old(c,1))/time_step));
		end
	  else

	   
	% force amplitudes (NONlinear)
	   	Fk = +( W.k3(c,1)*(d-W.l0(c,1))^3 + W.k1(c,1)*(d-W.l0(c,1)));
	   	Fd = + ( W.d3(c,1)*((d-W.dist_old(c,1))/time_step)^3  +W.d1(c,1)*((d-W.dist_old(c,1))/time_step));
      end




   
	  
        % add forces to the mass points which are not fixed
	   if(P.fixed(to,1)==0)   
	   	P.force(to,1)   = P.force(to,1) + (-1)* (Fk+Fd)*ndir(1,1); % f_x
	   	P.force(to,2)   = P.force(to,2) + (-1)*(Fk+Fd)*ndir(2,1); % f_y
	   end
	   if(P.fixed(from,1)==0)   
		P.force(from,1) = P.force(from,1) + (+1)*(Fk+Fd)*ndir(1,1); % f_x
	    P.force(from,2) = P.force(from,2) + (+1)*(Fk+Fd)*ndir(2,1); % f_y
	   end

	   % forces data
	   if (net.init_data.save_sim_data==1)
	   	sim_data.Fx(idx,to) = P.force(to,1);
	   	sim_data.Fy(idx,to) = P.force(to,2);
	   	sim_data.Fx(idx,from) = P.force(from,1);
	   	sim_data.Fy(idx,from) = P.force(from,2);
	   end
	   % update old distance with actual distnace
	   W.dist_old(c,1) = d;	   
    end 
    	   
    	   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add input signals
    % right now as Fx !! and on dimensional (exception => symmetric case!)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if (TEACHER_FORCING==1)

		if (SYMMETRIC | THREE_REGIONS)
			error(['teaching forcing for ***',net.info,'*** net no implemented yet!!'])
		end
    	P.force(:,1) = P.force(:,1) + net.W_in * input(idx,:)' + net.W_fb*output(idx,:)'; 
	else
		if (idx==1) % to make sure to get a nonzero idx
			if (SYMMETRIC)
				P.force(:,1) = P.force(:,1) + net.W_in(:,1) * input(idx,1)' + net.W_fb*sim_data.O(idx,:)'; % x-dimension
				P.force(:,1) = P.force(:,1) + net.W_in(:,2) * input(idx,2)'; % y-dimension
			elseif (THREE_REGIONS)
				P.force(:,1) = P.force(:,1) + net.W_in(:,1) * input(idx,1)' + net.W_fb*sim_data.O(idx,:)'; % x-dimension
				P.force(:,1) = P.force(:,1) - net.W_in(:,2) * input(idx,2)'; % y-dimension
					
			else
				P.force(:,1) = P.force(:,1) + net.W_in * input(idx,:)' + net.W_fb*sim_data.O(idx,:)'; % x-dimension
			end
		else
			if (SYMMETRIC)
				P.force(:,1) = P.force(:,1) + net.W_in(:,1) * input(idx,1)' + net.W_fb*sim_data.O(idx-1,:)'; % vertical
				P.force(:,1) = P.force(:,1) + net.W_in(:,2) * input(idx,2)' ; % horizontal
            elseif(THREE_REGIONS)
				P.force(:,1) = P.force(:,1) + net.W_in(:,1) * input(idx,1)' + net.W_fb*sim_data.O(idx-1,:)'; % vertical
				P.force(:,1) = P.force(:,1) - net.W_in(:,2) * input(idx,2)' ; % horizontal

			else
    			P.force(:,1) = P.force(:,1) + net.W_in * input(idx,:)' + net.W_fb*sim_data.O(idx-1,:)'; % x-dimension
    		end

    		
   		end
	end
 
    	   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	   
    % get rid of all velocities and forces for fixed points	   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	   
    P.states(net.fixed_idx,3:4) = zeros(length(net.fixed_idx),2);
    P.force(net.fixed_idx,1:2)  = zeros(length(net.fixed_idx),2);
  
    
    
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % simulation all dynamical system (mass points)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	for i=1:size(P.states,1)
	   	
	   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   	%%%%%%%%%%%%%% EULER integrations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		if(~isfield(net, 'rk_steps'))
	   		x = ode_simple_ms_sys(time_step,P.states(i,1:4),P.force(i,1:2));
	   		P.states(i,:) = x;
	   	else
	   	
	   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  		%%%%%%%%	   	4th orderRUNGE KUTTA       %%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  		
	   		[tx,xx,vx] = rk4ode2(@rhs_mass_sys, 0, time_step, P.states(i,1),P.states(i,3), time_step/net.rk_steps,P.force(i,1));
	   		[ty,xy,vy] = rk4ode2(@rhs_mass_sys, 0, time_step, P.states(i,2),P.states(i,4), time_step/net.rk_steps,P.force(i,2));
	   	
	   		P.states(i,1) = xx(1,end); % x-pos
	   		P.states(i,2) = xy(1,end); % y-pos
	   		P.states(i,3) = vx(1,end); % x-vel
	   		P.states(i,4) = vy(1,end); % y-vel 
	   	end

	   	
	   	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   	 if (net.init_data.save_sim_data==1)
	   		% getting data 
	   		sim_data.Sx(idx,i)  = P.states(i,1) + net.pos_noise*rand(size(P.states(i,1)));
	   		sim_data.Sy(idx,i)  = P.states(i,2) + net.pos_noise*rand(size(P.states(i,2)));
	   		sim_data.Sxd(idx,i) = P.states(i,3);
	   		sim_data.Syd(idx,i) = P.states(i,4);
	  	elseif (strcmp(net.readout_type,'POSITIONS'))
	  		sim_data.Sx(idx,i) = P.states(i,1)+ net.pos_noise*rand(size(P.states(i,1)));
	   	end


	end
	
		% getting outputs (depending on the readout scheme)
		switch net.readout_type
			
			case 'POSITIONS'
        		sim_data.O(idx,:) = net.W_out' * P.states(:,1); %  assuming just to use x-dimensions        	
        	case 'LENGTHS'
        		sim_data.O(idx,:) = net.W_out' * sim_data.D(idx,:)'; % lengths as outputs	
        		
        end % switch

	if(length(find(isnan(sim_data.O(idx,:)))>0))
		sim_data.ERROR = 'NaN - ERROR / unstable simulation';
		disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		disp('NaN - ERROR / unstable simulation');
		disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		net_after = 0;
   		return
    end
end 	


% updating states for the net to be sent back
net_after = net;
net_after.P = P; % dynamic information about the points
net_after.W = W; % dynamic information about the connections

if(isfield(net, 'tansig'))
 net_after.info = 'used TANSIG springs instead of 3rd order polynom';
end
