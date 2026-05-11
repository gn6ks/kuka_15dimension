function h = plot(p,T,color,s)
% POLYHEDRA/PLOT Command figure plot of a polyhedra
     p1=p;
if nargin < 4
     s = '.';
else
     s = strcat(s,'.');
end
if nargin < 3
     color = 'r';
end

if nargin < 2
     T = ht; % I4
end


p1 = T * p1;

prevhold = ishold;

% if ~prevhold
%     hold on;
% end

p.fc=color;

if p.showv==1
     plot3(p1.m(1,:),p1.m(2,:),p1.m(3,:),s,'MarkerSize',10);
end

h = patch('faces',p1.e,'vertices',p1.m(1:3,:)','FaceColor',p.fc);


if ~prevhold
     hold off;
end