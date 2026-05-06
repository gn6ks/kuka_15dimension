%% LINK Robot manipulator Link class
%
% A Link object holds all information related to a robot link such as
% kinematics parameters, rigid-body inertial parameters, motor and
% transmission parameters.
%
% Methods::
%  A             link transform matrix
%  RP            joint type: 'R' or 'P'
%  friction      friction force
%  nofriction    Link object with friction parameters set to zero
%  dyn           display link dynamic parameters
%  islimit       test if joint exceeds soft limit
%  isrevolute    test if joint is revolute
%  isprismatic   test if joint is prismatic
%  display       print the link parameters in human readable form
%  char          convert to string
%
% Properties (read/write)::
%
%  theta    kinematic: joint angle
%  d        kinematic: link offset
%  a        kinematic: link length
%  alpha    kinematic: link twist
%  sigma    kinematic: 0 if revolute, 1 if prismatic
%  mdh      kinematic: 0 if standard D&H, else 1
%  offset   kinematic: joint variable offset
%  qlim     kinematic: joint variable limits [min max]
%-
%  m        dynamic: link mass
%  r        dynamic: link COG wrt link coordinate frame 3x1
%  I        dynamic: link inertia matrix, symmetric 3x3, about link COG.
%  B        dynamic: link viscous friction (motor referred)
%  Tc       dynamic: link Coulomb friction
%-
%  G        actuator: gear ratio
%  Jm       actuator: motor inertia (motor referred)

%% TABLA DE DENAVIT-HARTENBERG PARA ROBOT PRR
% ARTICULACIÓN   theta        d               a   alfa
%      1           0         despl_1          0     0
%      2         theta_1       0            750     0
%      3         theta_2       0            750     0

espacio_x = 2;
espacio_y = 2;
espacio_z = 3;

% Define ejes de coordenadas
W=[-espacio_x espacio_x -espacio_y espacio_y 0 espacio_z];
%Link([theta d a alfa Prismático(1)/Revolución(0)])
L(1) = Link([0 0 0 0 1],'standard');
L(1).I = [0.13, 0.524, 0.539];  % Momento de inercia
L(1).r = [-0.3638, 0.006, 0.2275];
L(1).m = 17.4;       % Masa
L(1).Jm = 200e-6;    % Inercia del motor
L(1).G = 107.815;
L(1).B = 0.817e-3;
L(1).Tc = [0.126 -0.071];
L(1).qlim=[0 1]; %De 0 a 1 metro

L(2) = Link([0 0 0.75 0 0],'standard');
L(2).I = [0.066, 0.086, 0.0125];
L(2).r = [-0.0203, -0.0141, 0.070];
L(2).m = 4.8;
L(2).Jm = 200e-6;
L(2).G = -53.7063;
L(2).B = 1.38e-3;
L(2).Tc = [0.132, -0.105];
L(2).qlim=[-pi/2 pi/2]; %De -90º a 90º

L(3) = Link([0 0 0.75 0 0],'standard');
L(3).I = [1.8e-3, 1.3e-3, 1.8e-3];
L(3).r = [0, 0.019, 0];
L(3).m =  4.8;
L(3).Jm = 200e-6;
L(3).G = 76.0364;
L(3).B = 71.2e-6;
L(3).Tc = [11.2e-3, -16.9e-3];
L(3).qlim=[-pi/2 pi/2]; %De -90º a 90º

Qini=[1 0 0]; %Valores de las articulaciones
Qfin=[0.4 pi/2 -pi/2];

gravedad=[0 0 9.81];

RobotPRR=SerialLink(L,'name','PRR');