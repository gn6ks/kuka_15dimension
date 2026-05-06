function ploterr(img,img_x)

n = size(img.signals.values,2);
t = size(img.signals.values,3);

s = reshape(img.signals.values,n*2,t)';
s_x = reshape(img_x.signals.values,n*2,t)';

colors = 'bgrcmy';
hold on;
for i=1:n*2
    plot(img.time,s(:,i)-s_x(:,i),colors(rem(i,6)+1));
end
hold off;