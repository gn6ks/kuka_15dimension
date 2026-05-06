function plotscrew(p,vf)

prevhold = ishold;

if ~prevhold
    hold on;
end

quiver3(p.m(1,:),p.m(2,:),p.m(3,:),vf(1,:),vf(2,:),vf(3,:),0,'m');

if ~prevhold
    hold off;
end
