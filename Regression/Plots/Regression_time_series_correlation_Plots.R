################################################################################
# Rolling Correlations (News and ECB Indicators)
#
# This script computes 12-month rolling correlations between key time-series:
#   (i) Inflation-related news indicators vs. German HICP inflation (YoY)
#   (ii) Monetary-policy news indicators (quotes and non-quotes) vs. the ECB MRO rate
#
# For each indicator, the script computes the rolling correlation with the 
# relevant reference series, plots the rolling correlation over time, and saves
# the plot as a PNG for the dissertation figures folder
################################################################################

################################################################################
# Libraries
################################################################################
library("readxl")
library("ggplot2")
library("zoo")

################################################################################
# Load data
################################################################################
data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

################################################################################
# Reference series
################################################################################

# German HICP inflation used as reference for inflation-news correlations
ger_inf = ts(data$German.Inflation.Year.on.Year)

# ECB MRO rate used as reference for monetary-policy-news correlations
MRO = ts(data$ECB.MRO)

################################################################################
# News series: Inflation (direction and sentiment)
################################################################################
news_inc        = ts(data$News.Inflation.Inc.)
news_dec        = ts(data$News.Inflation.Dec.)
news_index      = ts(data$News.Inflation.Direction.Index)

news_pos        = ts(data$News.Inflation.Pos.)
news_neg        = ts(data$News.Inflation.Neg.)
news_index_sent = ts(data$News.Inflation.Sentiment.Index)

################################################################################
# News series: Monetary policy (quotes)
################################################################################
news_quote_haw        = ts(data$News.Monetary.Quote.Hawkish)
news_quote_dov        = ts(data$News.Monetary.Quote.Dovish)
news_quote_index      = ts(data$News.Monetary.Quote.Index)

news_quote_pos        = ts(data$News.Monetary.Quote.Pos.)
news_quote_neg        = ts(data$News.Monetary.Quote.Neg.)
news_quote_index_sent = ts(data$News.Monetary.Quote.Sentiment.Index)

################################################################################
# News series: Monetary policy (non-quotes)
################################################################################
news_non_quote_haw        = ts(data$News.Monetary.Non.Quote.Hawkish)
news_non_quote_dov        = ts(data$News.Monetary.Non.Quote.Dovish)
news_non_quote_index      = ts(data$News.Monetary.Non.Quote.Index)

news_non_quote_pos        = ts(data$News.Monetary.Non.Quote.Pos.)
news_non_quote_neg        = ts(data$News.Monetary.Non.Quote.Neg.)
news_non_quote_index_sent = ts(data$News.Monetary.Non.Quote.Sentiment.Index)

################################################################################
# Rolling window settings
################################################################################

# window_size is the length of the rolling window (in months).
window_size <- 12

################################################################################
# Output directory
################################################################################
out_dir = "D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text"

################################################################################
# Helper: rolling correlation plot + save
################################################################################
make_rollcorr_plot <- function(data, x, y, window_size, out_file) {
  
  # Compute rolling correlation between x and y using a rolling window
  rolling_corr <- rollapplyr(
    cbind(x, y),
    width = window_size,
    FUN = function(z) cor(z[, 1], z[, 2]),
    by.column = FALSE,
    fill = NA
  )
  
  # Store results into data for plotting
  data$rolling_corr <- rolling_corr
  
  # Drop initial NA values created by the rolling window
  data_clean <- data[!is.na(data$rolling_corr), ]
  
  # Plot rolling correlation
  p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) +
    geom_line(color = "black", linewidth = 1) +
    geom_hline(yintercept = 0, linetype = "solid", color = "black") +
    scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
    scale_x_date(
      expand = c(0.015, 0),
      date_labels = "%Y",
      breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"),
      name = "Year",
      limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))
    ) +
    theme_classic() +
    theme(
      axis.text.y = element_text(color = "black", size = 12),
      axis.title.y = element_text(color = "black", size = 14),
      axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
      legend.position = "none"
    )
  
  # Print plot to viewer
  print(p)
  
  # Save to file
  ggsave(out_file, p, width = 14, height = 6)
}

################################################################################
# Inflation news vs. German HICP inflation 
################################################################################

# Increasing inflation news vs HICP inflation
make_rollcorr_plot(data, news_inc, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_inc_tc.png"))

# Decreasing inflation news vs HICP inflation
make_rollcorr_plot(data, news_dec, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_dec_tc.png"))

# Inflation direction index vs HICP inflation
make_rollcorr_plot(data, news_index, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_index_tc.png"))

# Positive inflation news vs HICP inflation
make_rollcorr_plot(data, news_pos, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_pos_tc.png"))

# Negative inflation news vs HICP inflation
make_rollcorr_plot(data, news_neg, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_neg_tc.png"))

# Inflation sentiment index vs HICP inflation
make_rollcorr_plot(data, news_index_sent, ger_inf, window_size, paste0(out_dir, "/NEWS_inf_sent_index_tc.png"))

################################################################################
# Monetary-policy news (quotes) vs. ECB MRO rate
################################################################################

# Quote: Hawkish vs MRO
make_rollcorr_plot(data, news_quote_haw, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_haw_tc.png"))

# Quote: Dovish vs MRO
make_rollcorr_plot(data, news_quote_dov, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_dov_tc.png"))

# Quote: Stance index vs MRO
make_rollcorr_plot(data, news_quote_index, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_index_tc.png"))

# Quote: Positive sentiment vs MRO
make_rollcorr_plot(data, news_quote_pos, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_pos_tc.png"))

# Quote: Negative sentiment vs MRO
make_rollcorr_plot(data, news_quote_neg, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_neg_tc.png"))

# Quote: Sentiment index vs MRO
make_rollcorr_plot(data, news_quote_index_sent, MRO, window_size, paste0(out_dir, "/NEWS_mon_quote_sent_index_tc.png"))

################################################################################
# Monetary-policy news (non-quotes) vs. ECB MRO rate
################################################################################

# Non-Quote: Hawkish vs MRO
make_rollcorr_plot(data, news_non_quote_haw, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_haw_tc.png"))

# Non-Quote: Dovish vs MRO
make_rollcorr_plot(data, news_non_quote_dov, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_dov_tc.png"))

# Non-Quote: Stance index vs MRO
make_rollcorr_plot(data, news_non_quote_index, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_index_tc.png"))

# Non-Quote: Positive sentiment vs MRO
make_rollcorr_plot(data, news_non_quote_pos, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_pos_tc.png"))

# Non-Quote: Negative sentiment vs MRO
make_rollcorr_plot(data, news_non_quote_neg, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_neg_tc.png"))

# Non-Quote: Sentiment index vs MRO
make_rollcorr_plot(data, news_non_quote_index_sent, MRO, window_size, paste0(out_dir, "/NEWS_mon_non_quote_sent_index_tc.png"))
