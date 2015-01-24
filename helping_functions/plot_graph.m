function [] = plot_graph(net)
%
% plot network graph 
%  
% net:  network to plot
%
% helmut.hauser@bristol.ac.uk

MARKERSIZE = 15;
LINEWIDTH = 1;
			
			
figure;hold on;
set(gcf,'paperpositionmode','auto');
plot(net.P.states(:,1),net.P.states(:,2),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],'LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE); % plotting mass points

if (nargin==2) % colored graph
	h=colormap('jet');
	max_k = max(net.W.k1);
	min_k = min(net.W.k1);
	steepness = (64-1)/(max_k-min_k);offset = 1-steepness*min_k;

	for idx=1:length(net.W.from)
		col = h(ceil(steepness*(net.W.k1(idx,1))+offset),:);
		from = net.W.from(idx,1);
		to =net.W.to(idx,1);
		plot([net.P.states(from,1),net.P.states(to,1)],[net.P.states(from,2),net.P.states(to,2)],'LineWidth',3,'Color',col);hold on;
	end
else

	% plot connections with the actual data (when removed some connections after initialisation)
	px=net.P.states(:,1);	
	py=net.P.states(:,2);
	from = net.W.from;
	to = net.W.to;

	for i=1:length(net.W.from)
		plot([px(from(i,1),1), px(to(i,1),1)],[py(from(i,1),1), py(to(i,1),1)],'-k','LineWidth',LINEWIDTH);hold on;
	end
	plot(net.P.states(:,1),net.P.states(:,2),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor',[1 1 1],'LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE); % plotting mass points

end


plot(net.P.states(net.fixed_idx,1),net.P.states(net.fixed_idx,2),'s','MarkerEdgeColor','k',...
                'MarkerFaceColor','r','LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE+1);


plot(net.P.states(net.input_idx,1),net.P.states(net.input_idx,2),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor','g','LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE);
if (strcmp(net.readout_type,'POSITIONS'))
%  	plot(net.P.states(net.output_idx,1),net.P.states(net.output_idx,2),'om','LineWidth',10)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  plotting feedback nodes & assuming that we have only two feedbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (max(abs(net.W_fb)>0) & size(net.W_fb,2)==2)  % check if there exist feedback

	feedback_1_idx = setdiff( find(abs(net.W_fb(:,1))>0),net.fixed_idx);
	feedback_2_idx = setdiff( find(abs(net.W_fb(:,2))>0),net.fixed_idx);
	fb_color_1 = [0 1 1];
	fb_color_2 = [1	 0 1];
	plot(net.P.states(feedback_1_idx,1),net.P.states(feedback_1_idx,2),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor',fb_color_1,'LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE)
	plot(net.P.states(feedback_2_idx,1),net.P.states(feedback_2_idx,2),'o','MarkerEdgeColor','k',...
                'MarkerFaceColor',fb_color_2,'LineWidth' ,LINEWIDTH,'MarkerSize',MARKERSIZE)
	
end


% setting the right axes
marg = 0.1;  % 10 % margin
x_total  = net.init_data.p_xlim(1,2)- net.init_data.p_xlim(1,1);
y_total  = net.init_data.p_ylim(1,2)- net.init_data.p_ylim(1,1);
x_min = net.init_data.p_xlim(1,1) - marg*x_total;
x_max = net.init_data.p_xlim(1,2) + marg*x_total;
y_min = net.init_data.p_ylim(1,1) - marg*y_total;
y_max = net.init_data.p_ylim(1,2) + marg*y_total;
axis([x_min x_max y_min y_max]);


a1=gca;
set(a1,'FontSize',18);
xlabel('x-dimension')
ylabel('y-dimension')

%  save_path = 'YOUR_PATH';
%  print('-depsc',[save_path,'graph_plot.eps']);

