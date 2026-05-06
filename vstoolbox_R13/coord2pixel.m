function s = coord2pixel(xy,Fu,Fv,u0,v0)

n = size(xy,2);

x = xy(1,:);
y = xy(2,:);

u=Fu*x+u0;
v=Fv*y+v0;

s = reshape([u; v], 2*n,1);