function viewCCD(c,T0c,p,T0o,color,CCDSize)

if nargin<6
    CCDSize=[0.0084 0.0071];    
end

if nargin<5
    color='none';    
end

pc = inverse(T0c)*T0o*p;

u = c.fu * x(pc) ./ z(pc) + c.u0;
v = c.fv * y(pc) ./ z(pc) + c.v0;

X=CCDSize(1)*(u-c.u0)/c.hres;
Y=CCDSize(2)*(v-c.v0)/c.vres;

% 
% u = c.fu * x(pc) ./ z(pc);
% v = c.fv * y(pc) ./ z(pc);

plot(X,Y,'.','MarkerSize',10);

hold on;

patch('faces',faces(p),'vertices',[X; Y]','FaceColor',color);

hold off;

axis equal;
%axis ij;
axis([-CCDSize(1)/2.0 CCDSize(1)/2.0 -CCDSize(2)/2.0 CCDSize(2)/2.0]);
