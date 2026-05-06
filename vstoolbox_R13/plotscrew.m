function plotscrew(cVc)

t = size(cVc.signals.values,3);

v = reshape(cVc.signals.values(1:3,:,:),3,t);
w = reshape(cVc.signals.values(4:6,:,:),3,t);

subplot(211);


plot(cVc.time,v(1,:),'r');
hold on;
plot(cVc.time,v(2,:),'g');
plot(cVc.time,v(3,:),'b');
legend('vx','vy','vz');
hold off;

subplot(212);

plot(cVc.time,w(1,:),'r');
hold on;
plot(cVc.time,w(2,:),'g');
plot(cVc.time,w(3,:),'b');
legend('wx','wy','wz');
hold off;
