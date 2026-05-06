function val = get(s,prop_name)
% GET Get camera property from the specified object
% and return the value. Property names are: fu, fv, u0, v0, hres, vres

switch prop_name
case 'fu'
    val = s.fu;
case 'fv'
    val = s.fv;
case 'u0'
    val = s.u0;
case 'v0'
    val = s.v0;
case 'hres'
    val = s.hres;
case 'vres'
    val = s.vres;
otherwise
    error([prop_name ,'Is not a valid camera property'])
end