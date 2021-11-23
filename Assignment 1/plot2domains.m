%Output = PLOT2DOMAINS (func, funcType)
%   Plot the given symbolic function (func) of the given type (funcType)
%   with 2 MATLAB domains.  The function should return an array of 2
%   function line objects, one for each call to fplot. x is the independent
%   variable.

% Student Name 1: Nicholas Chu

% Student 1 #: 301440034

% Student 1 userid (email): nmc10@sfu.ca

% Student Name 2:

% Student 2 #:

% Student 2 userid (email):

% Below, edit to list any people who helped you with the assignment, 
%      or put ‘none’ if nobody helped (the two of) you. none

% Helpers: _everybody helped us/me with the assignment (list names or put ‘none’)_
% Cole Kashino, Savinu Dissanayake

function Output = plot2domain(func, funcType) 

    figure;

    % place your work here
	subplot(2,1,1);
	fplot1 = fplot(func, [-2*pi, 2*pi]);
	title({[funcType,': f(x) = ',char(func)]; ' for -2\pi < x < 2\pi'});
    % add more here
    subplot(2,1,2);
    fplot2 = fplot(func, [-30*pi, 30*pi]);
	title({[' for -30\pi < x < 30\pi']});
    % the below line is just temporary
    
    Output = {fplot1; fplot2};
end

