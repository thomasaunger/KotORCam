# KotORCam

This is a MATLAB® program that constructs a camera animation for use in _Star Wars™: Knights of the Old Republic™_, visualizes it and—if approved by the user—saves it to a file. The positions and orientations of the camera are constructed such that the square of the acceleration is minimized, while constrained by user-indicated positions and orientations or their first derivatives at specific times.

Position and orientation animations are initially constructed using cubic Bézier curves. These curves are constructed independently for the _x_-, _y_- and _z_-coordinates, as well as for the _theta_- (yaw), _phi_- (pitch) and _psi_-angles (roll). Alternatively, the position of a subject (also constructed using Bézier curves) can be indicated, prompting the _theta_- and _phi_-angles to be replaced with values that keep the camera oriented towards this subject.

In the simple case, it can be assumed that position refers to the position of the camera’s center of perspective and that orientation rotates around this point. For more realistic camera rotation, these assumptions can be violated by indicating a point of rotation for each of the angles of orientation. In general, this makes the position of the center of perspective dependent on orientation, which means that even when the camera supposedly moves in a straight line, the center of perspective may not. In particular, this makes following the position of a subject harder; to follow the subject from a given position, orientation must change, which in turn changes position, which requires another change of orientation, etc.. The `follow` function inside the `private` folder solves that problem by defining an appropriate cost function that is minimized using MATLAB®’s `fminunc` function.

## Installation

Simply drag the `KotORCam` folder to where you want to run it, then go inside this folder in MATLAB®.

## Usage

To run the program, call `kotorCam(name)`, where `name` is a string variable indicating the name of any resulting `MDL` file.

Position, rotation and subject position, as well as their first derivatives, can be indicated using the `pKnots.txt`, `rKnots.txt` and `sKnots.txt` files, respectively, which are located inside the `private` folder. Each of these files has an associated `Mask.txt` file, which indicates which values are to actually be used to construct the Bézier curves.

Further customizations can be made at the top of the `kotorCam.m` file, such as sample frequency, animation length, the points of rotation and more.

N.B.: this program was tested only on MATLAB® R2015a.

## Copyright

© 2019 Thomas A. Unger
