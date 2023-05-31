function g2 = dynamic_g2(T, y, x, params, steady_state, it_, T_flag)
% function g2 = dynamic_g2(T, y, x, params, steady_state, it_, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T             [#temp variables by 1]     double   vector of temporary terms to be filled by function
%   y             [#dynamic variables by 1]  double   vector of endogenous variables in the order stored
%                                                     in M_.lead_lag_incidence; see the Manual
%   x             [nperiods by M_.exo_nbr]   double   matrix of exogenous variables (in declaration order)
%                                                     for all simulation periods
%   steady_state  [M_.endo_nbr by 1]         double   vector of steady state values
%   params        [M_.param_nbr by 1]        double   vector of parameter values in declaration order
%   it_           scalar                     double   time period for exogenous variables for which
%                                                     to evaluate the model
%   T_flag        boolean                    boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   g2
%

if T_flag
    T = Gali.dynamic_g2_tt(T, y, x, params, steady_state, it_);
end
g2_i = zeros(4,1);
g2_j = zeros(4,1);
g2_v = zeros(4,1);

g2_i(1)=5;
g2_i(2)=5;
g2_i(3)=5;
g2_i(4)=5;
g2_j(1)=801;
g2_j(2)=800;
g2_j(3)=770;
g2_j(4)=769;
g2_v(1)=(-2);
g2_v(2)=2;
g2_v(3)=g2_v(2);
g2_v(4)=(-2);
g2 = sparse(g2_i,g2_j,g2_v,19,961);
end
