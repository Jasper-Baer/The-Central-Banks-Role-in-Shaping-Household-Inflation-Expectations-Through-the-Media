#####################################################################################
# This file estimates the baseline inflation-expectations regressions for different 
# education subsamples using the news-indicator residuals 
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
library("car")

################################################################################
# Paths and settings
################################################################################
DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

# Use util helpers 
UTIL_PATH <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Inflation Expectations/Util.R"
if (file.exists(UTIL_PATH)) source(UTIL_PATH)

dont_scale <- c("draghi","negative","whatever","Unmon")

# Optional recession filter 
recessions <- NULL
# recessions <- list(
#   c(as.Date("2001-02-01"), as.Date("2003-06-30")),
#   c(as.Date("2008-01-01"), as.Date("2009-04-30")),
#   c(as.Date("2020-02-01"), as.Date("2020-04-30"))
# )

################################################################################
# Data loading and preparation
################################################################################
if (exists("prepare_data", mode = "function")) {
  data <- prepare_data(DATA_PATH, START_DATE, dont_scale, recessions)
} else {
  data <- read_excel(DATA_PATH)
  data <- data.frame(data)
  data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
  data <- dplyr::filter(data, time >= START_DATE)
  
  # Apply optional recession filter
  if (!is.null(recessions)) {
    for (rr in recessions) {
      data <- data %>% filter(!(time >= rr[1] & time <= rr[2]))
    }
  }
  
  # Scale numeric columns except dummies
  numeric_columns <- sapply(data, is.numeric)
  numeric_columns[dont_scale] <- FALSE
  data[numeric_columns] <- scale(data[numeric_columns])
}

################################################################################
# Newey West coefficient tables (lag 4)
################################################################################
coeftable_df_nw4_local <- function(m) {
  ct <- lmtest::coeftest(m, vcov. = sandwich::NeweyWest(m, lag = 12, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname   = rownames(ct),
    estimate  = ct[, "Estimate"],
    se        = ct[, "Std. Error"],
    pval      = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

coeftable_df_nw4_safe <- function(m) {
  if (exists("coeftable_df_nw4", mode = "function")) return(coeftable_df_nw4(m))
  if (exists("coeftable_df_nw12", mode = "function")) return(coeftable_df_nw12(m))  # fallback if you prefer nw12
  coeftable_df_nw4_local(m)
}

################################################################################
# Models: education subsamples (models [1]–[6])
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
# Collect results
################################################################################
fit1 <- fit_no_controls_quotes_prim
fit2 <- fit_all_controls_quotes_prim
fit3 <- fit_no_controls_quotes_secon
fit4 <- fit_all_controls_quotes_secon
fit5 <- fit_no_controls_quotes_furth
fit6 <- fit_all_controls_quotes_furth

res1 <- coeftable_df_nw4_safe(fit1)
res2 <- coeftable_df_nw4_safe(fit2)
res3 <- coeftable_df_nw4_safe(fit3)
res4 <- coeftable_df_nw4_safe(fit4)
res5 <- coeftable_df_nw4_safe(fit5)
res6 <- coeftable_df_nw4_safe(fit6)

adj1 <- round(summary(fit1)$adj.r.squared, 3)
adj2 <- round(summary(fit2)$adj.r.squared, 3)
adj3 <- round(summary(fit3)$adj.r.squared, 3)
adj4 <- round(summary(fit4)$adj.r.squared, 3)
adj5 <- round(summary(fit5)$adj.r.squared, 3)
adj6 <- round(summary(fit6)$adj.r.squared, 3)