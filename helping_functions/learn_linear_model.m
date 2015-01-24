function [W,linear_output]= learn_linear_model(input,output)
% learns simple linear model for given input-output data set
% using linear regression
%
% it returns the corresponding optimal weights 
% output = a*input + b
% as vector W
% 
% helmut.hauser@bristol.ac.uk


X = horzcat(input,ones(length(input),1));  
W = X\output;
a = W(1,1);
b = W(2,1);

linear_output = X*W;