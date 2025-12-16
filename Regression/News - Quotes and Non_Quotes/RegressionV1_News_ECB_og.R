#####################################################################################
# This file estimates the baseline monetary-stance and monetary-sentiment news
# regressions (Quote vs Non-Quote) and outputs Newey West (lag 12) coefficient 
# tables.
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
library("car")

################################################################################
# Paths and settings
################################################################################
DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx"
START_DATE <- as.Date("2003-02-28")

# Use util helpers
UTIL_PATH <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Inflation Expectations/Util.R"
if (file.exists(UTIL_PATH)) source(UTIL_PATH)

dont_scale <- c("draghi","negative","trichet","whatever","Unmon",
                "REC_2022_03","REC_2022_04","REC_2022_05","REC_2022_06","REC_2022_07","REC_2022_08")

################################################################################
# Data loading and preparation
################################################################################
data <- read_excel(DATA_PATH)
data <- data.frame(data)

data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
data <- data %>% filter(time >= START_DATE)

# Build 2022 month dummies (Feb–Dec)
rec_months <- seq(as.Date("2022-02-01"), as.Date("2022-12-01"), by = "month")
rec_labels <- paste0("REC_", format(rec_months, "%Y_%m"))
month_tag  <- format(data$time, "%Y-%m")
rec_tags   <- format(rec_months, "%Y-%m")
rec_df     <- as.data.frame(sapply(rec_tags, function(m) as.integer(month_tag == m)))
names(rec_df) <- rec_labels
data <- dplyr::bind_cols(data, rec_df)

# Scale numeric columns except specified
numeric_columns <- sapply(data, is.numeric)
numeric_columns[dont_scale] <- FALSE
data[numeric_columns] <- scale(data[numeric_columns])

################################################################################
# Canonicalize ECB PC variables (levels vs diffs)
################################################################################
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

################################################################################
# Newey West coefficient tables (lag 12)
################################################################################
coeftable_df_nw12_local <- function(m) {
  ct <- lmtest::coeftest(m, vcov. = sandwich::NeweyWest(m, lag = 12, prewhite = FALSE, adjust = TRUE))
  data.frame(
    varname   = rownames(ct),
    estimate  = ct[, "Estimate"],
    se        = ct[, "Std. Error"],
    pval      = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}

coeftable_df_nw12_safe <- function(m) {
  if (exists("coeftable_df_nw12", mode = "function")) {
    return(coeftable_df_nw12(m))
  }
  coeftable_df_nw12_local(m)
}

################################################################################
# Monetary news regressions (stance and sentiment)
################################################################################
df_to_use <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)

################################################################################
# Monetary stance news regressions (Non-Quote)
################################################################################

# Hawkish
fit_nq_haw_1 <- lm(
  News.Monetary.Non.Quote.Hawkish ~ News.Monetary.Non.Quote.Hawkish.Lag1 + News.Monetary.Non.Quote.Hawkish.Lag2 + News.Monetary.Non.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_haw_2 <- lm(
  News.Monetary.Non.Quote.Hawkish ~ News.Monetary.Non.Quote.Hawkish.Lag1 + News.Monetary.Non.Quote.Hawkish.Lag2 + News.Monetary.Non.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_nq_haw_3 <- lm(
  News.Monetary.Non.Quote.Hawkish ~ News.Monetary.Non.Quote.Hawkish.Lag1 + News.Monetary.Non.Quote.Hawkish.Lag2 + News.Monetary.Non.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference +
    DAX.difference + VDAX + Unmon, df_to_use)

# Dovish
fit_nq_dov_1 <- lm(
  News.Monetary.Non.Quote.Dovish ~ News.Monetary.Non.Quote.Dovish.Lag1 + News.Monetary.Non.Quote.Dovish.Lag2 + News.Monetary.Non.Quote.Dovish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_dov_2 <- lm(
  News.Monetary.Non.Quote.Dovish ~ News.Monetary.Non.Quote.Dovish.Lag1 + News.Monetary.Non.Quote.Dovish.Lag2 + News.Monetary.Non.Quote.Dovish.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_nq_dov_3 <- lm(
  News.Monetary.Non.Quote.Dovish ~ News.Monetary.Non.Quote.Dovish.Lag1 + News.Monetary.Non.Quote.Dovish.Lag2 + News.Monetary.Non.Quote.Dovish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

# Stance index
fit_nq_idx_1 <- lm(
  News.Monetary.Non.Quote.Index ~ News.Monetary.Non.Quote.Index.Lag1 + News.Monetary.Non.Quote.Index.Lag2 + News.Monetary.Non.Quote.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_idx_2 <- lm(
  News.Monetary.Non.Quote.Index ~ News.Monetary.Non.Quote.Index.Lag1 + News.Monetary.Non.Quote.Index.Lag2 + News.Monetary.Non.Quote.Index.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_nq_idx_3 <- lm(
  News.Monetary.Non.Quote.Index ~ News.Monetary.Non.Quote.Index.Lag1 + News.Monetary.Non.Quote.Index.Lag2 + News.Monetary.Non.Quote.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Monetary stance news regressions (Quote)
################################################################################

# Hawkish
fit_q_haw_1 <- lm(
  News.Monetary.Quote.Hawkish ~ News.Monetary.Quote.Hawkish.Lag1 + News.Monetary.Quote.Hawkish.Lag2 + News.Monetary.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_haw_2 <- lm(
  News.Monetary.Quote.Hawkish ~ News.Monetary.Quote.Hawkish.Lag1 + News.Monetary.Quote.Hawkish.Lag2 + News.Monetary.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_q_haw_3 <- lm(
  News.Monetary.Quote.Hawkish ~ News.Monetary.Quote.Hawkish.Lag1 + News.Monetary.Quote.Hawkish.Lag2 + News.Monetary.Quote.Hawkish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference +
    DAX.difference + VDAX + Unmon, df_to_use)

# Dovish
fit_q_dov_1 <- lm(
  News.Monetary.Quote.Dovish ~ News.Monetary.Quote.Dovish.Lag1 + News.Monetary.Quote.Dovish.Lag2 + News.Monetary.Quote.Dovish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_dov_2 <- lm(
  News.Monetary.Quote.Dovish ~ News.Monetary.Quote.Dovish.Lag1 + News.Monetary.Quote.Dovish.Lag2 + News.Monetary.Quote.Dovish.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_q_dov_3 <- lm(
  News.Monetary.Quote.Dovish ~ News.Monetary.Quote.Dovish.Lag1 + News.Monetary.Quote.Dovish.Lag2 + News.Monetary.Quote.Dovish.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

# Stance index
fit_q_idx_1 <- lm(
  News.Monetary.Quote.Index ~ News.Monetary.Quote.Index.Lag1 + News.Monetary.Quote.Index.Lag2 + News.Monetary.Quote.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_idx_2 <- lm(
  News.Monetary.Quote.Index ~ News.Monetary.Quote.Index.Lag1 + News.Monetary.Quote.Index.Lag2 + News.Monetary.Quote.Index.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference, df_to_use)

fit_q_idx_3 <- lm(
  News.Monetary.Quote.Index ~ News.Monetary.Quote.Index.Lag1 + News.Monetary.Quote.Index.Lag2 + News.Monetary.Quote.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Monetary sentiment news regressions (Non-Quote)
################################################################################

# Positive
fit_nq_pos_1 <- lm(
  News.Monetary.Non.Quote.Pos. ~ News.Monetary.Non.Quote.Pos..Lag1 + News.Monetary.Non.Quote.Pos..Lag2 + News.Monetary.Non.Quote.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_pos_2 <- lm(
  News.Monetary.Non.Quote.Pos. ~ News.Monetary.Non.Quote.Pos..Lag1 + News.Monetary.Non.Quote.Pos..Lag2 + News.Monetary.Non.Quote.Pos..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_nq_pos_3 <- lm(
  News.Monetary.Non.Quote.Pos. ~ News.Monetary.Non.Quote.Pos..Lag1 + News.Monetary.Non.Quote.Pos..Lag2 + News.Monetary.Non.Quote.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference +
    DAX.difference + VDAX + Unmon, df_to_use)

# Negative
fit_nq_neg_1 <- lm(
  News.Monetary.Non.Quote.Neg. ~ News.Monetary.Non.Quote.Neg..Lag1 + News.Monetary.Non.Quote.Neg..Lag2 + News.Monetary.Non.Quote.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_neg_2 <- lm(
  News.Monetary.Non.Quote.Neg. ~ News.Monetary.Non.Quote.Neg..Lag1 + News.Monetary.Non.Quote.Neg..Lag2 + News.Monetary.Non.Quote.Neg..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_nq_neg_3 <- lm(
  News.Monetary.Non.Quote.Neg. ~ News.Monetary.Non.Quote.Neg..Lag1 + News.Monetary.Non.Quote.Neg..Lag2 + News.Monetary.Non.Quote.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

# Sentiment index
fit_nq_sen_1 <- lm(
  News.Monetary.Non.Quote.Sentiment.Index ~ News.Monetary.Non.Quote.Sentiment.Index.Lag1 + News.Monetary.Non.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Non.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_nq_sen_2 <- lm(
  News.Monetary.Non.Quote.Sentiment.Index ~ News.Monetary.Non.Quote.Sentiment.Index.Lag1 + News.Monetary.Non.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Non.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_nq_sen_3 <- lm(
  News.Monetary.Non.Quote.Sentiment.Index ~ News.Monetary.Non.Quote.Sentiment.Index.Lag1 + News.Monetary.Non.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Non.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Monetary sentiment news regressions (Quote)
################################################################################

# Positive
fit_q_pos_1 <- lm(
  News.Monetary.Quote.Pos. ~ News.Monetary.Quote.Pos..Lag1 + News.Monetary.Quote.Pos..Lag2 + News.Monetary.Quote.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_pos_2 <- lm(
  News.Monetary.Quote.Pos. ~ News.Monetary.Quote.Pos..Lag1 + News.Monetary.Quote.Pos..Lag2 + News.Monetary.Quote.Pos..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_q_pos_3 <- lm(
  News.Monetary.Quote.Pos. ~ News.Monetary.Quote.Pos..Lag1 + News.Monetary.Quote.Pos..Lag2 + News.Monetary.Quote.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + ED.Exchange.Rate.difference +
    DAX.difference + VDAX + Unmon, df_to_use)

# Negative
fit_q_neg_1 <- lm(
  News.Monetary.Quote.Neg. ~ News.Monetary.Quote.Neg..Lag1 + News.Monetary.Quote.Neg..Lag2 + News.Monetary.Quote.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_neg_2 <- lm(
  News.Monetary.Quote.Neg. ~ News.Monetary.Quote.Neg..Lag1 + News.Monetary.Quote.Neg..Lag2 + News.Monetary.Quote.Neg..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_q_neg_3 <- lm(
  News.Monetary.Quote.Neg. ~ News.Monetary.Quote.Neg..Lag1 + News.Monetary.Quote.Neg..Lag2 + News.Monetary.Quote.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

# Sentiment index
fit_q_sen_1 <- lm(
  News.Monetary.Quote.Sentiment.Index ~ News.Monetary.Quote.Sentiment.Index.Lag1 + News.Monetary.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.MRO.difference, df_to_use)

fit_q_sen_2 <- lm(
  News.Monetary.Quote.Sentiment.Index ~ News.Monetary.Quote.Sentiment.Index.Lag1 + News.Monetary.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.MRO.difference + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_q_sen_3 <- lm(
  News.Monetary.Quote.Sentiment.Index ~ News.Monetary.Quote.Sentiment.Index.Lag1 + News.Monetary.Quote.Sentiment.Index.Lag2 +
    News.Monetary.Quote.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference + ECB.MRO.difference +
    draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG + DAX.difference + VDAX +
    ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Collect results
################################################################################

# Non-Quote stance block
res_nq_haw_1 <- coeftable_df_nw12_safe(fit_nq_haw_1)
res_nq_haw_2 <- coeftable_df_nw12_safe(fit_nq_haw_2)
res_nq_haw_3 <- coeftable_df_nw12_safe(fit_nq_haw_3)

res_nq_dov_1 <- coeftable_df_nw12_safe(fit_nq_dov_1)
res_nq_dov_2 <- coeftable_df_nw12_safe(fit_nq_dov_2)
res_nq_dov_3 <- coeftable_df_nw12_safe(fit_nq_dov_3)

res_nq_idx_1 <- coeftable_df_nw12_safe(fit_nq_idx_1)
res_nq_idx_2 <- coeftable_df_nw12_safe(fit_nq_idx_2)
res_nq_idx_3 <- coeftable_df_nw12_safe(fit_nq_idx_3)

adj_nq_haw_1 <- round(summary(fit_nq_haw_1)$adj.r.squared, 3)
adj_nq_haw_2 <- round(summary(fit_nq_haw_2)$adj.r.squared, 3)
adj_nq_haw_3 <- round(summary(fit_nq_haw_3)$adj.r.squared, 3)
adj_nq_dov_1 <- round(summary(fit_nq_dov_1)$adj.r.squared, 3)
adj_nq_dov_2 <- round(summary(fit_nq_dov_2)$adj.r.squared, 3)
adj_nq_dov_3 <- round(summary(fit_nq_dov_3)$adj.r.squared, 3)
adj_nq_idx_1 <- round(summary(fit_nq_idx_1)$adj.r.squared, 3)
adj_nq_idx_2 <- round(summary(fit_nq_idx_2)$adj.r.squared, 3)
adj_nq_idx_3 <- round(summary(fit_nq_idx_3)$adj.r.squared, 3)

obs_nq_haw_1 <- nobs(fit_nq_haw_1); obs_nq_haw_2 <- nobs(fit_nq_haw_2); obs_nq_haw_3 <- nobs(fit_nq_haw_3)
obs_nq_dov_1 <- nobs(fit_nq_dov_1); obs_nq_dov_2 <- nobs(fit_nq_dov_2); obs_nq_dov_3 <- nobs(fit_nq_dov_3)
obs_nq_idx_1 <- nobs(fit_nq_idx_1); obs_nq_idx_2 <- nobs(fit_nq_idx_2); obs_nq_idx_3 <- nobs(fit_nq_idx_3)

# Quote stance block
res_q_haw_1 <- coeftable_df_nw12_safe(fit_q_haw_1)
res_q_haw_2 <- coeftable_df_nw12_safe(fit_q_haw_2)
res_q_haw_3 <- coeftable_df_nw12_safe(fit_q_haw_3)

res_q_dov_1 <- coeftable_df_nw12_safe(fit_q_dov_1)
res_q_dov_2 <- coeftable_df_nw12_safe(fit_q_dov_2)
res_q_dov_3 <- coeftable_df_nw12_safe(fit_q_dov_3)

res_q_idx_1 <- coeftable_df_nw12_safe(fit_q_idx_1)
res_q_idx_2 <- coeftable_df_nw12_safe(fit_q_idx_2)
res_q_idx_3 <- coeftable_df_nw12_safe(fit_q_idx_3)

adj_q_haw_1 <- round(summary(fit_q_haw_1)$adj.r.squared, 3)
adj_q_haw_2 <- round(summary(fit_q_haw_2)$adj.r.squared, 3)
adj_q_haw_3 <- round(summary(fit_q_haw_3)$adj.r.squared, 3)
adj_q_dov_1 <- round(summary(fit_q_dov_1)$adj.r.squared, 3)
adj_q_dov_2 <- round(summary(fit_q_dov_2)$adj.r.squared, 3)
adj_q_dov_3 <- round(summary(fit_q_dov_3)$adj.r.squared, 3)
adj_q_idx_1 <- round(summary(fit_q_idx_1)$adj.r.squared, 3)
adj_q_idx_2 <- round(summary(fit_q_idx_2)$adj.r.squared, 3)
adj_q_idx_3 <- round(summary(fit_q_idx_3)$adj.r.squared, 3)

obs_q_haw_1 <- nobs(fit_q_haw_1); obs_q_haw_2 <- nobs(fit_q_haw_2); obs_q_haw_3 <- nobs(fit_q_haw_3)
obs_q_dov_1 <- nobs(fit_q_dov_1); obs_q_dov_2 <- nobs(fit_q_dov_2); obs_q_dov_3 <- nobs(fit_q_dov_3)
obs_q_idx_1 <- nobs(fit_q_idx_1); obs_q_idx_2 <- nobs(fit_q_idx_2); obs_q_idx_3 <- nobs(fit_q_idx_3)

# Non-Quote sentiment block
res_nq_pos_1 <- coeftable_df_nw12_safe(fit_nq_pos_1)
res_nq_pos_2 <- coeftable_df_nw12_safe(fit_nq_pos_2)
res_nq_pos_3 <- coeftable_df_nw12_safe(fit_nq_pos_3)

res_nq_neg_1 <- coeftable_df_nw12_safe(fit_nq_neg_1)
res_nq_neg_2 <- coeftable_df_nw12_safe(fit_nq_neg_2)
res_nq_neg_3 <- coeftable_df_nw12_safe(fit_nq_neg_3)

res_nq_sen_1 <- coeftable_df_nw12_safe(fit_nq_sen_1)
res_nq_sen_2 <- coeftable_df_nw12_safe(fit_nq_sen_2)
res_nq_sen_3 <- coeftable_df_nw12_safe(fit_nq_sen_3)

adj_nq_pos_1 <- round(summary(fit_nq_pos_1)$adj.r.squared, 3)
adj_nq_pos_2 <- round(summary(fit_nq_pos_2)$adj.r.squared, 3)
adj_nq_pos_3 <- round(summary(fit_nq_pos_3)$adj.r.squared, 3)
adj_nq_neg_1 <- round(summary(fit_nq_neg_1)$adj.r.squared, 3)
adj_nq_neg_2 <- round(summary(fit_nq_neg_2)$adj.r.squared, 3)
adj_nq_neg_3 <- round(summary(fit_nq_neg_3)$adj.r.squared, 3)
adj_nq_sen_1 <- round(summary(fit_nq_sen_1)$adj.r.squared, 3)
adj_nq_sen_2 <- round(summary(fit_nq_sen_2)$adj.r.squared, 3)
adj_nq_sen_3 <- round(summary(fit_nq_sen_3)$adj.r.squared, 3)

obs_nq_pos_1 <- nobs(fit_nq_pos_1); obs_nq_pos_2 <- nobs(fit_nq_pos_2); obs_nq_pos_3 <- nobs(fit_nq_pos_3)
obs_nq_neg_1 <- nobs(fit_nq_neg_1); obs_nq_neg_2 <- nobs(fit_nq_neg_2); obs_nq_neg_3 <- nobs(fit_nq_neg_3)
obs_nq_sen_1 <- nobs(fit_nq_sen_1); obs_nq_sen_2 <- nobs(fit_nq_sen_2); obs_nq_sen_3 <- nobs(fit_nq_sen_3)

# Quote sentiment block
res_q_pos_1 <- coeftable_df_nw12_safe(fit_q_pos_1)
res_q_pos_2 <- coeftable_df_nw12_safe(fit_q_pos_2)
res_q_pos_3 <- coeftable_df_nw12_safe(fit_q_pos_3)

res_q_neg_1 <- coeftable_df_nw12_safe(fit_q_neg_1)
res_q_neg_2 <- coeftable_df_nw12_safe(fit_q_neg_2)
res_q_neg_3 <- coeftable_df_nw12_safe(fit_q_neg_3)

res_q_sen_1 <- coeftable_df_nw12_safe(fit_q_sen_1)
res_q_sen_2 <- coeftable_df_nw12_safe(fit_q_sen_2)
res_q_sen_3 <- coeftable_df_nw12_safe(fit_q_sen_3)

adj_q_pos_1 <- round(summary(fit_q_pos_1)$adj.r.squared, 3)
adj_q_pos_2 <- round(summary(fit_q_pos_2)$adj.r.squared, 3)
adj_q_pos_3 <- round(summary(fit_q_pos_3)$adj.r.squared, 3)
adj_q_neg_1 <- round(summary(fit_q_neg_1)$adj.r.squared, 3)
adj_q_neg_2 <- round(summary(fit_q_neg_2)$adj.r.squared, 3)
adj_q_neg_3 <- round(summary(fit_q_neg_3)$adj.r.squared, 3)
adj_q_sen_1 <- round(summary(fit_q_sen_1)$adj.r.squared, 3)
adj_q_sen_2 <- round(summary(fit_q_sen_2)$adj.r.squared, 3)
adj_q_sen_3 <- round(summary(fit_q_sen_3)$adj.r.squared, 3)

obs_q_pos_1 <- nobs(fit_q_pos_1); obs_q_pos_2 <- nobs(fit_q_pos_2); obs_q_pos_3 <- nobs(fit_q_pos_3)
obs_q_neg_1 <- nobs(fit_q_neg_1); obs_q_neg_2 <- nobs(fit_q_neg_2); obs_q_neg_3 <- nobs(fit_q_neg_3)
obs_q_sen_1 <- nobs(fit_q_sen_1); obs_q_sen_2 <- nobs(fit_q_sen_2); obs_q_sen_3 <- nobs(fit_q_sen_3)

################################################################################
# print(res_nq_haw_1)
# print(res_nq_haw_2)
# print(res_nq_haw_3)
