library("readxl")
library("ggplot2")
library("zoo")

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')

data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

ger_inf = ts(data$German.Inflation.Year.on.Year)

news_inc = ts(data$News.Inflation.Inc.)
news_stab = ts(data$News.Inflation.Stable)
news_dec = ts(data$News.Inflation.Dec.)
news_index = ts(data$News.Inflation.Direction.Index)

news_pos = ts(data$News.Inflation.Pos.)
news_neu = ts(data$News.Inflation.Neu.)
news_neg = ts(data$News.Inflation.Neg.)
news_index_sent = ts(data$News.Inflation.Sentiment.Index)

window_size <- 12

###

rolling_corr <- rollapplyr(cbind(news_inc, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_inc_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_dec, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_dec_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_index, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_index_tc.png", p, width = 14, height = 6)

################################################################################
################################################################################
################################################################################

rolling_corr <- rollapplyr(cbind(news_pos, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_pos_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_neg, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_neg_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_index_sent, ger_inf), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data_clean, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_inf_sent_index_tc.png", p, width = 14, height = 6)

################################################################################
################################################################################
################################################################################

MRO = ts(data$ECB.MRO)

news_quote_haw = ts(data$News.Monetary.Quote.Hawkish)
news_quote_stab = ts(data$News.Monetary.Quote.Stable)
news_quote_dov = ts(data$News.Monetary.Quote.Dovish)
news_quote_index = ts(data$News.Monetary.Quote.Index)

rolling_corr <- rollapplyr(cbind(news_quote_haw, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1, na.rm = FALSE) +  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_haw_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_quote_dov, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_dov_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_quote_index, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_index_tc.png", p, width = 14, height = 6)

################################################################################

news_quote_pos = data$News.Monetary.Quote.Pos.
news_quote_neu = data$News.Monetary.Quote.Neu.
news_quote_neg = data$News.Monetary.Quote.Neg.
news_quote_index_sent = data$News.Monetary.Quote.Sentiment.Index

rolling_corr <- rollapplyr(cbind(news_quote_pos, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_pos_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_quote_neg, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_neg_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_quote_index_sent, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_quote_sent_index_tc.png", p, width = 14, height = 6)

################################################################################
################################################################################
################################################################################

news_non_quote_haw = data$News.Monetary.Non.Quote.Hawkish
news_non_quote_stab = data$News.Monetary.Non.Quote.Stable
news_non_quote_dov = data$News.Monetary.Non.Quote.Dovish
news_non_quote_index = data$News.Monetary.Non.Quote.Index

rolling_corr <- rollapplyr(cbind(news_non_quote_haw, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_haw_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_non_quote_dov, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_dov_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_non_quote_index, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_index_tc.png", p, width = 14, height = 6)

################################################################################

news_non_quote_pos = data$News.Monetary.Non.Quote.Pos.
news_non_quote_neu = data$News.Monetary.Non.Quote.Neu.
news_non_quote_neg = data$News.Monetary.Non.Quote.Neg.
news_non_quote_index_sent = data$News.Monetary.Non.Quote.Sentiment.Index

rolling_corr <- rollapplyr(cbind(news_non_quote_pos, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_pos_tc.png", p, width = 14, height = 6)

###

rolling_corr <- rollapplyr(cbind(news_non_quote_neg, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data$rolling_corr <- rolling_corr

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_neg_tc.png", p, width = 14, height = 6)

rolling_corr <- rollapplyr(cbind(news_non_quote_index_sent, MRO), width = window_size, 
                           FUN = function(z) cor(z[, 1], z[, 2]), 
                           by.column = FALSE, fill = NA)

data_clean <- data[!is.na(data$rolling_corr), ]

p <- ggplot(data, aes(x = time, y = rolling_corr)) + 
  geom_line(color = "black", linewidth = 1) +  
  
  geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  scale_y_continuous(name = "Rolling Correlation", limits = c(-1, 1), expand = c(0, 0)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
               breaks = seq(as.Date("2003-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "Year", limits = c(as.Date("2003-01-01"), as.Date("2024-06-01"))) +
  
  theme_classic() + 
  theme(axis.text.y = element_text(color = "black", size = 12),
        axis.title.y = element_text(color = "black", size = 14),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_mon_non_quote_sent_index_tc.png", p, width = 14, height = 6)