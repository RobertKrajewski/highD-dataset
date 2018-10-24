import os
import sys
import pickle
import argparse

from data_management.read_csv import *
from visualization.visualize_frame import VisualizationPlot


def create_args():
    parser = argparse.ArgumentParser(description="ParameterOptimizer")
    # --- Input paths ---
    parser.add_argument('--input_path', default="../data/01_tracks.csv", type=str,
                        help='CSV file of the tracks')
    parser.add_argument('--input_static_path', default="../data/01_tracksMeta.csv",
                        type=str,
                        help='Static meta data file for each track')
    parser.add_argument('--input_meta_path', default="../data/01_recordingMeta.csv",
                        type=str,
                        help='Static meta data file for the whole video')
    parser.add_argument('--pickle_path', default="../data/01.pickle", type=str,
                        help='Converted pickle file that contains corresponding information of the "input_path" file')
    # --- Settings ---
    parser.add_argument('--visualize', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='True if you want to visualize the data.')
    parser.add_argument('--background_image', default="../data/01_highway.jpg", type=str,
                        help='Optional: you can specify the correlating background image.')

    # --- Visualization settings ---
    parser.add_argument('--plotBoundingBoxes', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to plot the bounding boxes or not.')
    parser.add_argument('--plotDirectionTriangle', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to plot the direction triangle or not.')
    parser.add_argument('--plotTextAnnotation', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to plot the text annotation or not.')
    parser.add_argument('--plotTrackingLines', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to plot the tracking lines or not.')
    parser.add_argument('--plotClass', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to show the class in the text annotation.')
    parser.add_argument('--plotVelocity', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to show the class in the text annotation.')
    parser.add_argument('--plotIDs', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: decide whether to show the class in the text annotation.')

    # --- I/O settings ---
    parser.add_argument('--save_as_pickle', default=True, type=lambda x: (str(x).lower() == 'true'),
                        help='Optional: you can save the tracks as pickle.')
    parsed_arguments = vars(parser.parse_args())
    return parsed_arguments


if __name__ == '__main__':
    created_arguments = create_args()
    print("Try to find the saved pickle file for better performance.")
    # Read the track csv and convert to useful format
    if os.path.exists(created_arguments["pickle_path"]):
        with open(created_arguments["pickle_path"], "rb") as fp:
            tracks = pickle.load(fp)
        print("Found pickle file {}.".format(created_arguments["pickle_path"]))
    else:
        print("Pickle file not found, csv will be imported now.")
        tracks = read_track_csv(created_arguments)
        print("Finished importing the pickle file.")

    if created_arguments["save_as_pickle"] and not os.path.exists(created_arguments["pickle_path"]):
        print("Save tracks to pickle file.")
        with open(created_arguments["pickle_path"], "wb") as fp:
            pickle.dump(tracks, fp)

    # Read the static info
    try:
        static_info = read_static_info(created_arguments)
    except:
        print("The static info file is either missing or contains incorrect characters.")
        sys.exit(1)

    # Read the video meta
    try:
        meta_dictionary = read_meta_info(created_arguments)
    except:
        print("The video meta file is either missing or contains incorrect characters.")
        sys.exit(1)

    if created_arguments["visualize"]:
        if tracks is None:
            print("Please specify the path to the tracks csv/pickle file.")
            sys.exit(1)
        if static_info is None:
            print("Please specify the path to the static tracks csv file.")
            sys.exit(1)
        if meta_dictionary is None:
            print("Please specify the path to the video meta csv file.")
            sys.exit(1)
        visualization_plot = VisualizationPlot(created_arguments, tracks, static_info, meta_dictionary)
        visualization_plot.show()