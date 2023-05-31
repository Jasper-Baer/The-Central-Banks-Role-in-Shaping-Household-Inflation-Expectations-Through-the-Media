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
    T = SW.static_g1_tt(T, y, x, params);
end
g1 = zeros(41, 41);
g1(1,41)=1;
g1(2,11)=(-params(9));
g1(2,18)=(-(1-params(9)));
g1(2,32)=1;
g1(3,10)=1;
g1(3,11)=(-T(8));
g1(4,11)=1;
g1(4,12)=1;
g1(4,17)=(-1);
g1(4,18)=(-1);
g1(5,10)=(-1);
g1(5,12)=1;
g1(5,39)=(-1);
g1(6,13)=(-(T(10)*1/T(12)));
g1(6,35)=(-1);
g1(7,11)=(-((T(4)-(1-params(12)))/T(4)));
g1(7,13)=1-(1-params(12))/T(4);
g1(7,19)=1;
g1(7,33)=(-(1/T(14)));
g1(8,14)=T(18);
g1(8,19)=T(14);
g1(8,33)=(-1);
g1(9,10)=(-((T(4)-(1-params(12)))*T(6)));
g1(9,14)=(-(1-params(39)-T(7)));
g1(9,15)=(-T(7));
g1(9,16)=1;
g1(9,34)=(-1);
g1(10,12)=(-(params(17)*params(9)));
g1(10,16)=1;
g1(10,17)=(-(params(17)*(1-params(9))));
g1(10,32)=(-params(17));
g1(11,14)=(-T(19));
g1(11,17)=(-params(22));
g1(11,18)=1;
g1(12,15)=(-T(5));
g1(12,35)=(-(T(5)*T(12)));
g1(12,39)=1-(1-T(5));
g1(13,20)=1;
g1(13,22)=(-params(9));
g1(13,30)=(-(1-params(9)));
g1(13,32)=1;
g1(14,21)=1;
g1(14,22)=(-T(8));
g1(15,22)=1;
g1(15,23)=1;
g1(15,28)=(-1);
g1(15,30)=(-1);
g1(16,21)=(-1);
g1(16,23)=1;
g1(16,40)=(-1);
g1(17,24)=(-(T(10)*1/T(12)));
g1(17,35)=(-1);
g1(18,22)=(-((T(4)-(1-params(12)))/T(4)));
g1(18,24)=1-(1-params(12))/T(4);
g1(18,29)=(-1);
g1(18,31)=1;
g1(18,33)=(-(1/T(14)));
g1(19,25)=T(18);
g1(19,29)=(-T(14));
g1(19,31)=T(14);
g1(19,33)=(-1);
g1(20,21)=(-((T(4)-(1-params(12)))*T(6)));
g1(20,25)=(-(1-params(39)-T(7)));
g1(20,26)=(-T(7));
g1(20,27)=1;
g1(20,34)=(-1);
g1(21,23)=(-(params(17)*params(9)));
g1(21,27)=1;
g1(21,28)=(-(params(17)*(1-params(9))));
g1(21,32)=(-params(17));
g1(22,20)=(-(1/(1+T(9)*params(20))*T(15)));
g1(22,29)=1-1/(1+T(9)*params(20))*(T(9)+params(20));
g1(22,37)=(-1);
g1(23,25)=(-(T(17)*T(19)));
g1(23,28)=(-(params(22)*T(17)));
g1(23,29)=(-(T(16)+params(18)/(1+T(9))-(1+T(9)*params(18))/(1+T(9))));
g1(23,30)=1-(T(10)+T(16)-T(17));
g1(23,38)=(-1);
g1(24,16)=(1-params(28))*params(27);
g1(24,27)=(-((1-params(28))*params(27)));
g1(24,29)=(-(params(25)*(1-params(28))));
g1(24,31)=1-params(28);
g1(24,36)=(-1);
g1(25,32)=1-params(29);
g1(26,33)=1-params(31);
g1(27,34)=1-params(32);
g1(28,35)=1-params(34);
g1(29,36)=1-params(35);
g1(30,9)=(-(1-params(8)));
g1(30,37)=1-params(36);
g1(31,9)=1;
g1(32,8)=(-(1-params(7)));
g1(32,38)=1-params(37);
g1(33,8)=1;
g1(34,26)=(-T(5));
g1(34,35)=(-(params(11)*T(5)*T(11)));
g1(34,40)=1-(1-T(5));
g1(35,4)=1;
g1(36,5)=1;
g1(37,6)=1;
g1(38,7)=1;
g1(39,3)=1;
g1(39,29)=(-1);
g1(40,2)=1;
g1(40,31)=(-1);
g1(41,1)=1;
g1(41,28)=(-1);
if ~isreal(g1)
    g1 = real(g1)+2*imag(g1);
end
end
