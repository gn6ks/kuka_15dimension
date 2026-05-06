function c = camera(varargin)
% CAMERA Constructor function for camera object

vert = [0 0 0; 0.5 -0.5 1; 0.5 0.5 1; -0.5 0.5 1; -0.5 -0.5 1]';
fac = [1 2 3; 1 3 4; 1 4 5; 1 5 2];

switch nargin
case 0      % "null" camera: focal 1, 
    p = polyhedra(vert*0.1,fac);
    p = SetFc(p,'y');
    p = HideVert(p);
    c.fu = 1;
    c.fv = 1;
    c.u0 = 0;
    c.v0 = 0;
    c.hres = 1;
    c.vres = 1;
    c = class(c,'camera',p);
case 1
    if (isa(varargin{1},'camera'))
        c = varargin{1};
    elseif (isa(varargin{1},'polyhedra'))
        c.fu = 1;
        c.fv = 1;
        c.u0 = 0;
        c.v0 = 0;
        c.hres = 1;
        c.vres = 1;
        c = class(c,'camera',varargin{1});
    else
        error('Wrong argument type')
    end
case {6,7,8}
    c.fu = varargin{1};
    c.fv = varargin{2};
    c.u0 = varargin{3};
    c.v0 = varargin{4};
    c.hres = varargin{5};
    c.vres = varargin{6};
    if nargin < 8
        s = 0.1;
    else
        s = varargin{8};
    end
    if nargin < 7
        color = 'y';
    else
        color = varargin{7};
    end
    p = polyhedra(vert*s,fac);
    p = SetFc(p,color);
    p = HideVert(p);
    c = class(c,'camera',p);
otherwise
    error('Wrong number of input arguments')
end