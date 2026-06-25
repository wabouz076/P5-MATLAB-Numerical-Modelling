# MATLAB Numerical Modelling Portfolio — Warren Truss and Dynamic Systems

**MEng Mechanical Engineering &nbsp;·&nbsp; University of Sussex &nbsp;·&nbsp; H7137 Numerical Modelling**

![MATLAB](https://img.shields.io/badge/MATLAB-R2021b-orange?style=flat-square)
![Problems](https://img.shields.io/badge/Problems-5-blue?style=flat-square)
![Iterations](https://img.shields.io/badge/Parametric%20Sweep-10%2C000-lightgrey?style=flat-square)
![ODE](https://img.shields.io/badge/ODE%20Solver-ode45-green?style=flat-square)

Five-problem MATLAB portfolio built around a candidate-specific 7-node, 11-member Warren truss. Problems progress from static matrix analysis through parametric optimisation, regression-based calibration, energy methods, and SDOF dynamic simulation. Candidate data loaded from `synthetic_truss_293259.mat`.

**Applied loads:** P1 = 10 kN, P2 = 13 kN, P3 = 17 kN  
**Member areas:** Bottom chord 870 mm² · Top chord 750 mm² · Diagonals 690 mm²

---

## Problem 1 — Static Truss Solver

Direct stiffness method. The 14-DOF equilibrium system (7 nodes × 2 DOF) is assembled into a 14×14 matrix Ax = b and solved via LU decomposition. Outputs member forces, nodal displacements, and factors of safety across all 11 members.

**Scripts:** `problem1truss.m` (main) + `truss_solver.m` (callable function, reused by Problems 2–4)

## Problem 2 — Parametric Design Tool

P1 swept from 0–30 kN and P3 from 0–51 kN across 10,000 load combinations (P2 fixed at 13 kN). Factor of safety computed at each point for all 11 members. Outputs: contour maps of maximum tension and compression FoS over the full design space, with live uicontrol sliders.

**Script:** `problem2_main.m`

## Problem 3 — Strain Gauge Calibration and Root-Finding

Candidate-specific strain gauge data loaded from `synthetic_truss_293259.mat`. Polynomial regression builds a calibration curve (measured microstrain vs. applied load). Secant method root-finding locates the failure load (FoS = 1). Residual analysis included.

**Script:** `problem_3.m`

## Problem 4 — Strain Energy and Castigliano's Theorem

Strain energy computed member-by-member using candidate-specific cross-sectional areas, integrated over 50 discretisation points per member using the trapezoidal rule. Nodal displacements derived via Castigliano's theorem and verified against Problem 1 results.

**Script:** `PROBLEM_4.m`

## Problem 5 — SDOF Dynamic Response Simulator

Candidate parameters: m = 1200 kg, k = 4×10⁶ N/m, ζ = 0.05, P₀ = 10,000 N. Equation of motion integrated using ODE45. Interactive dashboard with sliders for mass, stiffness, damping, and excitation frequency. Resonance detection and dynamic magnification factor (DMF) output included.

**Script:** `problem_5.m`

---

## Running

Run scripts in order: `problem1truss.m` → `problem2_main.m` → `problem_3.m` → `PROBLEM_4.m` → `problem_5.m`

`synthetic_truss_293259.mat` must be in the working directory. `truss_solver.m` is called internally — do not run directly. Problems 2 and 5 open interactive figure windows with live sliders.

## Tools

MATLAB R2021b · ODE45 · uicontrol · Curve Fitting Toolbox (Problem 3)
