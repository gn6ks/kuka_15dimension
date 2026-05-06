function s = char(p)
% POLYHEDRA / CHAR
% CHAR(p) is the string representation of p.m

n = size(p.m,2);
f = '';
for i=1:n
    f = strcat(f,' %12.5g');
end
f = strcat(f,'\n');
s = sprintf(f,p.m');
