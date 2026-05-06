function varargout = GetTranslation(h)

if nargout <= 1
    varargout{1} = h.m(1:3,4);
elseif nargout == 3
    for i=1:3
        varargout{i} = h.m(i,4);
    end
else
    error('Wrong number of output arguments')
end

