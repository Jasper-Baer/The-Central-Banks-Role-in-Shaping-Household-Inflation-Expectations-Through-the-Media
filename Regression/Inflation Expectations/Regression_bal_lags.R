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

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
data = data.frame(data)

data = data[12:(nrow(data)),]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

numeric_columns <- sapply(data, is.numeric)

dont_scale_names = c("draghi", "negative", "trichet", "whatever", "Unmon")

numeric_columns[dont_scale_names] <- FALSE

data[numeric_columns] <- scale(data[numeric_columns])

###

# [1]

###

fit_no_controls_quotes <- lm(German.Inflation.Balanced.difference ~
            + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Quote.Hawkish_stored_1
            + News.Monetary.Quote.Dovish_stored_1
            + News.Monetary.Quote.Pos._stored_1
            + News.Monetary.Quote.Neg._stored_1
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            , data)

fit_summary <- summary(fit_no_controls_quotes)
adj_r2 <- fit_summary$adj.r.squared

###

# [2]

###

fit_no_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
              + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Non.Quote.Hawkish_stored_1
            + News.Monetary.Non.Quote.Dovish_stored_1
            + News.Monetary.Non.Quote.Pos._stored_1
            + News.Monetary.Non.Quote.Neg._stored_1
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            , data)

fit_summary <- summary(fit_no_controls_non_quotes)
adj_r2 <- fit_summary$adj.r.squared

###

# [3]

###

fit_no_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
            + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Dovish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Pos._stored_1*Quote_Ratio 
            + News.Monetary.Quote.Neg._stored_1*Quote_Ratio 
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            , data)

fit_summary <- summary(fit_no_controls_both)
adj_r2 <- fit_summary$adj.r.squared

###

# [4]

###

fit_all_controls_quotes <- lm(German.Inflation.Balanced.difference ~
            + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Dovish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Pos._stored_1*Quote_Ratio 
            + News.Monetary.Quote.Neg._stored_1*Quote_Ratio 
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            + German.Industrial.Production.Gap.Lag1
            + Germany.Unemployment.difference.Lag1
            
            + ECB.MRO.difference.Lag1
            + draghi.Lag1
            + negative.Lag1
            + whatever.Lag1
            
            + ECB.MRO.POS.Lag1
            + ECB.MRO.NEG.Lag1
            + ED.Exchange.Rate.difference.Lag1
            + Unmon.Lag1
            + DAX.difference.Lag1
            + VDAX.Lag1
            
            , data)

fit_summary <- summary(fit_no_controls_quotes_count)
adj_r2 <- fit_summary$adj.r.squared

###

# [5]

###

fit_all_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
            + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Quote.Hawkish_stored_1
            + News.Monetary.Quote.Dovish_stored_1
            + News.Monetary.Quote.Pos._stored_1
            + News.Monetary.Quote.Neg._stored_1
            
            + Germany.Future.Un.difference.Lag1
            + Germany.Future.Eco.Lag1
            + Germany.Future.Fin.difference.Lag1
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            + German.Industrial.Production.Gap.Lag1
            + Germany.Unemployment.difference.Lag1
            
            + ECB.MRO.difference.Lag1
            + draghi.Lag1
            + negative.Lag1
            + whatever.Lag1
            
            + ECB.MRO.POS.Lag1
            + ECB.MRO.NEG.Lag1
            + ED.Exchange.Rate.difference.Lag1
            + Unmon.Lag1
            + DAX.difference.Lag1
            + VDAX.Lag1
            
            , data)

fit_summary <- summary(fit_all_controls_quotes)
adj_r2 <- fit_summary$adj.r.squared

###

# [6]

###

fit_all_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
            + German.Inflation.Balanced.difference.Lag1
            + German.Inflation.Balanced.difference.Lag2
            + German.Inflation.Balanced.difference.Lag3
            
            + News.Inflation.Inc._stored_1
            + News.Inflation.Dec._stored_1
            + News.Inflation.Pos._stored_1
            + News.Inflation.Neg._stored_1
            
            + News.Monetary.Quote.Hawkish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Dovish_stored_1*Quote_Ratio 
            + News.Monetary.Quote.Pos._stored_1*Quote_Ratio 
            + News.Monetary.Quote.Neg._stored_1*Quote_Ratio 
            
            + Germany.Future.Un.difference.Lag1
            + Germany.Future.Eco.Lag1
            + Germany.Future.Fin.difference.Lag1
            
            + German.Inflation.Year.on.Year.difference.Lag1
            + Reuter.Poll.Forecast.difference.Lag1
            
            + German.Industrial.Production.Gap.Lag1
            + Germany.Unemployment.difference.Lag1
            
            + ECB.MRO.difference.Lag1
            + draghi.Lag1
            + negative.Lag1
            + whatever.Lag1
            
            + ECB.MRO.POS.Lag1
            + ECB.MRO.NEG.Lag1
            
            + DAX.difference.Lag1
            + VDAX.Lag1
            
            + ED.Exchange.Rate.difference.Lag1
            
            + Unmon.Lag1
            
            , data)

fit_summary <- summary(fit_all_controls_quotes_count)
adj_r2 <- fit_summary$adj.r.squared

################################################################################

fit1 <- fit_no_controls_quotes      # [1] 
fit2 <- fit_no_controls_non_quotes  # [2] 
fit3 <- fit_no_controls_both        # [3] 
fit4 <- fit_no_controls_quotes_count# [4] 
fit5 <- fit_all_controls_quotes     # [5] 
fit6 <- fit_all_controls_quotes_count # [6]

get_res <- function(fit_obj) {
  co <- coeftest(fit_obj, vcov.=NeweyWest(fit_obj, prewhite=FALSE, adjust=TRUE))
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

  "News.Inflation.Inc._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Pos._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  
  "News.Monetary.Quote.Hawkish_stored_1"= "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Pos._stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg._stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  
  "News.Monetary.Non.Quote.Hawkish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Pos._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  
  "News.Monetary.Quote.Hawkish_stored_1:Quote_Ratio"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Pos._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  "Quote_Ratio:News.Monetary.Quote.Neg._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$ $\\cdot$ \\n $\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  
  "Quote_Ratio" = "$\\mathrm{NewsMP}_t^{\\text{QuoteShare}}$",
  
  "German.Inflation.Year.on.Year.difference.Lag1" = "$\\Delta$ HICP Inflation",
  "German.Inflation.Year.on.Year.Lag1" = "$HICP Inflation",
  "Reuter.Poll.Forecast.difference.Lag1"          = "$\\Delta$ Prof. Inflation Forecast",
  
  "German.Industrial.Production.Gap" = "Industrial Production Gap",
  "Germany.Unemployment.Lag1"         = "Unemployment Rate",
#  "Germany.Conf"                 = "Confidence",
  "Germany.Future.Un.Lag1"            = "Unemployment Expectations",
  "Germany.Future.Eco.Lag1"           = "Economic Expectations",
  "Germany.Future.Fin.Lag1"           = "Financial Expectations",
  
  "Germany.Unemployment.difference.Lag1"         = "\\Delta$ Unemployment Rate",
 # "Germany.Conf.difference"                 = "\\Delta$ Confidence",
  "Germany.Future.Un.differenc.Lag1e"            = "\\Delta$ Unemployment Expectations",
 # "Germany.Future.Eco.difference"           = "\\Delta$ Economic Expectations",
  "Germany.Future.Fin.difference.Lag1"           = "\\Delta$ Financial Expectations",
  
  "ECB.MRO.difference.Lag1"            = "$\\Delta MRO Rate$",
  "whatever.Lag1"           = "Whatever it Takes",
  "draghi.Lag1"             = "Draghi",
  "lagarde.Lag1"            = "Lagarde",
  "negative.Lag1"           = "Negative Rate",
  "ECB.MRO.POS.Lag1"        = "Positive Interest Surprise",
  "ECB.MRO.NEG.Lag1"        = "Negative Interest Surprise",
  "Unmon.Lag1"              = "Unconventional MP",
  "DAX.difference.Lag1"                = "$\\Delta$ DAX",
  "VDAX.Lag1"               = "VDAX",
  "ED.Exchange.Rate.difference.Lag1"   = "$\\Delta$ EURUSD",
  "(Intercept)"        = "Constant"
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
  
  "German.Inflation.Year.on.Year.difference.Lag1",
  "Reuter.Poll.Forecast.difference.Lag1",
  
  "German.Industrial.Production.Gap.Lag1",
  "Germany.Unemployment.difference.Lag1",
  #"Germany.Conf.difference",
  "Germany.Future.Un.difference.Lag1",
 # "Germany.Future.Eco.difference",
  "Germany.Future.Eco",
  "Germany.Future.Fin.difference.Lag1",
  
  "ECB.MRO.difference.Lag1",
  "draghi.Lag1",
  "lagarde.Lag1",
  "negative.Lag1",
  "whatever.Lag1",
  "ECB.MRO.POS.Lag1",
  "ECB.MRO.NEG.Lag1",
  "Unmon.Lag1",
  "DAX.difference.Lag1",
  "VDAX.Lag1",
  "ED.Exchange.Rate.difference.Lag1",
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