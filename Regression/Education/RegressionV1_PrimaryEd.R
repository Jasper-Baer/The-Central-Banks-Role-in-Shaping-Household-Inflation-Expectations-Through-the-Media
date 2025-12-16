#####################################################################################
# This file estimates the baseline inflation-expectations regressions for 
# household with primary education using the news-indicator residuals 
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
library("stargazer")
library("car")

################################################################################
# Paths and settings
################################################################################
DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

dont_scale <- c("draghi","negative","trichet","whatever","Unmon")

# Optional recession filter 
recessions <- NULL
# recessions <- list(
#   c(as.Date("2001-02-01"), as.Date("2003-06-30")),
#   c(as.Date("2008-01-01"), as.Date("2009-04-30")),
#   c(as.Date("2020-02-01"), as.Date("2020-04-30"))
# )

################################################################################
# Load and prep data
################################################################################
data <- read_excel(DATA_PATH)
data <- data.frame(data)

data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))

data <- data |> dplyr::filter(time >= START_DATE)

# Optional recession filter
if (!is.null(recessions)) {
  for (rr in recessions) {
    data <- data %>% filter(!(time >= rr[1] & time <= rr[2]))
  }
}

# Scale numeric columns except dummies
numeric_columns <- sapply(data, is.numeric)
numeric_columns[dont_scale] <- FALSE
data[numeric_columns] <- scale(data[numeric_columns])

################################################################################
# Models (Primary; [1]–[6])
################################################################################

# [1] Quotes, no controls
fit_no_controls_quotes <- lm(
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

# [2] Non-quotes, no controls
fit_no_controls_non_quotes <- lm(
  German.Inflation.Balanced.Primary.difference ~
    German.Inflation.Balanced.Primary.difference.Lag1 +
    German.Inflation.Balanced.Primary.difference.Lag2 +
    German.Inflation.Balanced.Primary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Non.Quote.Hawkish_stored_1 +
    News.Monetary.Non.Quote.Dovish_stored_1 +
    News.Monetary.Non.Quote.Pos._stored_1 +
    News.Monetary.Non.Quote.Neg._stored_1 +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

# [3] Both quote and non-quote, no controls
fit_no_controls_both <- lm(
  German.Inflation.Balanced.Primary ~
    German.Inflation.Balanced.Primary.Lag1 +
    German.Inflation.Balanced.Primary.Lag2 +
    German.Inflation.Balanced.Primary.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 +
    News.Monetary.Quote.Dovish_stored_1 +
    News.Monetary.Quote.Pos._stored_1 +
    News.Monetary.Quote.Neg._stored_1 +
    News.Monetary.Non.Quote.Hawkish_stored_1 +
    News.Monetary.Non.Quote.Dovish_stored_1 +
    News.Monetary.Non.Quote.Pos._stored_1 +
    News.Monetary.Non.Quote.Neg._stored_1 +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

# [4] Quotes interacted with quote share, no controls
fit_no_controls_quotes_count <- lm(
  German.Inflation.Balanced.Primary.difference ~
    German.Inflation.Balanced.Primary.difference.Lag1 +
    German.Inflation.Balanced.Primary.difference.Lag2 +
    German.Inflation.Balanced.Primary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 * Quote_Ratio +
    News.Monetary.Quote.Dovish_stored_1  * Quote_Ratio +
    News.Monetary.Quote.Pos._stored_1    * Quote_Ratio +
    News.Monetary.Quote.Neg._stored_1    * Quote_Ratio +
    German.Inflation.Year.on.Year.difference +
    Reuter.Poll.Forecast.difference,
  data = data
)

# [5] Quotes, all controls
fit_all_controls_quotes <- lm(
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
    Germany.Conf.difference +
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

# [6] Quotes interacted with quote share, all controls
fit_all_controls_quotes_count <- lm(
  German.Inflation.Balanced.Primary.difference ~
    German.Inflation.Balanced.Primary.difference.Lag1 +
    German.Inflation.Balanced.Primary.difference.Lag2 +
    German.Inflation.Balanced.Primary.difference.Lag3 +
    News.Inflation.Inc._stored_1 +
    News.Inflation.Dec._stored_1 +
    News.Inflation.Pos._stored_1 +
    News.Inflation.Neg._stored_1 +
    News.Monetary.Quote.Hawkish_stored_1 * Quote_Ratio +
    News.Monetary.Quote.Dovish_stored_1  * Quote_Ratio +
    News.Monetary.Quote.Pos._stored_1    * Quote_Ratio +
    News.Monetary.Quote.Neg._stored_1    * Quote_Ratio +
    Germany.Conf.difference +
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
# Collect results and NW SEs
################################################################################
fit1 <- fit_no_controls_quotes
fit2 <- fit_no_controls_non_quotes
fit3 <- fit_no_controls_both
fit4 <- fit_no_controls_quotes_count
fit5 <- fit_all_controls_quotes
fit6 <- fit_all_controls_quotes_count

get_res <- function(fit_obj, lag_nw = 12) {
  co <- coeftest(fit_obj, vcov. = NeweyWest(fit_obj, lag = lag_nw, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname  = rownames(co),
    estimate = co[, "Estimate"],
    se       = co[, "Std. Error"],
    pval     = co[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

res1 <- get_res(fit1, lag_nw = 12)
res2 <- get_res(fit2, lag_nw = 12)
res3 <- get_res(fit3, lag_nw = 12)
res4 <- get_res(fit4, lag_nw = 12)
res5 <- get_res(fit5, lag_nw = 12)
res6 <- get_res(fit6, lag_nw = 12)

adj1 <- round(summary(fit1)$adj.r.squared, 3)
adj2 <- round(summary(fit2)$adj.r.squared, 3)
adj3 <- round(summary(fit3)$adj.r.squared, 3)
adj4 <- round(summary(fit4)$adj.r.squared, 3)
adj5 <- round(summary(fit5)$adj.r.squared, 3)
adj6 <- round(summary(fit6)$adj.r.squared, 3)