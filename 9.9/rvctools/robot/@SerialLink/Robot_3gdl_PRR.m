%% Cargamos librerias Descargar libreria rvctools incluida y ejecutar en workspace
%addpath(genpath('C:\Users\josemanuel\Desktop\MAII\CPR\Matlab\librerias matlab\rvctools'));
%addpath(genpath('C:\Users\josemanuel\Desktop\MAII\CPR\Matlab\librerias matlab\vstoolbox_R13'));
%% Borrado de memoria
clear all;
close all;
clc;
clf;

IniciaParametrosPRR;

figure(gcf); %Pone pantalla gráfica en primer plano

RobotPRR.plot_Pastor_Tamarit(Qini,'workspace', W);

%% CONTROL FORWARD
SimOut = sim('Robot_3gdl_PRR_Forward.slx');

figure(1)
RobotPRR.plot_Pastor_Tamarit(pos_real.signals.values,'workspace', W);

%% DATOS POSICIÓN
figure (2)
hold on

subplot(2,1,1)
title('REFERENCIA POSICIÓN PRISMÁTICA vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('m');
plot(pos_ref.time,pos_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(pos_real.time,pos_real.signals.values(:,1),'r','LineWidth',2);
legend('ref pos q_0', 'real pos q_0', -1);

subplot(2,1,2)
hold on
grid
xlabel('seg');
ylabel('m');
plot(acc_control.time,acc_control.signals.values(:,1),'m','LineWidth',2);
%'Location','southwest'
legend('acc ctrl q_0', -1);

figure (3)
hold on

subplot(2,1,1)
title('REFERENCIA POSICIÓN REVOLUCIÓN vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('rad');
plot(pos_ref.time,pos_ref.signals.values(:,2),'b','LineWidth',2,...
     'LineStyle','--');
plot(pos_ref.time,pos_ref.signals.values(:,3),'r','LineWidth',2,...
     'LineStyle','--');

plot(pos_real.time,pos_real.signals.values(:,2),'b','LineWidth',2);
plot(pos_real.time,pos_real.signals.values(:,3),'r','LineWidth',2);
legend('ref pos q_1','ref pos q_2', 'real pos q_1','real pos q_2', -1);

subplot(2,1,2)
hold on
grid
xlabel('seg');
ylabel('rad');
plot(acc_control.time,acc_control.signals.values(:,2),'m','LineWidth',2);
plot(acc_control.time,acc_control.signals.values(:,3),'c','LineWidth',2);
%'Location','southwest'
legend('acc ctrl q_1','acc ctrl q_2', -1);

%% DATOS VELOCIDAD
figure (4)
hold on
title('REFERENCIA VELOCIDAD PRISMÁTICA vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('m/s');
plot(vel_ref.time,vel_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(vel_real.time,vel_real.signals.values(:,1),'r','LineWidth',2);
legend('ref vel q_0', 'real vel q_0', -1);

figure (5)
hold on
title('REFERENCIA VELOCIDAD REVOLUCIÓN vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('rad/s');
plot(vel_ref.time,vel_ref.signals.values(:,2),'r','LineWidth',2,...
     'LineStyle','--');
plot(vel_ref.time,vel_ref.signals.values(:,3),'b','LineWidth',2,...
     'LineStyle','--');
plot(vel_real.time,vel_real.signals.values(:,2),'r','LineWidth',2);
plot(vel_real.time,vel_real.signals.values(:,3),'b','LineWidth',2);
legend('ref vel q_1', 'ref vel q_2','real vel q_1','real vel q_2', -1);

%% DATOS ACELERACIÓN

figure (6)
hold on
title('REFERENCIA ACELERACIÓN PRISMÁTICA vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('m/s^2');
plot(acel_ref.time,acel_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(acel_real.time,acel_real.signals.values(:,1),'r','LineWidth',2);
legend('ref acel q_0', 'real acel q_0', -1);

figure (7)
hold on
title('REFERENCIA ACELERACIÓN REVOLUCIÓN vs REAL. CONTROL FORWARD.');
hold on
grid
xlabel('seg');
ylabel('rad/s^2');
plot(acel_ref.time,acel_ref.signals.values(:,2),'r','LineWidth',2,...
     'LineStyle','--');
plot(acel_ref.time,acel_ref.signals.values(:,3),'b','LineWidth',2,...
     'LineStyle','--');
plot(acel_real.time,acel_real.signals.values(:,2),'r','LineWidth',2);
plot(acel_real.time,acel_real.signals.values(:,3),'b','LineWidth',2);
legend('ref acel q_1', 'ref acel q_2','real acel q_1','real acel q_2', -1);

uiwait(msgbox('Programa pausado, click OK para reanudar'));

%% CONTROL DINÁMICO INVERSO
clear all;
IniciaParametrosPRR;
SimOut = sim('Robot_3gdl_PRR_DinInv.slx');
figure(1);
clf;
RobotPRR.plot_Pastor_Tamarit(pos_real.signals.values,'workspace', W);

%% DATOS POSICIÓN
figure (8)
hold on

subplot(2,1,1)
title('REFERENCIA POSICIÓN PRISMÁTICA vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('m');
plot(pos_ref.time,pos_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(pos_real.time,pos_real.signals.values(:,1),'r','LineWidth',2);
legend('ref pos q_0', 'real pos q_0', -1);

subplot(2,1,2)
hold on
grid
xlabel('seg');
ylabel('m');
plot(acc_control.time,acc_control.signals.values(:,1),'m','LineWidth',2);
%'Location','southwest'
legend('acc ctrl q_0', -1);

figure (9)
hold on

subplot(2,1,1)
title('REFERENCIA POSICIÓN REVOLUCIÓN vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('rad');
plot(pos_ref.time,pos_ref.signals.values(:,2),'b','LineWidth',2,...
     'LineStyle','--');
plot(pos_ref.time,pos_ref.signals.values(:,3),'r','LineWidth',2,...
     'LineStyle','--');

plot(pos_real.time,pos_real.signals.values(:,2),'b','LineWidth',2);
plot(pos_real.time,pos_real.signals.values(:,3),'r','LineWidth',2);
legend('ref pos q_1','ref pos q_2', 'real pos q_1','real pos q_2', -1);

subplot(2,1,2)
hold on
grid
xlabel('seg');
ylabel('rad');
plot(acc_control.time,acc_control.signals.values(:,2),'m','LineWidth',2);
plot(acc_control.time,acc_control.signals.values(:,3),'c','LineWidth',2);
%'Location','southwest'
legend('acc ctrl q_1','acc ctrl q_2', -1);

%% DATOS VELOCIDAD
figure (10)
hold on
title('REFERENCIA VELOCIDAD PRISMÁTICA vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('m/s');
plot(vel_ref.time,vel_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(vel_real.time,vel_real.signals.values(:,1),'r','LineWidth',2);
legend('ref vel q_0', 'real vel q_0', -1);

figure (11)
hold on
title('REFERENCIA VELOCIDAD REVOLUCIÓN vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('rad/s');
plot(vel_ref.time,vel_ref.signals.values(:,2),'r','LineWidth',2,...
     'LineStyle','--');
plot(vel_ref.time,vel_ref.signals.values(:,3),'b','LineWidth',2,...
     'LineStyle','--');
plot(vel_real.time,vel_real.signals.values(:,2),'r','LineWidth',2);
plot(vel_real.time,vel_real.signals.values(:,3),'b','LineWidth',2);
legend('ref vel q_1', 'ref vel q_2','real vel q_1','real vel q_2', -1);

%% DATOS ACELERACIÓN

figure (12)
hold on
title('REFERENCIA ACELERACIÓN PRISMÁTICA vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('m/s^2');
plot(acel_ref.time,acel_ref.signals.values(:,1),'r','LineWidth',2,...
     'LineStyle','--');
plot(acel_real.time,acel_real.signals.values(:,1),'r','LineWidth',2);
legend('ref acel q_0', 'real acel q_0', -1);

figure (13)
hold on
title('REFERENCIA ACELERACIÓN REVOLUCIÓN vs REAL. CONTROL DINÁMICO INVERSO.');
hold on
grid
xlabel('seg');
ylabel('rad/s^2');
plot(acel_ref.time,acel_ref.signals.values(:,2),'r','LineWidth',2,...
     'LineStyle','--');
plot(acel_ref.time,acel_ref.signals.values(:,3),'b','LineWidth',2,...
     'LineStyle','--');
plot(acel_real.time,acel_real.signals.values(:,2),'r','LineWidth',2);
plot(acel_real.time,acel_real.signals.values(:,3),'b','LineWidth',2);
legend('ref acel q_1', 'ref acel q_2','real acel q_1','real acel q_2', -1);


