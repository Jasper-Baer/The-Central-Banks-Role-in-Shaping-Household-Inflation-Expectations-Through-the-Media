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
    T = SW.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(41, 80);
g1(1,61)=1;
g1(2,31)=(-params(9));
g1(2,38)=(-(1-params(9)));
g1(2,52)=1;
g1(3,30)=1;
g1(3,31)=(-T(3));
g1(4,31)=1;
g1(4,32)=1;
g1(4,37)=(-1);
g1(4,38)=(-1);
g1(5,30)=(-1);
g1(5,32)=1;
g1(5,19)=(-1);
g1(6,33)=(-(1/T(5)*T(15)));
g1(6,4)=(-T(15));
g1(6,35)=1;
g1(6,65)=(-(T(14)*T(15)));
g1(6,55)=(-1);
g1(7,62)=(-((T(11)-(1-params(12)))/T(11)));
g1(7,33)=1;
g1(7,63)=(-((1-params(12))/T(11)));
g1(7,39)=1;
g1(7,53)=(-(1/T(7)));
g1(8,3)=(-(T(6)/(1+T(6))));
g1(8,34)=1;
g1(8,64)=(-(1/(1+T(6))));
g1(8,37)=(-T(16));
g1(8,66)=T(16);
g1(8,39)=T(7);
g1(8,53)=(-1);
g1(9,30)=(-((T(11)-(1-params(12)))*T(13)));
g1(9,34)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(9,35)=(-(T(1)*T(12)*T(13)));
g1(9,36)=1;
g1(9,54)=(-1);
g1(10,32)=(-(params(17)*params(9)));
g1(10,36)=1;
g1(10,37)=(-(params(17)*(1-params(9))));
g1(10,52)=(-params(17));
g1(11,3)=T(9);
g1(11,34)=(-T(8));
g1(11,37)=(-params(22));
g1(11,38)=1;
g1(12,35)=(-T(12));
g1(12,55)=(-(T(5)*T(12)));
g1(12,19)=(-(1-T(12)));
g1(12,59)=1;
g1(13,40)=1;
g1(13,42)=(-params(9));
g1(13,50)=(-(1-params(9)));
g1(13,52)=1;
g1(14,41)=1;
g1(14,42)=(-T(3));
g1(15,42)=1;
g1(15,43)=1;
g1(15,48)=(-1);
g1(15,50)=(-1);
g1(16,41)=(-1);
g1(16,43)=1;
g1(16,20)=(-1);
g1(17,44)=(-(1/T(5)*T(15)));
g1(17,7)=(-T(15));
g1(17,46)=1;
g1(17,70)=(-(T(14)*T(15)));
g1(17,55)=(-1);
g1(18,67)=(-((T(11)-(1-params(12)))/T(11)));
g1(18,44)=1;
g1(18,68)=(-((1-params(12))/T(11)));
g1(18,72)=(-1);
g1(18,51)=1;
g1(18,53)=(-(1/T(7)));
g1(19,6)=(-(T(6)/(1+T(6))));
g1(19,45)=1;
g1(19,69)=(-(1/(1+T(6))));
g1(19,48)=(-T(16));
g1(19,71)=T(16);
g1(19,72)=(-T(7));
g1(19,51)=T(7);
g1(19,53)=(-1);
g1(20,41)=(-((T(11)-(1-params(12)))*T(13)));
g1(20,45)=(-(1-params(39)-T(1)*T(12)*T(13)));
g1(20,46)=(-(T(1)*T(12)*T(13)));
g1(20,47)=1;
g1(20,54)=(-1);
g1(21,43)=(-(params(17)*params(9)));
g1(21,47)=1;
g1(21,48)=(-(params(17)*(1-params(9))));
g1(21,52)=(-params(17));
g1(22,40)=(-(T(17)*T(18)));
g1(22,9)=(-(params(20)*T(17)));
g1(22,49)=1;
g1(22,72)=(-(T(14)*T(17)));
g1(22,57)=(-1);
g1(23,6)=(-(T(19)*(-T(9))));
g1(23,45)=(-(T(8)*T(19)));
g1(23,48)=(-(params(22)*T(19)));
g1(23,9)=(-(params(18)/(1+T(14))));
g1(23,49)=(1+params(18)*T(14))/(1+T(14));
g1(23,72)=(-(T(14)/(1+T(14))));
g1(23,10)=(-T(15));
g1(23,50)=1+T(19);
g1(23,73)=(-(T(14)/(1+T(14))));
g1(23,58)=(-1);
g1(24,5)=(-params(26));
g1(24,36)=(-((-((1-params(28))*params(27)))-params(26)));
g1(24,8)=params(26);
g1(24,47)=(-((1-params(28))*params(27)+params(26)));
g1(24,49)=(-(params(25)*(1-params(28))));
g1(24,11)=(-params(28));
g1(24,51)=1;
g1(24,56)=(-1);
g1(25,12)=(-params(29));
g1(25,52)=1;
g1(25,74)=(-1);
g1(26,13)=(-params(31));
g1(26,53)=1;
g1(26,75)=(-1);
g1(27,14)=(-params(32));
g1(27,54)=1;
g1(27,74)=(-params(2));
g1(27,76)=(-1);
g1(28,15)=(-params(34));
g1(28,55)=1;
g1(28,77)=(-1);
g1(29,16)=(-params(35));
g1(29,56)=1;
g1(29,78)=(-1);
g1(30,2)=params(8);
g1(30,29)=(-1);
g1(30,17)=(-params(36));
g1(30,57)=1;
g1(31,29)=1;
g1(31,79)=(-1);
g1(32,1)=params(7);
g1(32,28)=(-1);
g1(32,18)=(-params(37));
g1(32,58)=1;
g1(33,28)=1;
g1(33,80)=(-1);
g1(34,46)=(-T(12));
g1(34,55)=(-(params(11)*T(4)*T(12)));
g1(34,20)=(-(1-T(12)));
g1(34,60)=1;
g1(35,24)=1;
g1(35,8)=1;
g1(35,47)=(-1);
g1(36,25)=1;
g1(36,6)=1;
g1(36,45)=(-1);
g1(37,26)=1;
g1(37,7)=1;
g1(37,46)=(-1);
g1(38,27)=1;
g1(38,10)=1;
g1(38,50)=(-1);
g1(39,23)=1;
g1(39,49)=(-1);
g1(40,22)=1;
g1(40,51)=(-1);
g1(41,21)=1;
g1(41,48)=(-1);

end
