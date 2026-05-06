function view(c,T0c,p,T0o,color)
if nargin<5
    color='none';    
end

pc = inverse(T0c)*T0o*p;

u = c.fu * x(pc) ./ z(pc) + c.u0;
v = c.fv * y(pc) ./ z(pc) + c.v0;

% 
% u = c.fu * x(pc) ./ z(pc);
% v = c.fv * y(pc) ./ z(pc);

plot(u,v,'.','MarkerSize',10);

hold on;

patch('faces',faces(p),'vertices',[u; v]','FaceColor',color);

hold off;

axis equal;
axis ij;
axis([0 c.hres-1 0 c.vres-1]);
