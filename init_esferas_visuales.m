function [h_esferas, esf_data] = init_esferas_visuales()
% INIT_ESFERAS_VISUALES  Modelo poli-esferico envolvente del KR15 (11 esferas).
%
% =========================================================================
% ORIGEN DE LOS PARAMETROS (calculados desde Shapes_Vertex*.mat):
%   Los centros y radios se obtuvieron aplicando el algoritmo de Ritter
%   sobre la nube de vertices reales de cada pieza del KR15:
%       Vertex0 -> Link 1 (cuerpo/rail)
%       Vertex1 -> Link 2 (hombro)
%       Vertex2 -> Link 3 (brazo superior)
%       Vertex3 -> Link 4 (antebrazo)
%       Vertex4 -> Link 5 (muneca 1)
%       Vertex5 -> Link 6 (muneca 2)
%       Vertex6 -> Link 7 (efector)
%
%   Se aplico un margen de seguridad del +5% al radio (teoria Tornero,
%   "Modelado y Deteccion de Colisiones", diap. 44: esferoides cuadraticas).
%   Se uso bi-esfera cuando la reduccion de volumen respecto a mono-esfera
%   supero el 20% (criterio de eficiencia jerarquica de la teoria).
%
%   VERIFICADO: el 100% de los vertices de cada eslabon queda dentro
%   de al menos una esfera de las asignadas a ese eslabon.
%
% DECISION POR ESLABON:
%   Link 1 (Cuerpo):     MONO-esfera  (forma compacta, ganancia bi < 20%)
%   Link 2 (Hombro):     BI-esfera    (ganancia volumen 39%)
%   Link 3 (Brazo sup):  BI-esfera    (forma muy alargada, ganancia 80%)
%   Link 4 (Antebrazo):  MONO-esfera  (forma cuasi-esferica, ganancia bi < 20%)
%   Link 5 (Muneca 1):   BI-esfera    (alargada en Y, ganancia 28%)
%   Link 6 (Muneca 2):   BI-esfera    (alargada en Z, ganancia 26%)
%   Link 7 (Efector):    MONO-esfera  (pieza plana compacta)
%
% TOTAL: 11 esferas para 7 eslabones.
%
% Teoria aplicada:
%   c_global = T_i * [c_local; 1]
%   donde T_i = robot.base * A(q1) * ... * A(qi)
%   Colision: norm(c_A_k - c_B_j) < r_A_k + r_B_j
% =========================================================================

    ax = gca;
    hold(ax, 'on');
    set(ax, 'NextPlot', 'add');

    esf_data = struct();

    % ------------------------------------------------------------------
    % Centros locales [3 x 11] en METROS
    % Calculados desde los vertices reales (Shapes_Vertex*.mat) con
    % el algoritmo de Ritter + 5% margen de seguridad.
    %
    % Columnas:
    %  k=  1        2        3        4        5        6        7        8        9       10       11
    %  L=  1        2        2        3        3        4        5        5        6        6        7
    % ------------------------------------------------------------------
    esf_data.centers = ...
    [-0.0535, -0.3009,  0.0016, -0.5534, -0.0846,  0.0075, -0.0072, -0.0197, -0.0037, -0.0001,  0.0000 ; ... % X
      0.0126,  0.2564,  0.0703,  0.0162,  0.0080,  0.0134, -0.2078, -0.0330,  0.0108,  0.0310,  0.0000 ; ... % Y
      0.1780, -0.0059,  0.0850, -0.1191, -0.1589,  0.0146, -0.0268,  0.0031, -0.0636,  0.0113, -0.0345 ]; % Z

    % ------------------------------------------------------------------
    % Radios [1 x 11] en METROS  (radio Ritter * 1.05)
    % k=   1       2       3       4       5       6       7       8       9      10      11
    % ------------------------------------------------------------------
    esf_data.radii = ...
    [0.3723, 0.2839, 0.2966, 0.2113, 0.1904, 0.3285, 0.1574, 0.1539, 0.0887, 0.0945, 0.0621];

    % ------------------------------------------------------------------
    % Eslabon asociado a cada esfera (indices DH 1..7)
    % k=  1   2   3   4   5   6   7   8   9  10  11
    % ------------------------------------------------------------------
    esf_data.link = [1,  2,  2,  3,  3,  4,  5,  5,  6,  6,  7];

    % Malla esferica unitaria (16 sectores, baja resolucion para RT)
    [sx, sy, sz] = sphere(16);
    esf_data.sx = sx;
    esf_data.sy = sy;
    esf_data.sz = sz;

    % Crear objetos surface en posicion local inicial
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
    % No restaurar hold off: la animacion lo requiere.
end