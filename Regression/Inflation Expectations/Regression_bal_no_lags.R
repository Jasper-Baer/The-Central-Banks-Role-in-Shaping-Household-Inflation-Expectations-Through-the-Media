library(readxl)
library(dplyr)
library(lmtest)
library(sandwich)
library(stats)
library(zoo)
library(ggplot2)
library(stargazer)
library(car)
library(tseries)
 
DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

# Safe scaling for numeric columns except those explicitly excluded
safe_scale <- function(df, exclude = character()) {
  is_num <- sapply(df, is.numeric)
  is_num[intersect(names(is_num), exclude)] <- FALSE
  df[is_num] <- scale(df[is_num])
  df
}

# Newey–West coeftable -> data.frame
coeftable_df_nw12 <- function(model) {
  ct <- lmtest::coeftest(model, vcov. = sandwich::NeweyWest(model, lag = 12, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname  = rownames(ct),
    estimate = ct[, "Estimate"],
    se       = ct[, "Std. Error"],
    pval     = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

# Signif. codes: map like your script (dot->*, *->**, **->***)
base_sig_code <- function(p) {
  if (p < 0.001) "***"
  else if (p < 0.01) "**"
  else if (p < 0.05) "*"
  else if (p < 0.1) "."
  else ""
}
bump_sig_code <- function(p) {
  x <- base_sig_code(p)
  if (x == ".") "*" else if (x == "*") "**" else if (x == "**") "***" else if (x == "***") "***" else ""
}

fmt_est_se <- function(est, se, p) {
  if (!length(est)) return(list(est = "", se = ""))
  s <- bump_sig_code(p)
  list(est = sprintf("%.3f%s", est, s),
       se  = sprintf("{(%.3f)}", se))
}

# One row (estimate line + SE line) across 6 models
latex_row_6 <- function(label, v, r1, r2, r3, r4, r5, r6) {
  pick <- function(res, var) fmt_est_se(res$estimate[res$varname == var],
                                        res$se[res$varname == var],
                                        res$pval[res$varname == var])
  f1 <- pick(r1, v); f2 <- pick(r2, v); f3 <- pick(r3, v)
  f4 <- pick(r4, v); f5 <- pick(r5, v); f6 <- pick(r6, v)
  
  line1 <- paste0(label, " & ",
                  f1$est, " & ", f2$est, " & ", f3$est, " & ",
                  f4$est, " & ", f5$est, " & ", f6$est, " \\\\")
  line2 <- paste0(" & ",
                  f1$se, " & ", f2$se, " & ", f3$se, " & ",
                  f4$se, " & ", f5$se, " & ", f6$se, " \\\\")
  paste(line1, line2, sep = "\n")
}

###############################################################################
# Data (same filters/transformations as your original)
###############################################################################
data <- read_excel(DATA_PATH) |> data.frame()
data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
data <- data |> dplyr::filter(time >= START_DATE)

# Build 2022 month dummies (Feb–Dec)
rec_months <- seq(as.Date("2022-02-01"), as.Date("2022-12-01"), by = "month")
rec_labels <- paste0("REC_", format(rec_months, "%Y_%m"))
month_tag  <- format(data$time, "%Y-%m")
rec_tags   <- format(rec_months, "%Y-%m")
rec_df     <- as.data.frame(sapply(rec_tags, function(m) as.integer(month_tag == m)))
names(rec_df) <- rec_labels
data <- dplyr::bind_cols(data, rec_df)

dont_scale <- c("draghi","negative","whatever","Unmon",
                "REC_2022_01","REC_2022_02","REC_2022_03","REC_2022_04",
                "REC_2022_05","REC_2022_06","REC_2022_07","REC_2022_08",
                "REC_2022_09","REC_2022_10","REC_2022_11","REC_2022_12")
data <- safe_scale(data, exclude = dont_scale)

# recessions <- list(
#   c(as.Date("2001-02-01"), as.Date("2003-07-01")),
#   c(as.Date("2008-01-01"), as.Date("2009-05-01")),
#   c(as.Date("2020-02-01"), as.Date("2020-05-01"))
# )

recessions <- list(
  c(as.Date("2001-02-01"), as.Date("2003-06-30")),
  c(as.Date("2008-01-01"), as.Date("2009-04-30")),
  c(as.Date("2020-02-01"), as.Date("2020-04-30"))
)

data <- data %>%
  filter(!Reduce(`|`, lapply(recessions, function(r) time >= r[1] & time <= r[2])))

################################################################################

fit_no_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                               German.Inflation.Balanced.difference.Lag1 +
                               German.Inflation.Balanced.difference.Lag2 +
                               German.Inflation.Balanced.difference.Lag3 +
                               News.Inflation.Inc._stored_1 +
                               News.Inflation.Dec._stored_1 +
                               News.Inflation.Pos._stored_1 +
                               News.Inflation.Neg._stored_1 +
                               News.Monetary.Quote.Hawkish_stored_1 +
                               News.Monetary.Quote.Dovish_stored_1 +
                               News.Monetary.Quote.Pos._stored_1 +
                               News.Monetary.Quote.Neg._stored_1 +
                               #REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                               German.Inflation.Year.on.Year.difference +
                               Reuter.Poll.Forecast.difference,
                             data)

fit_no_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                                   German.Inflation.Balanced.difference.Lag1 +
                                   German.Inflation.Balanced.difference.Lag2 +
                                   German.Inflation.Balanced.difference.Lag3 +
                                   News.Inflation.Inc._stored_1 +
                                   News.Inflation.Dec._stored_1 +
                                   News.Inflation.Pos._stored_1 +
                                   News.Inflation.Neg._stored_1 +
                                   News.Monetary.Non.Quote.Hawkish_stored_1 +
                                   News.Monetary.Non.Quote.Dovish_stored_1 +
                                   News.Monetary.Non.Quote.Pos._stored_1 +
                                   News.Monetary.Non.Quote.Neg._stored_1 +
                                   #REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                                   German.Inflation.Year.on.Year.difference +
                                   Reuter.Poll.Forecast.difference,
                                 data)

fit_no_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                                     German.Inflation.Balanced.difference.Lag1 +
                                     German.Inflation.Balanced.difference.Lag2 +
                                     German.Inflation.Balanced.difference.Lag3 +
                                     News.Inflation.Inc._stored_1 +
                                     News.Inflation.Dec._stored_1 +
                                     News.Inflation.Pos._stored_1 +
                                     News.Inflation.Neg._stored_1 +
                                     News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio +
                                     News.Monetary.Quote.Dovish_stored_1*Quote_Ratio +
                                     News.Monetary.Quote.Pos._stored_1*Quote_Ratio +
                                     News.Monetary.Quote.Neg._stored_1*Quote_Ratio +
                                     #REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                                     German.Inflation.Year.on.Year.difference +
                                     Reuter.Poll.Forecast.difference,
                                   data)

fit_all_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                                German.Inflation.Balanced.difference.Lag1 +
                                German.Inflation.Balanced.difference.Lag2 +
                                German.Inflation.Balanced.difference.Lag3 +
                                News.Inflation.Inc._stored_1 +
                                News.Inflation.Dec._stored_1 +
                                News.Inflation.Pos._stored_1 +
                                News.Inflation.Neg._stored_1 +
                                News.Monetary.Quote.Hawkish_stored_1 +
                                News.Monetary.Quote.Dovish_stored_1 +
                                News.Monetary.Quote.Pos._stored_1 +
                                News.Monetary.Quote.Neg._stored_1 +
                                #REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                                
                                Germany.Conf.difference +
                                # Germany.Conf.difference.Lag1 +
                                # Germany.Conf.difference.Lag2 +
                                # Germany.Conf.difference.Lag3 +
                                
                                German.Inflation.Year.on.Year.difference +
                                Reuter.Poll.Forecast.difference +
                                German.Industrial.Production.Gap +
                                Germany.Unemployment.difference +
                                ECB.MRO.difference +
                                draghi + negative + whatever +
                                ECB.MRO.POS + ECB.MRO.NEG +
                                ED.Exchange.Rate.difference + Unmon +
                                DAX.difference + VDAX,
                              data)

fit_all_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                                    German.Inflation.Balanced.difference.Lag1 +
                                    German.Inflation.Balanced.difference.Lag2 +
                                    German.Inflation.Balanced.difference.Lag3 +
                                    News.Inflation.Inc._stored_1 +
                                    News.Inflation.Dec._stored_1 +
                                    News.Inflation.Pos._stored_1 +
                                    News.Inflation.Neg._stored_1 +
                                    News.Monetary.Non.Quote.Hawkish_stored_1 +
                                    News.Monetary.Non.Quote.Dovish_stored_1 +
                                    News.Monetary.Non.Quote.Pos._stored_1 +
                                    News.Monetary.Non.Quote.Neg._stored_1 +
                                   # REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                                    
                                    Germany.Conf.difference +
                                    # Germany.Conf.difference.Lag1 +
                                    # Germany.Conf.difference.Lag2 +
                                    # Germany.Conf.difference.Lag3 +
                                    
                                    German.Inflation.Year.on.Year.difference +
                                    Reuter.Poll.Forecast.difference +
                                    German.Industrial.Production.Gap +
                                    Germany.Unemployment.difference +
                                    ECB.MRO.difference +
                                    draghi + negative + whatever +
                                    ECB.MRO.POS + ECB.MRO.NEG +
                                    ED.Exchange.Rate.difference + Unmon +
                                    DAX.difference + VDAX,
                                  data)

fit_all_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                                      German.Inflation.Balanced.difference.Lag1 +
                                      German.Inflation.Balanced.difference.Lag2 +
                                      German.Inflation.Balanced.difference.Lag3 +
                                      News.Inflation.Inc._stored_1 +
                                      News.Inflation.Dec._stored_1 +
                                      News.Inflation.Pos._stored_1 +
                                      News.Inflation.Neg._stored_1 +
                                      News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio +
                                      News.Monetary.Quote.Dovish_stored_1*Quote_Ratio +
                                      News.Monetary.Quote.Pos._stored_1*Quote_Ratio +
                                      News.Monetary.Quote.Neg._stored_1*Quote_Ratio +
                                      #REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
                                      
                                      Germany.Conf.difference +
                                      # Germany.Conf.difference.Lag1 +
                                      # Germany.Conf.difference.Lag2 +
                                      # Germany.Conf.difference.Lag3 +
                                      
                                      German.Inflation.Year.on.Year.difference +
                                      Reuter.Poll.Forecast.difference +
                                      German.Industrial.Production.Gap +
                                      Germany.Unemployment.difference +
                                      ECB.MRO.difference +
                                      draghi + negative + whatever +
                                      ECB.MRO.POS + ECB.MRO.NEG +
                                      DAX.difference + VDAX +
                                      ED.Exchange.Rate.difference +
                                      Unmon,
                                    data)

fit1 <- fit_no_controls_quotes
fit2 <- fit_no_controls_non_quotes
fit3 <- fit_no_controls_quotes_count
fit4 <- fit_all_controls_quotes
fit5 <- fit_all_controls_non_quotes
fit6 <- fit_all_controls_quotes_count

res1 <- coeftable_df_nw12(fit1)
res2 <- coeftable_df_nw12(fit2)
res3 <- coeftable_df_nw12(fit3)
res4 <- coeftable_df_nw12(fit4)
res5 <- coeftable_df_nw12(fit5)
res6 <- coeftable_df_nw12(fit6)

adj1 <- round(summary(fit1)$adj.r.squared, 3)
adj2 <- round(summary(fit2)$adj.r.squared, 3)
adj3 <- round(summary(fit3)$adj.r.squared, 3)
adj4 <- round(summary(fit4)$adj.r.squared, 3)
adj5 <- round(summary(fit5)$adj.r.squared, 3)
adj6 <- round(summary(fit6)$adj.r.squared, 3)

obs1 <- nobs(fit1); obs2 <- nobs(fit2); obs3 <- nobs(fit3)
obs4 <- nobs(fit4); obs5 <- nobs(fit5); obs6 <- nobs(fit6)

var_lab <- c(
  "German.Inflation.Balanced.difference.Lag1" = "$y_{t-1}$",
  "German.Inflation.Balanced.difference.Lag2" = "$y_{t-2}$",
  "German.Inflation.Balanced.difference.Lag3" = "$y_{t-3}$",
  "News.Inflation.Inc._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Pos._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "News.Monetary.Quote.Hawkish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Pos._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "News.Monetary.Non.Quote.Hawkish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Pos._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "News.Monetary.Quote.Hawkish_stored_1:Quote_Ratio"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Pos._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Neg._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio" = "$\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation",
  "Reuter.Poll.Forecast.difference"          = "$\\Delta$ Prof. Inflation Forecast",
  "German.Industrial.Production.Gap" = "Output Gap",
  "Germany.Unemployment.difference"  = "$\\Delta$ Unemployment Rate",
  
  "REC_2022_03" = "March 2022",
  "REC_2022_04" = "April 2022",
  "REC_2022_05" = "May 2022",
  "REC_2022_06" = "June 2022",
  "REC_2022_07" = "July 2022",
  "REC_2022_08" = "August 2022",
  
  "Germany.Conf.difference"          = "$\\Delta$ Confidence",
  "Germany.Conf.difference.Lag1"          = "$\\Delta$ Confidence t-1",
  "Germany.Conf.difference.Lag2"          = "$\\Delta$ Confidence t-2",
  "Germany.Conf.difference.Lag3"          = "$\\Delta$ Confidence t-3",
  
  
  "ECB.MRO.difference"               = "$\\Delta MRO Rate$",
  "whatever" = "Whatever it Takes",
  "draghi"   = "Draghi",
  "negative" = "Negative Rate",
  "ECB.MRO.POS" = "Positive Interest Surprise",
  "ECB.MRO.NEG" = "Negative Interest Surprise",
  "Unmon"       = "Unconventional MP",
  "DAX.difference" = "$\\Delta$ DAX",
  "VDAX"            = "VDAX",
  "ED.Exchange.Rate.difference" = "$\\Delta$ EURUSD",
  "(Intercept)" = "Constant"
)

all_vars <- c(
  "German.Inflation.Balanced.difference.Lag1",
  "German.Inflation.Balanced.difference.Lag2",
  "German.Inflation.Balanced.difference.Lag3",
  "News.Inflation.Inc._stored_1",
  "News.Inflation.Dec._stored_1",
  "News.Inflation.Pos._stored_1",
  "News.Inflation.Neg._stored_1",
  "News.Monetary.Quote.Hawkish_stored_1",
  "News.Monetary.Quote.Dovish_stored_1",
  "News.Monetary.Quote.Pos._stored_1",
  "News.Monetary.Quote.Neg._stored_1",
  "News.Monetary.Non.Quote.Hawkish_stored_1",
  "News.Monetary.Non.Quote.Dovish_stored_1",
  "News.Monetary.Non.Quote.Pos._stored_1",
  "News.Monetary.Non.Quote.Neg._stored_1",
  "News.Monetary.Quote.Hawkish_stored_1:Quote_Ratio",
  "Quote_Ratio:News.Monetary.Quote.Dovish_stored_1",
  "Quote_Ratio:News.Monetary.Quote.Pos._stored_1",
  "Quote_Ratio:News.Monetary.Quote.Neg._stored_1",
  "Quote_Ratio",
  "German.Inflation.Year.on.Year.difference",
  "Reuter.Poll.Forecast.difference",
  "German.Industrial.Production.Gap",
  "Germany.Unemployment.difference",
  
  "REC_2022_03",
  "REC_2022_04",
  "REC_2022_05",
  "REC_2022_06",
  "REC_2022_07",
  "REC_2022_08",
  
  "Germany.Conf.difference",
  "Germany.Conf.difference.Lag1",
  "Germany.Conf.difference.Lag2",
  "Germany.Conf.difference.Lag3",
  
  "ECB.MRO.difference",
  "draghi",
  "negative",
  "whatever",
  "ECB.MRO.POS",
  "ECB.MRO.NEG",
  "Unmon",
  "DAX.difference",
  "VDAX",
  "ED.Exchange.Rate.difference",
  "(Intercept)"
)

###############################################################################
# LaTeX build (identical structure/labels as your first script)
###############################################################################
out <- ""
out <- paste0(out, "\\begin{adjustbox}{angle=0}\n")
out <- paste0(out, "\\tiny\n\\centering\n")
out <- paste0(out, "\\resizebox{\\linewidth}{!}{\n")
out <- paste0(out, "\\begin{threeparttable}\n")
out <- paste0(out, "\\caption{Inflation Expectations Drivers}\n")
out <- paste0(out, "\\label{inf_drivers}\n")
out <- paste0(out, "\\begin{tabular}{lcccccc}\n")
out <- paste0(out, "& \\textbf{[1]} & \\textbf{[2]} & \\textbf{[3]} & \\textbf{[4]} & \\textbf{[5]} & \\textbf{[6]}  \\\\\n")
out <- paste0(out, "\\midrule\n")
out <- paste0(out, "$y_t$ & \\multicolumn{3}{l}{\\textbf{$\\Delta$ Household Inflation Expectations}} \\\\\n")
out <- paste0(out, "\\midrule\n")
out <- paste0(out, "\\multicolumn{1}{l}{\\textbf{}} & \\multicolumn{4}{c}{\\textbf{No Controls}} & \\multicolumn{2}{c}{\\textbf{All Controls}}  \\\\\n")
out <- paste0(out, "\\cmidrule(lr){2-5} \\cmidrule(lr){6-7}\n")
out <- paste0(out, "& \\textbf{Quotes} & \\textbf{Non-Quotes} & \\textbf{Quotes \\& Count} & \\textbf{Quotes} & \\textbf{Non-Quotes} & \\textbf{Quotes \\& Count}  \\\\\n")
out <- paste0(out, "\\midrule\n")

for (v in all_vars) {
  if (!v %in% names(var_lab)) next
  out <- paste0(out, latex_row_6(var_lab[v], v, res1, res2, res3, res4, res5, res6), "\n")
}

out <- paste0(out, "\\midrule\n")
out <- paste0(out, "Adjusted $R^2$ & ", adj1," & ",adj2," & ",adj3," & ",adj4," & ",adj5," & ",adj6," \\\\\n")
out <- paste0(out, "Obs. & ", obs1," & ",obs2," & ",obs3," & ",obs4," & ",obs5," & ",obs6," \\\\\n")
out <- paste0(out, "\\end{tabular}\n")
out <- paste0(out, "\\begin{tablenotes}\n\\footnotesize\n")
out <- paste0(out, "\\item Note: Results from estimating Equation~\\eqref{eq:Drivers}. All specifications include control variables (see Table~\\ref{Quantitative Data Table}). ``News Inflation'' variables measure shares of sentences on inflation direction or sentiment. ``News MP'' variables measure stance or sentiment of monetary policy news, split into commentary (``NoQuote'') and ECB Quotes. Newey-West standard errors are reported in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
out <- paste0(out, "\\end{tablenotes}\n")
out <- paste0(out, "\\end{threeparttable}}\n")
out <- paste0(out, "\\end{adjustbox}\n")

cat(out)

###############################################################################
# Compact 3-column table (style-only refactor; formulas & output unchanged)
###############################################################################

DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

# ---------- helpers ----------
safe_scale <- function(df, exclude = character()) {
  is_num <- sapply(df, is.numeric)
  is_num[intersect(names(is_num), exclude)] <- FALSE
  df[is_num] <- scale(df[is_num])
  df
}

make_rec_2022_dummies <- function(df) {
  rec_months <- seq(as.Date("2022-02-01"), as.Date("2022-12-01"), by = "month")
  rec_labels <- paste0("REC_", format(rec_months, "%Y_%m"))
  rec_tags   <- format(rec_months, "%Y-%m")
  month_tag  <- format(df$time, "%Y-%m")
  rec_df     <- as.data.frame(sapply(rec_tags, function(m) as.integer(month_tag == m)))
  names(rec_df) <- rec_labels
  dplyr::bind_cols(df, rec_df)
}

coeftable_df_nw12 <- function(model) {
  ct <- lmtest::coeftest(model, vcov. = sandwich::NeweyWest(model, lag = 12, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname  = rownames(ct),
    estimate = ct[, "Estimate"],
    se       = ct[, "Std. Error"],
    pval     = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

# significance mapping identical to your compact block
base_sig_code <- function(p) {
  if (p <= 0.001) "***" else if (p <= 0.01) "**" else if (p <= 0.05) "*" else if (p <= 0.1) "." else ""
}
bump_sig_code <- function(p) {
  x <- base_sig_code(p); if (x==".") "*" else if (x=="*") "**" else if (x=="**") "***" else if (x=="***") "***" else ""
}
fmt_est_se <- function(est, se, p) {
  if (!length(est)) return(list(est = "", se = ""))
  s <- bump_sig_code(p)
  list(est = sprintf("%.3f%s", est, s),
       se  = sprintf("{(%.3f)}", se))
}

latex_row_3 <- function(label, v, r1, r2, r3) {
  pick <- function(res, var) {
    rr <- res[res$varname == var, , drop = FALSE]
    if (!nrow(rr)) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
  }
  f1 <- pick(r1, v); f2 <- pick(r2, v); f3 <- pick(r3, v)
  paste0(
    label, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\n",
    " & ",   f1$se,  " & ", f2$se,  " & ", f3$se,  " \\\n"
  )
}

# ---------- data ----------

#END_DATE = as.Date("2021-02-28")

data <- read_excel(DATA_PATH) |> data.frame()
data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
data <- data |> filter(time >= START_DATE)
#data <- data |> filter(time <= END_DATE)
data <- make_rec_2022_dummies(data)

dont_scale <- c("draghi","negative","whatever","Unmon",
                "REC_2022_01","REC_2022_02","REC_2022_03","REC_2022_04",
                "REC_2022_05","REC_2022_06","REC_2022_07","REC_2022_08",
                "REC_2022_09","REC_2022_10","REC_2022_11","REC_2022_12")
data <- safe_scale(data, exclude = dont_scale)

# ---------- models: EXACTLY your three compact fits ----------
fit1 <- lm(German.Inflation.Balanced.difference ~
             German.Inflation.Balanced.difference.Lag1 +
             German.Inflation.Balanced.difference.Lag2 +
             German.Inflation.Balanced.difference.Lag3 +
             News.Inflation.Inc._stored_1 +
             News.Inflation.Dec._stored_1 +
             News.Inflation.Pos._stored_1 +
             News.Inflation.Neg._stored_1 +
             News.Monetary.Quote.Hawkish_stored_1 +
             News.Monetary.Quote.Dovish_stored_1 +
             News.Monetary.Quote.Pos._stored_1 +
             News.Monetary.Quote.Neg._stored_1 +
             Germany.Conf.difference +
             German.Inflation.Year.on.Year.difference +
             Reuter.Poll.Forecast.difference +
           German.Industrial.Production.Gap +
           Germany.Unemployment.difference +
           ECB.MRO.difference + draghi + negative + whatever +
           ECB.MRO.POS + ECB.MRO.NEG +
           ED.Exchange.Rate.difference + Unmon +
            DAX.difference + VDAX,
           data = data)

fit2 <- lm(German.Inflation.Balanced.difference ~
             German.Inflation.Balanced.difference.Lag1 +
             German.Inflation.Balanced.difference.Lag2 +
             German.Inflation.Balanced.difference.Lag3 +
             # News.Inflation.Inc._stored_1 +
             # News.Inflation.Dec._stored_1 +
             # News.Inflation.Pos._stored_1 +
             # News.Inflation.Neg._stored_1 +
             # News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio +
             # News.Monetary.Quote.Dovish_stored_1*Quote_Ratio +
             # News.Monetary.Quote.Pos._stored_1*Quote_Ratio +
             # News.Monetary.Quote.Neg._stored_1*Quote_Ratio +
             Germany.Conf.difference +
             German.Inflation.Year.on.Year.difference +
          #   Reuter.Poll.Forecast.difference +
             German.Industrial.Production.Gap +
             Germany.Unemployment.difference +
             ECB.MRO.difference + draghi + negative + whatever +
             ECB.MRO.POS + ECB.MRO.NEG +
             DAX.difference + VDAX +
             ED.Exchange.Rate.difference + Unmon,
           data = data)

fit3 <- lm(German.Inflation.Balanced.difference ~
             German.Inflation.Balanced.difference.Lag1 +
             German.Inflation.Balanced.difference.Lag2 +
             German.Inflation.Balanced.difference.Lag3 +
             # News.Inflation.Inc._stored_1 +
             # News.Inflation.Dec._stored_1 +
             # News.Inflation.Pos._stored_1 +
             # News.Inflation.Neg._stored_1 +
             # News.Monetary.Non.Quote.Hawkish_stored_1 +
             # News.Monetary.Non.Quote.Dovish_stored_1 +
             # News.Monetary.Non.Quote.Pos._stored_1 +
             # News.Monetary.Non.Quote.Neg._stored_1 +
             Germany.Conf.difference +
             German.Inflation.Year.on.Year.difference +
          #   Reuter.Poll.Forecast.difference +
             German.Industrial.Production.Gap +
             Germany.Unemployment.difference +
             ECB.MRO.difference + draghi + negative + whatever +
             ECB.MRO.POS + ECB.MRO.NEG +
             ED.Exchange.Rate.difference + Unmon +
             DAX.difference + VDAX,
           data = data)

# ---------- results ----------
res1 <- coeftable_df_nw12(fit1)
res2 <- coeftable_df_nw12(fit2)
res3 <- coeftable_df_nw12(fit3)

adj1 <- round(summary(fit1)$adj.r.squared, 3)
adj2 <- round(summary(fit2)$adj.r.squared, 3)
adj3 <- round(summary(fit3)$adj.r.squared, 3)

obs1 <- nobs(fit1); obs2 <- nobs(fit2); obs3 <- nobs(fit3)

var_lab <- c(
  "German.Inflation.Balanced.difference.Lag1" = "$y_{t-1}$",
  "German.Inflation.Balanced.difference.Lag2" = "$y_{t-2}$",
  "German.Inflation.Balanced.difference.Lag3" = "$y_{t-3}$",
  "News.Inflation.Inc._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Pos._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  
  "News.Monetary.Quote.Hawkish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Pos._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  
  "News.Monetary.Non.Quote.Hawkish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Pos._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg._stored_1"    = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  
  "News.Monetary.Quote.Hawkish_stored_1:Quote_Ratio"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Pos._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Neg._stored_1"     = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}\\cdot \\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio" = "$\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation",
  "Reuter.Poll.Forecast.difference"          = "$\\Delta$ Prof. Inflation Forecast",
  
  "German.Industrial.Production.Gap" = "Output Gap",
  "Germany.Unemployment.difference"  = "$\\Delta$ Unemployment Rate",
  "Germany.Conf.difference"          = "$\\Delta$ Confidence",
  
  "ECB.MRO.difference" = "$\\Delta MRO Rate$",
  "draghi"   = "Draghi",
  "negative" = "Negative Rate",
  "whatever" = "Whatever it Takes",
  "ECB.MRO.POS" = "Positive Interest Surprise",
  "ECB.MRO.NEG" = "Negative Interest Surprise",
  "Unmon"       = "Unconventional MP",
  "DAX.difference" = "$\\Delta$ DAX",
  "VDAX"            = "VDAX",
  "ED.Exchange.Rate.difference" = "$\\Delta$ EURUSD",
  "(Intercept)" = "Constant",
  
  "REC_2022_03" = "REC 2022-03",
  "REC_2022_04" = "REC 2022-04",
  "REC_2022_05" = "REC 2022-05",
  "REC_2022_06" = "REC 2022-06",
  "REC_2022_07" = "REC 2022-07",
  "REC_2022_08" = "REC 2022-08"
)

all_vars <- c(
  "German.Inflation.Balanced.difference.Lag1",
  "German.Inflation.Balanced.difference.Lag2",
  "German.Inflation.Balanced.difference.Lag3",
  
  "News.Inflation.Inc._stored_1",
  "News.Inflation.Dec._stored_1",
  "News.Inflation.Pos._stored_1",
  "News.Inflation.Neg._stored_1",
  
  "News.Monetary.Non.Quote.Hawkish_stored_1",
  "News.Monetary.Non.Quote.Dovish_stored_1",
  "News.Monetary.Non.Quote.Pos._stored_1",
  "News.Monetary.Non.Quote.Neg._stored_1",
  
  "News.Monetary.Quote.Hawkish_stored_1",
  "News.Monetary.Quote.Dovish_stored_1",
  "News.Monetary.Quote.Pos._stored_1",
  "News.Monetary.Quote.Neg._stored_1",
  
  "News.Monetary.Quote.Hawkish_stored_1:Quote_Ratio",
  "Quote_Ratio:News.Monetary.Quote.Dovish_stored_1",
  "Quote_Ratio:News.Monetary.Quote.Pos._stored_1",
  "Quote_Ratio:News.Monetary.Quote.Neg._stored_1",
  "Quote_Ratio",
  
  "German.Inflation.Year.on.Year.difference",
  "Reuter.Poll.Forecast.difference",
  
  "German.Industrial.Production.Gap",
  "Germany.Unemployment.difference",
  "Germany.Conf.difference",
  
  "ECB.MRO.difference",
  "draghi","negative","whatever",
  "ECB.MRO.POS","ECB.MRO.NEG","Unmon",
  "DAX.difference","VDAX","ED.Exchange.Rate.difference",
  
  "(Intercept)",
  
  "REC_2022_03","REC_2022_04","REC_2022_05",
  "REC_2022_06","REC_2022_07","REC_2022_08"
)

out3 <- ""
out3 <- paste0(out3,"\\begin{table}[!ht]\n")
out3 <- paste0(out3,"\\begin{threeparttable}\n")
out3 <- paste0(out3,"\\scriptsize\n")
out3 <- paste0(out3,"\\centering\n")
out3 <- paste0(out3,"\\caption{Household Inflation Expectations Drivers}\n")
out3 <- paste0(out3,"\\label{Final_results}\n")
out3 <- paste0(out3,"\\renewcommand{\\arraystretch}{0.94}\n")
out3 <- paste0(out3,"\\begin{tabularx}{\\textwidth}{l Y Y Y} \n")
out3 <- paste0(out3,"\\toprule\n")
out3 <- paste0(out3,"& \\textbf{[1]} & \\textbf{[2]} & \\textbf{[3]} \\\\\n")
out3 <- paste0(out3,"\\midrule\n")
out3 <- paste0(out3,"$y_t$ & \\multicolumn{3}{c}{$\\Delta$\\textbf{Household Inflation Expectations}} \\\\\n")
out3 <- paste0(out3,"\\midrule\n")

for (v in all_vars) {
  if (!v %in% names(var_lab)) next
  out3 <- paste0(out3, latex_row_3(var_lab[v], v, res1, res2, res3))
}

out3 <- paste0(out3,"\\midrule\n")
out3 <- paste0(out3,"Adjusted $R^2$ & ", adj1, " & ", adj2, " & ", adj3, " \\\\\n")
out3 <- paste0(out3,"Obs. & ", obs1, " & ", obs2, " & ", obs3, " \\\\\n")
out3 <- paste0(out3,"\\bottomrule\n")
out3 <- paste0(out3,"\\end{tabularx}\n")
out3 <- paste0(out3,"\\begin{tablenotes}[flushleft]\n\\footnotesize\n")
out3 <- paste0(out3,"\\item Note: Results from estimating Equation~\\eqref{eq:Drivers}. All specifications include control variables (see Table~\\ref{Quantitative Data Table}). ``News Inflation'' variables measure shares of sentences on inflation direction or sentiment. ``News MP'' variables measure stance or sentiment of monetary policy news, split into commentary (``NoQuote'') and ECB Quotes. Newey-West standard errors are reported in parentheses. ***, **, and * represent statistical significance at 1\\%, 5\\%, and 10\\%, respectively.\n")
out3 <- paste0(out3,"\\end{tablenotes}\n")
out3 <- paste0(out3,"\\end{threeparttable}\n")
out3 <- paste0(out3,"\\end{table}")

cat(out3)

################################################################################

DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

# ---------- helpers ----------
safe_scale <- function(df, exclude = character()) {
  is_num <- sapply(df, is.numeric)
  is_num[intersect(names(is_num), exclude)] <- FALSE
  df[is_num] <- scale(df[is_num])
  df
}

make_rec_2022_dummies <- function(df) {
  rec_months <- seq(as.Date("2022-02-01"), as.Date("2022-12-01"), by = "month")
  rec_labels <- paste0("REC_", format(rec_months, "%Y_%m"))
  rec_tags   <- format(rec_months, "%Y-%m")
  month_tag  <- format(df$time, "%Y-%m")
  rec_df     <- as.data.frame(sapply(rec_tags, function(m) as.integer(month_tag == m)))
  names(rec_df) <- rec_labels
  dplyr::bind_cols(df, rec_df)
}

coeftable_df_nw12 <- function(model) {
  ct <- lmtest::coeftest(model, vcov. = sandwich::NeweyWest(model, lag = 12, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname  = rownames(ct),
    estimate = ct[, "Estimate"],
    se       = ct[, "Std. Error"],
    pval     = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

# significance mapping identical to your compact block
base_sig_code <- function(p) {
  if (p <= 0.001) "***" else if (p <= 0.01) "**" else if (p <= 0.05) "*" else if (p <= 0.1) "." else ""
}
bump_sig_code <- function(p) {
  x <- base_sig_code(p); if (x==".") "*" else if (x=="*") "**" else if (x=="**") "***" else if (x=="***") "***" else ""
}
fmt_est_se <- function(est, se, p) {
  if (!length(est)) return(list(est = "", se = ""))
  s <- bump_sig_code(p)
  list(est = sprintf("%.3f%s", est, s),
       se  = sprintf("{(%.3f)}", se))
}

latex_row_3 <- function(label, v, r1, r2, r3) {
  pick <- function(res, var) {
    rr <- res[res$varname == var, , drop = FALSE]
    if (!nrow(rr)) fmt_est_se(numeric(0), numeric(0), 1) else fmt_est_se(rr$estimate, rr$se, rr$pval)
  }
  f1 <- pick(r1, v); f2 <- pick(r2, v); f3 <- pick(r3, v)
  paste0(
    label, " & ", f1$est, " & ", f2$est, " & ", f3$est, " \\\n",
    " & ",   f1$se,  " & ", f2$se,  " & ", f3$se,  " \\\n"
  )
}

# ---------- data ----------

#END_DATE = as.Date("2021-02-28")

data <- read_excel(DATA_PATH) |> data.frame()
data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
data <- data |> filter(time >= START_DATE)
#data <- data |> filter(time <= END_DATE)
data <- make_rec_2022_dummies(data)

sy <- sd(data$German.Inflation.Balanced.difference, na.rm = TRUE)

beta_dov <- coef(fit1)["News.Monetary.Quote.Dovish_stored_1"]

effect_y_units_per_1sd_x <- beta_dov * sy
effect_y_units_per_1sd_x

beta_inc <- coef(fit1)["News.Inflation.Inc._stored_1"]

effect_y_units_per_1sd_x <- beta_inc * sy
effect_y_units_per_1sd_x

################################################################################

vc1 <- sandwich::NeweyWest(fit1, lag = 12, prewhite = FALSE, adjust = TRUE)

# Restriktionsvektor: beta_Inc - beta_Dec
L <- c(
  "News.Inflation.Inc._stored_1" =  1,
  "News.Inflation.Dec._stored_1" = -1
)

# auf die richtigen Elemente der Koeffizienten / Varianzmatrix abbilden
b_hat   <- coef(fit1)[names(L)]
vc_sub  <- vc1[names(L), names(L)]

# Schätzer, Standardfehler, t-Statistik, p-Wert
diff_est <- sum(L * b_hat)
diff_se  <- sqrt( as.numeric(t(L) %*% vc_sub %*% L) )
t_stat   <- diff_est / diff_se
df       <- fit1$df.residual
p_val    <- 2 * pt(-abs(t_stat), df = df)

cat("H0: beta_Inc - beta_Dec = 0\n")
cat("Estimate:", round(diff_est, 3), 
    " SE:", round(diff_se, 3),
    " t:", round(t_stat, 2),
    " p-value:", round(p_val, 3), "\n")

################################################################################

vc1 <- sandwich::NeweyWest(fit1, lag = 12, prewhite = FALSE, adjust = TRUE)

L <- c(
  "News.Inflation.Inc._stored_1" =  1,
  "News.Inflation.Dec._stored_1" = -1
)

b_hat   <- coef(fit1)[names(L)]
vc_sub  <- vc1[names(L), names(L)]

diff_est <- sum(L * b_hat)
diff_se  <- sqrt( as.numeric(t(L) %*% vc_sub %*% L) )
t_stat   <- diff_est / diff_se
df       <- fit1$df.residual

# one-sided: H1: diff > 0
p_one <- 1 - pt(t_stat, df = df)

cat("H0: beta_Inc - beta_Dec <= 0  vs  H1: > 0\n")
cat("Estimate:", round(diff_est, 3),
    " SE:", round(diff_se, 3),
    " t:", round(t_stat, 2),
    " one-sided p-value:", round(p_one, 3), "\n")