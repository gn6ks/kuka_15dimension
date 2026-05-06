function uv=image(T0P,Fu,Fv,u0,v0)

X=T0P(1,:);
Y=T0P(2,:);
Z=T0P(3,:);

x=X./Z;
y=Y./Z;

fx=Fu*x;
fy=Fv*y;

u=fx+u0;
v=fy+v0;

uv=[u;v];