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
    T = Gali.static_g1_tt(T, y, x, params);
end
g1 = zeros(19, 19);
g1(1,17)=1-params(12);
g1(2,1)=(-1);
g1(2,17)=(-((1-params(14))*(y(1)-(y(1)+params(17)))));
g1(2,19)=1;
g1(3,1)=1;
g1(3,2)=(-T(1));
g1(3,19)=(-params(2));
g1(4,5)=T(2);
g1(4,7)=(-T(2));
g1(4,19)=T(2);
g1(5,1)=2*(y(19)-y(1));
g1(5,18)=1;
g1(5,19)=(-(2*(y(19)-y(1))));
g1(6,5)=1;
g1(7,1)=1;
g1(7,6)=1;
g1(7,7)=(-1);
g1(8,3)=1;
g1(8,12)=(-((1+params(6))/(params(1)+params(6)+(1-params(1))*params(5))));
g1(9,2)=1;
g1(9,3)=1;
g1(9,4)=(-1);
g1(10,12)=1-params(3);
g1(11,4)=1;
g1(11,8)=(-(1-params(1)));
g1(11,12)=(-1);
g1(12,1)=(-4);
g1(12,10)=1;
g1(13,4)=(-1);
g1(13,7)=params(9);
g1(13,9)=1;
g1(14,1)=(-1);
g1(14,11)=1;
g1(15,11)=1-params(4);
g1(16,7)=(-4);
g1(16,14)=1;
g1(17,6)=(-4);
g1(17,13)=1;
g1(18,5)=(-4);
g1(18,15)=1;
g1(19,1)=(-4);
g1(19,16)=1;
if ~isreal(g1)
    g1 = real(g1)+2*imag(g1);
end
end
