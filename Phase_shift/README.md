
# Phase shift measurement

This project is about phase shift measurement with Michelson interferometer. The results can be used to calculate refractive index change which is created by tighlty focusing femtosecond laser beam inside fused silica glass and creating structurtal change called modification.

Please carefully read the 'Refractive index change calculation.pdf' file at first.

In order to run the code 'measurement.m', download 'sineFit' function file. Download 'Samples.zip' with the 10 images. Unzip it. These samples show interference paterns created by using Michelson interferometer. The visible line shift occurs when there is a difference between fused silica and modifieded fused silica refractive indices.

### MATLAB code:
1) Image folder is selected.
2) Total length in pixels (for left and rigth side), number of lines and measurment number are set for averaging.
3) Manual or automated line drawing is chosen.
4) Images are scanned.
5) Offset, amplitude, frequency and phase of both lines are calculated.
6) Line shift is calculated.
7) Phase shift is calculated.
8) Three plots are created: 
  - first line with sine approximation,
  - second line with sine approximation,
  - both approximations with avergae amplitude and period.
9) All the phase shifts are saved in 'results.txt' file. Number at the top refers to the measurement number.
