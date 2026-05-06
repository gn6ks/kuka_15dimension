function CollisionAvoidance(u,Boundary,BlockName)

X=u(1,4);
Y=u(2,4);
Z=u(3,4);

y=u;
var=zeros(1,3);
set_param(['Manufacturing/' BlockName],'BackgroundColor','green');
if X > Boundary(2) || X < Boundary(1)
     var(1)=1;
end

if Y > Boundary(4) || Y < Boundary(3)
      var(1)=1;
end

if Z > Boundary(6) || Z < Boundary(5)
      var(1)=1;
end

for i=1:length(var)
   if var(i)==1
       set_param(['Manufacturing/' BlockName],'BackgroundColor','red');
       break;
   else
       
   end
end