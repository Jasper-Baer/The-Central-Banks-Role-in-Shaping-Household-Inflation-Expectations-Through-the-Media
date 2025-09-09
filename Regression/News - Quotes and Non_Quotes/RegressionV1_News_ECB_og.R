################################################################################
# Libraries
################################################################################
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")
library("stargazer")
library("car")
library("tseries")

data <- read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data <- data.frame(data)

data <- data[12:(nrow(data)), ]

data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))

numeric_columns <- sapply(data, is.numeric)
dont_scale_names <- c("draghi", "negative", "trichet", "whatever", "Unmon")
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

make_var_labels <- function(use_diffs_infeco, use_diffs_mp) {
  v <- c(
    "ECB.PC.Inflation.Inc." = "$\\mathrm{ECB \\ Inflation}_t^{\\text{Increasing}}$",
    "ECB.PC.Inflation.Dec." = "$\\mathrm{ECB \\ Inflation}_t^{\\text{Decreasing}}$",
    "ECB.PC.Outlook.Up"     = "$\\mathrm{ECB \\ Economy}_t^{\\text{Increasing}}$",
    "ECB.PC.Outlook.Down"   = "$\\mathrm{ECB \\ Economy}_t^{\\text{Decreasing}}$",
    "ECB.PC.Monetary.Haw."  = "$\\mathrm{ECB \\ MP}_t^{\\text{Hawkish}}$",
    "ECB.PC.Monetary.Dov."  = "$\\mathrm{ECB \\ MP}_t^{\\text{Dovish}}$",
    "ECB.MRO.difference"               = "$\\Delta$MRO rate",
    "German.Inflation.Year.on.Year.difference" = "$\\Delta$HICP Inflation",
    "Reuter.Poll.Forecast.difference"          = "$\\Delta$Prof. Inflation Forecast",
    "German.Industrial.Production.Gap" = "Industrial Production Gap",
    "Germany.Unemployment.difference"  = "$\\Delta$Unemployment Rate",
    "Germany.Future.Un.difference"     = "$\\Delta$Unemployment Expectations",
    "Germany.Future.Fin.difference"    = "$\\Delta$Financial Expectations",
    "Germany.Future.Eco"               = "Economic Expectations",
    "whatever"                         = "Whatever it Takes",
    "negative"                         = "Negative Rate",
    "ECB.MRO.POS"                      = "Positive Interest Surprise",
    "ECB.MRO.NEG"                      = "Negative Interest Surprise",
    "Unmon"                            = "Unconventional MP",
    "DAX.difference"                   = "$\\Delta$DAX",
    "VDAX"                             = "VDAX",
    "ED.Exchange.Rate.difference"      = "$\\Delta$EURUSD",
    "(Intercept)"                      = "Constant"
  )
  if (use_diffs_infeco) {
    v[["ECB.PC.Inflation.Inc."]] <- "$\\Delta\\,\\mathrm{ECB \\ Inflation}_t^{\\text{Increasing}}$"
    v[["ECB.PC.Inflation.Dec."]] <- "$\\Delta\\,\\mathrm{ECB \\ Inflation}_t^{\\text{Decreasing}}$"
    v[["ECB.PC.Outlook.Up"]]     <- "$\\Delta\\,\\mathrm{ECB \\ Economy}_t^{\\text{Increasing}}$"
    v[["ECB.PC.Outlook.Down"]]   <- "$\\Delta\\,\\mathrm{ECB \\ Economy}_t^{\\text{Decreasing}}$"
  }
  if (use_diffs_mp) {
    v[["ECB.PC.Monetary.Haw."]]  <- "$\\Delta\\,\\mathrm{ECB \\ MP}_t^{\\text{Hawkish}}$"
    v[["ECB.PC.Monetary.Dov."]]  <- "$\\Delta\\,\\mathrm{ECB \\ MP}_t^{\\text{Dovish}}$"
  }
  v
}

fmt_est_se <- function(e, s, p) {
  if (!length(e)) list(est = "", se = "") else {
    sc <- if (p < .01) "***" else if (p < .05) "**" else if (p < .1) "*" else ""
    list(est = sprintf("%.3f%s", e, sc), se = sprintf("(%.3f)", s))
  }
}

make_lag_row <- function(label_text, var1, var2, var3, res_list_1, res_list_2, res_list_3) {
  get_formatted <- function(res_list, var_name) {
    r1 <- res_list[[1]][res_list[[1]]$varname == var_name, ]
    r2 <- res_list[[2]][res_list[[2]]$varname == var_name, ]
    r3 <- res_list[[3]][res_list[[3]]$varname == var_name, ]
    f1 <- fmt_est_se(r1$estimate, r1$se, r1$pval)
    f2 <- fmt_est_se(r2$estimate, r2$se, r2$pval)
    f3 <- fmt_est_se(r3$estimate, r3$se, r3$pval)
    list(f1 = f1, f2 = f2, f3 = f3)
  }
  a <- get_formatted(res_list_1, var1)
  b <- get_formatted(res_list_2, var2)
  c <- get_formatted(res_list_3, var3)
  
  row1 <- paste0(label_text, " & ",
                 a$f1$est, " & ", b$f1$est, " & ", c$f1$est, " & ",
                 a$f2$est, " & ", b$f2$est, " & ", c$f2$est, " & ",
                 a$f3$est, " & ", b$f3$est, " & ", c$f3$est, " \\\\")
  row2 <- paste0(" & ",
                 a$f1$se, " & ", b$f1$se, " & ", c$f1$se, " & ",
                 a$f2$se, " & ", b$f2$se, " & ", c$f2$se, " & ",
                 a$f3$se, " & ", b$f3$se, " & ", c$f3$se, " \\\\")
  paste(row1, row2, sep = "\n")
}

make_single_row <- function(var, label_text, res_list_1, res_list_2, res_list_3) {
  make_lag_row(label_text, var, var, var, res_list_1, res_list_2, res_list_3)
}

nw_results <- function(model, lag = 12) {
  ct <- lmtest::coeftest(model, vcov. = sandwich::NeweyWest(model, lag = lag, prewhite = FALSE, adjust = TRUE))
  data.frame(varname = rownames(ct),
             estimate = ct[, "Estimate"],
             se       = ct[, "Std. Error"],
             pval     = ct[, "Pr(>|t|)"],
             stringsAsFactors = FALSE)
}

make_row_by_dv <- function(label_text, var_h, var_d, var_i, res_haw_list, res_dov_list, res_idx_list) {
  # pull one coef (estimate, se, p) from a single result df for a var
  get_f <- function(res_df, var_name) {
    rr <- res_df[res_df$varname == var_name, , drop = FALSE]
    if (nrow(rr) == 0) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
  }
  # spec1/spec2/spec3 for each DV
  h1 <- get_f(res_haw_list[[1]], var_h); h2 <- get_f(res_haw_list[[2]], var_h); h3 <- get_f(res_haw_list[[3]], var_h)
  d1 <- get_f(res_dov_list[[1]], var_d); d2 <- get_f(res_dov_list[[2]], var_d); d3 <- get_f(res_dov_list[[3]], var_d)
  i1 <- get_f(res_idx_list[[1]], var_i); i2 <- get_f(res_idx_list[[2]], var_i); i3 <- get_f(res_idx_list[[3]], var_i)
  
  row1 <- paste0(label_text, " & ",
                 h1$est, " & ", h2$est, " & ", h3$est, " & ",
                 d1$est, " & ", d2$est, " & ", d3$est, " & ",
                 i1$est, " & ", i2$est, " & ", i3$est, " \\\\")
  row2 <- paste0(" & ",
                 h1$se, " & ", h2$se, " & ", h3$se, " & ",
                 d1$se, " & ", d2$se, " & ", d3$se, " & ",
                 i1$se, " & ", i2$se, " & ", i3$se, " \\\\")
  paste(row1, row2, sep = "\n")
}

make_single_row_by_dv <- function(var, label_text, res_haw_list, res_dov_list, res_idx_list) {
  make_row_by_dv(label_text, var, var, var, res_haw_list, res_dov_list, res_idx_list)
}

build_mon_stance_table <- function(df, type = c("Quote","Non.Quote"),
                                   use_diffs_infeco, use_diffs_mp, caption_note = "") {
  type <- match.arg(type)
  stem <- if (type == "Quote") "News.Monetary.Quote" else "News.Monetary.Non.Quote"
  
  # --- models (unchanged) ---
  fit_no_controls_haw <- lm(as.formula(
    paste0(stem,".Hawkish ~ ", stem,".Hawkish.Lag1 + ", stem,".Hawkish.Lag2 + ", stem,".Hawkish.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_haw <- lm(as.formula(
    paste0(stem,".Hawkish ~ ", stem,".Hawkish.Lag1 + ", stem,".Hawkish.Lag2 + ", stem,".Hawkish.Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference")), df)
  fit_all_controls_haw <- lm(as.formula(
    paste0(stem,".Hawkish ~ ", stem,".Hawkish.Lag1 + ", stem,".Hawkish.Lag2 + ", stem,".Hawkish.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference + ",
           "DAX.difference + VDAX + Unmon")), df)
  
  fit_no_controls_dov <- lm(as.formula(
    paste0(stem,".Dovish ~ ", stem,".Dovish.Lag1 + ", stem,".Dovish.Lag2 + ", stem,".Dovish.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_dov <- lm(as.formula(
    paste0(stem,".Dovish ~ ", stem,".Dovish.Lag1 + ", stem,".Dovish.Lag2 + ", stem,".Dovish.Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference")), df)
  fit_all_controls_dov <- lm(as.formula(
    paste0(stem,".Dovish ~ ", stem,".Dovish.Lag1 + ", stem,".Dovish.Lag2 + ", stem,".Dovish.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
           "ED.Exchange.Rate.difference + Unmon")), df)
  
  fit_no_controls_ind <- lm(as.formula(
    paste0(stem,".Index ~ ", stem,".Index.Lag1 + ", stem,".Index.Lag2 + ", stem,".Index.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_ind <- lm(as.formula(
    paste0(stem,".Index ~ ", stem,".Index.Lag1 + ", stem,".Index.Lag2 + ", stem,".Index.Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference")), df)
  fit_all_controls_ind <- lm(as.formula(
    paste0(stem,".Index ~ ", stem,".Index.Lag1 + ", stem,".Index.Lag2 + ", stem,".Index.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
           "ED.Exchange.Rate.difference + Unmon")), df)
  
  res_haw_list <- list(nw_results(fit_no_controls_haw), nw_results(fit_macro_haw), nw_results(fit_all_controls_haw))
  res_dov_list <- list(nw_results(fit_no_controls_dov), nw_results(fit_macro_dov), nw_results(fit_all_controls_dov))
  res_idx_list <- list(nw_results(fit_no_controls_ind), nw_results(fit_macro_ind), nw_results(fit_all_controls_ind))
  
  # footer stats
  adj <- function(m) round(summary(m)$adj.r.squared, 3)
  n_   <- function(m) nobs(m)
  adj_r2 <- c(adj(fit_no_controls_haw), adj(fit_macro_haw), adj(fit_all_controls_haw),
              adj(fit_no_controls_dov), adj(fit_macro_dov), adj(fit_all_controls_dov),
              adj(fit_no_controls_ind), adj(fit_macro_ind), adj(fit_all_controls_ind))
  obs_   <- c(n_(fit_no_controls_haw), n_(fit_macro_haw), n_(fit_all_controls_haw),
              n_(fit_no_controls_dov), n_(fit_macro_dov), n_(fit_all_controls_dov),
              n_(fit_no_controls_ind), n_(fit_macro_ind), n_(fit_all_controls_ind))
  
  var_label <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  my_other_vars <- c(
    "ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
    "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.","German.Inflation.Year.on.Year.difference",
    "Reuter.Poll.Forecast.difference","German.Industrial.Production.Gap","Germany.Unemployment.difference",
    "Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco","ECB.MRO.difference",
    "whatever","negative","ECB.MRO.POS","ECB.MRO.NEG","Unmon","DAX.difference","VDAX","ED.Exchange.Rate.difference",
    "(Intercept)"
  )
  
  # --- LaTeX (new wrapper + new column order) ---
  txt <- ""
  txt <- paste0(txt, "\\noindent\n\\begin{minipage}{\\textwidth}\n")
  txt <- paste0(txt, "\\begin{adjustbox}{angle=0,center}\n")
  txt <- paste0(txt, "\\resizebox{0.8\\textheight}{!}{\n")
  txt <- paste0(txt, "\\begin{threeparttable}\n\\tiny\n\\setlength{\\tabcolsep}{3.5pt}\n")
  txt <- paste0(txt,"\\caption{Monetary News (", ifelse(type=="Quote","Quote","Non-Quote"),
                ") - Monetary Stance ", caption_note,"}\n")
  txt <- paste0(txt,"\\label{tab:mon_stance_", ifelse(type=="Quote","quote","nonquote"), "_",
                ifelse(use_diffs_mp,"mpdiff","mplevel"),"_", ifelse(use_diffs_infeco,"infecodiff","infecolevel"),"}\n")
  
  txt <- paste0(txt,"\\begin{tabular}{lccccccccc}\n")
  txt <- paste0(
    txt,
    "\\multicolumn{1}{l}{\\textbf{$y_t$}} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Hawkish}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Dovish}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Stance}}}$} \\\\\n"
  )
  txt <- paste0(txt,"\\midrule\n")
  
  # lags
  txt <- paste0(txt, make_row_by_dv("$y_{t-1}$",
                                    paste0(stem,".Hawkish.Lag1"), paste0(stem,".Dovish.Lag1"), paste0(stem,".Index.Lag1"),
                                    res_haw_list, res_dov_list, res_idx_list), "\n")
  txt <- paste0(txt, make_row_by_dv("$y_{t-2}$",
                                    paste0(stem,".Hawkish.Lag2"), paste0(stem,".Dovish.Lag2"), paste0(stem,".Index.Lag2"),
                                    res_haw_list, res_dov_list, res_idx_list), "\n")
  txt <- paste0(txt, make_row_by_dv("$y_{t-3}$",
                                    paste0(stem,".Hawkish.Lag3"), paste0(stem,".Dovish.Lag3"), paste0(stem,".Index.Lag3"),
                                    res_haw_list, res_dov_list, res_idx_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # other regressors (same order as before)
  for (v in my_other_vars) {
    if (! v %in% names(var_label)) next
    txt <- paste0(txt, make_single_row_by_dv(v, var_label[v], res_haw_list, res_dov_list, res_idx_list), "\n")
  }
  
  # footer (now three blocks of 3; we print as 9 cells)
  txt <- paste0(txt,"\\midrule\n")
  txt <- paste0(txt, "Adjusted $R^2$ & ",
                paste(adj_r2, collapse = " & "), " \\\\\n")
  txt <- paste0(txt, "Obs. & ",
                paste(obs_, collapse = " & "), " \\\\\n")
  txt <- paste0(txt,"\\end{tabular}\n")
  txt <- paste0(txt,"\\begin{tablenotes}[flushleft]\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg2} for three measures of monetary‐stance news ",
                ifelse(type=="Quote","with","without"), " ECB quotes: ",
                "$\\mathrm{News \\ MP}_t^{", ifelse(type=="Quote","\\text{Quote}","\\text{NoQuote}"),
                ",\\text{Hawkish}}$, $\\mathrm{News \\ MP}_t^{", ifelse(type=="Quote","\\text{Quote}","\\text{NoQuote}"),
                ",\\text{Dovish}}$, and $\\mathrm{News \\ MP}_t^{", ifelse(type=="Quote","\\text{Quote}","\\text{NoQuote}"),
                ",\\text{Stance}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. ",
                "All specifications include lagged dependent variables and the controls shown. Newey–West standard errors in parentheses. ",
                "***, **, and * denote 1\\%, 5\\%, and 10\\% significance.\n")
  txt <- paste0(txt,"\\end{tablenotes}\n\\end{threeparttable}\n}\n\\end{adjustbox}\n\\end{minipage}\n")
  txt
}

# ---- sentiment full table (Quote or Non-Quote) ----
build_mon_sentiment_table <- function(df, type = c("Quote","Non.Quote"),
                                      use_diffs_infeco, use_diffs_mp, caption_note = "") {
  type <- match.arg(type)
  stem <- if (type == "Quote") "News.Monetary.Quote" else "News.Monetary.Non.Quote"
  
  # --- models (unchanged) ---
  fit_no_controls_pos <- lm(as.formula(
    paste0(stem,".Pos. ~ ", stem,".Pos..Lag1 + ", stem,".Pos..Lag2 + ", stem,".Pos..Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_pos <- lm(as.formula(
    paste0(stem,".Pos. ~ ", stem,".Pos..Lag1 + ", stem,".Pos..Lag2 + ", stem,".Pos..Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference")), df)
  fit_all_controls_pos <- lm(as.formula(
    paste0(stem,".Pos. ~ ", stem,".Pos..Lag1 + ", stem,".Pos..Lag2 + ", stem,".Pos..Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference + ",
           "DAX.difference + VDAX + Unmon")), df)
  
  fit_no_controls_neg <- lm(as.formula(
    paste0(stem,".Neg. ~ ", stem,".Neg..Lag1 + ", stem,".Neg..Lag2 + ", stem,".Neg..Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_neg <- lm(as.formula(
    paste0(stem,".Neg. ~ ", stem,".Neg..Lag1 + ", stem,".Neg..Lag2 + ", stem,".Neg..Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference")), df)
  fit_all_controls_neg <- lm(as.formula(
    paste0(stem,".Neg. ~ ", stem,".Neg..Lag1 + ", stem,".Neg..Lag2 + ", stem,".Neg..Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
           "ED.Exchange.Rate.difference + Unmon")), df)
  
  fit_no_controls_sen <- lm(as.formula(
    paste0(stem,".Sentiment.Index ~ ", stem,".Sentiment.Index.Lag1 + ",
           stem,".Sentiment.Index.Lag2 + ", stem,".Sentiment.Index.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference")), df)
  fit_macro_sen <- lm(as.formula(
    paste0(stem,".Sentiment.Index ~ ", stem,".Sentiment.Index.Lag1 + ",
           stem,".Sentiment.Index.Lag2 + ", stem,".Sentiment.Index.Lag3 + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference")), df)
  fit_all_controls_sen <- lm(as.formula(
    paste0(stem,".Sentiment.Index ~ ", stem,".Sentiment.Index.Lag1 + ",
           stem,".Sentiment.Index.Lag2 + ", stem,".Sentiment.Index.Lag3 + ",
           "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
           "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
           "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
           "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
           "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
           "ED.Exchange.Rate.difference + Unmon")), df)
  
  res_pos_list <- list(nw_results(fit_no_controls_pos), nw_results(fit_macro_pos), nw_results(fit_all_controls_pos))
  res_neg_list <- list(nw_results(fit_no_controls_neg), nw_results(fit_macro_neg), nw_results(fit_all_controls_neg))
  res_sen_list <- list(nw_results(fit_no_controls_sen), nw_results(fit_macro_sen), nw_results(fit_all_controls_sen))
  
  adj <- function(m) round(summary(m)$adj.r.squared, 3)
  n_   <- function(m) nobs(m)
  adj_r2 <- c(adj(fit_no_controls_pos), adj(fit_macro_pos), adj(fit_all_controls_pos),
              adj(fit_no_controls_neg), adj(fit_macro_neg), adj(fit_all_controls_neg),
              adj(fit_no_controls_sen), adj(fit_macro_sen), adj(fit_all_controls_sen))
  obs_   <- c(n_(fit_no_controls_pos), n_(fit_macro_pos), n_(fit_all_controls_pos),
              n_(fit_no_controls_neg), n_(fit_macro_neg), n_(fit_all_controls_neg),
              n_(fit_no_controls_sen), n_(fit_macro_sen), n_(fit_all_controls_sen))
  
  var_label <- make_var_labels(use_diffs_infeco, use_diffs_mp)
  my_other_vars <- c(
    "ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
    "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.","German.Inflation.Year.on.Year.difference",
    "Reuter.Poll.Forecast.difference","German.Industrial.Production.Gap","Germany.Unemployment.difference",
    "Germany.Future.Un.difference","Germany.Future.Fin.difference","Germany.Future.Eco","ECB.MRO.difference",
    "whatever","negative","ECB.MRO.POS","ECB.MRO.NEG","Unmon","DAX.difference","VDAX","ED.Exchange.Rate.difference",
    "(Intercept)"
  )
  
  txt <- ""
  txt <- paste0(txt, "\\noindent\n\\begin{minipage}{\\textwidth}\n")
  txt <- paste0(txt, "\\begin{adjustbox}{angle=0,center}\n")
  txt <- paste0(txt, "\\resizebox{0.8\\textheight}{!}{\n")
  txt <- paste0(txt, "\\begin{threeparttable}\n\\tiny\n\\setlength{\\tabcolsep}{3.5pt}\n")
  txt <- paste0(txt,"\\caption{Monetary News (", ifelse(type=="Quote","Quote","Non-Quote"),
                ") - Monetary Sentiment ", caption_note,"}\n")
  txt <- paste0(txt,"\\label{tab:mon_sentiment_", ifelse(type=="Quote","quote","nonquote"), "_",
                ifelse(use_diffs_mp,"mpdiff","mplevel"),"_", ifelse(use_diffs_infeco,"infecodiff","infecolevel"),"}\n")
  
  txt <- paste0(txt,"\\begin{tabular}{lccccccccc}\n")
  txt <- paste0(
    txt,
    "\\multicolumn{1}{l}{\\textbf{$y_t$}} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NoQuote"), ",Positive}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NoQuote"), ",Negative}}}$} & ",
    "\\multicolumn{3}{c}{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NoQuote"), ",Sentiment}}}$} \\\\\n"
  )
  txt <- paste0(txt,"\\midrule\n")
  
  # lags
  txt <- paste0(txt, make_row_by_dv("$y_{t-1}$",
                                    paste0(stem,".Pos..Lag1"), paste0(stem,".Neg..Lag1"), paste0(stem,".Sentiment.Index.Lag1"),
                                    res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt, make_row_by_dv("$y_{t-2}$",
                                    paste0(stem,".Pos..Lag2"), paste0(stem,".Neg..Lag2"), paste0(stem,".Sentiment.Index.Lag2"),
                                    res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt, make_row_by_dv("$y_{t-3}$",
                                    paste0(stem,".Pos..Lag3"), paste0(stem,".Neg..Lag3"), paste0(stem,".Sentiment.Index.Lag3"),
                                    res_pos_list, res_neg_list, res_sen_list), "\n")
  txt <- paste0(txt,"\\midrule\n")
  
  # regressors
  for (v in my_other_vars) {
    if (! v %in% names(var_label)) next
    txt <- paste0(txt, make_single_row_by_dv(v, var_label[v], res_pos_list, res_neg_list, res_sen_list), "\n")
  }
  
  txt <- paste0(txt,"\\midrule\n")
  txt <- paste0(txt, "Adjusted $R^2$ & ",
                paste(adj_r2, collapse = " & "), " \\\\\n")
  txt <- paste0(txt, "Obs. & ",
                paste(obs_, collapse = " & "), " \\\\\n")
  txt <- paste0(txt,"\\end{tabular}\n")
  txt <- paste0(txt,"\\begin{tablenotes}[flushleft]\\footnotesize\n")
  txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg2} for three measures of monetary‐sentiment news ",
                ifelse(type=="Quote","with","without"), " ECB quotes. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. ",
                "All specifications include lagged dependent variables and the controls shown. Newey–West standard errors in parentheses. ",
                "***, **, and * denote 1\\%, 5\\%, and 10\\% significance.\n")
  txt <- paste0(txt,"\\end{tablenotes}\n\\end{threeparttable}\n}\n\\end{adjustbox}\n\\end{minipage}\n")
  txt
}


build_mon_small_table <- function(df, type = c("Quote","Non.Quote"),
                                  use_diffs_infeco = FALSE, use_diffs_mp = FALSE,
                                  which = c("stance","sentiment")) {
  type <- match.arg(type)
  which <- match.arg(which)
  stem <- if (type == "Quote") "News.Monetary.Quote" else "News.Monetary.Non.Quote"
  
  if (which == "stance") {
    fit_h <- lm(as.formula(
      paste0(stem,".Hawkish ~ ", stem,".Hawkish.Lag1 + ", stem,".Hawkish.Lag2 + ", stem,".Hawkish.Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ",
             "ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ",
             "Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    fit_d <- lm(as.formula(
      paste0(stem,".Dovish ~ ", stem,".Dovish.Lag1 + ", stem,".Dovish.Lag2 + ", stem,".Dovish.Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ",
             "ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ",
             "Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    fit_i <- lm(as.formula(
      paste0(stem,".Index ~ ", stem,".Index.Lag1 + ", stem,".Index.Lag2 + ", stem,".Index.Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ",
             "ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ",
             "Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    # results
    rh <- nw_results(fit_h); rd <- nw_results(fit_d); ri <- nw_results(fit_i)
    vlab <- make_var_labels(use_diffs_infeco, use_diffs_mp)
    
    row3 <- function(label_text, v_h, v_d, v_i) {
      g <- function(res, v) {
        rr <- res[res$varname == v, , drop = FALSE]
        if (nrow(rr) == 0) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
      }
      f1 <- g(rh, v_h); f2 <- g(rd, v_d); f3 <- g(ri, v_i)
      paste0(label_text, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\\\n",
             " & ", f1$se,  " & ", f2$se,  " & ", f3$se,  " \\\\\n")
    }
    
    txt <- ""
    txt <- paste0(txt, "\\begin{table}[H]\n\\footnotesize \n\\centering\n")
    txt <- paste0(txt, "\\caption{Monetary News (", ifelse(type=="Quote","Quote","Non-Quote"),
                  ") — Monetary Stance (All Controls, Compact)}\n")
    txt <- paste0(txt, "\\label{tab:monetary_stance_", ifelse(type=="Quote","quote","nonquote"),
                  "_small_", ifelse(use_diffs_mp,"mpdiff","mplevel"),"_",
                  ifelse(use_diffs_infeco,"infecodiff","infecolevel"),"}\n")
    txt <- paste0(txt, "\\setlength{\\tabcolsep}{1pt}\n")
    txt <- paste0(txt, "\\begin{tabular}{l@{\\hspace{-20pt}}c@{\\hspace{5pt}}c@{\\hspace{5pt}}c}\n")
    txt <- paste0(txt, "\\toprule\n")
    txt <- paste0(
      txt,
      " \\multicolumn{1}{l}{\\textbf{$y_t$}} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Hawkish}}}$} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Dovish}}}$} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\textbf{", ifelse(type=="Quote","Quote","NonQuote"), ",Stance}}}$}\\\\\n"
    )
    txt <- paste0(txt, "\\midrule\n")
    
    # Lags
    txt <- paste0(txt, row3("$y_{t-1}$", paste0(stem,".Hawkish.Lag1"), paste0(stem,".Dovish.Lag1"), paste0(stem,".Index.Lag1")))
    txt <- paste0(txt, row3("$y_{t-2}$", paste0(stem,".Hawkish.Lag2"), paste0(stem,".Dovish.Lag2"), paste0(stem,".Index.Lag2")))
    txt <- paste0(txt, row3("$y_{t-3}$", paste0(stem,".Hawkish.Lag3"), paste0(stem,".Dovish.Lag3"), paste0(stem,".Index.Lag3")))
    
    txt <- paste0(txt, "\\midrule\n")
    
    sel <- c("ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.",
             "ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
             "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.",
             "ECB.MRO.difference",
             "(Intercept)")
    for (v in sel) txt <- paste0(txt, row3(vlab[v], v, v, v))
    
    # Footer
    ar <- function(m) round(summary(m)$adj.r.squared, 3)
    txt <- paste0(txt, "\\midrule\n")
    txt <- paste0(txt, "Adjusted $R^2$ & ", ar(fit_h), " & ", ar(fit_d), " & ", ar(fit_i), " \\\\\n")
    txt <- paste0(txt, "Obs. & ", nobs(fit_h), " & ", nobs(fit_d), " & ", nobs(fit_i), " \\\\\n")
    txt <- paste0(txt, "\\bottomrule\n\\end{tabular}\n")
    txt <- paste0(txt, "\\begin{tablenotes}\n\\footnotesize\n")
    txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg2} for three measures of monetary‐stance news without ECB quotes: $\\mathrm{News \\ MP_t^{NoQuote,Hawkish}}$, $\\mathrm{News \\ MP_t^{NoQuote,Dovish}}$, and $\\mathrm{News \\ MP_t^{NoQuote,Stance}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. All specifications include lagged dependent variables and the two macro controls shown. Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
    txt <- paste0(txt, "\\end{tablenotes}\n\\end{table}\n")
    return(txt)
  } else {

    fit_p <- lm(as.formula(
      paste0(stem,".Pos. ~ ", stem,".Pos..Lag1 + ", stem,".Pos..Lag2 + ", stem,".Pos..Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ",
             "ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ",
             "Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    fit_n <- lm(as.formula(
      paste0(stem,".Neg. ~ ", stem,".Neg..Lag1 + ", stem,".Neg..Lag2 + ", stem,".Neg..Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ",
             "ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ",
             "Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    fit_s <- lm(as.formula(
      paste0(stem,".Sentiment.Index ~ ", stem,".Sentiment.Index.Lag1 + ",
             stem,".Sentiment.Index.Lag2 + ", stem,".Sentiment.Index.Lag3 + ",
             "ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. + ",
             "ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Future.Un.difference + Germany.Future.Eco + ",
             "Germany.Future.Fin.difference + German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference + ",
             "German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference + ",
             "draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX + ",
             "ED.Exchange.Rate.difference + Unmon")), df)
    
    rp <- nw_results(fit_p); rn <- nw_results(fit_n); rs <- nw_results(fit_s)
    vlab <- make_var_labels(use_diffs_infeco, use_diffs_mp)
    
    row3 <- function(label_text, v_p, v_n, v_s) {
      g <- function(res, v) {
        rr <- res[res$varname == v, , drop = FALSE]
        if (nrow(rr) == 0) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
      }
      f1 <- g(rp, v_p); f2 <- g(rn, v_n); f3 <- g(rs, v_s)
      paste0(label_text, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\\\n",
             " & ", f1$se,  " & ", f2$se,  " & ", f3$se,  " \\\\\n")
    }
    
    txt <- ""
    txt <- paste0(txt, "\\begin{table}[H]\n\\footnotesize \n\\centering\n")
    txt <- paste0(txt, "\\caption{Monetary News (", ifelse(type=="Quote","Quote","Non-Quote"),
                  ") — Monetary Sentiment (All Controls, Compact)}\n")
    txt <- paste0(txt, "\\label{tab:monetary_sentiment_", ifelse(type=="Quote","quote","nonquote"),
                  "_small_", ifelse(use_diffs_mp,"mpdiff","mplevel"),"_",
                  ifelse(use_diffs_infeco,"infecodiff","infecolevel"),"}\n")
    txt <- paste0(txt, "\\setlength{\\tabcolsep}{1pt}\n")
    txt <- paste0(txt, "\\begin{tabular}{l@{\\hspace{-35pt}}c@{\\hspace{2pt}}c@{\\hspace{2pt}}c}\n")
    txt <- paste0(txt, "\\toprule\n")
    txt <- paste0(
      txt,
      " \\multicolumn{1}{l}{\\textbf{$y_t$}} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\text{", ifelse(type=="Quote","Quote","NonQuote"), ",Hawkish}}}$} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\text{", ifelse(type=="Quote","Quote","NonQuote"), ",Dovish}}}$} & ",
      "{$\\boldsymbol{\\mathrm{News \\ MP}_t^{\\text{", ifelse(type=="Quote","Quote","NonQuote"), ",Stance}}}$}\\\\\n"
    )
    txt <- paste0(txt, "\\midrule\n")
    
    # Lags
    txt <- paste0(txt, row3("$y_{t-1}$", paste0(stem,".Pos..Lag1"), paste0(stem,".Neg..Lag1"), paste0(stem,".Sentiment.Index.Lag1")))
    txt <- paste0(txt, row3("$y_{t-2}$", paste0(stem,".Pos..Lag2"), paste0(stem,".Neg..Lag2"), paste0(stem,".Sentiment.Index.Lag2")))
    txt <- paste0(txt, row3("$y_{t-3}$", paste0(stem,".Pos..Lag3"), paste0(stem,".Neg..Lag3"), paste0(stem,".Sentiment.Index.Lag3")))
    
    txt <- paste0(txt, "\\midrule\n")
    
    sel <- c("ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.",
             "ECB.PC.Outlook.Up","ECB.PC.Outlook.Down",
             "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.",
             "ECB.MRO.difference",
             "(Intercept)")
    for (v in sel) txt <- paste0(txt, row3(vlab[v], v, v, v))
    
    ar <- function(m) round(summary(m)$adj.r.squared, 3)
    txt <- paste0(txt, "\\midrule\n")
    txt <- paste0(txt, "Adjusted $R^2$ & ", ar(fit_p), " & ", ar(fit_n), " & ", ar(fit_s), " \\\\\n")
    txt <- paste0(txt, "Obs. & ", nobs(fit_p), " & ", nobs(fit_n), " & ", nobs(fit_s), " \\\\\n")
    txt <- paste0(txt, "\\bottomrule\n\\end{tabular}\n")
    txt <- paste0(txt, "\\begin{tablenotes}\n\\footnotesize\n")
    txt <- paste0(txt, "\\item Note: Results from estimating Equation~\\eqref{Reg2} for three measures of monetary‐stance news without ECB quotes: $\\mathrm{News \\ MP_t^{NoQuote,Hawkish}}$, $\\mathrm{News \\ MP_t^{NoQuote,Dovish}}$, and $\\mathrm{News \\ MP_t^{NoQuote,Stance}}$. ECB variables capture the share of sentences on inflation outlook, economic outlook, and monetary stance in press conferences. All specifications include lagged dependent variables and the two macro controls shown. Newey-West standard errors are in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
    txt <- paste0(txt, "\\end{tablenotes}\n\\end{table}\n")
    return(txt)
  }
}

################################################################################
# EXECUTION
################################################################################

# Build the four dataframes (specs)
df_levels       <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)
df_mp_diffs     <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = TRUE)
df_infeco_diffs <- canonize_ecb_pc(data, use_diffs_infeco = TRUE,  use_diffs_mp = FALSE)
df_diffs        <- canonize_ecb_pc(data, use_diffs_infeco = TRUE,  use_diffs_mp = TRUE)

# ===== FULL TABLES =====
# Non-Quote
cat( build_mon_stance_table(df_levels,       type="Non.Quote", use_diffs_infeco=FALSE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco levels)") )
cat( build_mon_sentiment_table(df_levels,    type="Non.Quote", use_diffs_infeco=FALSE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco levels)") )

cat( build_mon_stance_table(df_mp_diffs,     type="Non.Quote", use_diffs_infeco=FALSE, use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco levels)") )
cat( build_mon_sentiment_table(df_mp_diffs,  type="Non.Quote", use_diffs_infeco=FALSE, use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco levels)") )

cat( build_mon_stance_table(df_infeco_diffs, type="Non.Quote", use_diffs_infeco=TRUE,  use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco Diffs)") )
cat( build_mon_sentiment_table(df_infeco_diffs, type="Non.Quote", use_diffs_infeco=TRUE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco Diffs)") )

cat( build_mon_stance_table(df_diffs,        type="Non.Quote", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco Diffs)") )
cat( build_mon_sentiment_table(df_diffs,     type="Non.Quote", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco Diffs)") )

# Quote
cat( build_mon_sentiment_table(df_levels,    type="Quote", use_diffs_infeco=FALSE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco levels)") )
cat( build_mon_stance_table(df_levels,       type="Quote", use_diffs_infeco=FALSE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco levels)") )

cat( build_mon_stance_table(df_mp_diffs,     type="Quote", use_diffs_infeco=FALSE, use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco levels)") )
cat( build_mon_sentiment_table(df_mp_diffs,  type="Quote", use_diffs_infeco=FALSE, use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco levels)") )

cat( build_mon_stance_table(df_infeco_diffs, type="Quote", use_diffs_infeco=TRUE,  use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco Diffs)") )
cat( build_mon_sentiment_table(df_infeco_diffs, type="Quote", use_diffs_infeco=TRUE, use_diffs_mp=FALSE, caption_note="(MP levels; Inf/Eco Diffs)") )

cat( build_mon_stance_table(df_diffs,        type="Quote", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco Diffs)") )
cat( build_mon_sentiment_table(df_diffs,     type="Quote", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE,  caption_note="(MP Diffs; Inf/Eco Diffs)") )

# ===== COMPACT TABLES (All controls) =====
# Non-Quote (stance + sentiment)
cat( build_mon_small_table(df_levels,     type="Non.Quote", which="stance",    use_diffs_infeco=FALSE, use_diffs_mp=FALSE) )
cat( build_mon_small_table(df_levels,     type="Non.Quote", which="sentiment", use_diffs_infeco=FALSE, use_diffs_mp=FALSE) )
cat( build_mon_small_table(df_diffs,      type="Non.Quote", which="stance",    use_diffs_infeco=TRUE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_diffs,      type="Non.Quote", which="sentiment", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_mp_diffs ,      type="Non.Quote", which="stance",    use_diffs_infeco=FALSE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_mp_diffs ,      type="Non.Quote", which="sentiment", use_diffs_infeco=FALSE,  use_diffs_mp=TRUE ) )

# Quote (stance + sentiment)
cat( build_mon_small_table(df_levels,     type="Quote", which="stance",    use_diffs_infeco=FALSE, use_diffs_mp=FALSE) )
cat( build_mon_small_table(df_levels,     type="Quote", which="sentiment", use_diffs_infeco=FALSE, use_diffs_mp=FALSE) )
cat( build_mon_small_table(df_diffs,      type="Quote", which="stance",    use_diffs_infeco=TRUE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_diffs,      type="Quote", which="sentiment", use_diffs_infeco=TRUE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_mp_diffs ,      type="Quote", which="stance",    use_diffs_infeco=FALSE,  use_diffs_mp=TRUE ) )
cat( build_mon_small_table(df_mp_diffs ,      type="Quote", which="sentiment", use_diffs_infeco=FALSE,  use_diffs_mp=TRUE ) )
