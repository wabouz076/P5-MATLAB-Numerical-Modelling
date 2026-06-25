# MATLAB Numerical Modelling Portfolio — Warren Truss and Dynamic Systems

MEng Mechanical Engineering · University of Sussex · H7137 Numerical Modelling  
Software: MATLAB R2021b · Curve Fitting Toolbox

---

Five-problem MATLAB portfolio built around a candidate-specific 7-node, 11-member Warren truss. Problems progress from static matrix analysis through parametric optimisation, experimental calibration, strain energy analysis, and SDOF dynamic simulation. Candidate parameters loaded from `synthetic_truss_293259.mat`.

Applied loads: P1 = 10 kN · P2 = 13 kN · P3 = 17 kN  
Member areas: Bottom chord 870 mm² · Top chord 750 mm² · Diagonals 690 mm²

![Parametric FoS Contour — Problem 2](preview.png)

## Problems

**Problem 1 — Static Truss Solver**  
14×14 equilibrium system assembled via direct stiffness method, solved by LU decomposition. Outputs member forces, nodal displacements, and factors of safety across all 11 members.

**Problem 2 — Parametric Design Tool**  
P1 swept 0–30 kN and P3 swept 0–51 kN across 10,000 load combinations. FoS computed for all 11 members at each point. Live contour maps with interactive uicontrol sliders.

**Problem 3 — Strain Gauge Calibration and Root-Finding**  
Experimental strain data loaded from the `.mat` file. Polynomial regression builds a calibration curve. Secant method locates the load at which FoS = 1.

**Problem 4 — Strain Energy and Castigliano's Theorem**  
Strain energy integrated member-by-member using the trapezoidal rule at 50 points per member. Nodal displacements derived via Castigliano's theorem and verified against Problem 1.

**Problem 5 — SDOF Dynamic Response Simulator**  
m = 1200 kg · k = 4×10⁶ N/m · ζ = 0.05 · P₀ = 10,000 N. Equation of motion solved using ODE45. Live dashboard with sliders for mass, stiffness, damping, and excitation frequency. Resonance detection and DMF output included.

## Tools

MATLAB R2021b · ODE45 · uicontrol · Curve Fitting Toolbox
