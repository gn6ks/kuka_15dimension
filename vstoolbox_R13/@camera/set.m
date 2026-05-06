function c = set(c,varargin)
% SET Set camera properties to the specified values
% and return the updated object

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
    case 'fu'
        c.fu = val;
    case 'fv'
        c.fv = val;
    case 'u0'
        c.u0 = val;
    case 'v0'
        c.v0 = val;
    case 'hres'
        c.hres = val;
    case 'vres'
        c.vres = val;
    otherwise
        error('Invalid property')
    end
end