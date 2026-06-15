# MATLAB Numerical Modelling Portfolio — Warren Truss & Dynamic Systems

> MEng Mechanical Engineering · University of Sussex · H7137 Numerical Modelling

## Overview

Five-problem MATLAB portfolio built around a 7-node, 11-member Warren truss (candidate 293259). Problems progress from static matrix analysis through parametric design optimisation, regression-based calibration, strain energy methods, and SDOF dynamic simulation — each with full interactivity where relevant.

---

## Problem Breakdown

### Problem 1 — Static Truss Solver (Direct Stiffness Method)

- Assembled 14×14 global stiffness matrix for the Warren truss
- Applied boundary conditions and solved for all nodal displacements and member forces
- Computed member stresses and factors of safety

### Problem 2 — Parametric Design Tool

- Swept P1 and P3 loads across 10,000 combinations to map the full design space
- Interactive UI sliders (uicontrol) for real-time load adjustment
- Contour plots of factor of safety across the P1–P3 space
- FoS annotations flagging critical members and unsafe regions

### Problem 3 — Strain Gauge Calibration & Root-Finding

- Synthetic strain gauge data: polynomial regression to build a calibration curve
- Secant method root-finding to identify the load at which FoS = 1 (failure threshold)
- Two-script structure: data processing + solver
- Residual analysis to validate regression quality

### Problem 4 — Strain Energy & Castigliano's Theorem

- Computed strain energy stored in each member using per-member cross-sectional areas from `synthetic_truss_293259.mat`
- Applied Castigliano's theorem to predict nodal displacements
- Trapezoidal numerical integration for energy accumulation
- Results cross-checked against Problem 1 displacements

### Problem 5 — SDOF Dynamic Response Simulator

- ODE45 integration of the equation of motion for a damped SDOF system
- Interactive dashboard (uicontrol sliders): mass, stiffness, damping ratio, forcing frequency
- Resonance detection — flags when excitation frequency approaches natural frequency
- Dynamic Magnification Factor (DMF) output as a function of frequency ratio

---

## Key Technical Features

| Feature | Detail |
|---|---|
| Truss geometry | 7 nodes, 11 members, Warren configuration |
| Matrix solver | Direct stiffness, 14×14 system |
| Design space | 10,000 P1–P3 combinations |
| Root-finding | Secant method (Problem 3) |
| Integration | Trapezoidal rule (Problem 4) |
| ODE solver | ode45 (Problem 5) |
| UI style | Classic uicontrol sliders (no App Designer) |

## Project Structure

```
my-project/
├── README.md
├── src/
│   ├── problem1_truss_solver.m
│   ├── problem2_parametric_tool.m
│   ├── problem3_calibration.m       ← Script 1: regression & data
│   ├── problem3_rootfinding.m       ← Script 2: secant method solver
│   ├── problem4_strain_energy.m
│   ├── problem5_dynamic_dashboard.m
│   └── synthetic_truss_293259.mat
├── results/                         ← all figures, contour plots, dashboard screenshots
├── requirements.txt                 ← MATLAB version, toolboxes
└── docs/                            ← full LaTeX report (PDF)
```

## Requirements

- MATLAB R2021b or later
- No additional toolboxes required (ODE45 and uicontrol are base MATLAB)

## Notes

All scripts are self-contained and runnable in sequence. Interactive problems (2 and 5) open figure windows with slider panels — adjust sliders to explore the design or response space in real time. Problem 3 requires both scripts to be run: calibration first, then root-finding.
