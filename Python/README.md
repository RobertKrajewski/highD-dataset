## highD Python tools
The python toolbox gives the opportunity to read in the highD csv files and visualize them in an interactive 
plot. Through modularity, one can use the i/o functions directly for own usage. In the following, 
each method is shortly described to maintain easy and correct usage.

```
 |-data
 |-src
    |- data_management
        |- read_csv.py
    |- utils
        |- plot_utils.py
    |- visualization
        |- visualize_frame.py
    |- main.py
```

## Quickstart
1) Copy the csv files into the **data** directory in a sub folder 
3) (Optional) Modify the folder_name (sub folder) and video_name variable in main.py or by changing 
the arguments when calling the python function
4) Run main.py

## Method descriptions
One can find short descriptions of each method implemented in this toolbox. 
### main.py
The main file is the starting point for the program. In this main file, the program first reads in 
several input arguments that control the program. There are mandatory parameter defined like the paths for the 
highD csv files. You can find the other parameters and their descriptions in the "Parameter" section below. The main file
reads in the highD data and passes it to the visualization program. The visualization program is an interactive plot that
is able to display the lanes and the vehicles driving on that lanes. One can interactively switch between frames to see 
how the tracks of the vehicles evolve over time. 
### read_csv.py
The "read_csv.py" file contains the methods for reading in the highD data. The first method "read_track_csv"
reads the information for each tracked vehicle. Every unique track contains information and position of the 
tracked and detected vehicle for each frame. 

The method "read_static_info" extracts the static information of each track. Static information is, for instance, the
direction, average velocity and more characteristic values. 

The method "read_video_meta" reads the general meta information of the whole video. 

### visualize_frame.py
The visualization program is a class "VisualizationPlot" that takes the information of the three highD csv files to create
an interactive plot that allows switching between frames of the video containing virtual vehicles. The virtual vehicles 
contain some information about their tracks, which can be shown by clicking on the corresponding yellow information box 
above each vehicle bounding box. 

### plot_utils.py
The plot utilities contain a utility function that helps to visualize the frame bar of the visualization plot.

## Parameter
Parameter name | Default value | Type | Description
 ---| ---| ---| ---
 folder_name | "" | string | The name of the folder in which the csv files lie.
 video_name | "" | string | The name of the video, which is used for the data paths.
 input_path | "../data/{}/{}_stats.csv" | string | The tracks csv file containing detailed information at each time step for each track.
 input_static_path | "../data/{}/{}_stats_static.csv" | string | The static tracks csv file containing the general information for each track.
 input_meta_path | "../data/{}/{}_stats_meta.csv" | string | The video meta csv file containing general information about the video itself.
 pickle_path | "../data/{}/{}.pickle" | string | The path to the pickle file that either will be created when "save_as_pickle" is activated or will be read when already available.
 visualize | True | boolean | True for visualizing the video including all tracks and False for just reading in the data.
 background_image | None | string | The path to the corresponding background image of the selected video. This triggers the visualization in a way that the vehicles and its tracks are plotted on this background image
 save_as_pickle | True | boolean | True for saving the read in information in a pickle file for faster future loading.

