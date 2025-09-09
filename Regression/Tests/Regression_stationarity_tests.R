library("readxl")
library("urca")
library("dplyr")
library("tidyr")
library("knitr")
library("kableExtra")

data <- read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data <- data.frame(data)
data <- data[12:(nrow(data)),]
data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
n <- nrow(data)
lags <- floor(0.75 * n^(1/3))

variables_to_test <- c(
  "News.Inflation.Direction.Index",
  "News.Inflation.Inc.",
  "News.Inflation.Dec.",
  "News.Inflation.Sentiment.Index",
  "News.Inflation.Pos.",
  "News.Inflation.Neg.",
  "News.Monetary.Non.Quote.Index",
  "News.Monetary.Non.Quote.Hawkish",
  "News.Monetary.Non.Quote.Dovish",
  "News.Monetary.Quote.Index",
  "News.Monetary.Quote.Hawkish",
  "News.Monetary.Quote.Dovish",
  "News.Monetary.Non.Quote.Pos.",
  "News.Monetary.Non.Quote.Neg.",
  "News.Monetary.Non.Quote.Sentiment.Index",
  "News.Monetary.Quote.Pos.",
  "News.Monetary.Quote.Neg.",
  "News.Monetary.Quote.Sentiment.Index",
  
  # "News.Inflation.Direction.Index_stored_1",
  # "News.Inflation.Inc._stored_1",
  # "News.Inflation.Dec._stored_1",
  # "News.Inflation.Sentiment.Index_stored_1",
  # "News.Inflation.Pos._stored_1",
  # "News.Inflation.Neg._stored_1",
  # "News.Monetary.Non.Quote.Index_stored_1",
  # "News.Monetary.Non.Quote.Hawkish_stored_1",
  # "News.Monetary.Non.Quote.Dovish_stored_1",
  # "News.Monetary.Quote.Index_stored_1",
  # "News.Monetary.Quote.Hawkish_stored_1",
  # "News.Monetary.Quote.Dovish_stored_1",
  # "News.Monetary.Non.Quote.Pos._stored_1",
  # "News.Monetary.Non.Quote.Neg._stored_1",
  # "News.Monetary.Non.Quote.Sentiment.Index_stored_1",
  # "News.Monetary.Quote.Pos._stored_1",
  # "News.Monetary.Quote.Neg._stored_1",
  # "News.Monetary.Quote.Sentiment.Index_stored_1",
  
  "Quote_Ratio",
  "ECB.PC.Inflation.Inc.",
  "ECB.PC.Inflation.Dec.",
  "ECB.PC.Inflation.Index",
  "ECB.PC.Monetary.Haw.",
  "ECB.PC.Monetary.Dov.",
  "ECB.PC.Monetary.Index",
  "ECB.PC.Monetary.Haw..difference",
  "ECB.PC.Monetary.Dov..difference",
  "ECB.PC.Monetary.Index.difference",
  "ECB.PC.Outlook.Up",
  "ECB.PC.Outlook.Down",
  "ECB.PC.Outlook.Index",
  "Germany.Unemployment",
  "Germany.Unemployment.difference",
  "German.Industrial.Production.Gap",
  "Germany.Future.Un",
  "Germany.Future.Un.difference",
  "Germany.Future.Eco",
  "Germany.Future.Fin",
  "Germany.Future.Fin.difference",
  "Germany.Conf",
  "Germany.Conf.difference",
  "ECB.MRO",
  "ECB.MRO.difference",
  "ECB.MRO.POS",
  "ECB.MRO.NEG",
  "DAX",
  "DAX.difference",
  "VDAX",
  "ED.Exchange.Rate",
  "ED.Exchange.Rate.difference",
  "Reuter.Poll.Forecast",
  "Reuter.Poll.Forecast.difference",
  "German.Inflation.Year.on.Year",
  "German.Inflation.Year.on.Year.difference",
  "Eurostoxx",
  "Eurostoxx.difference"
)

perform_adf_test <- function(variable_name, data, type = "drift", selectlags = "AIC") {
  adf_test <- ur.df(na.omit(data[[variable_name]]), type = type, selectlags = selectlags)
  test_stat <- adf_test@teststat[,"tau2"]
  crit_vals <- adf_test@cval["tau2", ]
  p_value <- approx(x = crit_vals, y = c(1, 5, 10), xout = test_stat, rule = 2)$y / 100
  list(
    Variable = variable_name,
    Test_Statistic = test_stat,
    `1%` = crit_vals["1pct"],
    `5%` = crit_vals["5pct"],
    `10%` = crit_vals["10pct"],
    Approx_P_Value = p_value
  )
}

adf_results <- lapply(variables_to_test, perform_adf_test, data = data)
adf_results_df <- do.call(rbind, lapply(adf_results, as.data.frame)) %>%
  mutate(Approx_P_Value = round(Approx_P_Value, 4)) %>%
  select(Variable, Test_Statistic, X1., X5., X10., Approx_P_Value)

perform_pp_test <- function(variable_name, data, type = "Z-tau", model = "constant", lags = "long") {
  pp_test <- ur.pp(na.omit(data[[variable_name]]), type = type, model = model, lags = lags)
  test_stat <- pp_test@teststat
  crit_vals <- pp_test@cval
  p_value <- approx(x = crit_vals, y = c(1, 5, 10), xout = test_stat, rule = 2)$y / 100
  list(
    Variable = variable_name,
    Test_Statistic = test_stat,
    `1%` = crit_vals[,"1pct"],
    `5%` = crit_vals[,"5pct"],
    `10%` = crit_vals[,"10pct"],
    Approx_P_Value = p_value
  )
}

pp_results <- lapply(variables_to_test, perform_pp_test, data = data)
pp_results_df <- do.call(rbind, lapply(pp_results, as.data.frame)) %>%
  mutate(Approx_P_Value = round(Approx_P_Value, 4)) %>%
  select(Variable, Test_Statistic, X1., X5., X10., Approx_P_Value)

merged_df <- adf_results_df %>%
  rename(ADF_Stat = Test_Statistic, ADF_pval = Approx_P_Value) %>%
  inner_join(pp_results_df %>%
               rename(PP_Stat = Test_Statistic, PP_pval = Approx_P_Value),
             by = "Variable")

bold_if_significant <- function(stat_value, p_val, digits = 3) {
  val_str <- format(round(stat_value, digits), nsmall = digits)
  if (!is.na(p_val) && p_val < 0.05) {
    paste0("\\textbf{", val_str, "}")
  } else {
    val_str
  }
}

merged_df <- merged_df %>%
  mutate(
    ADF_Stat_fmt = mapply(bold_if_significant, ADF_Stat, ADF_pval),
    PP_Stat_fmt  = mapply(bold_if_significant, PP_Stat, PP_pval)
  )

################################################################################

variable_order <- c(
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{QuoteShare}$", 
  
  "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$",
  "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$",
  "$\\mathrm{ECB \\ Inflation_t^{Outlook}}$",
  
  "$\\mathrm{ECB \\ MP_t^{Hawkish}}$",
  "$\\mathrm{ECB \\ MP_t^{Dovish}}$",
  "$\\mathrm{ECB \\ MP_t^{Stance}}$",
  
  "$\\Delta \\mathrm{ECB \\ MP_t^{Hawkish}}$",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Dovish}}$",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Stance}}$",
  
  "$\\mathrm{ECB \\ Economy_t^{Increasing}}$",
  "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$",
  "$\\mathrm{ECB \\ Economy_t^{Outlook}}$",
  
#   "News - Inflation Inc.",
#  # "News - Inflation Stable",
#   "News - Inflation Dec.",
#   "News - Inflation Direction Index",
#   "News - Inflation Pos.",
#  # "News - Inflation Neut.",
#   "News - Inflation Neg.",
#   "News - Inflation Sentiment Index",
#   "News - Monetary Hawkish - Quotes",
#  # "News - Monetary Stable - Quotes",
#   "News - Monetary Dovish - Quotes",
#   "News - Monetary Stance Index - Quotes",
#   "News - Monetary Hawkish - Non Quotes",
# #  "News - Monetary Stable - Non Quotes",
#   "News - Monetary Dovish - Non  Quotes",
#   "News - Monetary Stance Index - Non Quotes",
#   "News - Monetary Pos. - Quotes",
# #  "News - Monetary Neut. - Quotes",
#   "News - Monetary Neg. - Quotes",
#   "News - Monetary Sentiment Index - Quotes",
#   "News - Monetary Pos. - Non Quotes",
#  # "News - Monetary Neut. - Non Quotes",
#   "News - Monetary Neg. - Non Quotes",
#   "News - Monetary Sentiment Index - Non  Quotes",
#   "ECB - Inflation Inc.",
# #  "ECB - Inflation Stable",
#   "ECB - Inflation Dec.",
#   "ECB - Monetary Hawkish",
#  # "ECB - Monetary Neutral",
#   "ECB - Monetary Dovish",
#   "ECB - Economic Outlook Inc.",
#  # "ECB - Economic Outlook Stable",
#   "ECB - Economic Outlook Dec.",
  "MRO rate",
  "$\\Delta$ MRO rate",
  "Positive Interest Rate Surprise",
  "Negative Interest Rate Surprise",
  "DAX",
  "$\\Delta$ DAX",
  "VDAX",
  "EUROUSD",
  "$\\Delta$ EUROUSD",
  "Professional Inflation Forecast",
  "$\\Delta$ Professional Inflation Forecast",
  "Household Inflation Expectations",
  "$\\Delta$ Household Inflation Expectations",
  "HICP Inflation",
  "$\\Delta$ HICP Inflation",
  "output Gap",
  "Unemployment Rate",
  "$\\Delta$ Unemployment Rate",
  "Confidence",
  "$\\Delta$ Confidence",
  "Unemployment Expectations",
  "$\\Delta$ Unemployment Expectations",
  "Financial Expectations",
  "$\\Delta$ Financial Expectations",
  "Economic Expectations",
  "Eurostoxx",
  "Eurostoxx.difference"
)

################################################################################

name_mapping <- c(
  # 
  # "News - Inflation Inc."             = "News.Inflation.Inc.",
  # "News - Inflation Stable"           = "News.Inflation.Stable",
  # "News - Inflation Dec."             = "News.Inflation.Dec.",
  # "News - Inflation Direction Index"  = "News.Inflation.Direction.Index",
  # "News - Inflation Pos."             = "News.Inflation.Pos.",
  # "News - Inflation Neut."            = "News.Inflation.Neu.",
  # "News - Inflation Neg."             = "News.Inflation.Neg.",
  # "News - Inflation Sentiment Index"  = "News.Inflation.Sentiment.Index",
  # "News - Monetary Hawkish - Quotes"  = "News.Monetary.Quote.Hawkish",
  # "News - Monetary Stable - Quotes"   = "News.Monetary.Quote.Stable",
  # "News - Monetary Dovish - Quotes"   = "News.Monetary.Quote.Dovish",
  # "News - Monetary Stance Index - Quotes"   = "News.Monetary.Quote.Index",
  # "News - Monetary Hawkish - Non Quotes" = "News.Monetary.Non.Quote.Hawkish",
  # "News - Monetary Stable - Non Quotes"  = "News.Monetary.Non.Quote.Stable",
  # "News - Monetary Dovish - Non  Quotes" = "News.Monetary.Non.Quote.Dovish",
  # "News - Monetary Stance Index - Non Quotes"  = "News.Monetary.Non.Quote.Index",
  # "News - Monetary Pos. - Quotes"     = "News.Monetary.Quote.Pos.",
  # "News - Monetary Neut. - Quotes"    = "News.Monetary.Quote.Neu.",
  # "News - Monetary Neg. - Quotes"     = "News.Monetary.Quote.Neg.",
  # "News - Monetary Sentiment Index - Quotes"     = "News.Monetary.Quote.Sentiment.Index",
  # "News - Monetary Pos. - Non Quotes" = "News.Monetary.Non.Quote.Pos.",
  # "News - Monetary Neut. - Non Quotes"= "News.Monetary.Non.Quote.Neu.",
  # "News - Monetary Neg. - Non Quotes"= "News.Monetary.Non.Quote.Neg.",
  # "News - Monetary Sentiment Index - Non  Quotes"= "News.Monetary.Non.Quote.Sentiment.Index",
  # "ECB - Inflation Inc."              = "ECB.PC.Inflation.Inc.",
  # "ECB - Inflation Stable"            = "ECB.PC.Inflation.Stable",
  # "ECB - Inflation Dec."              = "ECB.PC.Inflation.Dec.",
  # "ECB - Monetary Hawkish"            = "ECB.PC.Monetary.Haw.",
  # "ECB - Monetary Neutral"            = "ECB.PC.Monetary.Stab.",
  # "ECB - Monetary Dovish"             = "ECB.PC.Monetary.Dov.",
  # "ECB - Economic Outlook Inc."       = "ECB.PC.Outlook.Up",
  # "ECB - Economic Outlook Stable"     = "ECB.PC.Outlook.Same",
  # "ECB - Economic Outlook Dec."       = "ECB.PC.Outlook.Down",
  "Positive Interest Rate Surprise"   = "ECB.MRO.POS",
  "Negative Interest Rate Surprise"   = "ECB.MRO.NEG",
  "MRO rate"                     = "ECB.MRO",
  "$\\Delta$ MRO rate"             = "ECB.MRO.difference",
  "DAX"                               = "DAX",
  "$\\Delta$ DAX"                       = "DAX.difference",
  "VDAX"                              = "VDAX",
  "EUROUSD"                           = "ED.Exchange.Rate",
  "$\\Delta$ EUROUSD"                   = "ED.Exchange.Rate.difference",
  "Professional Inflation Forecast"   = "Reuter.Poll.Forecast",
  "$\\Delta$ Professional Inflation Forecast"   = "Reuter.Poll.Forecast.difference",
  "HICP Inflation"                    = "German.Inflation.Year.on.Year",
  "$\\Delta$ HICP Inflation"            = "German.Inflation.Year.on.Year.difference",
  "Industrial Production Gap"         = "German.Industrial.Production.Gap",
  "Unemployment Rate"                 = "Germany.Unemployment",
  "$\\Delta$ Unemployment Rate"         = "Germany.Unemployment.difference",
  "Confidence"                        = "Germany.Conf",
  "$\\Delta$ Confidence"                = "Germany.Conf.difference",
  "Unemployment Expectations"         = "Germany.Future.Un",
  "$\\Delta$ Unemployment Expectations" = "Germany.Future.Un.difference",
  "Financial Expectations"            = "Germany.Future.Fin",
  "$\\Delta$ Financial Expectations"    = "Germany.Future.Fin.difference",
  "Economic Expectations"             = "Germany.Future.Eco"
)

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - Quantitative Variables - 14 Days after Press Conferences",
    label = "statio_test_quant_14",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\textbackslash\\{\\}\\\\textbackslash\\{\\}", "\\\\\\\\", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)

cat(latex_table)

################################################################################

name_mapping <- c(
  
  # "News.Inflation.Inc._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  # "News.Inflation.Dec._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  # "News.Inflation.Direction.Index_stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  # 
  # "News.Inflation.Pos._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  # "News.Inflation.Neg._stored_1"  = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  # "News.Inflation.Sentiment.Index_stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$" ,
  # 
  # "News.Monetary.Quote.Hawkish_stored_1"= "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  # "News.Monetary.Quote.Dovish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  # "News.Monetary.Quote.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$" ,
  # 
  # "News.Monetary.Quote.Pos._stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  # "News.Monetary.Quote.Neg._stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  # "News.Monetary.Quote.Sentiment.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  # 
  # "News.Monetary.Non.Quote.Hawkish_stored_1"  = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  # "News.Monetary.Non.Quote.Dovish_stored_1"   = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  # "News.Monetary.Non.Quote.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$" ,
  # 
  # "News.Monetary.Non.Quote.Pos._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  # "News.Monetary.Non.Quote.Neg._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  # "News.Monetary.Non.Quote.Sentiment.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$" = "News.Inflation.Inc.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$" ="News.Inflation.Dec.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$" = "News.Inflation.Direction.Index",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$" = "News.Inflation.Pos.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$" = "News.Inflation.Neg.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$" = "News.Inflation.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$" = "News.Monetary.Quote.Hawkish",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$" = "News.Monetary.Quote.Dovish",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$" = "News.Monetary.Quote.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$" = "News.Monetary.Quote.Pos.",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$" = "News.Monetary.Quote.Neg.",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$" = "News.Monetary.Quote.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$" = "News.Monetary.Non.Quote.Hawkish",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$" = "News.Monetary.Non.Quote.Dovish",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$" = "News.Monetary.Non.Quote.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$" = "News.Monetary.Non.Quote.Pos.",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$" = "News.Monetary.Non.Quote.Neg.",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$" = "News.Monetary.Non.Quote.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{QuoteShare}$" = "Quote_Ratio"
)

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - News Variables - 14 Days after Press Conferences",
    label = "statio_test_news_14",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

for (i in seq(3, nrow(final_table), by = 3)) {
  kable_table <- kable_table %>% row_spec(i, hline_after = TRUE)
} 

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
#latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("(?m)^\\\\addlinespace\\s*\n", "", latex_table, perl = TRUE)
#latex_table <- gsub("\\\\addlinespace", "", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)
cat(latex_table)

################################################################################

name_mapping <- c(
  
  "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$" = "ECB.PC.Inflation.Inc.",
  "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$" = "ECB.PC.Inflation.Dec.",
  "$\\mathrm{ECB \\ Inflation_t^{Outlook}}$" = "ECB.PC.Inflation.Index",
  
  "$\\mathrm{ECB \\ Economy_t^{Increasing}}$" = "ECB.PC.Outlook.Up",
  "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$" = "ECB.PC.Outlook.Down",
  "$\\mathrm{ECB \\ Economy_t^{Outlook}}$" = "ECB.PC.Outlook.Index",
  
  "$\\mathrm{ECB \\ MP_t^{Hawkish}}$" = "ECB.PC.Monetary.Haw.",
  "$\\mathrm{ECB \\ MP_t^{Dovish}}$" = "ECB.PC.Monetary.Dov.",
  "$\\mathrm{ECB \\ MP_t^{Stance}}$" = "ECB.PC.Monetary.Index",
  
  "$\\Delta \\mathrm{ECB \\ MP_t^{Hawkish}}$" = "ECB.PC.Monetary.Haw..difference",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Dovish}}$" = "ECB.PC.Monetary.Dov..difference",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Stance}}$" = "ECB.PC.Monetary.Index.difference"
  
)

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - ECB Variables - 14 Days after Press Conferences",
    label = "statio_test_ECB_14",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

for (i in seq(3, nrow(final_table), by = 3)) {
  kable_table <- kable_table %>% row_spec(i, hline_after = TRUE)
}

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
latex_table <- gsub("(?m)^\\\\addlinespace\\s*\n", "", latex_table, perl = TRUE)
#latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)
cat(latex_table)

################################################################################
################################################################################
################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
data = data.frame(data)
data = data[12:(nrow(data)),]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

variables_to_test <- c(
  
  "News.Inflation.Direction.Index_stored_1",
  "News.Inflation.Inc._stored_1",
  "News.Inflation.Dec._stored_1",
  
  "News.Inflation.Direction.Index",
  "News.Inflation.Inc.",
  "News.Inflation.Dec.",
  
  "News.Inflation.Sentiment.Index_stored_1",
  "News.Inflation.Pos._stored_1",
  "News.Inflation.Neg._stored_1",

  "News.Inflation.Sentiment.Index",
  "News.Inflation.Pos.",
  "News.Inflation.Neg.",
  
  "News.Monetary.Non.Quote.Index_stored_1",
  "News.Monetary.Non.Quote.Hawkish_stored_1",
  "News.Monetary.Non.Quote.Dovish_stored_1",

  "News.Monetary.Non.Quote.Index",
  "News.Monetary.Non.Quote.Hawkish",
  "News.Monetary.Non.Quote.Dovish",
   
  "News.Monetary.Quote.Index_stored_1",
  "News.Monetary.Quote.Hawkish_stored_1",
  "News.Monetary.Quote.Dovish_stored_1",

  "News.Monetary.Quote.Index",
  "News.Monetary.Quote.Hawkish",
  "News.Monetary.Quote.Dovish",
   
  "News.Monetary.Non.Quote.Sentiment.Index_stored_1",
  "News.Monetary.Non.Quote.Pos._stored_1",
  "News.Monetary.Non.Quote.Neg._stored_1",

  "News.Monetary.Non.Quote.Sentiment.Index",
  "News.Monetary.Non.Quote.Pos.",
  "News.Monetary.Non.Quote.Neg.",
  
  "News.Monetary.Quote.Sentiment.Index_stored_1",
  "News.Monetary.Quote.Pos._stored_1",
  "News.Monetary.Quote.Neg._stored_1",

  "News.Monetary.Quote.Sentiment.Index",
  "News.Monetary.Quote.Pos.",
  "News.Monetary.Quote.Neg.",

  "Quote_Ratio",
  "ECB.PC.Inflation.Inc.",
  # "ECB.PC.Inflation.Stable",
  "ECB.PC.Inflation.Dec.",
  "ECB.PC.Monetary.Haw.",
  # "ECB.PC.Monetary.Stab.",
  "ECB.PC.Monetary.Dov.",
  "ECB.PC.Outlook.Up",
  # "ECB.PC.Outlook.Same",
  "ECB.PC.Outlook.Down",
  # "News_res_inf_rising_stored_1",
  # "News_res_inf_falling_stored_1",
  # "News_res_inf_good_stored_1",
  # "News_res_inf_bad_stored_1",
  # "News_res_inf_ecbhawkish_quotes_stored_1",
  # "News_res_inf_ecbdovish_quotes_stored_1",
  # "News_res_inf_ecbpositive_quotes_stored_1",
  # "News_res_inf_ecbnegative_quotes_stored_1",
  # "News_res_inf_ecbhawkish_non_quotes_stored_1",
  # "News_res_inf_ecbdovish_non_quotes_stored_1",
  # "News_res_inf_ecbpositive_non_quotes_stored_1",
  # "News_res_inf_ecbnegative_non_quotes_stored_1",
 "Germany.Unemployment",
 "Germany.Unemployment.difference",
 "German.Industrial.Production.Gap",
 "Germany.Future.Un",
 "Germany.Future.Un.difference",
 "Germany.Future.Eco",
 "Germany.Future.Fin",
 "Germany.Future.Fin.difference",
 "Germany.Conf",
 "Germany.Conf.difference",
 "ECB.MRO",
 "ECB.MRO.difference",
 "ECB.MRO.POS",
 "ECB.MRO.NEG",
 "DAX",
 "DAX.difference",
 "VDAX",
 "ED.Exchange.Rate",
 "ED.Exchange.Rate.difference",
 "Reuter.Poll.Forecast",
 "Reuter.Poll.Forecast.difference",
 "German.Inflation.Year.on.Year",
 "German.Inflation.Year.on.Year.difference",
 "German.Inflation.Balanced",
 "German.Inflation.Balanced.difference"
)

################################################################################

variable_order <- c(
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$",
  
  "$\\mathrm{News \\ MP}_t^{QuoteShare}$", 
  
  "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$",
  "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$",
  "$\\mathrm{ECB \\ Inflation_t^{Outlook}}$",
  
  "$\\mathrm{ECB \\ MP_t^{Hawkish}}$",
  "$\\mathrm{ECB \\ MP_t^{Dovish}}$",
  "$\\mathrm{ECB \\ MP_t^{Stance}}$",
  
  "$\\Delta \\mathrm{ECB \\ MP_t^{Hawkish}}$",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Dovish}}$",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Stance}}$",
  
  "$\\mathrm{ECB \\ Economy_t^{Increasing}}$",
  "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$",
  "$\\mathrm{ECB \\ Economy_t^{Outlook}}$",
  
  "MRO rate",
  "$\\Delta$ MRO rate",
  "Positive Interest Rate Surprise",
  "Negative Interest Rate Surprise",
  "DAX",
  "$\\Delta$ DAX",
  "VDAX",
  "EUROUSD",
  "$\\Delta$ EUROUSD",
  "German.Inflation.Balanced",
  "German.Inflation.Balanced.difference",
  "Professional Inflation Forecast",
  "$\\Delta$ Professional Inflation Forecast",
  "Household Inflation Expectations",
  "$\\Delta$ Household Inflation Expectations",
  "HICP Inflation",
  "$\\Delta$ HICP Inflation",
  "Industrial Production Gap",
  "Unemployment Rate",
  "$\\Delta$ Unemployment Rate",
  "Confidence",
  "$\\Delta$ Confidence",
  "Unemployment Expectations",
  "$\\Delta$ Unemployment Expectations",
  "Financial Expectations",
  "$\\Delta$ Financial Expectations",
  "Economic Expectations"
)

name_mapping <- c(
  "Positive Interest Rate Surprise"   = "ECB.MRO.POS",
  "Negative Interest Rate Surprise"   = "ECB.MRO.NEG",
  "MRO rate"                     = "ECB.MRO",
  "$\\Delta$ MRO rate"             = "ECB.MRO.difference",
  "DAX"                               = "DAX",
  "$\\Delta$ DAX"                       = "DAX.difference",
  "VDAX"                              = "VDAX",
  "EUROUSD"                           = "ED.Exchange.Rate",
  "$\\Delta$ EUROUSD"                   = "ED.Exchange.Rate.difference",
  "Household Inflation Expectations" = "German.Inflation.Balanced",
  "$\\Delta$ Household Inflation Expectations" = "German.Inflation.Balanced.difference",
  "Professional Inflation Forecast"   = "Reuter.Poll.Forecast",
  "$\\Delta$ Professional Inflation Forecast"   = "Reuter.Poll.Forecast.difference",
  "HICP Inflation"                    = "German.Inflation.Year.on.Year",
  "$\\Delta$ HICP Inflation"            = "German.Inflation.Year.on.Year.difference",
  "Industrial Production Gap"         = "German.Industrial.Production.Gap",
  "Unemployment Rate"                 = "Germany.Unemployment",
  "$\\Delta$ Unemployment Rate"         = "Germany.Unemployment.difference",
  "Confidence"                        = "Germany.Conf",
  "$\\Delta$ Confidence"                = "Germany.Conf.difference",
  "Unemployment Expectations"         = "Germany.Future.Un",
  "$\\Delta$ Unemployment Expectations" = "Germany.Future.Un.difference",
  "Financial Expectations"            = "Germany.Future.Fin",
  "$\\Delta$ Financial Expectations"    = "Germany.Future.Fin.difference",
  "Economic Expectations"             = "Germany.Future.Eco"
)

adf_results <- lapply(variables_to_test, perform_adf_test, data = data)
adf_results_df <- do.call(rbind, lapply(adf_results, as.data.frame)) %>%
  mutate(Approx_P_Value = round(Approx_P_Value, 4)) %>%
  select(Variable, Test_Statistic, X1., X5., X10., Approx_P_Value)

pp_results <- lapply(variables_to_test, perform_pp_test, data = data)
pp_results_df <- do.call(rbind, lapply(pp_results, as.data.frame)) %>%
  mutate(Approx_P_Value = round(Approx_P_Value, 4)) %>%
  select(Variable, Test_Statistic, X1., X5., X10., Approx_P_Value)

merged_df <- adf_results_df %>%
  rename(ADF_Stat = Test_Statistic, ADF_pval = Approx_P_Value) %>%
  inner_join(pp_results_df %>%
               rename(PP_Stat = Test_Statistic, PP_pval = Approx_P_Value),
             by = "Variable")

bold_if_significant <- function(stat_value, p_val, digits = 3) {
  val_str <- format(round(stat_value, digits), nsmall = digits)
  if (!is.na(p_val) && p_val < 0.05) {
    paste0("\\textbf{", val_str, "}")
  } else {
    val_str
  }
}

merged_df <- merged_df %>%
  mutate(
    ADF_Stat_fmt = mapply(bold_if_significant, ADF_Stat, ADF_pval),
    PP_Stat_fmt  = mapply(bold_if_significant, PP_Stat, PP_pval)
  )

################################################################################

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - Quantitative Variables - Survey Month",
    label = "statio_test_quant_full",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\textbackslash\\{\\}\\\\textbackslash\\{\\}", "\\\\\\\\", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)

cat(latex_table)

################################################################################

name_mapping <- c(
  
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$" = "News.Inflation.Inc._stored_1",
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$" ="News.Inflation.Dec._stored_1",
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$" = "News.Inflation.Direction.Index_stored_1",
  # 
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$" = "News.Inflation.Pos._stored_1",
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$" = "News.Inflation.Neg._stored_1",
  # "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$" = "News.Inflation.Sentiment.Index_stored_1",
  # 
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$" = "News.Monetary.Quote.Hawkish_stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$" = "News.Monetary.Quote.Dovish_stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$" = "News.Monetary.Quote.Index_stored_1",
  # 
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$" = "News.Monetary.Quote.Pos._stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$" = "News.Monetary.Quote.Neg._stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$" = "News.Monetary.Quote.Sentiment.Index_stored_1",
  # 
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$" = "News.Monetary.Non.Quote.Hawkish_stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$" = "News.Monetary.Non.Quote.Dovish_stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$" = "News.Monetary.Non.Quote.Index_stored_1",
  # 
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$" = "News.Monetary.Non.Quote.Pos._stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$" = "News.Monetary.Non.Quote.Neg._stored_1",
  # "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$" = "News.Monetary.Non.Quote.Sentiment.Index_stored_1",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$" = "News.Inflation.Inc.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$" ="News.Inflation.Dec.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$" = "News.Inflation.Direction.Index",
  
  "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$" = "News.Inflation.Pos.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$" = "News.Inflation.Neg.",
  "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$" = "News.Inflation.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$" = "News.Monetary.Quote.Hawkish",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$" = "News.Monetary.Quote.Dovish",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$" = "News.Monetary.Quote.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$" = "News.Monetary.Quote.Pos.",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$" = "News.Monetary.Quote.Neg.",
  "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$" = "News.Monetary.Quote.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$" = "News.Monetary.Non.Quote.Hawkish",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$" = "News.Monetary.Non.Quote.Dovish",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$" = "News.Monetary.Non.Quote.Index",
  
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$" = "News.Monetary.Non.Quote.Pos.",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$" = "News.Monetary.Non.Quote.Neg.",
  "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$" = "News.Monetary.Non.Quote.Sentiment.Index",
  
  "$\\mathrm{News \\ MP}_t^{QuoteShare}$" = "Quote_Ratio"
)

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - News Variables - Survey Month",
    label = "statio_test_news_full",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

for (i in seq(3, nrow(final_table), by = 3)) {
  kable_table <- kable_table %>% row_spec(i, hline_after = TRUE)
} 

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
#latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("(?m)^\\\\addlinespace\\s*\n", "", latex_table, perl = TRUE)
#latex_table <- gsub("\\\\addlinespace", "", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)
cat(latex_table)

################################################################################

name_mapping <- c(
  
  "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$" = "ECB.PC.Inflation.Inc.",
  "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$" = "ECB.PC.Inflation.Dec.",
  "$\\mathrm{ECB \\ Inflation_t^{Outlook}}$" = "ECB.PC.Inflation.Index",
  
  "$\\mathrm{ECB \\ Economy_t^{Increasing}}$" = "ECB.PC.Outlook.Up",
  "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$" = "ECB.PC.Outlook.Down",
  "$\\mathrm{ECB \\ Economy_t^{Outlook}}$" = "ECB.PC.Outlook.Index",
  
  "$\\mathrm{ECB \\ MP_t^{Hawkish}}$" = "ECB.PC.Monetary.Haw.",
  "$\\mathrm{ECB \\ MP_t^{Dovish}}$" = "ECB.PC.Monetary.Dov.",
  "$\\mathrm{ECB \\ MP_t^{Stance}}$" = "ECB.PC.Monetary.Index",
  
  "$\\Delta \\mathrm{ECB \\ MP_t^{Hawkish}}$" = "ECB.PC.Monetary.Haw..difference",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Dovish}}$" = "ECB.PC.Monetary.Dov..difference",
  "$\\Delta \\mathrm{ECB \\ MP_t^{Stance}}$" = "ECB.PC.Monetary.Index.difference"
  
)

table_vars <- data.frame(LatexLabel = variable_order)
table_vars$CodeVar <- ifelse(
  table_vars$LatexLabel %in% names(name_mapping),
  name_mapping[table_vars$LatexLabel],
  NA
)

table_vars <- table_vars[!is.na(table_vars$CodeVar), ]

final_table <- table_vars %>%
  left_join(
    merged_df %>% select(Variable, ADF_Stat_fmt, PP_Stat_fmt),
    by = c("CodeVar" = "Variable")
  )

kable_table <- final_table %>%
  select(LatexLabel, ADF_Stat_fmt, PP_Stat_fmt) %>%
  rename(
    Variables               = LatexLabel,
    `ADF-test statistic`    = ADF_Stat_fmt,
    `PP-test statistic`     = PP_Stat_fmt
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Stationarity Tests - ECB Variables - 14 Days after Press Conferences",
    label = "statio_test_ECB_14",
    escape = FALSE
  ) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10) %>%
  footnote(
    general = "\\parbox[t]{\\textwidth}{Note: The table depicts ADF and PP test statistics for the variables. Bold values indicate \\\\ rejection of the null hypothesis of a unit root at the 5\\\\% significance level.}",
    general_title = "",
    escape = FALSE  
  )

kable_table <- gsub(
  "parbox[t]{textwidth}",
  "\\parbox[t]{\\textwidth}",
  kable_table,
  fixed = TRUE
)

for (i in seq(3, nrow(final_table), by = 3)) {
  kable_table <- kable_table %>% row_spec(i, hline_after = TRUE)
}

latex_table <- as.character(kable_table)
latex_table <- gsub("Bold values indicate \\\\ rejection", 
                    "Bold values indicate \\\\\\\\ rejection", 
                    latex_table)
latex_table <- gsub("\\\\begin\\{tabular\\}\\[t\\]\\{lll\\}", "\\\\begin\\{tabular\\}\\[t\\]\\{lcc\\}", latex_table)
#latex_table <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabularx}", latex_table)
latex_table <- gsub("(?m)^\\\\addlinespace\\s*\n", "", latex_table, perl = TRUE)
#latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("Variable & ADF-test statistic & PP-test statistic", 
                    "\\\\textbf{Variable} & \\\\textbf{ADF-test statistic} & \\\\textbf{PP-test statistic}", latex_table)
cat(latex_table)