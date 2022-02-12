function [XDOT] = NonLin6DOFModel (X,U)
load('workspacedat.mat');
% ------------------- STATE AND CONTROL VECTORS ---------------------------
x1 = X(1); % u
x2 = X(2); % v
x3 = X(3); % w
x4 = X(4); % p
x5 = X(5); % q
x6 = X(6); % r
x7 = X(7); % phi
x8 = X(8); % theta 
x9 = X(9); % psi

u1 = U(1); % aileron
u2 = U(2); % elevator
u3 = U(3); % rudder
u4 = U(4); % throttle 1
u5 = U(5); % throttle 2

% ------------------------ PARAMETERS --------------------------------------
% all in SI units
m = 64636.912725; % total mass

cbar = 3.415284;     % mean aerodynamic chord
% lt = 14.84376;      % distance of AC of tail and body
S = 91.045;        % wing platform area
% St = 34.6393;     % tail platform area

Xcg = 0.25*cbar;        % x position of CoG in FM
Ycg = 0;                % y position of CoG in FM
Zcg = 0;                % z position of CoG in FM 
rcg_b = [Xcg; Ycg; Zcg];

Xac = 0.12*cbar;        % x position of AC in FM
Yac = 0;                % y position of AC in FM
Zac = 0;                % z position of AC in FM
rac_b = [Xac; Yac; Zac];

% Engine constants [position of engines]
Xapt1 = 0;
Yapt1 = -4.8838;
Zapt1 = -0.9;

Xapt2 = 0;
Yapt2 = 4.8838;
Zapt2 = -0.9;

% Other constants
g = 9.81;       %acc due to gravity

% ------------------------- SATURATION LIMITS ---------------------------------- 
% if u1>u1max
%     u1 = u1max;
% elseif u1<u1min
%         u1 = u1min;
% end
% 
% if u2>u2max
%     u2 = u2max;
% elseif u2<u2min
%         u2 = u2min;
% end
% 
% 
% if u3>u3max
%     u3 = u3max;
% elseif u3<u3min
%         u3 = u3min;
% end
% 
% 
% if u4>u4max
%     u4 = u4max;
% elseif u4<u4min
%         u4 = u4min;
% end
% 
% if u5>u5max
%     u5 = u5max;
% elseif u5<u5min
%         u5 = u5min;
% end

% ------------------------------ INTERMEDIATE VARIABLES -------------------------
% Airspeed Calculation
Va = sqrt(x1^2 + x2^2 + x3^2);

% Alpha and Beta calculation
alpha = atan2(x3,x1);
beta = asin(x2/Va);
% Assuming air had a constant density
rho = 1.225;

%Computing dynamic pressure 
Q = 0.5*rho*Va^2;

% Define vectors wbw_b and V_b
wbe_b = [x4; x5; x6];
V_b = [x1;x2;x3];

% -------------------------- AERODYNAMIC FORCE COEFFICIENTS -----------------------
% Total lift 
CL_q = get_CLf(Alpha, Elev, CL, alpha, u2);

% Total drag force
CD_q = get_CD(Alpha, Elev, CD, alpha, u2);

% Side force calc
CY_q = get_CY(Beta, Rudder, Aileron, CY, beta, u3, u1);

% Actual dimensional forces in stability axis
FA_s = [-CD_q*Q*S; CY_q*Q*S; -CL_q*Q*S];

% in body axis
C_bs = [cos(alpha) 0 -sin(alpha); 0 1 0; sin(alpha) 0 cos(alpha)];
FA_b = C_bs*FA_s;

% ----------------------- AERODYNAMIC MOMENT ABOUT AC -----------------------------
Cl_q = get_Cl(Beta, Rudder, Aileron, Cl, beta, u3, u1);
Cm_q = get_Cm(Alpha, Elev, Cm, alpha, u2);
Cn_q = get_Cn(Beta, Rudder, Aileron, Cn, beta, u3, u1);

% CM = [Cl; Cm; Cn]
CMac_b = [Cl_q; Cm_q; Cn_q];

% aero moment about ac normalized to an aerodynamic moment
MAac_b = CMac_b*Q*S*cbar;

% aero moment about cg
MAcg_b = MAac_b + cross(FA_b, rcg_b - rac_b);

% ---------------------------- ENGINE FORCE AND THRUST ----------------------------
% Engine thrust calculation

F1 = u4*m*g;
F2 = u5*m*g;

% assuming thrust to be aligned with Fb
FE1_b = [F1; 0; 0];
FE2_b = [F2; 0; 0];

FE_b = FE1_b +FE2_b;

% Engine moment due to offset of engine thrust from cog
mew1 = [Xcg - Xapt1; Yapt1 - Ycg; Zcg - Zapt1];
mew2 = [Xcg - Xapt2; Yapt2 - Ycg; Zcg - Zapt2];

MEcg1_b = cross(mew1, FE1_b);
MEcg2_b = cross(mew2, FE2_b);

MEcg_b = MEcg1_b + MEcg2_b; 

% Gravity effects
g_b = [-g*sin(x8); g*cos(x8)*sin(x7); g*cos(x8)*cos(x7)];
Fg_b = m*g_b; 

% ------------------------------- STATE DERIVATIVES ------------------------------
% Inertia matrix

Ib = [0.7067E+06 -0.000 0.2699E+05; -0.000 0.2708E+07 -0.000; 0.2699E+05 -0.000 0.3308E+07];
invIb = 1.0e-05*[0.1415 0 -0.0012; 0 0.0369 0; -0.0012 0 0.0302];
% Calculating u, v, w rates
F_b = Fg_b + FE_b + FA_b;
x1to3dot = (1/m)*F_b - cross(wbe_b, V_b);

Mcg_b = MAcg_b + MEcg_b;
% pdot, qdot, rdot
x4to6dot = invIb*(Mcg_b - cross(wbe_b, Ib*wbe_b));

% phidot, thetadot, psidot
H_phi = [1 sin(x7)*tan(x8) cos(x7)*tan(x8); 0 cos(x7) -sin(x7); 0 sin(x7)/cos(x8) cos(x7)/cos(x8)];

x7to9dot = H_phi*wbe_b; 

XDOT = [x1to3dot; x4to6dot; x7to9dot];