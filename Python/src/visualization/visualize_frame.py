import os
import scipy.ndimage
import matplotlib as mpl

from data_management.read_csv import *

mpl.rcParams['savefig.dpi'] = 300
import matplotlib.pyplot as plt
from matplotlib.widgets import Button
from utils.plot_utils import DiscreteSlider


class VisualizationPlot(object):
    def __init__(self, arguments, read_tracks, static_info, meta_dictionary, fig=None):
        self.arguments = arguments
        self.tracks = read_tracks
        self.static_info = static_info
        self.meta_dictionary = meta_dictionary
        last_track = self.tracks[len(self.tracks) - 1]
        self.maximum_frames = self.static_info[last_track[TRACK_ID]][FINAL_FRAME] - 1
        self.current_frame = 1
        self.changed_button = False
        self.rect_map = {}
        self.plotted_objects = []

        # Create figure and axes
        if fig is None:
            self.fig, self.ax = plt.subplots(1, 1)
            self.fig.set_size_inches(32, 4)
            plt.subplots_adjust(left=0.0, right=1.0, bottom=0.20, top=1.0)
        else:
            self.fig = fig
            self.ax = self.fig.gca()

        # Check whether to use the given background image or to use the virtual created lanes
        background_image_path = arguments["background_image"]
        if background_image_path is not None and os.path.exists(background_image_path):
            # Plot the image
            self.background_image = scipy.ndimage.imread(background_image_path)
            self.y_sign = 1
            im = self.background_image[:, :, :]
            self.ax.imshow(im)
        else:
            # Create lane markings
            self.background_image = None
            self.y_sign = -1
            self.outer_line_thickness = .2
            self.lane_color = "white"
            self.plot_highway()

        # Initialize the plot with the bounding boxes of the first frame
        self.update_figure()

        ax_color = 'lightgoldenrodyellow'
        # Define axes for the widgets
        self.ax_slider = self.fig.add_axes([0.1, 0.05, 0.2, 0.03], facecolor=ax_color)  # Slider
        self.ax_button_previous2 = self.fig.add_axes([0.02, 0.035, 0.026, 0.07])  # Previous x5 button
        self.ax_button_previous = self.fig.add_axes([0.05, 0.035, 0.02, 0.07])  # Previous button
        self.ax_button_next = self.fig.add_axes([0.325, 0.035, 0.02, 0.07])  # Next button
        self.ax_button_next2 = self.fig.add_axes([0.35, 0.035, 0.025, 0.07])  # Next x5 button

        # Define the widgets
        self.frame_slider = DiscreteSlider(self.ax_slider, 'Frame', 1, self.maximum_frames, valinit=self.current_frame,
                                           valfmt='%s')
        self.button_previous2 = Button(self.ax_button_previous2, 'Previous x5')
        self.button_previous = Button(self.ax_button_previous, 'Previous')
        self.button_next = Button(self.ax_button_next, 'Next')
        self.button_next2 = Button(self.ax_button_next2, 'Next x5')

        # Define the callbacks for the widgets' actions
        self.frame_slider.on_changed(self.update_slider)
        self.button_previous.on_clicked(self.update_button_previous)
        self.button_next.on_clicked(self.update_button_next)
        self.button_previous2.on_clicked(self.update_button_previous2)
        self.button_next2.on_clicked(self.update_button_next2)

        self.ax.set_autoscale_on(False)

    def update_slider(self, value):
        if not self.changed_button:
            self.current_frame = value
            self.remove_patches()
            self.update_figure()
            self.fig.canvas.draw_idle()
        self.changed_button = False

    def update_button_next(self, _):
        if self.current_frame < self.maximum_frames:
            self.current_frame = self.current_frame + 1
            self.changed_button = True
            self.trigger_update()
        else:
            print("There are no frames available with an index higher than {}.".format(self.maximum_frames))  #

    def update_button_next2(self, _):
        if self.current_frame + 5 <= self.maximum_frames:
            self.current_frame = self.current_frame + 5
            self.changed_button = True
            self.trigger_update()
        else:
            print("There are no frames available with an index higher than {}.".format(self.maximum_frames))

    def update_button_previous(self, _):
        if self.current_frame > 1:
            self.current_frame = self.current_frame - 1
            self.changed_button = True
            self.trigger_update()
        else:
            print("There are no frames available with an index lower than 1.")

    def update_button_previous2(self, _):
        if self.current_frame - 5 > 0:
            self.current_frame = self.current_frame - 5
            self.changed_button = True
            self.trigger_update()
        else:
            print("There are no frames available with an index lower than 1.")

    def trigger_update(self):
        self.remove_patches()
        self.update_figure()
        self.frame_slider.update_val_external(self.current_frame)
        self.fig.canvas.draw_idle()

    def update_figure(self):
        # Dictionaries for the style of the different objects that are visualized
        rect_style = dict(facecolor="r", fill=True, edgecolor="k", zorder=19)
        triangle_style = dict(facecolor="k", fill=True, edgecolor="k", lw=0.1, alpha=0.6, zorder=19)
        text_style = dict(picker=True, size=8, color='k', zorder=10, ha="center")
        text_box_style = dict(boxstyle="round,pad=0.2", fc="yellow", alpha=.6, ec="black", lw=0.2)
        track_style = dict(color="r", linewidth=1, zorder=10)

        # Plot the bounding boxes, their text annotations and direction arrow
        plotted_objects = []
        for track in self.tracks:
            # Get the id of the current track
            track_id = track[TRACK_ID]
            static_track_information = self.static_info[track_id]
            # Get the initial and final frame of the track and check whether the current chosen frame is within these
            # bounds
            initial_frame = static_track_information[INITIAL_FRAME]
            final_frame = static_track_information[FINAL_FRAME]
            if initial_frame <= self.current_frame < final_frame:
                # If the current frame is within these bounds, we can now determine the internal track index for the
                # current frame.
                current_index = self.current_frame - initial_frame
                # Get the bounding box from the track information with the determined index
                try:
                    bounding_box = np.array(track[BBOX][current_index])
                    if self.arguments["background_image"] is not None:
                        bounding_box /= 0.10106
                        bounding_box /= 4
                    y_position = self.y_sign * bounding_box[1]
                except:
                    continue

                bounding_box_y = y_position
                # Plot the rectangle of the bounding box
                if self.arguments["plotBoundingBoxes"]:
                    if self.y_sign < 0:
                        bounding_box_y += self.y_sign * bounding_box[3]
                    rect = plt.Rectangle((bounding_box[0], bounding_box_y), bounding_box[2],
                                         bounding_box[3], **rect_style)
                    self.ax.add_patch(rect)
                    plotted_objects.append(rect)

                if self.arguments["plotDirectionTriangle"]:
                    # Add triangles that display the direction of the cars
                    current_velocity = track[X_VELOCITY][current_index]
                    triangle_y_position = [y_position,
                                           y_position + bounding_box[3],
                                           y_position + (bounding_box[3] / 2)]
                    if self.y_sign < 0:
                        triangle_y_position += self.y_sign * bounding_box[3]
                        bounding_box_y += self.y_sign * bounding_box[3]
                    # Differentiate between vehicles that drive on the upper or lower lanes
                    if current_velocity < 0:
                        x_back_position = bounding_box[0] + (bounding_box[2] * 0.2)
                        triangle_info = np.array([[x_back_position, x_back_position, bounding_box[0]], triangle_y_position])
                    else:
                        x_back_position = bounding_box[0] + bounding_box[2] - (bounding_box[2] * 0.2)
                        triangle_info = np.array([[x_back_position, x_back_position, bounding_box[0] + bounding_box[2]],
                                                  triangle_y_position])
                    polygon = plt.Polygon(np.transpose(triangle_info), True, **triangle_style)
                    self.ax.add_patch(polygon)
                    plotted_objects.append(polygon)

                if self.arguments["plotTextAnnotation"]:
                    # Plot the text annotation
                    vehicle_class = static_track_information[CLASS][0]

                    annotation_text = ""
                    if self.arguments["plotClass"]:
                        annotation_text += "{}".format(vehicle_class)
                    if self.arguments["plotVelocity"]:
                        if annotation_text != '':
                            annotation_text += '|'
                        x_velocity = abs(float(current_velocity)) * 3.6
                        annotation_text += "{:.2f}km/h".format(x_velocity)
                    if self.arguments["plotIDs"]:
                        if annotation_text != '':
                            annotation_text += '|'
                        annotation_text += "ID{}".format(track_id)
                    # Differentiate between using an empty background image and using the virtual background
                    if self.background_image is not None:
                        target_location = (bounding_box[0], y_position - 1)
                        text_location = (bounding_box[0] + (bounding_box[2] / 2), y_position - 1.5)
                    else:
                        target_location = (bounding_box[0], y_position + 1)
                        text_location = (bounding_box[0] + (bounding_box[2] / 2), y_position + 1.5)
                    text_patch = self.ax.annotate(annotation_text, xy=target_location, xytext=text_location,
                                                  bbox=text_box_style, **text_style)
                    plotted_objects.append(text_patch)

                # Plot tracking line for each vehicle
                if self.arguments["plotTrackingLines"]:
                    relevant_bounding_boxes = np.array(track[BBOX][0:current_index, :])
                    if relevant_bounding_boxes.shape[0] > 0:
                        if self.arguments["background_image"] is not None:
                            relevant_bounding_boxes /= 0.10106
                            relevant_bounding_boxes /= 4
                        sign = 1 if self.background_image is not None else self.y_sign
                        # Calculate the centroid of the vehicles by using the bounding box information
                        x_centroid_position = relevant_bounding_boxes[:, 0] + relevant_bounding_boxes[:, 2] / 2
                        y_centroid_position = (sign * relevant_bounding_boxes[:, 1]) + sign * (relevant_bounding_boxes[:, 3]) / 2
                        centroids = [x_centroid_position, y_centroid_position]
                        centroids = np.transpose(centroids)
                        # Check track direction
                        track_sign = 1 if current_velocity < 0 else -1
                        plotted_centroids = self.ax.plot(centroids[:, 0] + track_sign * (bounding_box[3] / 2),
                                                         centroids[:, 1], **track_style)
                        plotted_objects.append(plotted_centroids)

                # Save the plotted objects in a list
        self.fig.canvas.mpl_connect('pick_event', self.on_click)
        self.plotted_objects = plotted_objects

    def plot_highway(self):
        # Initialization
        upper_lanes = self.meta_dictionary[UPPER_LANE_MARKINGS]
        upper_lanes_shape = upper_lanes.shape
        lower_lanes = self.meta_dictionary[LOWER_LANE_MARKINGS]
        lower_lanes_shape = lower_lanes.shape
        # Top lane area
        rect = plt.Rectangle((0, self.y_sign * lower_lanes[lower_lanes_shape[0] - 1] - 5), 400,
                             lower_lanes[lower_lanes_shape[0] - 1] - upper_lanes[0] + 10,
                             color="grey", fill=True, alpha=1, zorder=5)
        self.ax.add_patch(rect)
        rect = plt.Rectangle((0, self.y_sign * upper_lanes[0]), 400, self.outer_line_thickness, color=self.lane_color,
                             fill=True, alpha=1, zorder=5)
        self.ax.add_patch(rect)
        for i in range(1, upper_lanes_shape[0] - 1):
            plt.plot((0, 400), (self.y_sign * upper_lanes[i], self.y_sign * upper_lanes[i]), color=self.lane_color,
                     linestyle="dashed", dashes=(25, 70), alpha=1, zorder=5)
        rect = plt.Rectangle((0, self.y_sign * upper_lanes[upper_lanes_shape[0] - 1]), 400, self.outer_line_thickness,
                             color=self.lane_color,
                             fill=True, alpha=1, zorder=5)
        self.ax.add_patch(rect)
        # Bottom lane area
        rect = plt.Rectangle((0, self.y_sign * lower_lanes[0]), 400, self.outer_line_thickness, color=self.lane_color,
                             alpha=1, zorder=5)
        self.ax.add_patch(rect)
        for i in range(1, lower_lanes_shape[0] - 1):
            plt.plot((0, 400), (self.y_sign * lower_lanes[i], self.y_sign * lower_lanes[i]), color=self.lane_color,
                     linestyle="dashed", dashes=(25, 70), alpha=1, zorder=5)
        rect = plt.Rectangle((0, self.y_sign * lower_lanes[lower_lanes_shape[0] - 1]), 400, self.outer_line_thickness,
                             color=self.lane_color,
                             alpha=1, zorder=5)
        self.ax.add_patch(rect)

    def on_click(self, event):
        artist = event.artist
        text_value = artist._text
        try:
            track_id = int(text_value[text_value.find("ID") + 2:])
            selected_track = None
            for track in self.tracks:
                if track[TRACK_ID] == track_id:
                    selected_track = track
                    break
            if selected_track is None:
                print("No track with the ID {} was found. Nothing to show.".format(track_id))
                return
            static_information = self.static_info[track_id]
            # Get bounding boxes for the selected track
            bounding_box = selected_track[BBOX]
            centroids = [bounding_box[:, 0] + bounding_box[:, 2] / 2,
                         bounding_box[:, 1] + bounding_box[:, 3] / 2]
            centroids = np.transpose(centroids)
            initial_frame = static_information[INITIAL_FRAME]
            final_frame = static_information[FINAL_FRAME]
            x_limits = [initial_frame, final_frame]
            track_frames = np.linspace(initial_frame, final_frame, centroids.shape[0], dtype=np.int64)
            # Create a new figure that pops up
            fig = plt.figure(np.random.randint(0, 5000, 1))
            fig.canvas.set_window_title("Track {}".format(track_id))
            plt.suptitle("Information for track {}.".format(track_id))
            # Plot the x positions
            plt.subplot(311, title="X-Position")
            x_positions = centroids[:, 0]
            borders = [np.amin(x_positions), np.amax(x_positions)]
            plt.plot(track_frames, x_positions)
            plt.plot([self.current_frame, self.current_frame], borders, "--r")
            plt.xlim(x_limits)
            offset = (borders[1] - borders[0]) * 0.05
            borders = [borders[0] - offset, borders[1] + offset]
            plt.ylim(borders)
            plt.xlabel('Frame')
            plt.ylabel('X-Position [m]')

            # Plot the y positions
            plt.subplot(312, title="Y-Position")
            y_positions = centroids[:, 1]
            borders = [np.amin(y_positions), np.amax(y_positions)]
            plt.plot(track_frames, y_positions)
            plt.plot([self.current_frame, self.current_frame], borders, "--r")
            plt.xlim(x_limits)
            offset = (borders[1] - borders[0]) * 0.05
            borders = [borders[0] - offset, borders[1] + offset]
            plt.ylim(borders)
            plt.xlabel('Frame')
            plt.ylabel('Y-Position [m]')

            # Plot the velocity
            plt.subplot(313, title="X-Velocity")
            velocity = abs(selected_track[X_VELOCITY])
            borders = [np.amin(velocity), np.amax(velocity)]
            plt.plot(track_frames, velocity)
            plt.plot([self.current_frame, self.current_frame], borders, "--r")
            plt.xlim(x_limits)
            offset = (borders[1] - borders[0]) * 0.05
            borders = [borders[0] - offset, borders[1] + offset]
            plt.ylim(borders)
            plt.xlabel('Frame')
            plt.ylabel('X-Velocity [m/s]')

            plt.subplots_adjust(wspace=0.1, hspace=1)
            plt.show()
        except:
            print("Something went wrong when trying to plot the detailed information of the vehicle.")
            return

    def get_figure(self):
        return self.fig

    def remove_patches(self, ):
        self.fig.canvas.mpl_disconnect('pick_event')
        for figure_object in self.plotted_objects:
            if isinstance(figure_object, list):
                figure_object[0].remove()
            else:
                figure_object.remove()

    @staticmethod
    def show():
        plt.show()
        plt.close()
