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
    T = Gali_base.dynamic_g1_tt(T, y, x, params, steady_state, it_);
end
g1 = zeros(16, 25);
g1(1,5)=1;
g1(1,21)=(-params(2));
g1(1,6)=(-T(4));
g1(2,21)=T(2);
g1(2,6)=1;
g1(2,22)=(-1);
g1(2,9)=T(2);
g1(2,11)=(-T(2));
g1(3,5)=(-params(7));
g1(3,6)=(-params(8));
g1(3,11)=1;
g1(3,15)=(-1);
g1(4,9)=1;
g1(4,16)=T(3);
g1(4,23)=(-T(3));
g1(5,21)=1;
g1(5,10)=1;
g1(5,11)=(-1);
g1(6,7)=1;
g1(6,16)=(-T(1));
g1(7,6)=1;
g1(7,7)=1;
g1(7,8)=(-1);
g1(8,3)=(-params(4));
g1(8,15)=1;
g1(8,25)=(-1);
g1(9,4)=(-params(3));
g1(9,16)=1;
g1(9,24)=(-1);
g1(10,8)=1;
g1(10,12)=(-(1-params(1)));
g1(10,16)=(-1);
g1(11,5)=(-4);
g1(11,1)=4;
g1(11,8)=(-4);
g1(11,2)=(-(4*params(9)));
g1(11,11)=(-(4*(-params(9))));
g1(11,14)=1;
g1(12,8)=(-1);
g1(12,11)=params(9);
g1(12,13)=1;
g1(13,11)=(-4);
g1(13,18)=1;
g1(14,10)=(-4);
g1(14,17)=1;
g1(15,9)=(-4);
g1(15,19)=1;
g1(16,5)=(-4);
g1(16,20)=1;

end
