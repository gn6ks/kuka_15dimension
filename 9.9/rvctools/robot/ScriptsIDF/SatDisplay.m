function y = SatDisplay(u, MaxSat, MinSat, BlockName)
%#eml

eml.extrinsic('set_param','get_param','gcs');

y=u;
var=zeros(1,6);
set_param(['Manufacturing/' BlockName],'BackgroundColor','green');
if u(1) > MaxSat(1) || u(1) < MinSat(1)
    var(1)=1;
     if u(1) > MaxSat(1)
         y(1)=MaxSat(1);
     else
         y(1)=MinSat(1);
     end
else
     y(1) = u(1);
end


if u(2) > MaxSat(2) || u(2) < MinSat(2)
      var(1)=1;
     if u(2) > MaxSat(2)
         y(2)=MaxSat(2);
     else
         y(2)=MinSat(2);
     end
else
     y(2)=u(2);
end


if u(3) > MaxSat(3) || u(3) < MinSat(3)
      var(1)=1;
     if u(3) > MaxSat(3)
         y(3)=MaxSat(3);
     else
         y(3)=MinSat(3);
     end
else
     y(3)=u(3);
end


if u(4) > MaxSat(4) || u(5) < MinSat(5)
 var(1)=1;
     if u(4) > MaxSat(4)
         y(4)=MaxSat(4);
     else
         y(4)=MinSat(4);
     end
else
     y(4)=u(4);
end

if u(5) > MaxSat(5) || u(5) < MinSat(5)
    var(1)=1;
     if u(5) > MaxSat(5)
         y(5)=MaxSat(5);
     else
         y(5)=MinSat(5);
     end
else
     y(5)=u(5);
end

if u(6) > MaxSat(6) || u(6) < MinSat(6)
 var(1)=1;
     if u(6) > MaxSat(6)
         y(6)=MaxSat(6);
     else
         y(6)=MinSat(6);
     end
else
     y(6)=u(6);
end

for i=1:length(var)
   if var(i)==1
       set_param(['Manufacturing/' BlockName],'BackgroundColor','red');
       break;
   else
       
   end
end