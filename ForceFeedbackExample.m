clear all; close all; clc
%%Force Feedback example
DOF ROBOT definition
%Link1 dynamic parameters
l=0.4;
M=1;
b=0.2;
r1=[0 0 0];
I1= [0 0 0;
     0 1/3*M*l^2 0;
     0 0 0];
Jm1   =  0.0002;
Bm1   =  b;

Tc1 = [0 0];
G1 = -0;
qlim1 = [-2*pi 2*pi];

L(1) = Link([0 0 l -pi/2 0 M r1 I1(1,1) I1(2,2) I1(3,3) I1(1,2) I1(2,3) I1(1,3) Jm1 G1 Bm1 Tc1],'standard');

one_link = SerialLink(L,'name','one link robot');
qi = 0;
open('PositionInnerLoop.slx')
open('VelocityInnerLoop.slx')