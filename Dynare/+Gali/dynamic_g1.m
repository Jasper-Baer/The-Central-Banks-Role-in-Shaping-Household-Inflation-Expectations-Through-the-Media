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
    T = Gali.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(19, 31);
g1(1,6)=(-params(12));
g1(1,23)=1;
g1(1,30)=(-1);
g1(2,7)=(-params(14));
g1(2,26)=(-(1-params(14)));
g1(2,23)=(-((1-params(14))*(y(26)-(y(26)+params(17)))));
g1(2,25)=1;
g1(3,7)=1;
g1(3,8)=(-T(4));
g1(3,25)=(-params(2));
g1(4,8)=1;
g1(4,27)=(-1);
g1(4,11)=T(2);
g1(4,13)=(-T(2));
g1(4,25)=T(2);
g1(5,26)=2*(y(25)-y(26));
g1(5,24)=1;
g1(5,25)=(-(2*(y(25)-y(26))));
g1(6,11)=1;
g1(6,18)=T(3);
g1(6,28)=(-T(3));
g1(7,26)=1;
g1(7,12)=1;
g1(7,13)=(-1);
g1(8,9)=1;
g1(8,18)=(-T(1));
g1(9,8)=1;
g1(9,9)=1;
g1(9,10)=(-1);
g1(10,5)=(-params(3));
g1(10,18)=1;
g1(10,29)=(-1);
g1(11,10)=1;
g1(11,14)=(-(1-params(1)));
g1(11,18)=(-1);
g1(12,7)=(-4);
g1(12,1)=4;
g1(12,10)=(-4);
g1(12,2)=(-(4*params(9)));
g1(12,13)=(-(4*(-params(9))));
g1(12,16)=1;
g1(13,10)=(-1);
g1(13,13)=params(9);
g1(13,15)=1;
g1(14,7)=(-1);
g1(14,3)=1;
g1(14,15)=(-1);
g1(14,17)=1;
g1(15,4)=(-params(4));
g1(15,17)=1;
g1(15,31)=(-1);
g1(16,13)=(-4);
g1(16,20)=1;
g1(17,12)=(-4);
g1(17,19)=1;
g1(18,11)=(-4);
g1(18,21)=1;
g1(19,7)=(-4);
g1(19,22)=1;

end
