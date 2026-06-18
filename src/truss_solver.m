function [x] = truss_solver(P1, P2, P3)
  
    % Geometry constants 
    theta = atan(3/1.5); 
    s = sin(theta);
    c = cos(theta);

    % Matrix A: Equilibrium equations for the 7 nodes 
    % Columns: [Rx1, Ry1, Ry4, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11]
    A = [1,0,0, 1,0,0, 0,0, c, 0, 0, 0, 0, 0;  
         0,1,0, 0,0,0, 0,0, s, 0, 0, 0, 0, 0;  
         0,0,0,-1,1,0, 0,0, 0,-c, c, 0, 0, 0;  
         0,0,0, 0,0,0, 0,0, 0, s, s, 0, 0, 0;  
         0,0,0, 0,-1,1,0,0, 0, 0, 0,-c, c, 0;  
         0,0,0, 0,0,0, 0,0, 0, 0, 0, s, s, 0;  
         0,0,0, 0,0,-1,0,0, 0, 0, 0, 0, 0,-c;  
         0,0,1, 0,0,0, 0,0, 0, 0, 0, 0, 0, s; 
         0,0,0, 0,0,0, 1,0,-c, c, 0, 0, 0, 0;  
         0,0,0, 0,0,0, 0,0,-s,-s, 0, 0, 0, 0;  
         0,0,0, 0,0,0,-1,1, 0, 0,-c, c, 0, 0;  
         0,0,0, 0,0,0, 0,0, 0, 0,-s,-s, 0, 0;  
         0,0,0, 0,0,0, 0,-1,0, 0, 0, 0,-c, c;  
         0,0,0, 0,0,0, 0,0, 0, 0, 0, 0,-s,-s]; 

    % Load vector 
    b = zeros(14,1);
    b(10) = P1; b(12) = P2; b(14) = P3;

    % Solver: Using the Gauss elimination
    x = A\b; 
end