var y pi i e_a e_b lambda alpha;
varexo e_a_s e_b_s e_lambda e_alpha;

parameters beta phi_pi phi_y rho_a rho_b rho_lambda rho_alpha kappa;

beta = 0.99;
phi_pi = 1.5;
phi_y = 0.5;
rho_a = 0.9;
rho_b = 0.9;
rho_lambda = 0.9;
rho_alpha = 0.9;
kappa = 0.1;

model;
// IS equation
y = y(-1) + 1/beta*(i(-1) - pi) + e_a;
// Phillips curve with Bayesian learning
pi = beta*(pi(-1) + (1-lambda)*alpha) + kappa*y + e_b;
// Taylor rule
i = phi_pi*pi + phi_y*y;
// Learning dynamics
lambda = rho_lambda*lambda(-1) + e_lambda;
alpha = rho_alpha*alpha(-1) + e_alpha;
// Shocks
e_a = rho_a*e_a(-1) + e_a_s;
e_b = rho_b*e_b(-1) + e_b_s;
end;

initval;
y = 0;
pi = 0;
i = 0;
lambda = 0.5;
alpha = 0;
e_a = 0;
e_b = 0;
end;

shocks;
var e_a_s; stderr 0.01;
var e_b_s; stderr 0.01;
var e_lambda; stderr 0.01;
var e_alpha; stderr 0.01;
end;

stoch_simul(order=1,irf=20);