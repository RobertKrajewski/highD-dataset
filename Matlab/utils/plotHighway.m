function [ax] = plotHighway(params)
ax = params.highwayAxes;
% Initialize the variables
upperLanes = params.videoMeta.upperLanes;
lowerLanes = params.videoMeta.lowerLanes;

laneThickness = params.laneThickness;
laneColor = params.laneColor;
trackWidth = params.trackWidth;
streetColor = params.streetColor;

hold on;
%% First plot the lane markings
positionBackground = [0 (-lowerLanes(size(lowerLanes, 2)) - 0.7) trackWidth (lowerLanes(size(lowerLanes, 2)) - upperLanes(1) + 2.0)];
rectangle(ax, 'Position', positionBackground, 'FaceColor', streetColor, 'EdgeColor', [1 1 1]);

% Upper lanes
positionBackground = [0 -upperLanes(1) trackWidth laneThickness];
rectangle(ax, 'Position', positionBackground, 'FaceColor', laneColor, 'EdgeColor', laneColor);
for i = 2:size(upperLanes, 2) - 1
    plot(ax, [0 trackWidth], [-upperLanes(i) -upperLanes(i)], '--', 'Color', laneColor);
end
positionBackground = [0 -upperLanes(size(upperLanes, 2)) trackWidth laneThickness];
rectangle(ax, 'Position', positionBackground, 'FaceColor', laneColor, 'EdgeColor', laneColor);

% Lower lanes
positionBackground = [0 -lowerLanes(1) trackWidth laneThickness];
rectangle(ax, 'Position', positionBackground, 'FaceColor', laneColor, 'EdgeColor', laneColor);
for i = 2:size(lowerLanes, 2) - 1
    plot(ax, [0 trackWidth], [-lowerLanes(i) -lowerLanes(i)], '--', 'Color', laneColor);
end
positionBackground = [0 -lowerLanes(size(lowerLanes, 2)) trackWidth laneThickness];
rectangle(ax, 'Position', positionBackground, 'FaceColor', laneColor, 'EdgeColor', laneColor);
end

