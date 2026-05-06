# Célula Robotizada KR15 — Detección de Colisiones por Poli-Esferas

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)](https://www.mathworks.com/)
[![Robotics Toolbox](https://img.shields.io/badge/Robotics%20Toolbox-9.9-blue)](https://petercorke.com/toolboxes/robotics-toolbox/)
[![Robot](https://img.shields.io/badge/Robot-KUKA%20KR15-red)](https://www.kuka.com/)

Simulación de una célula robotizada con dos KUKA KR15 que realizan cortes alternos sobre un tocho, con detección de colisiones en tiempo real mediante poli-esferas envolventes.

---

## ¿Qué hace?

Dos robots KR15 de 7 DOF comparten espacio de trabajo sobre un rail lineal. Mientras uno corta, el otro espera en *parking*. En cada frame de animación, el sistema comprueba si alguna esfera de un robot solapa con alguna del otro — si ocurre, las esferas implicadas se resaltan en rojo y se imprime un aviso en consola.

```
[COLISIÓN] Robot A eslabón(es) 3  ↔  Robot B eslabón(es) 2
```

---

## Requisitos

| Componente | Versión |
|-----------|---------|
| MATLAB | R2020b o superior |
| Robotics Toolbox (Peter Corke) | 9.9 |
| vstoolbox | R13 (incluido) |

---

## Estructura

```
celula_kr15/
├── Celula_IDF_corte.m          # Script principal
├── init_esferas_visuales.m     # Modelo poli-esférico (11 esferas por robot)
├── actualizar_esferas_frame.m  # Actualización y detección de colisión
├── animate_dual.m              # Animación sincronizada de ambos robots
├── Shapes_Vertex0-6.mat        # Mallas 3D reales del KR15
├── Esferas_Robot_Locales.TXT   # Tabla de referencia de esferas
├── 9.9/rvctools/               # Robotics Toolbox
└── vstoolbox_R13/              # Toolbox de visualización 3D
```

---

## Uso

```matlab
% Desde la carpeta raíz del proyecto:
Celula_IDF_corte
```

Esto lanza en orden: cálculo de IK, planificación de trayectorias, animación 3D con esferas y gráficas de velocidades articulares.

**Figuras generadas:**

| Figura | Contenido |
|--------|-----------|
| 1 | Animación 3D — robots, tocho y esferas |
| 2 | Velocidades articulares — Corte 1 (Robot A) |
| 3 | Velocidades articulares — Corte 2 (Robot B) |

---

## Modelo de colisión

Cada eslabón queda envuelto por 1 o 2 esferas calculadas con el **algoritmo de Ritter** sobre los vértices reales de las mallas 3D, con un margen de seguridad del +5%. Se usa bi-esfera cuando reduce el volumen más de un 20% respecto a la mono-esfera.

| Link | Pieza | Esferas | Radios (mm) |
|------|-------|---------|-------------|
| 1 | Cuerpo / Rail | 1 | 372 |
| 2 | Hombro | 2 | 284 / 297 |
| 3 | Brazo superior | 2 | 211 / 190 |
| 4 | Antebrazo | 1 | 329 |
| 5 | Muñeca 1 | 2 | 157 / 154 |
| 6 | Muñeca 2 | 2 | 89 / 95 |
| 7 | Efector | 1 | 62 |

La condición de colisión entre dos esferas de robots distintos es:

```
‖c_A − c_B‖  <  r_A + r_B
```

---

## Créditos

Teoría de detección de colisiones basada en Tornero, J. *"Modelado y Detección de Colisiones en Sistemas Robotizados"* — UPV.

Simulación construida con el [Robotics Toolbox](https://petercorke.com/toolboxes/robotics-toolbox/) de Peter Corke (v9.9).