% ENSC180-Assignment3

% Student Name 1: Nicholas Chu

% Student 1 #: 301440034

% Student 1 userid (email): nmc10@sfu.ca

% Student Name 2: 

% Student 2 #: 

% Student 2 userid (email):

% Below, edit to list any people who helped you with the assignment, 
%      or put ‘none’ if nobody helped (the two of) you.

% Helpers: none

% Instructions:
% * Put your name(s), student number(s), userid(s) in the above section.
% * Edit the "Helpers" line.  
% * Your group name should be "A3_<userid1>_<userid2>" (eg. A3_stu1_stu2)
% * Form a group 
%   as described at:  https://courses.cs.sfu.ca/docs/students
% * You will submit THIS file (assignment3_2017.m),    
%   and your video file (assignment3.avi or possibly similar).
% Craig Scratchley, Spring 2021

function frameArray = assignment3_2017

MAX_FRAMES = 1000; % you can change this and consider increasing it.
RESOLUTION = 1080; % you can change this and consider increasing it.
DURATION = 50       ; % Duration of video -- you can change this if you want.

% Colors
MAX_DEPTH = 310; % you will probably need to increase this.
CMAP=colormap(jet(300)); %change the colormap as you want.

WRITE_VIDEO_TO_FILE = true; % change this as you like (true/false)
DO_IN_PARALLEL =false; %change this as you like (true/false)

if DO_IN_PARALLEL
    startClusterIfNeeded
end

if WRITE_VIDEO_TO_FILE
    vidObj = [];
    openVideoFile
end

if DO_IN_PARALLEL || ~WRITE_VIDEO_TO_FILE 
    %preallocate struct array
    %frameArray=struct('cdata',cell(1,MAX_FRAMES),'colormap',cell(1,MAX_FRAMES));
end

% the path "around" the mandelbrot set, associating centres of frames
%     with zoom (magnification) levels.  

%           index  centre      number of times to zoom in by 2
PATH_POINTS =[0,    -0.5,            1;
              200,  0.001643721971153 + 0.822467633298876i,  (4/5);
              600,  0.001643721971153 + 0.822467633298876i, 6000;
              800, 0.001643721971153 + 0.822467633298876i, 10;
              1100, -0.77568377 + 0.13646737i,      10;
              1400, -0.77568377 + 0.13646737i,      2200;
              1700, -0.785 + 0.131i,      1800;
              2200, -0.785 + 0.131i,      11000;
              2350, -0.785 + 0.131i,      1;
              2400,  -0.1011 + 0.9563i,  1;
              3100,  -0.1011 + 0.9563i,  6000];
SIZE_0 = 1.5; % the "size" from the centre of a frame with no zooming.

% scale indexes to number of frames.
scaledIndexArray = PATH_POINTS(:, 1).*((MAX_FRAMES-1)/PATH_POINTS(end, 1));

% interpolate centres and zoom levels.
interpArray = interp1(scaledIndexArray, PATH_POINTS(:, 2:end), 0:(MAX_FRAMES-1), 'pchip');

zoomArray = interpArray(:,2); % zoom level of each frame

% ***** modify the below line to consider zoom levels.
sizeArray = SIZE_0 * ones(MAX_FRAMES,1)./zoomArray; % size from centre of each frame.

centreArray = interpArray(:,1);  % centre of each frame

iterateHandle = @iterate;

tic % begin timing
if DO_IN_PARALLEL
    parfor frameNum = 1:MAX_FRAMES
        %evaluate function iterate with handle iterateHandle
        frameArray(frameNum) = feval(iterateHandle, frameNum);
    end
else
    for frameNum = 1:MAX_FRAMES
        if WRITE_VIDEO_TO_FILE
            %frame has already been written in this case
            iterate(frameNum);
        else
            frameArray(frameNum) = iterate(frameNum);
        end
    end
end

if WRITE_VIDEO_TO_FILE
    if DO_IN_PARALLEL
        writeVideo(vidObj, frameArray);
    end
    close(vidObj);
    toc %end timing
else
    toc %end timing
    %clf;
    set(gcf, 'Position', [100, 100, RESOLUTION + 10, RESOLUTION + 10]);
    axis off;
    shg; % bring the figure to the top to be seen.
    movie(gcf, frameArray, 1, MAX_FRAMES/DURATION, [5, 5, 0, 0]);
end

    function frame = iterate (frameNum)

        centreX = real(centreArray(frameNum)); 
        centreY = imag(centreArray(frameNum)); 
        size = sizeArray(frameNum); 
        x = linspace(centreX - size, centreX + size, RESOLUTION);
        y = linspace(centreY - size, centreY + size, RESOLUTION);
        
        % the below might work okay unless you want to further optimize
        % Create the two-dimensional complex grid using meshgrid
        [X,Y] = meshgrid(x,y);
        z0 = X + 1i*Y;
        
        % Initialize the iterates and counts arrays.
        z = z0;
        
        % needed for mex, assumedly to make z elements separate
        %in memory from z0 elements.
        z(1,1) = z0(1,1); 
        
        % make c of type uint16 (unsigned 16-bit integer)
        c = zeros(RESOLUTION, RESOLUTION, 'uint16');
        
        % Here is the Mandelbrot iteration.
        c(abs(z) < 2) = 1;
        
        % below line turns warning off for MATLAB R2015b and similar
        %   releases of MATLAB.  Those releases have a bug causing a 
        %   warning for mex invocations like ours.  
        % warning( 'off', 'MATLAB:lang:badlyScopedReturnValue' );

        depth = MAX_DEPTH; % you can make depth dynamic if you want.
        
        for k = 2:depth
            [z,c] = mandelbrot_step(z,c,z0,k);
            % mandelbrot_step is a c-mex file that does one step of:
            % z = z.^2 + z0;
            % c(abs(z) < 2) = k;
        end
        
        % create an image from c and then convert to frame.  Use CMAP
        frame = im2frame(ind2rgb(c, CMAP));
        if WRITE_VIDEO_TO_FILE && ~DO_IN_PARALLEL
            writeVideo(vidObj, frame);
        end
        
        disp(['frame=' num2str(frameNum)]);
    end

    function startClusterIfNeeded
        myCluster = parcluster('local');
        if isempty(myCluster.Jobs) || ~strcmp(myCluster.Jobs(1).State, 'running')
            PHYSICAL_CORES = feature('numCores');
            
            % "hyperthreads" per physical core
            LOGICAL_PER_PHYSICAL = 2; %valid for the i7 on Craig's desktop
            
            % you can change the NUM_WORKERS calculation below if you want.
            NUM_WORKERS = (LOGICAL_PER_PHYSICAL + 1) * PHYSICAL_CORES;
            myCluster.NumWorkers = NUM_WORKERS;
            saveProfile(myCluster);
            disp('This may take a while when needed!')
            parpool(NUM_WORKERS);
        end
    end

    function openVideoFile
        % create video object
        vidObj = VideoWriter('assignment3');
        %vidObj.Quality = 100; % or consider changing
        vidObj.FrameRate = MAX_FRAMES/DURATION;
        open(vidObj);
    end

end


