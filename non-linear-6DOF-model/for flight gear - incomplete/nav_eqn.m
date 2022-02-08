function [V_earth] = nav_eqn(UVW, Eulerangles)

% navigation equations
p = UVW(1);
q = UVW(2);
r = UVW(3);
V_b = [p; q; r];

phi = Eulerangles(1);
theta = Eulerangles(2);
psi = Eulerangles(3);

C1v = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
C21 = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
Cb2 = [1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];

Cbv = Cb2*C21*C1v;
Cvb = Cbv';

[V_earth] = Cvb*V_b;



    