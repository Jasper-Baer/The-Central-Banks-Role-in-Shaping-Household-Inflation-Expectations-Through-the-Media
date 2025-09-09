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

library("lmtest")
library("sandwich")
library("stargazer")
library('car')

library("dplyr")
library("tidyr")
library("kableExtra")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
data = data.frame(data)
data <- data[12:(nrow(data)), ]

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)
data <- data[12:(nrow(data)), ]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

numeric_columns <- sapply(data, is.numeric)

dont_scale_names = c("draghi", "negative", "trichet", "whatever", "Unmon")

numeric_columns[dont_scale_names] <- FALSE
data[numeric_columns] <- scale(data[numeric_columns])

###############
# Correlation #
###############

################################################################################

use_first_differences <- FALSE
#use_first_differences <- TRUE

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

groups <- list(
  "Inflation News" = c(
    "News.Inflation.Inc.",
   # "News.Inflation.Stable",
    "News.Inflation.Dec.",
    "News.Inflation.Direction.Index",
    "News.Inflation.Pos.",
   # "News.Inflation.Neu.",
    "News.Inflation.Neg.",
    "News.Inflation.Sentiment.Index"
  ),
  "Monetary Policy News - Quotes" = c(
    "News.Monetary.Quote.Hawkish",
 #   "News.Monetary.Quote.Stable",     
    "News.Monetary.Quote.Dovish",
"News.Monetary.Quote.Index",
"News.Monetary.Quote.Pos.",
#"News.Monetary.Quote.Neu.",
"News.Monetary.Quote.Neg.",
"News.Monetary.Quote.Sentiment.Index"
  ),
  "Monetary Policy News - Non-Quotes" = c(
    "News.Monetary.Non.Quote.Hawkish",
 #   "News.Monetary.Non.Quote.Stable",  
    "News.Monetary.Non.Quote.Dovish",
"News.Monetary.Non.Quote.Index",
    "News.Monetary.Non.Quote.Pos.",
 #   "News.Monetary.Non.Quote.Neu.",
    "News.Monetary.Non.Quote.Neg.",
"News.Monetary.Non.Quote.Sentiment.Index"
  ),
  "ECB Inflation Outlook" = c(
    "ECB.PC.Inflation.Inc.",
  #  "ECB.PC.Inflation.Stable",
    "ECB.PC.Inflation.Dec.",
  "ECB.PC.Inflation.Index"
  ),

"ECB Monetary Stance" = c(
 "ECB.PC.Monetary.Haw.",
#  "ECB.PC.Monetary.Stab.",
  "ECB.PC.Monetary.Dov.",
"ECB.PC.Monetary.Index"
),

"ECB Economic Outlook" = c(
  "ECB.PC.Outlook.Up",
  #  "ECB.PC.Monetary.Stab.",
  "ECB.PC.Outlook.Down",
  "ECB.PC.Outlook.Index"
)

)

shift <- function(x, n) {
  if (n > 0) {
    c(rep(NA, n), x[1:(length(x) - n)])
  } else if (n < 0) {
    c(x[(1 - n):length(x)], rep(NA, -n))
  } else {
    x
  }
}


shifts <- c(0, 1, -1)
shift_labels <- c("Contemporaneous", "Lag 1", "Lead 1")

all_correlation_results <- list()

for (i in seq_along(shifts)) {
  
  shift_val <- shifts[i]
  shift_label <- shift_labels[i]
  
  correlation_results <- data.frame(
    Group = character(),
    Variable = character(),
    Correlation = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (grp in names(groups)) {
    vars <- groups[[grp]]
    for (var in vars) {
      # pick reference variable for correlation (unchanged)
      if (grp == "Inflation News" || grp == "ECB Inflation Outlook") {
        ref_var <- if (use_first_differences) "German.Inflation.Year.on.Year.difference" else "German.Inflation.Year.on.Year"
      } else if (grp == "Monetary Policy News - Quotes" || grp == "Monetary Policy News - Non-Quotes" || grp == "ECB Monetary Stance") {
        ref_var <- if (use_first_differences) "ECB.MRO.difference" else "ECB.MRO"
      } else if (grp == "ECB Economic Outlook") {
        ref_var <- if (use_first_differences) "German.Industrial.Production.Gap.difference" else "German.Industrial.Production.Gap"
      } else {
        ref_var <- NA
      }
      
      # correlation (unchanged)
      if (!is.na(ref_var) && var %in% names(data) && ref_var %in% names(data)) {
        corr_value <- cor(shift(data[[ref_var]], shift_val), data[[var]], use = "complete.obs")
      } else {
        corr_value <- NA
      }
      
      # --- NEW: use your existing name_mapping for the News/ECB variable
      mapped <- if (var %in% names(name_mapping)) name_mapping[[var]] else var
      
      # --- NEW: reference label (same wording you’re using in your outputs)
      ref_label <- switch(
        grp,
        "Inflation News"               = if (use_first_differences) "$\\Delta$ HICP Inflation" else "HICP Inflation",
        "ECB Inflation Outlook"        = if (use_first_differences) "$\\Delta$ HICP Inflation" else "HICP Inflation",
        "Monetary Policy News - Quotes"= if (use_first_differences) "$\\Delta$ MRO Rate" else "MRO Rate",
        "Monetary Policy News - Non-Quotes" = if (use_first_differences) "$\\Delta$ MRO Rate" else "MRO Rate",
        "ECB Monetary Stance"          = if (use_first_differences) "$\\Delta$ MRO Rate" else "MRO Rate",
        "ECB Economic Outlook"         = if (use_first_differences) "$\\Delta$ Output Gap" else "Output Gap",
        grp
      )
      
      left_cell <- paste0(ref_label, " \\& ", mapped)  # keep escape=FALSE in kable()
      
      correlation_results <- rbind(
        correlation_results,
        data.frame(
          Group = grp,
          Variable = left_cell,                  # <- uses your mapping
          Correlation = round(corr_value, 3),
          stringsAsFactors = FALSE
        )
      )
    }
  }
  
  all_correlation_results[[shift_label]] <- correlation_results
}

for (shift_label in names(all_correlation_results)) {
  
  correlation_results <- all_correlation_results[[shift_label]]
  
  correlation_results$Correlation <- ifelse(is.na(correlation_results$Correlation), "", correlation_results$Correlation)
  
  current_row <- 1
  
latex_table_final <- correlation_results %>%
  select(Variable, Correlation) %>%
  kable(format = "latex", booktabs = TRUE,
        caption = paste("Correlation between Inflation/Monetary Policy Variables and News Indicators -", shift_label),
        align = 'l r',                    # <— was 'lc'
        escape = FALSE, row.names = FALSE) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10)
  
  unique_groups <- unique(correlation_results$Group)
  
  for (grp in unique_groups) {
    n_rows <- nrow(correlation_results %>% filter(Group == grp))
    
    latex_table_final <- latex_table_final %>%
      group_rows(grp, current_row, current_row + n_rows - 1, italic = FALSE, bold = TRUE,
                 latex_gap_space = "", extra_latex_after = "\\\\\n\\midrule")
    
    current_row <- current_row + n_rows
  }
  
  latex_table_final <- as.character(latex_table_final)
  latex_table_final <- gsub("NA", "", latex_table_final)
  latex_table_final <- gsub("\\\\hspace\\{1em\\}", "", latex_table_final)
  latex_table_final <- gsub("\\\\addlinespace", "\\\\midrule", latex_table_final)
  latex_table_final <- gsub("\\\\midrule\\[\\]", "\\\\midrule", latex_table_final)
  
  cat(latex_table_final, "\n\n")
}

################################################################################

plot(data$time, data$Reuter.Poll.Forecast,
     type = "l", 
     xlab = "Date", 
     ylab = "Values",
     col = "blue", 
     main = "Time Series of News Monetary Quote Hawkish and ECB Monetary Index")

lines(data$time, data$German.Inflation.Year.on.Year, col = "red") 

legend("topright", legend = c("News Monetary Quote Hawkish", "ECB Monetary Index"),
       col = c("blue", "red"), lty = 1)

################################################################################

plot(data$time, data$Reuter.Poll.Forecast,
     type = "l", 
     xlab = "Date", 
     ylab = "Values",
     col = "blue", 
     main = "Time Series of News Monetary Quote Hawkish and ECB Monetary Index")

lines(data$time, data$News.Inflation.Direction.Index, col = "red") 

legend("topright", legend = c("News Monetary Quote Hawkish", "ECB Monetary Index"),
       col = c("blue", "red"), lty = 1)

###

plot(data$time, data$Reuter.Poll.Forecast,
     type = "l", 
     xlab = "Date", 
     ylab = "Values",
     col = "blue", 
     main = "Time Series of News Monetary Quote Hawkish and ECB Monetary Index")

lines(data$time, data$News.Inflation.Inc., col = "red") #

legend("topright", legend = c("News Monetary Quote Hawkish", "ECB Monetary Index"),
       col = c("blue", "red"), lty = 1)

###

plot(data$time, data$Reuter.Poll.Forecast,
     type = "l", 
     xlab = "Date", 
     ylab = "Values",
     col = "blue", 
     main = "Time Series of News Monetary Quote Hawkish and ECB Monetary Index")

lines(data$time, data$News.Inflation.Dec., col = "red") 

legend("topright", legend = c("News Monetary Quote Hawkish", "ECB Monetary Index"),
       col = c("blue", "red"), lty = 1)


################################################################################

plot(data$time, data$Reuter.Poll.Forecast,
     type = "l", 
     xlab = "Date", 
     ylab = "Values",
     col = "blue", 
     main = "Time Series of News Monetary Quote Hawkish and ECB Monetary Index")

lines(data$time, data$German.Inflation.Balanced, col = "red") 

legend("topright", legend = c("News Monetary Quote Hawkish", "ECB Monetary Index"),
       col = c("blue", "red"), lty = 1)

################################################################################
################################################################################
################################################################################

ccf_results <- data.frame(
  Group = character(),
  Variable = character(),
  Max_CCF = numeric(),
  Lag_at_Max = numeric(),
  stringsAsFactors = FALSE
)

max_lag <- 3  

for (grp in names(groups)) {
  vars <- groups[[grp]]
  for (var in vars) {
    if (grp == "Inflation News" || grp == "ECB Inflation Outlook") {
      ref_var <- if (use_first_differences) "German.Inflation.Year.on.Year.difference" else "German.Inflation.Year.on.Year"
    } else if (grp == "Monetary Policy News - Quotes" || grp == "Monetary Policy News - Non-Quotes" || grp == "ECB Monetary Stance") {
      ref_var <- if (use_first_differences) "ECB.MRO.difference" else "ECB.MRO"
    } else if (grp == "ECB Economic Outlook") {
      ref_var <- if (use_first_differences) "German.Industrial.Production.Gap.difference" else "German.Industrial.Production.Gap"
    } else {
      ref_var <- NA
    }
    
    if (!is.na(ref_var) && var %in% names(data) && ref_var %in% names(data)) {
      x <- data[[ref_var]]
      y <- data[[var]]
      
      ccf_obj <- ccf(x, y, lag.max = max_lag, plot = FALSE, na.action = na.omit)
      max_idx <- which.max(abs(ccf_obj$acf))
      
      max_ccf <- round(ccf_obj$acf[max_idx], 3)
      lag_at_max <- ccf_obj$lag[max_idx]
    } else {
      max_ccf <- NA
      lag_at_max <- NA
    }
    
    ccf_results <- rbind(ccf_results, data.frame(
      Group = grp,
      Variable = name_mapping[var],
      Max_CCF = max_ccf,
      Lag_at_Max = lag_at_max,
      stringsAsFactors = FALSE
    ))
  }
}


ccf_results$Max_CCF <- ifelse(is.na(ccf_results$Max_CCF), "", ccf_results$Max_CCF)
ccf_results$Lag_at_Max <- ifelse(is.na(ccf_results$Lag_at_Max), "", ccf_results$Lag_at_Max)

ccf_table <- ccf_results %>%
  select(Variable, Max_CCF, Lag_at_Max) %>%
  kable(format = "latex", booktabs = TRUE,
        caption = "Maximum Cross-Correlations and Corresponding Lags",
        align = 'lcc', escape = FALSE, row.names = FALSE) %>%
  kable_styling(latex_options = c("hold_position"), font_size = 10)


current_row <- 1
for (grp in unique(ccf_results$Group)) {
  n_rows <- nrow(ccf_results %>% filter(Group == grp))
  ccf_table <- ccf_table %>%
    group_rows(grp, current_row, current_row + n_rows - 1, italic = FALSE, bold = TRUE,
               latex_gap_space = "", extra_latex_after = "\\\\\n\\midrule")
  current_row <- current_row + n_rows
}

cat(ccf_table)

ref_var <- data$German.Inflation.Year.on.Year
for (var in groups[["Inflation News"]]) {
  if (var %in% names(data)) {
    ccf(ref_var, data[[var]], lag.max = 12, main = paste("Cross-Correlation: HICP vs", var))
  }
}

################################################################################

use_first_differences      <- FALSE
use_first_differences_MRO  <- FALSE
max_lag                    <- 12
out_dir <- "D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/ccf_plots"

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

safe_name <- function(x) gsub("[^A-Za-z0-9._-]", "_", x)

pretty_var <- function(v) if (!is.null(name_mapping[[v]])) name_mapping[[v]] else v

for (grp in names(groups)) {
  vars <- groups[[grp]]
  
  for (var in vars) {
    if (!(var %in% names(data))) next
    
    if (grp %in% c("Inflation News", "ECB Inflation Outlook")) {
      ref_var <- if (use_first_differences) "German.Inflation.Year.on.Year.difference" else "German.Inflation.Year.on.Year"
    } else if (grp %in% c("Monetary Policy News - Quotes", "Monetary Policy News - Non-Quotes", "ECB Monetary Stance")) {
      ref_var <- if (use_first_differences_MRO) "ECB.MRO.difference" else "ECB.MRO"
    } else if (grp == "ECB Economic Outlook") {
      ref_var <- if (use_first_differences) "German.Industrial.Production.Gap.difference" else "German.Industrial.Production.Gap"
    } else {
      ref_var <- NA
    }
    
    if (is.na(ref_var) || !(ref_var %in% names(data))) next

    fn <- file.path(out_dir, paste0("ccf_", safe_name(ref_var), "_vs_", safe_name(var), ".png"))

    png(fn, width = 1200, height = 800, res = 150)
    ccf(
      x = data[[ref_var]],
      y = data[[var]],
      lag.max = max_lag,
      plot = TRUE,
      na.action = na.omit,
      main = "",
      ylab = "CCF"
    )
    dev.off()
    
    cat("Saved:", fn, "\n")
  }
}