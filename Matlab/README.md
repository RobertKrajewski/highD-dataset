## highD Matlab tools
These tools allow you to read-in the highD csv files and visualize them in an interactive 
plot. Through modularity, one can use the i/o functions directly for individual applications.

```
 |- bin
    |- startVisualization.m
 |- data
 |- utils
    |- plotHighway.m
    |- plotTracksO.m
    |- plotTracksOnImage.m
    |- readInTracksCsv.m
    |- readInVideoCsv.m
 |- visualization
    |- trackVisualization.fig
    |- trackVisualization.m
 |- initialize.m
```

## Quickstart
1) Copy the csv files into the data directory
2) Run initialize.m
3) (Optional) Modify the videoName variable in bin/startVisualization.m
4) Run bin/startVisualization.m

## Method descriptions

### initialize.m
This script adds the folders to the working directory.

### bin

#### bin/startVisualization.m
Main visualization script.

### utils

#### utils/readInTracksCsv.m
This script extract tracks from the tracks csv file from highD. The structure that is extracted is clear 
and easy to use. Each track (a tracked vehicle) is an own struct containing all static and dynamic information 
for each frame that the vehicle is detected in. This script takes the dynamic and static tracks csv file and combines 
the information into one struct.

#### utils/readInVideoCsv.m
This script reads-in the video meta data from the highD csv file. 

#### utils/plotHighway.m
This script creates the highway from the lane description. The lanes are plotted into the "params.ax" axis. 

#### utils/plotTracks.m
This script plots the vehicles of a specific frame on virtual lanes. The used axis is the one passed with "params.ax".

#### utils/plotTracksOnImage.m
This script plots the vehicles of a specific frame on a background image. The used axis is the one passed with "params.ax".

### visualization

#### trackVisualization.m
This script is a complete program that creates an user interface. The user interface allows switching between frames 
of the given highD data containing virtual vehicles. The virtual vehicles contain some information about their tracks, 
which can be shown by clicking the vehicle bounding box. 
