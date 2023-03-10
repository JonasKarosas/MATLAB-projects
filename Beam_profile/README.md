
# Beam profile plot

This project is about a technique used to draw beam profile after the diffractive optical element (DOE).
It applies to the elements made by different methods such photolithography, direct laser writing, volume laser writing etc.
The main parts of this technique are image registration with camera and its analysis with MATLAB. For more details, see 'Description.pdf' file.

In order to run the code 'plot.m', download the 'Sample.zip' with the 51 images and one text file. Unzip it. This is the sample of the beam
intensity distributions in XY plane at different Z positions of the positioning stage created by letting HeNe laser through volume Fresnel
lens which was recorder by the femtosecond laser. Text file consists of starting position, step and ending position of the positioning stage.

### MATLAB code:
1) Magnification is set to get the correct scale when plotting the beam profile.
2) All the pictures from the selected folder are uploaded.
3) Starting position, step and ending position of the stage uploaded from the 'x_lengths.txt' file.
4) Center point of the first and last pictures are set by hand.
5) Loop is created to scan all the images across the the center in x direction and intensity is found. All the intensities are stored in the array.
6) Intensity is normalised by the max value in the intensities array.
7) Plot is created and saved at the same location as 'plot.m' file. Plot can be seen in 'Result.png' file.
