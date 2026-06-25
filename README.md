# MATLAB Numerical Modelling Portfolio — Warren Truss and Dynamic Systems

MEng Mechanical Engineering · University of Sussex · H7137 Numerical Modelling  
Software: MATLAB R2021b · Curve Fitting Toolbox

---

Five-problem MATLAB portfolio built around a candidate-specific 7-node, 11-member Warren truss. Problems progress from a static matrix solver through parametric design optimisation, experimental calibration, strain energy analysis, and SDOF dynamic simulation. All candidate parameters are loaded from `synthetic_truss_293259.mat`.

Applied loads: P1 = 10 kN · P2 = 13 kN · P3 = 17 kN  
Member areas: Bottom chord 870 mm² · Top chord 750 mm² · Diagonals 690 mm²

![Parametric FoS Contour — Problem 2](preview.png)

## Problem Breakdown

**Problem 1 — Static Truss Solver**  
14×14 equilibrium system assembled via direct stiffness method, solved by LU decomposition. Outputs member forces, nodal displacements, and factors of safety. The solver function `truss_solver.m` is called by Problems 2, 3, and 4.

**Problem 2 — Parametric Design Tool**  
P1 swept 0–30 kN and P3 swept 0–51 kN across 10,000 combinations (P2 fixed). FoS computed for all 11 members at each combination. Output: live contour maps with uicontrol sliders.

**Problem 3 — Strain Gauge Calibration and Root-Finding**  
Experimental strain data loaded from `.mat` file. Polynomial regression builds a calibration curve. Secant method locates the failure load where FoS = 1.

**Problem 4 — Strain Energy and Castigliano's Theorem**  
Strain energy integrated member-by-member using the trapezoidal rule (50 points per member). Nodal displacements derived via Castigliano's theorem and verified against Problem 1.

**Problem 5 — SDOF Dynamic Response Simulator**  
m = 1200 kg · k = 4×10⁶ N/m · ζ = 0.05 · P₀ = 10,000 N. Equation of motion solved using ODE45. Live dashboard with sliders for mass, stiffness, damping, and excitation frequency. Resonance detection and dynamic magnification factor output.

## Repository

```
P5MATLAB/
├── README.md
├── problem1truss.m
├── truss_solver.m
├── problem2_main.m
├── problem_3.m
├── PROBLEM_4.m
├── problem_5.m
├── synthetic_truss_293259.mat
└── results/
    ├── problem1_member_forces.png
    ├── problem2_FoS_contour.png
    ├── problem3_calibration.png
    ├── problem4_strain_energy.png
    └── problem5_dashboard.png
```

Run scripts in order. `synthetic_truss_293259.mat` must be in the working directory. `truss_solver.m` is a function — do not run directly.

## Tools

MATLAB R2021b · ODE45 · uicontrol · Curve Fitting Toolbox
