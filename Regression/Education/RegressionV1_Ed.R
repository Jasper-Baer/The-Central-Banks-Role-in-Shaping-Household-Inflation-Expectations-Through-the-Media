################################################################################
# Libraries
################################################################################
library(readxl)
library(dplyr)
library(lmtest)
library(sandwich)

################################################################################
# Load & prep data
################################################################################
data <- read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
data <- data.frame(data)

data <- data[12:nrow(data), ]

data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))

numeric_columns <- sapply(data, is.numeric)
dont_scale_names <- c("draghi", "negative", "trichet", "whatever", "Unmon")
numeric_columns[dont_scale_names] <- FALSE
data[numeric_columns] <- scale(data[numeric_columns])

################################################################################
# Models
################################################################################

## [1] Primary — No Controls
fit_no_controls_quotes_prim <- lm(
  German.Inflation.Balanced.Primary.difference ~
    German.Inflation.Balanced.Primary.difference.Lag1 +
    German.Inflation.Balanced.Primary.difference.Lag2 +
    German.Inflation.Balanced.Primary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

## [2] Primary — Controls
fit_all_controls_quotes_prim <- lm(
  German.Inflation.Balanced.Primary.difference ~
    German.Inflation.Balanced.Primary.difference.Lag1 +
    German.Inflation.Balanced.Primary.difference.Lag2 +
    German.Inflation.Balanced.Primary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    Germany.Future.Un.difference +
    Germany.Future.Eco +
    Germany.Future.Fin.difference +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap +
    Germany.Unemployment.difference +
    ECB.MRO.difference +
    draghi + negative + whatever +
    ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference +
    Unmon,
  data = data
)

## [3] Secondary — No Controls
fit_no_controls_quotes_secon <- lm(
  German.Inflation.Balanced.Secondary.difference ~
    German.Inflation.Balanced.Secondary.difference.Lag1 +
    German.Inflation.Balanced.Secondary.difference.Lag2 +
    German.Inflation.Balanced.Secondary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

## [4] Secondary — Controls
fit_all_controls_quotes_secon <- lm(
  German.Inflation.Balanced.Secondary.difference ~
    German.Inflation.Balanced.Secondary.difference.Lag1 +
    German.Inflation.Balanced.Secondary.difference.Lag2 +
    German.Inflation.Balanced.Secondary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    Germany.Future.Un.difference +
    Germany.Future.Eco +
    Germany.Future.Fin.difference +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap +
    Germany.Unemployment.difference +
    ECB.MRO.difference +
    draghi + negative + whatever +
    ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference +
    Unmon,
  data = data
)

## [5] Further — No Controls
fit_no_controls_quotes_furth <- lm(
  German.Inflation.Balanced.Further.difference ~
    German.Inflation.Balanced.Further.difference.Lag1 +
    German.Inflation.Balanced.Further.difference.Lag2 +
    German.Inflation.Balanced.Further.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

## [6] Further — Controls
fit_all_controls_quotes_furth <- lm(
  German.Inflation.Balanced.Further.difference ~
    German.Inflation.Balanced.Further.difference.Lag1 +
    German.Inflation.Balanced.Further.difference.Lag2 +
    German.Inflation.Balanced.Further.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    Germany.Future.Un.difference +
    Germany.Future.Eco +
    Germany.Future.Fin.difference +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap +
    Germany.Unemployment.difference +
    ECB.MRO.difference +
    draghi + negative + whatever +
    ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference +
    Unmon,
  data = data
)

################################################################################
# Extract NW(4) robust coefs
################################################################################
get_res <- function(fit_obj) {
  co <- coeftest(fit_obj, vcov. = NeweyWest(fit_obj, lag = 4, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname  = rownames(co),
    estimate = co[, "Estimate"],
    se       = co[, "Std. Error"],
    pval     = co[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

res1 <- get_res(fit_no_controls_quotes_prim)
res2 <- get_res(fit_all_controls_quotes_prim)
res3 <- get_res(fit_no_controls_quotes_secon)
res4 <- get_res(fit_all_controls_quotes_secon)
res5 <- get_res(fit_no_controls_quotes_furth)
res6 <- get_res(fit_all_controls_quotes_furth)

adj1 <- round(summary(fit_no_controls_quotes_prim)$adj.r.squared, 3)
adj2 <- round(summary(fit_all_controls_quotes_prim)$adj.r.squared, 3)
adj3 <- round(summary(fit_no_controls_quotes_secon)$adj.r.squared, 3)
adj4 <- round(summary(fit_all_controls_quotes_secon)$adj.r.squared, 3)
adj5 <- round(summary(fit_no_controls_quotes_furth)$adj.r.squared, 3)
adj6 <- round(summary(fit_all_controls_quotes_furth)$adj.r.squared, 3)

obs1 <- nobs(fit_no_controls_quotes_prim)
obs2 <- nobs(fit_all_controls_quotes_prim)
obs3 <- nobs(fit_no_controls_quotes_secon)
obs4 <- nobs(fit_all_controls_quotes_secon)
obs5 <- nobs(fit_no_controls_quotes_furth)
obs6 <- nobs(fit_all_controls_quotes_furth)

################################################################################
# Formatting helpers
################################################################################
base_sig_code <- function(p) {
  if (p < 0.001) return("***")
  else if (p < 0.01) return("**")
  else if (p < 0.05) return("*")
  else if (p < 0.1) return(".")
  else return("")
}

# Upgrade '.' to '*' etc., as in your code
custom_sig_code <- function(p) {
  x <- base_sig_code(p)
  if (x == ".") return("*")
  if (x == "*") return("**")
  if (x == "**") return("***")
  if (x == "***") return("***")
  ""
}

fmt_est_se <- function(est, se, p) {
  if (!length(est)) return(list(est = "", se = ""))
  s <- custom_sig_code(p)
  list(
    est = sprintf("%.3f%s", est, s),
    se  = sprintf("{(%.3f)}", se)
  )
}

# For non-lag regressors: same varname across all 6 fits
mk_row_6col <- function(var_label, varname, df1, df2, df3, df4, df5, df6) {
  grab <- function(df, vn) {
    a <- df[df$varname == vn, ]
    if (!nrow(a)) return(list(est = "", se = ""))
    fmt_est_se(a$estimate, a$se, a$pval)
  }
  r1 <- grab(df1, varname); r2 <- grab(df2, varname); r3 <- grab(df3, varname)
  r4 <- grab(df4, varname); r5 <- grab(df5, varname); r6 <- grab(df6, varname)
  row1 <- paste0(var_label, " & ", r1$est, " & ", r2$est, " & ", r3$est, " & ", r4$est, " & ", r5$est, " & ", r6$est, " \\\\")
  row2 <- paste0(" & ", r1$se, " & ", r2$se, " & ", r3$se, " & ", r4$se, " & ", r5$se, " & ", r6$se, " \\\\")
  paste(row1, row2, sep = "\n")
}

# For the lagged dependent variable: different varname per column
mk_row_6col_by_names <- function(var_label, v1, v2, v3, v4, v5, v6, df1, df2, df3, df4, df5, df6) {
  grab <- function(df, vn) {
    if (is.null(vn) || is.na(vn) || !nzchar(vn)) return(list(est = "", se = ""))
    a <- df[df$varname == vn, ]
    if (!nrow(a)) return(list(est = "", se = ""))
    fmt_est_se(a$estimate, a$se, a$pval)
  }
  r1 <- grab(df1, v1); r2 <- grab(df2, v2); r3 <- grab(df3, v3)
  r4 <- grab(df4, v4); r5 <- grab(df5, v5); r6 <- grab(df6, v6)
  row1 <- sprintf("%s & %s & %s & %s & %s & %s & %s \\\\",
                  var_label, r1$est, r2$est, r3$est, r4$est, r5$est, r6$est)
  row2 <- sprintf(" & %s & %s & %s & %s & %s & %s \\\\",
                  r1$se, r2$se, r3$se, r4$se, r5$se, r6$se)
  paste(row1, row2, sep = "\n")
}

################################################################################
# Labels and variable lists
################################################################################
var_lab <- c(
  # LHS lags
  "German.Inflation.Balanced.Primary.difference.Lag1"   = "$y_{t-1}$",
  "German.Inflation.Balanced.Primary.difference.Lag2"   = "$y_{t-2}$",
  "German.Inflation.Balanced.Primary.difference.Lag3"   = "$y_{t-3}$",
  "German.Inflation.Balanced.Secondary.difference.Lag1" = "$y_{t-1}$",
  "German.Inflation.Balanced.Secondary.difference.Lag2" = "$y_{t-2}$",
  "German.Inflation.Balanced.Secondary.difference.Lag3" = "$y_{t-3}$",
  "German.Inflation.Balanced.Further.difference.Lag1"   = "$y_{t-1}$",
  "German.Inflation.Balanced.Further.difference.Lag2"   = "$y_{t-2}$",
  "German.Inflation.Balanced.Further.difference.Lag3"   = "$y_{t-3}$",
  
  # News — Inflation
  "News.Inflation.Inc._stored_1"  = "$\\mathrm{News\\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec._stored_1"  = "$\\mathrm{News\\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Pos._stored_1"  = "$\\mathrm{News\\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg._stored_1"  = "$\\mathrm{News\\ Inflation}_t^{\\text{Negative}}$",
  
  # News — MP (Quotes)
  "News.Monetary.Quote.Hawkish_stored_1" = "$\\mathrm{News\\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish_stored_1"  = "$\\mathrm{News\\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Pos._stored_1"    = "$\\mathrm{News\\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg._stored_1"    = "$\\mathrm{News\\ MP}_t^{\\text{Quote,Negative}}$",
  
  # Controls
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation",
  "Reuter.Poll.Forecast.difference"          = "$\\Delta$ Prof. Inflation Forecast",
  "German.Industrial.Production.Gap"         = "Industrial Production Gap",
  "Germany.Unemployment.difference"          = "$\\Delta$ Unemployment Rate",
  "Germany.Future.Un.difference"             = "$\\Delta$ Unemployment Expectations",
  "Germany.Future.Fin.difference"            = "$\\Delta$ Financial Expectations",
  "Germany.Future.Eco"                       = "Economic Expectations",
  "ECB.MRO.difference"                       = "$\\Delta i$",
  "draghi"                                   = "Draghi",
  "lagarde"                                  = "Lagarde",
  "negative"                                 = "Negative Rate",
  "whatever"                                 = "Whatever it Takes",
  "ECB.MRO.POS"                              = "Positive Interest Surprise",
  "ECB.MRO.NEG"                              = "Negative Interest Surprise",
  "Unmon"                                    = "Unconventional MP",
  "DAX.difference"                           = "$\\Delta$ DAX",
  "VDAX"                                     = "VDAX",
  "ED.Exchange.Rate.difference"              = "$\\Delta$ EURUSD",
  "(Intercept)"                               = "Constant"
)

# All non-lag regressors to print once
all_vars <- c(
  "News.Inflation.Inc._stored_1",
  "News.Inflation.Dec._stored_1",
  "News.Inflation.Pos._stored_1",
  "News.Inflation.Neg._stored_1",
  
  "News.Monetary.Quote.Hawkish_stored_1",
  "News.Monetary.Quote.Dovish_stored_1",
  "News.Monetary.Quote.Pos._stored_1",
  "News.Monetary.Quote.Neg._stored_1",
  
  "German.Inflation.Year.on.Year.difference",
  "Reuter.Poll.Forecast.difference",
  
  "German.Industrial.Production.Gap",
  "Germany.Unemployment.difference",
  "Germany.Future.Un.difference",
  "Germany.Future.Fin.difference",
  "Germany.Future.Eco",
  
  "ECB.MRO.difference",
  "draghi", "lagarde", "negative", "whatever",
  "ECB.MRO.POS", "ECB.MRO.NEG",
  "Unmon",
  "DAX.difference", "VDAX", "ED.Exchange.Rate.difference",
  "(Intercept)"
)

################################################################################
# Build LaTeX table text
# (Ensure your LaTeX preamble has: \usepackage{booktabs,threeparttable,adjustbox})
################################################################################
out_txt <- ""
out_txt <- paste0(out_txt, "\\begin{adjustbox}{center}\n")
out_txt <- paste0(out_txt, "\\tiny\n")
out_txt <- paste0(out_txt, "\\resizebox{0.95\\linewidth}{!}{%\n")
out_txt <- paste0(out_txt, "\\begin{threeparttable}\n")
out_txt <- paste0(out_txt, "\\caption{Inflation Expectations Drivers -- Educational Levels}\n")
out_txt <- paste0(out_txt, "\\label{inf_drivers_edu}\n")
out_txt <- paste0(out_txt, "\\begin{tabular}{lcccccc}\n")
out_txt <- paste0(out_txt, "\\multicolumn{1}{l}{\\textbf{}} & \\textbf{[1]} & \\textbf{[2]} & \\textbf{[3]} & \\textbf{[4]} & \\textbf{[5]} & \\textbf{[6]} \\\\\n")
out_txt <- paste0(out_txt, "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}\n")
out_txt <- paste0(out_txt, " & \\textbf{No Controls} & \\textbf{Controls} & \\textbf{No Controls} & \\textbf{Controls} & \\textbf{No Controls} & \\textbf{Controls} \\\\\n")
out_txt <- paste0(out_txt, "\\multicolumn{1}{l}{\\textbf{}} & \\multicolumn{2}{c}{\\textbf{Primary Education}} & \\multicolumn{2}{c}{\\textbf{Secondary Education}} & \\multicolumn{2}{c}{\\textbf{Further Education}} \\\\\n")
out_txt <- paste0(out_txt, "\\midrule\n")

# Three lag rows ONCE (mapping the correct varname per column)
out_txt <- paste0(out_txt,
                  mk_row_6col_by_names("$y_{t-1}$",
                                       "German.Inflation.Balanced.Primary.difference.Lag1",
                                       "German.Inflation.Balanced.Primary.difference.Lag1",
                                       "German.Inflation.Balanced.Secondary.difference.Lag1",
                                       "German.Inflation.Balanced.Secondary.difference.Lag1",
                                       "German.Inflation.Balanced.Further.difference.Lag1",
                                       "German.Inflation.Balanced.Further.difference.Lag1",
                                       res1,res2,res3,res4,res5,res6), "\n",
                  mk_row_6col_by_names("$y_{t-2}$",
                                       "German.Inflation.Balanced.Primary.difference.Lag2",
                                       "German.Inflation.Balanced.Primary.difference.Lag2",
                                       "German.Inflation.Balanced.Secondary.difference.Lag2",
                                       "German.Inflation.Balanced.Secondary.difference.Lag2",
                                       "German.Inflation.Balanced.Further.difference.Lag2",
                                       "German.Inflation.Balanced.Further.difference.Lag2",
                                       res1,res2,res3,res4,res5,res6), "\n",
                  mk_row_6col_by_names("$y_{t-3}$",
                                       "German.Inflation.Balanced.Primary.difference.Lag3",
                                       "German.Inflation.Balanced.Primary.difference.Lag3",
                                       "German.Inflation.Balanced.Secondary.difference.Lag3",
                                       "German.Inflation.Balanced.Secondary.difference.Lag3",
                                       "German.Inflation.Balanced.Further.difference.Lag3",
                                       "German.Inflation.Balanced.Further.difference.Lag3",
                                       res1,res2,res3,res4,res5,res6), "\n"
)

# Non-lag regressors
for (v in all_vars) {
  if (!v %in% names(var_lab)) next
  row_6 <- mk_row_6col(var_label = var_lab[v], varname = v,
                       df1 = res1, df2 = res2, df3 = res3, df4 = res4, df5 = res5, df6 = res6)
  if (nchar(row_6) > 0) out_txt <- paste0(out_txt, row_6, "\n")
}

# Footer
out_txt <- paste0(out_txt, "\\midrule\n")
out_txt <- paste0(out_txt, "Adjusted $R^2$ & ", adj1, " & ", adj2, " & ", adj3, " & ", adj4, " & ", adj5, " & ", adj6, " \\\\\n")
out_txt <- paste0(out_txt, "Obs. & ", obs1, " & ", obs2, " & ", obs3, " & ", obs4, " & ", obs5, " & ", obs6, " \\\\\n")
out_txt <- paste0(out_txt, "\\end{tabular}\n")
out_txt <- paste0(out_txt, "\\begin{tablenotes}[flushleft]\n")
out_txt <- paste0(out_txt, "\\footnotesize\n")
out_txt <- paste0(out_txt, "\\item Note: Newey--West standard errors (lag 4) in parentheses. Coefficients marked ***, **, and * are significant at the 1\\%, 5\\%, and 10\\% levels, respectively.\n")
out_txt <- paste0(out_txt, "\\end{tablenotes}\n")
out_txt <- paste0(out_txt, "\\end{threeparttable}}\n")  # end resizebox
out_txt <- paste0(out_txt, "\\end{adjustbox}\n")

cat(out_txt)