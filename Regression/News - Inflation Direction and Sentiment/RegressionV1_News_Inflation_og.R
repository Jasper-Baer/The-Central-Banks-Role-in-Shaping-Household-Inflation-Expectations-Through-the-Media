#####################################################################################
# This file estimates the baseline inflation-direction and inflation-sentiment news
# regressions outputs bare-bones Newey West (lag 12) coefficient tables.
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
# Inflation direction news regressions
################################################################################
df_to_use <- canonize_ecb_pc(data, use_diffs_infeco = FALSE, use_diffs_mp = FALSE)

# Increasing
fit_inc_1 <- lm(
  News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_inc_2 <- lm(
  News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_inc_3 <- lm(
  News.Inflation.Inc. ~ News.Inflation.Inc..Lag1 + News.Inflation.Inc..Lag2 + News.Inflation.Inc..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    ED.Exchange.Rate.difference + DAX.difference + VDAX + Unmon, df_to_use)

# Decreasing
fit_dec_1 <- lm(
  News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_dec_2 <- lm(
  News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_dec_3 <- lm(
  News.Inflation.Dec. ~ News.Inflation.Dec..Lag1 + News.Inflation.Dec..Lag2 + News.Inflation.Dec..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df_to_use)

# Direction index
fit_idx_1 <- lm(
  News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
    News.Inflation.Direction.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_idx_2 <- lm(
  News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
    News.Inflation.Direction.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_idx_3 <- lm(
  News.Inflation.Direction.Index ~ News.Inflation.Direction.Index.Lag1 + News.Inflation.Direction.Index.Lag2 +
    News.Inflation.Direction.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    REC_2022_03 + REC_2022_04 + REC_2022_05 + REC_2022_06 + REC_2022_07 + REC_2022_08 +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Inflation sentiment news regressions (3 DVs × 3 specs)
################################################################################

# Positive
fit_pos_1 <- lm(
  News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_pos_2 <- lm(
  News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_pos_3 <- lm(
  News.Inflation.Pos. ~ News.Inflation.Pos..Lag1 + News.Inflation.Pos..Lag2 + News.Inflation.Pos..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    ED.Exchange.Rate.difference + DAX.difference + VDAX + Unmon, df_to_use)

# Negative
fit_neg_1 <- lm(
  News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_neg_2 <- lm(
  News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_neg_3 <- lm(
  News.Inflation.Neg. ~ News.Inflation.Neg..Lag1 + News.Inflation.Neg..Lag2 + News.Inflation.Neg..Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df_to_use)

# Sentiment index
fit_sen_1 <- lm(
  News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
    News.Inflation.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference, df_to_use)

fit_sen_2 <- lm(
  News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
    News.Inflation.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference, df_to_use)

fit_sen_3 <- lm(
  News.Inflation.Sentiment.Index ~ News.Inflation.Sentiment.Index.Lag1 + News.Inflation.Sentiment.Index.Lag2 +
    News.Inflation.Sentiment.Index.Lag3 +
    ECB.PC.Outlook.Up + ECB.PC.Outlook.Down + ECB.PC.Monetary.Haw. + ECB.PC.Monetary.Dov. +
    ECB.PC.Inflation.Inc. + ECB.PC.Inflation.Dec. +
    Germany.Conf.difference +
    German.Inflation.Year.on.Year.difference + Reuter.Poll.Forecast.difference +
    German.Industrial.Production.Gap + Germany.Unemployment.difference +
    ECB.MRO.difference + draghi + negative + whatever + ECB.MRO.POS + ECB.MRO.NEG +
    DAX.difference + VDAX + ED.Exchange.Rate.difference + Unmon, df_to_use)

################################################################################
# Collect results
################################################################################

# Direction block 
res_inc_1 <- coeftable_df_nw12_safe(fit_inc_1)
res_inc_2 <- coeftable_df_nw12_safe(fit_inc_2)
res_inc_3 <- coeftable_df_nw12_safe(fit_inc_3)

res_dec_1 <- coeftable_df_nw12_safe(fit_dec_1)
res_dec_2 <- coeftable_df_nw12_safe(fit_dec_2)
res_dec_3 <- coeftable_df_nw12_safe(fit_dec_3)

res_idx_1 <- coeftable_df_nw12_safe(fit_idx_1)
res_idx_2 <- coeftable_df_nw12_safe(fit_idx_2)
res_idx_3 <- coeftable_df_nw12_safe(fit_idx_3)

adj_inc_1 <- round(summary(fit_inc_1)$adj.r.squared, 3)
adj_inc_2 <- round(summary(fit_inc_2)$adj.r.squared, 3)
adj_inc_3 <- round(summary(fit_inc_3)$adj.r.squared, 3)
adj_dec_1 <- round(summary(fit_dec_1)$adj.r.squared, 3)
adj_dec_2 <- round(summary(fit_dec_2)$adj.r.squared, 3)
adj_dec_3 <- round(summary(fit_dec_3)$adj.r.squared, 3)
adj_idx_1 <- round(summary(fit_idx_1)$adj.r.squared, 3)
adj_idx_2 <- round(summary(fit_idx_2)$adj.r.squared, 3)
adj_idx_3 <- round(summary(fit_idx_3)$adj.r.squared, 3)

obs_inc_1 <- nobs(fit_inc_1); obs_inc_2 <- nobs(fit_inc_2); obs_inc_3 <- nobs(fit_inc_3)
obs_dec_1 <- nobs(fit_dec_1); obs_dec_2 <- nobs(fit_dec_2); obs_dec_3 <- nobs(fit_dec_3)
obs_idx_1 <- nobs(fit_idx_1); obs_idx_2 <- nobs(fit_idx_2); obs_idx_3 <- nobs(fit_idx_3)

# Sentiment block 
res_pos_1 <- coeftable_df_nw12_safe(fit_pos_1)
res_pos_2 <- coeftable_df_nw12_safe(fit_pos_2)
res_pos_3 <- coeftable_df_nw12_safe(fit_pos_3)

res_neg_1 <- coeftable_df_nw12_safe(fit_neg_1)
res_neg_2 <- coeftable_df_nw12_safe(fit_neg_2)
res_neg_3 <- coeftable_df_nw12_safe(fit_neg_3)

res_sen_1 <- coeftable_df_nw12_safe(fit_sen_1)
res_sen_2 <- coeftable_df_nw12_safe(fit_sen_2)
res_sen_3 <- coeftable_df_nw12_safe(fit_sen_3)

adj_pos_1 <- round(summary(fit_pos_1)$adj.r.squared, 3)
adj_pos_2 <- round(summary(fit_pos_2)$adj.r.squared, 3)
adj_pos_3 <- round(summary(fit_pos_3)$adj.r.squared, 3)
adj_neg_1 <- round(summary(fit_neg_1)$adj.r.squared, 3)
adj_neg_2 <- round(summary(fit_neg_2)$adj.r.squared, 3)
adj_neg_3 <- round(summary(fit_neg_3)$adj.r.squared, 3)
adj_sen_1 <- round(summary(fit_sen_1)$adj.r.squared, 3)
adj_sen_2 <- round(summary(fit_sen_2)$adj.r.squared, 3)
adj_sen_3 <- round(summary(fit_sen_3)$adj.r.squared, 3)

obs_pos_1 <- nobs(fit_pos_1); obs_pos_2 <- nobs(fit_pos_2); obs_pos_3 <- nobs(fit_pos_3)
obs_neg_1 <- nobs(fit_neg_1); obs_neg_2 <- nobs(fit_neg_2); obs_neg_3 <- nobs(fit_neg_3)
obs_sen_1 <- nobs(fit_sen_1); obs_sen_2 <- nobs(fit_sen_2); obs_sen_3 <- nobs(fit_sen_3)

################################################################################
# print(res_inc_1)
# print(res_inc_2)
# print(res_inc_3)
