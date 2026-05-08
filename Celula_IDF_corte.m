%% =========================================================================
%  ROBOTIC CELL WITH 2 KUKA KR15 ROBOTS - ALTERNATING CUTS (SEQUENTIAL)
%  =========================================================================
%  Based on the theory of Josep Tornero i Montserrat
%  Maintainer: gn6ks
%  =========================================================================

%% --- LOAD LIBRARIES --------------------------------------------------
addpath(genpath('9.9\rvctools'));
addpath(genpath('9.9\rvctools\robot\@SerialLink'));
addpath(genpath('vstoolbox_R13'));

clear all; close all; clc;

%% --- GLOBAL PARAMETERS -------------------------------------------------
% W: visualization workspace [xmin xmax ymin ymax zmin zmax]
% q_park: rest configuration for each robot (1st coord = prismatic rail)
T0 = eye(4);
W  = [-3, 3, -4, 4, -1, 3];

q_park_A = [-1.5,  0,  0, -pi/2,  0,  0,  0];
q_park_B = [ 1.5,  0,  0, -pi/2,  0,  0,  0];

%% --- KR15 LINKS ------------------------------------------------------
% Prismatic link 1 (rail), links 2-7 revolute. Standard DH parameters.
function L = crea_eslabones_KR15()
    L(1) = Link([0 0 0 pi/2 1], 'standard');
    L(1).qlim = [-3 3];
    L(2) = Link([0  0.675  0.3  -pi/2  0], 'standard');
    L(3) = Link([0  0      0.65  0      0], 'standard');
    L(4) = Link([0  0      0.15 -pi/2  0], 'standard');
    L(5) = Link([0  0.60   0    pi/2   0], 'standard');
    L(6) = Link([0  0      0    pi/2   0], 'standard');
    L(7) = Link([0 -0.14   0    pi     0], 'standard');
end

%% --- ROBOT A (odd cuts, rail Y = -1) --------------------------------
La    = crea_eslabones_KR15();
kukaA = SerialLink(La);
kukaA.base    = transl(-1, -1, -0.305) * trotx(-pi/2);
kukaA.model3d = 'KUKA\KR15_robot1';
kukaA.name    = 'KR15_A';

%% --- ROBOT B (even cuts,  rail Y = +1) --------------------------------
Lb    = crea_eslabones_KR15();
kukaB = SerialLink(Lb);
kukaB.base    = transl(-1, +1, -0.305) * trotx(-pi/2);
kukaB.model3d = 'KUKA\KR15_robot1';
kukaB.name    = 'KR15_B';

%% --- ARTIFICIAL ROBOT FOR IK CALCULATION --------------------------------
Lc(1) = Link([0 -0.305 -1 -pi/2], 'standard');
Lc(2) = Link([0  0      0  pi/2  1], 'standard');
Lc(3) = Link([0  0.675  0.3 -pi/2 0], 'standard');
Lc(4) = Link([0  0      0.65  0   0], 'standard');
Lc(5) = Link([0  0      0.15 -pi/2 0], 'standard');
Lc(6) = Link([0  0.60   0    pi/2  0], 'standard');
Lc(7) = Link([0  0      0    pi/2  0], 'standard');
Lc(8) = Link([0 -0.14   0    pi    0], 'standard');

ckuka         = SerialLink(Lc, 'name', 'Cell');
ckuka.model3d = 'KUKA\KR15_2_2';
cqi     = [0,  0,  0,  -pi/2,  0,  0,  0,  0];
IK_seed = [0, -0.5, 0, -1, 0.5, 0, 0.5, 0];

%% --- TABLE -----------------------------------------------------------
M               = Link([0 0 0 0], 'standard');
MesaRot         = SerialLink(M);
MesaRot.model3d = 'MESA';
MesaRot.name    = 'TABLE';

%% --- INITIAL WORKPIECE -----------------------------------------------
OPoints = 0.3 * [0 0 0; 1 0 0; 1 1 0; 0 1 0;
                  0 0 1; 1 0 1; 1 1 1; 0 1 1]';
p = polyhedra(OPoints, [1 2 3 4; 1 2 6 5; 2 3 7 6;
                         5 6 7 8; 3 4 8 7; 1 4 8 5]);
T0obj_inicial = T0 * transl(-0.15, -0.15, 0);

%% =========================================================================
%  HELPER FUNCTION: mundo_a_ckuka
%  Converts a transformation matrix from world coordinates to the ckuka local system,
%  compensating for the Y offset of the robot executing the cut.
% =========================================================================
function T_local = mundo_a_ckuka(T_mundo, railY)
    T_local = T_mundo;
    T_local(2,4) = T_mundo(2,4) - railY;
end

%% =========================================================================
%  FUNCTION: calcula_corte
%  T_ini and T_fin must already be in the ckuka local system.
%  Returns a 7 DOF trajectory for the KR15 (cols 2:8).
% =========================================================================
function [tray_KR15, vel_q] = calcula_corte(ckuka, cqi, IK_seed, T_ini, T_fin)

    cqf_ini = ckuka.ikine(T_ini, IK_seed, 'pinv');
    cqf_fin = ckuka.ikine(T_fin, IK_seed, 'pinv');

    tray_aprox  = jtraj(cqi,     cqf_ini, 50);
    tray_retira = jtraj(cqf_fin, cqi,     50);

    % ctraj: linear Cartesian interpolation. IK solved point by point.
    cTray_corte = ctraj(T_ini, T_fin, 50);
    tray_corte  = zeros(50, length(cqi));
    for i = 1:50
        tray_corte(i,:) = ckuka.ikine(cTray_corte(:,:,i), IK_seed, 'pinv');
    end

    tray_full = cat(1, tray_aprox, tray_corte, tray_retira);
    tray_KR15 = tray_full(:, 2:8);   % col 1 = rail of ckuka, discarded

    % Joint velocities (differential Jacobian)
    vel_end = [0, 0.005, 0, 0, 0, 0]';   % 5 mm/s in Cartesian Y
    vel_q   = zeros(50, length(cqi));
    for i = 1:50
        J = ckuka.jacob0(tray_corte(i,:));
        vel_q(i,:) = pinv(J) * vel_end;
    end
end

%% =========================================================================
%  FUNCTION: plot_velocidades
% =========================================================================
function plot_velocidades(vel_q, num_corte, fig_vel)
    figure(fig_vel);
    subplot(2,1,1);
    plot(vel_q(:,2), 'LineWidth', 1.5);
    ylabel('m/s'); grid on;
    legend('Vel Q1 (prismatic)');
    title(sprintf('JOINT VELOCITIES - CUT %d', num_corte));

    subplot(2,1,2);
    hold on; grid on;
    colores = {'b','r','g','m','c','k'};
    nombres = {'Vel Q0','Vel Q2','Vel Q3','Vel Q4','Vel Q5','Vel Q6','Vel Q7'};
    plot(vel_q(:,1), 'Color', colores{1}, 'LineWidth', 1.5);
    for k = 3:8
        plot(vel_q(:,k), 'Color', colores{mod(k,6)+1}, 'LineWidth', 1.5);
    end
    legend(nombres, 'Location', 'southeast');
    ylabel('rad/s');
end

%% =========================================================================
%  PRE-CALCULATION CUT 1  Robot A (rail Y = -1)
%  Workpiece points are converted to the ckuka system compensating Y=-1
% =========================================================================

% Target points in WORLD coordinates
T11_mundo = T0obj_inicial * transl(0.15,  0.40, 0.3) * trotx(pi);
T13_mundo = T0obj_inicial * transl(0.15, -0.10, 0.3) * trotx(pi);

% Convert to ckuka local system (compensate rail Y=-1)
T11_A = mundo_a_ckuka(T11_mundo, -1);
T13_A = mundo_a_ckuka(T13_mundo, -1);

fprintf('Calculating trajectory Cut 1 (Robot A)...\n');
[tray_kukaA_c1, vel_c1] = calcula_corte(ckuka, cqi, IK_seed, T11_A, T13_A);

%% =========================================================================
%  PRE-CALCULATION CUT 2  Robot B (rail Y = +1)
%  Workpiece points are converted to the ckuka system compensating Y=+1
% =========================================================================

% Target points in WORLD coordinates
T21_mundo = T0obj_inicial * transl(0.00, -0.10, 0.3) * trotx(pi);
T23_mundo = T0obj_inicial * transl(0.30,  0.30, 0.3) * trotx(pi);

% Convert to ckuka local system (compensate rail Y=+1)
T21_B = mundo_a_ckuka(T21_mundo, +1);
T23_B = mundo_a_ckuka(T23_mundo, +1);

fprintf('Calculating trajectory Cut 2 (Robot B)...\n');
[tray_kukaB_c2, vel_c2] = calcula_corte(ckuka, cqi, IK_seed, T21_B, T23_B);

fprintf('Calculation complete. Starting animation...\n\n');

%% =========================================================================
%  ANIMATION FIGURE  single initialization
% =========================================================================
figure('units','normalized','outerposition',[0 0 1 1]);
title('INITIAL STATE  2 KR15 ROBOTS');

% 1. Render robots and table
kukaA.plot3d_Pastor_Tamarit(q_park_A, 'workspace', W);
kukaB.plot3d_Pastor_Tamarit(q_park_B, 'workspace', W);

% 2. Capture patches before/after drawing the workpiece to identify
%    only its handles and be able to delete it without affecting the 3D models of the robots.
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);

MesaRot.plot3d_Pastor_Tamarit(cqi(1), 'workspace', W);

% 3.  LOCK HOLD BEFORE CREATING SPHERES (prevents accidental deletion)
hold(gca, 'on');
[h_esf_A, esf_data] = init_esferas_visuales();
[h_esf_B, ~]        = init_esferas_visuales();

% 4. Position spheres at parking configuration
actualizar_esferas_frame(kukaA, q_park_A, esf_data, h_esf_A);
actualizar_esferas_frame(kukaB, q_park_B, esf_data, h_esf_B);

drawnow; % Force full rendering before animation
pause(1.5);

% Save workpiece handles to delete ONLY it when updating.
% polyhedra/plot does not return handles, so we capture them by comparing
% existing patches before and after drawing the workpiece.
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);

MesaRot.plot3d_Pastor_Tamarit(cqi(1), 'workspace', W);
pause(1.5);

%% =========================================================================
%  CUT 1  Robot A cuts, Robot B in parking
% =========================================================================
title('CUT 1  Robot A (sequence)');
animate_dual(kukaA, tray_kukaA_c1, kukaB, q_park_B, h_esf_A, esf_data, h_esf_B, esf_data);

% Velocities Cut 1
plot_velocidades(vel_c1, 1, 2);

% Update workpiece: delete old geometry and plot only the remaining piece
% so the cut-off volume disappears from the visualization.
OPoints = 0.3 * [0 0 0; 0.2/0.3 0 0; 0.2/0.3 1 0; 0 1 0;
                  0 0 1; 0.2/0.3 0 1; 0.2/0.3 1 1; 0 1 1]';
p = polyhedra(OPoints, [1 2 3 4; 1 2 6 5; 2 3 7 6;
                          5 6 7 8; 3 4 8 7; 1 4 8 5]);
figure(1);
title('WORKPIECE UPDATED  preparing Cut 2...');
delete(h_tocho);
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);
drawnow;
pause(0.5);

%% =========================================================================
%  CUT 2  Robot B cuts, Robot A in parking
% =========================================================================
figure(1);
title('CUT 2  Robot B (sequence)');
animate_dual(kukaB, tray_kukaB_c2, kukaA, q_park_A, h_esf_B, esf_data, h_esf_A, esf_data);

% Velocities Cut 2
plot_velocidades(vel_c2, 2, 3);

% Final workpiece: remove previous patch and display the final remaining geometry
OPoints = 0.3 * [0 0 0; 0.1/0.3 0 0; 0.2/0.3 1 0; 0 1 0;
                  0 0 1; 0.1/0.3 0 1; 0.2/0.3 1 1; 0 1 1;
                  0.2/0.3 0.2/0.3 0; 0.2/0.3 0.2/0.3 1]';
p = polyhedra(OPoints, [1 2 3 4; 2 2 9 3; 1 2 6 5; 2 3 7 6;
                          5 6 7 8; 6 6 10 7; 9 3 7 10; 3 4 8 7;
                          1 4 8 5; 2 9 10 6]);
figure(1);
title('SEQUENCE COMPLETED  both robots in rest position');
delete(h_tocho);
plot(p, ht(T0obj_inicial), 'y');
drawnow;

msgbox('Program Finished  2 KR15 robots completed all cuts.');