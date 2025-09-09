library("readxl")
library("ggplot2")
library("zoo")
library("dplyr")

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx')
data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

data = data[1:dim(data)[1],]

################################################################################
### Figure 2
################################################################################

specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- 0.0135*100
label_eu <- "EU Enlargement"
label_color_eu <- "red"
arrow_y_start_eu <- data[data$time == specific_time_eu, ]$ECB.Non.Quote.Count

specific_time_ns <- as.Date("2007-08-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 0.018*100
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data[data$time == specific_time_ns, ]$ECB.Non.Quote.Count

specific_time_lb <- as.Date("2008-10-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.010*100
label_lb <- "Interest Rate Cutes"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data[data$time == specific_time_lb, ]$ECB.Non.Quote.Count

# specific_time_gd <- as.Date("2009-09-30")
# specific_value_gd <- 0.008
# label_gd <- "Greek Debt Crisis"
# label_color_gd <- "red"
# arrow_y_start_gd <- data[data$time == specific_time_gd, ]$ECB.Non.Quote.Count

specific_time_sm <- as.Date("2010-03-31")
specific_value_sm<- 0.013*100
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- data[data$time == specific_time_sm, ]$ECB.Non.Quote.Count

specific_time_lt <- as.Date("2011-12-31")
specific_value_lt<- 0.011*100
label_lt <- "LTROs"
label_color_lt <- "red"
arrow_y_start_lt <- data[data$time == specific_time_lt, ]$ECB.Non.Quote.Count

specific_time_wt <- as.Date("2012-07-31")
specific_value_wt <- 0.016*100
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- data[data$time == specific_time_wt, ]$ECB.Non.Quote.Count

specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.018*100
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- data[data$time == specific_time_nr, ]$ECB.Non.Quote.Count

specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- 0.015*100
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- data[data$time == specific_time_qe, ]$ECB.Non.Quote.Count

specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.010*100
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data[data$time == specific_time_ta, ]$ECB.Non.Quote.Count

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 0.8
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- data[data$time == specific_time_covid, ]$ECB.Non.Quote.Count

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 1.725
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data[data$time == specific_time_ru_uk, ]$ECB.Non.Quote.Count

###

sec_scale_mro <- 0.38
sec_scale_ratio <- 1
text_offset <- 0.125

p <- ggplot(data, aes(x = time)) + 
  
  #geom_line(aes(y = News.Inflation.Count, color = "News Inflation Count"), size = 1) +
  geom_line(aes(y = data$ECB.Quote.Count * sec_scale_ratio , color = "News ECB Quote Count"), linewidth = 1) +
  geom_line(aes(y = data$ECB.Non.Quote.Count * sec_scale_ratio, color = "News ECB Non Quote Count"), linewidth = 1) +
  
  geom_line(aes(y = ECB.MRO * sec_scale_mro, color = "MRO"), linewidth = 1) +
  
  scale_color_manual(values = c(#"News Inflation Count" = "blue",
    "News ECB Quote Count" = "blue", 
    "News ECB Non Quote Count" = "green", 
    "MRO" = "orange")) +
  
  #scale_y_continuous(sec.axis = sec_axis(~./sec_scale_ratio, name = "News ECB Counts")) +
  scale_y_continuous(name = "% of News Coverage", limits = c(0, 2.05), expand = c(0, 0),
                     sec.axis = sec_axis(~./sec_scale_mro, name = "MRO (%)")) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("blue", "green","orange"), 
                                                  shape = c(NA, NA,NA),
                                                  linetype = c("longdash", "longdash", "longdash")))) +
  
  #geom_hline(yintercept = 0, linetype = "solid", color = "black") +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
       # legend.position = c(0.025, 0.5),
        legend.position = "none",
        legend.text = element_text(size = 23), 
        legend.justification = c(0, -1.5),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2004-06-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2007-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2005-12-31"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2009-06-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-07-31"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-07-30"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 9) +
 # annotate("text", x = as.Date("2014-09-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2016-03-31"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2017-10-31"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 9) +
 
  annotate("text", x = as.Date("2019-07-31"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2021-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  annotate("segment", x = as.Date("2004-02-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75) +
  # annotate("segment", x = as.Date("2007-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #           colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2005-12-31"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  annotate("segment", x = as.Date("2009-06-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75) +
  annotate("segment", x = as.Date("2010-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2010-07-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
#  annotate("segment", x = as.Date("2014-09-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.75) + 
  annotate("segment", x = as.Date("2016-03-31"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2017-10-31"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) + 
  annotate("segment", x = as.Date("2019-07-31"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2021-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_Quota_Count.png", p, width = 14, height = 6)

################################################################################
### Figure 3(a)
################################################################################

offset <- -0.00
text_offset <- 0.1

scaling_factor <- max(data$News.Inflation.Inc.*200) / max(data$German.Inflation.Year.on.Year)

scaling_factor = 0.085

###

specific_time_te <- as.Date("2002-02-28")
specific_value_te <- 0.35
label_te <- "Teuro"
label_color_te <- "red"
arrow_y_start_te <- (data[data$time == specific_time_te, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_va <- as.Date("2005-11-30")
specific_value_va <- 0.65
label_va <- "VAT Increase"
label_color_va <- "red"
arrow_y_start_va <- (data[data$time == specific_time_va, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_fc <- as.Date("2007-07-31")
specific_value_fc <- 0.85
label_fc <- "Financial Crisis"
label_color_fc <- "red"
arrow_y_start_fc <- (data[data$time == specific_time_fc, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.9
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- (data[data$time == specific_time_lb, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_dc <- as.Date("2010-03-31")
specific_value_dc <- -0.33
label_dc <- "First Greek Bailout"
label_color_dc <- "red"
arrow_y_start_dc <- (data[data$time == specific_time_dc, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- -0.25
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- (data[data$time == specific_time_qe, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_br <- as.Date("2016-06-30")
specific_value_br <- -0.3
label_br <- "Brexit"
label_color_br <- "red"
arrow_y_start_br <- (data[data$time == specific_time_qe, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

# specific_time_gb <- as.Date("2015-07-31")
# specific_value_gb <- -0.5
# label_gb <- "Greek Bailout Referendum"
# label_color_gb <- "red"
# arrow_y_start_gb <- (data[data$time == specific_time_gb, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 0.425
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- (data[data$time == specific_time_covid, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.60
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- (data[data$time == specific_time_ru_uk, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

###

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

max_inflation <- max((data$German.Inflation.Year.on.Year + offset) * scaling_factor)
min_inflation <- min((data$German.Inflation.Year.on.Year + offset) * scaling_factor)

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -1, to = 1, by = 0.25)

###

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Inflation.Inc., color = "Share of Increasing Inflation Sentences"), fill = "black", size = 0.1, show.legend = TRUE) +
  geom_col(aes(y = -News.Inflation.Dec., color = "Share of Decreasing Inflation Sentences"), fill = "grey40", size = 0.1, show.legend = TRUE) +
  
  geom_line(aes(y = (German.Inflation.Year.on.Year + offset) * scaling_factor, color = "Inflation (% change)"), 
            linetype = "solid", size = 0.8, show.legend = TRUE) +
  
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Inflation Increasing"), 
  #            size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  # geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Inflation Decreasing"), 
  #            size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.5, 1),
    sec.axis = sec_axis(~inverse_transform(.), name="Inflation", breaks = breaks_inflation)
  ) +
  
  scale_color_manual(values = c("Share of Increasing Inflation Sentences" = "black", "Share of Decreasing Inflation Sentences" = "grey40", "Inflation (% change)" = 'darkorange')) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("darkorange", "grey40", 'black'), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
  legend.position = "none",
     #   legend.position = c(0.55, 0.4),
      # legend.position = c(0.95, 0.95),
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
     legend.background = element_blank(),   
     legend.box.background = element_blank() ,
        legend.key.size = unit(0.5, "cm")) + 
  
  #  annotate("text", x = as.Date("2002-10-31"), y = (specific_value_te + text_offset), label = label_te, color = label_color_te, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2005-06-30"), y = (specific_value_va + text_offset), label = label_va, color = label_color_va, angle = 0, vjust = 1, size = 9) +
 # annotate("text", x = as.Date("2005-08-28"), y = (specific_value_fc + text_offset), label = label_fc, color = label_color_fc, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2011-06-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-06-28"), y = (specific_value_dc - text_offset), label = label_dc, color = label_color_dc, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2014-02-28"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_br - text_offset), label = label_br, color = label_color_br, angle = 0, vjust = 1, size = 9) +
  #annotate("text", x = as.Date("2016-07-31"), y = (specific_value_gb - text_offset), label = label_gb, color = label_color_gb, angle = 0, vjust = 1, size = 4.2) +
  annotate("text", x = as.Date("2017-01-01"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2017-08-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  # annotate("segment", x = as.Date("2002-10-31"), xend = specific_time_te, y = specific_value_te, yend = arrow_y_start_te, 
  #           colour = label_color_te, size = 0.5) +
  annotate("segment", x = as.Date("2005-06-30"), xend = specific_time_va, y = specific_value_va, yend = arrow_y_start_va, 
           colour = label_color_va, size = 0.75) +
#  annotate("segment", x = as.Date("2005-08-28"), xend = specific_time_fc, y = specific_value_fc, yend = arrow_y_start_fc, 
#           colour = label_color_fc, size = 0.5) +
  annotate("segment", x = as.Date("2011-06-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.75) + 
  annotate("segment", x = as.Date("2010-06-28"), xend = specific_time_dc, y = specific_value_dc - 0.1, yend = arrow_y_start_dc, 
           colour = label_color_dc, size = 0.75) +
  annotate("segment", x = as.Date("2014-02-28"), xend = specific_time_qe, y = specific_value_qe - 0.1, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_br, y = specific_value_br - 0.1, yend = arrow_y_start_br, 
           colour = label_color_br, size = 0.75) + 
  annotate("segment", x = as.Date("2017-01-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2017-08-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 
  
#annotate("segment", x = as.Date("2016-07-31"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
#         colour = label_color_qe, size = 0.75) 


print(p) 

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_INF_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure 3(b)
################################################################################

scaling_factor <- max(abs(data$News.Inflation.Neg.*300)) / max(data$German.Inflation.Year.on.Year)

scaling_factor = 0.045

offset <- -0.00
text_offset <- 0.05

###

specific_time_te <- as.Date("2002-02-28")
specific_value_te <- 0.2
label_te <- "Teuro"
label_color_te <- "red"
arrow_y_start_te <- (data[data$time == specific_time_te, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_va <- as.Date("2005-11-30")
specific_value_va <- 0.3
label_va <- "VAT Increase"
label_color_va <- "red"
arrow_y_start_va <- (data[data$time == specific_time_va, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_fc <- as.Date("2007-07-31")
specific_value_fc <- 0.45
label_fc <- "Financial Crisis"
label_color_fc <- "red"
arrow_y_start_fc <- (data[data$time == specific_time_fc, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.4
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- (data[data$time == specific_time_lb, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_dc <- as.Date("2011-03-31")
specific_value_dc <- -0.135
label_dc <- "First Greek Bailout"
label_color_dc <- "red"
arrow_y_start_dc <- (data[data$time == specific_time_dc, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_qe <- as.Date("2015-02-28")
specific_value_qe <- -0.075
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- (data[data$time == specific_time_qe, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_br <- as.Date("2016-06-30")
specific_value_br <- -0.09
label_br <- "Brexit"
label_color_br <- "red"
arrow_y_start_br <- (data[data$time == specific_time_qe, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- 0.3
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- (data[data$time == specific_time_covid, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.45
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- (data[data$time == specific_time_ru_uk, ]$German.Inflation.Year.on.Year + offset)*scaling_factor

###

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -1, to = 1, by = 0.1)

###

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Inflation.Neg., color = "News Inflation Negative"), fill = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(y = -News.Inflation.Pos., color = "News Inflation Positive"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  
  geom_line(aes(y = (German.Inflation.Year.on.Year + offset) * scaling_factor, color = "Inflation"), 
            linetype = "solid", size = 0.8) +
  
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Inflation Negative"), 
             size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Inflation Positive"), 
             size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.2, 0.525),
    sec.axis = sec_axis(~inverse_transform(.), name="Inflation", breaks = breaks_inflation), expand = c(0.075, 0)) +
  
  scale_color_manual(values = c( "Inflation" = 'darkorange', "News Inflation Positive" = "grey40", "News Inflation Negative" = "black"),
                     breaks = c("Inflation", "News Inflation Positive", "News Inflation Negative")) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("red", "grey40", 'black'), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #legend.position = c(0.025, -0.22),
        legend.position = "none",
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  #  annotate("text", x = as.Date("2002-10-31"), y = (specific_value_te + text_offset), label = label_te, color = label_color_te, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2005-06-30"), y = (specific_value_va + text_offset), label = label_va, color = label_color_va, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-08-28"), y = (specific_value_fc + text_offset), label = label_fc, color = label_color_fc, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2011-06-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-06-28"), y = (specific_value_dc - text_offset), label = label_dc, color = label_color_dc, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2014-02-28"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_br - text_offset), label = label_br, color = label_color_br, angle = 0, vjust = 1, size = 9) +
  #annotate("text", x = as.Date("2016-07-31"), y = (specific_value_gb - text_offset), label = label_gb, color = label_color_gb, angle = 0, vjust = 1, size = 4.2) +
  annotate("text", x = as.Date("2017-03-01"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2018-01-01"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  # annotate("segment", x = as.Date("2002-10-31"), xend = specific_time_te, y = specific_value_te, yend = arrow_y_start_te, 
  #           colour = label_color_te, size = 0.5) +
  annotate("segment", x = as.Date("2005-06-30"), xend = specific_time_va, y = specific_value_va, yend = arrow_y_start_va, 
           colour = label_color_va, size = 0.75) +
  #  annotate("segment", x = as.Date("2005-08-28"), xend = specific_time_fc, y = specific_value_fc, yend = arrow_y_start_fc, 
  #           colour = label_color_fc, size = 0.5) +
  annotate("segment", x = as.Date("2011-06-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.75) + 
  annotate("segment", x = as.Date("2010-06-28"), xend = specific_time_dc, y = specific_value_dc - 0.04, yend = arrow_y_start_dc, 
           colour = label_color_dc, size = 0.75) +
  annotate("segment", x = as.Date("2014-02-28"), xend = specific_time_qe, y = specific_value_qe - 0.04, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_br, y = specific_value_br - 0.04, yend = arrow_y_start_br, 
           colour = label_color_br, size = 0.75) + 
  annotate("segment", x = as.Date("2017-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2018-01-01"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

#annotate("segment", x = as.Date("2016-07-31"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
#         colour = label_color_qe, size = 0.75) 
print(p) 

#ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/NEWS_SENT.png", p, width = 16, height = 6)
ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWS_SENT_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure 4(a)
################################################################################

text_offset <- 0.0025

###

specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- +0.08
label_eu <- "EU Enlargement"
label_color_eu <- "red"
arrow_y_start_eu <- data[data$time == specific_time_eu, ]$News.Monetary.Quote.Hawkish

specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- 0.065
label_ih <- "Interest Rate Hikes"
label_color_ih <- "red"
arrow_y_start_ih <- data[data$time == specific_time_ih, ]$News.Monetary.Quote.Hawkish

specific_time_ns <- as.Date("2007-08-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- -0.17
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- -data[data$time == specific_time_ns, ]$News.Monetary.Quote.Dovish

specific_time_lb <- as.Date("2008-10-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- -0.075
label_lb <- "Interest Rate Cutes"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- -data[data$time == specific_time_lb, ]$News.Monetary.Quote.Dovish

specific_time_sm <- as.Date("2010-03-31")
specific_value_sm<- -0.05
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- -data[data$time == specific_time_sm, ]$News.Monetary.Quote.Dovish

specific_time_lt <- as.Date("2011-12-31")
specific_value_lt<- -0.12
label_lt <- "LTROs"
label_color_lt <- "red"
arrow_y_start_lt <- -data[data$time == specific_time_lt, ]$News.Monetary.Quote.Dovish

specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- -0.15
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- -data[data$time == specific_time_wt, ]$News.Monetary.Quote.Dovish

# specific_time_nr <- as.Date("2014-06-30")
# specific_value_nr <- +0.09
# label_nr <- "Negative Interest Rates"
# label_color_nr <- "red"
# arrow_y_start_nr <- -data[data$time == specific_time_nr, ]$News.Monetary.Quote.Dovish

specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- -0.08
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- -data[data$time == specific_time_qe, ]$News.Monetary.Quote.Dovish

specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.035
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data[data$time == specific_time_ta, ]$News.Monetary.Quote.Hawkish

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.12
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- -data[data$time == specific_time_covid, ]$News.Monetary.Quote.Dovish

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.068
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data[data$time == specific_time_ru_uk, ]$News.Monetary.Quote.Hawkish

###

scaling_factor <- 0.035

offset <- -2


inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -6, to = 6, by = 1)
breaks_frequency <- seq(from = -0.2, to = 0.1, by = 0.05)

###

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Monetary.Quote.Hawkish, color = "News Quote Hawkish"), fill = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(y = -News.Monetary.Quote.Dovish, color = "News Quote Dovish"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  
  geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 0.8) +
  
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Quote Hawkish"), 
             size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Quote Dovish"), 
             size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.190, 0.11),
    sec.axis = sec_axis(~inverse_transform(.), name="ECB MRO", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c("News Quote Hawkish" = "black", "News Quote Dovish" = "grey40", "MRO" = 'darkorange')) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("red", "grey40", "black"), 
                                                  shape = c(NA, 22, 22),
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #  legend.position = c(0.025, -0.16),
        legend.position = 'none',
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2005-09-28"), y = (specific_value_eu + 0.022), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  #annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  # annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  # annotate("text", x = as.Date("2005-06-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  #  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  annotate("text", x = as.Date("2008-03-30"), y = (specific_value_ns - text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2009-03-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2011-03-30"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2014-06-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2015-05-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_ta + 0.022), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-09-30"), y = (specific_value_covid - text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2020-01-01"), y = (specific_value_ru_uk + 0.022), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  annotate("segment", x = as.Date("2005-09-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75) +
  # annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_ih, y = specific_value_ih, yend = arrow_y_start_ih, 
  #          colour = label_color_ih, size = 0.5) +
  # annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #         colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2008-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  annotate("segment", x = as.Date("2009-03-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75) +
  annotate("segment", x = as.Date("2011-03-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2014-06-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
  # annotate("segment", x = as.Date("2015-05-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #          colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2016-05-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) +
  annotate("segment", x = as.Date("2019-09-30"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2020-01-01"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_QUOTE_MON_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure 4(b)
################################################################################

text_offset <- 0.015

###

specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- -0.025
label_eu <- "EU Enlargement"
label_color_eu <- "red"
arrow_y_start_eu <- -data[data$time == specific_time_eu, ]$News.Monetary.Quote.Pos.

specific_time_ns <- as.Date("2007-08-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- -0.045
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data[data$time == specific_time_ns, ]$News.Monetary.Quote.Neg.

specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- -0.065
label_ih <- "Interest Rate Hikes"
label_color_ih <- "red"
arrow_y_start_ih <- data[data$time == specific_time_ih, ]$News.Monetary.Quote.Neg.

specific_time_lb <- as.Date("2008-10-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.065
label_lb <- "Interest Rate Cutes"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data[data$time == specific_time_lb, ]$News.Monetary.Quote.Neg.

specific_time_sm <- as.Date("2010-03-31")
specific_value_sm<- 0.055
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- data[data$time == specific_time_sm, ]$News.Monetary.Quote.Neg.

specific_time_lt <- as.Date("2011-12-31")
specific_value_lt<- 0.08
label_lt <- "LTROs"
label_color_lt <- "red"
arrow_y_start_lt <- data[data$time == specific_time_lt, ]$News.Monetary.Quote.Neg.

specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- 0.108
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- data[data$time == specific_time_wt, ]$News.Monetary.Quote.Neg.

specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.12
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- data[data$time == specific_time_nr, ]$News.Monetary.Quote.Neg.

specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- 0.08
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- data[data$time == specific_time_qe, ]$News.Monetary.Quote.Neg.

specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.06
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data[data$time == specific_time_ta, ]$News.Monetary.Quote.Neg.

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.065
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- data[data$time == specific_time_covid, ]$News.Monetary.Quote.Neg.

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.105
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data[data$time == specific_time_ru_uk, ]$News.Monetary.Quote.Neg.

###

scaling_factor <- 0.025

offset <- -2

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 6, by = 1)
breaks_frequency <- seq(from = -0.2, to = 0.15, by = 0.025)

###

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Monetary.Quote.Neg., color = "News Quote Negative"), fill = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(y = -News.Monetary.Quote.Pos., color = "News Quote Positive"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  
  geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 0.8) +
  
  geom_point(aes(x = as.Date("2002-01-01"), y = 0, color = "News Quote Negative"), 
             size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  geom_point(aes(x = as.Date("2002-01-01"), y = 0, color = "News Quote Positive"), 
             size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-0.075, 0.125),
    sec.axis = sec_axis(~inverse_transform(.), name="ECB MRO", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c( "MRO" = 'darkorange', "News Quote Positive" = "grey40", "News Quote Negative" = "black"),
                     breaks = c("MRO", "News Quote Positive", "News Quote Negative")) +
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("red", "grey40", 'black'), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 20),
        axis.text.y.right = element_text(color = "black", size = 20),
        axis.title.y = element_text(color = "black", size = 20),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, 0.6),
        legend.position = 'none',
        legend.text = element_text(size = 20), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2005-08-28"), y = (specific_value_eu - 0.002), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 4.2) +
  annotate("text", x = as.Date("2009-03-30"), y = (specific_value_ns - 0.002), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2009-12-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2011-01-31"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-10-30"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 9) +
  #annotate("text", x = as.Date("2014-06-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2014-10-30"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2016-09-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid - 0.002), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-10-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  
  annotate("segment", x = as.Date("2005-08-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75) +
  #  annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #          colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2009-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  annotate("segment", x = as.Date("2009-12-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75) +
  annotate("segment", x = as.Date("2011-01-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2010-10-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
#  annotate("segment", x = as.Date("2014-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2014-10-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2016-09-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2019-10-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_QUOTE_SENT_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure E.1(a)
################################################################################

specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- 0.27
label_eu <- "EU Enlargement"
label_color_eu <- "red"
arrow_y_start_eu <- data[data$time == specific_time_eu, ]$News.Monetary.Non.Quote.Hawkish

specific_time_ns <- as.Date("2007-08-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- -0.55
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- -data[data$time == specific_time_ns, ]$News.Monetary.Non.Quote.Dovish

specific_time_lb <- as.Date("2008-10-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- -0.3
label_lb <- "Interest Rate Cutes"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- -data[data$time == specific_time_lb, ]$News.Monetary.Non.Quote.Dovish

specific_time_sm <- as.Date("2010-03-31")
specific_value_sm<- +0.25
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- -data[data$time == specific_time_sm, ]$News.Monetary.Non.Quote.Dovish

specific_time_lt <- as.Date("2011-12-31")
specific_value_lt<- -0.35
label_lt <- "LTROs"
label_color_lt <- "red"
arrow_y_start_lt <- -data[data$time == specific_time_lt, ]$News.Monetary.Non.Quote.Dovish

specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- -0.45
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- -data[data$time == specific_time_wt, ]$News.Monetary.Non.Quote.Dovish

# specific_time_nr <- as.Date("2014-06-30")
# specific_value_nr <- -0.51
# label_nr <- "Negative Interest Rates"
# label_color_nr <- "red"
# arrow_y_start_nr <- -data[data$time == specific_time_nr, ]$News.Monetary.Non.Quote.Dovish

specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- -0.58
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- -data[data$time == specific_time_qe, ]$News.Monetary.Non.Quote.Dovish

specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.18
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data[data$time == specific_time_ta, ]$News.Monetary.Non.Quote.Hawkish

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.35
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- -data[data$time == specific_time_covid, ]$News.Monetary.Non.Quote.Dovish

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.25
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data[data$time == specific_time_ru_uk, ]$News.Monetary.Non.Quote.Hawkish

###

#scaling_factor <- 0.025

#offset <- -2


inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 5, by = 1)
breaks_frequency <- seq(from = -0.6, to = 0.3, by = 0.1)

###

text_offset <- 0.012

scaling_factor <- 0.10

offset <- -2

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Monetary.Non.Quote.Hawkish, color = "News Non Quote Hawkish"), fill = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(y = -News.Monetary.Non.Quote.Dovish, color = "News Non Quote Dovish"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  
  geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 0.8) +
  
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Hawkish"), 
             size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Dovish"), 
             size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) ifelse(abs(x) < .Machine$double.eps^0.5, "0", as.character(abs(x))),
    breaks = breaks_frequency,
    limits = c(-0.63, 0.33),
    sec.axis = sec_axis(~inverse_transform(.), name="ECB MRO", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c("News Non Quote Hawkish" = "black", "News Non Quote Dovish" = "grey40", "MRO" = 'darkorange')) +
  
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("red", "grey40", 'black'), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, -0.16),
        legend.position = "none",
        legend.text = element_text(size = 22), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) + 
  # Annotations
  annotate("text", x = as.Date("2005-06-28"), y = (specific_value_eu + 0.06), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.75) +
  #  annotate("text", x = as.Date("2006-08-30"), y = (specific_value_ih + 0.02), label = label_ih, color = label_color_ih, angle = 0, vjust = 1, size = 6.75) +
  annotate("text", x = as.Date("2008-03-30"), y = (specific_value_ns - text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  # annotate("text", x = as.Date("2009-03-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2009-12-31"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-12-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2015-05-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2016-10-30"), y = (specific_value_ta + 0.06), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-08-30"), y = (specific_value_covid - text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-11-01"), y = (specific_value_ru_uk + 0.06), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  annotate("segment", x = as.Date("2005-06-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75) +
  # annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_ih, y = specific_value_ih, yend = arrow_y_start_ih, 
  #          colour = label_color_ih, size = 0.5) +
  # annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #         colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2008-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  #annotate("segment", x = as.Date("2009-03-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
  #         colour = label_color_sm, size = 0.5) +
  annotate("segment", x = as.Date("2009-12-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2010-10-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
  # annotate("segment", x = as.Date("2015-05-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
  #          colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2016-10-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) +
  annotate("segment", x = as.Date("2019-08-30"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2019-11-01"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_NON_QUOTE_MON_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure E.1(b)
################################################################################

text_offset <- 0.045

###

inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

breaks_mro <- seq(from = -5, to = 6, by = 1)
breaks_frequency <- seq(from = -0.6, to = 0.5, by = 0.1)

###

specific_time_eu <- as.Date("2004-02-29")
specific_value_eu <- -0.05
label_eu <- "EU Enlargement"
label_color_eu <- "red"
arrow_y_start_eu <- data[data$time == specific_time_eu, ]$News.Monetary.Non.Quote.Neg.

specific_time_ns <- as.Date("2007-08-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- -0.12
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data[data$time == specific_time_ns, ]$News.Monetary.Non.Quote.Neg.

specific_time_ih <- as.Date("2005-12-31")
specific_value_ih <- 0.08
label_ih <- "Interest Rate Hikes"
label_color_ih <- "red"
arrow_y_start_ih <- data[data$time == specific_time_ih, ]$News.Monetary.Non.Quote.Neg

specific_time_lb <- as.Date("2008-10-31")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 0.18
label_lb <- "Interest Rate Cutes"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data[data$time == specific_time_lb, ]$News.Monetary.Non.Quote.Neg.

specific_time_sm <- as.Date("2010-03-31")
specific_value_sm<- 0.30
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- data[data$time == specific_time_sm, ]$News.Monetary.Non.Quote.Neg.

specific_time_lt <- as.Date("2011-12-31")
specific_value_lt<- 0.35
label_lt <- "LTROs"
label_color_lt <- "red"
arrow_y_start_lt <- data[data$time == specific_time_lt, ]$News.Monetary.Non.Quote.Neg.

specific_time_wt <- as.Date("2012-08-31")
specific_value_wt <- 0.45
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- data[data$time == specific_time_wt, ]$News.Monetary.Non.Quote.Neg.

specific_time_nr <- as.Date("2014-06-30")
specific_value_nr <- 0.55
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- data[data$time == specific_time_nr, ]$News.Monetary.Non.Quote.Neg.

specific_time_qe <- as.Date("2015-01-31")
specific_value_qe <- 0.33
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- data[data$time == specific_time_qe, ]$News.Monetary.Non.Quote.Neg.

specific_time_ta <- as.Date("2017-10-31")
specific_value_ta <- 0.25
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data[data$time == specific_time_ta, ]$News.Monetary.Non.Quote.Neg.

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -0.16
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- data[data$time == specific_time_covid, ]$News.Monetary.Non.Quote.Neg.

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 0.35
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data[data$time == specific_time_ru_uk, ]$News.Monetary.Non.Quote.Neg.


scaling_factor <- 0.1

offset <- -1.5

p <- ggplot(data, aes(x = time)) + 
  geom_col(aes(y = News.Monetary.Non.Quote.Neg., color = "News Non Quote Negative"), fill = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(y = -News.Monetary.Non.Quote.Pos., color = "News Non Quote Positive"), fill = "grey40", size = 0.1, show.legend = FALSE) +
  
  geom_line(aes(y = (ECB.MRO + offset)  * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 0.8) +
  
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Negative"), 
             size = 5, shape = 22, fill = "black", show.legend = TRUE) +
  geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "News Non Quote Positive"), 
             size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
  
  scale_y_continuous(
    name = "% of News Coverage",
    labels = function(x) ifelse(abs(x) < .Machine$double.eps^0.5, "0", as.character(abs(x))),
    breaks = breaks_frequency,
    limits = c(-0.2, 0.5),
    sec.axis = sec_axis(~inverse_transform(.), name="MRO (%)", breaks = breaks_mro)
  ) +
  scale_color_manual(values = c( "MRO" = 'darkorange', "News Non Quote Positive" = "grey40", "News Non Quote Negative" = "black"),
                     breaks = c("MRO", "News Non Quote Positive", "News Non Quote Negative")) +
  scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
               breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
               name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
  
  guides(color = guide_legend(title = "", 
                              override.aes = list(fill = c("red", "grey40", 'black'), 
                                                  shape = c(NA, 22, 22), 
                                                  linetype = c("longdash", "blank", "blank")))) +
  
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "black", size = 22),
        axis.text.y.right = element_text(color = "black", size = 22),
        axis.title.y = element_text(color = "black", size = 22),
        axis.text.x = element_text(angle = 90, vjust = 0.5, size = 14),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        #   legend.position = c(0.025, 0.6),
        legend.position = 'none',
        legend.text = element_text(size = 20), 
        legend.justification = c(0, -1),
        legend.key.size = unit(0.5, "cm")) +
  
  # Annotations
  annotate("text", x = as.Date("2005-03-28"), y = (specific_value_eu - 0.0125), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 9) +
  # annotate("text", x = as.Date("2005-03-30"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 4.2) +
 annotate("text", x = as.Date("2008-03-30"), y = (specific_value_ns - 0.0125), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 9) +
  #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
  annotate("text", x = as.Date("2008-08-30"), y = (specific_value_sm + text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2010-10-30"), y = (specific_value_lt + text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2011-10-31"), y = (specific_value_wt + text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 9) +
 # annotate("text", x = as.Date("2014-06-30"), y = (specific_value_nr + text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2013-08-28"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2018-06-30"), y = (specific_value_ta + text_offset + 0.01), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid - 0.0125), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2019-09-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  
  annotate("segment", x = as.Date("2005-03-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
           colour = label_color_eu, size = 0.75) +
  #  annotate("segment", x = as.Date("2005-03-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
  #          colour = label_color_lb, size = 0.5) +
  #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
  #           colour = label_color_gd, size = 0.5) +
  annotate("segment", x = as.Date("2008-03-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.75) +
  annotate("segment", x = as.Date("2008-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.75) +
  annotate("segment", x = as.Date("2010-10-30"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.75) + 
  annotate("segment", x = as.Date("2011-10-31"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.75) + 
 # annotate("segment", x = as.Date("2014-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2013-08-28"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.75) +
  annotate("segment", x = as.Date("2018-06-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.75) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.75) +
  annotate("segment", x = as.Date("2019-09-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.75) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/NEWSECB_NON_QUOTE_SENT_2.png", p, width = 10, height = 6, dpi = 300)

################################################################################
### Figure 5
################################################################################

data_ECB = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_ECB_2_og.xlsx')
data_ECB = data.frame(data_ECB)
#data_ECB = data_ECB[7:dim(data_ECB)[1],]

data_ECB$time = as.Date(strptime(data_ECB$time, "%Y-%m-%d"))

data_ECB <- data_ECB %>%
  arrange(time) %>%
  mutate(width = as.numeric(difftime(lead(time, default = last(time) + 30), time, units = "days")))

# data_ECB = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly_2_ECB_2_og_full.xlsx')
# data_ECB = data.frame(data_ECB)
# 
# data_ECB$time = as.Date(strptime(data_ECB$t_date, "%Y-%m-%d"))
# 
# data_ECB = data_ECB[26:dim(data_ECB)[1],]

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

text_offset = 2.5

breaks_inflation <- seq(from = -6, to = 12, by = 2)
breaks_frequency <- seq(from = -25, to = 30, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- "red"
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Inflation.Dec.

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- "red"
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Inflation.Inc.

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 27
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Inflation.Inc.

specific_time_lb <- as.Date("2008-09-04")
specific_value_lb <- 17
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Inc.

specific_time_lb <- as.Date("2008-10-02")
specific_value_lb <- -21
#label_lb <- "Interest Rate Cuts"
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- -data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Dec.

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- -17
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Inflation.Dec.

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -15
label_lt <- "TLTRO"
label_color_lt <- "red"
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Inflation.Dec.

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -23.5
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Inflation.Dec.

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -20.5
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Inflation.Dec.

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- 13
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Inflation.Inc.

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 18
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Inflation.Inc.

specific_time_covid <- as.Date("2020-03-12")
specific_value_covid <- -18
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- -data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Inflation.Dec.

specific_time_ru_uk <- as.Date("2022-03-10")
specific_value_ru_uk <- 27.5
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data_ECB[data_ECB$time == specific_time_ru_uk, ]$ECB.PC.Inflation.Inc.

scaling_factor <- max(abs(data_ECB$ECB.PC.Inflation.Inc.), abs(data_ECB$ECB.PC.Inflation.Dec.)) / max(data$German.Inflation.Year.on.Year, na.rm = TRUE)
scaling_factor = 2.5
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

p <- ggplot(data_ECB) + 
  geom_col(aes(x = time, y = ECB.PC.Inflation.Inc., width = width),
           fill = "black", color = "black", size = 0.1, show.legend = FALSE) +
  geom_col(aes(x = time, y = -ECB.PC.Inflation.Dec., width = width),
           fill = "grey40", color = "grey40", size = 0.1, show.legend = FALSE) +
  
geom_line(
  data = data_eu_for, 
  aes(x = time, y = (Inflation.Forecast.EU.Staff+ offset) * scaling_factor, color = "Next Year Forecast"), 
  linetype = "solid", 
  size = 0.8,    # Increased size
  na.rm = TRUE
) +
  
  geom_line(
    data = data, 
    aes(x = time, y = (German.Inflation.Year.on.Year+ offset) * scaling_factor, color = "Inflation"), 
    linetype = "solid", 
    size = 0.8,    # Increased size
    na.rm = TRUE
  ) +
  
  
  scale_color_manual(
    values = c("Next Year Forecast" = "green", "Inflation" = 'darkorange')  # Changed to blue for better contrast
  ) +
  
  # Define Y-axis with secondary axis
  scale_y_continuous(
    name = "(%) Share of Sentences in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-25,30),
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
  
  # Apply classic theme and customize text elements
  theme_classic() + 
  theme(
    axis.text.y.left = element_text(color = "black", size = 20),
    axis.text.y.right = element_text(color = "black", size = 20),
    axis.title.y = element_text(color = "black", size = 13),
    axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",  # No legend as lines are commented out
    legend.text = element_text(size = 20), 
    legend.justification = c(0, -1),
    legend.key.size = unit(0.5, "cm")) +

# Annotations 
#annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
 # annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2007-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2007-11-30"), y = (specific_value_sm - text_offset + 1.5), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2011-07-31"), y = (specific_value_lt - text_offset + 1.5), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2012-04-30"), y = (specific_value_wt - text_offset + 1.5), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset + 1.5), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2015-01-22"), y = (specific_value_qe + text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2016-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2005-08-28"), y = (specific_value_lb - text_offset + 1.5), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2020-03-12"), y = (specific_value_covid - text_offset + 1.5), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2021-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 6.5) +
  
  # Existing segments
 # annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
#           colour = label_color_euro_intro, size = 0.5) +
  annotate("segment", x = as.Date("2007-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.5) +
#  annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
 #          colour = label_color_eu_enlargement, size = 0.5) +
  annotate("segment", x = as.Date("2007-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.5) +
  annotate("segment", x = as.Date("2011-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.5) + 
  annotate("segment", x = as.Date("2005-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.5) + 
  annotate("segment", x = as.Date("2012-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.5) + 
  annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2015-01-22"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.5) +
  annotate("segment", x = as.Date("2016-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.5) +
  annotate("segment", x = as.Date("2020-03-12"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.5) +
  annotate("segment", x = as.Date("2021-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.5) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/final/ECB_INF.png", p, width = 10, height = 6, dpi = 300)

################################################################################

text_offset = 2.5

breaks_mro <- seq(from = -4, to = 5, by = 1)
breaks_frequency <- seq(from = -30, to = 25, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- "red"
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Monetary.Dov.

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- "red"
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Monetary.Haw.

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 25
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Monetary.Haw.

specific_time_lb <- as.Date("2008-09-04")
specific_value_lb <- 9
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Monetary.Haw.

specific_time_lb <- as.Date("2008-10-02")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- 15
#label_lb <- "Interest Rate Cuts"
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Monetary.Haw.

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- -17
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Monetary.Dov.

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -30
label_lt <- "TLTRO"
label_color_lt <- "red"
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Monetary.Dov.

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -24
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Monetary.Dov.

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -27
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Monetary.Dov.

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- -24
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- -data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Monetary.Dov.

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 20
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Monetary.Haw.

specific_time_covid <- as.Date("2020-01-23")
specific_value_covid <- 9
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Monetary.Haw.

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 20
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
arrow_y_start_ru_uk <- data_ECB[data_ECB$time == specific_time_ru_uk, ]$ECB.PC.Monetary.Haw.

scaling_factor <- max(abs(data_ECB$ECB.PC.Monetary.Haw.), abs(data_ECB$ECB.PC.Monetary.Dov.)) / max(data$ECB.MRO, na.rm = TRUE)
scaling_factor = 6
offset <- -2
inverse_transform <- function(x) {
  (x / scaling_factor) - offset
}

# Create the plot
p <- ggplot() + 
  # First Part: Rows 1-25 with width = 40
  geom_col(data = data_first_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 40,    # Width for first part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_first_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 40,    # Width for first part
           show.legend = FALSE, 
           position = "identity") +
  
  # Second Part: Rows 26-102 with width = 30
  geom_col(data = data_second_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 30,    # Width for second part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 30,    # Width for second part
           show.legend = FALSE, 
           position = "identity") +
  
  # Third Part: Rows 103-n with width = 20
  geom_col(data = data_third_part, 
           aes(x = time, y = ECB.PC.Monetary.Haw.), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 40,    # Width for third part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = -ECB.PC.Monetary.Dov.), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 40,    # Width for third part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_line(aes(x = time, y = (ECB.MRO + offset) * scaling_factor, color = "MRO"), 
            linetype = "solid", size = 0.8, data = data) +
  
  # geom_line(aes(x = time, y = (Eurozone.Inflation + offset) * scaling_factor, color = "Inflation"), 
  #           linetype = "solid", size = 0.8, data = data) +
  # 
  # geom_line(data = data_eu_for, aes(x = Date, y = (Next.year.forecast + offset) * scaling_factor, color = "Next Year Forecast"), 
  #           linetype = "solid", size = 0.8) +
  
#  scale_color_manual(values = c("Inflation" = 'darkorange', "Next Year Forecast" = "green")) +
  scale_color_manual(values = c("MRO" = 'darkorange')) +
  
  # Define Y-axis with secondary axis
  scale_y_continuous(
    name = "Share of Sentences in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-max(abs(data_ECB$ECB.PC.Monetary.Dov.)), max(abs(data_ECB$ECB.PC.Monetary.Haw.))),
    sec.axis = sec_axis(~inverse_transform(.), 
                        name = "MRO", 
                        breaks = breaks_mro)
  ) +
  
  # Define X-axis as Date
  scale_x_date(
    expand = c(0.015, 0), 
    date_labels = "%Y", 
    breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
    name = "", 
    limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))
  ) +
  
  # Apply classic theme and customize text elements
  theme_classic() + 
  theme(
    axis.text.y.left = element_text(color = "black", size = 22),
    axis.text.y.right = element_text(color = "black", size = 22),
    axis.title.y = element_text(color = "black", size = 13),
    axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",  # No legend as lines are commented out
    legend.text = element_text(size = 20), 
    legend.justification = c(0, -1),
    legend.key.size = unit(0.5, "cm")) +
  
  # Annotations 
 # annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
#  annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2005-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2007-11-30"), y = (specific_value_sm - text_offset + 2), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_lt - text_offset + 2), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2008-04-30"), y = (specific_value_wt - text_offset + 2), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2012-06-30"), y = (specific_value_nr - text_offset + 2), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2014-09-30"), y = (specific_value_qe - text_offset + 2), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2015-08-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2019-01-01"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2021-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 6.5) +
  
  # Existing segments
 # annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
  #         colour = label_color_euro_intro, size = 0.5) +
  annotate("segment", x = as.Date("2005-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.5) +
  #annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
  #         colour = label_color_eu_enlargement, size = 0.5) +
  annotate("segment", x = as.Date("2007-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.5) +
  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.5) + 
  annotate("segment", x = as.Date("2015-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.5) + 
  annotate("segment", x = as.Date("2008-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.5) + 
  annotate("segment", x = as.Date("2012-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2014-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.5) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.5) +
  annotate("segment", x = as.Date("2019-01-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.5) +
  annotate("segment", x = as.Date("2021-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.5) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/ECB_MRO.png", p, width = 10, height = 6, dpi = 300)

################################################################################

breaks_gdp <- seq(from = -4, to = 5, by = 1)
breaks_frequency <- seq(from = -25, to = 25, by = 5)

data_first_part <- data_ECB[1:25, ]
data_second_part <- data_ECB[26:102, ]
data_third_part <- data_ECB[103:nrow(data_ECB), ]

################################################################################

specific_time_euro_intro <- as.Date("2002-01-03")
specific_value_euro_intro <- -10
label_euro_intro <- "Introduction of Euro"
label_color_euro_intro <- "red"
arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Outlook.Up

specific_time_eu_enlargement <- as.Date("2004-05-06")
specific_value_eu_enlargement <- 20
label_eu_enlargement <- "EU Enlargement"
label_color_eu_enlargement <- "red"
arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Outlook.Up

specific_time_ns <- as.Date("2007-09-06")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_ns <- 25
label_ns <- "First Non-Standard Measures"
label_color_ns <- "red"
arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Outlook.Up

specific_time_lb <- as.Date("2008-09-04")
specific_value_lb <- 9
label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Outlook.Up

specific_time_lb <- as.Date("2008-10-02")
#specific_time_lb <- as.Date("2008-09-30")
specific_value_lb <- -9
label_lb <- "Interest Rate Cuts"
#label_lb <- "Fall of Lehman Brothers"
label_color_lb <- "red"
arrow_y_start_lb <- -data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Outlook.Up

specific_time_sm <- as.Date("2010-03-04")
specific_value_sm<- -6.25
label_sm <- "SMP"
label_color_sm <- "red"
arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Outlook.Up

specific_time_lt <- as.Date("2011-12-08")
specific_value_lt<- -15
label_lt <- "TLTRO"
label_color_lt <- "red"
arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Outlook.Up

specific_time_wt <- as.Date("2012-08-02")
specific_value_wt <- -22
label_wt <- "Whatever it Takes"
label_color_wt <- "red"
arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Outlook.Up

specific_time_nr <- as.Date("2014-06-05")
specific_value_nr <- -20
label_nr <- "Negative Interest Rates"
label_color_nr <- "red"
arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Outlook.Up

specific_time_qe <- as.Date("2015-01-22")
specific_value_qe <- -15
label_qe <- "QE"
label_color_qe <- "red"
arrow_y_start_qe <- -data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Outlook.Up

specific_time_ta <- as.Date("2017-10-26")
specific_value_ta <- 20
label_ta <- "Tapering of QE"
label_color_ta <- "red"
arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Outlook.Up

specific_time_covid <- as.Date("2020-02-29")
specific_value_covid <- -20
label_covid <- "COVID-19 Pandemic"
label_color_covid <- "red"
arrow_y_start_covid <- -data_ECB[data_ECB$time == specific_time_covid, ]$ECB.PC.Outlook.Up

specific_time_ru_uk <- as.Date("2022-02-28")
specific_value_ru_uk <- 20
label_ru_uk <- "Russia-Ukraine War"
label_color_ru_uk <- "red"
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

# Create the plot
p <- ggplot() + 
  # First Part: Rows 1-25 with width = 40
  geom_col(data = data_first_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 40,    # Width for first part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_first_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 40,    # Width for first part
           show.legend = FALSE, 
           position = "identity") +
  
  # Second Part: Rows 26-102 with width = 30
  geom_col(data = data_second_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 30,    # Width for second part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_second_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 30,    # Width for second part
           show.legend = FALSE, 
           position = "identity") +
  
  # Third Part: Rows 103-n with width = 20
  geom_col(data = data_third_part, 
           aes(x = time, y = ECB.PC.Outlook.Up), 
           fill = "black", 
           color = "black", 
           size = 0.1, 
           width = 40,    # Width for third part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_col(data = data_third_part, 
           aes(x = time, y = -ECB.PC.Outlook.Down), 
           fill = "grey40", 
           color = "grey40", 
           size = 0.1, 
           width = 40,    # Width for third part
           show.legend = FALSE, 
           position = "identity") +
  
  geom_line(
    data = data_ECB_clean, 
    aes(x = time, y = y_forecast, color = "Next Year Forecast"), 
    linetype = "solid", 
    size = 0.8,    # Increased size
    na.rm = TRUE
  ) +
  
  # scale_color_manual(values = c("Next Year Forecast" = "green")) + # "Inflation" = 'darkorange', 
  scale_color_manual(
    values = c("Next Year Forecast" = "blue")  # Changed to blue for better contrast
  ) +
  
  # Define Y-axis with secondary axis
  scale_y_continuous(
    name = "Share of Sentences in Press Conferences",
    labels = function(x) abs(x),
    breaks = breaks_frequency,
    limits = c(-max(abs(data_ECB$ECB.PC.Outlook.Down)), max(abs(data_ECB$ECB.PC.Outlook.Up))),
    sec.axis = sec_axis(~inverse_transform(.), 
                        name = "GDP Growth", 
                        breaks = breaks_gdp)
  ) +
  
  # Define X-axis as Date
  scale_x_date(
    expand = c(0.015, 0), 
    date_labels = "%Y", 
    breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
    name = "", 
    limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))
  ) +
  
  # Apply classic theme and customize text elements
  theme_classic() + 
  theme(
    axis.text.y.left = element_text(color = "black", size = 22),
    axis.text.y.right = element_text(color = "black", size = 22),
    axis.title.y = element_text(color = "black", size = 13),
    axis.text.x = element_text(angle = 45, vjust = 0.5, size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    legend.position = "none",  # No legend as lines are commented out
    legend.text = element_text(size = 20), 
    legend.justification = c(0, -1),
    legend.key.size = unit(0.5, "cm")) +
  
  # Annotations 
  annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2005-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2009-11-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2011-07-31"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2012-04-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2006-08-28"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
  annotate("text", x = as.Date("2019-03-01"), y = (specific_value_covid + text_offset), label = label_covid, color = label_color_covid, angle = 0, vjust = 1, size = 9) +
  annotate("text", x = as.Date("2021-02-28"), y = (specific_value_ru_uk + text_offset), label = label_ru_uk, color = label_color_ru_uk, angle = 0, vjust = 1, size = 9) +
  
  # Existing segments
  annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
           colour = label_color_euro_intro, size = 0.5) +
  annotate("segment", x = as.Date("2005-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
           colour = label_color_ns, size = 0.5) +
  annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
           colour = label_color_eu_enlargement, size = 0.5) +
  annotate("segment", x = as.Date("2009-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
           colour = label_color_sm, size = 0.5) +
  annotate("segment", x = as.Date("2011-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
           colour = label_color_lt, size = 0.5) + 
  annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
           colour = label_color_lb, size = 0.5) + 
  annotate("segment", x = as.Date("2012-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
           colour = label_color_wt, size = 0.5) + 
  annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
           colour = label_color_nr, size = 0.5) + 
  annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
           colour = label_color_qe, size = 0.5) +
  annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
           colour = label_color_ta, size = 0.5) +
  annotate("segment", x = as.Date("2019-03-01"), xend = specific_time_covid, y = specific_value_covid, yend = arrow_y_start_covid, 
           colour = label_color_covid, size = 0.5) +
  annotate("segment", x = as.Date("2021-02-28"), xend = specific_time_ru_uk, y = specific_value_ru_uk, yend = arrow_y_start_ru_uk, 
           colour = label_color_ru_uk, size = 0.5) 

print(p)

ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/ECB_GDP.png", p, width = 10, height = 6, dpi = 400)

# specific_time_eu <- as.Date("2004-02-29")
# specific_value_eu <- 7
# label_eu <- "EU Enlargement"
# label_color_eu <- "red"
# arrow_y_start_eu <- data[data$time == specific_time_eu, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_ns <- as.Date("2007-08-31")
# #specific_time_lb <- as.Date("2008-09-30")
# specific_value_ns <- 9
# label_ns <- "First Non-Standard Measures"
# label_color_ns <- "red"
# arrow_y_start_ns <- data[data$time == specific_time_ns, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_lb <- as.Date("2008-10-31")
# #specific_time_lb <- as.Date("2008-09-30")
# specific_value_lb <- -5
# label_lb <- "Interest Rate Cutes"
# #label_lb <- "Fall of Lehman Brothers"
# label_color_lb <- "red"
# arrow_y_start_lb <- -data[data$time == specific_time_lb, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_lb <- as.Date("2008-09-30")
# specific_value_lb <- 9
# label_lb <- "Fall of Lehman Brothers"
# label_color_lb <- "red"
# arrow_y_start_lb <- data[data$time == specific_time_lb, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_sm <- as.Date("2010-03-31")
# specific_value_sm<- -6.25
# label_sm <- "SMP"
# label_color_sm <- "red"
# arrow_y_start_sm <- -data[data$time == specific_time_sm, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_lt <- as.Date("2011-12-31")
# specific_value_lt<- -5
# label_lt <- "TLTRO"
# label_color_lt <- "red"
# arrow_y_start_lt <- -data[data$time == specific_time_lt, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_wt <- as.Date("2012-08-31")
# specific_value_wt <- -8
# label_wt <- "Whatever it Takes"
# label_color_wt <- "red"
# arrow_y_start_wt <- -data[data$time == specific_time_wt, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_nr <- as.Date("2014-06-30")
# specific_value_nr <- -12
# label_nr <- "Negative Interest Rates"
# label_color_nr <- "red"
# arrow_y_start_nr <- -data[data$time == specific_time_nr, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_qe <- as.Date("2015-01-31")
# specific_value_qe <- -7
# label_qe <- "QE"
# label_color_qe <- "red"
# arrow_y_start_qe <- -data[data$time == specific_time_qe, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_ta <- as.Date("2017-10-31")
# specific_value_ta <- 5
# label_ta <- "Tapering of QE"
# label_color_ta <- "red"
# arrow_y_start_ta <- data[data$time == specific_time_ta, ]$ECB.PC.Inflation.Inc.

# p <- ggplot(data[51:dim(data)[1],], aes(x = time)) + 
#   geom_col(aes(y = ECB.PC.Inflation.Inc., color = "ECB.PC.Inflation.Increasing"), fill = "black", size = 0.1, show.legend = FALSE) +
#   geom_col(aes(y = -ECB.PC.Inflation.Dec., color = "ECB.PC.Inflation.Decreasing"), fill = "grey40", size = 0.1, show.legend = FALSE) +
#   
#   geom_line(aes(y = (Eurozone.Inflation + offset) * scaling_factor, color = "Inflation"), 
#             linetype = "solid", size = 0.8) +
#   # geom_line(aes(y = (Eurozone.Inflation.Professionell.Forecasts + offset) * scaling_factor, color = "Inflation Staff Forecast"),
#   #           linetype = "solid", size = 0.8) +
#   
#   # geom_line(data = data_eu_for, aes(x = Date, y = (Next.year.forecast + offset) * scaling_factor, color = "Next Year Forecast"), 
#   #           linetype = "solid", size = 0.8) +
#   
#   geom_step(data = data_eu_for, aes(x = Date, y = (Next.year.forecast + offset) * scaling_factor, color = "Next Year Forecast"), 
#             linetype = "solid", size = 0.8) +
#   
#   geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "ECB.PC.Inflation.Increasing"), 
#              size = 5, shape = 22, fill = "black", show.legend = TRUE) +
#   geom_point(aes(x = as.Date("2000-01-01"), y = 0, color = "ECB.PC.Inflation.Decreasing"), 
#              size = 5, shape = 22, fill = "grey40", show.legend = TRUE) +
#   
#   scale_y_continuous(
#     name = "Share of Sentences in Press Conferences",
#     labels = function(x) abs(x),
#     breaks = breaks_frequency,
#     limits = c(-10, 11),
#     sec.axis = sec_axis(~inverse_transform(.), name="Inflation", breaks = breaks_inflation), expand = c(0.075, 0)) +
#   scale_color_manual(values = c("ECB.PC.Inflation.Increasing" = "black", "ECB.PC.Inflation.Decreasing" = "grey40", "Inflation" = 'darkorange', "Inflation Staff Forecast" = "green")) +
#   
#   scale_x_date(expand = c(0.015, 0), date_labels="%Y", 
#                breaks = seq(as.Date("2006-01-01"), as.Date("2019-01-01"), by = "1 year"), 
#                name = "", limits = c(as.Date("2006-01-01"), as.Date("2019-01-01"))) +
#   
#   guides(color = guide_legend(title = "", override.aes = list(fill = c("grey40",'black', "red", "green"), 
#                                                               shape = c(22, 22, NA, NA), 
#                                                               linetype = c("blank", "blank","longdash", "longdash")))) +
#   
#   theme_classic() + 
#   theme(axis.text.y.left = element_text(color = "black", size = 20),
#         axis.text.y.right = element_text(color = "black", size = 20),
#         axis.title.y = element_text(color = "black", size = 13),
#         axis.text.x = element_text(angle = 45, vjust = 0.5, size = 20),
#         panel.grid.minor = element_blank(),
#         panel.grid.major = element_blank(),
#         # legend.position = c(0.025, -0.275),
#         legend.position = "none",
#         legend.text = element_text(size = 20), 
#         legend.justification = c(0, -1),
#         legend.key.size = unit(0.5, "cm")) +
#   
#   # Annotations
#   #annotate("text", x = as.Date("2003-08-28"), y = (specific_value_eu + text_offset), label = label_eu, color = label_color_eu, angle = 0, vjust = 1, size = 6.5) +
#   # annotate("text", x = as.Date("2006-07-30"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 4.2) +
#   annotate("text", x = as.Date("2005-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 6.5) +
#   #  annotate("text", x = as.Date("2009-07-31"), y = (specific_value_gd + text_offset), label = label_gd, color = label_color_gd, angle = 0, vjust = 1) +
#   annotate("text", x = as.Date("2009-11-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2011-07-31"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2012-04-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2012-08-28"), y = (specific_value_lb + text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
#   
#   
#   # annotate("segment", x = as.Date("2003-08-28"), xend = specific_time_eu, y = specific_value_eu, yend = arrow_y_start_eu, 
#   #          colour = label_color_eu, size = 0.5) +
#   annotate("segment", x = as.Date("2012-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
#            colour = label_color_lb, size = 0.5) + 
#   # annotate("segment", x = as.Date("2006-07-30"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
#   #          colour = label_color_lb, size = 0.5) +
#   #  annotate("segment", x = as.Date("2009-07-31"), xend = specific_time_gd, y = specific_value_gd, yend = arrow_y_start_gd, 
#   #           colour = label_color_gd, size = 0.5) +
#   annotate("segment", x = as.Date("2005-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
#            colour = label_color_ns, size = 0.5) +
#   annotate("segment", x = as.Date("2009-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
#            colour = label_color_sm, size = 0.5) +
#   annotate("segment", x = as.Date("2011-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
#            colour = label_color_lt, size = 0.5) + 
#   annotate("segment", x = as.Date("2012-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
#            colour = label_color_wt, size = 0.5) + 
#   annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#            colour = label_color_nr, size = 0.5) + 
#   annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
#            colour = label_color_qe, size = 0.5) +
#   annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
#            colour = label_color_ta, size = 0.5) 
# 
# print(p) 
# 
# ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/ECB_INF.png", p, width = 10, height = 6, dpi = 900)

###

# p <- ggplot(data_press, aes(x = date)) +
#   geom_line(data = data, aes(x = time, y = Household.Inflation.Expectations, colour = "Expected Inflation", linetype = "Expected Inflation"), linewidth = 0.6) +
#   geom_line(data = data, aes(x = time, y = German.Household.Inflation.Expectations.CP.TOT.per, colour = "Perceived Inflation", linetype = "Perceived Inflation"), linewidth = 0.6) +
#   geom_line(data = data, aes(x = time, y = German.Inflation.Year.on.Year, colour = "HICP", linetype = "HICP"), linewidth = 0.6) +
#   
#   scale_y_continuous(name = "Inflation", labels = function(x) abs(x)) +
#   scale_x_date(name = "Year", expand = c(0.015, 0), date_labels="%Y", date_breaks = "1 year", limits = c(as.Date("2002-01-01"), as.Date("2019-01-01"))) +
#   scale_colour_manual(values = c("Expected Inflation" = "green", "Perceived Inflation" = "blue", "HICP" = "black"), breaks = c("Expected Inflation", "Perceived Inflation", "HICP")) +
#   scale_linetype_manual(values = c("Expected Inflation" = "longdash", "Perceived Inflation" = "longdash", "HICP" = "solid"), breaks = c("Expected Inflation", "Perceived Inflation", "HICP")) +
#   theme_classic() +
#   theme(axis.text.y.left = element_text(color = "black"),
#         axis.text.y.right = element_text(color = "black"),
#         axis.title.y = element_text(color = "black", size = 18),
#         axis.title.x = element_text(color = "black", size = 18),
#         axis.text.x = element_text(angle = 45, vjust = 0.5, size = 13),
#         panel.grid.minor = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "bottom",
#         legend.direction = "horizontal",
#         legend.text = element_text(size = 18)) +
#   guides(colour = guide_legend(override.aes = list(size = 6, linetype = 1.5))) +
#   labs(y.sec = "Inflation Rate (%)",
#        colour = NULL,
#        linetype = NULL)
# 
# print(p)
# 
# ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/Household_Inf_Exp.png", p, width = 10, height = 6)

###

#data = data[22:dim(data)[1],]

###

# specific_time_euro_intro <- as.Date("2002-01-03")
# specific_value_euro_intro <- -7
# label_euro_intro <- "Introduction of Euro"
# label_color_euro_intro <- "red"
# arrow_y_start_euro_intro <- data_ECB[data_ECB$time == specific_time_euro_intro, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_eu_enlargement <- as.Date("2004-05-06")
# specific_value_eu_enlargement <- 7
# label_eu_enlargement <- "EU Enlargement"
# label_color_eu_enlargement <- "red"
# arrow_y_start_eu_enlargement <- data_ECB[data_ECB$time == specific_time_eu_enlargement, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_ns <- as.Date("2007-09-06")
# #specific_time_lb <- as.Date("2008-09-30")
# specific_value_ns <- 9
# label_ns <- "First Non-Standard Measures"
# label_color_ns <- "red"
# arrow_y_start_ns <- data_ECB[data_ECB$time == specific_time_ns, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_lb <- as.Date("2008-09-04")
# specific_value_lb <- 9
# label_lb <- "Fall of Lehman Brothers"
# label_color_lb <- "red"
# arrow_y_start_lb <- data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Inc.
# 
# specific_time_lb <- as.Date("2008-10-02")
# #specific_time_lb <- as.Date("2008-09-30")
# specific_value_lb <- -9
# label_lb <- "Interest Rate Cuts"
# #label_lb <- "Fall of Lehman Brothers"
# label_color_lb <- "red"
# arrow_y_start_lb <- -data_ECB[data_ECB$time == specific_time_lb, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_sm <- as.Date("2010-03-04")
# specific_value_sm<- -6.25
# label_sm <- "SMP"
# label_color_sm <- "red"
# arrow_y_start_sm <- -data_ECB[data_ECB$time == specific_time_sm, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_lt <- as.Date("2011-12-08")
# specific_value_lt<- -5
# label_lt <- "TLTRO"
# label_color_lt <- "red"
# arrow_y_start_lt <- -data_ECB[data_ECB$time == specific_time_lt, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_wt <- as.Date("2012-08-02")
# specific_value_wt <- -8
# label_wt <- "Whatever it Takes"
# label_color_wt <- "red"
# arrow_y_start_wt <- -data_ECB[data_ECB$time == specific_time_wt, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_nr <- as.Date("2014-06-05")
# specific_value_nr <- -12
# label_nr <- "Negative Interest Rates"
# label_color_nr <- "red"
# arrow_y_start_nr <- -data_ECB[data_ECB$time == specific_time_nr, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_qe <- as.Date("2015-01-22")
# specific_value_qe <- -7
# label_qe <- "QE"
# label_color_qe <- "red"
# arrow_y_start_qe <- -data_ECB[data_ECB$time == specific_time_qe, ]$ECB.PC.Inflation.Dec.
# 
# specific_time_ta <- as.Date("2017-10-26")
# specific_value_ta <- 5
# label_ta <- "Tapering of QE"
# label_color_ta <- "red"
# arrow_y_start_ta <- data_ECB[data_ECB$time == specific_time_ta, ]$ECB.PC.Inflation.Inc.
# 
# ###
# 
# data$Eurozone.Inflation = data$German.Inflation.Year.on.Year
# 
# scaling_factor <- max(abs(data_ECB$ECB.PC.Inflation.Inc.), abs(data_ECB$ECB.PC.Inflation.Dec.)) / max(data$Eurozone.Inflation)
# 
# offset <- -1.5
# 
# text_offset <- 0.7
# 
# inverse_transform <- function(x) {
#   (x / scaling_factor) - offset
# }
# 
# max_inflation <- max((data$German.Inflation.Year.on.Year + offset) * scaling_factor)
# min_inflation <- min((data$German.Inflation.Year.on.Year + offset) * scaling_factor)
# 
# breaks_inflation <- seq(from = -4, to = 5, by = 1)
# breaks_frequency <- seq(from = -10, to = 10, by = 2.5)
# 
# data_first_part <- data_ECB[1:nrow(data_ECB), ]
# #data_second_part <- data_ECB[26:102, ]
# #data_third_part <- data_ECB[103:nrow(data_ECB), ]
# 
# p <- ggplot() + 
#   # First 25 elements with the original width
#   geom_col(data = data_first_part, aes(x = time, y = ECB.PC.Inflation.Inc.), 
#            fill = "black", color = "black", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   geom_col(data = data_first_part, aes(x = time, y = -ECB.PC.Inflation.Dec.), 
#            fill = "grey40", color = "grey40", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   
#   # Next 26 to 102 elements with a different width
#   geom_col(data = data_second_part, aes(x = time, y = ECB.PC.Inflation.Inc.), 
#            fill = "black", color = "black", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   geom_col(data = data_second_part, aes(x = time, y = -ECB.PC.Inflation.Dec.), 
#            fill = "grey40", color = "grey40", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   
#   # Elements after the 102nd with a different width
#   geom_col(data = data_third_part, aes(x = time, y = ECB.PC.Inflation.Inc.), 
#            fill = "black", color = "black", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   geom_col(data = data_third_part, aes(x = time, y = -ECB.PC.Inflation.Dec.), 
#            fill = "grey40", color = "grey40", size = 0.1, width = 40, show.legend = FALSE, position = "identity") +
#   
#   # Add the lines as before
#   geom_line(aes(x = time, y = (Eurozone.Inflation + offset) * scaling_factor, color = "Inflation"), 
#             linetype = "solid", size = 0.8, data = data) +
#   
#   geom_line(data = data_eu_for, aes(x = Date, y = (Next.year.forecast + offset) * scaling_factor, color = "Next Year Forecast"), 
#             linetype = "solid", size = 0.8) +
#   
#   scale_y_continuous(
#     name = "Share of Sentences in Press Conferences",
#     labels = function(x) abs(x),
#     breaks = breaks_frequency,
#     limits = c(-10, 11),
#     sec.axis = sec_axis(~inverse_transform(.), name = "Inflation", breaks = breaks_inflation), expand = c(0.075, 0)) +
#   
#   scale_color_manual(values = c("Inflation" = 'darkorange', "Next Year Forecast" = "green")) +
#   
#   scale_x_date(expand = c(0.015, 0), date_labels = "%Y", 
#                breaks = seq(as.Date("2002-01-01"), as.Date("2024-01-01"), by = "1 year"), 
#                name = "", limits = c(as.Date("2002-01-01"), as.Date("2024-01-01"))) +
#   
#   guides(color = guide_legend(title = "", override.aes = list(linetype = c("solid", "solid")))) +
#   
#   theme_classic() + 
#   theme(axis.text.y.left = element_text(color = "black", size = 20),
#         axis.text.y.right = element_text(color = "black", size = 20),
#         axis.title.y = element_text(color = "black", size = 13),
#         axis.text.x = element_text(angle = 45, vjust = 0.5, size = 20),
#         panel.grid.minor = element_blank(),
#         panel.grid.major = element_blank(),
#         legend.position = "none",
#         legend.text = element_text(size = 20), 
#         legend.justification = c(0, -1),
#         legend.key.size = unit(0.5, "cm")) +
#   
#   # Annotations 
#   annotate("text", x = as.Date("2004-03-01"), y = (specific_value_euro_intro - text_offset), label = label_euro_intro, color = label_color_euro_intro, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2004-05-01"), y = (specific_value_eu_enlargement + text_offset), label = label_eu_enlargement, color = label_color_eu_enlargement, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2005-08-30"), y = (specific_value_ns + text_offset), label = label_ns, color = label_color_ns, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2009-11-30"), y = (specific_value_sm - text_offset), label = label_sm, color = label_color_sm, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2011-07-31"), y = (specific_value_lt - text_offset), label = label_lt, color = label_color_lt, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2012-04-30"), y = (specific_value_wt - text_offset), label = label_wt, color = label_color_wt, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2015-06-30"), y = (specific_value_nr - text_offset), label = label_nr, color = label_color_nr, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2015-09-30"), y = (specific_value_qe - text_offset), label = label_qe, color = label_color_qe, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2017-05-30"), y = (specific_value_ta + text_offset), label = label_ta, color = label_color_ta, angle = 0, vjust = 1, size = 6.5) +
#   annotate("text", x = as.Date("2006-08-28"), y = (specific_value_lb - text_offset), label = label_lb, color = label_color_lb, angle = 0, vjust = 1, size = 6.5) +
#    
#   # Existing segments
#   annotate("segment", x = as.Date("2004-03-01"), xend = specific_time_euro_intro, y = specific_value_euro_intro, yend = arrow_y_start_euro_intro, 
#            colour = label_color_euro_intro, size = 0.5) +
#   annotate("segment", x = as.Date("2005-08-30"), xend = specific_time_ns, y = specific_value_ns, yend = arrow_y_start_ns, 
#            colour = label_color_ns, size = 0.5) +
#   annotate("segment", x = as.Date("2004-05-01"), xend = specific_time_eu_enlargement, y = specific_value_eu_enlargement, yend = arrow_y_start_eu_enlargement, 
#            colour = label_color_eu_enlargement, size = 0.5) +
#   annotate("segment", x = as.Date("2009-11-30"), xend = specific_time_sm, y = specific_value_sm, yend = arrow_y_start_sm, 
#            colour = label_color_sm, size = 0.5) +
#   annotate("segment", x = as.Date("2011-07-31"), xend = specific_time_lt, y = specific_value_lt, yend = arrow_y_start_lt, 
#            colour = label_color_lt, size = 0.5) + 
#   annotate("segment", x = as.Date("2006-08-28"), xend = specific_time_lb, y = specific_value_lb, yend = arrow_y_start_lb, 
#            colour = label_color_lb, size = 0.5) + 
#   annotate("segment", x = as.Date("2012-04-30"), xend = specific_time_wt, y = specific_value_wt, yend = arrow_y_start_wt, 
#            colour = label_color_wt, size = 0.5) + 
#   annotate("segment", x = as.Date("2015-06-30"), xend = specific_time_nr, y = specific_value_nr, yend = arrow_y_start_nr, 
#            colour = label_color_nr, size = 0.5) + 
#   annotate("segment", x = as.Date("2015-09-30"), xend = specific_time_qe, y = specific_value_qe, yend = arrow_y_start_qe, 
#            colour = label_color_qe, size = 0.5) +
#   annotate("segment", x = as.Date("2017-05-30"), xend = specific_time_ta, y = specific_value_ta, yend = arrow_y_start_ta, 
#            colour = label_color_ta, size = 0.5) 
#     
# print(p)
# 
# ggsave("D:/Studium/PhD/Github/Single-Author/First Draw/Single Author Text/ECB_INF.png", p, width = 10, height = 6, dpi = 400)
