function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
% function g1 = dynamic_g1(T, y, x, params, steady_state, it_, T_flag)
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
%   g1
%

if T_flag
    T = SW_base.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(43, 84);
g1(1,32)=(-params(9));
g1(1,39)=(-(1-params(9)));
g1(1,53)=1;
g1(2,31)=1;
g1(2,32)=(-T(3));
g1(3,32)=1;
g1(3,33)=1;
g1(3,38)=(-1);
g1(3,39)=(-1);
g1(4,31)=(-1);
g1(4,33)=1;
g1(4,19)=(-1);
g1(5,34)=(-(1/T(5)*T(15)));
g1(5,4)=(-T(15));
g1(5,36)=1;
g1(5,68)=(-(T(14)*T(15)));
g1(5,56)=(-1);
g1(6,65)=(-((T(11)-(1-params(12)))/T(11)));
g1(6,34)=1;
g1(6,66)=(-((1-params(12))/T(11)));
g1(6,40)=1;
g1(6,54)=(-(1/T(7)));
g1(7,3)=(-(T(6)/(1+T(6))));
g1(7,35)=1;
g1(7,67)=(-(1/(1+T(6))));
g1(7,38)=(-T(16));
g1(7,69)=T(16);
g1(7,40)=T(7);
g1(7,54)=(-1);
g1(8,31)=(-((T(11)-(1-params(12)))*T(13)));
g1(8,35)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(8,36)=(-(T(1)*T(12)*T(13)));
g1(8,37)=1;
g1(8,55)=(-1);
g1(9,33)=(-(params(17)*params(9)));
g1(9,37)=1;
g1(9,38)=(-(params(17)*(1-params(9))));
g1(9,53)=(-params(17));
g1(10,3)=T(9);
g1(10,35)=(-T(8));
g1(10,38)=(-params(22));
g1(10,39)=1;
g1(11,36)=(-T(12));
g1(11,56)=(-(T(5)*T(12)));
g1(11,19)=(-(1-T(12)));
g1(11,60)=1;
g1(12,21)=(-params(43));
g1(12,64)=1;
g1(12,84)=(-1);
g1(13,50)=(-params(40));
g1(13,75)=(-(1-params(40)));
g1(13,62)=1;
g1(13,64)=(-((1-params(40))*(1-params(41))));
g1(14,75)=1;
g1(14,62)=(-1);
g1(14,63)=1;
g1(15,41)=1;
g1(15,43)=(-params(9));
g1(15,51)=(-(1-params(9)));
g1(15,53)=1;
g1(16,42)=1;
g1(16,43)=(-T(3));
g1(17,43)=1;
g1(17,44)=1;
g1(17,49)=(-1);
g1(17,51)=(-1);
g1(18,42)=(-1);
g1(18,44)=1;
g1(18,20)=(-1);
g1(19,45)=(-(1/T(5)*T(15)));
g1(19,7)=(-T(15));
g1(19,47)=1;
g1(19,73)=(-(T(14)*T(15)));
g1(19,56)=(-1);
g1(20,70)=(-((T(11)-(1-params(12)))/T(11)));
g1(20,45)=1;
g1(20,71)=(-((1-params(12))/T(11)));
g1(20,52)=1;
g1(20,54)=(-(1/T(7)));
g1(20,62)=(-1);
g1(21,6)=(-(T(6)/(1+T(6))));
g1(21,46)=1;
g1(21,72)=(-(1/(1+T(6))));
g1(21,49)=(-T(16));
g1(21,74)=T(16);
g1(21,52)=T(7);
g1(21,54)=(-1);
g1(21,62)=(-T(7));
g1(22,42)=(-((T(11)-(1-params(12)))*T(13)));
g1(22,46)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(22,47)=(-(T(1)*T(12)*T(13)));
g1(22,48)=1;
g1(22,55)=(-1);
g1(23,44)=(-(params(17)*params(9)));
g1(23,48)=1;
g1(23,49)=(-(params(17)*(1-params(9))));
g1(23,53)=(-params(17));
g1(24,41)=(-(T(17)*T(18)));
g1(24,9)=(-(params(20)*T(17)));
g1(24,50)=1;
g1(24,58)=(-1);
g1(24,62)=(-(T(14)*T(17)));
g1(25,6)=(-(T(19)*(-T(9))));
g1(25,46)=(-(T(8)*T(19)));
g1(25,49)=(-(params(22)*T(19)));
g1(25,9)=(-(params(18)/(1+T(14))));
g1(25,50)=(1+params(18)*T(14))/(1+T(14));
g1(25,10)=(-T(15));
g1(25,51)=1+T(19);
g1(25,76)=(-(T(14)/(1+T(14))));
g1(25,59)=(-1);
g1(25,62)=(-(T(14)/(1+T(14))));
g1(26,5)=(-params(26));
g1(26,37)=(-((-((1-params(28))*params(27)))-params(26)));
g1(26,8)=params(26);
g1(26,48)=(-((1-params(28))*params(27)+params(26)));
g1(26,50)=(-(params(25)*(1-params(28))));
g1(26,11)=(-params(28));
g1(26,52)=1;
g1(26,57)=(-1);
g1(27,12)=(-params(29));
g1(27,53)=1;
g1(27,77)=(-1);
g1(28,13)=(-params(31));
g1(28,54)=1;
g1(28,78)=(-1);
g1(29,14)=(-params(32));
g1(29,55)=1;
g1(29,77)=(-params(2));
g1(29,79)=(-1);
g1(30,15)=(-params(34));
g1(30,56)=1;
g1(30,80)=(-1);
g1(31,16)=(-params(35));
g1(31,57)=1;
g1(31,81)=(-1);
g1(32,2)=params(8);
g1(32,30)=(-1);
g1(32,17)=(-params(36));
g1(32,58)=1;
g1(33,30)=1;
g1(33,82)=(-1);
g1(34,1)=params(7);
g1(34,29)=(-1);
g1(34,18)=(-params(37));
g1(34,59)=1;
g1(35,29)=1;
g1(35,83)=(-1);
g1(36,47)=(-T(12));
g1(36,56)=(-(params(11)*T(4)*T(12)));
g1(36,20)=(-(1-T(12)));
g1(36,61)=1;
g1(37,25)=1;
g1(37,8)=1;
g1(37,48)=(-1);
g1(38,26)=1;
g1(38,6)=1;
g1(38,46)=(-1);
g1(39,27)=1;
g1(39,7)=1;
g1(39,47)=(-1);
g1(40,28)=1;
g1(40,10)=1;
g1(40,51)=(-1);
g1(41,24)=1;
g1(41,50)=(-1);
g1(42,23)=1;
g1(42,52)=(-1);
g1(43,22)=1;
g1(43,49)=(-1);

end
