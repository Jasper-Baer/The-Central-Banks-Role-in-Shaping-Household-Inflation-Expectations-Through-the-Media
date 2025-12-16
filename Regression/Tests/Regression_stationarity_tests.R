################################################################################
# This script loads monthly regression datasets, runs ADF and Phillips-Perron
# unit-root tests for selected variables.
################################################################################

library(readxl)
library(urca)
library(dplyr)

################################################################################
# User settings
################################################################################

path_ecb_14 <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx"
path_inf_full <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"

start_date <- as.Date("2003-02-28")

output_dir <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/output_tests"

################################################################################
# Helpers
################################################################################

approx_pval_from_crit <- function(test_stat, crit_vals_named) {
  if (anyNA(c(test_stat, crit_vals_named))) return(NA_real_)
  
  crit_vals <- as.numeric(crit_vals_named[c("1pct", "5pct", "10pct")])
  levels <- c(1, 5, 10)
  
  p <- approx(x = crit_vals, y = levels, xout = as.numeric(test_stat), rule = 2)$y
  as.numeric(p) / 100
}

add_stars <- function(stat_value, p_val, digits = 3) {
  if (is.na(stat_value)) return(NA_character_)
  val_str <- format(round(stat_value, digits), nsmall = digits)
  
  if (is.na(p_val)) return(val_str)
  if (p_val <= 0.01) return(paste0(val_str, "***"))
  if (p_val <= 0.05) return(paste0(val_str, "**"))
  if (p_val < 0.10)  return(paste0(val_str, "*"))
  val_str
}

perform_adf_test <- function(variable_name, data, type = "drift", selectlags = "AIC") {
  if (!variable_name %in% names(data)) {
    return(data.frame(
      Variable = variable_name,
      ADF_Stat = NA_real_,
      ADF_pval = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  x <- na.omit(data[[variable_name]])
  if (length(x) < 10) {
    return(data.frame(
      Variable = variable_name,
      ADF_Stat = NA_real_,
      ADF_pval = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  adf <- ur.df(x, type = type, selectlags = selectlags)
  
  stat <- as.numeric(adf@teststat[, "tau2"])
  crit <- adf@cval["tau2", ]
  pval <- approx_pval_from_crit(stat, crit)
  
  data.frame(
    Variable = variable_name,
    ADF_Stat = stat,
    ADF_pval = pval,
    stringsAsFactors = FALSE
  )
}

perform_pp_test <- function(variable_name, data, type = "Z-tau", model = "constant", lags = "long") {
  if (!variable_name %in% names(data)) {
    return(data.frame(
      Variable = variable_name,
      PP_Stat = NA_real_,
      PP_pval = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  x <- na.omit(data[[variable_name]])
  if (length(x) < 10) {
    return(data.frame(
      Variable = variable_name,
      PP_Stat = NA_real_,
      PP_pval = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  pp <- ur.pp(x, type = type, model = model, lags = lags)
  
  stat <- as.numeric(pp@teststat)
  crit <- pp@cval
  
  crit_vec <- c("1pct" = crit[, "1pct"], "5pct" = crit[, "5pct"], "10pct" = crit[, "10pct"])
  pval <- approx_pval_from_crit(stat, crit_vec)
  
  data.frame(
    Variable = variable_name,
    PP_Stat = stat,
    PP_pval = pval,
    stringsAsFactors = FALSE
  )
}

run_unit_root_tests <- function(data, variables_to_test,
                                adf_type = "drift", adf_selectlags = "AIC",
                                pp_type = "Z-tau", pp_model = "constant", pp_lags = "long") {
  
  adf_df <- do.call(rbind, lapply(variables_to_test, perform_adf_test,
                                  data = data, type = adf_type, selectlags = adf_selectlags))
  pp_df  <- do.call(rbind, lapply(variables_to_test, perform_pp_test,
                                  data = data, type = pp_type, model = pp_model, lags = pp_lags))
  
  merged <- adf_df %>%
    inner_join(pp_df, by = "Variable") %>%
    mutate(
      ADF_Stat_fmt = mapply(add_stars, ADF_Stat, ADF_pval),
      PP_Stat_fmt  = mapply(add_stars, PP_Stat,  PP_pval)
    )
  
  merged
}

print_barebone <- function(df, title = NULL) {
  if (!is.null(title)) {
    cat("\n\n", title, "\n", paste(rep("-", nchar(title)), collapse = ""), "\n", sep = "")
  }
  out <- df %>%
    transmute(
      Variable,
      ADF_Stat = round(ADF_Stat, 3),
      ADF_pval = round(ADF_pval, 4),
      PP_Stat  = round(PP_Stat, 3),
      PP_pval  = round(PP_pval, 4),
      ADF_Stat_sig = ADF_Stat_fmt,
      PP_Stat_sig  = PP_Stat_fmt
    )
  print(out, row.names = FALSE)
  invisible(out)
}

################################################################################
# Dataset 1: 14 days after press conferences (ECB_2_og.xlsx)
################################################################################

data_14 <- read_excel(path_ecb_14) |> data.frame()
data_14$time <- as.Date(strptime(data_14$time, "%Y-%m-%d"))
data_14 <- data_14 %>% filter(time >= start_date)

variables_to_test_14 <- c(
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

results_14 <- run_unit_root_tests(data_14, variables_to_test_14)
all_14_tbl <- print_barebone(results_14, "Unit-root tests (14 days after press conferences): all variables")

vars_news_14 <- c(
  "News.Inflation.Inc.","News.Inflation.Dec.","News.Inflation.Direction.Index",
  "News.Inflation.Pos.","News.Inflation.Neg.","News.Inflation.Sentiment.Index",
  "News.Monetary.Quote.Hawkish","News.Monetary.Quote.Dovish","News.Monetary.Quote.Index",
  "News.Monetary.Quote.Pos.","News.Monetary.Quote.Neg.","News.Monetary.Quote.Sentiment.Index",
  "News.Monetary.Non.Quote.Hawkish","News.Monetary.Non.Quote.Dovish","News.Monetary.Non.Quote.Index",
  "News.Monetary.Non.Quote.Pos.","News.Monetary.Non.Quote.Neg.","News.Monetary.Non.Quote.Sentiment.Index",
  "Quote_Ratio"
)

vars_ecb_14 <- c(
  "ECB.PC.Inflation.Inc.","ECB.PC.Inflation.Dec.","ECB.PC.Inflation.Index",
  "ECB.PC.Outlook.Up","ECB.PC.Outlook.Down","ECB.PC.Outlook.Index",
  "ECB.PC.Monetary.Haw.","ECB.PC.Monetary.Dov.","ECB.PC.Monetary.Index",
  "ECB.PC.Monetary.Haw..difference","ECB.PC.Monetary.Dov..difference","ECB.PC.Monetary.Index.difference"
)

vars_quant_14 <- setdiff(variables_to_test_14, c(vars_news_14, vars_ecb_14))

print_barebone(results_14 %>% filter(Variable %in% vars_news_14), "Subset: News variables (14 days)")
print_barebone(results_14 %>% filter(Variable %in% vars_ecb_14),  "Subset: ECB variables (14 days)")
print_barebone(results_14 %>% filter(Variable %in% vars_quant_14), "Subset: Quantitative controls (14 days)")

if (!is.null(output_dir)) {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  write.csv(all_14_tbl, file.path(output_dir, "unit_root_results_14_all.csv"), row.names = FALSE)
  write.csv(all_14_tbl %>% filter(Variable %in% vars_news_14),  file.path(output_dir, "unit_root_results_14_news.csv"), row.names = FALSE)
  write.csv(all_14_tbl %>% filter(Variable %in% vars_ecb_14),   file.path(output_dir, "unit_root_results_14_ecb.csv"), row.names = FALSE)
  write.csv(all_14_tbl %>% filter(Variable %in% vars_quant_14), file.path(output_dir, "unit_root_results_14_quant.csv"), row.names = FALSE)
}

################################################################################
# Dataset 2: survey month (Regession_data_monthly_2_processed_inf.xlsx)
################################################################################

data_full <- read_excel(path_inf_full) |> data.frame()
data_full$time <- as.Date(strptime(data_full$time, "%Y-%m-%d"))
data_full <- data_full %>% filter(time >= start_date)

variables_to_test_full <- c(
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
  "Germany.Unemployment",
  "Germany.Unemployment.difference",
  "German.Industrial.Production.Gap",
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

results_full <- run_unit_root_tests(data_full, variables_to_test_full)
all_full_tbl <- print_barebone(results_full, "Unit-root tests (survey month): all variables")

vars_news_full <- c(
  "News.Inflation.Direction.Index_stored_1","News.Inflation.Inc._stored_1","News.Inflation.Dec._stored_1",
  "News.Inflation.Sentiment.Index_stored_1","News.Inflation.Pos._stored_1","News.Inflation.Neg._stored_1",
  "News.Monetary.Non.Quote.Index_stored_1","News.Monetary.Non.Quote.Hawkish_stored_1","News.Monetary.Non.Quote.Dovish_stored_1",
  "News.Monetary.Quote.Index_stored_1","News.Monetary.Quote.Hawkish_stored_1","News.Monetary.Quote.Dovish_stored_1",
  "News.Monetary.Non.Quote.Sentiment.Index_stored_1","News.Monetary.Non.Quote.Pos._stored_1","News.Monetary.Non.Quote.Neg._stored_1",
  "News.Monetary.Quote.Sentiment.Index_stored_1","News.Monetary.Quote.Pos._stored_1","News.Monetary.Quote.Neg._stored_1",
  "News.Inflation.Direction.Index","News.Inflation.Inc.","News.Inflation.Dec.",
  "News.Inflation.Sentiment.Index","News.Inflation.Pos.","News.Inflation.Neg.",
  "News.Monetary.Non.Quote.Index","News.Monetary.Non.Quote.Hawkish","News.Monetary.Non.Quote.Dovish",
  "News.Monetary.Quote.Index","News.Monetary.Quote.Hawkish","News.Monetary.Quote.Dovish",
  "News.Monetary.Non.Quote.Sentiment.Index","News.Monetary.Non.Quote.Pos.","News.Monetary.Non.Quote.Neg.",
  "News.Monetary.Quote.Sentiment.Index","News.Monetary.Quote.Pos.","News.Monetary.Quote.Neg.",
  "Quote_Ratio"
)

vars_quant_full <- setdiff(variables_to_test_full, vars_news_full)

print_barebone(results_full %>% filter(Variable %in% vars_news_full),  "Subset: News variables (survey month)")
print_barebone(results_full %>% filter(Variable %in% vars_quant_full), "Subset: Quantitative controls (survey month)")

if (!is.null(output_dir)) {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  write.csv(all_full_tbl, file.path(output_dir, "unit_root_results_full_all.csv"), row.names = FALSE)
  write.csv(all_full_tbl %>% filter(Variable %in% vars_news_full),  file.path(output_dir, "unit_root_results_full_news.csv"), row.names = FALSE)
  write.csv(all_full_tbl %>% filter(Variable %in% vars_quant_full), file.path(output_dir, "unit_root_results_full_quant.csv"), row.names = FALSE)
}