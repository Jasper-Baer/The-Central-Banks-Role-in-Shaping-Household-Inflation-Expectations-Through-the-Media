library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_quarterly_processed.xlsx')
data = read_excel('D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/Regession_data_quarterly_processed.xlsx')
data = data.frame(data)
#data = data[24:dim(data)[1],]
#data = data[9:dim(data)[1],]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data = data[11:dim(data)[1],]
#data = data[23:dim(data)[1],]

#years = as.Date(strptime(c(2002:2019), '%Y'))
years = as.Date(strptime(c(2004:2019), '%Y'))

data = data[5:dim(data)[1],]

###

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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


###

coeff = max(data$ECB_News_diff_inf_1)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB_News_diff_inf_1.rolling/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

coeff = max(data$ECB_News_diff_inf_2)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB_News_diff_inf_2/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

coeff = max(data$News.Inflation.Index)/max(data$ECB.Inflation.Index)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB.Inflation.Index, colour = "ECB", linetype = "ECB")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = News.Inflation.Index/coeff, colour = "News", linetype = "News")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("ECB" = "red", "Stm - RWI" = "blue", "News" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("ECB" = 1, "Stm - RWI" = 1, "News" = 1, "Germany Inflation" = 3)) +
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

###

coeff = max(data$News.Inflation.Index)/max(data$ECB.Inflation.Index)
coeff = 1

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = scale(ECB.Inflation.Index), colour = "ECB", linetype = "ECB")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = scale(News.Inflation.Index/coeff), colour = "News", linetype = "News")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("ECB" = "red", "Stm - RWI" = "blue", "News" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("ECB" = 1, "Stm - RWI" = 1, "News" = 1, "Germany Inflation" = 3)) +
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


###

coeff = max(data$ECB_News_diff_inf_2)/max(data$ECB_News_diff_inf_1)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB_News_diff_inf_1, colour = "ECB diff 1", linetype = "ECB diff 1")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB_News_diff_inf_2/coeff, colour = "ECB diff 2", linetype = "ECB diff 2")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("ECB diff 1" = "red", "Stm - RWI" = "blue", "ECB diff 2" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("ECB diff 1" = 1, "Stm - RWI" = 1, "ECB diff 2" = 1, "Germany Inflation" = 3)) +
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

years = as.Date(strptime(c(2004:2019), '%Y'))

coeff = max(data$News.Inflation.Index)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real)*1000

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = (News.Inflation.Index*-1)/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter, colour = "Stm - GD", linetype = "Stm - GD")) +
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

coeff = max(data$News.ECB.Count)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real, colour = "Stm - GD", linetype = "Stm - GD")) +
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

###

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

###

coeff = max(data$ECB.Inflation.Index)/max(data$News.Inflation.Index*-1)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = News.Inflation.Index*-1, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = ECB.Inflation.Index/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

plot(data$News.Inflation.Index*-1, type = 'l')
plot(data$ECB.Inflation.Index, type = 'l')

###

coeff = max(data$German.Inflation.Year.on.Year)/max(data$News.Inflation.Index)*0.005

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = News.Inflation.Index*-1, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = German.Inflation.Year.on.Year/coeff+0.03, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

###

coeff = max(data$German.Inflation.Year.on.Year)/max(data$ECB.Inflation.Index)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB.Inflation.Index, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = German.Inflation.Year.on.Year/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

###

coeff = max(data$German.Inflation.Year.on.Year)/max(data$ECB.Inflation.Index)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB_News_res_inf_1, colour = "Media Bias", linetype = "Media Bias")) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter, colour = "Inflation Gap", linetype = "Inflation Gap")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), size = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Media Bias" = "red", "Inflation Gap" = "blue", "Stm - ECB" = "black", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Media Bias" = 1, "Inflation Gap" = 1, "Stm - ECB" = 1, "Germany Inflation" = 3)) +
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

###

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB_News_res_inf_1, colour = "Stm - GD", linetype = "Stm - GD")) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Real-3, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

###

coeff = max(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)/max(data$ECB_News_res_inf_2_Reuter)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = ECB_News_res_inf_2_Reuter, colour = "Stm - GD", linetype = "Stm - GD")) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Quant.Real/coeff, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  #geom_line(aes(y = German.Inflation.Year.on.Year/coeff, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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


ECB_News_res_inf_2_Reuter