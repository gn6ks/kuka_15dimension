function v = HYBVSn(input);

% implementation of 2D and 1/2 visual servoing
% To be revised in the next version
% 
%to simplify the programmation (point selection) 
% gain
n = 1;
lambda = 1;

[nl,nc]=size(input);
nbp=nl/5;

% Sensor informations
s = input(1:2*nbp);
sd= input(2*nbp+1:4*nbp);
Zd= input(4*nbp+1:5*nbp);

for i=1:nbp
    x(i) = s(i*2-1);
    y(i) = s(i*2);
    xd(i) = sd(i*2-1);
    yd(i) = sd(i*2);
end

% Computing the Rotation matrix
C=zeros(3*nbp,12+nbp);

for i = 1:nbp
    C(3*(i-1)+1:3*i,1:12) =[xd(i) yd(i) 1 0 0 0 0 0 0 1/Zd(i) 0 0;
                             0 0 0 xd(i) yd(i) 1 0 0 0 0 1/Zd(i) 0 ;
                             0 0 0 0 0 0 xd(i) yd(i) 1 0 0 1/Zd(i)];
    C(3*(i-1)+1:3*i,12+i) = [-x(i);-y(i);-1];
end


[U,S,V]=svd(C);

sol = V(:,12+nbp); 

kR = [sol(1:3,1)';sol(4:6,1)';sol(7:9,1)'];

dkR=det(kR);
k = sign(dkR)*(abs(dkR))^(1/3);

R = kR/k;

% evaluation of U theta by using acos (bad estimation)
% has to be improved

musth = (R-R')/2;
usth = [musth(3,2); musth(1,3); musth(2,1)];


u = usth/norm(usth);
th = acos((trace(R)-1)/2);
t = sol(10:12,1)'/k;

% extraction of the relative depth
rz = (1/k)*sol(13:12+nbp,1);


Z = rz.*Zd;

% initialisation of the error function
e(1:2,1) = s(2*(n-1)+1:2*n,1)-sd(2*(n-1)+1:2*n,1);
e(3,1) = log(rz(n));
e(4:6,1) =-u*th;


% Computing the image jacobian matrix for 2D points
for i=1:nbp
    J(i*2-1,1:6) = [-1/Z(i) 0    x(i)/Z(i)  x(i)*y(i) -(1+x(i)^2) y(i)];
    J(i*2,1:6)   = [   0 -1/Z(i) y(i)/Z(i) 1+y(i)^2  -x(i)*y(i)  -x(i)];    
end

% Extracting the 2 lines for the chosen 2D point
L(1:2,1:6) = J(2*(n-1)+1:2*n,1:6);

% Interaction line for the relative depth
% use the selected point x(n), y(n) and Z(n)
%L(3,1:6) = [...];

% Inertaction matrix fot the utheta representation
L(4:6,1:6) = [zeros(3,3) eye(3,3)];

% Computing of the control law
v=-lambda*pinv(L(1:6,:))*e(1:6);
