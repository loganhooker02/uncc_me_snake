%process_videosx('test1.mp4', 'cameraParams.mat', 'hello_world.mat', 5)
%uncomment line above and replace arguments to run as file rather than in command window

function process_videosx(inputFile, calibrationFile, outputFile, tagSize)

% Given video file with april tags and convert into pose, location, and ID
% histories
% Inputs:
%   fileName: mp4 video
%   cameraParameters
%   tag size
% Outputs:
%   .mat file (with april tag data)
video = VideoReader(inputFile);
load(calibrationFile);

% start of code
intrinsics = cameraParams.Intrinsics;
frameRate = video.FrameRate;

% process each frame
for i = 1:video.NumFrames
    %reads video frame
    videoFrame = read(video, i);

    %find current time step of video
    time(i) = (i-1)/frameRate; %current frame / framerate

    % reads current frame for tags
    % https://www.mathworks.com/help/vision/ref/readapriltag.html
    % - id is a vector of N integers identifying each tag
    % - loc is a 4 x 2 x N matrix where loc(:,:,i) gives a set of coordinates
    % the array contains the (x,y) locations for each of the four corners
    % of the tags
    % - pose is a rigidtform3d object. origin of each frame is at center of
    % tag, https://www.mathworks.com/help/images/ref/rigidtform3d.html
    [id,loc, pose] = readAprilTag(videoFrame,"tag36h11",intrinsics,tagSize);

    % record data over time
    locHist{i} = loc;
    idHist{i} = id;
    poseHist{i} = pose;
end
1;
save(outputFile,"locHist","idHist","poseHist","video")
end
