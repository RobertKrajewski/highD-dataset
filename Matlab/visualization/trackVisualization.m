function varargout = trackVisualization(varargin)
% TRACKVISUALIZATION MATLAB code for trackVisualization.fig
%      TRACKVISUALIZATION, by itself, creates a new TRACKVISUALIZATION or raises the existing
%      singleton*.
%
%      H = TRACKVISUALIZATION returns the handle to a new TRACKVISUALIZATION or the handle to
%      the existing singleton*.
%
%      TRACKVISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKVISUALIZATION.M with the given input arguments.
%
%      TRACKVISUALIZATION('Property','Value',...) creates a new TRACKVISUALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackVisualization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackVisualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackVisualization

% Last Modified by GUIDE v2.5 03-Sep-2018 08:42:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackVisualization_OpeningFcn, ...
                   'gui_OutputFcn',  @trackVisualization_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackVisualization is made visible.
function trackVisualization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackVisualization (see VARARGIN)

inputArguments = varargin{1};

handles.tracks = inputArguments.tracks;
handles.videoMeta = inputArguments.videoMeta;
handles.backgroundImagePath = inputArguments.backgroundImagePath;

% Plot parameters
handles.laneThickness = inputArguments.laneThickness;
handles.laneColor = inputArguments.laneColor;
handles.trackWidth = inputArguments.trackWidth;
handles.streetColor = inputArguments.streetColor;
handles.boundingBoxColor = inputArguments.boundingBoxColor;
handles.removingList = inputArguments.removingList;
handles.currentFrame = inputArguments.currentFrame;
handles.minimumFrame = inputArguments.minimumFrame;
handles.maximumFrame = inputArguments.maximumFrame;
handles.stop = inputArguments.stop;
handles.playRate = inputArguments.playRate;
handles.plotTextAnnotation = inputArguments.plotTextAnnotation;
handles.plotTrackingLine = inputArguments.plotTrackingLine;
handles.geoParams = inputArguments.geoParams;

% Function to handle clicks on the bounding boxes
handles.onClick = @onClick; 

% Set the default values for the GUI objects
set(handles.frameSlider,'Value', handles.currentFrame);
set(handles.frameSlider,'Min', 1);
set(handles.frameSlider,'Max', handles.maximumFrame);
set(handles.frameSlider,'SliderStep', [1/handles.maximumFrame 1]);
set(handles.frameText,'String', num2str(handles.currentFrame));
set(handles.playRateEdit,'String', num2str(handles.playRate));
set(handles.stopButton,'Enable', 'off');

% Handle either a background image or create the lanes
if handles.backgroundImagePath == ""
    handles.backgroundImage = "";
    handles.highwayAxes = plotHighway(handles);
    daspect([2 1 1])
    removingList = plotTracks(handles.highwayAxes, handles.tracks, ...
        handles.currentFrame, handles, handles.removingList);
    handles.removingList = removingList;
else    
    backgroundImage = imread(handles.backgroundImagePath);
    backgroundImage = backgroundImage(:, :, :);
    handles.backgroundImage = backgroundImage;
    imagesc([.0 .0], [.0 .0], backgroundImage);
    removingList = plotTracksOnImage(handles.highwayAxes, ...
        handles.tracks, handles.currentFrame, handles, handles.removingList);
    handles.removingList = removingList;
	xlim([0 size(handles.backgroundImage, 2)]);
end

% Choose default command line output for trackVisualization
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackVisualization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackVisualization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
sliderValue = int32(round(get(hObject,'Value')));
handles = setFrame(handles, sliderValue);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in previous2Button.
function previous2Button_Callback(hObject, eventdata, handles)
% hObject    handle to previous2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newFrame = handles.currentFrame - 5;
if handles.minimumFrame <= newFrame
    handles = setFrame(handles, newFrame);
    guidata(hObject, handles);
end

% --- Executes on button press in previousButton.
function previousButton_Callback(hObject, eventdata, handles)
% hObject    handle to previousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newFrame = handles.currentFrame - 1;
if handles.minimumFrame <= newFrame
    handles = setFrame(handles, newFrame);
    guidata(hObject, handles);
end

% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newFrame = handles.currentFrame + 1;
if handles.maximumFrame >= newFrame
    handles = setFrame(handles, newFrame);
    guidata(hObject, handles);
end
    
% --- Executes on button press in next2Button.
function next2Button_Callback(hObject, eventdata, handles)
% hObject    handle to next2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newFrame = handles.currentFrame + 5;
if handles.maximumFrame >= newFrame
    handles = setFrame(handles, newFrame);
    guidata(hObject, handles);
end

% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    handles.stop = 0;
    set(handles.playButton,'Enable', 'off');
    set(handles.stopButton,'Enable', 'on');
    guidata(hObject, handles);
    while handles.currentFrame < handles.maximumFrame
        handles = guidata(hObject);
        if handles.stop
            break;
        end
        followingFrame = handles.currentFrame + handles.playRate;
        if handles.maximumFrame < followingFrame
            break;
        end
        handles.currentFrame = followingFrame;
        set(handles.frameText,'String', num2str(handles.currentFrame));
        set(handles.frameSlider,'Value', handles.currentFrame);
        if handles.backgroundImagePath == ""
            removingList = plotTracks(handles.highwayAxes, ...
                handles.tracks, handles.currentFrame, handles, handles.removingList);
        else
            removingList = plotTracksOnImage(handles.highwayAxes, ...
                handles.tracks, handles.currentFrame, handles, handles.removingList);
            xlim([0 size(handles.backgroundImage, 2)]);
        end
        handles.removingList = removingList;
        guidata(hObject, handles);
        drawnow;
    end
    set(handles.playButton,'Enable', 'on');
    set(handles.stopButton,'Enable', 'off');
    handles.stop = 0;
    guidata(hObject, handles);
catch 
end

% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.stop = 1;
guidata(hObject, handles);
if handles.backgroundImagePath == ""
    removingList = plotTracks(handles.highwayAxes, ...
        handles.tracks, handles.currentFrame, handles, handles.removingList);
else
    removingList = plotTracksOnImage(handles.highwayAxes, ...
        handles.tracks, handles.currentFrame, handles, handles.removingList);
	xlim([0 size(handles.backgroundImage, 2)]);
end
handles.removingList = removingList;
guidata(hObject, handles);


function playRateEdit_Callback(hObject, eventdata, handles)
% hObject    handle to playRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of playRateEdit as text
%        str2double(get(hObject,'String')) returns contents of playRateEdit as a double
try
    playRate = str2double(get(hObject,'String'));
    if isnan(playRate)
        set(handles.playRateEdit,'BackgroundColor', [1 .5 .45]);
    else
        handles.playRate = playRate;
    set(handles.playRateEdit,'BackgroundColor', [1 1 1]);
    end
catch
    set(handles.playRateEdit,'BackgroundColor', [1 .5 .45]);
end
guidata(hObject, handles);
    

% --- Executes during object creation, after setting all properties.
function playRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to playRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on playRateEdit and none of its controls.
function playRateEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to playRateEdit (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
failed = 0;
try
    playRate = str2double(get(hObject,'String'));
    if isnan(playRate) || isinf(playRate)
        failed = 1;
    end        
catch
    failed = 1;
end
if failed
    set(handles.playRateEdit,'BackgroundColor', [1, .5 .45]);
else
    set(handles.playRateEdit,'BackgroundColor', [1 1 1]);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.stop = 1;
guidata(hObject, handles);
drawnow;
[file,~] = uiputfile;
set(gcf,'PaperPositionMode','auto');
print(file,'-dpng','-noui', '-r300');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
handles.stop = 1;
guidata(hObject, handles);
java.lang.Thread.sleep(1*100)
delete(hObject);
close all;

% --- Executes on mouse press over axes background.
function highwayAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to highwayAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function [handles] = setFrame(handles, newFrame)
handles.currentFrame = newFrame;
set(handles.frameText,'String', num2str(handles.currentFrame));
set(handles.frameSlider,'Value', handles.currentFrame);
if handles.backgroundImagePath == ""
    removingList = plotTracks(handles.highwayAxes, ...
        handles.tracks, handles.currentFrame, handles, handles.removingList);
else
    removingList = plotTracksOnImage(handles.highwayAxes, ...
        handles.tracks, handles.currentFrame, handles, handles.removingList);
	xlim([0 size(handles.backgroundImage, 2)]);
end
handles.removingList = removingList;


function onClick(~, ~, track, currentFrame)
% Get actual bounding boxes and positions
boundingBoxes = track.bbox;
centroids = [boundingBoxes(:,1) + boundingBoxes(:,3)/2, ...
             boundingBoxes(:,2) + boundingBoxes(:,4)/2];

% Create new figure
figure('Name', sprintf('Track %d', track.id));
framesForTrack = track.initialFrame:1:track.finalFrame;
currentFrameLine = [currentFrame currentFrame];

% Plot X position
axInfo = subplot(3, 1, 1);
hold all;
grid on;
xPositions = centroids(1:end, 1);
plot(axInfo, framesForTrack, xPositions);
line(axInfo, currentFrameLine, [min(xPositions) max(xPositions)], 'Color', 'r', 'LineStyle', '--');
xlabel(axInfo, 'Frame');
ylabel(axInfo, 'X-Position [m]');
xlim(axInfo, [track.initialFrame track.finalFrame]);
yLimits = [min(xPositions) max(xPositions)];
offset = (yLimits(2) - yLimits(1)) * 0.05;
yLimits =[yLimits(1) - offset, yLimits(2) + offset];
ylim(axInfo, yLimits);
title(axInfo, 'X-Position');

% Plot Y position
axInfo = subplot(3, 1, 2);

hold all;
grid on;
yPositions = centroids(1:end, 2);
plot(axInfo, framesForTrack, yPositions);
line(axInfo, currentFrameLine, [min(yPositions) max(yPositions)], 'Color', 'r', 'LineStyle', '--');
xlabel(axInfo, 'Frame');
ylabel(axInfo, 'Y-Position [m]');
xlim(axInfo, [track.initialFrame track.finalFrame]);
yLimits = [min(yPositions) max(yPositions)];
offset = (yLimits(2) - yLimits(1)) * 0.05;
yLimits =[yLimits(1) - offset, yLimits(2) + offset];
ylim(axInfo, yLimits);
title(axInfo, 'Y-Position');

% Plot Velocity
axInfo = subplot(3, 1, 3);
hold all;
grid on;
velocity = abs(track.xVelocity(1:end));
plot(axInfo, framesForTrack(1:end), velocity(1:end));
line(axInfo, currentFrameLine, [0 50], 'Color', 'r', 'LineStyle', '--');
xlabel(axInfo, 'Frame');
ylabel(axInfo, 'Velocity [m/s]');
xlim(axInfo, [track.initialFrame track.finalFrame]);
yLimits = [min(velocity) max(velocity)];
offset = (yLimits(2) - yLimits(1)) * 0.05;
yLimits =[yLimits(1) - offset, yLimits(2) + offset];
ylim(axInfo, yLimits);
title(axInfo, 'Velocity');
