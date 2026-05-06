function [colision, pares] = actualizar_esferas_frame(robot, q, esf_data, h_esferas, esf_data_B, h_esferas_B)
% ACTUALIZAR_ESFERAS_FRAME  Actualiza posiciones globales de las poli-esferas
%   y, opcionalmente, detecta colisiones con un segundo conjunto de esferas.
%
% Sintaxis:
%   actualizar_esferas_frame(robot, q, esf_data, h_esferas)
%       Solo actualiza visualmente las esferas del robot indicado.
%
%   [colision, pares] = actualizar_esferas_frame(robot, q, esf_data, h_esferas, ...
%                                                esf_data_B, h_esferas_B)
%       Además comprueba colisión entre el robot A (el que se actualiza)
%       y el robot B (esf_data_B / h_esferas_B), ya previamente actualizado.
%
% Teoría aplicada (Tornero, "Modelado y Detección de Colisiones"):
%   La transformada global del eslabón i es:
%       T_i = robot.base * A(q1) * A(q2) * ... * A(qi)
%   El centro global de la esfera k (asociada al eslabón i) es:
%       c_glob_k = T_i * [c_local_k; 1]   (coordenadas homogéneas)
%   Condición de colisión entre esfera k del robot A y esfera j del robot B:
%       ||c_A_k - c_B_j||_2 < r_A_k + r_B_j
%   Esta es la prueba de poli-esfera de nivel 0 (bi-esfera) de la jerarquía.
%
% Salidas:
%   colision  – true si se detectó al menos una pareja de esferas en colisión
%   pares     – matriz [M x 4]: [k_A, link_A, j_B, link_B] de pares colisionados

    detectar = (nargin == 6);
    colision = false;
    pares    = zeros(0, 4);

    N_A = numel(esf_data.radii);

    % ── Centros globales del robot A ──────────────────────────────────────
    c_glob_A = zeros(3, N_A);

    T = robot.base;
    ultimo_link = 0;
    for i = 1:robot.n
        T = T * robot.links(i).A(q(i));
        idx = find(esf_data.link == i);
        if isempty(idx), continue; end

        for k = idx
            % Guardar centro global para detección posterior
            hom   = T * [esf_data.centers(:, k); 1];
            c_glob_A(:, k) = hom(1:3);

            % Actualizar visualización (solo si el handle sigue válido)
            if isvalid(h_esferas(k))
                r = esf_data.radii(k);
                set(h_esferas(k), ...
                    'XData', esf_data.sx * r + hom(1), ...
                    'YData', esf_data.sy * r + hom(2), ...
                    'ZData', esf_data.sz * r + hom(3));
            end
        end
        ultimo_link = i;
    end

    % ── Detección de colisión con robot B ─────────────────────────────────
    if ~detectar, return; end

    N_B = numel(esf_data_B.radii);

    % Recuperar centros globales actuales del robot B desde los handles
    % (ya fueron calculados en su propia llamada anterior a esta función)
    c_glob_B = zeros(3, N_B);
    for j = 1:N_B
        if isvalid(h_esferas_B(j))
            xd = get(h_esferas_B(j), 'XData');
            yd = get(h_esferas_B(j), 'YData');
            zd = get(h_esferas_B(j), 'ZData');
            % Centro = punto central de la malla surface almacenada
            c_glob_B(:, j) = [mean(xd(:)); mean(yd(:)); mean(zd(:))];
        end
    end

    % Comprobar todos los pares (k_A, j_B) de esferas inter-robot
    for k = 1:N_A
        for j = 1:N_B
            dist = norm(c_glob_A(:, k) - c_glob_B(:, j));
            umbral = esf_data.radii(k) + esf_data_B.radii(j);
            if dist < umbral
                colision = true;
                pares(end+1, :) = [k, esf_data.link(k), j, esf_data_B.link(j)]; %#ok<AGROW>
                % Resaltar esferas en colisión
                if isvalid(h_esferas(k))
                    set(h_esferas(k),   'FaceColor', [1, 0.2, 0.2], 'FaceAlpha', 0.55);
                end
                if isvalid(h_esferas_B(j))
                    set(h_esferas_B(j), 'FaceColor', [1, 0.2, 0.2], 'FaceAlpha', 0.55);
                end
            else
                % Restaurar color normal si ya no hay colisión
                if isvalid(h_esferas(k))
                    set(h_esferas(k),   'FaceColor', [0.1, 0.5, 0.9], 'FaceAlpha', 0.30);
                end
                if isvalid(h_esferas_B(j))
                    set(h_esferas_B(j), 'FaceColor', [0.1, 0.5, 0.9], 'FaceAlpha', 0.30);
                end
            end
        end
    end

    % Mostrar advertencia en consola si hay colisión
    if colision
        links_A = unique(pares(:, 2))';
        links_B = unique(pares(:, 4))';
        fprintf('[COLISIÓN] Robot A eslabón(es) %s  ↔  Robot B eslabón(es) %s\n', ...
            num2str(links_A), num2str(links_B));
    end
end