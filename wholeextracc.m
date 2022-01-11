clear; 
clc;

% Specify AVL Filenames
files.geo = 'b737.avl';
files.run = 'b737.run';
files.mass = 'b737.mass';

Altft = 0; 
m2ft = 3.28084;       % multiply factor to get from = to feet
Alt = Altft*(1/m2ft); %m

% Compute Air Data
[T, a, P, rho] = atmosisa(Alt); 
% T - Texperature
% a - Speed of Sound
% P - Pressure(Ps)
% rho - Density

V = 45;     %Flight Velocity
Mach = V/a; % flight mach number 

% alpha and elevator values
alpha = linspace(-3, 10, 14);
elevator = linspace(-5, 5, 3);

n = 0; % Number of Iterations

imax = numel(elevator) ;
jmax = numel(alpha);

CX = zeros([jmax imax]);
CY = zeros([jmax imax]);
CZ = zeros([jmax imax]);

Cl = zeros([jmax imax]);
Cm = zeros([jmax imax]);
Cn = zeros([jmax imax]);

CL = zeros([jmax imax]);
CD = zeros([jmax imax]);

totalruns = jmax*imax;

for i = 1:imax      % For each CG
    for j = 1:jmax    % For each Alpha
       
        filenames.sb = ['SB_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];
        filenames.st = ['ST_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];
        filenames.ft = ['FT_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];
        filenames.fn = ['FN_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];
        filenames.fs = ['FS_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];
        filenames.mode = ['MODE_Long_elevator' num2str(elevator(i)) '_alpha' num2str(alpha(j)) '.txt'];

        basename = strcat('long_run_elevator',num2str(i),'alpha',num2str(j));
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

        %Modify Mach Number

        fprintf(fid, '%s\n', 'M');      % Modify case
        fprintf(fid, '%s\n', 'MN');     % Change mach no
        fprintf(fid,  '%s\n\n', num2str(Mach));

        % Modify Density

        fprintf(fid, '%s\n', 'C1');      % Modify case
        fprintf(fid, '%s\n', 'D');      % Change density
        fprintf(fid, '%s\n\n', num2str(rho));

        %Change Velocity

        fprintf(fid, '%s\n', 'C1');     % Modify case
        fprintf(fid, '%s\n', 'V');      % Change velocity
        fprintf(fid, '%s\n\n', num2str(V));

        %Change Alpha

        fprintf(fid, '%s\n', 'A');     % Modify case
        fprintf(fid, '%s\n', 'A');      % Modify case
        fprintf(fid, '%s\n', num2str(alpha(j)));

        %Change elevaator

        fprintf(fid, '%s\n', 'D3');     % Modify case
        fprintf(fid, '%s\n', 'D3');     % Modify case
        fprintf(fid, '%s\n', num2str(elevator(i)));

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
        runs = i*j;
        
        %getting the values 
         fextrac = fopen(filenames.st, 'r');
         x = textscan(fextrac, '%s');
         s = 1;
         for temp = 1:100
             if strcmp(x{1,1}{temp,1}, 'CXtot') == 1 && s == 1
                 CX(j,i) = x{1,1}{temp+2,1};
                 CY(j,i) = x{1,1}{temp+2+9,1};
                 CZ(j,i) = x{1,1}{temp+2+15,1};
 
                 Cl(j,i) = x{1,1}{temp+2+3,1};       
                 Cm(j,i) = x{1,1}{temp+2+12,1};
                 Cn(j,i) = x{1,1}{temp+2+18,1};
 
                 CL(j,i) = x{1,1}{temp+2+24,1};
                 CD(j,i) = x{1,1}{temp+2+27,1};
 
                 s = 0;
             end
 
         end
         fclose(fextrac);
         

        disp(['Iteration ...' num2str(n) '/' num2str(totalruns)])
        n = n +1;
        
    end
end

disp('Finished run')