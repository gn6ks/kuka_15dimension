function varargout = GetRPY(h)

s = h.m(1:3,1);
n = h.m(1:3,2);
a = h.m(1:3,3);

phi = atan2(s(2),s(1));
theta = atan2(-s(3),cos(phi)*s(1)+sin(phi)*s(2));
psi = atan2(sin(phi)*a(1)-cos(phi)*a(2),-sin(phi)*n(1)+cos(phi)*n(2));

if nargout <= 1
    varargout{1} = [phi; theta; psi];
elseif nargout == 3
    varargout{1} = phi;
    varargout{2} = theta;
    varargout{3} = psi;
else
    error('Wrong number of output arguments')
end
