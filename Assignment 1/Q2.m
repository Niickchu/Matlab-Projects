%output = Q2 
%   Plot the required function with its first and second derivatives, 
%   local maxima, local minima, inflection points, and vertical asymptotes.  
%   An array of objects is returned as described in the assignment handout.

% Student Name 1: Nicholas Chu

% Student 1 #: 301440034

% Student 1 userid (email):

% Student Name 2:

% Student 2 #:

% Student 2 userid (email):

% Below, edit to list any people who helped you with the assignment, 
%      or put ‘none’ if nobody helped (the two of) you.

% Helpers: _everybody helped us/me with the assignment (list names or put ‘none’)_
% Cole Kashino, Savinu Dissanayake

function Output = Q2

figure;

lmaxPlot=[];
lminPlot=[];
inflPlot=[];
verAsymPlotBottom=[];

syms x;
func = (2*x^4 - 40*x^3 + 299*x^2 - 989*x + 1219)/(x^2 - 10*x + 23);

% place your work here
assume(x, 'real');
dy = diff(func, x);

extrema = vpasolve(dy == 0, x, [-Inf, Inf]);
extremaCount = size(extrema, 1);

minima = sym(zeros(0,0));
maxima = sym(zeros(0,0));

ddy = diff(dy, x);

inflectionPoints = vpasolve(ddy == 0, x, [-Inf, Inf]);

if extremaCount ~= 0
    for j=1:extremaCount
        
        if(subs(ddy, extrema(j)) > 0)
            minima = [minima extrema(j)];
        elseif(subs(ddy, extrema(j)) < 0)
            maxima = [maxima extrema(j)];
        end
    end
end
         
hold on
ylim([-15, 30]);
xlim([2, 8]);
fplotH = fplot(func);
dyPlots = fplot(dy, 'red');
ddyPlots = fplot(ddy, 'yellow');

legendArray = {'f(x)',"f'(x)","f'(x)"};    

lmaxPlot = plot(maxima, subs(func, maxima), 'or');

legendArray = [legendArray, {'Local Maxima'}];

lminPlot = plot(minima, subs(func, minima), 'og');

legendArray = [legendArray, {'Local Minima'}];

inflPlot = plot(inflectionPoints, subs(func, inflectionPoints), 'ob');

legendArray = [legendArray, {'Inflection Points'}];

[temp, var2] = numden(func);
if (var2 ~= 1)
    vertAsym = solve(var2 == sym(0), x);
    verAsymPlotBottom = plot([vertAsym], -15, 'xk');
    verAsymPlotTop = plot([vertAsym], 30, 'xk');  
end

legendArray = [legendArray, {'Vert. Asymptote'}];
legendObject = legend(legendArray);
set(legendObject, 'Location', 'north');



hold off

Output = {fplotH; lmaxPlot; lminPlot; inflPlot; verAsymPlotBottom}; 
end
