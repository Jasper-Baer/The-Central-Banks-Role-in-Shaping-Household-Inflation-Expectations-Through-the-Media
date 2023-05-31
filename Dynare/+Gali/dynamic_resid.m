function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
% function residual = dynamic_resid(T, y, x, params, steady_state, it_, T_flag)
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
%   residual
%

if T_flag
    T = Gali.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(19, 1);
lhs = y(23);
rhs = params(18)+params(12)*y(6)+x(it_, 2);
residual(1) = lhs - rhs;
lhs = y(25);
rhs = params(14)*y(7)+(1-params(14))*((1-y(23))*(y(26)+params(17))+y(23)*y(26));
residual(2) = lhs - rhs;
lhs = y(7);
rhs = params(2)*y(25)+y(8)*T(4);
residual(3) = lhs - rhs;
lhs = y(8);
rhs = T(2)*(y(13)-y(25)-y(11))+y(27);
residual(4) = lhs - rhs;
lhs = y(24);
rhs = (y(25)-y(26))^2;
residual(5) = lhs - rhs;
lhs = y(11);
rhs = (y(28)-y(18))*T(3);
residual(6) = lhs - rhs;
lhs = y(12);
rhs = y(13)-y(26);
residual(7) = lhs - rhs;
lhs = y(9);
rhs = T(1)*y(18);
residual(8) = lhs - rhs;
lhs = y(8);
rhs = y(10)-y(9);
residual(9) = lhs - rhs;
lhs = y(18);
rhs = params(3)*y(5)+x(it_, 1);
residual(10) = lhs - rhs;
lhs = y(10);
rhs = y(18)+(1-params(1))*y(14);
residual(11) = lhs - rhs;
lhs = y(16);
rhs = 4*(y(7)+y(10)-y(1)-params(9)*(y(13)-y(2)));
residual(12) = lhs - rhs;
lhs = y(15);
rhs = y(10)-y(13)*params(9);
residual(13) = lhs - rhs;
lhs = y(17);
rhs = y(7)+y(15)-y(3);
residual(14) = lhs - rhs;
lhs = y(17);
rhs = params(4)*y(4)+x(it_, 3);
residual(15) = lhs - rhs;
lhs = y(20);
rhs = y(13)*4;
residual(16) = lhs - rhs;
lhs = y(19);
rhs = y(12)*4;
residual(17) = lhs - rhs;
lhs = y(21);
rhs = y(11)*4;
residual(18) = lhs - rhs;
lhs = y(22);
rhs = y(7)*4;
residual(19) = lhs - rhs;

end
