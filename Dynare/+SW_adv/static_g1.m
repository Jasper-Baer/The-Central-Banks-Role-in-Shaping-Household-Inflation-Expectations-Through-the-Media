function g1 = static_g1(T, y, x, params, T_flag)
% function g1 = static_g1(T, y, x, params, T_flag)
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
%   g1
%

if T_flag
    T = SW_adv.static_g1_tt(T, y, x, params);
end
g1 = zeros(45, 45);
g1(1,11)=(-params(9));
g1(1,18)=(-(1-params(9)));
g1(1,32)=1;
g1(2,10)=1;
g1(2,11)=(-T(8));
g1(3,11)=1;
g1(3,12)=1;
g1(3,17)=(-1);
g1(3,18)=(-1);
g1(4,10)=(-1);
g1(4,12)=1;
g1(4,39)=(-1);
g1(5,13)=(-(T(10)*1/T(12)));
g1(5,35)=(-1);
g1(6,11)=(-((T(4)-(1-params(12)))/T(4)));
g1(6,13)=1-(1-params(12))/T(4);
g1(6,19)=1;
g1(6,33)=(-(1/T(14)));
g1(7,14)=T(19);
g1(7,19)=T(14);
g1(7,33)=(-1);
g1(8,10)=(-((T(4)-(1-params(12)))*T(6)));
g1(8,14)=(-(1-params(39)-T(7)));
g1(8,15)=(-T(7));
g1(8,16)=1;
g1(8,34)=(-1);
g1(9,12)=(-(params(17)*params(9)));
g1(9,16)=1;
g1(9,17)=(-(params(17)*(1-params(9))));
g1(9,32)=(-params(17));
g1(10,14)=(-T(20));
g1(10,17)=(-params(22));
g1(10,18)=1;
g1(11,15)=(-T(5));
g1(11,35)=(-(T(5)*T(12)));
g1(11,39)=1-(1-T(5));
g1(12,43)=1-params(43);
g1(12,45)=(-1);
g1(13,29)=(-1);
g1(13,41)=1;
g1(13,43)=(-((1-params(40))*(1-params(41))));
g1(14,29)=1;
g1(14,41)=(-1);
g1(14,42)=1;
g1(15,20)=1;
g1(15,22)=(-params(9));
g1(15,30)=(-(1-params(9)));
g1(15,32)=1;
g1(16,21)=1;
g1(16,22)=(-T(8));
g1(17,22)=1;
g1(17,23)=1;
g1(17,28)=(-1);
g1(17,30)=(-1);
g1(18,21)=(-1);
g1(18,23)=1;
g1(18,40)=(-1);
g1(19,24)=(-(T(10)*1/T(12)));
g1(19,35)=(-1);
g1(20,22)=(-((T(4)-(1-params(12)))/T(4)));
g1(20,24)=1-(1-params(12))/T(4);
g1(20,31)=1;
g1(20,33)=(-(1/T(14)));
g1(20,41)=(-1);
g1(21,25)=T(19);
g1(21,31)=T(14);
g1(21,33)=(-1);
g1(21,41)=(-T(14));
g1(22,21)=(-((T(4)-(1-params(12)))*T(6)));
g1(22,25)=(-(1-params(39)-T(7)));
g1(22,26)=(-T(7));
g1(22,27)=1;
g1(22,34)=(-1);
g1(23,23)=(-(params(17)*params(9)));
g1(23,27)=1;
g1(23,28)=(-(params(17)*(1-params(9))));
g1(23,32)=(-params(17));
g1(24,20)=(-(T(15)*T(16)));
g1(24,29)=1-params(20)*T(15);
g1(24,37)=(-1);
g1(24,41)=(-(T(9)*T(15)));
g1(25,25)=(-(T(18)*T(20)));
g1(25,28)=(-(params(22)*T(18)));
g1(25,29)=(-(params(18)/(1+T(9))-(1+T(9)*params(18))/(1+T(9))));
g1(25,30)=1-(T(10)+T(17)-T(18));
g1(25,38)=(-1);
g1(25,41)=(-T(17));
g1(26,16)=(1-params(28))*params(27);
g1(26,27)=(-((1-params(28))*params(27)));
g1(26,29)=(-(params(25)*(1-params(28))));
g1(26,31)=1-params(28);
g1(26,36)=(-1);
g1(27,32)=1-params(29);
g1(28,33)=1-params(31);
g1(29,34)=1-params(32);
g1(30,35)=1-params(34);
g1(31,36)=1-params(35);
g1(32,9)=(-(1-params(8)));
g1(32,37)=1-params(36);
g1(33,9)=1;
g1(34,8)=(-(1-params(7)));
g1(34,38)=1-params(37);
g1(35,8)=1;
g1(36,26)=(-T(5));
g1(36,35)=(-(params(11)*T(5)*T(11)));
g1(36,40)=1-(1-T(5));
g1(37,45)=1-params(45);
g1(38,4)=1;
g1(39,5)=1;
g1(40,6)=1;
g1(41,7)=1;
g1(42,3)=1;
g1(42,29)=(-1);
g1(43,2)=1;
g1(43,31)=(-1);
g1(44,1)=1;
g1(44,28)=(-1);
g1(45,43)=(-1);
g1(45,44)=1;
if ~isreal(g1)
    g1 = real(g1)+2*imag(g1);
end
end
