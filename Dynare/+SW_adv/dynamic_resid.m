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
    T = SW_adv.dynamic_resid_tt(T, y, x, params, steady_state, it_);
end
residual = zeros(45, 1);
lhs = y(54);
rhs = params(9)*y(33)+(1-params(9))*y(40);
residual(1) = lhs - rhs;
lhs = y(32);
rhs = y(33)*T(3);
residual(2) = lhs - rhs;
lhs = y(33);
rhs = y(40)+y(39)-y(34);
residual(3) = lhs - rhs;
lhs = y(34);
rhs = y(32)+y(19);
residual(4) = lhs - rhs;
lhs = y(37);
rhs = y(57)+T(15)*(y(35)*1/T(5)+y(4)+y(71)*T(14));
residual(5) = lhs - rhs;
lhs = y(35);
rhs = y(55)*1/T(7)-y(41)+y(68)*(T(11)-(1-params(12)))/T(11)+y(69)*(1-params(12))/T(11);
residual(6) = lhs - rhs;
lhs = y(36);
rhs = y(55)+y(3)*T(6)/(1+T(6))+y(70)*1/(1+T(6))+(y(39)-y(72))*T(16)-y(41)*T(7);
residual(7) = lhs - rhs;
lhs = y(38);
rhs = y(56)+y(36)*(1-params(39)-T(1)*T(12)*T(13))+y(37)*T(1)*T(12)*T(13)+y(32)*(T(11)-(1-params(12)))*T(13);
residual(8) = lhs - rhs;
lhs = y(38);
rhs = params(17)*(y(54)+params(9)*y(34)+(1-params(9))*y(39));
residual(9) = lhs - rhs;
lhs = y(40);
rhs = y(39)*params(22)+y(36)*T(8)-y(3)*T(9);
residual(10) = lhs - rhs;
lhs = y(61);
rhs = y(19)*(1-T(12))+y(37)*T(12)+y(57)*T(5)*T(12);
residual(11) = lhs - rhs;
lhs = y(65);
rhs = params(42)+params(43)*y(21)+y(67);
residual(12) = lhs - rhs;
lhs = y(63);
rhs = params(40)*y(51)+(1-params(40))*((1-params(41))*(y(65)+y(78))+params(41)*y(78));
residual(13) = lhs - rhs;
lhs = y(64);
rhs = y(63)-y(78);
residual(14) = lhs - rhs;
lhs = y(42);
rhs = params(9)*y(44)+(1-params(9))*y(52)-y(54);
residual(15) = lhs - rhs;
lhs = y(43);
rhs = T(3)*y(44);
residual(16) = lhs - rhs;
lhs = y(44);
rhs = y(52)+y(50)-y(45);
residual(17) = lhs - rhs;
lhs = y(45);
rhs = y(43)+y(20);
residual(18) = lhs - rhs;
lhs = y(48);
rhs = y(57)+T(15)*(y(46)*1/T(5)+y(7)+y(76)*T(14));
residual(19) = lhs - rhs;
lhs = y(46);
rhs = y(63)-y(53)+y(55)*1/T(7)+y(73)*(T(11)-(1-params(12)))/T(11)+y(74)*(1-params(12))/T(11);
residual(20) = lhs - rhs;
lhs = y(47);
rhs = y(55)+y(6)*T(6)/(1+T(6))+y(75)*1/(1+T(6))+(y(50)-y(77))*T(16)-(y(53)-y(63))*T(7);
residual(21) = lhs - rhs;
lhs = y(49);
rhs = y(56)+y(47)*(1-params(39)-T(1)*T(12)*T(13))+y(48)*T(1)*T(12)*T(13)+y(43)*(T(11)-(1-params(12)))*T(13);
residual(22) = lhs - rhs;
lhs = y(49);
rhs = params(17)*(y(54)+params(9)*y(45)+(1-params(9))*y(50));
residual(23) = lhs - rhs;
lhs = y(51);
rhs = y(59)+T(17)*(params(20)*y(9)+y(63)*T(14)+y(42)*T(18));
residual(24) = lhs - rhs;
lhs = y(52);
rhs = y(60)+y(10)*T(15)+y(79)*T(14)/(1+T(14))+y(9)*params(18)/(1+T(14))-y(51)*(1+params(18)*T(14))/(1+T(14))+y(63)*T(14)/(1+T(14))+(params(22)*y(50)+y(47)*T(8)-y(6)*T(9)-y(52))*T(19);
residual(25) = lhs - rhs;
lhs = y(53);
rhs = y(51)*params(25)*(1-params(28))+(1-params(28))*params(27)*(y(49)-y(38))+params(26)*(y(49)-y(38)-y(8)+y(5))+params(28)*y(11)+y(58);
residual(26) = lhs - rhs;
lhs = y(54);
rhs = params(29)*y(12)+x(it_, 1);
residual(27) = lhs - rhs;
lhs = y(55);
rhs = params(31)*y(13)+x(it_, 2);
residual(28) = lhs - rhs;
lhs = y(56);
rhs = params(32)*y(14)+x(it_, 3)+x(it_, 1)*params(2);
residual(29) = lhs - rhs;
lhs = y(57);
rhs = params(34)*y(15)+x(it_, 4);
residual(30) = lhs - rhs;
lhs = y(58);
rhs = params(35)*y(16)+x(it_, 5);
residual(31) = lhs - rhs;
lhs = y(59);
rhs = params(36)*y(17)+y(31)-params(8)*y(2);
residual(32) = lhs - rhs;
lhs = y(31);
rhs = x(it_, 6);
residual(33) = lhs - rhs;
lhs = y(60);
rhs = params(37)*y(18)+y(30)-params(7)*y(1);
residual(34) = lhs - rhs;
lhs = y(30);
rhs = x(it_, 7);
residual(35) = lhs - rhs;
lhs = y(62);
rhs = y(20)*(1-T(12))+y(48)*T(12)+y(57)*params(11)*T(4)*T(12);
residual(36) = lhs - rhs;
lhs = y(67);
rhs = params(45)*y(22)+x(it_, 8);
residual(37) = lhs - rhs;
lhs = y(26);
rhs = params(38)+y(49)-y(8);
residual(38) = lhs - rhs;
lhs = y(27);
rhs = params(38)+y(47)-y(6);
residual(39) = lhs - rhs;
lhs = y(28);
rhs = params(38)+y(48)-y(7);
residual(40) = lhs - rhs;
lhs = y(29);
rhs = params(38)+y(52)-y(10);
residual(41) = lhs - rhs;
lhs = y(25);
rhs = params(5)+y(51);
residual(42) = lhs - rhs;
lhs = y(24);
rhs = y(53)+100*((1+params(5)/100)/T(10)-1);
residual(43) = lhs - rhs;
lhs = y(23);
rhs = y(50)+params(4);
residual(44) = lhs - rhs;
lhs = y(66);
rhs = y(65)+params(44);
residual(45) = lhs - rhs;

end
