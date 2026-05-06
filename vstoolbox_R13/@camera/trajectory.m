function trajectory(c,T0c)

n = size(T0c.signals.values,3);
plot(ht(T0c.signals.values(:,:,1)),'start');

prevhold = ishold;

if ~prevhold
    hold on;
end

for i=2:5:n-1
    plot(ht(T0c.signals.values(:,:,i)));
end
plot(ht(T0c.signals.values(:,:,end)),'end');

plot(c,ht(T0c.signals.values(:,:,1)));
plot(c,ht(T0c.signals.values(:,:,end)));

if ~prevhold
    hold off;
end
    
