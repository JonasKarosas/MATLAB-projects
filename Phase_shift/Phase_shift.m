clc;
clear;
close all;

% Choosing image folder
image_folder = uigetdir;
images_names = dir(fullfile(image_folder,'*.bmp'));
total_images = numel(images_names);

length = 40; % length in pixels
n_line = 10; % number of lines
mes = 1; % number of measurments (only important if auto~=1)

auto = 0.5; % automation of line drawing
% 0 - all lines drawn manually
% 0.5 - first two lines drawn manually, others at the same coordinates
% 1 - all lines drawn by the coordinates defined below
yl1 = 800;
yl2 = 1350;
xp1 = 940;
xp2 = 1650;

offs1(n_line) = zeros;% offset for the first line
offs2(n_line) = zeros;% offset for the first line
amp1(n_line) = zeros;% amplitude for the first line
amp2(n_line) = zeros;% amplitude for the first line
f1(n_line) = zeros; % freq for the first line
f2(n_line) = zeros; % freq for the second line
phi1(n_line) = zeros; % phase for the first line
phi2(n_line) = zeros; % phase for the second line
rez(total_images+1,mes) = zeros; % phase shift matrix

% FIRST LINE DRAWN ON UPPER INTEFERENCE LINES!
% SECOND LINE DRAWN ON LOWER INTEFERENCE LINES!

h = waitbar(0,'Please wait...');
for avg = 1:mes
    for m = 1:total_images
        % Reading pictures
        filename = fullfile (image_folder, images_names(m).name);
        I = imread(filename);
        % I = rgb2gray(I); % from RGB to grayscale
        
        % Getting coordinates of two lines
        if auto == 0
            imshow(I);
            title("Measurement: "+avg+"  Image name: "+extractBefore(images_names(m).name, "."))
            [x1,y] = getline;
            [x2,~] = getline;
        elseif auto == 0.5 && m == 1
            imshow(I);
            title("Measurement: "+avg+"  Image name: "+extractBefore(images_names(m).name, "."))
            [x1,y] = getline;
            [x2,~] = getline;
            close();
        elseif auto == 1
            y(1) = yl1;
            y(2) = yl2;
            x1(1) = xp1;
            x2(1) = xp2;
        end
        
        yline = [y(1), y(2)];
        dy = y(2)-y(1);
        
        % Averaging intensity of n lines arranged by the distance length
        for n = 1:n_line
            dx = -length/2 + length*(n-1)/(n_line-1);
            xpos1 = [x1(1)+dx, x1(1)+dx];
            xpos2 = [x2(1)+dx, x2(1)+dx];
           
            % Intensity distributions
            y_el = improfile(I, xpos1, yline); %modified zone
            y_ref = improfile(I, xpos2, yline); %unmodified zone
        
            y1 = y_el';
            y2 = y_ref';

            % Sine fit
            x = 0:1:dy+1;
            [SineP1] = sineFit(x, y1);
            [SineP2] = sineFit(x, y2);
 
            offs1(n) = SineP1(1);
            offs2(n) = SineP2(1);
            
            amp1(n) = SineP1(2);
            amp2(n) = SineP2(2);
            
            f1(n) = SineP1(3);
            f2(n) = SineP2(3);
            
            phi1(n) = SineP1(4);
            phi2(n) = SineP2(4);
        end
        
        % Offset
        offs1 = mean(offs1(n));
        offs2 = mean(offs2(n));
        offs = (offs1 + offs2) / 2;
        
        % Amplitude
        amp1 = mean(amp1(n));
        amp2 = mean(amp2(n));
        amp = (amp1 + amp2) / 2;
                
        % Frequency
        f1 = mean(f1(n));
        f2 = mean(f2(n));
        f = (f1 + f2) / 2;
        
        % Phase
        phi1 = mean(phi1(n));
        phi2 = mean(phi2(n));
        
        % Phase shift (refers to line shift)
        dx1 = (2*pi - phi1) / (2*pi * f1);
        dx2 = (2*pi - phi2) / (2*pi * f2);
        if (dx1 > dx2) % phase shift is over 2pi
            dx2 = (2*pi - phi2 + 2*pi) / (2*pi * f2);
        end
        phi = abs(dx1 - dx2);
        
        % Phase shift of the interference lines
        dfi = phi * f;
        
        rez(1,avg) = avg;
        rez(m+1, avg) = dfi;
        
        waitbar(m / total_images, h)
        
        % First line intensity plot
        figure(1) % green - real, blue - sine fit
        y1_fit = offs1 + amp1 * sin(2*pi * f1 * x + phi1);
        plot(x, y1, 'g', x, y1_fit, 'b')
        
        % Second line intensity plot
        figure(2) % green - real, red - sine fit
        y2_fit = offs2 + amp2 * sin(2*pi * f2 * x + phi2);
        plot(x, y2, 'g', x, y2_fit, 'r')
        
        % First and second lines with avearge amplitude and period
        figure(3)
        y1_fit = offs + amp * sin(2*pi * f * x + phi1);
        y2_fit = offs + amp * sin(2*pi * f * x + phi2);
        plot(x, y1_fit, 'b', x, y2_fit, 'r')
    end
end
close(gcf);
close(h)

writematrix(rez,'phase shift.txt');