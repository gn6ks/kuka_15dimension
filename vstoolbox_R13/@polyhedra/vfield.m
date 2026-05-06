function vf = vfield(p,v,w)

n = size(p.m,2);

vf = v * ones(1,n) + skewsym(w) * p.m(1:3,:);

function m = skewsym(u)

m = [0 -u(3) u(2); u(3) 0 -u(1); -u(2) u(1) 0];
