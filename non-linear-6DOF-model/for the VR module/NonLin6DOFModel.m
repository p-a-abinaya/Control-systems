function [XDOT] = NonLin6DOFModel (X,U)
% STATE AND CONTROL VECTORS 
x1 = X(1); %u
x2 = X(2); %v
x3 = X(3); %w
x4 = X(4); %p
x5 = X(5); %q
x6 = X(6); %r
x7 = X(7); %phi
x8 = X(8); %theta 
x9 = X(9); %psi

u1 = U(1);
u2 = U(2);
u3 = U(3);
u4 = U(4);
u5 = U(5);

% PARAMETERS
% all in SI units
m = 120000; % total mass

cbar = 6.6;     % mean aerodynamic chord
lt = 24.8;      % distance of AC of tail and body
S = 260;        % wing platform area
St = 64;        % tail platform area

Xcg = 0.23*cbar;        % x position of CoG in FM
Ycg = 0;                % y position of CoG in FM
Zcg = 0.10*cbar;        % z position of CoG in FM

Xac = 0.12*cbar;        % x position of AC in FM
Yac = 0;                % y position of AC in FM
Zac = 0;                % z position of AC in FM

% Engine constants [position of engines]
Xapt1 = 0;
Yapt1 = -7.94;
Zapt1 = -1.9;

Xapt2 = 0;
Yapt2 = 7.94;
Zapt2 = -1.9;

% Other constants
g = 9.81;       %acc due to gravity
despda = 0.25;  %change in downwash wrt alpha
alpha_L0 = -11.5*pi/180;        %zero lift AoA
n = 5.5;                        %slope of linear part of Cl vs AoA
a3 = -768.5;                    %coeff of a^3   
a2 = 609.2;                     %coeff of a^2 
a1 = -155.2;                    %coeff of a^1  
a0 = 15.212;                    %coeff of a^0
alpha_switch = 14.5*pi/180;     %alpha when lift goes from linear to non linear



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
% intermediate variables
% airspeed calc
Va = sqrt(x1^2 + x2^2 + x3^2);

% alpha beta calc
alpha = atan2(x3,x1);
beta = asin(x2/Va);
rho = 1.225;

%dynamic pressure 
Q = 0.5*rho*Va^2;

%also define vectors wbw_b and V_b
wbe_b = [x4; x5; x6];
V_b = [x1;x2;x3];

% aerodynamic force coeff
if alpha < alpha_switch
    CL_wb = n*(alpha - alpha_L0);
else
    CL_wb = a3*alpha^3 + a2*alpha^2 + a1*alpha + a0;
end

% calc CL_t 
epsilon = despda*(alpha - alpha_L0);
alpha_t = alpha - epsilon + u2 + 1.35*x5*lt/Va;
CL_t = 3.1*(St/S)*alpha_t;

%total lift 
CL = CL_wb + CL_t;

% total drag force neglecting tail 
CD = 0.13+0.07*(5.5*alpha + 0.654)^2;

% side force calc
CY = -1.6*beta + 0.24*u3;

% actual dimensional forces in stability axis
FA_s = [-CD*Q*S; CY*Q*S; -CL*Q*S];

% in body axis
C_bs = [cos(alpha) 0 -sin(alpha); 0 1 0; sin(alpha) 0 cos(alpha)];
FA_b = C_bs*FA_s;

% aero moment about AC
% calc moments in Fb 
eta11 = 1.4*beta;
eta21 = -0.59 - (3.1*(St*lt)/(S*cbar))*(alpha - epsilon);
eta31 = (1 - alpha*(180/(15*pi)))*beta;

eta = [eta11; eta21; eta31];
dCMdx = (cbar/Va)*[-11 0 5; 0 (-4.03*(St*lt^2)/(S*cbar^2)) 0; 1.7 0 -11.5];

dCMdu = [-0.6 0 0.22; 0 (3.1*(St*lt)/(S*cbar)) 0; 0 0 -0.63];

% CM = [Cl; Cm; Cn]
CMac_b = eta + dCMdx*wbe_b + dCMdu*[u1; u2; u3];

% aero moment about ac normalized to an aerodynamic moment

MAac_b = CMac_b*Q*S*cbar;

% aero moment about cg
rcg_b = [Xcg; Ycg; Zcg];
rac_b = [Xac; Yac; Zac];
MAcg_b = MAac_b + cross(FA_b, rcg_b - rac_b);

% engine force and moment 
% engine thrust calc

F1 = u4*m*g;
F2 = u5*m*g;

% assuming thrust to be aligned with Fb
FE1_b = [F1; 0; 0];
FE2_b = [F2; 0; 0];

FE_b = FE1_b +FE2_b;

% engine moment due to offset of engine thrust from cog
mew1 = [Xcg - Xapt1; Yapt1 - Ycg; Zcg - Zapt1];
mew2 = [Xcg - Xapt2; Yapt2 - Ycg; Zcg - Zapt2];

MEcg1_b = cross(mew1, FE1_b);
MEcg2_b = cross(mew2, FE2_b);

MEcg_b = MEcg1_b + MEcg2_b; 

% gravity effects
g_b = [-g*sin(x8); g*cos(x8)*sin(x7); g*cos(x8)*cos(x7)];
Fg_b = m*g_b; 

% state derivatives
% inertia matrix

Ib = m*[40.07 0 -2.0923; 0 64 0; -2.0923 0 99.92];
invIb = 1/m*[0.0249836 0 0.000523151; 0 0.015625 0; 0.000523151 0 0.010019];

% calc u, v, w rates
F_b = Fg_b + FE_b + FA_b;
x1to3dot = (1/m)*F_b - cross(wbe_b, V_b);

Mcg_b = MAcg_b + MEcg_b;
% pdot, qdot, rdot
x4to6dot = invIb*(Mcg_b - cross(wbe_b, Ib*wbe_b));

% phidot, thetadot, psidot
H_phi = [1 sin(x7)*tan(x8) cos(x7)*tan(x8); 0 cos(x7) -sin(x7); 0 sin(x7)/cos(x8) cos(x7)/cos(x8)];

x7to9dot = H_phi*wbe_b; 

XDOT = [x1to3dot; x4to6dot; x7to9dot];







