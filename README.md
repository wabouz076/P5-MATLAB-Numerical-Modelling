# MATLAB Numerical Modelling Portfolio — Warren Truss & Dynamic Systems

> H7137 Numerical Modelling & Engineering Simulations · University of Sussex · Candidate 293259

## Overview

Five-problem MATLAB portfolio built around a candidate-specific 7-node, 11-member Warren truss (candidate 293259, using `synthetic_truss_293259.mat`). Problems progress from static matrix analysis through parametric design optimisation, regression-based calibration, strain energy methods, and SDOF dynamic simulation — each with full interactivity where relevant.

Applied loads: **P1 = 10 kN**, **P2 = 13 kN**, **P3 = 17 kN**. Member cross-sections: bottom chord A = 870 mm², top chord A = 750 mm², diagonals A = 690 mm².

---

## Problem Breakdown

### Problem 1 — Static Truss Solver (`problem1truss.m` + `truss_solver.m`)

Direct stiffness method. The 14-equation equilibrium system (7 nodes × 2 DOF) was assembled into a 14×14 matrix Ax = b, solved via MATLAB backslash (LU decomposition). Member forces, nodal displacements, and factors of safety computed for the full truss geometry (θ = atan(3/1.5)).

Key file: `truss_solver.m` — callable function used by Problems 2, 3, 4.

### Problem 2 — Parametric Design Tool (`problem2_main.m`)

P1 swept from 0–30 kN and P3 from 0–51 kN across 100×100 = 10,000 combinations (P2 fixed at 13 kN). Factor of safety computed at each combination for all 11 members. Output: contour maps of max tension and max compression FoS over the full P1–P3 design space, with interactive uicontrol sliders for real-time adjustment.

### Problem 3 — Strain Gauge Calibration & Root-Finding (`problem_3.m`)

Loaded `synthetic_truss_293259.mat` for candidate-specific strain gauge data. Polynomial regression to build a calibration curve (measured microstrain vs. predicted). Secant method root-finding to identify the failure load threshold (FoS = 1). Residual analysis included to validate fit quality.

### Problem 4 — Strain Energy & Castigliano's Theorem (`PROBLEM_4.m`)

Strain energy computed for each of the 11 members using candidate-specific areas (A_bot = 870 mm², A_top = 750 mm², A_diag = 690 mm²), with 50 discretisation points per member. Trapezoidal numerical integration over each member length. Displacements derived via Castigliano's theorem and cross-checked against Problem 1 results.

### Problem 5 — SDOF Dynamic Response Simulator (`problem_5.m`)

Candidate-specific parameters: m = 1200 kg, k = 4×10⁶ N/m, ζ = 0.05 (from digit vector d = [2,9,3,2,5,9]). Forcing amplitude P₀ = 10,000 N. ODE45 integration of the equation of motion. Interactive dashboard: sliders for mass, stiffness, damping ratio, and excitation frequency. Resonance flagged when excitation frequency approaches natural frequency. DMF output as a function of frequency ratio.

---

## Key Technical Summary

| Feature | Detail |
|---|---|
| Truss | 7 nodes, 11 members, Warren geometry, θ = atan(3/1.5) |
| Matrix system | 14×14, direct stiffness + LU decomposition |
| Design sweep | 10,000 combinations (P1 × P3) |
| Root-finding | Secant method (Problem 3) |
| Integration | Trapezoidal rule (Problem 4), 50 pts/member |
| ODE solver | ode45 (Problem 5) |
| UI | uicontrol sliders (Problems 2 and 5) |
| Data file | `synthetic_truss_293259.mat` — candidate-specific truss data |

---

## Project Structure

```
my-project/
├── README.md
├── src/
│   ├── problem1truss.m             ← static truss solver (main script)
│   ├── truss_solver.m              ← callable solver function
│   ├── problem2_main.m             ← parametric design tool
│   ├── problem_3.m                 ← calibration + secant root-finding
│   ├── PROBLEM_4.m                 ← strain energy + Castigliano
│   ├── problem_5.m                 ← SDOF ODE45 dynamic dashboard
│   └── synthetic_truss_293259.mat  ← candidate-specific truss data
├── results/                        ← figures, contour maps, dashboard screenshots
├── requirements.txt
└── docs/                           ← full report (PDF)
```

## Requirements

MATLAB R2021b or later. No additional toolboxes required (ODE45 and uicontrol are base MATLAB). Curve Fitting Toolbox used for polynomial regression in Problem 3.

## Running

1. Ensure `synthetic_truss_293259.mat` is on the MATLAB path (or in the working directory)
2. Run scripts in order: `problem1truss.m` → `problem2_main.m` → `problem_3.m` → `PROBLEM_4.m` → `problem_5.m`
3. Problems 2 and 5 open interactive figure windows — adjust sliders to explore the design or dynamic response space live
4. `truss_solver.m` is a function called internally; do not run it directly

## Notes

All parameters (loads, areas, dynamic coefficients) are candidate-specific (293259). Running on a different machine will produce identical results provided `synthetic_truss_293259.mat` is available. Problem 3 requires the `.mat` file; the other problems are self-contained.
