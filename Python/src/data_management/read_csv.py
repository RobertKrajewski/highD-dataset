import pandas
import numpy as np

# TRACK FILE
BBOX = "bbox"
FRAMES = "frames"
FRAME = "frame"
TRACK_ID = "id"
X = "x"
Y = "y"
WIDTH = "width"
HEIGHT = "height"
X_VELOCITY = "xVelocity"
Y_VELOCITY = "yVelocity"
X_ACCELERATION = "xAcceleration"
Y_ACCELERATION = "yAcceleration"
FRONT_SIGHT_DISTANCE = "frontSightDistance"
BACK_SIGHT_DISTANCE = "backSightDistance"
DHW = "dhw"
THW = "thw"
TTC = "ttc"
PRECEDING_X_VELOCITY = "precedingXVelocity"
PRECEDING_ID = "precedingId"
FOLLOWING_ID = "followingId"
LEFT_PRECEDING_ID = "leftPrecedingId"
LEFT_ALONGSIDE_ID = "leftAlongsideId"
LEFT_FOLLOWING_ID = "leftFollowingId"
RIGHT_PRECEDING_ID = "rightPrecedingId"
RIGHT_ALONGSIDE_ID = "rightAlongsideId"
RIGHT_FOLLOWING_ID = "rightFollowingId"
LANE_ID = "laneId"

# STATIC FILE
INITIAL_FRAME = "initialFrame"
FINAL_FRAME = "finalFrame"
NUM_FRAMES = "numFrames"
CLASS = "class"
DRIVING_DIRECTION = "drivingDirection"
TRAVELED_DISTANCE = "traveledDistance"
MIN_X_VELOCITY = "minXVelocity"
MAX_X_VELOCITY = "maxXVelocity"
MEAN_X_VELOCITY = "meanXVelocity"
MIN_DHW = "minDHW"
MIN_THW = "minTHW"
MIN_TTC = "minTTC"
NUMBER_LANE_CHANGES = "numLaneChanges"

# VIDEO META
ID = "id"
FRAME_RATE = "frameRate"
LOCATION_ID = "locationId"
SPEED_LIMIT = "speedLimit"
MONTH = "month"
WEEKDAY = "weekDay"
START_TIME = "startTime"
DURATION = "duration"
TOTAL_DRIVEN_DISTANCE = "totalDrivenDistance"
TOTAL_DRIVEN_TIME = "totalDrivenTime"
N_VEHICLES = "numVehicles"
N_CARS = "numCars"
N_TRUCKS = "numTrucks"
UPPER_LANE_MARKINGS = "upperLaneMarkings"
LOWER_LANE_MARKINGS = "lowerLaneMarkings"


def read_track_csv(arguments):
    """
    This method reads the tracks file from highD data.

    :param arguments: the parsed arguments for the program containing the input path for the tracks csv file.
    :return: a list containing all tracks as dictionaries.
    """
    # Read the csv file, convert it into a useful data structure
    df = pandas.read_csv(arguments["input_path"])

    # Declare and initialize the tracks list and some variables
    tracks = []
    actual_id = -1
    track_length = 0

    # Iterate over all rows of the csv because we need to create the bounding boxes for each row
    for i_row in range(df.shape[0]):
        i_track_id = df[TRACK_ID][i_row]
        # Set the first track_id
        if actual_id == -1:
            actual_id = i_track_id

        # Create the dictionary for each track. Using mostly vectorized code to be faster and save memory
        if actual_id != i_track_id:
            starting_index = int(i_row - track_length)
            r = list(range(starting_index, i_row))
            bounding_boxes = np.transpose(np.array([df[X][r].values,
                                                    df[Y][r].values,
                                                    df[WIDTH][r].values,
                                                    df[HEIGHT][r].values]))
            track = {TRACK_ID: actual_id,
                     FRAME: df[FRAME][r].values,
                     BBOX: bounding_boxes,
                     X_VELOCITY: df[X_VELOCITY][r].values,
                     Y_VELOCITY: df[Y_VELOCITY][r].values,
                     X_ACCELERATION: df[X_ACCELERATION][r].values,
                     Y_ACCELERATION: df[Y_ACCELERATION][r].values,
                     FRONT_SIGHT_DISTANCE: df[FRONT_SIGHT_DISTANCE][r].values,
                     BACK_SIGHT_DISTANCE: df[BACK_SIGHT_DISTANCE][r].values,
                     THW: df[THW][r].values,
                     TTC: df[TTC][r].values,
                     DHW: df[DHW][r].values,
                     PRECEDING_X_VELOCITY: df[PRECEDING_X_VELOCITY][r].values,
                     PRECEDING_ID: df[PRECEDING_ID][r].values,
                     FOLLOWING_ID: df[FOLLOWING_ID][r].values,
                     LEFT_FOLLOWING_ID: df[LEFT_FOLLOWING_ID][r].values,
                     LEFT_ALONGSIDE_ID: df[LEFT_ALONGSIDE_ID][r].values,
                     LEFT_PRECEDING_ID: df[LEFT_PRECEDING_ID][r].values,
                     RIGHT_FOLLOWING_ID: df[RIGHT_FOLLOWING_ID][r].values,
                     RIGHT_ALONGSIDE_ID: df[RIGHT_ALONGSIDE_ID][r].values,
                     RIGHT_PRECEDING_ID: df[RIGHT_PRECEDING_ID][r].values,
                     LANE_ID: df[LANE_ID][r].values
                     }
            # Reset the bounding boxes list and set the new track id
            actual_id = i_track_id
            track_length = 0

            # Add the new track to the tracks list
            tracks.append(track)
        track_length += 1
    return tracks


def read_static_info(arguments):
    """
    This method reads the static info file from highD data.

    :param arguments: the parsed arguments for the program containing the input path for the static csv file.
    :return: the static dictionary - the key is the track_id and the value is the corresponding data for this track
    """
    # Read the csv file, convert it into a useful data structure
    df = pandas.read_csv(arguments["input_static_path"])

    # Declare and initialize the static_dictionary
    static_dictionary = {}

    # Iterate over all rows of the csv because we need to create the bounding boxes for each row
    for i_row in range(df.shape[0]):
        track_id = int(df[TRACK_ID][i_row])
        static_dictionary[track_id] = {TRACK_ID: track_id,
                                       WIDTH: int(df[WIDTH][i_row]),
                                       HEIGHT: int(df[HEIGHT][i_row]),
                                       INITIAL_FRAME: int(df[INITIAL_FRAME][i_row]),
                                       FINAL_FRAME: int(df[FINAL_FRAME][i_row]),
                                       NUM_FRAMES: int(df[NUM_FRAMES][i_row]),
                                       CLASS: str(df[CLASS][i_row]),
                                       DRIVING_DIRECTION: float(df[DRIVING_DIRECTION][i_row]),
                                       TRAVELED_DISTANCE: float(df[TRAVELED_DISTANCE][i_row]),
                                       MIN_X_VELOCITY: float(df[MIN_X_VELOCITY][i_row]),
                                       MAX_X_VELOCITY: float(df[MAX_X_VELOCITY][i_row]),
                                       MEAN_X_VELOCITY: float(df[MEAN_X_VELOCITY][i_row]),
                                       MIN_TTC: float(df[MIN_TTC][i_row]),
                                       MIN_THW: float(df[MIN_THW][i_row]),
                                       MIN_DHW: float(df[MIN_DHW][i_row]),
                                       NUMBER_LANE_CHANGES: int(df[NUMBER_LANE_CHANGES][i_row])
                                       }
    return static_dictionary


def read_meta_info(arguments):
    """
    This method reads the video meta file from highD data.

    :param arguments: the parsed arguments for the program containing the input path for the video meta csv file.
    :return: the meta dictionary containing the general information of the video
    """
    # Read the csv file, convert it into a useful data structure
    df = pandas.read_csv(arguments["input_meta_path"])

    # Declare and initialize the extracted_meta_dictionary
    extracted_meta_dictionary = {ID: int(df[ID][0]),
                                 FRAME_RATE: int(df[FRAME_RATE][0]),
                                 LOCATION_ID: int(df[LOCATION_ID][0]),
                                 SPEED_LIMIT: float(df[SPEED_LIMIT][0]),
                                 MONTH: str(df[MONTH][0]),
                                 WEEKDAY: str(df[WEEKDAY][0]),
                                 START_TIME: str(df[START_TIME][0]),
                                 DURATION: float(df[DURATION][0]),
                                 TOTAL_DRIVEN_DISTANCE: float(df[TOTAL_DRIVEN_DISTANCE][0]),
                                 TOTAL_DRIVEN_TIME: float(df[TOTAL_DRIVEN_TIME][0]),
                                 N_VEHICLES: int(df[N_VEHICLES][0]),
                                 N_CARS: int(df[N_CARS][0]),
                                 N_TRUCKS: int(df[N_TRUCKS][0]),
                                 UPPER_LANE_MARKINGS: np.fromstring(df[UPPER_LANE_MARKINGS][0], sep=";"),
                                 LOWER_LANE_MARKINGS: np.fromstring(df[LOWER_LANE_MARKINGS][0], sep=";")}
    return extracted_meta_dictionary
