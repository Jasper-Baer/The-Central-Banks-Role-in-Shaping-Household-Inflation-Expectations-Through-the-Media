function residual = static_resid(T, y, x, params, T_flag)
% function residual = static_resid(T, y, x, params, T_flag)
%
% File created by Dynare Preprocessor from .mod file
%
% Inputs:
%   T         [#temp variables by 1]  double   vector of temporary terms to be filled by function
%   y         [M_.endo_nbr by 1]      double   vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1]       double   vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1]     double   vector of parameter values in declaration order
%                                              to evaluate the model
%   T_flag    boolean                 boolean  flag saying whether or not to calculate temporary terms
%
% Output:
%   residual
%

if T_flag
    T = Gali_base.static_resid_tt(T, y, x, params);
end
residual = zeros(16, 1);
lhs = y(1);
rhs = params(2)*y(1)+T(1)*y(2);
residual(1) = lhs - rhs;
lhs = y(2);
rhs = y(2)+T(2)*(y(7)-y(1)-y(5));
residual(2) = lhs - rhs;
lhs = y(7);
rhs = y(1)*params(7)+y(2)*params(8)+y(11);
residual(3) = lhs - rhs;
residual(4) = y(5);
lhs = y(6);
rhs = y(7)-y(1);
residual(5) = lhs - rhs;
lhs = y(3);
rhs = (1+params(6))/(params(1)+params(6)+(1-params(1))*params(5))*y(12);
residual(6) = lhs - rhs;
lhs = y(2);
rhs = y(4)-y(3);
residual(7) = lhs - rhs;
lhs = y(11);
rhs = y(11)*params(4)+x(2);
residual(8) = lhs - rhs;
lhs = y(12);
rhs = y(12)*params(3)+x(1);
residual(9) = lhs - rhs;
lhs = y(4);
rhs = y(12)+(1-params(1))*y(8);
residual(10) = lhs - rhs;
lhs = y(10);
rhs = y(1)*4;
residual(11) = lhs - rhs;
lhs = y(9);
rhs = y(4)-y(7)*params(9);
residual(12) = lhs - rhs;
lhs = y(14);
rhs = y(7)*4;
residual(13) = lhs - rhs;
lhs = y(13);
rhs = y(6)*4;
residual(14) = lhs - rhs;
lhs = y(15);
rhs = y(5)*4;
residual(15) = lhs - rhs;
lhs = y(16);
rhs = y(1)*4;
residual(16) = lhs - rhs;
if ~isreal(residual)
  residual = real(residual)+imag(residual).^2;
end
end
