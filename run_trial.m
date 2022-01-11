%% This Script runs AVL and produces files for each flight condition
% The script runs AVL for @ number of different Alphas, Setas and CS
clear; clc;


% Specify AVL Filenames
files.geo = 'b737.avl';
files.run = 'b737.run';
files.mass = 'b737.mass';

 
CGrangeX = linspace(1.35,1.42,2);
CGrange = [CGrangeX; zeros(1,numel (CGrangeX)); 0.034*ones(1,numel (CGrangeX))]';
MassMatrix = linspace(71.994,80,2);

Alt = 25; %m

% Compute Air Data
[T, a, P, rho] = atmosisa(Alt); 
% T - Texperature
% a - Speed of Sound
% P - Pressure(Ps)
% rho - Density

V = 10;     %Flight Velocity
Mach = V/a; % flight mach number 

Alpha = linspace(-5,15,1);  % Alphas
Beta = linspace(-15,15,1);  % Betas
Elev = linspace(-10,10,1);  % Elevator
Rudd = linspace(-5,5,1);    % Rudder
it = 0; % Number of Iterations

imax = numel(CGrangeX);
jmax = numel(Alpha);
kmax = numel(Beta);

runtotal = jmax*kmax*imax;

for i = 1:imax      % For each CG
    for j = 1:jmax    % For each Alpha
        for k=1:kmax   % For each Beta

        filenames.sb = ['SB_AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.txt'];
        filenames.st = ['ST_AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.txt'];
        filenames.ft = ['AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.ft'];
        filenames.fn = ['AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.fn'];
        filenames.fs = ['AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.fs'];
        filenames.mode = ['AVL_xcg_' num2str(CGrange(i)) '_a' num2str(Alpha(j)) '_b' num2str(Beta(k)) '.ss'];
        
        basename = strcat('newruntrial_cg',num2str(i),'a',num2str(j),'b',num2str(k));
        fID = fopen(fileName, 'r');
        x = textscan(fID, '%s');
        s = 1;
        for temp = 1:100
            if strcmp(x{1,1}{temp,1}, 'CXtot') == 1 && s == 1
                CX_basename = x{1,1}{temp+2,1};
                CY_basename = x{1,1}{temp+2+9,1};
                CZ_basename = x{1,1}{temp+2+15,1};
        
                Cl_basename = x{1,1}{temp+2+3,1};       
                Cm_basename = x{1,1}{temp+2+12,1};
                Cn_basename = x{1,1}{temp+2+18,1};
        
                CL_basename = x{1,1}{temp+2+24,1};
                CD_basename = x{1,1}{temp+2+27,1};
        
                s = 0;
            end
    
        end
        fid = fopen(strcat(basename,'.run'), 'w');

        fprintf(fid, 'LOAD %s\n',files.geo);        % Load the AVL definition of the aircraft
        fprintf(fid, 'Mass %s\n',files.mass);       % Load the AVL Mass File
        fprintf(fid, '%s\n','MSET');                % Set Mass File for all Run Cases
        fprintf(fid, '%s\n','0');
        fprintf(fid, 'PLOP\n %s \n\n','G');         % Disable Graphics


fprintf (fid, '%s\n', 'OPER');      % Open the OPER menu
fprintf (fid, '%s\n', 'f');         % Load case file
fprintf (fid, '%s\n', files.run);   % Load case file

fprintf(fid, '%s\n', 'O');
fprintf(fid, '%s\n', 'P');
fprintf(fid, '%s\n\n', 'T,T,T,F');

% Set CG

fprintf(fid, '%s\n', 'M');
fprintf(fid, '%s\n', 'X');       % Change CG X
fprintf(fid, '%s\n\n', num2str(CGrange(i,1)));

% Set Mass

fprintf(fid, '%s\n', 'M');
fprintf(fid, '%s\n', 'M');       % Change Mass
fprintf(fid, '%s\n\n', num2str(MassMatrix(i)));

%Set Mech Number

fprintf(fid, '%s\n', 'M');      % Modify case
fprintf(fid, '%s\n', 'MN');     % Change mach no
fprintf(fid,  '%s\n\n', num2str(Mach));

% Set Density

fprintf(fid, '%s\n', 'C1');      % Modify case
fprintf(fid, '%s\n', 'D');      % Change density
fprintf(fid, '%s\n\n', num2str(rho));

%Set Velocity

fprintf(fid, '%s\n', 'C1');     % Modify case
fprintf(fid, '%s\n', 'V');      % Change velocity
fprintf(fid, '%s\n\n', num2str(V));
 
%Change Alpha

fprintf(fid, '%s\n', 'A');     % Modify case
fprintf(fid, '%s\n', 'A');      % Modify case
fprintf(fid, '%s\n', num2str(Alpha(j)));

%Change Beta

fprintf(fid, '%s\n', 'B');     % Modify case
fprintf(fid, '%s\n', 'B');     % Modify case
fprintf(fid, '%s\n', num2str(Beta(k)));

fprintf(fid, '%s\n\n', 'C1');  % Recompute

fprintf(fid, '%s\n', 'A');     % Modify case
fprintf(fid, '%s\n', 'A');     % Modify case
fprintf(fid, '%s\n', num2str(Alpha(j)));

fprintf(fid, '%s\n', 'x');     % Run the case


fprintf (fid, '%s\n', 'st');   % Save the st data
fprintf(fid,  '%s\n', filenames.st);

fprintf(fid, '%s\n', 'sb');    % Save the sb date
fprintf(fid, '%s\n', filenames.sb);

fprintf(fid, 'Quit\n'); % Exit MODE Menu

fprintf(fid, '\n');     % Quit Program
fclose(fid);            % Close File
 
% Execute Run

[status,result] = dos(strcat('.\avl.exe < ',basename, '.run'));  % Run AVL
runs = i*j*k;

disp(['Iteration ...' num2str(it) '/' num2str(runtotal)])
it = it +1;

        end
    end
end

disp('Finished run')