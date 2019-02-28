function [removingList] = plotTracksOnImage(ax, tracks, currentFrame, params, removingList)
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
boundingBoxColor = [1 0 0];
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
            boundingBox = boundingBox / params.geoParams.meterPerPixel;
            boundingBox = boundingBox / 4;
            velocity = track.xVelocity(currentIndex);
        catch
           continue 
        end
        % Plot the bounding box
        positionBoundingBox = [boundingBox(1) ...
                               boundingBox(2) ...
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
        
        % Plotting the triangle for the direction of the vehicle
        if velocity < 0
            back = boundingBox(1)+(boundingBox(3)*0.2);
            front = boundingBox(1);
        else
            back = boundingBox(1)+boundingBox(3)-(boundingBox(3)*0.2);
            front = boundingBox(1)+boundingBox(3);
        end
        triangleXPosition = [back back front];
        triangleYPosition = [boundingBox(2) ...
                             boundingBox(2)+boundingBox(4) ...
                             boundingBox(2)+(boundingBox(4)/2)];
        triangle = patch(ax, triangleXPosition, triangleYPosition, [0 0 0]);
        removingList = [removingList; triangle];
        
        % Plot the text annotation
        if params.plotTextAnnotation
            velocityKmh = abs(velocity) * 3.6;
            boundingBoxAnnotationText = sprintf('%s|%.2fkm/h|ID%d', ...
                                                track.class(1), ...
                                                velocityKmh, ...
                                                track.id);
            textAnnotation = text(ax, boundingBox(1),boundingBox(2)-1.5, ...
                                  boundingBoxAnnotationText, 'FontSize',8);        
            textAnnotation.BackgroundColor = [1 1 .3];
            textAnnotation.Margin = .5;
            removingList = [removingList; textAnnotation];
        end
        
        % Plot the track line
        if params.plotTrackingLine
            relevantBoundingBoxes = track.bbox(1:currentIndex, :);
            relevantBoundingBoxes = relevantBoundingBoxes / params.geoParams.meterPerPixel;
            relevantBoundingBoxes = relevantBoundingBoxes / 4;
            centroids = [relevantBoundingBoxes(:,1) + relevantBoundingBoxes(:,3)/2, ...
                         relevantBoundingBoxes(:,2) + relevantBoundingBoxes(:,4)/2];
            if velocity < 0
                sign = 1;
            else
                sign = -1;
            end
            plottedCentroids = line(ax, 'XData', centroids(:, 1)+sign*(boundingBox(3)/2), ...
                                        'YData', centroids(:, 2));
            removingList = [removingList; plottedCentroids];
        end
    end
end
xlim(ax, [0 params.trackWidth]);
axis off;
end
