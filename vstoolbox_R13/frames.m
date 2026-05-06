T0 = ht
clf
plot(T0,'world')
hold on
T0e = ht('xyzrpy',-0.2,0.3,0.8,pi/6,pi/2,pi/12)
plot(T0e,'end-effector')
Tec = ht('xyzrpy',0.03,-0.02,0.5,pi/4,0,0)
T0c = T0e * Tec
plot(T0c,'camera')
axis equal
