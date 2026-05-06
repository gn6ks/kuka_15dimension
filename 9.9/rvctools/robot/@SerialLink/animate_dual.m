function animate_dual(robotActivo, tray_activo, robotParking, q_parking, ...
                      h_esf_A, esf_data_A, h_esf_B, esf_data_B)
% ANIMATE_DUAL  Anima DOS robots KR15 en la misma figura, frame a frame.
%   El robot activo sigue su trayectoria; el robot en parking permanece quieto.
%   En cada frame se actualizan las poli-esferas de AMBOS robots y se comprueba
%   la colisión inter-robot según la teoría poli-esférica de Tornero.
%
% Uso:
%   animate_dual(robotActivo, tray_activo, robotParking, q_parking, ...
%                h_esf_A, esf_data_A, h_esf_B, esf_data_B)
%
%   h_esf_A / esf_data_A  → esferas del robot ACTIVO
%   h_esf_B / esf_data_B  → esferas del robot en PARKING
%
% Detección de colisiones:
%   Se llama a actualizar_esferas_frame() con los 6 argumentos para obtener
%   [colision, pares]. Si hay colisión se imprime un aviso en consola y las
%   esferas implicadas se resaltan en rojo. La animación NO se detiene (decisión
%   de diseño: el control reactivo queda fuera del alcance de este módulo).

    handles_activo  = findobj('Tag', robotActivo.name);
    handles_parking = findobj('Tag', robotParking.name);
    links_a  = robotActivo.links;
    links_p  = robotParking.links;
    N_a      = robotActivo.n;
    N_p      = robotParking.n;

    % ── Precalcular esferas del robot en PARKING (no cambia en el bucle) ──
    % Se actualiza una sola vez aquí para que c_glob_B esté disponible
    % en la primera iteración de actualizar_esferas_frame con detección.
    actualizar_esferas_frame(robotParking, q_parking, esf_data_B, h_esf_B);

    for fi = 1:size(tray_activo, 1)
        q_a = tray_activo(fi, :);
        q_p = q_parking;

        % ── 1) Actualizar robot ACTIVO (cinemática visual) ─────────────────
        for handle = handles_activo'
            h = get(handle, 'UserData');
            T = robotActivo.base;
            vert = transl(T)';
            for L = 1:N_a
                if h.link(L) ~= 0
                    set(h.link(L), 'Matrix', T);
                end
                T    = T * links_a(L).A(q_a(L));
                vert = [vert; transl(T)']; %#ok<AGROW>
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

        % ── 2) Actualizar robot PARKING (visual, sin detección) ────────────
        for handle = handles_parking'
            h = get(handle, 'UserData');
            T = robotParking.base;
            vert = transl(T)';
            for L = 1:N_p
                if h.link(L) ~= 0
                    set(h.link(L), 'Matrix', T);
                end
                T    = T * links_p(L).A(q_p(L));
                vert = [vert; transl(T)']; %#ok<AGROW>
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

        % ── 3) Actualizar poli-esferas del robot ACTIVO + detección colisión
        %   Se pasan los 6 argumentos para que actualizar_esferas_frame()
        %   compruebe la distancia inter-esfera entre ambos robots.
        [colision, pares] = actualizar_esferas_frame( ...
            robotActivo, q_a, esf_data_A, h_esf_A, esf_data_B, h_esf_B);

        % ── 4) Un solo drawnow por frame (rendimiento) ─────────────────────
        delay = robotActivo.delay;
        if delay > 0
            pause(delay);
        end
        drawnow;
    end
end