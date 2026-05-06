
function s = pixel2coord(uv,Fu,Fv,u0,v0)

n = size(uv,2);

u = uv(1,:);
v = uv(2,:);

x = (u - u0) / Fu;
y = (v - v0) / Fv;
s = reshape([x; y], 2*n,1);

% end of pixel2coord