#####################################################################################
# This file prepares the monthly inflation dataset for news variables (based on 
# news published from the 15th of the current month to the 15th of the next month) 
# and macro and monetary controls.
#####################################################################################

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
library("knitr")
library("tidyr")

################################################################################
# Data loading and basic transformations
################################################################################
data <- read_excel("D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly_2_inf.xlsx")
data <- data.frame(data)
data <- data[23:nrow(data), ]

# Derived indices
data$news_ecb_sent_non_quotes <- data$news_index_ecbpositive_non_quotes - data$news_index_ecbnegative_non_quotes
data$news_ecb_sent_quotes     <- data$news_index_ecbpositive_quotes     - data$news_index_ecbnegative_quotes

data$news_ecb_mon_quotes      <- data$news_index_ecbhawkish_quotes      - data$news_index_ecbdovish_quotes
data$news_ecb_mon_non_quotes  <- data$news_index_ecbhawkish_non_quotes  - data$news_index_ecbdovish_non_quotes

data$news_ecb_mon_number_quotes     <- data$news_index_ecbhawkish_quotes     + data$news_index_ecbnomon_quotes     + data$news_index_ecbdovish_quotes
data$news_ecb_mon_number_non_quotes <- data$news_index_ecbhawkish_non_quotes + data$news_index_ecbnomon_non_quotes + data$news_index_ecbdovish_non_quotes

data$news_inf  <- data$news_index_rising - data$news_index_falling
data$news_sent <- data$news_index_good   - data$news_index_bad

################################################################################
# Rename variable names
################################################################################
data$stored_1 <- data$Reuter.Poll.Forecast

data <- data %>%
  rename(
    "News.Inflation.Direction.Index" = "news_inf",
    "News.Inflation.Dec."            = "news_index_falling",
    "News.Inflation.Stable"          = "news_index_notrend",
    "News.Inflation.Inc."            = "news_index_rising",
    
    "News.Inflation.Sentiment.Index" = "news_sent",
    "News.Inflation.Pos."            = "news_index_good",
    "News.Inflation.Neu."            = "news_index_neutral",
    "News.Inflation.Neg."            = "news_index_bad",
    
    "News.Monetary.Quote.Index"      = "news_ecb_mon_quotes",
    "News.Monetary.Quote.Hawkish"    = "news_index_ecbhawkish_quotes",
    "News.Monetary.Quote.Stable"     = "news_index_ecbnomon_quotes",
    "News.Monetary.Quote.Dovish"     = "news_index_ecbdovish_quotes",
    
    "News.Monetary.Quote.Sentiment.Index" = "news_ecb_sent_quotes",
    "News.Monetary.Quote.Pos."            = "news_index_ecbpositive_quotes",
    "News.Monetary.Quote.Neu."            = "news_index_ecbneutral_quotes",
    "News.Monetary.Quote.Neg."            = "news_index_ecbnegative_quotes",
    
    "News.Monetary.Non.Quote.Index"       = "news_ecb_mon_non_quotes",
    "News.Monetary.Non.Quote.Hawkish"     = "news_index_ecbhawkish_non_quotes",
    "News.Monetary.Non.Quote.Stable"      = "news_index_ecbnomon_non_quotes",
    "News.Monetary.Non.Quote.Dovish"      = "news_index_ecbdovish_non_quotes",
    
    "News.Monetary.Non.Quote.Sentiment.Index" = "news_ecb_sent_non_quotes",
    "News.Monetary.Non.Quote.Pos."            = "news_index_ecbpositive_non_quotes",
    "News.Monetary.Non.Quote.Neu."            = "news_index_ecbneutral_non_quotes",
    "News.Monetary.Non.Quote.Neg."            = "news_index_ecbnegative_non_quotes",
    
    "News.Inflation.Count"       = "news_index_inf_number",
    "News.ECB.Quote.Count"       = "news_index_ecb_quotes_number",
    "News.ECB.Non.Quote.Count"   = "news_index_ecb_non_quotes_number"
  )

################################################################################
# Differences (simple first differences) and logs
################################################################################
first_diff_names <- c(
  "ED.Exchange.Rate",
  "Eurostoxx",
  "DAX",
  "ECB.MRO",
  "German.Inflation.Year.on.Year",
  "Reuter.Poll.Forecast",
  "Germany.Unemployment",
  "Germany.Conf",
  "German.Inflation.Balanced",
  "German.Inflation.Balanced.Primary",
  "German.Inflation.Balanced.Secondary",
  "German.Inflation.Balanced.Further"
)

data$DAX              <- log(data$DAX)
data$ED.Exchange.Rate <- log(data$ED.Exchange.Rate)

data <- data %>%
  mutate(across(
    .cols  = all_of(first_diff_names),
    .fns   = ~ c(NA, diff(.)),
    .names = "{.col}.difference"
  ))

data$time <- as.Date(strptime(data$date, "%Y-%m-%d"))

################################################################################
# Residualization step (store residuals of each index on stored_1)
################################################################################
predictors_names <- c("stored_1")

monetary_indices <- c(
  "News.Monetary.Non.Quote.Hawkish", "News.Monetary.Non.Quote.Dovish", "News.Monetary.Non.Quote.Index",
  "News.Monetary.Quote.Hawkish",     "News.Monetary.Quote.Dovish",     "News.Monetary.Quote.Index",
  "News.Monetary.Non.Quote.Pos.",    "News.Monetary.Non.Quote.Neg.",    "News.Monetary.Non.Quote.Sentiment.Index",
  "News.Monetary.Quote.Pos.",        "News.Monetary.Quote.Neg.",        "News.Monetary.Quote.Sentiment.Index"
)

all_indices <- c(
  monetary_indices,
  "News.Inflation.Pos.", "News.Inflation.Neg.", "News.Inflation.Sentiment.Index",
  "News.Inflation.Inc.", "News.Inflation.Dec.", "News.Inflation.Direction.Index"
)

results <- list()

for (pred_name in predictors_names) {
  for (index in all_indices) {
    
    current_predictors <- pred_name
    
    formula_str <- paste(index, " ~ ", current_predictors, sep = "")
    model <- lm(as.formula(formula_str), data = data)
    
    results[[paste(index, pred_name, sep = "_")]] <- model$residuals
  }
}

data <- cbind(data, results)

################################################################################
# Event dummies and policy regime indicators
################################################################################
event_dates <- as.Date(c(
  "2009-05-07", "2010-05-10", "2011-08-07", "2011-10-06", "2012-09-06",
  "2014-06-05", "2014-09-04", "2015-01-22", "2015-03-09", "2016-03-10"
))

event_months   <- format(event_dates, "%Y-%m")
monthly_months <- format(data$time, "%Y-%m")

data$Unmon    <- as.integer(monthly_months %in% event_months)
data$draghi   <- ifelse(data$time >= as.Date("2011-11-01") & data$time <= as.Date("2019-10-31"), 1, 0)
data$negative <- ifelse(data$time >= as.Date("2014-06-30") & data$time <= as.Date("2022-07-27"), 1, 0)
data$whatever <- ifelse(data$time >= as.Date("2012-07-01") & data$time <= as.Date("2012-07-31"), 1, 0)

################################################################################
# Lags (order 3) for all variables except the first column
################################################################################
lag_order <- 3
data_lags <- data.frame(matrix(nrow = nrow(data), ncol = 0))

for (var in names(data)[2:ncol(data)]) {
  for (l in 1:lag_order) {
    new_var_name <- paste(var, gsub(" ", "", paste("Lag", as.character(l), "")), sep = ".")
    data_lags[[new_var_name]] <- lag(data[[var]], l)
  }
}

data <- cbind(data, data_lags)
data <- data[(lag_order + 1):nrow(data), ]

################################################################################
# Quote share
################################################################################
data$ECB.Quote.Count <- data$`News.Monetary.Quote.Hawkish` +
  data$`News.Monetary.Quote.Stable` +
  data$`News.Monetary.Quote.Dovish`

data$ECB.Non.Quote.Count <- data$`News.Monetary.Non.Quote.Hawkish` +
  data$`News.Monetary.Non.Quote.Stable` +
  data$`News.Monetary.Non.Quote.Dovish`

data$ECB.All.Count <- data$ECB.Non.Quote.Count + data$ECB.Quote.Count
data$Quote_Ratio   <- data$ECB.Quote.Count / data$ECB.All.Count

write_xlsx(data, "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx")

################################################################################
# Summary statistics: news variables
################################################################################
name_mapping_news <- c(
  "News.Inflation.Inc."            = "$\\mathrm{News \\ Inflation}_t^{\\text{Increasing}}$",
  "News.Inflation.Dec."            = "$\\mathrm{News \\ Inflation}_t^{\\text{Decreasing}}$",
  "News.Inflation.Direction.Index" = "$\\mathrm{News \\ Inflation}_t^{\\text{Direction}}$",
  
  "News.Inflation.Pos."            = "$\\mathrm{News \\ Inflation}_t^{\\text{Positive}}$",
  "News.Inflation.Neg."            = "$\\mathrm{News \\ Inflation}_t^{\\text{Negative}}$",
  "News.Inflation.Sentiment.Index" = "$\\mathrm{News \\ Inflation}_t^{\\text{Sentiment}}$",
  
  "News.Monetary.Quote.Hawkish"          = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Hawkish}}$",
  "News.Monetary.Quote.Dovish"           = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Dovish}}$",
  "News.Monetary.Quote.Index"            = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Stance}}$",
  
  "News.Monetary.Quote.Pos."             = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Positive}}$",
  "News.Monetary.Quote.Neg."             = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Negative}}$",
  "News.Monetary.Quote.Sentiment.Index"  = "$\\mathrm{News \\ MP}_t^{\\text{Quote,Sentiment}}$",
  
  "News.Monetary.Non.Quote.Hawkish"         = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Hawkish}}$",
  "News.Monetary.Non.Quote.Dovish"          = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Dovish}}$",
  "News.Monetary.Non.Quote.Index"           = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Stance}}$",
  
  "News.Monetary.Non.Quote.Pos."            = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Positive}}$",
  "News.Monetary.Non.Quote.Neg."            = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Negative}}$",
  "News.Monetary.Non.Quote.Sentiment.Index" = "$\\mathrm{News \\ MP}_t^{\\text{NoQuote,Sentiment}}$",
  
  "Quote_Ratio" = "$\\mathrm{News \\ MP}_t^{\\text{QuoteShare}}$"
)

var_names_news <- names(name_mapping_news)

summary_stats_news <- data %>%
  summarise(across(all_of(var_names_news), list(
    Mean = ~ round(mean(.x, na.rm = TRUE), 3),
    Std  = ~ round(sd(.x, na.rm = TRUE), 3),
    Min  = ~ round(min(.x, na.rm = TRUE), 3),
    Max  = ~ round(max(.x, na.rm = TRUE), 3)
  )))

################################################################################
# Summary statistics: macro and monetary controls
################################################################################
name_mapping_controls <- c(
  "ECB.MRO"                       = "MRO rate",
  "ECB.MRO.difference"            = "$\\Delta$ MRO rate",
  "ECB.MRO.POS"                   = "Positive Interest Rate Surprise",
  "ECB.MRO.NEG"                   = "Negative Interest Rate Surprise",
  
  "Unmon"                         = "Unconventional MP",
  "negative"                      = "Negative Rate",
  "whatever"                      = "Whatever it Takes",
  "draghi"                        = "Draghi",
  
  "DAX"                           = "DAX",
  "DAX.difference"                = "$\\Delta$ DAX",
  "VDAX"                          = "VDAX",
  "ED.Exchange.Rate"              = "EUROUSD",
  "ED.Exchange.Rate.difference"   = "$\\Delta$ EUROUSD",
  
  "German.Inflation.Balanced"              = "Household Inflation Expectations",
  "German.Inflation.Balanced.difference"   = "$\\Delta$ Household Inflation Expectations",
  
  "German.Industrial.Production.Gap"       = "Industrial Production Gap",
  "Germany.Unemployment"                   = "Unemployment Rate",
  "Germany.Unemployment.difference"        = "$\\Delta$ Unemployment Rate",
  
  "Germany.Conf"                           = "Household Confidence",
  "Germany.Conf.difference"                = "$\\Delta$ Household Confidence",
  
  "Reuter.Poll.Forecast"                   = "Professional Inflation Forecast",
  "Reuter.Poll.Forecast.difference"        = "$\\Delta$ Professional Inflation Forecast",
  "German.Inflation.Year.on.Year"          = "HICP Inflation",
  "German.Inflation.Year.on.Year.difference" = "$\\Delta$ HICP Inflation"
)

var_names_controls <- names(name_mapping_controls)

summary_stats_controls <- data %>%
  summarise(across(all_of(var_names_controls), list(
    Mean = ~ round(mean(.x, na.rm = TRUE), 3),
    Std  = ~ round(sd(.x, na.rm = TRUE), 3),
    Min  = ~ round(min(.x, na.rm = TRUE), 3),
    Max  = ~ round(max(.x, na.rm = TRUE), 3)
  )))
