%Output = AUTO_FPLOT (func)
%plots the given function (func) with the x-axis limits automatically set 
%depending on the interesting points found. Interesting points include:
%local extrema, inflection points, vertical asymptotes, horizontal
%asymptotes.

% Student Name 1: Nicholas Chu

% Student 1 #: 301440034

% Student 1 userid (email): nmc10@sfu.ca

% Student Name 2:

% Student 2 #:

% Student 2 userid (email):

% Below, edit to list any people who helped you with the assignment, 
%      or put ‘none’ if nobody helped (the two of) you.

% Helpers: Cole Kashino, Ahmed Basim

function Output = auto_fplot (~)

figure;
syms x;

func;

lmaxPlot=[];
lminPlot=[];
inflPlot=[];
verAsymPlotBottom=[];
title(char(func));
xlabel('x');
ylabel('f(x)');

% place your work here

%test if function is periodic (infsol)

interestingPointCounter = [];
smallInterestingPoint = [];
bigInterestingPoint = [];

lastwarn(''); %clear warning message
[result_Dy, param_Dy, ~] = solve(func, x, 'ReturnConditions', true);
% test if the function someFunction is symbolically solvable
isFuncSymSolvable =  ~(strcmp(lastwarn, 'Cannot find explicit solution.'));

dy = diff(func, x);
ddy = diff(dy, x);
assume(x, 'real');

%check if infinite interesting points 
infSolutions = false;

[~, params, ~] = solve(func,x, 'ReturnConditions', true, 'Real', true);
if params == 'k'
    [~, params, ~] = solve(ddy,x,'ReturnConditions', true, 'Real', true);
    if params == 'k'
        infSolutions = true;
    end 
    if infSolutions == true
        zeroVal = subs(func, x, 0);
        startingSlope = subs(dy, x, 0);
                
        [testSol, testParams, testCond] = solve(dy == startingSlope, func == zeroVal, x,'IgnoreProperties', true, 'ReturnConditions', true, 'Real', true);

        point_1 = subs(testSol(size(testSol, 1)), params(1), 0);
        point_2 = subs(testSol(size(testSol, 1)), params(1), 1);
        
        periodSize = point_2 - point_1;
        
        period = [-periodSize periodSize];
        
       
        perArrSize = size(period, 1);
        smallPer = period(perArrSize, 1);
        bigPer = period(perArrSize, 2);
        periodLim = [smallPer bigPer];
        
    end
end

leftAsymptote = limit(func, x, -Inf);
rightAsymptote = limit(func, x, Inf);


min = sym(zeros(0, 0));
max = sym(zeros(0, 0));


if infSolutions == true
    
[extSol, extParam, ~] = solve(dy, x, 'ReturnConditions', true);

i = -100;

min = [];
max = [];
ext = [];
if(isempty(extSol) == 0)
    
    while i < 100
        
        temp = subs(extSol(size(extSol, 1)), extParam(1), i);
        if (double(temp) > -periodSize && temp < periodSize)
            ext = [ext temp];
        end
        i = i + 1;
        
    end
end

for i=1:size(ext, 2)
    if subs(ddy, x, ext(i)) > 0
        max = [max ext(i)];
    elseif subs(ddy, x, ext(i)) < 0
        min = [min ext(i)];
    end
end

else
ext = vpasolve(dy, x, [-Inf Inf]);

extremaCount = size(ext, 1);
    
    if(dy ~= 0)   
        if extremaCount ~= 0
            interestingPointCounter = extremaCount;
            for i=1:extremaCount
                if(subs(ddy, ext(i)) > 0)
                    min = [min ext(i)];
                elseif(subs(ddy, ext(i)) < 0)
                    max = [max ext(i)];
                end
                if(i == 1)
                    smallInterestingPoint = ext(i);
                    bigInterestingPoint = ext(i);
                end
                if(i ~= 1)
                    if(ext(i) < smallInterestingPoint)
                        smallInterestingPoint = ext(i);
                    end
                    if(ext(i) > bigInterestingPoint)
                        bigInterestingPoint = ext(i);
                    end
                end
            end
        end
    end
end

hold on

legendArray = [];
legendObjs = [];

legend;

set(legend, 'AutoUpdate', 'off');

fplotH = fplot(func); % this line might need to be modified


legendObjs = [fplotH];
legendArray = {'f(x)'};


if size(max) ~= 0 
    lmaxPlot = plot(max, subs(func, max), 'ored', 'DisplayName', 'local Maxima');

    legendObjs = [legendObjs, lmaxPlot];
    legendArray = [legendArray {'local maxima'}];
end

if size(min) ~= 0
    lminPlot = plot(min, subs(func, min), 'ogreen');
    legendObjs = [legendObjs, lminPlot];
    legendArray = [legendArray {'local minima'}];
end

isAVerticalAsym = false;

if infSolutions == true
    inflectionpoints = [];
    
    [inflSolution, inflParameters, inflConditions] = solve(ddy, x, 'ReturnConditions', true);
    
    
    i = -100;
    
    
    while i < 100
        temp = subs(inflSolution(size(inflSolution, 1)), inflParameters(1), i);
        if (temp > -periodSize && temp < periodSize)
            inflectionpoints = [inflectionpoints temp];
        end
        i = i + 1;
    end
    
    inflectionpoints;
    inflPlot = plot(inflectionpoints, subs(func, inflectionpoints), 'ob');
    legendObjs = [legendObjs, inflPlot];
    legendArray = [legendArray {'Infl. Points'}];
    
elseif(ddy ~=0)
    inflectionpoints = vpasolve(ddy, x, [-Inf Inf]);
    if size(inflectionpoints) ~= 0
        for i=1:size(inflectionpoints)
            if(inflectionpoints < smallInterestingPoint)
                smallInterestingPoint = inflectionpoints(i);
            end
            if(inflectionpoints > bigInterestingPoint)
                bigInterestingPoint = inflectionpoints(i);
            end
        end
        inflPlot = plot(inflectionpoints, subs(func, inflectionpoints), 'ob');
        legendObjs = [legendObjs, inflPlot];
        
        legendArray = [legendArray {'Infl. Points'}];
    end
    interestingPointCounter = interestingPointCounter + size(inflectionpoints, 1);
end

hasAsymptote = false;

if(dy ~= 0)
    [~, val] = numden(func);
    
    if (val ~= 1)
        vertAsym = double(solve(val == sym(0), x));
        interestingPointCounter = interestingPointCounter + size(vertAsym, 1);
        if size(vertAsym, 1) ~= 0
            for i=1:size(vertAsym, 1)
                if(vertAsym(i) < smallInterestingPoint)
                    smallInterestingPoint = vertAsym(i);
                end
                if(vertAsym(i) > bigInterestingPoint)
                    bigInterestingPoint = vertAsym(i);
                end
            end
            
            hasAsymptote = true;
         
        end
        
    end
end
if(infSolutions == true)
    xlim(double(periodLim));
elseif(interestingPointCounter == 0)
   xlim([-20 * (pi) 20 * (pi)]);   
elseif(isempty(interestingPointCounter) == 1)
    xlim([-20 * (pi) 20 * (pi)]);
elseif(interestingPointCounter == 1)
    if(isempty(smallInterestingPoint) == 0)
        xlim([(double(smallInterestingPoint)-20 *(pi)) (double((smallInterestingPoint)+20 * (pi)))])
    elseif(isempty(smallInterestingPoint) == 0)
        xlim([(double(bigInterestingPoint)-20 *(pi)) (double((greaterIntpoint)+20 * (pi)))])
    end
elseif(interestingPointCounter > 1)
    if(smallInterestingPoint ~= bigInterestingPoint)
        xlimitSmall = double(smallInterestingPoint(1));
        xlimitBig = double(bigInterestingPoint(1));
        domainSize = double((xlimitBig - xlimitSmall)/0.70);
        midPoint = ((xlimitBig + xlimitSmall)/2);
        xlim([midPoint-(domainSize/2) midPoint+(domainSize/2)])
    elseif(smallInterestingPoint == bigInterestingPoint)
        
        xlim([(double(smallInterestingPoint)-20 *(pi)) (double((smallInterestingPoint)+20 * (pi)))])
    end
end

LRlim = xlim;

if hasAsymptote == true
            updownbounds = ylim;
            verAsymPlotBottom = plot((vertAsym), updownbounds(1), 'xk');
            legendArray = [legendArray {'Vert Asymptotes'}];
            legendObjs = [legendObjs, verAsymPlotBottom(1)];
            verAsymptoteTopPlot = plot((vertAsym), updownbounds(2), 'xk');  
end

if(~isnan(leftAsymptote) && leftAsymptote ~= -Inf && leftAsymptote ~= Inf)
    plotLeftAsym = plot(LRlim(1), leftAsymptote, 'xgreen');
    legendObjs = [legendObjs, plotLeftAsym];
    legendArray = [legendArray {'Left Asymptote'}];
end
if(~isnan(rightAsymptote) && rightAsymptote ~= Inf && rightAsymptote ~= -Inf)
    plotRightAsym = plot(LRlim(2), rightAsymptote, 'xred');
    legendObjs = [legendObjs, plotRightAsym];
    legendArray = [legendArray {'Right Asymptote'}];
end

legend([legendObjs], {char(legendArray)}, 'Location', 'North');



Output = {fplotH; lmaxPlot; lminPlot; inflPlot; verAsymPlotBottom}; 
end