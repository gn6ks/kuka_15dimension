function plot(h,l,s,size)
% HT/PLOT Command figure plot of a HT
    if nargin < 4
        size=1;
    end

    if nargin < 3
        s = 0.1;
    end
    
    if nargin < 2
        l = '';
    end
    
    vx = h.m(1:3,1) * s;
    vy = h.m(1:3,2) * s;
    vz = h.m(1:3,3) * s;
    p = h.m(1:3,4);

    quiver3(p(1), p(2), p(3), vx(1), vx(2), vx(3),0,'r','LineWidth',size);

    prevhold = ishold;

    if ~prevhold
        hold on;
    end

    quiver3(p(1), p(2), p(3), vy(1), vy(2), vy(3),0,'g','LineWidth',size);
    quiver3(p(1), p(2), p(3), vz(1), vz(2), vz(3),0,'b','LineWidth',size);
    text(p(1),p(2)-s/10,p(3)-s/10,l);

    if ~prevhold
        hold off;
    end
    
