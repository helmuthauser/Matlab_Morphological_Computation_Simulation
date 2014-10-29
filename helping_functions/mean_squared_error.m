function e = mean_squared_error(target,output)
% calculates mean squared error
%
% hhauser@ifi.uzh.ch


% assuming both have the same size
len = length(target);

e = sum((target-output).^2)/len;