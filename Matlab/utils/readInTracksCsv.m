function [tracks] = readInTracksCsv(filename, filenameStatic)
% Read the csv and convert it into a table
csvData = readtable(filename, 'Delimiter', ',');
csvDataStatic = readtable(filenameStatic, 'Delimiter', ',');

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
currentId = -1;
trackLength = 0;

% Iterate over the whole table
for iRow = 1:size(csvData, 1)
    iTrackId = csvData.id(iRow);
    if currentId == -1
        currentId = iTrackId;
    end
    % If the Id changes, the track has ended and it needs to be written 
    % into the tracks struct 
    if currentId ~= iTrackId
        startingIndex = int32(iRow - trackLength);
        tracks(trackIndex).id = currentId;
        tracks(trackIndex).frames = csvData.frame(startingIndex:iRow);
        tracks(trackIndex).bbox = [csvData.x(startingIndex:iRow) ...
                                   csvData.y(startingIndex:iRow) ... 
                                   csvData.width(startingIndex:iRow) ...
                                   csvData.height(startingIndex:iRow)];
        tracks(trackIndex).xVelocity = csvData.xVelocity(startingIndex:iRow);
        tracks(trackIndex).yVelocity = csvData.yVelocity(startingIndex:iRow);
        tracks(trackIndex).xAcceleration = csvData.xAcceleration(startingIndex:iRow);
        tracks(trackIndex).yAcceleration = csvData.yAcceleration(startingIndex:iRow);
        tracks(trackIndex).lane = csvData.laneId(startingIndex:iRow);
        tracks(trackIndex).thw = csvData.thw(startingIndex:iRow);
        tracks(trackIndex).ttc = csvData.ttc(startingIndex:iRow);
        tracks(trackIndex).dhw = csvData.dhw(startingIndex:iRow);
        tracks(trackIndex).frontSightDistance = csvData.frontSightDistance(startingIndex:iRow);
        tracks(trackIndex).backSightDistance = csvData.backSightDistance(startingIndex:iRow);
        tracks(trackIndex).precedingXVelocity = csvData.precedingXVelocity(startingIndex:iRow);
        tracks(trackIndex).precedingId = csvData.precedingId(startingIndex:iRow);
        tracks(trackIndex).followingId = csvData.followingId(startingIndex:iRow);
        tracks(trackIndex).leftPrecedingId = csvData.leftPrecedingId(startingIndex:iRow);
        tracks(trackIndex).leftAlongsideId = csvData.leftAlongsideId(startingIndex:iRow);
        tracks(trackIndex).leftFollowingId = csvData.leftFollowingId(startingIndex:iRow);
        tracks(trackIndex).rightPrecedingId = csvData.rightPrecedingId(startingIndex:iRow);
        tracks(trackIndex).rightAlongsideId = csvData.rightAlongsideId(startingIndex:iRow);
        tracks(trackIndex).rightFollowingId = csvData.rightFollowingId(startingIndex:iRow);
        
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

      
        % Reset the values again for next track
        currentId = iTrackId;
        
        % Increment the internal track index 
        trackIndex = trackIndex + 1;
        trackLength = 0;
    end
    trackLength = trackLength + 1;
end
end