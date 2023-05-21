# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed.xlsx')
#data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')
data = data.frame(data)
#data = data[24:dim(data)[1],]
#data = data[9:dim(data)[1],]

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))
#years = as.Date(strptime(c(2002:2019), '%Y'))
years = as.Date(strptime(c(2003:2019), '%Y'))

###############################################
# Plots Paper
###############################################

recessions <- data.frame(
  start = as.Date(c("2003-01-01",  "2008-03-01", "2011-07-01", "2017-12-01")),
  end = as.Date(c("2005-02-28", "2009-06-30", "2015-05-30","2019-01-01")) # "2020-05-30"
)

##### Inflation Count

coeff = max(data$News.Inflation.Count)/max(data$German.Inflation.Year.on.Year.Harmonised)*0.8

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.5) +
  #geom_line(aes(y = News.Inflation.Count.role/coeff), colour="blue", linetype = 1) +
  geom_bar(aes(y = News.Inflation.Count.role / coeff), stat = "identity", fill = "blue", width = 10) +
  geom_line(aes(y = German.Inflation.Year.on.Year.Harmonised), colour="red", linetype = 2, size = 0.75) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Germany HCPI", sec.axis = sec_axis(~.*coeff*1000, name = "Inflation News Coverage*10^(-3)")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2003-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### INI

coeff = max(data$News.Inflation.Index.role*-1)/max(data$German.Inflation.Year.on.Year)

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.5) +
  geom_line(aes(y = News.Inflation.Index.role*-1/coeff + 0.000/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Germany HCPI", sec.axis = sec_axis(~.*coeff - 0.000*coeff, name = "Inflation News Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### Inflation Direction

coeff = max(data$News.Inflation.Direction.Index.role)/max(data$German.Inflation.Year.on.Year)

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Direction.Index.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Germany HCPI", sec.axis = sec_axis(~.*coeff, name = "News Direction Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### Inflation Sentiment

coeff = max(data$News.Inflation.Sentiment.Index.role*-1)/max(data$German.Inflation.Year.on.Year)*0.5

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Sentiment.Index.role*-1/coeff-0.10/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Germany HCPI", sec.axis = sec_axis(~.*coeff + 0.1, name = "News Sentiment Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###################################################################################

# Ini und ECB Index

coeff = max(data$News.Inflation.Index.role*-1)/max(data$ECB.Inflation.Index.role)

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.5) +
  geom_line(aes(y = News.Inflation.Index.role*-1/coeff - 0.00/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = ECB.Inflation.Index.role), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "ECB Inflation Index", sec.axis = sec_axis(~.*coeff, name = "News Inflation Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###########################################################################

cor(data$News.Inflation.Direction.Index, data$German.Inflation.Year.on.Year, method = c("pearson"))
cor(data$News.Inflation.Sentiment.Index, data$German.Inflation.Year.on.Year, method = c("pearson"))
cor(data$News.Inflation.Index*-1, data$German.Inflation.Year.on.Year, method = c("pearson"))

cor(data$ECB.Inflation.Index, data$German.Inflation.Year.on.Year, method = c("pearson"))
cor(data$ECB.Inflation.Index, data$Eurozone.Inflation, method = c("pearson"))

############################################################################

##### ECB Inflation Index

coeff = max(data$ECB.Inflation.Index.role)/max(data$Eurozone.Inflation) 

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = (ECB.Inflation.Index.role)/coeff+0.00/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = Eurozone.Inflation), colour="red", linetype = 2) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="darkorange", linetype = 2) +
  scale_y_continuous(name = "Inflation", sec.axis = sec_axis(~.*coeff+0.00, name = "ECB Inflation Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$ECB.Inflation.Index.role)/max(data$Eurozone.Inflation) 

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = (ECB.Inflation.Index.role)/coeff+0.00/coeff, color="ECB Inflation Index"), linetype = 1) +
  geom_line(aes(y = Eurozone.Inflation, color="Eurozone Inflation"), linetype = 2) +
  geom_line(aes(y = German.Inflation.Year.on.Year, color="German Inflation"), linetype = 2) +
  scale_y_continuous(name = "Inflation", sec.axis = sec_axis(~.*coeff+0.00, name = "ECB Inflation Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values=c("ECB Inflation Index"="blue", "Eurozone Inflation"="red", "German Inflation"="darkorange"),
                     name="Legend",
                     labels=c("ECB Inflation Index", "Eurozone Inflation", "German Inflation")) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE, title = NULL))

#coeff = max(data$ECB.Inflation.Index.role)/max(data$News.Inflation.Index)*0.5 

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = scale(ECB.Inflation.Index.role)), colour="blue", linetype = 1) +
  geom_line(aes(y = scale(News.Inflation.Index.role*-1)), colour="red", linetype = 2) +
  scale_y_continuous(name = "Inflation", sec.axis = sec_axis(~.*coeff+0.00, name = "ECB Inflation Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### ECB Lambda

coeff = max(data$News.ECB.Count.role)/max(data$German.Inflation.Year.on.Year)

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_bar(aes(y = News.ECB.Count.role/coeff+0.0/coeff), stat = "identity", fill = "blue", width = 10) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Germany HCPI", sec.axis = sec_axis(~.*coeff-0.0, name = "ECB Lambda")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

########################################################################

coeff = max(data$German.Household.Inflation.Expectations.EU.Median, na.rm = TRUE)/max(data$German.Household.Inflation.Expectations.Stm)

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  geom_line(aes(y = German.Household.Inflation.Expectations.Role, colour = "Role", linetype = "Role")) +
  geom_line(aes(y = German.Household.Inflation.Expectations.Berk.5, colour = "Berk.5", linetype = "Berk.5")) +
  geom_line(aes(y = German.Household.Inflation.Expectations.Berk.1, colour = "Berk.1", linetype = "Berk.1")) +
  geom_line(aes(y = German.Household.Inflation.Expectations.Stm, colour = "Stm", linetype = "Stm")) +
  geom_line(aes(y = German.Household.Inflation.Expectations.EU.Median/coeff, colour = "EU Median (Scaled Stm)", linetype = "EU Median (Scaled Stm)")) +
  geom_line(aes(y = German.Inflation.Year.on.Year, colour = "Germany Inflation", linetype = "Germany Inflation"), linewidth = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("Role" = "red", "ECB" = "blue", "Berk.5" = "black", "Berk.1" = "darkred","Stm" = "darkgreen", "EU Median (Scaled Stm)" = "violet", "Germany Inflation" = "darkorange")) +
  scale_linetype_manual(values = c("Role" = 1, "ECB" = 1, "Berk.5" = 1, "Berk.1" = 1, "Stm" = 1, "EU Median (Scaled Stm)" = 1, "Germany Inflation" = 3)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))

########################################################################

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  #geom_line(aes(y = Germany.Inflation.Professionell.Forecasts.GD, colour = "GD", linetype = "GD")) +
  #geom_line(aes(y = Germany.Inflation.Professionell.Forecasts.RWI, colour = "RWI", linetype = "RWI")) +
  #geom_line(aes(y = Eurozone.Inflation.Professionell.Forecasts, colour = "ECB Survey", linetype = "ECB Survey")) +
  geom_line(aes(y = Reuter.Poll.Forecast, colour = "Reuters Poll", linetype = "Reuters Poll")) +
  geom_line(aes(y = German.Inflation.Year.on.Year.Harmonised, colour = "Germany Inflation", linetype = "Germany Inflation"), linewidth = 1) +
  geom_line(aes(y = German.Household.Inflation.Expectations.Stm, colour = "Stm", linetype = "Stm"), linewidth = 1) +
 #geom_line(aes(y = Eurozone.Inflation, colour = "Eurozone Inflation", linetype = "Eurozone Inflation"), linewidth = 1) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values = c("GD" = "red", "RWI" = "blue", "ECB Survey" = "black", "Germany Inflation" = "darkorange", "Stm" = "darkred", "Eurozone Inflation" = "green", 'Reuters Poll' = 'darkgreen')) +
  scale_linetype_manual(values = c("GD" = 1, "RWI" = 1, "ECB Survey" = 1, "Germany Inflation" = 3, "Stm" = 3,  "Eurozone Inflation" = 2, 'Reuters Poll' = 1)) +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE, title = NULL), linetype = guide_legend(nrow = 2, byrow = TRUE, title = NULL))

##### Residuals - Reuter

coeff_1 = max(data$ECB_News_res_inf_1)/max(data$ECB_News_res_inf_0_Reuter)
coeff_2 = max(data$ECB_News_res_inf_2_Reuter)/max(data$ECB_News_res_inf_0_Reuter)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff_1, color="ECB_News"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_0_Reuter.role, color="ECB_Count"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_2_Reuter.role/coeff_2, color="News_Forecast"), linetype = 1) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Media Bias")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values=c("ECB_News"="blue", "ECB_Count"="red", "News_Forecast"="green"),
                     name="Legend",
                     labels=c("ECB_Count", "ECB_News", "News_Forecast")) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE, title = NULL))

####

coeff_1 = max(data$ECB_News_res_inf_1)/max(data$ECB_News_res_inf_0_eu)
coeff_2 = max(data$ECB_News_res_inf_2_eu)/max(data$ECB_News_res_inf_0_eu)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff_1, color="ECB_News"), linetype = 1) +
  #geom_line(aes(y = ECB_News_res_inf_0_eu.role, color="ECB_Count"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_2_eu.role/coeff_2, color="News_Forecast"), linetype = 1) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Media Bias")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values=c("ECB_News"="blue", "News_Forecast"="green"),
                     name="Legend",
                     labels=c("ECB_News", "News_Forecast")) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE, title = NULL))

##### Residuals - GD

coeff_1 = max(data$ECB_News_res_inf_1)/max(data$ECB_News_res_inf_0_GD)
coeff_2 = max(data$ECB_News_res_inf_2_GD)/max(data$ECB_News_res_inf_0_GD)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff_1, color="ECB_News"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_0_GD.role, color="ECB_Count"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_2_GD.role/coeff_2, color="News_Forecast"), linetype = 1) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values=c("ECB_News"="blue", "ECB_Count"="red", "News_Forecast"="green"),
                     name="Legend",
                     labels=c("ECB_News", "ECB_Count", "News_Forecast")) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        legend.position = c(0.98, 0.98),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.box.background = element_rect(color = "white", size = 0.5, linetype = "solid"),
        legend.text = element_text(size = 10)) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE, title = NULL))

##### Residuals - RWI

coeff_1 = max(data$ECB_News_res_inf_1)/max(ECB_News_res_inf_0_RWI)
coeff_2 = max(data$ECB_News_res_inf_2_RWI)/max(ECB_News_res_inf_0_RWI)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff_1, color="ECB_News"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_0_RWI.role, color="ECB_Count"), linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_2_RWI.role/coeff_2, color="News_Forecast"), linetype = 1) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  scale_color_manual(values=c("ECB_News"="blue", "ECB_Count"="red", "News_Forecast"="green"),
                     name="Legend",
                     labels=c("ECB_News", "ECB_Count", "News_Forecast")) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank())

############################################



###########################################

ggplot(data, aes(x = time)) + 
  labs(y = "Inflation Expectation") +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.GD.role, colour = "Stm - GD", linetype = "Stm - GD")) +
  #geom_line(aes(y = German.Absolute.Expectations.Gap.Stm.RWI.role, colour = "Stm - RWI", linetype = "Stm - RWI")) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role, colour = "Stm - ECB", linetype = "Stm - ECB")) +
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

#############################################
#############################################
#############################################

### Reuter Expectations Gap

coeff = max(data$News.ECB.Count)/max(data$German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = News.ECB.Count.role/coeff+0.0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "News ECB Count")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$News.ECB.Count)/max(data$German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter)*0.3

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = News.ECB.Count.role/coeff-0.03/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "News ECB Count")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = 1

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter/coeff-0.00/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter), colour="red", linetype = 2) +
  scale_y_continuous(name = "Relative Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "Absolute Expectation Gap")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 


##################

coeff = max(data$ECB_News_res_inf_0_eu)/max(data$German.ECB.Absolute.Expectations.Gap.Stm)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_0_eu.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap (EU - Stm)", sec.axis = sec_axis(~.*coeff-0.0, name = "News Coverage Residuals")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###################

coeff = max(data$ECB_News_res_inf_1.role)/max(data$German.ECB.Absolute.Expectations.Gap.Stm.role)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap (EU - Stm)", sec.axis = sec_axis(~.*coeff-0.0, name = "News Index Residuals")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

data = data[30:dim(data)[1],]

coeff = max(data$ECB_News_res_inf_1.role)/max(data$German.ECB.Absolute.Expectations.Gap.Role.role)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap (EU - Stm)", sec.axis = sec_axis(~.*coeff-0.0, name = "News Index Residuals")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###################

coeff = max(data$ECB_News_res_inf_2_eu.role)/max(data$German.ECB.Absolute.Expectations.Gap.Stm.role)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_2_eu.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap (EU - Stm)", sec.axis = sec_axis(~.*coeff-0.0, name = "News Index Residuals")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

#################################

coeff = max(data$ECB_News_res_inf_3_eu)/max(data$German.ECB.Absolute.Expectations.Gap.Stm)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_3_eu.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "News ECB Count")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

#################################

coeff = max(data$ECB_News_res_inf_4_eu)/max(data$German.ECB.Absolute.Expectations.Gap.Stm)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_4_eu.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "News ECB Count")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 


#####################

coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Stm)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Stm.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.0, name = "News ECB Count")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

########################################################
########################################################
########################################################

#coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Berk)*2
coeff = 1

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_2_RWI.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = ECB_News_res_inf_2_GD.role), colour="red", linetype = 2) +
  geom_line(aes(y = ECB_News_res_inf_2_eu.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 


##### Absolute Inflation Expectations - Residuals_1

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0

coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Berk)*2

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Berk.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Berk)*2

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Berk.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Absolute.Expectations.Gap.Role)*1.2

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Role)*2

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.05/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "ECB Role Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###

coeff = max(data$ECB_News_res_inf_1)/max(data$German.ECB.Absolute.Expectations.Gap.Role)*2

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.05/coeff), colour="blue", linetype = 1, size = 0.9) +
  geom_line(aes(y = German.ECB.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2, size = 0.9) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Role.role), colour="darkgreen", linetype = 3, size = 0.9) +
  geom_line(aes(y = German.Absolute.Real.Inflation.Expectations.Gap.Role.role), colour="black", linetype = 4, size = 0.9) +
  scale_y_continuous(name = "ECB Role Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###

data$German.Absolute.Expectations.Gap[is.na(data$German.Absolute.Expectations.Gap)] <- 0

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Absolute.Expectations.Gap)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##

data$German.Absolute.Expectations.Gap.Role[is.na(data$German.Absolute.Expectations.Gap.Role)] <- 0

coeff = max(data$ECB_News_res_inf_1)/max(data$German.Absolute.Expectations.Gap.Role)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_1.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### Absolute Inflation Expectations - Residuals_2

data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0

coeff = max(data$ECB_News_res_inf_2)/max(data$German.Absolute.Expectations.Gap.Berk)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_2.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Berk.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##

data$German.Absolute.Expectations.Gap.Role[is.na(data$German.Absolute.Expectations.Gap.Role)] <- 0

coeff = max(data$ECB_News_res_inf_2)/max(data$German.Absolute.Expectations.Gap.Role)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_2.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Role.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##### Absolute Inflation Expectations - Residuals_3

data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0

coeff = max(data$ECB_News_res_inf_2)/max(data$German.Absolute.Expectations.Gap.Berk)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf_3.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.Berk.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.015, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

###########################################################################

cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$ECB.Inflation.Index, method = c("pearson"))

cor(data1$German.Household.Inflation.Expectations, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$German.Household.Inflation.Expectations, data1$ECB.Inflation.Index, method = c("pearson"))

cor(data[100:(dim(data)[1]-20),]$German.Absolute.Expectations.Gap.Berk, data[100:(dim(data)[1]-20),]$ECB_News_res_inf_1, method = c("pearson"))

#### Sonstige Plots

coeff = max(data1$ECB.Economic.Index)/max(data1$Eurozone.Industrial.Production)*0.5

ggplot(data1, aes(x = time)) + 
  geom_line(aes(y = ECB.Economic.Index.role/coeff-(0.03/coeff)), colour="blue", linetype = 1) +
  geom_line(aes(y = Eurozone.Industrial.Production), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Eurozone Industrial Production", sec.axis = sec_axis(~.*coeff+0.03, name = "ECB Economic Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data$ECB.Monetary.Index)/max(data$ECB.DFR)

ggplot(data, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = (ECB.Monetary.Index.role*-1)/coeff+(0.2/coeff)), colour="blue", linetype = 1) +
  geom_line(aes(y = ECB.DFR), colour="red", linetype = 2) +
  scale_y_continuous(name = "ECB Deposit Facility", sec.axis = sec_axis(~.*coeff-(0.2), name = "ECB Monetary Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

data1$German.Relative.Expectations.Gap[is.na(data1$German.Relative.Expectations.Gap)] <- 0

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[step:dim(data1)[1],], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff+0.025/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Expectations.Gap.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Relative Expectation Gap", sec.axis = sec_axis(~.*coeff-0.025, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

############################################

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[step:dim(data1)[1],], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff-0.06/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Expectations.Gap.role*-1), colour="red", linetype = 2) +
  scale_y_continuous(name = "Relative Expectation Gap", sec.axis = sec_axis(~.*coeff-0.025, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

############################################

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[step:(dim(data1)[1]-60),], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff+0.005/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Expectations.Gap.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Relative Expectation Gap", sec.axis = sec_axis(~.*coeff-0.005, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[(step+110):(dim(data1)[1]),], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff+0.025/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Relative.Expectations.Gap.role*-1), colour="red", linetype = 2) +
  scale_y_continuous(name = "Relative Expectation Gap", sec.axis = sec_axis(~.*coeff-0.025, name = "Residuals from ECB Index on News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 