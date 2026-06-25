% problem 1 
clc; clear; clearvars;

% define forces 
P1=10;
P2=13;
P3=17; 

% define angles 
s = sin(atan(3/1.5));
c = cos(atan(3/1.5));

% initialise coloumn vector x of Ax=b; 
x = zeros(1,14)';

% plugging in values for A
A=[1,0,0,1,0,0,0,0,c,0,0,0,0,0; 
   0,1,0,0,0,0,0,0,s,0,0,0,0,0;
   0,0,0,-1,1,0,0,0,0,-c,c,0,0,0;
   0,0,0,0,0,0,0,0,0,s,s,0,0,0;
   0,0,0,0,-1,1,0,0,0,0,0,-c,c,0;
   0,0,0,0,0,0,0,0,0,0,0,s,s,0;
   0,0,0,0,0,-1,0,0,0,0,0,0,0,-c;
   0,0,1,0,0,0,0,0,0,0,0,0,0,s;
   0,0,0,0,0,0,1,0,-c,c,0,0,0,0;
   0,0,0,0,0,0,0,0,-s,-s,0,0,0,0;
   0,0,0,0,0,0,-1,1,0,0,-c,c,0,0;
   0,0,0,0,0,0,0,0,0,0,-s,-s,0,0;
   0,0,0,0,0,0,0,-1,0,0,0,0,-c,c;
   0,0,0,0,0,0,0,0,0,0,0,0,-s,-s];

% plugging in values for b 
b=[0;0;0;0;0;0;0;0;0;P1;0;P2;0;P3];

% solve for x using the A\b
 x = A\b;

fprintf(' ___________________________ \n')
fprintf('|  F  |  Value (kN) | State |\n');
fprintf(' ___________________________ \n')

names = ["Rx1 ","Ry1 ","Ry4 ","F1 ","F2 ","F3 ","F4 ","F5 ","F6 ","F7 ","F8 ","F9 ","F10 ","F11 "];
 
 
% determining whether forces are in forces or compression
for j = 1:length(x)

    % First 3 are reactions
    if j <= 3
        type = 'R';
% tension
    elseif x(j) > 0
        type = 'T';
% compression
    elseif x(j) < 0
        type = 'C';

    else
        type = 'Zero force member';
    end

    fprintf('|%5s| %8.2f    |  (%s)  |\n', names(j), abs(x(j)), type)

end
   fprintf(' ___________________________ \n')

Rx1 = x(1);
Ry1 = x(2);
Ry4 = x(3);

% Global equations
sum_Fy = (Ry1 + Ry4) - (P1 + P2 + P3);
sum_Fx = Rx1;
sum_M  = (Ry4*9) - (P1*1.5 + P2*4.5 + P3*7.5);

% Printing the actual sums
fprintf('\nGLOBAL EQUILIBRIUM CHECKS\n');
fprintf('--------------------------------\n');
fprintf('Sum of Fx      = %8.4f kN\n', sum_Fx);
fprintf('Sum of Fy      = %8.4f kN\n', sum_Fy);
fprintf('Sum of Moments = %8.4f kN*m\n', sum_M);
fprintf('--------------------------------\n');

% Sum Fy check
if abs(sum_Fy) < 1e-6 && abs(sum_Fx) < 1e-6 && abs(sum_M) < 1e-6
    fprintf('Global Checks → PASS\n');
else
    fprintf('Global Checks → FAIL\n');
end


fprintf('--------------------------------\n');
