clc;
clear;
close all;

% Objective lens - RMS4X
% https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=1044&pn=RMS4X
% Parameters
NA = 0.1;
mgnf = 4;
lens = 100; % used lens (mm)
mgf = mgnf*lens/180;

% Camera parameters
% https://www.baslerweb.com/en/products/cameras/area-scan-cameras/ace/aca2500-14gc/
p = 0.0022; % pixel size (mm)
ps = p/mgf; % pixel size after magnification
width = 2000; % defined due to center missmacth between first and last pictures

% Picture upload
img_folder = uigetdir;
img_names = dir(fullfile(img_folder,'*.bmp'));
total_img = numel (img_names);

% X pasitioning stage first/step/end points
lengths = fullfile(img_folder, 'x_lengths.txt');
fid = fopen(lengths);
C = textscan(fid, '%s');
C = C{1};
first = str2double(C{1});
step = str2double(C{4});
last = str2double(C{7});

% Center point for the first picture
f = fullfile(img_folder, img_names(1).name);
f = imread(f);
f = imcomplement(f); % color inversion
SP = figure(1); % adding scroll bars
img = imshow(f);
imscrollpanel(SP,img); 
imoverview(img)
waitfor(msgbox('Double click on the picture to choose the center point'));
[x0,y0] = getpts;

% Center point for the last picture
f = fullfile (img_folder, img_names(total_img).name);
f = imread(f);
f = imcomplement(f); % color inversion
hold on
img = imshow(f);
[x1,y1] = getpts;
close(gcf)

% Calculating center shift between first and last pictures
dy = (y1-y0)/(total_img-1);
dx = (x1-x0)/(total_img-1);
h = waitbar(0,'Please wait...');

% Scanning the pictures
for n = 1:total_img
    f = fullfile (img_folder, img_names(n).name);
    I = imread(f);
    %I = rgb2gray(RGB); % from RGB to grayscale
    yline = [y0+dy*(n-1), y0+dy*(n-1)];
    xline = [x0-width+dx*(n-1), x0+width+dx*(n-1)];
    intensity = improfile(I-1,xline, yline);
    
    % Seting the size of the i array
    [row,col] = size(intensity);
    if n == 1
        cc = row;
        i = zeros(total_img, cc);
    end
    
    % Changing the size of ints array in case of different row nr in intensity
    if row > cc
        dif = row-cc;
        cc = row;
        dif_a = zeros(total_img, dif);
        i_ref = [i dif_a];
        i = i_ref;
    end
    
    % Assigning intensity values to the i array
    i(n,:) = intensity';
    
    waitbar(n/total_img,h)
end

posx = -width*ps:ps:width*ps;
posz = first:step:last;
[x,z] = meshgrid(posx,posz);

% Normalization
maxI = max(max(i));
disp(['Max intensity value in Matrix: ',num2str(maxI)])

% CONTOUR
% parula(default); jet; turbo; hsv; hot; cool; spring; summer; autumn; 
% winter; gray; bone; copper; pink; lines; colorcube; prism; flag; white
pos = [0.1 0.29 0.85 0.54]; % [left bottom width height]
subplot('Position',pos);
contourf(z,x,i/maxI, 100, 'linestyle','none')
colormap(gca, 'jet') 
set(gcf,'position',[0,0,800,300])

cbr = colorbar('southoutside'); % colorbar orientation
set(cbr, 'Position',[0.1 0.18 0.85 0.06]) % colorbar position
set(cbr, 'xtick',linspace (0, 1, 6)) % colorbar ticks range
tix0 = get(cbr,'xtick')';
set(cbr, 'xticklabel',num2str(tix0,'%.1f')) % decimal place
caxis([0 1]);
xlabel(cbr,'\itIntensity', 'Rotation',0.0, 'FontSize',13, 'Position',[0.5, -1.3, 0])

xlabel('\itz, \rmmm', 'FontSize',13, 'Position',[10, 1.1, 0])
xticks([0 5 10 15 20])
set(gca, 'xaxisLocation','top')
set(gca, 'FontSize',13, 'TickDir','out')

if C{5} == num2str('um')
    ylabel('\itx, \rmµm', 'FontSize',13)
else
    ylabel('\itx, \rmmm', 'FontSize',13)
end
ylim([-0.8 0.8])
yticks([-0.5 0 0.5])
tix = get(gca,'ytick')';
set(gca,'yticklabel',num2str(tix,'%.1f')) % decimal place

close(h)
saveas(gcf,'Beam profile.bmp');
