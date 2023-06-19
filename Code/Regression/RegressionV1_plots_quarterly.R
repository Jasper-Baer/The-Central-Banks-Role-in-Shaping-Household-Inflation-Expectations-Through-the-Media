library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed.xlsx')
data = read_excel('D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/Regession_data_quarterly_processed.xlsx')
data = data.frame(data)
#data = data[24:dim(data)[1],]
#data = data[9:dim(data)[1],]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data = data[11:dim(data)[1],]
data = data[23:dim(data)[1],]

#years = as.Date(strptime(c(2002:2019), '%Y'))
years = as.Date(strptime(c(2003:2019), '%Y'))

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB_News_res_inf_1/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Stm - GD" = "red", "Stm - RWI" = "blue", "Stm - ECB" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Stm - GD" = 1, "Stm - RWI" = 1, "Stm - ECB" = 1, "Germany Inflation" = 3)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 8)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))

####

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB_News_res_inf_1/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Stm - GD" = "red", "Stm - RWI" = "blue", "Stm - ECB" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Stm - GD" = 1, "Stm - RWI" = 1, "Stm - ECB" = 1, "Germany Inflation" = 3)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 8)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))

####

coeff = max(data$News.ECB.Count)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = News.ECB.Count/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Stm - GD" = "red", "Stm - RWI" = "blue", "Stm - ECB" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Stm - GD" = 1, "Stm - RWI" = 1, "Stm - ECB" = 1, "Germany Inflation" = 3)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 8)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))

####

coeff = max(data$News.ECB.Count)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = News.ECB.Count/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Stm - GD" = "red", "Stm - RWI" = "blue", "Stm - ECB" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Stm - GD" = 1, "Stm - RWI" = 1, "Stm - ECB" = 1, "Germany Inflation" = 3)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 8)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))
