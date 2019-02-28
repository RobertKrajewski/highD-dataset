function [tracks] = readInTracksCsv(filename, filenameStatic)
% Read the csv and convert it into a table
csvData = readtable(filename, 'Delimiter', ',');
csvDataStatic = readtable(filenameStatic, 'Delimiter', ',');

% Group by track id
G = findgroups(csvData(:, 2));
groupedById = splitapply(@(varargin)(varargin), csvData, G);

% Build a map containing the track id and its corresponding index in the 
% static tracks csv file. This enables fast access to the information when
% creating the final tracks struct.
idList = {};
indexList = [];
for iRow = 1:size(csvDataStatic, 1)
    iTrackId = csvDataStatic.id(iRow);
    idList = [idList; iTrackId];
    indexList = [indexList; iRow];
end
staticMap = containers.Map(idList,indexList);

% Initialize tracks 
tracks = {};

% Initialize constant variables
trackIndex = 1;

% Iterate over the whole table
for iRow = 1:size(groupedById, 1)
    iTrack = groupedById(iRow, :);
    iTrackIds = cell2mat(iTrack(2));
    currentId = iTrackIds(1);
    
    tracks(trackIndex).id = currentId;
    tracks(trackIndex).frames = cell2mat(iTrack(1));
    tracks(trackIndex).bbox = [cell2mat(iTrack(3)) ...
                               cell2mat(iTrack(4)) ... 
                               cell2mat(iTrack(5)) ...
                               cell2mat(iTrack(6))];
    tracks(trackIndex).xVelocity = cell2mat(iTrack(7));
    tracks(trackIndex).yVelocity = cell2mat(iTrack(8));
    tracks(trackIndex).xAcceleration = cell2mat(iTrack(9));
    tracks(trackIndex).yAcceleration = cell2mat(iTrack(10));
    tracks(trackIndex).lane = cell2mat(iTrack(25));
    tracks(trackIndex).thw = cell2mat(iTrack(14));
    tracks(trackIndex).ttc = cell2mat(iTrack(15));
    tracks(trackIndex).dhw = cell2mat(iTrack(13));
    tracks(trackIndex).frontSightDistance = cell2mat(iTrack(11));
    tracks(trackIndex).backSightDistance = cell2mat(iTrack(12));
    tracks(trackIndex).precedingXVelocity = cell2mat(iTrack(16));
    tracks(trackIndex).precedingId = cell2mat(iTrack(17));
    tracks(trackIndex).followingId = cell2mat(iTrack(18));
    tracks(trackIndex).leftPrecedingId = cell2mat(iTrack(19));
    tracks(trackIndex).leftAlongsideId = cell2mat(iTrack(20));
    tracks(trackIndex).leftFollowingId = cell2mat(iTrack(21));
    tracks(trackIndex).rightPrecedingId = cell2mat(iTrack(22));
    tracks(trackIndex).rightAlongsideId = cell2mat(iTrack(23));
    tracks(trackIndex).rightFollowingId = cell2mat(iTrack(24));

    csvStaticIndex = staticMap(currentId);
    tracks(trackIndex).initialFrame = csvDataStatic.initialFrame(csvStaticIndex);
    tracks(trackIndex).finalFrame = csvDataStatic.finalFrame(csvStaticIndex);
    tracks(trackIndex).numFrames = csvDataStatic.numFrames(csvStaticIndex);
    extractedClass = csvDataStatic.class(csvStaticIndex);
    tracks(trackIndex).class = extractedClass{1};
    tracks(trackIndex).minXVelocity = csvDataStatic.minXVelocity(csvStaticIndex);
    tracks(trackIndex).maxXVelocity = csvDataStatic.maxXVelocity(csvStaticIndex);
    tracks(trackIndex).meanXVelocity = csvDataStatic.meanXVelocity(csvStaticIndex);
    tracks(trackIndex).drivingDirection = csvDataStatic.drivingDirection(csvStaticIndex);
    tracks(trackIndex).traveledDistance = csvDataStatic.traveledDistance(csvStaticIndex);
    tracks(trackIndex).minDHW = csvDataStatic.minDHW(csvStaticIndex);
    tracks(trackIndex).minTHW = csvDataStatic.minTHW(csvStaticIndex);
    tracks(trackIndex).minTTC = csvDataStatic.minTTC(csvStaticIndex);
    tracks(trackIndex).numLaneChanges = csvDataStatic.numLaneChanges(csvStaticIndex);
    
    % Increment the internal track index 
    trackIndex = trackIndex + 1;
end
end
