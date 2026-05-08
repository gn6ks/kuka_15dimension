%  =========================================================================
%  Based on the theory of Josep Tornero i Montserrat
%  Maintainer: gn6ks
%  =========================================================================

% ANIMATE_DUAL  Animates TWO KR15 robots in the same figure, frame by frame.
%   The active robot follows its trajectory; the parking robot remains stationary.
%   In each frame, the poly-spheres of BOTH robots are updated and
%   inter-robot collision is checked.
function animate_dual(robotActivo, tray_activo, robotParking, q_parking, ...
                      h_esf_A, esf_data_A, h_esf_B, esf_data_B)

    handles_activo  = findobj('Tag', robotActivo.name);
    handles_parking = findobj('Tag', robotParking.name);
    links_a  = robotActivo.links;
    links_p  = robotParking.links;
    N_a      = robotActivo.n;
    N_p      = robotParking.n;

    actualizar_esferas_frame(robotParking, q_parking, esf_data_B, h_esf_B);

    for fi = 1:size(tray_activo, 1)
        q_a = tray_activo(fi, :);
        q_p = q_parking;

        % ── 1) Update ACTIVE robot (visual kinematics) ─────────────────
        for handle = handles_activo'
            h = get(handle, 'UserData');
            T = robotActivo.base;
            vert = transl(T)';
            for L = 1:N_a
                if h.link(L) ~= 0
                    set(h.link(L), 'Matrix', T);
                end
                T    = T * links_a(L).A(q_a(L));
                vert = [vert; transl(T)'];
            end
            T = T * robotActivo.tool;
            if length(h.link) > N_a
                set(h.link(N_a+1), 'Matrix', T);
            end
            vert = [vert; transl(T)'];
            if isfield(h, 'shadow')
                set(h.shadow, 'Xdata', vert(:,1), 'Ydata', vert(:,2), ...
                    'Zdata', h.floorlevel * ones(size(vert(:,1))));
            end
            if isfield(h, 'trail')
                Ttool = robotActivo.fkine(q_a);
                robotActivo.trail = [robotActivo.trail; transl(Ttool)'];
                set(h.trail, 'Xdata', robotActivo.trail(:,1), ...
                              'Ydata', robotActivo.trail(:,2), ...
                              'Zdata', robotActivo.trail(:,3));
            end
            if ~isempty(h.wrist)
                trplot(h.wrist, T);
            end
            h.q = q_a;
            set(handle, 'UserData', h);
        end

        % ── 2) Update PARKING robot (visual, no detection) ────────────
        for handle = handles_parking'
            h = get(handle, 'UserData');
            T = robotParking.base;
            vert = transl(T)';
            for L = 1:N_p
                if h.link(L) ~= 0
                    set(h.link(L), 'Matrix', T);
                end
                T    = T * links_p(L).A(q_p(L));
                vert = [vert; transl(T)'];
            end
            T = T * robotParking.tool;
            if length(h.link) > N_p
                set(h.link(N_p+1), 'Matrix', T);
            end
            vert = [vert; transl(T)'];
            if isfield(h, 'shadow')
                set(h.shadow, 'Xdata', vert(:,1), 'Ydata', vert(:,2), ...
                    'Zdata', h.floorlevel * ones(size(vert(:,1))));
            end
            h.q = q_p;
            set(handle, 'UserData', h);
        end

        % ── 3) Update poly-spheres of ACTIVE robot + collision detection
        %   The 6 arguments are passed so actualizar_esferas_frame()
        %   can check the inter-sphere distance between both robots.
        [colision, pares] = actualizar_esferas_frame( ...
            robotActivo, q_a, esf_data_A, h_esf_A, esf_data_B, h_esf_B);

        % ── 4) Single drawnow per frame (performance) ─────────────────────
        delay = robotActivo.delay;
        if delay > 0
            pause(delay);
        end
        drawnow;
    end
end