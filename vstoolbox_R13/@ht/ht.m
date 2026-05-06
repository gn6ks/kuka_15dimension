function h = ht(varargin)
% ht Constructor function for homogeneous transformation object
switch nargin
case 0
    h.m = eye(4);
    h = class(h,'ht');
case 1
    if (isa(varargin{1},'ht'))
        h = varargin{1};
    elseif (isa(varargin{1},'double'))
        [r,c] = size(varargin{1});
        if r==4 & c==4
            h.m = varargin{1};
            h = class(h,'ht');
        else
            error('Wrong matrix dimensions')
        end
    else
        error('Wrong argument type')
    end
case 2
    if (isa(varargin{1},'char'))
        s = varargin{1};
        if strcmp(s,'xrot')
            a = varargin{2};
            h.m = eye(4);
            h.m(2:3,2:3) = [cos(a) -sin(a); sin(a) cos(a)];
            h = class(h,'ht');
        elseif strcmp(s,'yrot')
            a = varargin{2};
            h.m = eye(4);
            h.m([1 3],[1 3]) = [cos(a) sin(a); -sin(a) cos(a)];
            h = class(h,'ht');
        elseif strcmp(s,'zrot')
            a = varargin{2};
            h.m = eye(4);
            h.m(1:2,1:2) = [cos(a) -sin(a); sin(a) cos(a)];
            h = class(h,'ht');
        else
            error('Wrong argument type')
        end
    else
        error('Wrong argument type')
    end
case 4
    if (isa(varargin{1},'char'))
        s = varargin{1};
        if strcmp(s,'xyz')
            x = varargin{2};
            y = varargin{3};
            z = varargin{4};
            h.m = [eye(3) [x; y; z]; zeros(1,3) 1];
            h = class(h,'ht');
        elseif strcmp(s,'rpy')
            phi   = varargin{2};
            theta = varargin{3};
            psi   = varargin{4};
            h = ht('zrot',phi) * ht('yrot',theta) * ht('xrot',psi);
        end
    else
        error('Wrong argument type')
    end
case 7
    if (isa(varargin{1},'char'))
        s = varargin{1};
        if strcmp(s,'xyzrpy')
            x = varargin{2};
            y = varargin{3};
            z = varargin{4};
            phi   = varargin{5};
            theta = varargin{6};
            psi   = varargin{7};
            h = ht('xyz',x,y,z) * ht('rpy',phi,theta,psi);
        end
    else
        error('Wrong argument type')
    end
otherwise
    error('Wrong number of input arguments')
end
