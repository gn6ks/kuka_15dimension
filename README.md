# KR15 Robotic Cell — Poly-Sphere Collision Detection

[![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange)](https://www.mathworks.com/)
[![Robotics Toolbox](https://img.shields.io/badge/Robotics%20Toolbox-9.9-blue)](https://petercorke.com/toolboxes/robotics-toolbox/)
[![Robot](https://img.shields.io/badge/Robot-KUKA%20KR15-red)](https://www.kuka.com/)
[![UPV](https://img.shields.io/badge/UPV-Robotics%20Research-green)](https://www.upv.es/)

Simulation of an industrial robotic cell with two **KUKA KR15** robots on a shared linear rail, performing alternate cuts on a workpiece. Features a **real-time inter-robot collision detection** system based on hierarchical poly-sphere envelopes, following Tornero's theory (*"Modelado y Detección de Colisiones en Sistemas Robotizados"*, UPV). Built on top of the [Robotics Toolbox](https://petercorke.com/toolboxes/robotics-toolbox/) by Peter Corke (v9.9).

<table>
  <tr>
    <th align="left" width="50%">Cut 1 — Robot A active</th>
    <th align="left" width="50%">Cut 2 — Robot B active</th>
  </tr>
  <tr>
    <td align="center"><i>Image / GIF — Cut 1</i></td>
    <td align="center"><i>Image / GIF — Cut 2</i></td>
  </tr>
</table>

---

## Status

| OS | MATLAB | Toolbox | Status |
|:---|:-------|:--------|:-------|
| `Windows 10/11` | `R2020b+` | `rvctools 9.9` | [![Build](https://img.shields.io/badge/build-passing-brightgreen)]() |

---

## Documentation

> All scripts must be run from the repository root folder. The main script uses relative paths to locate `rvctools` and `vstoolbox_R13` automatically.

---

## Requirements

| Component | Version | Check |
|-----------|---------|-------|
| MATLAB | R2020b or later | `version` |
| Robotics Toolbox (Corke) | 9.9 | `ver` |
| vstoolbox | R13 | Included in repo |
| KUKA 3D models | `KR15_robot1`, `KR15_2_2`, `MESA` | Inside `vstoolbox` |
| Disk space | 500 MB+ free | `dir` |

---

## Repository Structure

```
.
├── /9.9
├── /slprj
├── /vstoolbox_R13
├── actualizar_esferas_frame.m
├── Celula_IDF_corte.m
├── ForceFeedbackExample.m
├── IniciaParametrosPRR.m
├── init_esferas_visuales.m
└── Robot_3gdl_PRR.m

```

> The `Shapes_Vertex*.mat` files contain the real vertex clouds used to compute sphere parameters. Do not replace them with generic meshes.

---

## Quick Start

### Step 1 — Clone the repository

```shell
git clone https://github.com/gn6ks/kuka_15dimension.git
cd kuka_15dimension
```

### Step 2 — Open MATLAB and run

```matlab
Celula_IDF_corte
```

The script handles everything automatically: toolbox paths, IK pre-computation, 3D rendering, sphere initialisation, and animation.

### Step 3 — Expected output

| Figure | Content |
|--------|---------|
| Fig. 1 | 3D animation — robots, workpiece, semi-transparent collision spheres |
| Fig. 2 | Joint velocities — Cut 1 (Robot A) |
| Fig. 3 | Joint velocities — Cut 2 (Robot B) |

When a collision is detected between the two robots, the affected spheres turn **red** and a warning is printed to the console:

```
[COLLISION] Robot A link(s) 3  ↔  Robot B link(s) 2
```

---

## Collision Model

Each link is wrapped by 1 or 2 spheres computed with **Ritter's algorithm** on the real vertex clouds from `Shapes_Vertex*.mat`, with a **+5% safety margin** on the radius. A bi-sphere is used when it reduces volume by more than 20% over the mono-sphere — following the hierarchical efficiency criterion from Tornero's theory.

| Link | Part | Spheres | Radii (mm) |
|------|------|---------|------------|
| 1 | Body / Rail | 1 | 372 |
| 2 | Shoulder | 2 | 284 / 297 |
| 3 | Upper arm | 2 | 211 / 190 |
| 4 | Forearm | 1 | 329 |
| 5 | Wrist 1 | 2 | 157 / 154 |
| 6 | Wrist 2 | 2 | 89 / 95 |
| 7 | End-effector | 1 | 62 |

Collision condition between a sphere of Robot A and a sphere of Robot B:

```
‖c_A − c_B‖  <  r_A + r_B
```

All 121 pairs (11 × 11) are checked every frame. Verified: **100% of mesh vertices** of each link are enclosed by their assigned sphere(s).

---

## Demos

<table>
  <tr>
    <th align="left" width="33%">3D Animation</th>
    <th align="left" width="33%">Collision Detection</th>
    <th align="left" width="33%">Joint Velocities</th>
  </tr>
  <tr>
    <td align="center"><i>Image / GIF — Animation</i></td>
    <td align="center"><i>Image / GIF — Collision</i></td>
    <td align="center"><i>Image / GIF — Velocities</i></td>
  </tr>
</table>

---

## Troubleshooting

```matlab
% Robotics Toolbox not found
addpath(genpath('9.9\rvctools'))

% 3D models not rendering
addpath(genpath('vstoolbox_R13'))

% IK not converging — adjust seed configuration in Celula_IDF_corte.m
IK_seed = [0, -0.5, 0, -1, 0.5, 0, 0.5, 0];

% Spheres disappearing during animation — hold on must remain active
% Do not call hold off between init_esferas_visuales and animate_dual
```

---

## Citation

If you use this framework in your research or work, we would appreciate ❤️ if you could leave a ⭐ and/or cite it:

```bibtex
@misc{kuka_15dimension,
  author       = {gn6ks and contributors},
  title        = {KR15 Robotic Cell: Real-Time Poly-Sphere Collision Detection in MATLAB},
  year         = {2026},
  publisher    = {GitHub},
  howpublished = {\url{https://github.com/gn6ks/kuka_15dimension}}
}
```

This project builds upon the theory developed at UPV. If you also use the underlying collision detection framework, please cite:

```bibtex
@techreport{Tornero_ColisionUPV,
  author      = {Tornero, Josep},
  title       = {Modelado y Detección de Colisiones en Sistemas Robotizados},
  institution = {Universitat Politècnica de València (UPV)},
  year        = {2004}
}
```

---

## Contributors

We would like to acknowledge all contributors 🚀

[![celula_kr15 contributors](https://contrib.rocks/image?repo=<your-username>/celula_kr15&max=20)](https://github.com/<your-username>/celula_kr15/graphs/contributors)

---

## Acknowledgements

| Logo | Notes |
|:----:|:------|
| <img src="https://upload.wikimedia.org/wikipedia/commons/7/71/LOGOUPV.png" alt="UPV" width="150" align="left"> | Developed at the [Universitat Politècnica de València (UPV)](https://www.upv.es/), in the context of robotic research and development. |