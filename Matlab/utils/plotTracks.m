function [removingList] = plotTracks(ax, tracks, currentFrame, params, removingList)
%% Plot bounding boxes
% Remove old lines
if nargin > 4
    if size(removingList, 1) > 0
       for i = 1:size(removingList, 1)
          delete(removingList(i)); 
       end
    end
end
% Important parameters for plotting the bounding boxes
removingList = [];
boundingBoxColor = params.boundingBoxColor;
% We need to draw the bounding boxes from 0 to negative because the image 
% coordinate origin is in the upper left corner. Therefore the bounding box
% coordinates are mirrored.
ySign = -1;
% Now plot the bounding boxes together with annotations
for iTrack = 1:size(tracks, 2)
    track = tracks(iTrack);
    initialFrame = track.initialFrame;
    finalFrame = track.finalFrame;
    if (initialFrame <= currentFrame) && (currentFrame < finalFrame)
        % Get internal track index for the chosen frame
        currentIndex = currentFrame - initialFrame + 1;
        % Try to get the bounding box
        try
            boundingBox = track.bbox(currentIndex, :);
            velocity = track.xVelocity(currentIndex);
        catch
           continue 
        end
        % Plot the bounding box
        positionBoundingBox = [boundingBox(1) ...
                               ySign*boundingBox(2)+ySign*boundingBox(4) ...
                               boundingBox(3) ...
                               boundingBox(4)];
        if params.stop == 1
            rect = rectangle(ax, 'Position', positionBoundingBox, ...
                                 'FaceColor', boundingBoxColor, ...
                                 'EdgeColor', [0 0 0], ...
                                 'PickableParts', 'visible', ...
                                 'ButtonDownFcn',{@params.onClick, track, currentFrame});
        else
            rect = rectangle(ax, 'Position', positionBoundingBox, ...
                                 'FaceColor', boundingBoxColor, ...
                                 'EdgeColor', [0 0 0], ...
                                 'PickableParts', 'visible');
        end
        removingList = [removingList; rect];
        
        % Plot the triangle that represents the direction of the vehicle
        if velocity < 0
            centroidSign = 1;
            front = boundingBox(1) + (boundingBox(3)*0.2);
            triangleXPosition = [front front boundingBox(1)];
        else
            centroidSign = -1;
            front = boundingBox(1) + boundingBox(3) - (boundingBox(3)*0.2);
            triangleXPosition = [front front boundingBox(1)+boundingBox(3)];
        end
        triangleYPosition = [ySign*boundingBox(2) ...
                             ySign*boundingBox(2)+ySign*boundingBox(4)...
                             ySign*boundingBox(2)+ySign*(boundingBox(4)/2)];
        triangle = fill(ax, triangleXPosition, triangleYPosition, [0 0 0]);
        removingList = [removingList; triangle];
        
        % Plot the text annotation
        if params.plotTextAnnotation
            velocityKmh = abs(velocity) * 3.6;
            boundingBoxAnnotationText = sprintf('%s|%.2fkm/h|ID%d', ...
                                                track.class(1), ...
                                                velocityKmh, ...
                                                track.id);
            textAnnotation = text(ax, boundingBox(1), ySign*boundingBox(2)+0.6, ...
                                  boundingBoxAnnotationText, 'FontSize',8);
            textAnnotation.BackgroundColor = [1 1 0.3];
            textAnnotation.Margin = .5;
            removingList = [removingList; textAnnotation];
        end
        
        % Plot the track line
        if params.plotTrackingLine
            relevantBoundingBoxes = track.bbox(1:currentIndex, :);
            centroids = [relevantBoundingBoxes(:,1) + relevantBoundingBoxes(:,3)/2, ...
                         relevantBoundingBoxes(:,2) + relevantBoundingBoxes(:,4)/2];
            plottedCentroids = line(ax, centroids(:, 1)+ centroidSign * (boundingBox(3)/2), ...
                                    ySign*centroids(:, 2));
            removingList = [removingList; plottedCentroids];
        end
    end
end
xlim(ax, [0 params.trackWidth]);
axis off;
end
