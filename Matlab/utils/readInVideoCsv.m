function [videoMeta] = readInVideoCsv(filename)
% Read the csv and convert it into a table
csvData = readtable(filename, 'Delimiter', ',');
% Initialize the tracks struct
videoMeta = {};

% Declare and initialize the extracted_meta_dictionary
videoMeta.id = int32(csvData.id);
videoMeta.frameRate = int32(csvData.frameRate);
videoMeta.locationId = int32(csvData.locationId);
videoMeta.speedLimit = double(csvData.speedLimit);
videoMeta.month = char(csvData.month);
videoMeta.weekDay = char(csvData.weekDay);
videoMeta.startTime = char(csvData.startTime);
videoMeta.duration = char(csvData.duration);
videoMeta.totalDrivenDistance = double(csvData.totalDrivenDistance);
videoMeta.totalDrivenTime = double(csvData.totalDrivenTime);
videoMeta.numVehicles = int32(csvData.numVehicles);
videoMeta.numCars = int32(csvData.numCars);
videoMeta.numTrucks = int32(csvData.numTrucks);
try
    % Extract upper Lanes
    upperCell = regexp(csvData.upperLaneMarkings, ';', 'split');
    upperCell = upperCell{1};
    cellSize = size(upperCell, 2);
    upperLanes = double.empty(cellSize, 0);
    for i = 1:size(upperCell, 2)
        cellValue = upperCell(1, i);
        upperLanes(i) = str2double(cellValue);
    end
    videoMeta.upperLanes = upperLanes;

    % Extract lower Lanes
    lowerCell = regexp(csvData.lowerLaneMarkings, ';', 'split');
    lowerCell = lowerCell{1};
    cellSize = size(lowerCell, 2);
    lowerLanes = double.empty(cellSize, 0);
    for i = 1:size(lowerCell, 2)
        cellValue = lowerCell(1, i);
        lowerLanes(i) = str2double(cellValue);
    end
    videoMeta.lowerLanes = lowerLanes;
catch
    printf("Something failed when reading the lane markings.");
end
end