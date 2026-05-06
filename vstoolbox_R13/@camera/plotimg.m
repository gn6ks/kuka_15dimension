function plotimg(c,img,img_x)

n = size(img.signals.values,2);
t = size(img.signals.values,3);

axis([0 get(c,'hres')-1 0 get(c,'vres')-1]);
axis('equal');
axis('ij');
hold on;
for i=1:n
    plot(reshape(img.signals.values(1,i,:),t,1),reshape(img.signals.values(2,i,:),t,1),'.');
end

if nargin==3
    for i=1:n
        plot(reshape(img_x.signals.values(1,i,1),1,1),reshape(img_x.signals.values(2,i,1),1,1),'r+');
    end
end
hold off;