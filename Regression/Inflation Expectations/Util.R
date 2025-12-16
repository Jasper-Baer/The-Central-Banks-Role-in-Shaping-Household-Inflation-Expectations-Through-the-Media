#####################################################################################
# Helpers used across the three regression scripts
#####################################################################################

# Scaling numeric columns except those explicitly excluded
scale_num <- function(df, exclude = character()) {
  is_num <- sapply(df, is.numeric)
  is_num[intersect(names(is_num), exclude)] <- FALSE
  
  cols <- names(df)[is_num]
  df[cols] <- lapply(df[cols], function(x) as.numeric(base::scale(x)))
  df
}

# Build 2022 month dummies (Feb–Dec) 
add_rec_dummies_2022 <- function(df) {
  rec_months <- seq(as.Date("2022-02-01"), as.Date("2022-12-01"), by = "month")
  rec_labels <- paste0("REC_", format(rec_months, "%Y_%m"))
  
  month_tag <- format(df$time, "%Y-%m")
  rec_tags  <- format(rec_months, "%Y-%m")
  
  rec_df <- as.data.frame(sapply(rec_tags, function(m) as.integer(month_tag == m)))
  names(rec_df) <- rec_labels
  
  dplyr::bind_cols(df, rec_df)
}

# Filter out recession periods
filter_recessions <- function(df, recessions) {
  if (is.null(recessions) || length(recessions) == 0) return(df)
  df %>%
    dplyr::filter(!Reduce(`|`, lapply(recessions, function(r) time >= r[1] & time <= r[2])))
}

# Load + date parsing + start-date filter + REC dummies + scaling (+ optional recessions)
prepare_data <- function(data_path, start_date, dont_scale, recessions = NULL) {
  
  data <- readxl::read_excel(data_path) |> data.frame()
  data$time <- as.Date(strptime(data$time, "%Y-%m-%d"))
  data <- data |> dplyr::filter(time >= start_date)
  
  data <- add_rec_dummies_2022(data)
  
  # Always exclude REC dummies from scaling
  rec_dummy_names <- paste0("REC_2022_", sprintf("%02d", 2:12))
  dont_scale_all  <- unique(c(dont_scale, rec_dummy_names))
  
  data <- scale_num(data, exclude = dont_scale_all)
  
  data <- filter_recessions(data, recessions)
  
  data
}

# Newey–West coeftable
coeftable_df_nw12 <- function(model) {
  ct <- lmtest::coeftest(
    model,
    vcov. = sandwich::NeweyWest(model, lag = 12, prewhite = FALSE, adjust = TRUE)
  )
  data.frame(
    varname  = rownames(ct),
    estimate = ct[, "Estimate"],
    se       = ct[, "Std. Error"],
    pval     = ct[, "Pr(>|t|)"],
    stringsAsFactors = FALSE
  )
}
