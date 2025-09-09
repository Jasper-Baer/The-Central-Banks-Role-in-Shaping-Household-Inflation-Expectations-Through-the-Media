################################################################################
# Libraries
################################################################################
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("stargazer")
library('car')
library("tseries")

################################################################################
# Data Loading and Preparation
################################################################################
# !!! IMPORTANT: Replace this with the correct path to your Excel file.
data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)

data <- data[12:(nrow(data)), ]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

numeric_columns <- sapply(data, is.numeric)
dont_scale_names = c("draghi", "negative", "trichet", "whatever", "Unmon")
numeric_columns[dont_scale_names] <- FALSE
data[numeric_columns] <- scale(data[numeric_columns])

canonize_ecb_pc <- function(df, use_diffs_infeco = FALSE, use_diffs_mp = FALSE) {
  pick <- function(level, diff, use) if (use) diff else level
  df[["ECB.PC.Inflation.Inc."]] <- df[[ pick("ECB.PC.Inflation.Inc.", "ECB.PC.Inflation.Inc..difference", use_diffs_infeco) ]]
  df[["ECB.PC.Inflation.Dec."]] <- df[[ pick("ECB.PC.Inflation.Dec.", "ECB.PC.Inflation.Dec..difference", use_diffs_infeco) ]]
  df[["ECB.PC.Outlook.Up"]]     <- df[[ pick("ECB.PC.Outlook.Up",     "ECB.PC.Outlook.Up.difference",     use_diffs_infeco) ]]
  df[["ECB.PC.Outlook.Down"]]   <- df[[ pick("ECB.PC.Outlook.Down",   "ECB.PC.Outlook.Down.difference",   use_diffs_infeco) ]]
  df[["ECB.PC.Monetary.Haw."]]  <- df[[ pick("ECB.PC.Monetary.Haw.",  "ECB.PC.Monetary.Haw..difference",  use_diffs_mp) ]]
  df[["ECB.PC.Monetary.Dov."]]  <- df[[ pick("ECB.PC.Monetary.Dov.",  "ECB.PC.Monetary.Dov..difference",  use_diffs_mp) ]]
  df
}

################################################################################
# Helper Functions for LaTeX Table Generation
################################################################################

make_var_labels <- function(use_diffs_infeco, use_diffs_mp) {
  v <- c(
    "ECB.PC.Inflation.Inc." = "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$",
    "ECB.PC.Inflation.Dec." = "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$",
    "ECB.PC.Outlook.Up"     = "$\\mathrm{ECB \\ Economy_t^{Increasing}}$",
    "ECB.PC.Outlook.Down"   = "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$",
    "ECB.PC.Monetary.Haw."  = "$\\mathrm{ECB \\ MP_t^{Hawkish}}$",
    "ECB.PC.Monetary.Dov."  = "$\\mathrm{ECB \\ MP_t^{Dovish}}$",
    "German.Inflation.Year.on.Year.difference" = "$\\Delta$HICP inflation",
    "Reuter.Poll.Forecast.difference"          = "$\\Delta$Prof. inflation forecast",
    "German.Industrial.Production.Gap" = "Output Gap",
    "Germany.Unemployment.difference"  = "$\\Delta$ Unemployment Rate",
    "Germany.Future.Un.difference"     = "$\\Delta$ Unemployment Expectations",
    "Germany.Future.Fin.difference"    = "$\\Delta$ Financial Expectations",
    "Germany.Future.Eco"               = "Economic Expectations",
    "ECB.MRO.difference"               = "$\\Delta$ MRO rate",
    "whatever"                         = "Whatever it Takes",
    "negative"                         = "Negative Rate",
    "ECB.MRO.POS"                      = "Positive Interest Surprise",
    "ECB.MRO.NEG"                      = "Negative Interest Surprise",
    "Unmon"                            = "Unconventional MP",
    "DAX.difference"                   = "$\\Delta$ DAX",
    "VDAX"                             = "VDAX",
    "ED.Exchange.Rate.difference"      = "$\\Delta$ EURUSD",
    "(Intercept)"                      = "Constant"
  )
  if (use_diffs_infeco) {
    v[["ECB.PC.Inflation.Inc."]] <- "$\\Delta\\,\\mathrm{ECB \\ Inflation_t^{Increasing}}$"
    v[["ECB.PC.Inflation.Dec."]] <- "$\\Delta\\,\\mathrm{ECB \\ Inflation_t^{Decreasing}}$"
    v[["ECB.PC.Outlook.Up"]]     <- "$\\Delta\\,\\mathrm{ECB \\ Economy_t^{Increasing}}$"
    v[["ECB.PC.Outlook.Down"]]   <- "$\\Delta\\,\\mathrm{ECB \\ Economy_t^{Decreasing}}$"
  }
  if (use_diffs_mp) {
    v[["ECB.PC.Monetary.Haw."]]  <- "$\\Delta\\,\\mathrm{ECB \\ MP_t^{Hawkish}}$"
    v[["ECB.PC.Monetary.Dov."]]  <- "$\\Delta\\,\\mathrm{ECB \\ MP_t^{Dovish}}$"
  }
  v
}

fmt_est_se <- function(e, s, p) { if (!length(e) || is.na(e)) list(est="", se="") else { sc <- if(p<.01)"***" else if(p<.05)"**" else if(p<.1)"*" else ""; list(est=sprintf("%.3f%s",e,sc), se=sprintf("(%.3f)",s)) }}

make_lag_row <- function(label_text, var1, var2, var3, res_inc_list, res_dec_list, res_idx_list) {
  get_formatted_results <- function(res_list, var_name) {
    r1 <- res_list[[1]][res_list[[1]]$varname == var_name, ]
    r2 <- res_list[[2]][res_list[[2]]$varname == var_name, ]
    r3 <- res_list[[3]][res_list[[3]]$varname == var_name, ]
    
    f1 <- fmt_est_se(r1$estimate, r1$se, r1$pval)
    f2 <- fmt_est_se(r2$estimate, r2$se, r2$pval)
    f3 <- fmt_est_se(r3$estimate, r3$se, r3$pval)
    
    list(f1 = f1, f2 = f2, f3 = f3)
  }
  
  f_inc <- get_formatted_results(res_inc_list, var1)
  f_dec <- get_formatted_results(res_dec_list, var2)
  f_idx <- get_formatted_results(res_idx_list, var3)
  
  # This order matches the desired table structure (grouped by dependent variable)
  row1 <- paste0(label_text, " & ",
                 f_inc$f1$est, " & ", f_inc$f2$est, " & ", f_inc$f3$est, " & ",
                 f_dec$f1$est, " & ", f_dec$f2$est, " & ", f_dec$f3$est, " & ",
                 f_idx$f1$est, " & ", f_idx$f2$est, " & ", f_idx$f3$est, " \\\\")
  row2 <- paste0(" & ",
                 f_inc$f1$se, " & ", f_inc$f2$se, " & ", f_inc$f3$se, " & ",
                 f_dec$f1$se, " & ", f_dec$f2$se, " & ", f_dec$f3$se, " & ",
                 f_idx$f1$se, " & ", f_idx$f2$se, " & ", f_idx$f3$se, " \\\\")
  
  paste(row1, row2, sep = "\n")
}

make_single_row <- function(var, label_text, res_inc_list, res_dec_list, res_idx_list) {
  make_lag_row(label_text, var, var, var, res_inc_list, res_dec_list, res_idx_list)
}

################################################################################
# Main Function to Build LaTeX Table
################################################################################

build_infl_dir_table <- function(df, use_diffs_infeco, use_diffs_mp, caption_note="") {
  
  # --- Define and run all regression models ---
  # (Regression model definitions are unchanged)
  fit_no_controls_inc <- lm(
    News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df)
  
  fit_macro_inc <- lm(
    News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_inc <- lm(
    News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + draghi + negative +
      whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference + DAX.difference + VDAX + Unmon, df)
  
  fit_no_controls_dec <- lm(
    News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference, df)
  
  fit_macro_dec <- lm(
    News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_dec <- lm(
    News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + draghi + negative +
      whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  fit_no_controls_ind <- lm(
    News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
      News.Inflation.Direction.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df)
  
  fit_macro_ind <- lm(
    News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
      News.Inflation.Direction.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_ind <- lm(
    News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
      News.Inflation.Direction.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  # --- Process results ---
  get_res_df <- function(m) {
    c0 <- lmtest::coeftest(m, vcov.=sandwich::NeweyWest(lag = 12, m, prewhite=FALSE, adjust=TRUE))
    data.frame(varname=rownames(c0),
               estimate=c0[, "Estimate"], se=c0[, "Std. Error"], pval=c0[, "Pr(>|t|)"],
               stringsAsFactors=FALSE)
  }
  
  res_inc_list <- list(get_res_df(fit_no_controls_inc), get_res_df(fit_macro_inc), get_res_df(fit_all_controls_inc))
  res_dec_list <- list(get_res_df(fit_no_controls_dec), get_res_df(fit_macro_dec), get_res_df(fit_all_controls_dec))
  res_idx_list <- list(get_res_df(fit_no_controls_ind), get_res_df(fit_macro_ind), get_res_df(fit_all_controls_ind))
  
  adj_r2_inc_1 <- round(summary(fit_no_controls_inc)$adj.r.squared, 3)
  adj_r2_inc_2 <- round(summary(fit_macro_inc)$adj.r.squared, 3)
  adj_r2_inc_3 <- round(summary(fit_all_controls_inc)$adj.r.squared, 3)
  adj_r2_dec_1 <- round(summary(fit_no_controls_dec)$adj.r.squared, 3)
  adj_r2_dec_2 <- round(summary(fit_macro_dec)$adj.r.squared, 3)
  adj_r2_dec_3 <- round(summary(fit_all_controls_dec)$adj.r.squared, 3)
  adj_r2_idx_1 <- round(summary(fit_no_controls_ind)$adj.r.squared, 3)
  adj_r2_idx_2 <- round(summary(fit_macro_ind)$adj.r.squared, 3)
  adj_r2_idx_3 <- round(summary(fit_all_controls_ind)$adj.r.squared, 3)
  
  obs_inc_1 <- nobs(fit_no_controls_inc); obs_inc_2 <- nobs(fit_macro_inc); obs_inc_3 <- nobs(fit_all_controls_inc)
  obs_dec_1 <- nobs(fit_no_controls_dec); obs_dec_2 <- nobs(fit_macro_dec); obs_dec_3 <- nobs(fit_all_controls_dec)
  obs_idx_1 <- nobs(fit_no_controls_ind); obs_idx_2 <- nobs(fit_macro_ind); obs_idx_3 <- nobs(fit_all_controls_ind)
  
  var_label <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  my_other_vars <- c(
    "ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
    "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.","German.Inflation.Year.on.Year.difference",
    "Reuter.Poll.Forecast.difference","German.Industrial.Production.Gap","Germany.Unemployment.difference",
    "Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco","ECB.MRO.difference",
    "whatever","negative","ECB.MRO.POS","ECB.MRO.NEG","Unmon","DAX.difference","VDAX","ED.Exchange.Rate.difference",
    "(Intercept)"
  )
  
  # --- Build the LaTeX string ---
  txt <- ""
  txt <- paste0(txt,"\\begin{minipage}{\\textwidth}\n")
  txt <- paste0(txt,"\\begin{adjustbox}{angle=0,center}\n")
  txt <- paste0(txt,"\\resizebox{0.8\\textheight}{!}{\n")
  txt <- paste0(txt,"\\begin{threeparttable}\n")
  txt <- paste0(txt,"\\tiny\n")
  txt <- paste0(txt,"\\setlength{\\tabcolsep}{3.5pt}\n")
  txt <- paste0(txt,"\\caption{Inflation Direction - Full Table}\n")
  txt <- paste0(txt,"\\label{drivers_of_news_inf_full}\n")
  txt <- paste0(txt,"\\begin{tabular}{lccccccccc}\n")
  txt <- paste0(txt,"\\multicolumn{1}{l}{\\textbf{$y_t$}} & \\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Increasing}}}$} & \\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Decreasing}}}$} & \\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Direction}}}$}  \\\\\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # Lags rows
  txt <- paste0(txt, make_lag_row("$y_{t-1}$", "News.Inflation.Inc..Lag1", "News.Inflation.Dec..Lag1", "News.Inflation.Direction.Index.Lag1", res_inc_list, res_dec_list, res_idx_list), "\n")
  txt <- paste0(txt, make_lag_row("$y_{t-2}$", "News.Inflation.Inc..Lag2", "News.Inflation.Dec..Lag2", "News.Inflation.Direction.Index.Lag2", res_inc_list, res_dec_list, res_idx_list), "\n")
  txt <- paste0(txt, make_lag_row("$y_{t-3}$", "News.Inflation.Inc..Lag3", "News.Inflation.Dec..Lag3", "News.Inflation.Direction.Index.Lag3", res_inc_list, res_dec_list, res_idx_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # Variable rows (ECB + Macro)
  for (v in c("ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down","ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.")) {
    txt <- paste0(txt, make_single_row(v, var_label[v], res_inc_list, res_dec_list, res_idx_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  for (v in c("German.Inflation.Year.on.Year.difference", "Reuter.Poll.Forecast.difference")) {
    txt <- paste0(txt, make_single_row(v, var_label[v], res_inc_list, res_dec_list, res_idx_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  for (v in c("German.Industrial.Production.Gap","Germany.Unemployment.difference","Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco")) {
    txt <- paste0(txt, make_single_row(v, var_label[v], res_inc_list, res_dec_list, res_idx_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  # Variable rows (Financial + Policy)
  for (v in c("ECB.MRO.difference", "whatever", "negative", "ECB.MRO.POS", "ECB.MRO.NEG", "Unmon", "DAX.difference", "VDAX", "ED.Exchange.Rate.difference")) {
    txt <- paste0(txt, make_single_row(v, var_label[v], res_inc_list, res_dec_list, res_idx_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  # Constant
  txt <- paste0(txt, make_single_row("(Intercept)", var_label["(Intercept)"], res_inc_list, res_dec_list, res_idx_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # Stats rows
  txt <- paste0(txt, "Adjusted $R^2$ & ", adj_r2_inc_1," & ",adj_r2_inc_2," & ",adj_r2_inc_3," & ", adj_r2_dec_1," & ",adj_r2_dec_2," & ",adj_r2_dec_3," & ", adj_r2_idx_1," & ",adj_r2_idx_2," & ",adj_r2_idx_3, " \\\\\n")
  txt <- paste0(txt, "Obs. & ", obs_inc_1," & ",obs_inc_2," & ",obs_inc_3," & ", obs_dec_1," & ",obs_dec_2," & ",obs_dec_3," & ", obs_idx_1," & ",obs_idx_2," & ",obs_idx_3, " \\\\\n")
  
  # Table footer
  txt <- paste0(txt,"\\end{tabular}\n")
  txt <- paste0(txt,"\\begin{tablenotes}[flushleft]\n")
  txt <- paste0(txt,"\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg1} for three measures of inflation‐direction news: $\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$, $\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$, and $\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
  txt <- paste0(txt,"\\end{tablenotes}\n")
  txt <- paste0(txt,"\\end{threeparttable}\n")
  txt <- paste0(txt,"}\n")
  txt <- paste0(txt,"\\end{adjustbox}\n")
  txt <- paste0(txt,"\\end{minipage}\n")
  
  return(txt)
}

################################################################################
# Execution
################################################################################
# Set parameters for which data version to use
df_to_use  <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)

# Generate and print the LaTeX code to the console
latex_output <- build_infl_dir_table(df_to_use, 
                                     use_diffs_infeco = FALSE, 
                                     use_diffs_mp = FALSE, 
                                     caption_note="")
cat(latex_output)

################################################################################

build_infl_dir_table_small <- function(df, use_diffs_infeco = FALSE, use_diffs_mp = FALSE) {
  
  fit_controls_inc <- lm(
    News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  
  fit_controls_dec <- lm(
    News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  
  fit_controls_ind <- lm(
    News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
      News.Inflation.Direction.Index.Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  get_res_df <- function(m) {
    ct <- lmtest::coeftest(m, vcov. = sandwich::NeweyWest(m, lag = 12, prewhite = FALSE, adjust = TRUE))
    data.frame(varname = rownames(ct),
               estimate = ct[, "Estimate"],
               se       = ct[, "Std. Error"],
               pval     = ct[, "Pr(>|t|)"],
               stringsAsFactors = FALSE)
  }
  r_inc <- get_res_df(fit_controls_inc)
  r_dec <- get_res_df(fit_controls_dec)
  r_idx <- get_res_df(fit_controls_ind)
  
  row3 <- function(label_text, v_inc, v_dec, v_idx) {
    g <- function(res, v) {
      rr <- res[res$varname == v, , drop = FALSE]
      if (nrow(rr) == 0) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
    }
    f1 <- g(r_inc, v_inc); f2 <- g(r_dec, v_dec); f3 <- g(r_idx, v_idx)
    paste0(
      label_text, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\\\n",
      " & ", f1$se, " & ", f2$se, " & ", f3$se, " \\\\\n"
    )
  }
  
  # Labels
  vlab <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  
  txt <- ""
  txt <- paste0(txt, "\\begin{table}[H]\n\\footnotesize \n\\centering\n")
  txt <- paste0(txt, "\\caption{Inflation Direction}\n\\label{drivers_of_news_inflation}\n")
  txt <- paste0(txt, "\\setlength{\\tabcolsep}{1pt}\n")
  txt <- paste0(txt, "\\begin{tabular}{l@{\\hspace{-20pt}}c@{\\hspace{5pt}}c@{\\hspace{5pt}}c}\n")
  txt <- paste0(txt, "\\toprule\n")
  txt <- paste0(txt,"\\multicolumn{1}{l}{\\textbf{$y_t$}} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Increasing}}}$} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Decreasing}}}$} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Direction}}}$}\\\\\n")
  txt <- paste0(txt, "\\midrule\n")
  
  # Lags
  txt <- paste0(txt, row3("$y_{t-1}$", "News.Inflation.Inc..Lag1", "News.Inflation.Dec..Lag1", "News.Inflation.Direction.Index.Lag1"))
  txt <- paste0(txt, row3("$y_{t-2}$", "News.Inflation.Inc..Lag2", "News.Inflation.Dec..Lag2", "News.Inflation.Direction.Index.Lag2"))
  txt <- paste0(txt, row3("$y_{t-3}$", "News.Inflation.Inc..Lag3", "News.Inflation.Dec..Lag3", "News.Inflation.Direction.Index.Lag3"))
  
  txt <- paste0(txt, "\\midrule\n")
  
  # ECB variables
  txt <- paste0(txt, row3(vlab["ECB.PC.Inflation.Inc."], "ECB.PC.Inflation.Inc.", "ECB.PC.Inflation.Inc.", "ECB.PC.Inflation.Inc."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Inflation.Dec."], "ECB.PC.Inflation.Dec.", "ECB.PC.Inflation.Dec.", "ECB.PC.Inflation.Dec."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Outlook.Up"],     "ECB.PC.Outlook.Up",     "ECB.PC.Outlook.Up",     "ECB.PC.Outlook.Up"))
  txt <- paste0(txt, row3(vlab["ECB.PC.Outlook.Down"],   "ECB.PC.Outlook.Down",   "ECB.PC.Outlook.Down",   "ECB.PC.Outlook.Down"))
  txt <- paste0(txt, row3(vlab["ECB.PC.Monetary.Haw."],  "ECB.PC.Monetary.Haw.",  "ECB.PC.Monetary.Haw.",  "ECB.PC.Monetary.Haw."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Monetary.Dov."],  "ECB.PC.Monetary.Dov.",  "ECB.PC.Monetary.Dov.",  "ECB.PC.Monetary.Dov."))
  
  txt <- paste0(txt, "\\midrule\n")
  
  txt <- paste0(txt, row3(vlab["German.Inflation.Year.on.Year.difference"],
                          "German.Inflation.Year.on.Year.difference",
                          "German.Inflation.Year.on.Year.difference",
                          "German.Inflation.Year.on.Year.difference"))
  txt <- paste0(txt, row3(vlab["Reuter.Poll.Forecast.difference"],
                          "Reuter.Poll.Forecast.difference",
                          "Reuter.Poll.Forecast.difference",
                          "Reuter.Poll.Forecast.difference"))
  
  txt <- paste0(txt, " \\midrule\n")
  
  # Constant
  txt <- paste0(txt, row3(vlab["(Intercept)"], "(Intercept)", "(Intercept)", "(Intercept)"))
  
  # Footer stats
  adj_r2_inc <- round(summary(fit_controls_inc)$adj.r.squared, 3)
  adj_r2_dec <- round(summary(fit_controls_dec)$adj.r.squared, 3)
  adj_r2_idx <- round(summary(fit_controls_ind)$adj.r.squared, 3)
  obs_inc    <- nobs(fit_controls_inc)
  obs_dec    <- nobs(fit_controls_dec)
  obs_idx    <- nobs(fit_controls_ind)
  
  txt <- paste0(txt, "\\midrule\n")
  txt <- paste0(txt, "Adjusted $R^2$ & ", adj_r2_inc, " & ", adj_r2_dec, " & ", adj_r2_idx, " \\\\\n")
  txt <- paste0(txt, "Obs. & ", obs_inc, " & ", obs_dec, " & ", obs_idx, " \\\\\n")
  txt <- paste0(txt, "\\bottomrule\n\\end{tabular}\n")
  
  txt <- paste0(txt, "\\begin{tablenotes}\n\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg1} for three measures of inflation‐direction news: $\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$, $\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$, and $\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. All specifications include lagged dependent variables and the two macro controls shown. Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
  txt <- paste0(txt, "\\end{tablenotes}\n\\end{table}\n")
  
  txt
}

df_small_diff <- canonize_ecb_pc(data, use_diffs_infeco = TRUE, use_diffs_mp = TRUE)
cat(build_infl_dir_table_small(df_small_diff,
                               use_diffs_infeco = TRUE,
                               use_diffs_mp = TRUE))

df_small_levels <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)

cat(build_infl_dir_table_small(df_small_levels, 
                               use_diffs_infeco = FALSE, 
                               use_diffs_mp = FALSE))

df_small_MP_diff <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = TRUE)

cat(build_infl_dir_table_small(df_small_MP_diff, 
                               use_diffs_infeco = FALSE, 
                               use_diffs_mp = TRUE))

################################################################################
# Inflation Sentiment — Full Table (ADD ONLY)
################################################################################

build_infl_sent_table <- function(df, use_diffs_infeco, use_diffs_mp, caption_note="") {
  # --- Models (Positive, Negative, Sentiment) with 3 specs each ---
  fit_no_controls_pos <- lm(
    News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df)
  
  fit_macro_pos <- lm(
    News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_pos <- lm(
    News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + draghi + negative +
      whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference + DAX.difference + VDAX + Unmon, df)
  
  fit_no_controls_neg <- lm(
    News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df)
  
  fit_macro_neg <- lm(
    News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_neg <- lm(
    News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco +
      Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
      German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + draghi + negative +
      whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  fit_no_controls_sen <- lm(
    News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
      News.Inflation.Sentiment.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df)
  
  fit_macro_sen <- lm(
    News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
      News.Inflation.Sentiment.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference, df)
  
  fit_all_controls_sen <- lm(
    News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
      News.Inflation.Sentiment.Index.Lag3 + ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. +
      ECB.PC.Monetary.Dov. + ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference +
      Germany.Future.Eco + Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference +
      Reuter.Poll.Forecast.difference + German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  # --- NW results (mirrors your helper pattern) ---
  get_res_df <- function(m) {
    c0 <- lmtest::coeftest(m, vcov.=sandwich::NeweyWest(lag = 12, m, prewhite=FALSE, adjust=TRUE))
    data.frame(varname=rownames(c0),
               estimate=c0[, "Estimate"], se=c0[, "Std. Error"], pval=c0[, "Pr(>|t|)"],
               stringsAsFactors=FALSE)
  }
  res_pos_list <- list(get_res_df(fit_no_controls_pos), get_res_df(fit_macro_pos), get_res_df(fit_all_controls_pos))
  res_neg_list <- list(get_res_df(fit_no_controls_neg), get_res_df(fit_macro_neg), get_res_df(fit_all_controls_neg))
  res_sen_list <- list(get_res_df(fit_no_controls_sen), get_res_df(fit_macro_sen), get_res_df(fit_all_controls_sen))
  
  # Stats
  ar <- function(m) round(summary(m)$adj.r.squared, 3)
  n_ <- function(m) nobs(m)
  adj_r2 <- c(ar(fit_no_controls_pos), ar(fit_macro_pos), ar(fit_all_controls_pos),
              ar(fit_no_controls_neg), ar(fit_macro_neg), ar(fit_all_controls_neg),
              ar(fit_no_controls_sen), ar(fit_macro_sen), ar(fit_all_controls_sen))
  obs_   <- c(n_(fit_no_controls_pos), n_(fit_macro_pos), n_(fit_all_controls_pos),
              n_(fit_no_controls_neg), n_(fit_macro_neg), n_(fit_all_controls_neg),
              n_(fit_no_controls_sen), n_(fit_macro_sen), n_(fit_all_controls_sen))
  
  vlab <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  my_other_vars <- c(
    "ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
    "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.","German.Inflation.Year.on.Year.difference",
    "Reuter.Poll.Forecast.difference","German.Industrial.Production.Gap","Germany.Unemployment.difference",
    "Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco","ECB.MRO.difference",
    "whatever","negative","ECB.MRO.POS","ECB.MRO.NEG","Unmon","DAX.difference","VDAX","ED.Exchange.Rate.difference",
    "(Intercept)"
  )
  
  # --- LaTeX (same wrapper/shape as your direction table) ---
  txt <- ""
  txt <- paste0(txt,"\\begin{minipage}{\\textwidth}\n")
  txt <- paste0(txt,"\\begin{adjustbox}{angle=0,center}\n")
  txt <- paste0(txt,"\\resizebox{0.8\\textheight}{!}{\n")
  txt <- paste0(txt,"\\begin{threeparttable}\n")
  txt <- paste0(txt,"\\tiny\n")
  txt <- paste0(txt,"\\setlength{\\tabcolsep}{3.5pt}\n")
  txt <- paste0(txt,"\\caption{Inflation Sentiment - Full Table}\n")
  txt <- paste0(txt,"\\label{drivers_of_news_inf_sent_full}\n")
  txt <- paste0(txt,"\\begin{tabular}{lccccccccc}\n")
  txt <- paste0(
    txt,
    "\\multicolumn{1}{l}{\\textbf{$y_t$}} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Positive}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Negative}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Sentiment}}}$}  \\\\\n"
  )
  txt <- paste0(txt,"\\midrule\n")
  
  # Lags (grouped by DV: Pos [spec1-3], Neg [1-3], Sent [1-3])
  txt <- paste0(txt, make_lag_row("$y_{t-1}$",
                                  "News.Inflation.Pos..Lag1", "News.Inflation.Neg..Lag1", "News.Inflation.Sentiment.Index.Lag1",
                                  res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt, make_lag_row("$y_{t-2}$",
                                  "News.Inflation.Pos..Lag2", "News.Inflation.Neg..Lag2", "News.Inflation.Sentiment.Index.Lag2",
                                  res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt, make_lag_row("$y_{t-3}$",
                                  "News.Inflation.Pos..Lag3", "News.Inflation.Neg..Lag3", "News.Inflation.Sentiment.Index.Lag3",
                                  res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # ECB blocks
  for (v in c("ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down","ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.")) {
    txt <- paste0(txt, make_single_row(v, vlab[v], res_pos_list, res_neg_list, res_sen_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  
  # Core macro
  for (v in c("German.Inflation.Year.on.Year.difference", "Reuter.Poll.Forecast.difference")) {
    txt <- paste0(txt, make_single_row(v, vlab[v], res_pos_list, res_neg_list, res_sen_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  
  # More controls (financial/policy)
  for (v in c("German.Industrial.Production.Gap","Germany.Unemployment.difference","Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco")) {
    txt <- paste0(txt, make_single_row(v, vlab[v], res_pos_list, res_neg_list, res_sen_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  for (v in c("ECB.MRO.difference", "whatever", "negative", "ECB.MRO.POS", "ECB.MRO.NEG", "Unmon", "DAX.difference", "VDAX", "ED.Exchange.Rate.difference")) {
    txt <- paste0(txt, make_single_row(v, vlab[v], res_pos_list, res_neg_list, res_sen_list), "\n")
  }
  txt <- paste0(txt, "\\midrule\n")
  
  # Constant
  txt <- paste0(txt, make_single_row("(Intercept)", vlab["(Intercept)"], res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # Stats rows
  txt <- paste0(txt, "Adjusted $R^2$ & ", paste(adj_r2, collapse = " & "), " \\\\\n")
  txt <- paste0(txt, "Obs. & ", paste(obs_, collapse = " & "), " \\\\\n")
  
  # Footer
  txt <- paste0(txt,"\\end{tabular}\n")
  txt <- paste0(txt,"\\begin{tablenotes}[flushleft]\n\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg1} for three measures of inflation‐sentiment news: ",
                "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$, $\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$, and ",
                "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. ",
                "Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
  txt <- paste0(txt,"\\end{tablenotes}\n")
  txt <- paste0(txt,"\\end{threeparttable}\n")
  txt <- paste0(txt,"}\n\\end{adjustbox}\n\\end{minipage}\n")
  
  return(txt)
}

################################################################################
# Inflation Sentiment — Compact Table (ADD ONLY)
################################################################################

build_infl_sent_table_small <- function(df, use_diffs_infeco = FALSE, use_diffs_mp = FALSE) {
  fit_controls_pos <- lm(
    News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference + Germany.Future.Eco + Germany.Future.Fin.difference +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + 
      German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  fit_controls_neg <- lm(
    News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference + Germany.Future.Eco + Germany.Future.Fin.difference +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + 
      German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  fit_controls_sen <- lm(
    News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
      News.Inflation.Sentiment.Index.Lag3 + 
      ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + 
      ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + 
      ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + 
      Germany.Future.Un.difference + Germany.Future.Eco + Germany.Future.Fin.difference +
      German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + 
      German.Industrial.Production.Gap + Germany.Unemployment.difference +
      ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
      DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df)
  
  get_res_df <- function(m) {
    ct <- lmtest::coeftest(m, vcov. = sandwich::NeweyWest(m, lag = 12, prewhite = FALSE, adjust = TRUE))
    data.frame(varname = rownames(ct),
               estimate = ct[, "Estimate"],
               se       = ct[, "Std. Error"],
               pval     = ct[, "Pr(>|t|)"],
               stringsAsFactors = FALSE)
  }
  r_pos <- get_res_df(fit_controls_pos)
  r_neg <- get_res_df(fit_controls_neg)
  r_sen <- get_res_df(fit_controls_sen)
  
  row3 <- function(label_text, v_pos, v_neg, v_sen) {
    g <- function(res, v) {
      rr <- res[res$varname == v, , drop = FALSE]
      if (nrow(rr) == 0) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
    }
    f1 <- g(r_pos, v_pos); f2 <- g(r_neg, v_neg); f3 <- g(r_sen, v_sen)
    paste0(label_text, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\\\n",
           " & ", f1$se,  " & ", f2$se,  " & ", f3$se,  " \\\\\n")
  }
  
  vlab <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  
  txt <- ""
  txt <- paste0(txt, "\\begin{table}[H]\n\\footnotesize \n\\centering\n")
  txt <- paste0(txt, "\\caption{Inflation Sentiment}\n\\label{drivers_of_news_inflation_sent}\n")
  txt <- paste0(txt, "\\setlength{\\tabcolsep}{1pt}\n")
  txt <- paste0(txt, "\\begin{tabular}{l@{\\hspace{-20pt}}c@{\\hspace{5pt}}c@{\\hspace{5pt}}c}\n")
  txt <- paste0(txt, "\\toprule\n")
  txt <- paste0(txt,"\\multicolumn{1}{l}{\\textbf{$y_t$}} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Positive}}}$} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Negative}}}$} & {$\\boldsymbol{\\mathrm{News \\ Inflation_t^{Sentiment}}}$}\\\\\n")
  txt <- paste0(txt, "\\midrule\n")
  
  # Lags
  txt <- paste0(txt, row3("$y_{t-1}$", "News.Inflation.Pos..Lag1", "News.Inflation.Neg..Lag1", "News.Inflation.Sentiment.Index.Lag1"))
  txt <- paste0(txt, row3("$y_{t-2}$", "News.Inflation.Pos..Lag2", "News.Inflation.Neg..Lag2", "News.Inflation.Sentiment.Index.Lag2"))
  txt <- paste0(txt, row3("$y_{t-3}$", "News.Inflation.Pos..Lag3", "News.Inflation.Neg..Lag3", "News.Inflation.Sentiment.Index.Lag3"))
  
  txt <- paste0(txt, "\\midrule\n")
  
  # ECB variables
  txt <- paste0(txt, row3(vlab["ECB.PC.Inflation.Inc."], "ECB.PC.Inflation.Inc.", "ECB.PC.Inflation.Inc.", "ECB.PC.Inflation.Inc."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Inflation.Dec."], "ECB.PC.Inflation.Dec.", "ECB.PC.Inflation.Dec.", "ECB.PC.Inflation.Dec."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Outlook.Up"],     "ECB.PC.Outlook.Up",     "ECB.PC.Outlook.Up",     "ECB.PC.Outlook.Up"))
  txt <- paste0(txt, row3(vlab["ECB.PC.Outlook.Down"],   "ECB.PC.Outlook.Down",   "ECB.PC.Outlook.Down",   "ECB.PC.Outlook.Down"))
  txt <- paste0(txt, row3(vlab["ECB.PC.Monetary.Haw."],  "ECB.PC.Monetary.Haw.",  "ECB.PC.Monetary.Haw.",  "ECB.PC.Monetary.Haw."))
  txt <- paste0(txt, row3(vlab["ECB.PC.Monetary.Dov."],  "ECB.PC.Monetary.Dov.",  "ECB.PC.Monetary.Dov.",  "ECB.PC.Monetary.Dov."))
  
  txt <- paste0(txt, "\\midrule\n")
  
  # Macro
  txt <- paste0(txt, row3(vlab["German.Inflation.Year.on.Year.difference"],
                          "German.Inflation.Year.on.Year.difference",
                          "German.Inflation.Year.on.Year.difference",
                          "German.Inflation.Year.on.Year.difference"))
  txt <- paste0(txt, row3(vlab["Reuter.Poll.Forecast.difference"],
                          "Reuter.Poll.Forecast.difference",
                          "Reuter.Poll.Forecast.difference",
                          "Reuter.Poll.Forecast.difference"))
  
  txt <- paste0(txt, " \\midrule\n")
  
  # Constant
  txt <- paste0(txt, row3(vlab["(Intercept)"], "(Intercept)", "(Intercept)", "(Intercept)"))
  
  # Footer stats
  adj_r2_pos <- round(summary(fit_controls_pos)$adj.r.squared, 3)
  adj_r2_neg <- round(summary(fit_controls_neg)$adj.r.squared, 3)
  adj_r2_sen <- round(summary(fit_controls_sen)$adj.r.squared, 3)
  obs_pos    <- nobs(fit_controls_pos)
  obs_neg    <- nobs(fit_controls_neg)
  obs_sen    <- nobs(fit_controls_sen)
  
  txt <- paste0(txt, "\\midrule\n")
  txt <- paste0(txt, "Adjusted $R^2$ & ", adj_r2_pos, " & ", adj_r2_neg, " & ", adj_r2_sen, " \\\\\n")
  txt <- paste0(txt, "Obs. & ", obs_pos, " & ", obs_neg, " & ", obs_sen, " \\\\\n")
  txt <- paste0(txt, "\\bottomrule\n\\end{tabular}\n")
  
  txt <- paste0(txt, "\\begin{tablenotes}\n\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg1} for three measures of inflation‐sentiment news: $\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$, $\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$, and $\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$. All specifications include lagged dependent variables and the controls shown. Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
  txt <- paste0(txt, "\\end{tablenotes}\n\\end{table}\n")
  
  txt
}

################################################################################
# Execution (ADD ONLY) — Inflation Sentiment tables
################################################################################

# Full table (use same df_to_use you already set above)
latex_output_sent <- build_infl_sent_table(df_to_use,
                                           use_diffs_infeco = FALSE,
                                           use_diffs_mp = FALSE,
                                           caption_note = "")
cat(latex_output_sent)

# Compact tables for the three data variants (diffs / levels / MP-diff)
df_small_diff <- canonize_ecb_pc(data, use_diffs_infeco = TRUE, use_diffs_mp = TRUE)
cat(build_infl_sent_table_small(df_small_diff, use_diffs_infeco = TRUE, use_diffs_mp = TRUE))

df_small_levels <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)
cat(build_infl_sent_table_small(df_small_levels, use_diffs_infeco = FALSE, use_diffs_mp = FALSE))

df_small_MP_diff <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = TRUE)
cat(build_infl_sent_table_small(df_small_MP_diff, use_diffs_infeco = FALSE, use_diffs_mp = TRUE))
