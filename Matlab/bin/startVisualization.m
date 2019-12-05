clc; clear;

% Name of the video
videoString = "01";

% Define path of background image. Can be empty.
backgroundImagePath = sprintf('data/%s_highway.jpg', videoString);
% backgroundImagePath = "";

% Read tracks by using tracks file and static tracks file.
tracksFilename = sprintf('data/%s_tracks.csv', videoString);
tracksStaticFilename = sprintf('data/%s_tracksMeta.csv', videoString);
tracks = readInTracksCsv(tracksFilename, tracksStaticFilename);
% Read video meta data from video meta file
videoMetaFilename = sprintf('data/%s_recordingMeta.csv', videoString);
videoMeta = readInVideoCsv(videoMetaFilename);

% The visualization needs the tracks, the videoMeta data and the
% backgroundImagePath (which can be empty). 
argumentsInput.tracks = tracks;
argumentsInput.videoMeta = videoMeta;
argumentsInput.backgroundImagePath = backgroundImagePath;

% Plot variables initialization. These are the default values. Please use
% them or modify them for your own purpose.
argumentsInput.removingList = [];
argumentsInput.trackWidth = 408; % Width of the video frame
argumentsInput.laneThickness = 0.3; % thickness of the lane markings
argumentsInput.laneColor = [1 1 1]; % color of the lane markings (white)
argumentsInput.currentFrame = 1; % Starting frame
argumentsInput.minimumFrame = 1; % Minimum frame that exists (1)
argumentsInput.maximumFrame = tracks(end).finalFrame-1; % Maximum frame
argumentsInput.playRate = 1; % The play rate (going "playRate" steps forward)
argumentsInput.stop = false; % Boolean for 
argumentsInput.streetColor = [0.6 0.6 0.6]; % The street color 
argumentsInput.boundingBoxColor = [1 0 0]; % The color of the bounding box
argumentsInput.plotTextAnnotation = true; % Whether the text annotations shall be plotted
argumentsInput.plotTrackingLine = true; % Whether the tracking line shall be plotted

argumentsInput.geoParams.meterPerPixel = 0.10106;
argumentsInput.geoParams.kmhPerPixelFrame = 9.0954;

% Start the visualization
trackVisualization(argumentsInput);