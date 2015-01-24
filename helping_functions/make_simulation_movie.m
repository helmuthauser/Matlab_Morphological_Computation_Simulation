function [F] = make_simulation_movie(net,d,SAVE_MOVIE,name)  
% make_simulation_movie(net,d,SAVE_MOVIE,name)
% input: 
%  		net 		net to simulate (necessary color information)
%  		d       	simulation data obtained during simulation
% 		SAVE_MOVIE	true/false to safe the movie to 'name.avi' - default is false!
%		name		name of the movie to be saved - default 'ms_movie'
%
%  		IMPORTANT 	net.init_data.save_sim_data=1 in order to get in structure d necessary information
%					to make the movie
%  		NOTE:   movie2avi(F,filename,'fps',25) saves the file
%				mencoder filename -ovc lavc -o filename_small.avi 	reduces the file size
%
% helmut.hauser@bristol.ac.uk



if (nargin==3)
	name = 'ms_movie';
end
if (nargin==2)
	name = 'ms_movie';
	SAVE_MOVIE = 0;
end

LINE = 2;		% line thickness of connnections
MARKER = 15;	% size of the mass particles marker (circle)

close all;
fps= 20;
time_step=net.init_data.time_step;
num_step = 1/fps/time_step; % 25 fps = 40 ms
F = moviein(size(d.Sx,1)/num_step);

% check for maximal and minimal values to keep 
% the axis constant during simulation
x_max  = max(max(d.Sx));
x_min  = min(min(d.Sx));
y_max  = max(max(d.Sy));
y_min  = min(min(d.Sy));


fix_idx = net.fixed_idx;   % indices of fixed points  (red)
in_idx  = net.input_idx;   % indices of input neurons (green)

% initial positions: to get a frame information (axes)
plot(d.Sx(1,:),d.Sy(1,:),'ob');
r=0.05; % procentage of making the window bigger
x_range = x_max-x_min;
y_range = y_max-y_min;
if (y_range==0) 
	y_min = -1; y_max=+1;
end
axis([x_min-r*x_range x_max+r*x_range y_min-r*y_range y_max+r*y_range]);

lim = axis;
%  return

% video making loop
frame_nr = 0;
time_counter = 0;
    for idx=1:num_step:size(d.Sx,1)
    		frame_nr=frame_nr+1; 
    		time_counter = time_counter+num_step*time_step;
    	    
			% plot all spring connections
			clf;
			hold on;
          	for j=1:size(net.W.from,1)
          		plot([d.Sx(idx,net.W.from(j,1)),d.Sx(idx,net.W.to(j,1))],[d.Sy(idx,net.W.from(j,1)),d.Sy(idx,net.W.to(j,1))],'LineWidth',LINE);
          	end
    	
    		% plot nodes
          	plot(d.Sx(idx,:),d.Sy(idx,:),'ob','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',MARKER);hold on;
          	plot(d.Sx(idx,fix_idx),d.Sy(idx,fix_idx),'or','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',MARKER);
          	plot(d.Sx(idx,in_idx),d.Sy(idx,in_idx),'og','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',MARKER);

          	hold off;
		 	axis(lim);
		 	title(['time = ' ,num2str(time_counter),' s'])
		  	drawnow;
%  			F(frame_nr) = getframe(gcf); % the whole figure
			F(frame_nr) = getframe;		% just the plot
    end

% saving the file to out.avi 
% and make small version out of it
if (SAVE_MOVIE==1)	
	disp(['... saving file to ',name,'.avi']) 
 	movie2avi(F,[name,'_BIG.avi'],'fps',fps);
 	disp('... using mencoder to reduce filesize');
	unix(['mencoder -quiet ', name,'_BIG.avi -ovc lavc -o ',name,'.avi']);
	disp('... cleaning old big avi-file')
	unix(['rm -f ',name,'_BIG.avi']); 
	disp('finished.');
end