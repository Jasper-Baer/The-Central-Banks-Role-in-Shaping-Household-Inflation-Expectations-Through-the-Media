library("readxl")
library("ggplot2")
library("zoo")
library("dplyr")

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

label_color = "black"
up_color = "gray18"
down_color = "gray47"
line_color = "red"

################################################################################
### Figure 2
################################################################################

# EU Enlargement
specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- 0.0135*100
label_eu <- "EU Enlargement"
label_color_eu <- label_color
closest_date_eu <- data$time[which.min(abs(data$time - specific_time_eu))]
arrow_y_start_eu <- data[data$time == closest_date_eu, ]$ECB.Non.Quote.Count

# First Non-Standard Measures
specific_time_ns <- as.Date("2007-08-31")
specific_value_ns <- 0.017*100
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
closest_date_ns <- data$time[which.min(abs(data$time - specific_time_ns))]
arrow_y_start_ns <- data[data$time == closest_date_ns, ]$ECB.Non.Quote.Count

# Interest Rate Cuts
specific_time_lb <- as.Date("2008-10-31")
specific_value_lb <- 0.010*100
label_lb <- "Interest Rate Cuts"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]
arrow_y_start_lb <- data[data$time == closest_date_lb, ]$ECB.Non.Quote.Count

# SMP
specific_time_sm <- as.Date("2010-03-31")
specific_value_sm <- 0.012*100
label_sm <- "SMP"
label_color_sm <- label_color
closest_date_sm <- data$time[which.min(abs(data$time - specific_time_sm))]
arrow_y_start_sm <- data[data$time == closest_date_sm, ]$ECB.Non.Quote.Count

# LTROs
specific_time_lt <- as.Date("2011-12-31")
specific_value_lt <- 0.0145*100
label_lt <- "LTROs"
label_color_lt <- label_color
closest_date_lt <- data$time[which.min(abs(data$time - specific_time_lt))]
arrow_y_start_lt <- data[data$time == closest_date_lt, ]$ECB.Non.Quote.Count

# Whatever it Takes
specific_time_wt <- as.Date("2012-07-31")
specific_value_wt <- 0.019*100
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
closest_date_wt <- data$time[which.min(abs(data$time - specific_time_wt))]
arrow_y_start_wt <- data[data$time == closest_date_wt, ]$ECB.Non.Quote.Count

# Negative Interest Rates
specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.0185*100
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
closest_date_nr <- data$time[which.min(abs(data$time - specific_time_nr))]
arrow_y_start_nr <- data[data$time == closest_date_nr, ]$ECB.Non.Quote.Count

# QE
specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- 0.0185*100
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]
arrow_y_start_qe <- data[data$time == closest_date_qe, ]$ECB.Non.Quote.Count

# Tapering of QE
specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.0135*100
label_ta <- "Tapering of QE"
label_color_ta <- label_color
closest_date_ta <- data$time[which.min(abs(data$time - specific_time_ta))]
arrow_y_start_ta <- data[data$time == closest_date_ta, ]$ECB.Non.Quote.Count

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 1
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]
arrow_y_start_covid <- data[data$time == closest_date_covid, ]$ECB.Non.Quote.Count

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 1.725
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]
arrow_y_start_ru_uk <- data[data$time == closest_date_ru_uk, ]$ECB.Non.Quote.Count

###

sec_scale_mro <- 0.38
sec_scale_ratio <- 1
text_offset <- 0.16

p <- ggplot(data, aes(x = time)) + 
  
  geom_line(aes(y = ECB.Quote.Count * sec_scale_ratio , color = "News ECB Quote Count"), linewidth = 1.6, linetype = "longdash") +
  geom_line(aes(y = ECB.Non.Quote.Count * sec_scale_ratio, color = "News ECB Non Quote Count"), linewidth = 1.6, linetype = "longdash") +
  geom_line(aes(y = ECB.MRO * sec_scale_mro, color = "MRO"), linewidth = 1.6, linetype = "solid") +
  
  scale_color_manual(values = c(
    "News ECB Quote Count" = "blue", 
    "News ECB Non Quote Count" = "green", 
    "MRO" = line_color)) +
  
  scale_y_continuous(name = "% of News Coverage", limits = c(0, 2.15), expand = c(0, 0),
                     sec.axis = sec_axis(~./sec_scale_mro, name = "MRO Rate")) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("blue", "green","red"), 
                                                  shape = c(NA, NA,NA),
                                                  linetype = c("dashed", "dashed", "longdash")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 24),
        axis.text.y.right = element_text(color = "black", size = 24),
        axis.title.y = element_text(color = "black", size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none",
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1.5),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
 # annotate("text", x = as.Date("2004-06-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2007-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2005-12-31"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2009-12-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-03-30"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-01-30"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
 # annotate("text", x = as.Date("2014-09-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 7) +
  annotate("text", x = as.Date("2016-03-31"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2017-10-31"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
 
  annotate("text", x = as.Date("2019-07-31"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-06-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
 # annotate("segment", x = as.Date("2004-02-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
#           colour = label_color_eu, size = 0.75) +
  # annotate("segment", x = as.Date("2007-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #           colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2005-12-31"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  annotate("segment", x = as.Date("2009-12-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75) +
  annotate("segment", x = as.Date("2011-03-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2010-01-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
#  annotate("segment", x = as.Date("2014-09-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.75) + 
  annotate("segment", x = as.Date("2016-03-31"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2017-10-31"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) + 
  annotate("segment", x = as.Date("2019-07-31"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2020-06-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_Quota_Count.png", p, width = 16, height = 6)

################################################################################
### Figure 3(a)
################################################################################

offset <- -0.00
text_offset <- 0.08

scaling_factor <- max(data$News.Inflation.Inc.*200) / max(data$German.Inflation.Year.on.Year)
scaling_factor = 0.085

# Teuro
specific_time_te <- as.Date("2002-02-28")
specific_value_te <- 0.35
label_te <- "Teuro"
label_color_te <- label_color 
closest_date_te <- data$time[which.min(abs(data$time - specific_time_te))]

# VAT Increase
specific_time_va <- as.Date("2005-11-30")
specific_value_va <- 0.7
label_va <- "VAT Increase"
label_color_va <- label_color 
closest_date_va <- data$time[which.min(abs(data$time - specific_time_va))]

# Financial Crisis
specific_time_fc <- as.Date("2007-07-31")
specific_value_fc <- 0.85
label_fc <- "Financial Crisis"
label_color_fc <- label_color 
closest_date_fc <- data$time[which.min(abs(data$time - specific_time_fc))]

# Fall of Lehman Brothers
specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.9
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color 
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]

# First Greek Bailout
specific_time_dc <- as.Date("2010-03-31")
specific_value_dc <- -0.33
label_dc <- "First Greek Bailout"
label_color_dc <- label_color 
closest_date_dc <- data$time[which.min(abs(data$time - specific_time_dc))]

# QE
specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- -0.29
label_qe <- "QE"
label_color_qe <- label_color 
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]

# Brexit
specific_time_br <- as.Date("2016-06-30")
specific_value_br <- -0.3
label_br <- "Brexit"
label_color_br <- label_color 
closest_date_br <- data$time[which.min(abs(data$time - specific_time_br))]

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 0.55
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color 
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.85
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color 
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

max_inflation <- max((data$German.Inflation.Year.on.Year + offset) * scaling_factor)
min_inflation <- min((data$German.Inflation.Year.on.Year + offset) * scaling_factor)

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -1, to = 1, by = 0.25)

data_first_part <- data[1:25, ]
data_second_part <- data[26:102, ]
data_third_part <- data[103:nrow(data), ]

get_bar_y <- function(date, above_zero = TRUE) {
  row <- data[data$time == date, ]
  if (nrow(row) == 0) return(NA_real_)
  if (above_zero) row$News.Inflation.Inc. else -row$News.Inflation.Dec.
}

arrow_end_va    <- get_bar_y(closest_date_va,    TRUE)
arrow_end_lb    <- get_bar_y(closest_date_lb,    TRUE)
arrow_end_dc    <- get_bar_y(closest_date_dc,    FALSE)
arrow_end_qe    <- get_bar_y(closest_date_qe,    FALSE)
arrow_end_br    <- get_bar_y(closest_date_br,    FALSE)
arrow_end_covid <- get_bar_y(closest_date_covid, TRUE)
arrow_end_ru_uk <- get_bar_y(closest_date_ru_uk, TRUE)

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Inflation.Inc.), 
           fill = up_color, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Inflation.Dec.), 
           fill = down_color, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Inflation.Inc.), 
           fill = up_color, width = 50) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Inflation.Dec.), 
           fill = down_color, width = 50) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Inflation.Inc.), 
           fill = up_color, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Inflation.Dec.), 
           fill = down_color, width = 50) +
  
  geom_line(data = data, 
            aes(x = time,y = (German.Inflation.Year.on.Year + offset) * scaling_factor), 
            color = line_color, size = 1.6) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.5, 1),
    sec.axis = sec_axis(~inverse_transform(.), name="Inflation", breaks = breaks_inflation)
  ) +
  
  scale_x_date(expand = c(0.01, 0.01), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") +
  
  # Labels
  annotate("text", x = as.Date("2006-03-30"), y = (specific_value_va + text_offset), 
           label = label_va, color = label_color_va, size = 10) +
  annotate("text", x = as.Date("2011-06-28"), y = (specific_value_lb + text_offset), 
           label = label_lb, color = label_color_lb, size = 10) +
  annotate("text", x = as.Date("2010-06-28"), y = (specific_value_dc - 0.15), 
           label = label_dc, color = label_color_dc, size = 10) +
  annotate("text", x = as.Date("2014-06-28"), y = (specific_value_qe - 0.15), 
           label = label_qe, color = label_color_qe, size = 10) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_br - 0.15), 
           label = label_br, color = label_color_br, size = 10) +
  annotate("text", x = as.Date("2018-01-01"), y = (specific_value_covid + text_offset), 
           label = label_covid, color = label_color_covid, size = 10) +
  annotate("text", x = as.Date("2018-04-28"), y = (specific_value_ru_uk + text_offset), 
           label = label_ru_uk, color = label_color_ru_uk, size = 10) +
  
  annotate("segment", x = as.Date("2006-03-30"), xend = specific_time_va, 
           y = specific_value_va, yend = arrow_end_va, 
           colour = label_color_va, linewidth = 1.3) +
  annotate("segment", x = as.Date("2011-06-28"), xend = specific_time_lb, 
           y = specific_value_lb, yend = arrow_end_lb, 
           colour = label_color_lb, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2010-06-28"), xend = specific_time_dc, 
           y = specific_value_dc - 0.1, yend = arrow_end_dc, 
           colour = label_color_dc, linewidth = 1.3) +
  annotate("segment", x = as.Date("2014-06-28"), xend = specific_time_qe, 
           y = specific_value_qe - 0.1, yend = arrow_end_qe, 
           colour = label_color_qe, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_br, 
           y = specific_value_br - 0.1, yend = arrow_end_br, 
           colour = label_color_br, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2018-01-01"), xend = specific_time_covid, 
           y = specific_value_covid, yend = arrow_end_covid, 
           colour = label_color_covid, linewidth = 1.3) +
  annotate("segment", x = as.Date("2018-04-28"), xend = specific_time_ru_uk, 
           y = specific_value_ru_uk, yend = arrow_end_ru_uk, 
           colour = label_color_ru_uk, linewidth = 1.3)

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_INF_2.png", 
       p, width = 16, height = 6, dpi = 300)


################################################################################
### Figure 3(b)
################################################################################

scaling_factor <- max(abs(data$News.Inflation.Neg.*300)) / max(data$German.Inflation.Year.on.Year)
scaling_factor = 0.045

offset <- -0.00
text_offset <- 0.05

specific_time_te <- as.Date("2002-02-28")
specific_value_te <- 0.2
label_te <- "Teuro"
label_color_te <- label_color
closest_date_te <- data$time[which.min(abs(data$time - specific_time_te))]

specific_time_va <- as.Date("2005-11-30")
specific_value_va <- 0.35
label_va <- "VAT Increase"
label_color_va <- label_color
closest_date_va <- data$time[which.min(abs(data$time - specific_time_va))]

specific_time_fc <- as.Date("2007-07-31")
specific_value_fc <- 0.45
label_fc <- "Financial Crisis"
label_color_fc <- label_color
closest_date_fc <- data$time[which.min(abs(data$time - specific_time_fc))]

specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.425
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]

specific_time_dc <- as.Date("2010-03-31")
specific_value_dc <- -0.135
label_dc <- "First Greek Bailout"
label_color_dc <- label_color 
closest_date_dc <- data$time[which.min(abs(data$time - specific_time_dc))]

specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- -0.1
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]

specific_time_br <- as.Date("2016-06-30")
specific_value_br <- -0.12
label_br <- "Brexit"
label_color_br <- label_color
closest_date_br <- data$time[which.min(abs(data$time - specific_time_br))]

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 0.26
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.45
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -1, to = 1, by = 0.1)

get_bar_y <- function(date, above_zero = TRUE) {
  row <- data[data$time == date, ]
  if (nrow(row) == 0) return(NA_real_)
  if (above_zero) row$News.Inflation.Neg. else -row$News.Inflation.Pos.
}

arrow_end_va    <- get_bar_y(closest_date_va,    TRUE)
arrow_end_lb    <- get_bar_y(closest_date_lb,    TRUE)
arrow_end_dc    <- get_bar_y(closest_date_dc,    FALSE)
arrow_end_qe    <- get_bar_y(closest_date_qe,    FALSE)
arrow_end_br    <- get_bar_y(closest_date_br,    FALSE)
arrow_end_covid <- get_bar_y(closest_date_covid, TRUE)
arrow_end_ru_uk <- get_bar_y(closest_date_ru_uk, TRUE)

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Inflation.Neg.), fill = up_color, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Inflation.Pos.), fill = down_color, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Inflation.Neg.), fill = up_color, width = 40) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Inflation.Pos.), fill = down_color, width = 40) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Inflation.Neg.), fill = up_color, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Inflation.Pos.), fill = down_color, width = 50) +
  
  geom_line(data = data, aes(x = time,y = (German.Inflation.Year.on.Year + offset) * scaling_factor), 
            color = line_color, size = 1.6) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.2, 0.525),
    sec.axis = sec_axis(~inverse_transform(.), name="Inflation", breaks = breaks_inflation), expand = c(0.075, 0)) +
  
  scale_color_manual(values = c("Inflation" = line_color, "News Inflation Positive" = down_color, "News Inflation Negative" = up_color)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = "none") +
  
  # Labels
  annotate("text", x = as.Date("2006-03-30"), y = (specific_value_va + text_offset), label = label_va, color = label_color_va, size = 10) +
  annotate("text", x = as.Date("2011-06-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, size = 10) +
  annotate("text", x = as.Date("2010-06-28"), y = (specific_value_dc - text_offset), label = label_dc, color = label_color_dc, size = 10) +
  annotate("text", x = as.Date("2014-06-28"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, size = 10) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_br - text_offset), label = label_br, color = label_color_br, size = 10) +
  annotate("text", x = as.Date("2018-06-01"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, size = 10) +
  annotate("text", x = as.Date("2019-04-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, size = 10) +
  
  annotate("segment", x = as.Date("2006-03-30"), xend = specific_time_va, y = specific_value_va, yend = arrow_end_va, 
           colour = label_color_va, linewidth = 1.3) +
  annotate("segment", x = as.Date("2011-06-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_end_lb, 
           colour = label_color_lb, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2010-06-28"), xend = specific_time_dc, y = specific_value_dc - 0.025, yend = arrow_end_dc, 
           colour = label_color_dc, linewidth = 1.3) +
  annotate("segment", x = as.Date("2014-06-28"), xend = specific_time_qe, y = specific_value_qe - 0.025, yend = arrow_end_qe, 
           colour = label_color_qe, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_br, y = specific_value_br - 0.025, yend = arrow_end_br, 
           colour = label_color_br, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2018-06-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_end_covid, 
           colour = label_color_covid, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-04-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_end_ru_uk, 
           colour = label_color_ru_uk, linewidth = 1.3)

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_SENT_2.png", 
       p, width = 16, height = 6, dpi = 300)

################################################################################
### Figure 4(a)
################################################################################

# EU Enlargement
specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- 0.22
label_eu <- "EU Enlargement"
label_color_eu <- label_color
closest_date_eu <- data$time[which.min(abs(data$time - specific_time_eu))]
arrow_y_start_eu <- data[data$time == closest_date_eu, ]$News.Monetary.Non.Quote.Hawkish

# First Non-Standard Measures
specific_time_ns <- as.Date("2007-08-31")
specific_value_ns <- -0.45
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
closest_date_ns <- data$time[which.min(abs(data$time - specific_time_ns))]
arrow_y_start_ns <- -data[data$time == closest_date_ns, ]$News.Monetary.Non.Quote.Dovish

# Interest Rate Cuts (Fall of Lehman Brothers)
specific_time_lb <- as.Date("2008-10-31")
specific_value_lb <- -0.3
label_lb <- "Interest Rate Cutes"  # oder "Fall of Lehman Brothers"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]
arrow_y_start_lb <- -data[data$time == closest_date_lb, ]$News.Monetary.Non.Quote.Dovish

# SMP
specific_time_sm <- as.Date("2010-03-31")
specific_value_sm <- -0.25
label_sm <- "SMP"
label_color_sm <- label_color
closest_date_sm <- data$time[which.min(abs(data$time - specific_time_sm))]
arrow_y_start_sm <- -data[data$time == closest_date_sm, ]$News.Monetary.Non.Quote.Dovish

# LTROs
specific_time_lt <- as.Date("2011-12-31")
specific_value_lt <- -0.35
label_lt <- "LTROs"
label_color_lt <- label_color
closest_date_lt <- data$time[which.min(abs(data$time - specific_time_lt))]
arrow_y_start_lt <- -data[data$time == closest_date_lt, ]$News.Monetary.Non.Quote.Dovish

# Whatever it Takes
specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -0.57
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
closest_date_wt <- data$time[which.min(abs(data$time - specific_time_wt))]
arrow_y_start_wt <- -data[data$time == closest_date_wt, ]$News.Monetary.Non.Quote.Dovish

# QE
specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- -0.55
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]
arrow_y_start_qe <- -data[data$time == closest_date_qe, ]$News.Monetary.Non.Quote.Dovish

# Tapering of QE
specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- -0.41
label_ta <- "Tapering of QE"
label_color_ta <- label_color
closest_date_ta <- data$time[which.min(abs(data$time - specific_time_ta))]
arrow_y_start_ta <- -data[data$time == closest_date_ta, ]$News.Monetary.Non.Quote.Dovish

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.50
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]
arrow_y_start_covid <- -data[data$time == closest_date_covid, ]$News.Monetary.Non.Quote.Dovish

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.24
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]
arrow_y_start_ru_uk <- data[data$time == closest_date_ru_uk, ]$News.Monetary.Non.Quote.Hawkish


###

#scaling_factor <- 0.025

#offset <- -2


inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 5, by = 1)
breaks_frequency <- seq(from = -0.6, to = 0.3, by = 0.1)

###

text_offset <- 0.016

scaling_factor <- 0.10

offset <- -2

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Monetary.Non.Quote.Hawkish, color = "News Non Quote Hawkish"), fill = up_color , size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Monetary.Non.Quote.Dovish, color = "News Non Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Monetary.Non.Quote.Hawkish, color = "News Non Quote Hawkish"), fill = up_color , size = 0.1, show.legend = TRUE, width = 40) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Monetary.Non.Quote.Dovish, color = "News Non Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 40) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Monetary.Non.Quote.Hawkish, color = "News Non Quote Hawkish"), fill = up_color , size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Monetary.Non.Quote.Dovish, color = "News Non Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_line(data = data, aes(x = time,y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 1.6, show.legend = TRUE) +
  
  # geom_col(aes(y = News.Monetary.Non.Quote.Hawkish, color = "News Non Quote Hawkish"), fill = "black", size = 0.1, show.legend = FALSE) +
  # geom_col(aes(y = -News.Monetary.Non.Quote.Dovish, color = "News Non Quote Dovish"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  # 
  # geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
  #           linetype = "solid", size = 0.8) +
  # 
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Hawkish"), 
  #            size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Dovish"), 
  #            size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) ifelse(abs(x) < .Machine$double.eps^0.5, "0", as.character(abs(x))),
    breaks = breaks_frequency,
    limits = c(-0.63, 0.33),
    sec.axis = sec_axis(~inverse_transform(.), name="MRO Rate", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c("News Non Quote Hawkish" = up_color , "News Non Quote Dovish" = down_color, "MRO" = line_color)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c(label_color, down_color, up_color ), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, -0.16),
        legend.position = "none",
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) + 
  # Annotations
  annotate("text", x = as.Date("2005-06-28"), y = (specific_value_eu + 0.08), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  #  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  annotate("text", x = as.Date("2007-03-30"), y = (specific_value_ns - text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2006-03-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-06-30"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-01-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2015-05-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 8.5) +
  annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2017-12-30"), y = (specific_value_ta - text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2021-01-30"), y = (specific_value_covid - text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2019-11-01"), y = (specific_value_ru_uk + 0.08), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  annotate("segment", x = as.Date("2005-06-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75, linewidth = 1.3) +
  # annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_ih, y = specific_value_ih, yend = arrow_y_start_ih, 
  #          colour = label_color_ih, size = 0.5) +
  # annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #         colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2007-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2006-03-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2010-06-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2011-01-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
  # annotate("segment", x = as.Date("2015-05-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #          colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-12-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2021-01-30"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-11-01"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_NON_QUOTE_MON_2.png", p, width = 16, height = 6, dpi = 300)

################################################################################
### Figure 4(b)
################################################################################

text_offset <- 0.06

###

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 6, by = 1)
breaks_frequency <- seq(from = -0.6, to = 0.5, by = 0.1)

###
# EU Enlargement
specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- 0.4
label_eu <- "EU Enlargement"
label_color_eu <- label_color
closest_date_eu <- data$time[which.min(abs(data$time - specific_time_eu))]
arrow_y_start_eu <- data[data$time == closest_date_eu, ]$News.Monetary.Non.Quote.Neg.

# First Non-Standard Measures
specific_time_ns <- as.Date("2007-08-31")
specific_value_ns <- -0.12
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
closest_date_ns <- data$time[which.min(abs(data$time - specific_time_ns))]
arrow_y_start_ns <- data[data$time == closest_date_ns, ]$News.Monetary.Non.Quote.Neg.

# Interest Rate Hikes
specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- 0.08
label_ih <- "Interest Rate Hikes"
label_color_ih <- label_color
closest_date_ih <- data$time[which.min(abs(data$time - specific_time_ih))]
arrow_y_start_ih <- data[data$time == closest_date_ih, ]$News.Monetary.Non.Quote.Neg.

# Interest Rate Cutes (Fall of Lehman Brothers)
specific_time_lb <- as.Date("2008-10-31")
specific_value_lb <- 0.18
label_lb <- "Interest Rate Cutes"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]
arrow_y_start_lb <- data[data$time == closest_date_lb, ]$News.Monetary.Non.Quote.Neg.

# SMP
specific_time_sm <- as.Date("2010-03-31")
specific_value_sm <- 0.30
label_sm <- "SMP"
label_color_sm <- label_color
closest_date_sm <- data$time[which.min(abs(data$time - specific_time_sm))]
arrow_y_start_sm <- data[data$time == closest_date_sm, ]$News.Monetary.Non.Quote.Neg.

# LTROs
specific_time_lt <- as.Date("2011-12-31")
specific_value_lt <- 0.35
label_lt <- "LTROs"
label_color_lt <- label_color
closest_date_lt <- data$time[which.min(abs(data$time - specific_time_lt))]
arrow_y_start_lt <- data[data$time == closest_date_lt, ]$News.Monetary.Non.Quote.Neg.

# Whatever it Takes
specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- 0.425
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
closest_date_wt <- data$time[which.min(abs(data$time - specific_time_wt))]
arrow_y_start_wt <- data[data$time == closest_date_wt, ]$News.Monetary.Non.Quote.Neg.

# Negative Interest Rates
specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.55
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
closest_date_nr <- data$time[which.min(abs(data$time - specific_time_nr))]
arrow_y_start_nr <- data[data$time == closest_date_nr, ]$News.Monetary.Non.Quote.Neg.

# QE
specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- 0.44
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]
arrow_y_start_qe <- data[data$time == closest_date_qe, ]$News.Monetary.Non.Quote.Neg.

# Tapering of QE
specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.27
label_ta <- "Tapering of QE"
label_color_ta <- label_color
closest_date_ta <- data$time[which.min(abs(data$time - specific_time_ta))]
arrow_y_start_ta <- data[data$time == closest_date_ta, ]$News.Monetary.Non.Quote.Neg.

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.16
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]
arrow_y_start_covid <- data[data$time == closest_date_covid, ]$News.Monetary.Non.Quote.Neg.

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.35
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]
arrow_y_start_ru_uk <- data[data$time == closest_date_ru_uk, ]$News.Monetary.Non.Quote.Neg.



scaling_factor <- 0.1

offset <- -1.5

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Monetary.Non.Quote.Neg., color = "News Non Quote Negative"), fill = up_color , size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Monetary.Non.Quote.Pos., color = "News Non Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Monetary.Non.Quote.Neg., color = "News Non Quote Negative"), fill = up_color , size = 0.1, show.legend = TRUE, width = 40) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Monetary.Non.Quote.Pos., color = "News Non Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 40) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Monetary.Non.Quote.Neg., color = "News Non Quote Negative"), fill = up_color , size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Monetary.Non.Quote.Pos., color = "News Non Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_line(data = data, aes(x = time,y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 1.6, show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) ifelse(abs(x) < .Machine$double.eps^0.5, "0", as.character(abs(x))),
    breaks = breaks_frequency,
    limits = c(-0.2, 0.5),
    sec.axis = sec_axis(~inverse_transform(.), name="MRO Rate", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c( "MRO" = line_color, "News Non Quote Positive" = down_color, "News Non Quote Negative" = up_color),
                     breaks = c("MRO", "News Non Quote Positive", "News Non Quote Negative")) +
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c(label_color, down_color, up_color), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, 0.6),
        legend.position = 'none',
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2005-03-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 4.2) +
  annotate("text", x = as.Date("2008-03-30"), y = (specific_value_ns - 0.0125), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2008-08-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-10-30"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-10-31"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2014-06-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 8.5) +
  annotate("text", x = as.Date("2016-03-28"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2018-06-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid - 0.0125), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-07-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  
  annotate("segment", x = as.Date("2005-03-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75, linewidth = 1.3) +
  #  annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #          colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2008-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2008-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2010-10-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2011-10-31"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
  # annotate("segment", x = as.Date("2014-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2016-03-28"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2018-06-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-07-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_NON_QUOTE_SENT_2.png", p, width = 16, height = 6, dpi = 300)

################################################################################
### Figure E.1(a)
################################################################################

text_offset <- 0.003

###

# EU Enlargement
specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- +0.07
label_eu <- "EU Enlargement"
label_color_eu <- label_color
closest_date_eu <- data$time[which.min(abs(data$time - specific_time_eu))]
arrow_y_start_eu <- data[data$time == closest_date_eu, ]$News.Monetary.Quote.Hawkish

# Interest Rate Hikes
specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- 0.065
label_ih <- "Interest Rate Hikes"
label_color_ih <- label_color
closest_date_ih <- data$time[which.min(abs(data$time - specific_time_ih))]
arrow_y_start_ih <- data[data$time == closest_date_ih, ]$News.Monetary.Quote.Hawkish

# First Non-Standard Measures
specific_time_ns <- as.Date("2007-08-31")
specific_value_ns <- -0.22
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
closest_date_ns <- data$time[which.min(abs(data$time - specific_time_ns))]
arrow_y_start_ns <- -data[data$time == closest_date_ns, ]$News.Monetary.Quote.Dovish

# Interest Rate Cutes (bzw. Fall of Lehman Brothers)
specific_time_lb <- as.Date("2008-10-31")
specific_value_lb <- -0.075
label_lb <- "Interest Rate Cutes"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]
arrow_y_start_lb <- -data[data$time == closest_date_lb, ]$News.Monetary.Quote.Dovish

# SMP
specific_time_sm <- as.Date("2010-03-31")
specific_value_sm <- -0.07
label_sm <- "SMP"
label_color_sm <- label_color
closest_date_sm <- data$time[which.min(abs(data$time - specific_time_sm))]
arrow_y_start_sm <- -data[data$time == closest_date_sm, ]$News.Monetary.Quote.Dovish

# LTROs
specific_time_lt <- as.Date("2011-12-31")
specific_value_lt <- -0.13
label_lt <- "LTROs"
label_color_lt <- label_color
closest_date_lt <- data$time[which.min(abs(data$time - specific_time_lt))]
arrow_y_start_lt <- -data[data$time == closest_date_lt, ]$News.Monetary.Quote.Dovish

# Whatever it Takes
specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- -0.22
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
closest_date_wt <- data$time[which.min(abs(data$time - specific_time_wt))]
arrow_y_start_wt <- -data[data$time == closest_date_wt, ]$News.Monetary.Quote.Dovish

# QE
specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- -0.125
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]
arrow_y_start_qe <- -data[data$time == closest_date_qe, ]$News.Monetary.Quote.Dovish

# Tapering of QE
specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.035
label_ta <- "Tapering of QE"
label_color_ta <- label_color
closest_date_ta <- data$time[which.min(abs(data$time - specific_time_ta))]
arrow_y_start_ta <- data[data$time == closest_date_ta, ]$News.Monetary.Quote.Hawkish

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.13
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]
arrow_y_start_covid <- -data[data$time == closest_date_covid, ]$News.Monetary.Quote.Dovish

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.068
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]
arrow_y_start_ru_uk <- data[data$time == closest_date_ru_uk, ]$News.Monetary.Quote.Hawkish

###

scaling_factor <- 0.035

offset <- -2


inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -6, to = 6, by = 1)
breaks_frequency <- seq(from = -0.25, to = 0.1, by = 0.05)

###

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Monetary.Quote.Hawkish, color = "News Quote Hawkish"), fill = up_color, size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Monetary.Non.Quote.Dovish, color = "News Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Monetary.Quote.Hawkish, color = "News Quote Hawkish"), fill = up_color, size = 0.1, show.legend = TRUE, width = 40) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Monetary.Quote.Dovish, color = "News Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 40) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Monetary.Quote.Hawkish, color = "News Quote Hawkish"), fill = up_color, size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Monetary.Quote.Dovish, color = "News Quote Dovish"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_line(data = data, aes(x = time,y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 1.6, show.legend = TRUE) +
  
  # geom_col(aes(y = News.Monetary.Quote.Hawkish, color = "News Quote Hawkish"), fill = "black", size = 0.1, show.legend = FALSE) +
  # geom_col(aes(y = -News.Monetary.Quote.Dovish, color = "News Quote Dovish"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  # 
  # geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
  #           linetype = "solid", size = 0.8) +
  # 
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Quote Hawkish"), 
  #            size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Quote Dovish"), 
  #            size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  # 
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.25, 0.1),
    sec.axis = sec_axis(~inverse_transform(.), name="MRO Rate", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c("News Quote Hawkish" = up_color, "News Quote Dovish" = down_color, "MRO" = line_color)) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c(label_color, down_color, up_color), 
                                                  shape = c(NA, 22, 22),
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #  legend.position = c(0.025, -0.16),
        legend.position = 'none',
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu + 0.03), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 10) +
  #annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  # annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  # annotate("text", x = as.Date("2005-06-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  #  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  annotate("text", x = as.Date("2007-03-30"), y = (specific_value_ns - text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2009-03-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-03-30"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2014-12-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2015-05-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 7) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_ta + 0.03), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-09-30"), y = (specific_value_covid - text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-01-01"), y = (specific_value_ru_uk + 0.03), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75, linewidth = 1.3) +
  # annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_ih, y = specific_value_ih, yend = arrow_y_start_ih, 
  #          colour = label_color_ih, size = 0.5) +
  # annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #         colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2007-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2009-03-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2011-03-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2014-12-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
  # annotate("segment", x = as.Date("2015-05-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #          colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2016-05-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-09-30"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-01-01"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_QUOTE_MON_2.png", p, width = 16, height = 6, dpi = 300)

################################################################################
### Figure E.1(b)
################################################################################

text_offset <- 0.02

###

# EU Enlargement
specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- -0.055
label_eu <- "EU Enlargement"
label_color_eu <- label_color
closest_date_eu <- data$time[which.min(abs(data$time - specific_time_eu))]
arrow_y_start_eu <- -data[data$time == closest_date_eu, ]$News.Monetary.Quote.Pos.

# First Non-Standard Measures
specific_time_ns <- as.Date("2007-08-31")
specific_value_ns <- 0.11
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
closest_date_ns <- data$time[which.min(abs(data$time - specific_time_ns))]
arrow_y_start_ns <- data[data$time == closest_date_ns, ]$News.Monetary.Quote.Pos.

# Interest Rate Hikes
specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- -0.065
label_ih <- "Interest Rate Hikes"
label_color_ih <- label_color
closest_date_ih <- data$time[which.min(abs(data$time - specific_time_ih))]
arrow_y_start_ih <- data[data$time == closest_date_ih, ]$News.Monetary.Quote.Neg.

# Interest Rate Cutes (alternativ: Fall of Lehman Brothers)
specific_time_lb <- as.Date("2008-10-31")
specific_value_lb <- 0.065
label_lb <- "Interest Rate Cutes"
label_color_lb <- label_color
closest_date_lb <- data$time[which.min(abs(data$time - specific_time_lb))]
arrow_y_start_lb <- data[data$time == closest_date_lb, ]$News.Monetary.Quote.Neg.

# SMP
specific_time_sm <- as.Date("2010-03-31")
specific_value_sm <- 0.065
label_sm <- "SMP"
label_color_sm <- label_color
closest_date_sm <- data$time[which.min(abs(data$time - specific_time_sm))]
arrow_y_start_sm <- data[data$time == closest_date_sm, ]$News.Monetary.Quote.Neg.

# LTROs
specific_time_lt <- as.Date("2011-12-31")
specific_value_lt <- 0.13
label_lt <- "LTROs"
label_color_lt <- label_color
closest_date_lt <- data$time[which.min(abs(data$time - specific_time_lt))]
arrow_y_start_lt <- data[data$time == closest_date_lt, ]$News.Monetary.Quote.Neg.

# Whatever it Takes
specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- 0.13
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
closest_date_wt <- data$time[which.min(abs(data$time - specific_time_wt))]
arrow_y_start_wt <- data[data$time == closest_date_wt, ]$News.Monetary.Quote.Neg.

# Negative Interest Rates
specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.12
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
closest_date_nr <- data$time[which.min(abs(data$time - specific_time_nr))]
arrow_y_start_nr <- data[data$time == closest_date_nr, ]$News.Monetary.Quote.Neg.

# QE
specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- 0.08
label_qe <- "QE"
label_color_qe <- label_color
closest_date_qe <- data$time[which.min(abs(data$time - specific_time_qe))]
arrow_y_start_qe <- data[data$time == closest_date_qe, ]$News.Monetary.Quote.Neg.

# Tapering of QE
specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.06
label_ta <- "Tapering of QE"
label_color_ta <- label_color
closest_date_ta <- data$time[which.min(abs(data$time - specific_time_ta))]
arrow_y_start_ta <- data[data$time == closest_date_ta, ]$News.Monetary.Quote.Neg.

# COVID-19 Pandemic
specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.055
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
closest_date_covid <- data$time[which.min(abs(data$time - specific_time_covid))]
arrow_y_start_covid <- data[data$time == closest_date_covid, ]$News.Monetary.Quote.Neg.

# Russia-Ukraine War
specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.105
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
closest_date_ru_uk <- data$time[which.min(abs(data$time - specific_time_ru_uk))]
arrow_y_start_ru_uk <- data[data$time == closest_date_ru_uk, ]$News.Monetary.Quote.Neg.

###

scaling_factor <- 0.025

offset <- -2

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 6, by = 1)
breaks_frequency <- seq(from = -0.2, to = 0.15, by = 0.025)

###

p <- ggplot() + 
  
  geom_col(data = data_first_part, aes(x = time,y = News.Monetary.Quote.Neg., color = "News Quote Negative"), fill = up_color, size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_first_part, aes(x = time,y = -News.Monetary.Quote.Pos., color = "News Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_col(data = data_second_part, aes(x = time,y = News.Monetary.Quote.Neg., color = "News Quote Negative"), fill = up_color, size = 0.1, show.legend = TRUE, width = 40) +
  geom_col(data = data_second_part, aes(x = time,y = -News.Monetary.Quote.Pos., color = "News Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 40) +
  
  geom_col(data = data_third_part, aes(x = time,y = News.Monetary.Quote.Neg., color = "News Quote Negative"), fill = up_color, size = 0.1, show.legend = TRUE, width = 50) +
  geom_col(data = data_third_part, aes(x = time,y = -News.Monetary.Quote.Pos., color = "News Quote Positive"), fill = down_color, size = 0.1, show.legend = TRUE, width = 50) +
  
  geom_line(data = data, aes(x = time,y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 1.6, show.legend = TRUE) +
  
  # geom_col(aes(y = News.Monetary.Quote.Neg., color = "News Quote Negative"), fill = "black", size = 0.1, show.legend = FALSE) +
  # geom_col(aes(y = -News.Monetary.Quote.Pos., color = "News Quote Positive"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  # 
  # geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
  #           linetype = "solid", size = 0.8) +
  # 
  # geom_point(aes(x = as.Date("2002-01-01"), y = 0, color = "News Quote Negative"), 
  #            size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  # geom_point(aes(x = as.Date("2002-01-01"), y = 0, color = "News Quote Positive"), 
  #            size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +

scale_y_continuous(
  name = "% of News Coverage",
  labels = function(x) abs(x),
  breaks = breaks_frequency,
  limits = c(-0.075, 0.15),
  sec.axis = sec_axis(~inverse_transform(.), name="MRO Rate", breaks = breaks_mro)
) +
  scale_color_manual(values = c( "MRO" = line_color, "News Quote Positive" = down_color, "News Quote Negative" = up_color),
                     breaks = c("MRO", "News Quote Positive", "News Quote Negative")) +
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c(label_color, down_color, up_color), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, 0.6),
        legend.position = 'none',
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2004-08-28"), y = (specific_value_eu - 0.007), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 4.2) +
  annotate("text", x = as.Date("2006-03-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2008-08-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-06-30"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2014-12-31"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
  # annotate("text", x = as.Date("2014-06-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 8.5) +
  annotate("text", x = as.Date("2016-03-28"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2018-06-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid - 0.007), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-07-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  
  annotate("segment", x = as.Date("2004-08-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75, linewidth = 1.3) +
  #  annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #          colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2006-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2008-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2010-06-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2014-12-31"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
  # annotate("segment", x = as.Date("2014-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2016-03-28"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2018-06-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-07-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_QUOTE_SENT_2.png", p, width = 16, height = 6, dpi = 300)

################################################################################
### Figure 5
################################################################################

data_ECB = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data_ECB = data.frame(data_ECB)
#data_ECB = data_ECB[7:dim(data_ECB)[1],]

data_ECB$time = as.Date(strptime(data_ECB$time, "%Y-%m-%d"))

# data_ECB <- data_ECB %>%
#   arrange(time) %>%
#   mutate(width = as.numeric(difftime(lead(time, default = last(time) + 30), time, units = "days")))

###

data_eu_for = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/EU_staff_forecast.xlsx')
data_eu_for = data.frame(data_eu_for)

data_eu_for$time = as.Date(strptime(data_eu_for$Date, "%Y-%m-%d"))

###

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

################################################################################

text_offset = 6

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -25, to = 30, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- label_color
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Inflation.Dec.

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- label_color
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Inflation.Inc.

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 29
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Inflation.Inc.

specific_time_lb <- as.Date("2008-09-04")
specific_value_lb <- 17
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Inc.

specific_time_lb <- as.Date("2008-10-02")
specific_value_lb <- -21
#label_lb <- "Interest Rate Cuts"
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color
arrow_y_start_lb <- -data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Dec.

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- -16
label_sm <- "SMP"
label_color_sm <- label_color
arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Inflation.Dec.

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -17
label_lt <- "TLTRO"
label_color_lt <- label_color
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Inflation.Dec.

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -22
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Inflation.Dec.

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -20.5
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Inflation.Dec.

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- 13
label_qe <- "QE"
label_color_qe <- label_color
arrow_y_start_qe <- data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Inflation.Inc.

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 20
label_ta <- "Tapering of QE"
label_color_ta <- label_color
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Inflation.Inc.

specific_time_covid <- as.Date("2020-03-12")
specific_value_covid <- -19
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
arrow_y_start_covid <- -data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Inflation.Dec.

specific_time_ru_uk <- as.Date("2022-03-10")
specific_value_ru_uk <- 27.5
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
arrow_y_start_ru_uk <- data_ECB[data_ECB$time == specific_time_ru_uk, ]$ECB.PC.Inflation.Inc.

scaling_factor <- max(abs(data_ECB$ECB.PC.Inflation.Inc.), abs(data_ECB$ECB.PC.Inflation.Dec.)) / max(data$German.Inflation.Year.on.Year, na.rm = TRUE)
scaling_factor = 3.25
offset <- -0
inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

data_ECB_clean <- data_ECB %>%
  filter(!is.na(Inflation.Forecast.EU.Staff))

y_max <- max(abs(data_ECB$ECB.PC.Inflation.Inc.), abs(data_ECB$ECB.PC.Inflation.Dec.), na.rm = TRUE)
y_min <- -y_max
forecast_max <- max(data_ECB_clean$y_forecast, na.rm = TRUE)
forecast_min <- min(data_ECB_clean$y_forecast, na.rm = TRUE)
new_y_max <- max(y_max, forecast_max)
new_y_min <- min(y_min, forecast_min)

p <- ggplot() + 
  
  geom_col(data = data_first_part, 
           aes(x = time, y = ECB.PC.Inflation.Inc.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_first_part, 
           aes(x = time, y = -ECB.PC.Inflation.Dec.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = ECB.PC.Inflation.Inc.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 40,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = -ECB.PC.Inflation.Dec.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 40,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = ECB.PC.Inflation.Inc.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = -ECB.PC.Inflation.Dec.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_line(
    data = data_eu_for, 
    aes(x = time, y = (Inflation.Forecast.EU.Staff+ offset) * scaling_factor, color = "Next Year Forecast"), 
    linetype = "dashed", 
    size = 1.6,    
    na.rm = TRUE
  ) +
  
  geom_line(
    data = data, 
    aes(x = time, y = (German.Inflation.Year.on.Year+ offset) * scaling_factor, color = "Inflation"), 
    linetype = "solid", 
    size = 1.6,    
    na.rm = TRUE
  ) +
  
  
  scale_color_manual(
    values = c("Next Year Forecast" = "green", "Inflation" = line_color)  
  ) +
  
  # Define Y-axis with secondary axis
  scale_y_continuous(
    name = "% in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-30,35),
    sec.axis = sec_axis(~inverse_transform(.), 
                        name = "Inflation", 
                        breaks = breaks_inflation)
  ) +
  
  # Define X-axis as Date
  scale_x_date(
    expand = c(0.015, 0), 
    date_labels = "%Y", 
    breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
    name = "", 
    limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))
  ) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = up_color, size = 24),
        axis.text.y.right = element_text(color = up_color, size = 24),
        axis.title.y = element_text(color = up_color, size = 24),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 22),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        # legend.position = c(0.025, 0.5),
        legend.position = "none",
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1.5),
        legend.key.size = unit(0.5, "cm")) +

# Annotations 
#annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
 # annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2007-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2007-11-30"), y = (specific_value_sm - text_offset + 3.5), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-01-31"), y = (specific_value_lt - text_offset + 3.5), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2012-04-30"), y = (specific_value_wt - text_offset + 3.5), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
 # annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset + 1.5), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 7) +
  annotate("text", x = as.Date("2015-01-22"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2005-08-28"), y = (specific_value_lb - text_offset + 3.5), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-03-12"), y = (specific_value_covid - text_offset + 3.5), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2019-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  # Existing segments
 # annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
#           colour = label_color_euro_intro, size = 0.5) +
  annotate("segment", x = as.Date("2007-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
#  annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
 #          colour = label_color_eu_enlargement, size = 0.5) +
  annotate("segment", x = as.Date("2007-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2011-01-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2005-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2012-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
#  annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
 #          colour = label_color_nr, size = 0.75) + 
  annotate("segment", x = as.Date("2015-01-22"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2016-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-03-12"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/ECB_INF.png", p, width = 16, height = 6, dpi = 300)

################################################################################

text_offset = 6

breaks_mro <- seq(from = -4, to = 6, by = 1)
breaks_frequency <- seq(from = -35, to = 35, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- label_color
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Monetary.Dov.

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- label_color
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Monetary.Haw.

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 25
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Monetary.Haw.

specific_time_lb <- as.Date("2008-10-02")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 19
#label_lb <- "Interest Rate Cuts"
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Monetary.Haw.

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- -19
label_sm <- "SMP"
label_color_sm <- label_color
arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Monetary.Dov.

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -22.5
label_lt <- "TLTRO"
label_color_lt <- label_color
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Monetary.Dov.

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -30
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Monetary.Dov.

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -27
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Monetary.Dov.

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- -24
label_qe <- "QE"
label_color_qe <- label_color
arrow_y_start_qe <- -data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Monetary.Dov.

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 8.5
label_ta <- "Tapering of QE"
label_color_ta <- label_color
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Monetary.Haw.

specific_time_covid <- as.Date("2020-01-23")
specific_value_covid <- -33
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
arrow_y_start_covid <- -data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Monetary.Dov.

specific_time_ru_uk <- as.Date("2022-03-10")
specific_value_ru_uk <- 16
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
arrow_y_start_ru_uk <- data_ECB[data_ECB$time == specific_time_ru_uk, ]$ECB.PC.Monetary.Haw.

scaling_factor <- max(abs(data_ECB$ECB.PC.Monetary.Haw.), abs(data_ECB$ECB.PC.Monetary.Dov.)) / max(data$ECB.MRO, na.rm = TRUE)
scaling_factor = 6
offset <- -2
inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

p <- ggplot() + 

  geom_col(data = data_first_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_first_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 40,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 40,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_line(aes(x = time, y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 1.6, data = data) +
  
  scale_color_manual(values = c("MRO" = line_color)) +
  
  scale_y_continuous(
    name = "% in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-max(abs(data_ECB$ECB.PC.Monetary.Dov.)+5), max(abs(data_ECB$ECB.PC.Monetary.Haw.))+ 13),
    sec.axis = sec_axis(~inverse_transform(.), 
                        name = "MRO Rate", 
                        breaks = breaks_mro)
  ) +
  
  scale_x_date(
    expand = c(0.015, 0), 
    date_labels = "%Y", 
    breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
    name = "", 
    limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))
  ) +
  
  theme_classic() + 
  theme(
    axis.text.y.left = element_text(color = up_color, size = 24),
    axis.text.y.right = element_text(color = up_color, size = 24),
    axis.title.y = element_text(color = up_color, size = 24),
    axis.text.x = element_text(angle = 45, vjust = 0.5, size = 22),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",  
    legend.text = element_text(size = 22), 
    legend.justification = c(0, -1),
    legend.key.size = unit(0.5, "cm")) +
  
  # Annotations 
 # annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
#  annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2005-11-30"), y = (specific_value_sm - text_offset + 3.5), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_lt - text_offset + 3.5), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-04-30"), y = (specific_value_wt - text_offset + 3.5), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
 # annotate("text", x = as.Date("2012-06-30"), y = (specific_value_nr - text_offset + 2), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 7) +
  annotate("text", x = as.Date("2014-09-30"), y = (specific_value_qe - text_offset + 3.5), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-08-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2018-01-01"), y = (specific_value_covid - text_offset + 3.5), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2020-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  # Existing segments
 # annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
  #         colour = label_color_euro_intro, size = 0.5) +
  annotate("segment", x = as.Date("2006-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
  #annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
  #         colour = label_color_eu_enlargement, size = 0.5) +
  annotate("segment", x = as.Date("2005-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2011-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2011-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
#  annotate("segment", x = as.Date("2012-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2014-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2018-01-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2020-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/ECB_MRO.png", p, width = 16, height = 6, dpi = 300)

################################################################################

text_offset = 6

breaks_gdp <- seq(from = -4, to = 6, by = 1)
breaks_frequency <- seq(from = -35, to = 45, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

line_color = "green"

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- label_color
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Outlook.Up

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- label_color
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Outlook.Up

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 39
label_ns <- "First Non-Standard Measures"
label_color_ns <- label_color
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Outlook.Up

specific_time_lb <- as.Date("2008-09-04")
specific_value_lb <- 31
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- label_color
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Outlook.Up

# specific_time_lb <- as.Date("2008-10-02")
# #specific_time_lb <- as.Date("2008-09-30")
# specific_value_lb <- -9
# label_lb <- "Interest Rate Cuts"
# #label_lb <- "Fall of Lehman Brothers"
# label_color_lb <- "red"
# arrow_y_start_lb <- -data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Outlook.Up

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- 22.5
label_sm <- "SMP"
label_color_sm <- label_color
arrow_y_start_sm <- data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Outlook.Up

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -17
label_lt <- "TLTRO"
label_color_lt <- label_color
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Outlook.Down

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -25
label_wt <- "Whatever it Takes"
label_color_wt <- label_color
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Outlook.Down

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -20
label_nr <- "Negative Interest Rates"
label_color_nr <- label_color
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Outlook.Up

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- -15
label_qe <- "QE"
label_color_qe <- label_color
arrow_y_start_qe <- -data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Outlook.Down

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 26
label_ta <- "Tapering of QE"
label_color_ta <- label_color
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Outlook.Up

specific_time_covid <- as.Date("2020-03-12")
specific_value_covid <- -20
label_covid <- "COVID-19 Pandemic"
label_color_covid <- label_color
arrow_y_start_covid <- -data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Outlook.Down

specific_time_ru_uk <- as.Date("2022-03-10")
specific_value_ru_uk <- 37
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- label_color
arrow_y_start_ru_uk <- data_ECB[data_ECB$time == specific_time_ru_uk, ]$ECB.PC.Outlook.Up

scaling_factor <- max(abs(data_ECB$ECB.PC.Monetary.Haw.), abs(data_ECB$ECB.PC.Monetary.Dov.)) / max(data$ECB.MRO, na.rm = TRUE)
offset <- -1.5
inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

data_ECB_clean <- data_ECB %>%
  filter(!is.na(GDP.Forecast.EU.Staff)) %>%
  mutate(y_forecast = (GDP.Forecast.EU.Staff + offset) * scaling_factor)

y_max <- max(abs(data_ECB$ECB.PC.Inflation.Inc.), abs(data_ECB$ECB.PC.Inflation.Dec.), na.rm = TRUE)
y_min <- -y_max
forecast_max <- max(data_ECB_clean$y_forecast, na.rm = TRUE)
forecast_min <- min(data_ECB_clean$y_forecast, na.rm = TRUE)
new_y_max <- max(y_max, forecast_max)
new_y_min <- min(y_min, forecast_min)

p <- ggplot() + 

  geom_col(data = data_first_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_first_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 40,    
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 40,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = up_color, 
           color = up_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = down_color, 
           color = down_color, 
           size = 0.1, 
           width = 50,   
           show.legend = FALSE, 
           position = "identity") +
  
  geom_line(
    data = data_ECB_clean, 
    aes(x = time, y = y_forecast, color = "Next Year Forecast"), 
    linetype = "solid", 
    size = 1.6,    
    na.rm = TRUE
  ) +
  
  scale_color_manual(
    values = c("Next Year Forecast" = line_color) 
  ) +
  
  scale_y_continuous(
    name = "% in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-max(abs(data_ECB$ECB.PC.Outlook.Down) + 10), max(abs(data_ECB$ECB.PC.Outlook.Up))+15),
    sec.axis = sec_axis(~inverse_transform(.), 
                        name = "GDP Growth", 
                        breaks = breaks_gdp)
  ) +
  
  scale_x_date(
    expand = c(0.015, 0), 
    date_labels = "%Y", 
    breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
    name = "", 
    limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))
  ) +
  
  theme_classic() + 
  theme(
    axis.text.y.left = element_text(color = up_color, size = 24),
    axis.text.y.right = element_text(color = up_color, size = 24),
    axis.title.y = element_text(color = up_color, size = 24),
    axis.text.x = element_text(angle = 45, vjust = 0.5, size = 22),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",  
    legend.text = element_text(size = 22), 
    legend.justification = c(0, -1),
    legend.key.size = unit(0.5, "cm")) +
  
  # Annotations 
 # annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
#  annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2011-06-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-07-31"), y = (specific_value_lt - text_offset + 3.5), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2013-04-30"), y = (specific_value_wt - text_offset + 3.5), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 10) +
 # annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset + 1.25), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 7) +
  annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset + 3.5), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2010-08-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid - text_offset + 3.5), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 10) +
  annotate("text", x = as.Date("2021-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 10) +
  
  # Existing segments
 # annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
#           colour = label_color_euro_intro, size = 0.75) +
  annotate("segment", x = as.Date("2006-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75, linewidth = 1.3) +
#  annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
 #          colour = label_color_eu_enlargement, size = 0.75) +
  annotate("segment", x = as.Date("2011-06-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2010-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2010-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.75, linewidth = 1.3) + 
  annotate("segment", x = as.Date("2013-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75, linewidth = 1.3) + 
#  annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.75) + 
  annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75, linewidth = 1.3) +
  annotate("segment", x = as.Date("2021-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75, linewidth = 1.3) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/ECB_GDP.png", p, width = 16, height = 6, dpi = 300)