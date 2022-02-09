% constant init
clear
clc
close all


x0 = [85; 0; 0; 0; 0; 0; 0; 0.1; 0];


%  control limits/saturation
%aileron limits
u1min = -25*pi/180;
u1max = 25*pi/180;

%tail limits
u2min = -25*pi/180;
u2max = 25*pi/180;

%rudder limits
u3min = -25*pi/180;
u3max = 25*pi/180;

%engine 1 limits
u4min = -5*pi/180;
u4max = 75*pi/180;

%engine 2 limits
u5min = -5*pi/180;
u5max = 75*pi/180;

run('non_lin_6_DOF.slx')