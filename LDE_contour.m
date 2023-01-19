fitted = 0; % change to 1 in case to draw fitted plot

if fitted == 0
    clc;
    clear;
    close all;

    Pulse_E = 0;   % 0 - values are taken by the code
    Foc_depth = 0; % 1 - values taken from txt file             

    % Pulse energies
    E_start = 100;                  
    E_step = 50;                    
    E_end = 850;                    
    E=E_start:E_step:E_end;
    
    % Focusing depths
    D_start = 2.0;                  
    D_step = 0.2;                   
    D_end = 5.6;                    
    D = D_start:D_step:D_end;

    % IMPORT DATA
    % 1) Modification axial lenghts
    [lengths, path1] = uigetfile('*.txt','Please choose txt file with modification axial leghts (choose scanning speed)');
    L = fullfile(path1, lengths);
    z = importdata(L); % um
    max_z = max(max(z));
    disp(['Maximum modification axial legth value is ', num2str(max_z), 'um']);

    % 2) Pulse energies
    if Pulse_E == 1
        [energy, path2]= uigetfile('*.txt','Please choose txt file with pulse energies or press cancel');
        ee = fullfile(path2, energy);
        if (ee ~= 0)
            E = (importdata(ee))'; % nJ
        end
    end

    % 3) Focusing depths
    if Foc_depth == 1
        [depths, path3] = uigetfile('*.txt','Please choose txt file with focusing depths or press cancel');
        dd = fullfile(path3, depths);
        if (dd ~= 0)
            D = (importdata(dd))'; % mm
        end
    end

    [x,y]=meshgrid(E,D);

% FIT
% In order to fit the plot with two-dimentional polynomial:
% APPS -> Curve Fitting -> Custom Equation
% Copy the polynomial formula below and assign the values X=x , Y=y, Z=z
% c0+c1*x+c2*y+c3*x.*y+c4*x.^2+c5*y.^2+c6*x.^2.*y.^2
% Copy the coefficients to the code below
% To draw the fitted graph: change 'fitted' parameter to 1. Run the code
else
    c0 = -20.63;  
    c1 = 0.3058;  
    c2 = 3.515;  
    c3 = -0.0227;  
    c4 = -0.0001316;  
    c5 = -0.6706;  
    c6 = 3.114e-08; 
    z = c0+c1*x+c2*y+c3*x.*y+c4*x.^2+c5*y.^2+c6*x.^2.*y.^2;
end

% CONTOUR
font = 11;
figure('Name',lengths)
hold on
contourf(x,y,z, 200, 'linestyle', 'none') % colorful contour
v = [0, 20, 40, 60, 80, 100 120];
contour(x,y,z, v, 'linecolor', 'k' , 'ShowText', 'on'); % contour lines

xlabel('Pulse energy \rm(nJ)','FontSize',font)
xlim([E_start E_end])
xticks([100 200 300 400 500 600 700 800])

ylabel('Focusing depth \rm(mm)','FontSize',font)
ylim([D_start D_end])
ytickformat('%.1f');

set(gca,'FontSize',font,'TickDir','out')
axis ij
   
% parula(default); jet; turbo; hsv; hot; cool; spring; summer; autumn; 
% winter; gray; bone; copper; pink; lines; colorcube; prism; flag; white
colormap(turbo);
xlabel(colorbar('Ticks',v), '\itL \rm(µm)','Rotation',0.0,'FontSize',font, 'Position', [1, -4, 0])
caxis([0 max_z]); % Change max_z to draw plots with the same z range

% SAVE
try
    fitted;
    saveas(gcf,extractBefore(lengths, ".")+"_fitted",'bmp');
catch
    saveas(gcf,extractBefore(lengths, "."),'bmp');
end