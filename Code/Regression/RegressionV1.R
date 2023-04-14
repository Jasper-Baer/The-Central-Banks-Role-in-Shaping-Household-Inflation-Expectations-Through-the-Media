# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/Regession_data.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data1$time, "%Y-%m-%d"))
years = as.Date(strptime(c(2000:2019), '%Y'))

###############################################
# Plots Paper
###############################################

recessions <- data.frame(
  start = as.Date(c("2002-01-01",  "2008-03-01", "2011-07-01", "2017-12-01")),
  end = as.Date(c("2005-02-28", "2009-06-30", "2015-05-30","2019-01-01")) # "2020-05-30"
)

coeff = max(data1$News.Inflation.Count)/max(data1$German.Inflation.Year.on.Year)

ggplot(data1, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Count.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff*1000, name = "Inflation News Coverage*10^(-3)")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data1$time), by = "1 year"), name = "", limits = c(min(data1$time), max(data1$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data1$News.Inflation.Index)/max(data1$German.Inflation.Year.on.Year)*2.4

ggplot(data1, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Index.role/coeff*-1), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff, name = "Inflation News Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data1$time), by = "1 year"), name = "", limits = c(min(data1$time), max(data1$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

####################################################################

coeff = max(data1$News.Inflation.Direction.Index)/max(data1$German.Inflation.Year.on.Year)

ggplot(data1, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Direction.Index.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff, name = "News Direction Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data1$time), by = "1 year"), name = "", limits = c(min(data1$time), max(data1$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data1$News.Inflation.Sentiment.Index)/max(data1$German.Inflation.Year.on.Year)

ggplot(data1, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.3) +
  geom_line(aes(y = News.Inflation.Sentiment.Index.role/coeff+0.1/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff-0.1, name = "News Sentiment Index")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2000-01-01"), max(data1$time), by = "1 year"), name = "", limits = c(min(data1$time), max(data1$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

####################################################################

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

coeff = max(data1$ECB.Monetary.Index)/max(data1$ECB.DFR)

ggplot(data1, aes(x = time)) + 
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

coeff = max(data1$ECB.Monetary.Index)/max(data1$Eurozone.Inflation)*0.55

ggplot(data1, aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = (ECB.Inflation.Index.role)/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = Eurozone.Inflation), colour="red", linetype = 2) +
  scale_y_continuous(name = "Eurozone Inflation", sec.axis = sec_axis(~.*coeff, name = "ECB Inflation Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

########################################################################

coeff = 1

ggplot(data1, aes(x = time)) + 
  labs(y = "Inflation Expecation") +
  geom_line(aes(y = German.Household.Inflation.Expectations), colour="blue", linetype = 1) +
  geom_line(aes(y = Eurozone.Inflation.Professionell.Forecasts), colour="red", linetype = 2) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

##########################################################################

#data1$German.Absolute.Expectations.Gap[is.nan(data1$German.Absolute.Expectations.Gap)] <- 0
data1$German.Absolute.Expectations.Gap[is.na(data1$German.Absolute.Expectations.Gap)] <- 0

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Absolute.Expectations.Gap)

ggplot(data1[step:dim(data1)[1],], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff+0.015/coeff), colour="blue", linetype = 1) +
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

###########################################################################

cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$ECB.Inflation.Index, method = c("pearson"))

cor(data1$German.Household.Inflation.Expectations, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$German.Household.Inflation.Expectations, data1$ECB.Inflation.Index, method = c("pearson"))