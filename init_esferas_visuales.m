%  =========================================================================
%  Based on the theory of Josep Tornero i Montserrat
%  Maintainer: gn6ks
%  =========================================================================

% PARAMETER ORIGIN (calculated from Shapes_Vertex*.mat):
%   Centers and radii were obtained by applying Ritter's algorithm
%   to the real vertex cloud of each KR15 part:
%       Vertex0 -> Link 1 (body/rail)
%       Vertex1 -> Link 2 (shoulder)
%       Vertex2 -> Link 3 (upper arm)
%       Vertex3 -> Link 4 (forearm)
%       Vertex4 -> Link 5 (wrist 1)
%       Vertex5 -> Link 6 (wrist 2)
%       Vertex6 -> Link 7 (end-effector)

function [h_esferas, esf_data] = init_esferas_visuales()
    ax = gca;
    hold(ax, 'on');
    set(ax, 'NextPlot', 'add');

    esf_data = struct();

    % ------------------------------------------------------------------
    % Local centers [3 x 11] in METERS
    % Calculated from real vertices (Shapes_Vertex*.mat) with
    % Ritter's algorithm + 5% safety margin.
    %
    % Columns:
    %  k=  1        2        3        4        5        6        7        8        9       10       11
    %  L=  1        2        2        3        3        4        5        5        6        6        7
    % ------------------------------------------------------------------
    esf_data.centers = ...
    [-0.0535, -0.3009,  0.0016, -0.5534, -0.0846,  0.0075, -0.0072, -0.0197, -0.0037, -0.0001,  0.0000 ; ... % X
      0.0126,  0.2564,  0.0703,  0.0162,  0.0080,  0.0134, -0.2078, -0.0330,  0.0108,  0.0310,  0.0000 ; ... % Y
      0.1780, -0.0059,  0.0850, -0.1191, -0.1589,  0.0146, -0.0268,  0.0031, -0.0636,  0.0113, -0.0345 ]; % Z

    % ------------------------------------------------------------------
    % Radii [1 x 11] in METERS  (Ritter radius * 1.05)
    % k=   1       2       3       4       5       6       7       8       9      10      11
    % ------------------------------------------------------------------
    esf_data.radii = ...
    [0.3723, 0.2839, 0.2966, 0.2113, 0.1904, 0.3285, 0.1574, 0.1539, 0.0887, 0.0945, 0.0621];

    % ------------------------------------------------------------------
    % Associated link for each sphere (DH indices 1..7)
    % k=  1   2   3   4   5   6   7   8   9  10  11
    % ------------------------------------------------------------------
    esf_data.link = [1,  2,  2,  3,  3,  4,  5,  5,  6,  6,  7];

    % Unit sphere mesh (16 sectors, low resolution for real-time)
    [sx, sy, sz] = sphere(16);
    esf_data.sx = sx;
    esf_data.sy = sy;
    esf_data.sz = sz;

    % Create surface objects at initial local position
    N = numel(esf_data.radii);
    h_esferas = gobjects(1, N);
    for k = 1:N
        r = esf_data.radii(k);
        c = esf_data.centers(:, k);
        h_esferas(k) = surface( ...
            sx*r + c(1), sy*r + c(2), sz*r + c(3), ...
            'FaceColor',        [0.1, 0.5, 0.9], ...
            'EdgeColor',        'none',           ...
            'FaceAlpha',        0.28,             ...
            'HandleVisibility', 'off',            ...
            'Parent',           ax);
    end
end