%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'Gali';
M_.dynare_version = '5.4';
oo_.dynare_version = '5.4';
options_.dynare_version = '5.4';
%
% Some global variables initialization
%
global_initialization;
M_.exo_names = cell(3,1);
M_.exo_names_tex = cell(3,1);
M_.exo_names_long = cell(3,1);
M_.exo_names(1) = {'eps_a'};
M_.exo_names_tex(1) = {'{\varepsilon_a}'};
M_.exo_names_long(1) = {'technology shock'};
M_.exo_names(2) = {'eps_lambda'};
M_.exo_names_tex(2) = {'eps\_lambda'};
M_.exo_names_long(2) = {'eps_lambda'};
M_.exo_names(3) = {'eps_m'};
M_.exo_names_tex(3) = {'{\varepsilon_\m}'};
M_.exo_names_long(3) = {'money growth rate shock'};
M_.endo_names = cell(19,1);
M_.endo_names_tex = cell(19,1);
M_.endo_names_long = cell(19,1);
M_.endo_names(1) = {'pi'};
M_.endo_names_tex(1) = {'{\pi}'};
M_.endo_names_long(1) = {'inflation'};
M_.endo_names(2) = {'y_gap'};
M_.endo_names_tex(2) = {'{\tilde y}'};
M_.endo_names_long(2) = {'output gap'};
M_.endo_names(3) = {'y_nat'};
M_.endo_names_tex(3) = {'{y^{nat}}'};
M_.endo_names_long(3) = {'natural output'};
M_.endo_names(4) = {'y'};
M_.endo_names_tex(4) = {'{y}'};
M_.endo_names_long(4) = {'output'};
M_.endo_names(5) = {'r_nat'};
M_.endo_names_tex(5) = {'{r^{nat}}'};
M_.endo_names_long(5) = {'natural interest rate'};
M_.endo_names(6) = {'r_real'};
M_.endo_names_tex(6) = {'{r^r}'};
M_.endo_names_long(6) = {'//real interest rate'};
M_.endo_names(7) = {'i'};
M_.endo_names_tex(7) = {'{i}'};
M_.endo_names_long(7) = {'nominal interrst rate'};
M_.endo_names(8) = {'n'};
M_.endo_names_tex(8) = {'{n}'};
M_.endo_names_long(8) = {'hours worked'};
M_.endo_names(9) = {'m_real'};
M_.endo_names_tex(9) = {'{m-p}'};
M_.endo_names_long(9) = {'real money stock'};
M_.endo_names(10) = {'m_growth_ann'};
M_.endo_names_tex(10) = {'{\Delta m}'};
M_.endo_names_long(10) = {'money growth annualized'};
M_.endo_names(11) = {'money_growth'};
M_.endo_names_tex(11) = {'{\Delta m_q}'};
M_.endo_names_long(11) = {'money growth'};
M_.endo_names(12) = {'a'};
M_.endo_names_tex(12) = {'{a}'};
M_.endo_names_long(12) = {'AR(1) technology shock process'};
M_.endo_names(13) = {'r_real_ann'};
M_.endo_names_tex(13) = {'{r^{r,ann}}'};
M_.endo_names_long(13) = {'annualized real interest rate'};
M_.endo_names(14) = {'i_ann'};
M_.endo_names_tex(14) = {'{i^{ann}}'};
M_.endo_names_long(14) = {'annualized nominal interest rate'};
M_.endo_names(15) = {'r_nat_ann'};
M_.endo_names_tex(15) = {'{r^{nat,ann}}'};
M_.endo_names_long(15) = {'annualized natural interest rate'};
M_.endo_names(16) = {'pi_ann'};
M_.endo_names_tex(16) = {'{\pi^{ann}}'};
M_.endo_names_long(16) = {'annualized inflation rate'};
M_.endo_names(17) = {'lam'};
M_.endo_names_tex(17) = {'lam'};
M_.endo_names_long(17) = {'lam'};
M_.endo_names(18) = {'Bias'};
M_.endo_names_tex(18) = {'Bias'};
M_.endo_names_long(18) = {'Bias'};
M_.endo_names(19) = {'Exp_pi'};
M_.endo_names_tex(19) = {'Exp\_pi'};
M_.endo_names_long(19) = {'Exp_pi'};
M_.endo_partitions = struct();
M_.param_names = cell(18,1);
M_.param_names_tex = cell(18,1);
M_.param_names_long = cell(18,1);
M_.param_names(1) = {'alppha'};
M_.param_names_tex(1) = {'{\alppha}'};
M_.param_names_long(1) = {'capital share'};
M_.param_names(2) = {'betta'};
M_.param_names_tex(2) = {'{\beta}'};
M_.param_names_long(2) = {'discount factor'};
M_.param_names(3) = {'rho_a'};
M_.param_names_tex(3) = {'{\rho_a}'};
M_.param_names_long(3) = {'autocorrelation technology shock'};
M_.param_names(4) = {'rho_m'};
M_.param_names_tex(4) = {'{\rho_{m}}'};
M_.param_names_long(4) = {'autocorrelation monetary growth rate shock'};
M_.param_names(5) = {'siggma'};
M_.param_names_tex(5) = {'{\sigma}'};
M_.param_names_long(5) = {'log utility'};
M_.param_names(6) = {'phi'};
M_.param_names_tex(6) = {'{\phi}'};
M_.param_names_long(6) = {'unitary Frisch elasticity'};
M_.param_names(7) = {'phi_pi'};
M_.param_names_tex(7) = {'{\phi_{\pi}}'};
M_.param_names_long(7) = {'inflation feedback Taylor Rule'};
M_.param_names(8) = {'phi_y'};
M_.param_names_tex(8) = {'{\phi_{y}}'};
M_.param_names_long(8) = {'output feedback Taylor Rule'};
M_.param_names(9) = {'eta'};
M_.param_names_tex(9) = {'{\eta}'};
M_.param_names_long(9) = {'semi-elasticity of money demand'};
M_.param_names(10) = {'epsilon'};
M_.param_names_tex(10) = {'{\epsilon}'};
M_.param_names_long(10) = {'demand elasticity'};
M_.param_names(11) = {'theta'};
M_.param_names_tex(11) = {'{\theta}'};
M_.param_names_long(11) = {'Calvo parameter'};
M_.param_names(12) = {'rho_lambda'};
M_.param_names_tex(12) = {'rho\_lambda'};
M_.param_names_long(12) = {'rho_lambda'};
M_.param_names(13) = {'rho_alpha'};
M_.param_names_tex(13) = {'rho\_alpha'};
M_.param_names_long(13) = {'rho_alpha'};
M_.param_names(14) = {'rho'};
M_.param_names_tex(14) = {'rho'};
M_.param_names_long(14) = {'rho'};
M_.param_names(15) = {'bet_lam'};
M_.param_names_tex(15) = {'bet\_lam'};
M_.param_names_long(15) = {'bet_lam'};
M_.param_names(16) = {'bet_alpha'};
M_.param_names_tex(16) = {'bet\_alpha'};
M_.param_names_long(16) = {'bet_alpha'};
M_.param_names(17) = {'alpha'};
M_.param_names_tex(17) = {'alpha'};
M_.param_names_long(17) = {'alpha'};
M_.param_names(18) = {'lam_int'};
M_.param_names_tex(18) = {'lam\_int'};
M_.param_names_long(18) = {'lam_int'};
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 19;
M_.param_nbr = 18;
M_.orig_endo_nbr = 19;
M_.aux_vars = [];
M_ = setup_solvers(M_);
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = true;
M_.det_shocks = [];
M_.surprise_shocks = [];
M_.heteroskedastic_shocks.Qvalue_orig = [];
M_.heteroskedastic_shocks.Qscale_orig = [];
options_.linear = false;
options_.block = false;
options_.bytecode = false;
options_.use_dll = false;
M_.nonzero_hessian_eqs = 5;
M_.hessian_eq_zero = isempty(M_.nonzero_hessian_eqs);
M_.orig_eq_nbr = 19;
M_.eq_nbr = 19;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./+' M_.fname '/set_auxiliary_variables.m'], 'file') == 2;
M_.epilogue_names = {};
M_.epilogue_var_list_ = {};
M_.orig_maximum_endo_lag = 1;
M_.orig_maximum_endo_lead = 1;
M_.orig_maximum_exo_lag = 0;
M_.orig_maximum_exo_lead = 0;
M_.orig_maximum_exo_det_lag = 0;
M_.orig_maximum_exo_det_lead = 0;
M_.orig_maximum_lag = 1;
M_.orig_maximum_lead = 1;
M_.orig_maximum_lag_with_diffs_expanded = 1;
M_.lead_lag_incidence = [
 0 7 26;
 0 8 27;
 0 9 0;
 1 10 0;
 0 11 0;
 0 12 0;
 2 13 0;
 0 14 0;
 3 15 0;
 0 16 0;
 4 17 0;
 5 18 28;
 0 19 0;
 0 20 0;
 0 21 0;
 0 22 0;
 6 23 0;
 0 24 0;
 0 25 0;]';
M_.nstatic = 11;
M_.nfwrd   = 2;
M_.npred   = 5;
M_.nboth   = 1;
M_.nsfwrd   = 3;
M_.nspred   = 6;
M_.ndynamic   = 8;
M_.dynamic_tmp_nbr = [4; 0; 0; 0; ];
M_.model_local_variables_dynamic_tt_idxs = {
};
M_.equations_tags = {
  1 , 'name' , 'lam' ;
  2 , 'name' , 'Exp_pi' ;
  3 , 'name' , 'pi' ;
  4 , 'name' , 'y_gap' ;
  5 , 'name' , 'Bias' ;
  6 , 'name' , 'r_nat' ;
  7 , 'name' , 'r_real' ;
  8 , 'name' , 'y_nat' ;
  9 , 'name' , '9' ;
  10 , 'name' , 'a' ;
  11 , 'name' , 'y' ;
  12 , 'name' , 'm_growth_ann' ;
  13 , 'name' , 'm_real' ;
  14 , 'name' , 'money_growth' ;
  15 , 'name' , '15' ;
  16 , 'name' , 'i_ann' ;
  17 , 'name' , 'r_real_ann' ;
  18 , 'name' , 'r_nat_ann' ;
  19 , 'name' , 'pi_ann' ;
};
M_.mapping.pi.eqidx = [2 3 5 7 12 14 19 ];
M_.mapping.y_gap.eqidx = [3 4 9 ];
M_.mapping.y_nat.eqidx = [8 9 ];
M_.mapping.y.eqidx = [9 11 12 13 ];
M_.mapping.r_nat.eqidx = [4 6 18 ];
M_.mapping.r_real.eqidx = [7 17 ];
M_.mapping.i.eqidx = [4 7 12 13 16 ];
M_.mapping.n.eqidx = [11 ];
M_.mapping.m_real.eqidx = [13 14 ];
M_.mapping.m_growth_ann.eqidx = [12 ];
M_.mapping.money_growth.eqidx = [14 15 ];
M_.mapping.a.eqidx = [6 8 10 11 ];
M_.mapping.r_real_ann.eqidx = [17 ];
M_.mapping.i_ann.eqidx = [16 ];
M_.mapping.r_nat_ann.eqidx = [18 ];
M_.mapping.pi_ann.eqidx = [19 ];
M_.mapping.lam.eqidx = [1 2 ];
M_.mapping.Bias.eqidx = [5 ];
M_.mapping.Exp_pi.eqidx = [2 3 4 5 ];
M_.mapping.eps_a.eqidx = [10 ];
M_.mapping.eps_lambda.eqidx = [1 ];
M_.mapping.eps_m.eqidx = [15 ];
M_.static_and_dynamic_models_differ = false;
M_.has_external_function = false;
M_.state_var = [4 7 9 11 12 17 ];
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(19, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(18, 1);
M_.endo_trends = struct('deflator', cell(19, 1), 'log_deflator', cell(19, 1), 'growth_factor', cell(19, 1), 'log_growth_factor', cell(19, 1));
M_.NNZDerivatives = [59; 4; -1; ];
M_.static_tmp_nbr = [2; 0; 0; 0; ];
M_.model_local_variables_static_tt_idxs = {
};
M_.params(5) = 1;
siggma = M_.params(5);
M_.params(6) = 1;
phi = M_.params(6);
M_.params(7) = 1.5;
phi_pi = M_.params(7);
M_.params(8) = 0.125;
phi_y = M_.params(8);
M_.params(11) = 0.6666666666666666;
theta = M_.params(11);
M_.params(4) = 0.5;
rho_m = M_.params(4);
M_.params(3) = 0.9;
rho_a = M_.params(3);
M_.params(2) = 0.99;
betta = M_.params(2);
M_.params(9) = 4;
eta = M_.params(9);
M_.params(1) = 0.3333333333333333;
alppha = M_.params(1);
M_.params(10) = 6;
epsilon = M_.params(10);
M_.params(14) = 0.7;
rho = M_.params(14);
M_.params(12) = 0.4;
rho_lambda = M_.params(12);
M_.params(13) = 0.76;
rho_alpha = M_.params(13);
M_.params(16) = 0.5;
bet_alpha = M_.params(16);
M_.params(15) = 0.5;
bet_lam = M_.params(15);
M_.params(17) = 0.5;
alpha = M_.params(17);
M_.params(18) = 0.02;
lam_int = M_.params(18);
alpha_int = -0.01;
%
% INITVAL instructions
%
options_.initval_file = false;
oo_.steady_state(17) = 0.5;
if M_.exo_nbr > 0
	oo_.exo_simul = ones(M_.maximum_lag,1)*oo_.exo_steady_state';
end
if M_.exo_det_nbr > 0
	oo_.exo_det_simul = ones(M_.maximum_lag,1)*oo_.exo_det_steady_state';
end
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(2, 2) = 0.0625;
resid;
steady;
oo_.dr.eigval = check(M_,options_,oo_);
model_diagnostics(M_,options_,oo_);
options_.impulse_responses.plot_threshold = 0;
options_.irf = 15;
options_.order = 2;
var_list_ = {'y_gap';'pi_ann';'i_ann';'r_real_ann';'m_real';'money_growth';'Bias';'Exp_pi'};
[info, oo_, options_, M_] = stoch_simul(M_, options_, oo_, var_list_);
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(3, 3) = 0;


oo_.time = toc(tic0);
disp(['Total computing time : ' dynsec2hms(oo_.time) ]);
if ~exist([M_.dname filesep 'Output'],'dir')
    mkdir(M_.dname,'Output');
end
save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save([M_.dname filesep 'Output' filesep 'Gali_results.mat'], 'oo_recursive_', '-append');
end
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
