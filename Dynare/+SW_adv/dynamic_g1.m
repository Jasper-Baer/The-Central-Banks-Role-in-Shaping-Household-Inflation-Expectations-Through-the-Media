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
    T = SW_adv.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(45, 87);
g1(1,33)=(-params(9));
g1(1,40)=(-(1-params(9)));
g1(1,54)=1;
g1(2,32)=1;
g1(2,33)=(-T(3));
g1(3,33)=1;
g1(3,34)=1;
g1(3,39)=(-1);
g1(3,40)=(-1);
g1(4,32)=(-1);
g1(4,34)=1;
g1(4,19)=(-1);
g1(5,35)=(-(1/T(5)*T(15)));
g1(5,4)=(-T(15));
g1(5,37)=1;
g1(5,71)=(-(T(14)*T(15)));
g1(5,57)=(-1);
g1(6,68)=(-((T(11)-(1-params(12)))/T(11)));
g1(6,35)=1;
g1(6,69)=(-((1-params(12))/T(11)));
g1(6,41)=1;
g1(6,55)=(-(1/T(7)));
g1(7,3)=(-(T(6)/(1+T(6))));
g1(7,36)=1;
g1(7,70)=(-(1/(1+T(6))));
g1(7,39)=(-T(16));
g1(7,72)=T(16);
g1(7,41)=T(7);
g1(7,55)=(-1);
g1(8,32)=(-((T(11)-(1-params(12)))*T(13)));
g1(8,36)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(8,37)=(-(T(1)*T(12)*T(13)));
g1(8,38)=1;
g1(8,56)=(-1);
g1(9,34)=(-(params(17)*params(9)));
g1(9,38)=1;
g1(9,39)=(-(params(17)*(1-params(9))));
g1(9,54)=(-params(17));
g1(10,3)=T(9);
g1(10,36)=(-T(8));
g1(10,39)=(-params(22));
g1(10,40)=1;
g1(11,37)=(-T(12));
g1(11,57)=(-(T(5)*T(12)));
g1(11,19)=(-(1-T(12)));
g1(11,61)=1;
g1(12,21)=(-params(43));
g1(12,65)=1;
g1(12,67)=(-1);
g1(13,51)=(-params(40));
g1(13,78)=(-(1-params(40)));
g1(13,63)=1;
g1(13,65)=(-((1-params(40))*(1-params(41))));
g1(14,78)=1;
g1(14,63)=(-1);
g1(14,64)=1;
g1(15,42)=1;
g1(15,44)=(-params(9));
g1(15,52)=(-(1-params(9)));
g1(15,54)=1;
g1(16,43)=1;
g1(16,44)=(-T(3));
g1(17,44)=1;
g1(17,45)=1;
g1(17,50)=(-1);
g1(17,52)=(-1);
g1(18,43)=(-1);
g1(18,45)=1;
g1(18,20)=(-1);
g1(19,46)=(-(1/T(5)*T(15)));
g1(19,7)=(-T(15));
g1(19,48)=1;
g1(19,76)=(-(T(14)*T(15)));
g1(19,57)=(-1);
g1(20,73)=(-((T(11)-(1-params(12)))/T(11)));
g1(20,46)=1;
g1(20,74)=(-((1-params(12))/T(11)));
g1(20,53)=1;
g1(20,55)=(-(1/T(7)));
g1(20,63)=(-1);
g1(21,6)=(-(T(6)/(1+T(6))));
g1(21,47)=1;
g1(21,75)=(-(1/(1+T(6))));
g1(21,50)=(-T(16));
g1(21,77)=T(16);
g1(21,53)=T(7);
g1(21,55)=(-1);
g1(21,63)=(-T(7));
g1(22,43)=(-((T(11)-(1-params(12)))*T(13)));
g1(22,47)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(22,48)=(-(T(1)*T(12)*T(13)));
g1(22,49)=1;
g1(22,56)=(-1);
g1(23,45)=(-(params(17)*params(9)));
g1(23,49)=1;
g1(23,50)=(-(params(17)*(1-params(9))));
g1(23,54)=(-params(17));
g1(24,42)=(-(T(17)*T(18)));
g1(24,9)=(-(params(20)*T(17)));
g1(24,51)=1;
g1(24,59)=(-1);
g1(24,63)=(-(T(14)*T(17)));
g1(25,6)=(-(T(19)*(-T(9))));
g1(25,47)=(-(T(8)*T(19)));
g1(25,50)=(-(params(22)*T(19)));
g1(25,9)=(-(params(18)/(1+T(14))));
g1(25,51)=(1+params(18)*T(14))/(1+T(14));
g1(25,10)=(-T(15));
g1(25,52)=1+T(19);
g1(25,79)=(-(T(14)/(1+T(14))));
g1(25,60)=(-1);
g1(25,63)=(-(T(14)/(1+T(14))));
g1(26,5)=(-params(26));
g1(26,38)=(-((-((1-params(28))*params(27)))-params(26)));
g1(26,8)=params(26);
g1(26,49)=(-((1-params(28))*params(27)+params(26)));
g1(26,51)=(-(params(25)*(1-params(28))));
g1(26,11)=(-params(28));
g1(26,53)=1;
g1(26,58)=(-1);
g1(27,12)=(-params(29));
g1(27,54)=1;
g1(27,80)=(-1);
g1(28,13)=(-params(31));
g1(28,55)=1;
g1(28,81)=(-1);
g1(29,14)=(-params(32));
g1(29,56)=1;
g1(29,80)=(-params(2));
g1(29,82)=(-1);
g1(30,15)=(-params(34));
g1(30,57)=1;
g1(30,83)=(-1);
g1(31,16)=(-params(35));
g1(31,58)=1;
g1(31,84)=(-1);
g1(32,2)=params(8);
g1(32,31)=(-1);
g1(32,17)=(-params(36));
g1(32,59)=1;
g1(33,31)=1;
g1(33,85)=(-1);
g1(34,1)=params(7);
g1(34,30)=(-1);
g1(34,18)=(-params(37));
g1(34,60)=1;
g1(35,30)=1;
g1(35,86)=(-1);
g1(36,48)=(-T(12));
g1(36,57)=(-(params(11)*T(4)*T(12)));
g1(36,20)=(-(1-T(12)));
g1(36,62)=1;
g1(37,22)=(-params(45));
g1(37,67)=1;
g1(37,87)=(-1);
g1(38,26)=1;
g1(38,8)=1;
g1(38,49)=(-1);
g1(39,27)=1;
g1(39,6)=1;
g1(39,47)=(-1);
g1(40,28)=1;
g1(40,7)=1;
g1(40,48)=(-1);
g1(41,29)=1;
g1(41,10)=1;
g1(41,52)=(-1);
g1(42,25)=1;
g1(42,51)=(-1);
g1(43,24)=1;
g1(43,53)=(-1);
g1(44,23)=1;
g1(44,50)=(-1);
g1(45,65)=(-1);
g1(45,66)=1;

end
