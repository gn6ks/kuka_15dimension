%% =========================================================================
%  CÉLULA ROBOTIZADA CON 2 ROBOTS KUKA KR15 - CORTES ALTERNOS (SECUENCIAL)
%  =========================================================================
%  Basado en el trabajo de Jose Manuel Pastor Alcaraz y Fernando Tamarit Peris
%
%  CORRECCIÓN DEFINITIVA DE IK:
%
%  ckuka es un robot de cálculo con base = eye(4) (origen del mundo).
%  Su primer eslabón Lc(1) ya contiene el offset de altura (d=-0.305) y el
%  offset X=-1 del rail mediante sus parámetros DH  NO se debe modificar
%  su base nunca.
%
%  El error de IK anterior se producía porque:
%    · Robot A está en Y=-1, Robot B en Y=+1.
%    · ckuka está centrado en Y=0.
%    · Los puntos objetivo (T_ini, T_fin) se calculaban igual para ambos
%      robots  desde Y=0 el punto del corte 2 puede quedar fuera de rango.
%
%  SOLUCIÓN: los puntos T_ini/T_fin se expresan en el sistema local de ckuka
%  transformando el offset Y de cada robot. Para Robot A (Y=-1) el tocho
%  está en Y_local = Y_mundo - (-1) = Y_mundo + 1. Para Robot B (Y=+1) el
%  tocho está en Y_local = Y_mundo - (+1) = Y_mundo - 1.
%  Esto se consigue premultiplicando por inv(base_robot) · T_mundo.
%
%  ACTUALIZACIÓN SEGURA DEL TOCHO:
%  Se guarda h_tocho al crearlo y se hace delete(h_tocho) para borrarlo.
%  Nunca se usa findobj(gca,'Type','patch') que borraba los robots.
% =========================================================================

%% --- CARGA DE LIBRERÍAS --------------------------------------------------
addpath(genpath('9.9\rvctools'));
addpath(genpath('9.9\rvctools\robot\@SerialLink'));
addpath(genpath('vstoolbox_R13'));

clear all; close all; clc;

%% --- PARÁMETROS GLOBALES -------------------------------------------------
T0 = eye(4);
W  = [-3, 3, -4, 4, -1, 3];

q_park_A = [-1.5,  0,  0, -pi/2,  0,  0,  0];
q_park_B = [ 1.5,  0,  0, -pi/2,  0,  0,  0];

%% --- ESLABONES KR15 ------------------------------------------------------
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

%% --- ROBOT A (cortes impares, rail Y = -1) --------------------------------
La    = crea_eslabones_KR15();
kukaA = SerialLink(La);
kukaA.base    = transl(-1, -1, -0.305) * trotx(-pi/2);
kukaA.model3d = 'KUKA\KR15_robot1';
kukaA.name    = 'KR15_A';

%% --- ROBOT B (cortes pares,  rail Y = +1) --------------------------------
Lb    = crea_eslabones_KR15();
kukaB = SerialLink(Lb);
kukaB.base    = transl(-1, +1, -0.305) * trotx(-pi/2);
kukaB.model3d = 'KUKA\KR15_robot1';
kukaB.name    = 'KR15_B';

%% --- ROBOT ARTIFICIAL PARA CÁLCULO DE IK --------------------------------
% base = eye(4) SIEMPRE. Lc(1) ya codifica altura y X del rail.
% NO modificar ckuka.base en ningún punto del script.
Lc(1) = Link([0 -0.305 -1 -pi/2], 'standard');
Lc(2) = Link([0  0      0  pi/2  1], 'standard');
Lc(3) = Link([0  0.675  0.3 -pi/2 0], 'standard');
Lc(4) = Link([0  0      0.65  0   0], 'standard');
Lc(5) = Link([0  0      0.15 -pi/2 0], 'standard');
Lc(6) = Link([0  0.60   0    pi/2  0], 'standard');
Lc(7) = Link([0  0      0    pi/2  0], 'standard');
Lc(8) = Link([0 -0.14   0    pi    0], 'standard');

ckuka         = SerialLink(Lc, 'name', 'Celula');
ckuka.model3d = 'KUKA\KR15_2_2';
% ckuka.base permanece eye(4)  igual que en el código original
cqi     = [0,  0,  0,  -pi/2,  0,  0,  0,  0];
IK_seed = [0, -0.5, 0, -1, 0.5, 0, 0.5, 0];

%% --- MESA ----------------------------------------------------------------
M               = Link([0 0 0 0], 'standard');
MesaRot         = SerialLink(M);
MesaRot.model3d = 'MESA';
MesaRot.name    = 'MESA';

%% --- TOCHO INICIAL -------------------------------------------------------
OPoints = 0.3 * [0 0 0; 1 0 0; 1 1 0; 0 1 0;
                  0 0 1; 1 0 1; 1 1 1; 0 1 1]';
p = polyhedra(OPoints, [1 2 3 4; 1 2 6 5; 2 3 7 6;
                         5 6 7 8; 3 4 8 7; 1 4 8 5]);
T0obj_inicial = T0 * transl(-0.15, -0.15, 0);

%% =========================================================================
%  FUNCIÓN AUXILIAR: mundo_a_ckuka
%  Convierte una transformada en coordenadas mundo al sistema local de ckuka,
%  compensando el offset Y del robot que va a ejecutar el corte.
%
%  ckuka está centrado en Y=0. Si el robot real está en Y=railY, los puntos
%  del tocho (definidos en coordenadas mundo) se ven desde ckuka desplazados
%  en -railY respecto al eje Y.
%
%  Uso:
%    T_ckuka = mundo_a_ckuka(T_mundo, railY)
%    donde railY = -1 para Robot A, +1 para Robot B
% =========================================================================
function T_local = mundo_a_ckuka(T_mundo, railY)
    % ckuka asume que el robot está en Y=0. El robot real está en Y=railY.
    % Compensamos restando railY al componente Y de la traslación del target.
    T_local = T_mundo;
    T_local(2,4) = T_mundo(2,4) - railY;
end

%% =========================================================================
%  FUNCIÓN: calcula_corte
%  T_ini y T_fin deben estar ya en el sistema local de ckuka
%  (usar mundo_a_ckuka antes de llamar).
%  Devuelve trayectoria en 7 DOF del KR15 (cols 2:8).
% =========================================================================
function [tray_KR15, vel_q] = calcula_corte(ckuka, cqi, IK_seed, T_ini, T_fin)

    cqf_ini = ckuka.ikine(T_ini, IK_seed, 'pinv');
    cqf_fin = ckuka.ikine(T_fin, IK_seed, 'pinv');

    tray_aprox  = jtraj(cqi,     cqf_ini, 50);
    tray_retira = jtraj(cqf_fin, cqi,     50);

    cTray_corte = ctraj(T_ini, T_fin, 50);
    tray_corte  = zeros(50, length(cqi));
    for i = 1:50
        tray_corte(i,:) = ckuka.ikine(cTray_corte(:,:,i), IK_seed, 'pinv');
    end

    tray_full = cat(1, tray_aprox, tray_corte, tray_retira);
    tray_KR15 = tray_full(:, 2:8);

    % Velocidades articulares (Jacobiano diferencial)
    vel_end = [0, 0.005, 0, 0, 0, 0]';
    vel_q   = zeros(50, length(cqi));
    for i = 1:50
        J = ckuka.jacob0(tray_corte(i,:));
        vel_q(i,:) = pinv(J) * vel_end;
    end
end

%% =========================================================================
%  FUNCIÓN: plot_velocidades
% =========================================================================
function plot_velocidades(vel_q, num_corte, fig_vel)
    figure(fig_vel);
    subplot(2,1,1);
    plot(vel_q(:,2), 'LineWidth', 1.5);
    ylabel('m/s'); grid on;
    legend('Vel Q1 (prismática)');
    title(sprintf('VELOCIDADES ARTICULACIONES  CORTE %d', num_corte));

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
%  PRE-CÁLCULO CORTE 1  Robot A (rail Y = -1)
%  Los puntos del tocho se convierten al sistema de ckuka compensando Y=-1
% =========================================================================

% Puntos objetivo en coordenadas MUNDO
T11_mundo = T0obj_inicial * transl(0.15,  0.40, 0.3) * trotx(pi);
T13_mundo = T0obj_inicial * transl(0.15, -0.10, 0.3) * trotx(pi);

% Convertir al sistema local de ckuka (compensar rail Y=-1)
T11_A = mundo_a_ckuka(T11_mundo, -1);
T13_A = mundo_a_ckuka(T13_mundo, -1);

fprintf('Calculando trayectoria Corte 1 (Robot A)...\n');
[tray_kukaA_c1, vel_c1] = calcula_corte(ckuka, cqi, IK_seed, T11_A, T13_A);

%% =========================================================================
%  PRE-CÁLCULO CORTE 2  Robot B (rail Y = +1)
%  Los puntos del tocho se convierten al sistema de ckuka compensando Y=+1
% =========================================================================

% Puntos objetivo en coordenadas MUNDO
T21_mundo = T0obj_inicial * transl(0.00, -0.10, 0.3) * trotx(pi);
T23_mundo = T0obj_inicial * transl(0.30,  0.30, 0.3) * trotx(pi);

% Convertir al sistema local de ckuka (compensar rail Y=+1)
T21_B = mundo_a_ckuka(T21_mundo, +1);
T23_B = mundo_a_ckuka(T23_mundo, +1);

fprintf('Calculando trayectoria Corte 2 (Robot B)...\n');
[tray_kukaB_c2, vel_c2] = calcula_corte(ckuka, cqi, IK_seed, T21_B, T23_B);

fprintf('Cálculo completado. Iniciando animación...\n\n');

%% =========================================================================
%  FIGURA DE ANIMACIÓN  inicialización única
% =========================================================================
figure('units','normalized','outerposition',[0 0 1 1]);
title('SITUACIÓN INICIAL  2 ROBOTS KR15');

% 1. Renderizar robots y mesa
kukaA.plot3d_Pastor_Tamarit(q_park_A, 'workspace', W);
kukaB.plot3d_Pastor_Tamarit(q_park_B, 'workspace', W);

% 2. Renderizar tocho inicial
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);

MesaRot.plot3d_Pastor_Tamarit(cqi(1), 'workspace', W);

% 3.  BLOQUEAR HOLD ANTES DE CREAR ESFERAS (evita borrado accidental)
hold(gca, 'on');
[h_esf_A, esf_data] = init_esferas_visuales();
[h_esf_B, ~]        = init_esferas_visuales();

% 4. Posicionar esferas en la configuración de parking
actualizar_esferas_frame(kukaA, q_park_A, esf_data, h_esf_A);
actualizar_esferas_frame(kukaB, q_park_B, esf_data, h_esf_B);

drawnow; % Forzar renderizado completo antes de la animación
pause(1.5);

% Guardar handles del tocho para borrar SOLO él al actualizar.
% polyhedra/plot no devuelve handles, así que los capturamos comparando
% los patches existentes antes y después de dibujar el tocho.
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);

MesaRot.plot3d_Pastor_Tamarit(cqi(1), 'workspace', W);
pause(1.5);

%% =========================================================================
%  CORTE 1  Robot A corta, Robot B en parking
% =========================================================================
title('CORTE 1  Robot A (secuencia)');
animate_dual(kukaA, tray_kukaA_c1, kukaB, q_park_B, h_esf_A, esf_data, h_esf_B, esf_data);

% Velocidades Corte 1
plot_velocidades(vel_c1, 1, 2);

% Actualizar tocho  borrar solo h_tocho
OPoints = 0.3 * [0 0 0; 0.2/0.3 0 0; 0.2/0.3 1 0; 0 1 0;
                  0 0 1; 0.2/0.3 0 1; 0.2/0.3 1 1; 0 1 1]';
p = polyhedra(OPoints, [1 2 3 4; 1 2 6 5; 2 3 7 6;
                          5 6 7 8; 3 4 8 7; 1 4 8 5]);
figure(1);
title('Tocho actualizado  preparando Corte 2...');
delete(h_tocho);
patches_antes = findobj(gca, 'Type', 'patch');
plot(p, ht(T0obj_inicial), 'y');
patches_despues = findobj(gca, 'Type', 'patch');
h_tocho = setdiff(patches_despues, patches_antes);
drawnow;
pause(0.5);

%% =========================================================================
%  CORTE 2  Robot B corta, Robot A en parking
% =========================================================================
figure(1);
title('CORTE 2  Robot B (secuencia)');
animate_dual(kukaB, tray_kukaB_c2, kukaA, q_park_A, h_esf_B, esf_data, h_esf_A, esf_data);

% Velocidades Corte 2
plot_velocidades(vel_c2, 2, 3);

% Tocho final
OPoints = 0.3 * [0 0 0; 0.1/0.3 0 0; 0.2/0.3 1 0; 0 1 0;
                  0 0 1; 0.1/0.3 0 1; 0.2/0.3 1 1; 0 1 1;
                  0.2/0.3 0.2/0.3 0; 0.2/0.3 0.2/0.3 1]';
p = polyhedra(OPoints, [1 2 3 4; 2 2 9 3; 1 2 6 5; 2 3 7 6;
                          5 6 7 8; 6 6 10 7; 9 3 7 10; 3 4 8 7;
                          1 4 8 5; 2 9 10 6]);
figure(1);
title('SECUENCIA COMPLETADA  ambos robots en posición de reposo');
delete(h_tocho);
plot(p, ht(T0obj_inicial), 'y');
drawnow;

msgbox('Programa Finalizado  2 robots KR15 completaron todos los cortes.');

% Las funciones init_esferas_visuales() y actualizar_esferas_frame() se
% encuentran en sus propios archivos .m separados (misma carpeta).
% Esto permite reutilizarlas desde animate_dual y desde el script principal.