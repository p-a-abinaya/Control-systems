clear; clc;

files.geo = 'allegro.avl';
files.run = 'allegro.run';
files.mass = 'allegro.mass';

Alt = 25;  %m

% Compute Air Data
[T, a, P, rho] = atmosisa(Alt); 
% T - Texperature
% a - Speed of Sound
% P - Pressure(Ps)
% rho - Density

V = 10;     %Flight Velocity
Mach = V/a; % flight mach number 


beta = linspace(-50,50,21);  % beta
rudder = linspace(-26,26,14);  % rudder
aileron = linspace(-30, 15, 10); % aileron

it = 0; % Number of Iterations

imax = numel(aileron);
jmax = numel(rudder);
kmax = numel(beta);
runtotal = imax*jmax*kmax;

CX = zeros(kmax,jmax,imax); 
CY = zeros(kmax,jmax,imax); 
CZ = zeros(kmax,jmax,imax); 

Cl = zeros(kmax,jmax,imax); 
Cm = zeros(kmax,jmax,imax); 
Cn = zeros(kmax,jmax,imax); 

CL = zeros(kmax,jmax,imax); 
CD = zeros(kmax,jmax,imax); 

for i = 1:imax %for each aileron position
    for j = 1:jmax %for each rudder angle 
        for k = 1: kmax %for each beta

        basename = strcat('Case_a',num2str(aileron(i)),'_r',num2str(rudder(j)), '_b', num2str(beta(k)));
        fid = fopen(strcat(basename,'.run'), 'w');
        
        fprintf(fid, 'LOAD %s\n',files.geo);        % Load the AVL definition of the aircraft
        fprintf(fid, 'Mass %s\n',files.mass);       % Load the AVL Mass File
        fprintf(fid, '%s\n','MSET');                % Set Mass File for all Run Cases
        fprintf(fid, '%s\n','0');
        fprintf(fid, 'PLOP\n %s \n\n','G');      
        
        fprintf (fid, '%s\n', 'OPER');      % Open the OPER menu
        fprintf (fid, '%s\n', 'f');         % Load case file
        fprintf (fid, '%s\n', files.run);   % Load case file
        fprintf(fid, '%s\n', 'O');
        fprintf(fid, '%s\n', 'P');
        fprintf(fid, '%s\n\n', 'T,T,T,F');
        
        %set Mach number
        fprintf(fid, '%s\n', 'M');      % Modify case
        fprintf(fid, '%s\n', 'MN');     % Change mach no
        fprintf(fid,  '%s\n', num2str(Mach));
        
        %set Velocity
        fprintf(fid, '%s\n', 'V');     % Change Velocity
        fprintf(fid,  '%s\n', num2str(V));
        
       %set Density
       fprintf(fid, '%s\n', 'D');     % Change Density
       fprintf(fid,  '%s\n\n', num2str(rho));
       
       
       fprintf(fid, '%s\n', 'B');     % Modify case
       fprintf(fid, '%s\n', 'B');      % Modify case
       fprintf(fid, '%s\n', num2str(beta(k)));
       
       fprintf(fid, '%s\n', 'D5');     % Modify case
       fprintf(fid, '%s\n', 'D5');      % Modify case
       fprintf(fid, '%s\n', num2str(rudder(j))); 
       
       fprintf(fid, '%s\n', 'D3');     % Modify case
       fprintf(fid, '%s\n', 'D3');      % Modify case
       fprintf(fid, '%s\n', num2str(aileron(i))); 
       
       %run the case
       fprintf(fid, '%s\n', 'x');
       
       %save the files 
       file_save.st = ['Stab_Der_ail' num2str(aileron(i)) '_r' num2str(rudder(j)) '_b' num2str(beta(k)) '.txt'];
       file_save.sb = ['Body_axis_ail' num2str(aileron(i)) '_r' num2str(rudder(j)) '_b' num2str(beta(k)) '.txt'];
       file_save.ft = ['Tot_Force_ail' num2str(aileron(i)) '_r' num2str(rudder(j)) '_b' num2str(beta(k)) '.txt'];
       file_save.fb = ['Body_Force_ail' num2str(aileron(i)) '_r' num2str(rudder(j)) '_b' num2str(beta(k)) '.txt'];
       file_save.hm = ['Hinge_Mom_ail' num2str(aileron(i)) '_r' num2str(rudder(j)) '_b' num2str(beta(k)) '.txt'];
        
        
       fprintf(fid, '%s\n', 'st');   % Save the st data
       fprintf(fid,  '%s\n', file_save.st);

       fprintf(fid, '%s\n', 'sb');    % Save the sb date
       fprintf(fid, '%s\n', file_save.sb);
       
       fprintf(fid, 'Quit\n'); % Exit MODE Menu 
       fprintf(fid, '\n');     % Quit Program
       fclose(fid);            % Close File
 
       % Execute Run
           [status,result] = dos(strcat('.\avl.exe < ',basename, '.run'));  % Run AVL
           runs = i*j*k;
           clc;
           disp(['Iteration ...' num2str(it) '/' num2str(runtotal)]);
           it = it + 1;
           
        f = fopen(file_save.st, 'r');
        x = textscan(f, '%s');
        for r = 70:80
            if strcmp(x{1,1}{r,1}, 'CXtot') == 1
                       CX(k,j, i) = str2double(x{1,1}{r+2,1});
                       CY(k,j,i) = str2double(x{1,1}{r+2+9,1});
                       CZ(k,j,i) = str2double(x{1,1}{r+2+15,1});

                       Cl(k,j,i) = str2double(x{1,1}{r+2+3,1});            
                       Cm(k,j,i) = str2double(x{1,1}{r+2+12,1});
                       Cn(k,j,i) = str2double(x{1,1}{r+2+18,1});

                       CL(k,j,i) = str2double(x{1,1}{r+2+24,1});
                       CD(k,j,i) = str2double(x{1,1}{r+2+27,1});
            end

        end
        fclose(f);
        end 
    end
end
clc;
disp(['Iteration ...' num2str(it) '/' num2str(runtotal)]);
clc;
disp('Finished run');
