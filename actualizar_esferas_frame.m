%  =========================================================================
%  Based on the theory of Josep Tornero i Montserrat
%  Maintainer: gn6ks
%  =========================================================================

% UPDATE_SPHERES_FRAME  Updates global positions of poly-spheres
%   and, optionally, detects collisions with a second set of spheres.

function [colision, pares] = actualizar_esferas_frame(robot, q, esf_data, h_esferas, esf_data_B, h_esferas_B)

    detectar = (nargin == 6);
    colision = false;
    pares    = zeros(0, 4);

    N_A = numel(esf_data.radii);

    % ── Global centers of robot A ──────────────────────────────────────
    c_glob_A = zeros(3, N_A);

    T = robot.base;
    ultimo_link = 0;
    for i = 1:robot.n
        T = T * robot.links(i).A(q(i));
        idx = find(esf_data.link == i);
        if isempty(idx), continue; end

        for k = idx
            % Save global center for later detection
            hom   = T * [esf_data.centers(:, k); 1];
            c_glob_A(:, k) = hom(1:3);

            % Update visualization (only if handle is still valid)
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

    % ── Collision detection with robot B ─────────────────────────────────
    if ~detectar, return; end

    N_B = numel(esf_data_B.radii);

    % Retrieve current global centers of robot B from handles
    % (already computed in its previous call to this function)
    c_glob_B = zeros(3, N_B);
    for j = 1:N_B
        if isvalid(h_esferas_B(j))
            xd = get(h_esferas_B(j), 'XData');
            yd = get(h_esferas_B(j), 'YData');
            zd = get(h_esferas_B(j), 'ZData');
            % Center = central point of the stored surface mesh
            c_glob_B(:, j) = [mean(xd(:)); mean(yd(:)); mean(zd(:))];
        end
    end

    % Check all sphere pairs (k_A, j_B) inter-robot
    for k = 1:N_A
        for j = 1:N_B
            dist = norm(c_glob_A(:, k) - c_glob_B(:, j));
            umbral = esf_data.radii(k) + esf_data_B.radii(j);
            if dist < umbral
                colision = true;
                pares(end+1, :) = [k, esf_data.link(k), j, esf_data_B.link(j)];
                % Highlight colliding spheres
                if isvalid(h_esferas(k))
                    set(h_esferas(k),   'FaceColor', [1, 0.2, 0.2], 'FaceAlpha', 0.55);
                end
                if isvalid(h_esferas_B(j))
                    set(h_esferas_B(j), 'FaceColor', [1, 0.2, 0.2], 'FaceAlpha', 0.55);
                end
            else
                % Restore normal color if no longer colliding
                if isvalid(h_esferas(k))
                    set(h_esferas(k),   'FaceColor', [0.1, 0.5, 0.9], 'FaceAlpha', 0.30);
                end
                if isvalid(h_esferas_B(j))
                    set(h_esferas_B(j), 'FaceColor', [0.1, 0.5, 0.9], 'FaceAlpha', 0.30);
                end
            end
        end
    end

    % Show warning in console if collision occurs
    if colision
        links_A = unique(pares(:, 2))';
        links_B = unique(pares(:, 4))';
        fprintf('[COLLISION] Robot A link(s) %s  ↔  Robot B link(s) %s\n', ...
            num2str(links_A), num2str(links_B));
    end
end