function h = mtimes(p,q)
% ht/MTIMES Implement p * q for ht.

if isa(p,'ht') 
    if isa(q,'ht')
        h.m = p.m * q.m;
        h = class(h,'ht');
    elseif isa(q,'double')
        [r,c] = size(q);
        if r==4
            h = p.m * q;
        else
            error('Matrix argument must have 4 rows')
        end
    elseif isa(q,'polyhedra')
        h = polyhedra(p.m * coords(q),faces(q));
        h = SetFc(h,GetFc(q));
        if VertVisible(q)
            h = ShowVert(h);
        else
            h = HideVert(h);
        end
        if isa(q,'camera');
            h = camera(h);
            h = set(h,'fu',get(q,'fu'),'fv',get(q,'fv'),...
                      'u0',get(q,'u0'),'v0',get(q,'v0'),...
                      'hres',get(q,'hres'),'vres',get(q,'vres'));
        end
    else
        error('Wrong argument type')
    end
else
    error('Wrong argument type')
end
