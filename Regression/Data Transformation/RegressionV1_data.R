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
library("writexl") 
library("tseries")

library("kableExtra")
library("dplyr")
library("knitr")
library("tidyr")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly_2_inf.xlsx')
data = data.frame(data)
data <- data[23:nrow(data), ]

data$news_ecb_sent_non_quotes = data$news_index_ecbpositive_non_quotes - data$news_index_ecbnegative_non_quotes
data$news_ecb_sent_quotes = data$news_index_ecbpositive_quotes - data$news_index_ecbnegative_quotes

data$news_ecb_mon_quotes = data$news_index_ecbhawkish_quotes - data$news_index_ecbdovish_quotes
data$news_ecb_mon_non_quotes = data$news_index_ecbhawkish_non_quotes - data$news_index_ecbdovish_non_quotes

data$news_ecb_mon_number_quotes = data$news_index_ecbhawkish_quotes + data$news_index_ecbnomon_quotes + data$news_index_ecbdovish_quotes
data$news_ecb_mon_number_non_quotes = data$news_index_ecbhawkish_non_quotes + data$news_index_ecbnomon_non_quotes + data$news_index_ecbdovish_non_quotes

data$news_inf = data$news_index_rising - data$news_index_falling 
data$news_sent = data$news_index_good - data$news_index_bad

data$ECB_mon_index =  data$ECB_mon_haw_og - data$ECB_mon_dov_og
data$ECB_out_index =  data$ECB_out_up_og - data$ECB_out_down_og
data$ECB_inf_index =  data$ECB_inf_up_og - data$ECB_inf_down_og

################################################################################

data$'stored_1' = data$Reuter.Poll.Forecast
data$'stored_2' = data$German.Inflation.Year.on.Year

data <- data %>%
  rename( 
    "ECB.PC.Inflation.Inc." = "ECB_inf_up_og" ,"ECB.PC.Inflation.Stable" = "ECB_inf_same_og","ECB.PC.Inflation.Dec." = "ECB_inf_down_og",
    "ECB.PC.Inflation.Index" = "ECB_inf_index",
    "News.Inflation.Direction.Index" = "news_inf", "News.Inflation.Dec." = "news_index_falling", "News.Inflation.Stable" = "news_index_notrend",
    "News.Inflation.Inc." = "news_index_rising", 
    "ECB.PC.Monetary.Haw." = "ECB_mon_haw_og" ,"ECB.PC.Monetary.Stab." = "ECB_mon_not_og","ECB.PC.Monetary.Dov." = "ECB_mon_dov_og",
    "ECB.PC.Monetary.Index" = "ECB_mon_index",
    "ECB.PC.Outlook.Up" = "ECB_out_up_og" ,"ECB.PC.Outlook.Same" = "ECB_out_same_og","ECB.PC.Outlook.Down" = "ECB_out_down_og",
    "ECB.PC.Outlook.Index" = "ECB_out_index",
    "News.Inflation.Sentiment.Index" = "news_sent", "News.Inflation.Pos." = "news_index_good",
    "News.Inflation.Neu." = "news_index_neutral", "News.Inflation.Neg." = "news_index_bad",
    "News.Monetary.Quote.Index" = "news_ecb_mon_quotes",
    "News.Monetary.Quote.Hawkish" = "news_index_ecbhawkish_quotes", "News.Monetary.Quote.Stable" = "news_index_ecbnomon_quotes", "News.Monetary.Quote.Dovish" = "news_index_ecbdovish_quotes",
    "News.Monetary.Quote.Sentiment.Index" = "news_ecb_sent_quotes", "News.Monetary.Quote.Pos." = "news_index_ecbpositive_quotes", "News.Monetary.Quote.Neu." = "news_index_ecbneutral_quotes",
    "News.Monetary.Quote.Neg." = "news_index_ecbnegative_quotes", "News.Monetary.Non.Quote.Index" = "news_ecb_mon_non_quotes",
    "News.Monetary.Non.Quote.Hawkish" = "news_index_ecbhawkish_non_quotes", "News.Monetary.Non.Quote.Stable" = "news_index_ecbnomon_non_quotes", "News.Monetary.Non.Quote.Dovish" = "news_index_ecbdovish_non_quotes",
    "News.Monetary.Non.Quote.Sentiment.Index" = "news_ecb_sent_non_quotes", "News.Monetary.Non.Quote.Pos." = "news_index_ecbpositive_non_quotes", "News.Monetary.Non.Quote.Neu." = "news_index_ecbneutral_non_quotes",
    "News.Monetary.Non.Quote.Neg." = "news_index_ecbnegative_non_quotes",
    "News.Inflation.Count" = "news_index_inf_number", "News.ECB.Quote.Count" = "news_index_ecb_quotes_number",
    "News.ECB.Non.Quote.Count" = "news_index_ecb_non_quotes_number"
  )
 
first_diff_names = c(
                    "ED.Exchange.Rate",
                    "Eurostoxx",
                    "DAX",
                    "ECB.MRO",
                    "German.Inflation.Year.on.Year",
                    "Reuter.Poll.Forecast",
                    "Germany.Unemployment",
                    "Germany.Future.Un",
                    "Germany.Future.Eco", 
                    "Germany.Future.Fin",
                    "Germany.Conf",
                    "ECB.PC.Monetary.Haw.",
                    "ECB.PC.Monetary.Dov.",
                    "ECB.PC.Monetary.Index",
                    "German.Inflation.Balanced",
                    "German.Inflation.Balanced.Primary",
                    "German.Inflation.Balanced.Secondary",
                    "German.Inflation.Balanced.Further",
                    "German.Inflation.Balanced.Perc",
                    "German.Inflation.Balanced.Primary.Perc",
                    "German.Inflation.Balanced.Secondary.Perc",
                    "German.Inflation.Balanced.Further.Perc"
                     )

data <- data %>%
  mutate(across(
    .cols = all_of(first_diff_names),
    .fns = ~ c(NA, diff(.)),
    .names = "{.col}.difference"
  ))

data <- data[-1, ]

data$time = as.Date(strptime(data$date, "%Y-%m-%d"))

data$GR = ifelse(data$time > as.Date("2008-09-15"), 1, 0)
data$debt = ifelse(data$time > as.Date("2010-01-01"), 1, 0)
data$forward = ifelse(data$time > as.Date("2013-07-01"), 1, 0)
data$ni = ifelse(data$time > as.Date("2014-06-05"), 1, 0)
data$qe = ifelse(data$time > as.Date("2015-01-22"), 1, 0)
data$brexit = ifelse(data$time > as.Date("2016-06-23"), 1, 0)

data$duisenberg = ifelse(data$time >= as.Date("2002-01-01") & data$time <= as.Date("2003-10-31"), 1, 0)
data$trichet = ifelse(data$time >= as.Date("2003-11-01") & data$time <= as.Date("2011-10-31"), 1, 0)
data$draghi = ifelse(data$time >= as.Date("2011-11-30") & data$time <= as.Date("2019-10-31"), 1, 0)
data$lagarde = ifelse(data$time >= as.Date("2019-11-01"), 1, 0)
data$low_int = ifelse(data$time >= as.Date("2011-07-01"), 1, 0)

data$negative = ifelse(data$time >= as.Date("2013-06-11") & data$time <= as.Date("2013-07-11"), 1, 0)
data$whatever = ifelse(data$time >= as.Date("2012-07-01") & data$time <= as.Date("2012-08-01"), 1, 0)

predictors_names <- c("stored_1", "stored_2")

indices <- c(
  "News.Monetary.Non.Quote.Hawkish", "News.Monetary.Non.Quote.Dovish", "News.Monetary.Non.Quote.Index",
  "News.Monetary.Quote.Hawkish", "News.Monetary.Quote.Dovish", "News.Monetary.Quote.Index",
  "News.Monetary.Non.Quote.Pos.", "News.Monetary.Non.Quote.Neg.", "News.Monetary.Non.Quote.Sentiment.Index",
  "News.Monetary.Quote.Pos.", "News.Monetary.Quote.Neg.", "News.Monetary.Quote.Sentiment.Index",
  "News.Inflation.Pos.", "News.Inflation.Neg.", "News.Inflation.Sentiment.Index",
  "News.Inflation.Inc.", "News.Inflation.Dec.", "News.Inflation.Direction.Index"
  )

results <- list()

for(pred_name in predictors_names) {
  for(index in indices) {
    formula_str <- paste(index, " ~ ", pred_name, sep = "")
    formula_obj <- as.formula(formula_str)
    model <- lm(formula_obj, data = data)
    results[[paste(index, pred_name, sep = "_")]] <- model$residuals
  }
}

data = cbind(data, results)

###

data$UB = ifelse(data$time > as.Date("2009-05-07"), 1, 0)
data$SM1 = ifelse(data$time >= as.Date("2010-05-10"), 1, 0)
data$SM2 = ifelse(data$time >= as.Date("2011-08-07"), 1, 0)
data$CB = ifelse(data$time >= as.Date("2011-10-06"), 1, 0)
data$OMT = ifelse(data$time >= as.Date("2012-09-06"), 1, 0)
data$ABS = ifelse(data$time >= as.Date("2014-06-05"), 1, 0)
data$ABSCS = ifelse(data$time >= as.Date("2014-09-04"), 1, 0)
data$PS = ifelse(data$time >= as.Date("2015-01-22"), 1, 0)
data$PSNA1 = ifelse(data$time >= as.Date("2015-03-09"), 1, 0)
data$PSNA2 = ifelse(data$time >= as.Date("2016-03-10"), 1, 0)

###

financial_crisis_start <- as.Date("2007-09-01")
financial_crisis_end <- as.Date("2009-06-30")
data$financial_crisis <- ifelse(data$time >= financial_crisis_start & data$time <= financial_crisis_end, 1, 0)

#### Unconventional monetary policy:

event_dates <- as.Date(c("2009-05-07", "2010-05-10", "2011-08-07", "2011-10-06", "2012-09-06", 
                         "2014-06-05", "2014-09-04", "2015-01-22", "2015-03-09", "2016-03-10"))

event_months <- format(event_dates, "%Y-%m")

monthly_months <- format(data$time, "%Y-%m")

data$Unmon <- as.integer(monthly_months %in% event_months)

###

lag_order = 3
nvar = dim(data)[2]

data_lags = data.frame(matrix(nrow = nrow(data), ncol = 0))

for (var in names(data)[2:dim(data)[2]]) {
  
  for (l in 1:lag_order) {
    
    new_var_name = paste(var, gsub(" ", "", paste("Lag", as.character(l), "")), sep=".")
    
    data_lags[[new_var_name]] = lag(data[[var]], l)
  }
}

data = cbind(data, data_lags)
data = data[(lag_order+1):nrow(data),]

###

data$ECB.Quote.Count = data$"News.Monetary.Quote.Hawkish" + data$"News.Monetary.Quote.Stable" + data$"News.Monetary.Quote.Dovish"
data$ECB.Non.Quote.Count = data$"News.Monetary.Non.Quote.Hawkish" + data$"News.Monetary.Non.Quote.Stable" + data$"News.Monetary.Non.Quote.Dovish"

data$ECB.All.Count = data$ECB.Non.Quote.Count + data$ECB.Quote.Count

data$Quote_Ratio = data$"News.Monetary.Quote.Hawkish" + data$"News.Monetary.Quote.Stable" + data$"News.Monetary.Quote.Dovish"
data$Quote_Ratio = data$ECB.Quote.Count/data$ECB.All.Count

write_xlsx(data, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')

####

name_mapping <- c(
  "News.Inflation.Inc." = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec." = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Direction.Index" = "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  
  "News.Inflation.Pos." = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg." = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "News.Inflation.Sentiment.Index" = "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$",
  
  "News.Monetary.Quote.Hawkish" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Index" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$",
  
  "News.Monetary.Quote.Pos." = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg." = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "News.Monetary.Quote.Sentiment.Index" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  
  "News.Monetary.Non.Quote.Hawkish" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Index" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$",
  
  "News.Monetary.Non.Quote.Pos." = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg." = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "News.Monetary.Non.Quote.Sentiment.Index" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$",
  
  "Quote_Ratio" = "$\\mathrm{News \\ MP}_t^{QuoteShare}$"
)

name_mapping <- c(
  "News.Inflation.Inc._stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec._stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Direction.Index_stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  
  "News.Inflation.Pos._stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg._stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "News.Inflation.Sentiment.Index_stored_1" = "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$",
  
  "News.Monetary.Quote.Hawkish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$",
  
  "News.Monetary.Quote.Pos._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "News.Monetary.Quote.Sentiment.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  
  "News.Monetary.Non.Quote.Hawkish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$",
  
  "News.Monetary.Non.Quote.Pos._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg._stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "News.Monetary.Non.Quote.Sentiment.Index_stored_1" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$"#,
  
 # "Quote_Ratio" = "$\\mathrm{News \\ MP}_t^{QuoteShare}$"
)

################################################################################

var_names <- names(name_mapping)

summary_stats <- data %>%
  summarise(across(all_of(var_names), list(
    Mean = ~round(mean(.x, na.rm = TRUE), 3),
    Std = ~round(sd(.x, na.rm = TRUE), 3),
    Min = ~round(min(.x, na.rm = TRUE), 3),
    Max = ~round(max(.x, na.rm = TRUE), 3)
  )))

long_format_stats <- summary_stats %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", ".value"),
    names_pattern = "(.+)_(.+)"
  )

long_format_stats <- long_format_stats %>%
  mutate(Variable_Desired = name_mapping[Variable]) %>%
  
  mutate(Variable_Desired = ifelse(is.na(Variable_Desired), Variable, Variable_Desired))

long_format_stats <- long_format_stats %>%
  filter(!is.na(Variable_Desired))

table_data <- long_format_stats %>%
  select(Variable = Variable_Desired, Mean, Std, Min, Max)

kable_table <- table_data %>%
  kable(format = "latex", booktabs = TRUE, 
        caption = "Summary Statistics - News Variables - Survey Month", 
        align = 'c',
        label = "sum_news_full",
        escape = FALSE) %>% 
  kable_styling(latex_options = c("hold_position"), 
                font_size = 10) 

latex_table <- as.character(kable_table)
latex_table <- gsub("\\\\begin\\{tabular\\}", 
                    "\\\\begin\\{tabular\\}\\{lcccc\\}", 
                    latex_table)
latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("\\[t\\]\\{ccccc\\}", "", latex_table)
latex_table <- gsub("\\[!h\\]", "\\[!ht\\]", latex_table) 
latex_table <- gsub("Variable & Mean & Std & Min & Max", "\\\\textbf{Variable} & \\\\textbf{Mean} & \\\\textbf{Std} & \\\\textbf{Min} & \\\\textbf{Max}", latex_table)

cat(latex_table)

################################################################################

name_mapping <- c( 
  "ECB.MRO" = "MRO rate",
  "ECB.MRO.difference" = "$\\Delta$ MRO rate",
  "ECB.MRO.POS" = "Positive Interest Rate Surprise",
  "ECB.MRO.NEG" = "Negative Interest Rate Surprise",
  
  "Unmon" = "Unconventional MP",
  "negative" = "Negative Rate",
  "whatever" = "Whatever it Takes",
  "draghi" = "Draghi",
  
  "DAX" = "DAX",
  "DAX.difference" = "$\\Delta$ DAX",
  "VDAX" = "VDAX",
  "ED.Exchange.Rate" = "EUROUSD",
  "ED.Exchange.Rate.difference" = "$\\Delta$ EUROUSD",
  
  "German.Inflation.Balanced" = "Household Inflation Expectations",
  "German.Inflation.Balanced.difference" = "$\\Delta$ Household Inflation Expectations",
  
  "German.Industrial.Production.Gap" = "Industrial Production Gap",  
  "Germany.Unemployment" = "Unemployment Rate",
  "Germany.Unemployment.difference" = "$\\Delta$ Unemployment Rate",
  "Germany.Future.Un" = "Unemployment Expectations",
  "Germany.Future.Un.difference" = "$\\Delta$ Unemployment Expectations",
  "Germany.Future.Fin" = "Financial Expectations",
  "Germany.Future.Fin.difference" = "$\\Delta$ Financial Expectations",
  "Germany.Future.Eco" = "Economic Expectations",
  "Germany.Future.Eco.difference" = "$\\Delta$ Economic Expectations",
  
  "Reuter.Poll.Forecast" = "Professional Inflation Forecast",
  "Reuter.Poll.Forecast.difference" = "$\\Delta$ Professional Inflation Forecast",
  "German.Inflation.Year.on.Year" = "HICP Inflation",
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation"
)

var_names <- names(name_mapping)

summary_stats <- data %>%
  summarise(across(all_of(var_names), list(
    Mean = ~round(mean(.x, na.rm = TRUE), 3),
    Std  = ~round(sd(.x, na.rm = TRUE), 3),
    Min  = ~round(min(.x, na.rm = TRUE), 3),
    Max  = ~round(max(.x, na.rm = TRUE), 3)
  )))

long_format_stats <- summary_stats %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", ".value"),
    names_pattern = "(.+)_(.+)"
  ) %>%
  mutate(Variable_Desired = name_mapping[Variable]) %>%
  mutate(Variable_Desired = ifelse(is.na(Variable_Desired), Variable, Variable_Desired)) %>%
  filter(!is.na(Variable_Desired))

table_data <- long_format_stats %>%
  select(Variable = Variable_Desired, Mean, Std, Min, Max)

kable_table <- table_data %>%
  kable(format = "latex", booktabs = TRUE, 
        caption = "Summary Statistics - Macroeconomic and Monetary Variables - Survey Month", 
        align = 'c',
        label = "sum_control_full",
        escape = FALSE) %>% 
  kable_styling(latex_options = c("hold_position"), font_size = 10)

latex_table <- as.character(kable_table)

latex_table <- gsub("\\\\begin\\{tabular\\}", 
                    "\\\\begin\\{tabular\\}\\{lcccc\\}", 
                    latex_table)

latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("\\[t\\]\\{ccccc\\}", "", latex_table)
latex_table <- gsub("\\[!h\\]", "\\[!ht\\]", latex_table)
latex_table <- gsub("Variable & Mean & Std & Min & Max", 
                    "\\\\textbf{Variable} & \\\\textbf{Mean} & \\\\textbf{Std} & \\\\textbf{Min} & \\\\textbf{Max}", 
                    latex_table)

cat(latex_table)

################################################################################

name_mapping <- c(
  "ECB.PC.Inflation.Inc." = "$\\mathrm{ECB \\ Inflation_t^{Increasing}}$",
  "ECB.PC.Inflation.Dec." = "$\\mathrm{ECB \\ Inflation_t^{Decreasing}}$",
  "ECB.PC.Inflation.Index"= "$\\mathrm{ECB \\ Inflation_t^{Outlook}}$",
  
  "ECB.PC.Outlook.Up"     = "$\\mathrm{ECB \\ Economy_t^{Increasing}}$",
  "ECB.PC.Outlook.Down"   = "$\\mathrm{ECB \\ Economy_t^{Decreasing}}$",
  "ECB.PC.Outlook.Index"  = "$\\mathrm{ECB \\ Economy_t^{Outlook}}$",
  
  "ECB.PC.Monetary.Haw."  = "$\\mathrm{ECB \\ MP_t^{Hawkish}}$",
  "ECB.PC.Monetary.Dov."  = "$\\mathrm{ECB \\ MP_t^{Dovish}}$",
  "ECB.PC.Monetary.Index" = "$\\mathrm{ECB \\ MP_t^{Stance}}$"
)  

var_names <- names(name_mapping)

summary_stats <- data %>%
  summarise(across(all_of(var_names), list(
    Mean = ~round(mean(.x, na.rm = TRUE), 3),
    Std  = ~round(sd(.x, na.rm = TRUE), 3),
    Min  = ~round(min(.x, na.rm = TRUE), 3),
    Max  = ~round(max(.x, na.rm = TRUE), 3)
  )))

long_format_stats <- summary_stats %>%
  pivot_longer(
    cols = everything(),
    names_to = c("Variable", ".value"),
    names_pattern = "(.+)_(.+)"
  ) %>%
  mutate(Variable_Desired = name_mapping[Variable]) %>%
  mutate(Variable_Desired = ifelse(is.na(Variable_Desired), Variable, Variable_Desired)) %>%
  filter(!is.na(Variable_Desired))

table_data <- long_format_stats %>%
  select(Variable = Variable_Desired, Mean, Std, Min, Max)

kable_table <- table_data %>%
  kable(format = "latex", booktabs = TRUE, 
        caption = "Summary Statistics - ECB Variables - Survey Month", 
        align = 'c',
        label = "sum_ecb_full",
        escape = FALSE) %>% 
  kable_styling(latex_options = c("hold_position"), font_size = 10)

latex_table <- as.character(kable_table)

latex_table <- gsub("\\\\begin\\{tabular\\}", 
                    "\\\\begin\\{tabular\\}\\{lcccc\\}", 
                    latex_table)

latex_table <- gsub("\\\\addlinespace", "\\\\midrule", latex_table)
latex_table <- gsub("\\\\fontsize\\{10\\}\\{12\\}\\\\selectfont", "\\\\footnotesize\\\n\\\\setlength\\{\\\\tabcolsep\\}\\{6pt\\}", latex_table)
latex_table <- gsub("\\[t\\]\\{ccccc\\}", "", latex_table)
latex_table <- gsub("\\[!h\\]", "\\[!ht\\]", latex_table)
latex_table <- gsub("Variable & Mean & Std & Min & Max", 
                    "\\\\textbf{Variable} & \\\\textbf{Mean} & \\\\textbf{Std} & \\\\textbf{Min} & \\\\textbf{Max}", 
                    latex_table)

cat(latex_table)