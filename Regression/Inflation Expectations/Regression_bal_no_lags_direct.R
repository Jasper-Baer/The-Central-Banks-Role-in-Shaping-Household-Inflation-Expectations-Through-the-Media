library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

library("lmtest")
library("sandwich")
library("stargazer")
library('car')

#####################################################################################

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

###

# [1]

###

fit_no_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                             + German.Inflation.Balanced.difference.Lag1
                             + German.Inflation.Balanced.difference.Lag2
                             + German.Inflation.Balanced.difference.Lag3
                             
                             + News.Inflation.Inc.
                             + News.Inflation.Dec.
                             + News.Inflation.Pos.
                             + News.Inflation.Neg.
                             
                             + News.Monetary.Quote.Hawkish
                             + News.Monetary.Quote.Dovish
                             + News.Monetary.Quote.Pos.
                             + News.Monetary.Quote.Neg.
                             
                             + German.Inflation.Year.on.Year.difference
                             + Reuter.Poll.Forecast.difference

                             , data)

###

# [2]

###

fit_no_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                                 + German.Inflation.Balanced.difference.Lag1
                                 + German.Inflation.Balanced.difference.Lag2
                                 + German.Inflation.Balanced.difference.Lag3
                                 
                                 + News.Inflation.Inc.
                                 + News.Inflation.Dec.
                                 + News.Inflation.Pos.
                                 + News.Inflation.Neg.
                                 
                                 + News.Monetary.Non.Quote.Hawkish
                                 + News.Monetary.Non.Quote.Dovish
                                 + News.Monetary.Non.Quote.Pos.
                                 + News.Monetary.Non.Quote.Neg.
                                 
                                 + German.Inflation.Year.on.Year.difference
                                 + Reuter.Poll.Forecast.difference
                                 
                                 , data)

###

# [3]

###

fit_no_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                           + German.Inflation.Balanced.difference.Lag1
                           + German.Inflation.Balanced.difference.Lag2
                           + German.Inflation.Balanced.difference.Lag3
                           
                           + News.Inflation.Inc.
                           + News.Inflation.Dec.
                           + News.Inflation.Pos.
                           + News.Inflation.Neg.
                           
                           + News.Monetary.Quote.Hawkish*Quote_Ratio 
                           + News.Monetary.Quote.Dovish*Quote_Ratio 
                           + News.Monetary.Quote.Pos.*Quote_Ratio 
                           + News.Monetary.Quote.Neg.*Quote_Ratio 
                           
                           + German.Inflation.Year.on.Year.difference
                           + Reuter.Poll.Forecast.difference
                           
                           , data)

###

# [4]

###

fit_all_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                                   + German.Inflation.Balanced.difference.Lag1
                                   + German.Inflation.Balanced.difference.Lag2
                                   + German.Inflation.Balanced.difference.Lag3
                                   
                                   + News.Inflation.Inc.
                                   + News.Inflation.Dec.
                                   + News.Inflation.Pos.
                                   + News.Inflation.Neg.
                                   
                                   + News.Monetary.Quote.Hawkish
                                   + News.Monetary.Quote.Dovish
                                   + News.Monetary.Quote.Pos.
                                   + News.Monetary.Quote.Neg.
                                   
                              + Germany.Conf.difference 
                              
                              + German.Inflation.Year.on.Year.difference
                              + Reuter.Poll.Forecast.difference
                              
                              + German.Industrial.Production.Gap
                              + Germany.Unemployment.difference
                              
                              + ECB.MRO.difference
                              + draghi
                              + negative
                              + whatever
                              
                              + ECB.MRO.POS
                              + ECB.MRO.NEG
                              + ED.Exchange.Rate.difference
                              + Unmon
                              + DAX.difference
                              + VDAX
                                   
                                   , data)


###

# [5]

###

fit_all_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                              + German.Inflation.Balanced.difference.Lag1
                              + German.Inflation.Balanced.difference.Lag2
                              + German.Inflation.Balanced.difference.Lag3
                              
                              + News.Inflation.Inc.
                              + News.Inflation.Dec.
                              + News.Inflation.Pos.
                              + News.Inflation.Neg.
                              
                              + News.Monetary.Non.Quote.Hawkish
                              + News.Monetary.Non.Quote.Dovish
                              + News.Monetary.Non.Quote.Pos.
                              + News.Monetary.Non.Quote.Neg.
                              
                              + Germany.Conf.difference 
                              
                              + German.Inflation.Year.on.Year.difference
                              + Reuter.Poll.Forecast.difference
                              
                              + German.Industrial.Production.Gap
                              + Germany.Unemployment.difference
                              
                              + ECB.MRO.difference
                              + draghi
                              + negative
                              + whatever
                              
                              + ECB.MRO.POS
                              + ECB.MRO.NEG
                              + ED.Exchange.Rate.difference
                              + Unmon
                              
                              + DAX.difference
                              + VDAX
                              
                              , data)

###

# [6]

###

fit_all_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                                    + German.Inflation.Balanced.difference.Lag1
                                    + German.Inflation.Balanced.difference.Lag2
                                    + German.Inflation.Balanced.difference.Lag3
                                    
                                    + News.Inflation.Inc.
                                    + News.Inflation.Dec.
                                    + News.Inflation.Pos.
                                    + News.Inflation.Neg.
                                    
                                    + News.Monetary.Quote.Hawkish*Quote_Ratio 
                                    + News.Monetary.Quote.Dovish*Quote_Ratio 
                                    + News.Monetary.Quote.Pos.*Quote_Ratio 
                                    + News.Monetary.Quote.Neg.*Quote_Ratio 
                                    
                                    + Germany.Conf.difference 
                                    
                                    + German.Inflation.Year.on.Year.difference
                                    
                                    + Reuter.Poll.Forecast.difference
                                    
                                    + German.Industrial.Production.Gap
                                    + Germany.Unemployment.difference
                                    
                                    + ECB.MRO.difference
                                    + draghi
                                    + negative
                                    + whatever
                                    
                                    + ECB.MRO.POS
                                    + ECB.MRO.NEG
                                    
                                    + DAX.difference
                                    + VDAX
                                    
                                    + ED.Exchange.Rate.difference
                                    
                                    + Unmon
                                    
                                    , data)

################################################################################

fit1 <- fit_no_controls_quotes      # [1] 
fit2 <- fit_no_controls_non_quotes  # [2] 
fit3 <- fit_no_controls_quotes_count# [3] 
fit4 <- fit_all_controls_quotes     # [4] 
fit5 <- fit_all_controls_non_quotes   # [5] 
fit6 <- fit_all_controls_quotes_count # [6]

get_res <- function(fit_obj) {
  co <- coeftest(fit_obj, vcov.=NeweyWest(lag = 12, fit_obj, prewhite=FALSE, adjust=TRUE))
  data.frame(
    varname  = rownames(co),
    estimate = co[, "Estimate"],
    se       = co[, "Std. Error"],
    pval     = co[, "Pr(>|t|)"],
    stringsAsFactors=FALSE
  )
}

res1 <- get_res(fit1)
res2 <- get_res(fit2)
res3 <- get_res(fit3)
res4 <- get_res(fit4)
res5 <- get_res(fit5)
res6 <- get_res(fit6)

adj1 <- round(summary(fit1)$adj.r.squared,3)
adj2 <- round(summary(fit2)$adj.r.squared,3)
adj3 <- round(summary(fit3)$adj.r.squared,3)
adj4 <- round(summary(fit4)$adj.r.squared,3)
adj5 <- round(summary(fit5)$adj.r.squared,3)
adj6 <- round(summary(fit6)$adj.r.squared,3)

obs1 <- nobs(fit1)
obs2 <- nobs(fit2)
obs3 <- nobs(fit3)
obs4 <- nobs(fit4)
obs5 <- nobs(fit5)
obs6 <- nobs(fit6)

base_sig_code <- function(p) {
  if (p < 0.001) return("***")
  else if (p < 0.01) return("**")
  else if (p < 0.05) return("*")
  else if (p < 0.1) return(".")
  else return("")
}
custom_sig_code <- function(p) {
  x <- base_sig_code(p)
  if (x==".") return("*")
  if (x=="*") return("**")
  if (x=="**") return("***")
  if (x=="***") return("***")
  ""
}

fmt_est_se <- function(est, se, p) {
  if (!length(est)) return(list(est="",se=""))
  s <- custom_sig_code(p)
  list(est = sprintf("%.3f%s", est, s),
       se  = sprintf("{(%.3f)}", se))
}

mk_row_6col <- function(var_label, varname,
                        df1, df2, df3, df4, df5, df6) {
  a1 <- df1[df1$varname==varname,]
  a2 <- df2[df2$varname==varname,]
  a3 <- df3[df3$varname==varname,]
  a4 <- df4[df4$varname==varname,]
  a5 <- df5[df5$varname==varname,]
  a6 <- df6[df6$varname==varname,]
  
  r1 <- fmt_est_se(a1$estimate, a1$se, a1$pval)
  r2 <- fmt_est_se(a2$estimate, a2$se, a2$pval)
  r3 <- fmt_est_se(a3$estimate, a3$se, a3$pval)
  r4 <- fmt_est_se(a4$estimate, a4$se, a4$pval)
  r5 <- fmt_est_se(a5$estimate, a5$se, a5$pval)
  r6 <- fmt_est_se(a6$estimate, a6$se, a6$pval)
  
  row1 <- paste0(
    var_label," & ",
    r1$est," & ",r2$est," & ",r3$est," & ",r4$est," & ",r5$est," & ",r6$est,
    " \\\\"
  )
  row2 <- paste0(
    " & ",
    r1$se," & ",r2$se," & ",r3$se," & ",r4$se," & ",r5$se," & ",r6$se,
    " \\\\"
  )
  paste(row1,row2,sep="\n")
}

var_lab <- c(
  "German.Inflation.Balanced.difference.Lag1" = "$y_{t-1}$",
  "German.Inflation.Balanced.difference.Lag2" = "$y_{t-2}$",
  "German.Inflation.Balanced.difference.Lag3" = "$y_{t-3}$",
  
  "News.Inflation.Inc."  = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec."  = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Pos."  = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg."  = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  
  "News.Monetary.Quote.Hawkish"= "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Pos."   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg."   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  
  "News.Monetary.Non.Quote.Hawkish"  = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish"   = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Pos." = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg." = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  
  "News.Monetary.Quote.Hawkish:Quote_Ratio"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Dovish"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Pos." = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Neg." = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  
  "Quote_Ratio" = "$\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation",
  "German.Inflation.Year.on.Year" = "$HICP Inflation",
  "Reuter.Poll.Forecast.difference"          = "$\\Delta$ Prof. Inflation Forecast",
  
  "German.Industrial.Production.Gap" = "Industrial Production Gap",
  "Germany.Unemployment"         = "Unemployment Rate",
  "Germany.Conf.difference"                 = "$\\Delta$ Confidence",
 # "Germany.Future.Un"            = "Unemployment Expectations",
 # "Germany.Future.Fin"           = "Financial Expectations",
 # "Germany.Future.Eco"           = "Economic Expectations",
  
  "Germany.Unemployment.difference"         = "$\\Delta$ Unemployment Rate",
  # "Germany.Conf.difference"                 = "\\Delta$ Confidence",
 # "Germany.Future.Un.difference"            = "$\\Delta$ Unemployment Expectations",
 # "Germany.Future.Fin.difference"           = "$\\Delta$ Financial Expectations",
#  "Germany.Future.Eco.difference"           = "$\\Delta$ Economic Expectations",
  
  "ECB.MRO.difference"            = "$\\Delta MRO Rate$",
  "whatever"           = "Whatever it Takes",
  "draghi"             = "Draghi",
  "negative"           = "Negative Rate",
  "ECB.MRO.POS"        = "Positive Interest Surprise",
  "ECB.MRO.NEG"        = "Negative Interest Surprise",
  "Unmon"              = "Unconventional MP",
  "DAX.difference"                = "$\\Delta$ DAX",
  "VDAX"               = "VDAX",
  "ED.Exchange.Rate.difference"   = "$\\Delta$ EURUSD",
  "(Intercept)"        = "Constant"
)

all_vars <- c(
  "German.Inflation.Balanced.difference.Lag1",
  "German.Inflation.Balanced.difference.Lag2",
  "German.Inflation.Balanced.difference.Lag3",
  
  "News.Inflation.Inc.",
  "News.Inflation.Dec.",
  "News.Inflation.Pos.",
  "News.Inflation.Neg.",
  
  "News.Monetary.Quote.Hawkish",
  "News.Monetary.Quote.Dovish",
  "News.Monetary.Quote.Pos.",
  "News.Monetary.Quote.Neg.",
  
  "News.Monetary.Non.Quote.Hawkish",
  "News.Monetary.Non.Quote.Dovish",
  "News.Monetary.Non.Quote.Pos.",
  "News.Monetary.Non.Quote.Neg.",
  
  "News.Monetary.Quote.Hawkish:Quote_Ratio",
  "Quote_Ratio:News.Monetary.Quote.Dovish",
  "Quote_Ratio:News.Monetary.Quote.Pos.",
  "Quote_Ratio:News.Monetary.Quote.Neg.",
  
  "Quote_Ratio",
  
  "German.Inflation.Year.on.Year.difference",
  "Reuter.Poll.Forecast.difference",
  
  "German.Industrial.Production.Gap",
  "Germany.Unemployment.difference",
  "Germany.Conf.difference",
#  "Germany.Future.Un.difference",
#  "Germany.Future.Eco.difference",
#  "Germany.Future.Eco",
#  "Germany.Future.Fin.difference",
  
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

out_txt <- ""
out_txt <- paste0(out_txt,"\\begin{adjustbox}{angle=0}\n")
out_txt <- paste0(out_txt,"\\tiny\n\\centering\n")
out_txt <- paste0(out_txt,"\\resizebox{\\linewidth}{!}{\n")
out_txt <- paste0(out_txt,"\\begin{threeparttable}\n")
out_txt <- paste0(out_txt,"\\caption{Inflation Expectations Drivers}\n")
out_txt <- paste0(out_txt,"\\label{inf_drivers}\n")
out_txt <- paste0(out_txt,"\\begin{tabular}{lcccccc}\n")
out_txt <- paste0(
  out_txt,
  "& \\textbf{[1]} & \\textbf{[2]} & \\textbf{[3]} & \\textbf{[4]} & \\textbf{[5]} & \\textbf{[6]}  \\\\\n"
)
out_txt <- paste0(
  out_txt,
  "\\multicolumn{1}{l}{\\textbf{}} & \\multicolumn{4}{c}{\\textbf{No Controls}} & \\multicolumn{2}{c}{\\textbf{All Controls}}  \\\\\n"
)
out_txt <- paste0(
  out_txt,
  "\\cmidrule(lr){2-5} \\cmidrule(lr){6-7}\n",
  "& \\textbf{Quotes} & \\textbf{Non-Quotes} & \\textbf{Both} & \\textbf{Quotes \\& Count} & \\textbf{Quotes} & \\textbf{Quotes \\& Count}  \\\\\n"
)
out_txt <- paste0(out_txt,"\\midrule\n")

for (v in all_vars) {
  if (! v %in% names(var_lab)) next
  row_6 <- mk_row_6col(
    var_label = var_lab[v], 
    varname   = v,
    df1=res1, df2=res2, df3=res3, df4=res4, df5=res5, df6=res6
  )
  if (nchar(row_6)>0) out_txt <- paste0(out_txt, row_6, "\n")
}

out_txt <- paste0(out_txt,"\\midrule\n")
out_txt <- paste0(
  out_txt,
  "Adjusted $R^2$ & ",
  adj1," & ",adj2," & ",adj3," & ",adj4," & ",adj5," & ",adj6,
  " \\\\\n"
)
out_txt <- paste0(
  out_txt,
  "Obs. & ",
  obs1," & ",obs2," & ",obs3," & ",obs4," & ",obs5," & ",obs6,
  " \\\\\n"
)
out_txt <- paste0(out_txt,"\\end{tabular}\n")
out_txt <- paste0(out_txt,"\\begin{tablenotes}\n")
out_txt <- paste0(out_txt,"\\footnotesize\n")
out_txt <- paste0(out_txt,"\\item Note: Newey-West Standard Errors in parenthesis. ***, **, and * represent statistical significance at respectively 1\\%, 5\\%, and 10\\%.\n")
out_txt <- paste0(out_txt,"\\end{tablenotes}\n")
out_txt <- paste0(out_txt,"\\end{threeparttable}}\n")
out_txt <- paste0(out_txt,"\\end{adjustbox}\n")

cat(out_txt)