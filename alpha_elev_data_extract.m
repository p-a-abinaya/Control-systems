clear; clc;

files.geo = 'supergee.avl';
files.run = 'supergee.run';
files.mass = 'supergee.mass';

Alt = 25;  %m

% Compute Air Data
[T, a, P, rho] = atmosisa(Alt); 
% T - Texperature
% a - Speed of Sound
% P - Pressure(Ps)
% rho - Density

V = 10;     %Flight Velocity
Mach = V/a; % flight mach number 


Alpha = linspace(-5,15,10);  % Alphas
Elev = linspace(-10,10,10);  % Elevator

it = 0; % Number of Iterations

imax = numel(Elev);
jmax = numel(Alpha);
runtotal = imax*jmax;

for i = 1:imax %for each elevator condition
    for j = 1:jmax %for each alpha         

        basename = strcat('Case_e',num2str(Elev(i)),'a_',num2str(Alpha(j)));
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
       
       
       fprintf(fid, '%s\n', 'A');     % Modify case
       fprintf(fid, '%s\n', 'A');      % Modify case
       fprintf(fid, '%s\n', num2str(Alpha(j)));
       
       fprintf(fid, '%s\n', 'D3');     % Modify case
       fprintf(fid, '%s\n', 'D3');      % Modify case
       fprintf(fid, '%s\n', num2str(Elev(i))); 
       
       %run the case
       fprintf(fid, '%s\n', 'x');
       
       %save the files 
        file_save.st = ['Stab_Der_e' num2str(Elev(i)) 'a_' num2str(Alpha(j)) '.txt'];
        file_save.sb = ['Body_axis_e' num2str(Elev(i)) 'a_' num2str(Alpha(j)) '.txt'];
        file_save.ft = ['Tot_Force_e' num2str(Elev(i)) 'a_' num2str(Alpha(j)) '.txt'];
        file_save.fb = ['Body_Force_e' num2str(Elev(i)) 'a_' num2str(Alpha(j)) '.txt'];
        file_save.hm = ['Hinge_Mom_e' num2str(Elev(i)) 'a_' num2str(Alpha(j)) '.txt'];
        
        
       fprintf(fid, '%s\n', 'st');   % Save the st data
       fprintf(fid,  '%s\n', file_save.st);

       fprintf(fid, '%s\n', 'sb');    % Save the sb date
       fprintf(fid, '%s\n', file_save.sb);
       
       fprintf(fid, 'Quit\n'); % Exit MODE Menu 
       fprintf(fid, '\n');     % Quit Program
       fclose(fid);            % Close File
 
       % Execute Run
       [status,result] = dos(strcat('.\avl.exe < ',basename, '.run'));  % Run AVL
       runs = i*j;
       disp(['Iteration ...' num2str(it) '/' num2str(runtotal)]);
       it = it + 1;
       
    end
end
disp('Finished run');
