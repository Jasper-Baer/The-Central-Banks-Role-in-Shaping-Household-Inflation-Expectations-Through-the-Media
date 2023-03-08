# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/regression_data_monthly.xlsx')
data = data.frame(data)

data1 = data %>% select(German.Absolute.Expectations.Gap,German.Relative.Expectations.Gap,
                        ECB.DFR ,Eurozone.Industrial.Production, German.Industrial.Production, News.Inflation.Index, News.Inflation.Count, 
                        ECB.Inflation.Index, ECB.Monetary.Index, ECB.Economic.Index, 
                        Eurozone.Inflation, German.Inflation.Year.on.Year, German.Household.Inflation.Expectations,
                        Eurozone.Inflation.Professionell.Forecasts, German.Household.Inflation.Expectations.Balanced,
                        News.Inflation.Sentiment.Index, News.Inflation.Direction.Index)
#time = data %>% select(FRED.Graph.Observations)

#data1$ECB.DFR = c(0,diff(data1$ECB.DFR))

lag_order = 12
nvar = dim(data1)[2]

data_lags = data.frame(matrix(nrow = (dim(data1) - lag_order), ncol = (lag_order*nvar)))

#fit = lm(Relative.Expectations.Gap ~ News.Inflation.Index + News.Inflation.Count + ECB.Inflation.Index, data1)
#coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=FALSE, adjust=TRUE, verbose=TRUE))

lag_names = c()

for (l in 1:lag_order)
{
  data_lags[,((l-1)*nvar+1):(l*nvar)] = data1[(l):(dim(data1)[1]-lag_order + l -1),]
  col_names = names(data1[(l):(dim(data1)[1]-lag_order + l -1),])
  lag_names = c(lag_names, paste(col_names, gsub(" ", "", paste("Lag",as.character(l), "")), sep="."))
}

names(data_lags) = lag_names
time = data[,1]
names(time) = "Date"
data1 = cbind(data1, time)
data1 = data1[(lag_order+1):dim(data1)[1],]
data1 = cbind(data1, data_lags)
#data1 = data1[1:95,]
data1 = data1[48:dim(data1)[1],]
step = 3

#time = time[((lag_order+1):(dim(data1)[1]+lag_order)),]

#######################################################
# Differences
#######################################################

normalized_news_inflation_index = (data1$News.Inflation.Index - mean(data1$News.Inflation.Index))/sd(data1$News.Inflation.Index)
normalized_ECB_inflation_index = ((data1$ECB.Inflation.Index - mean(data1$ECB.Inflation.Index))/sd(data1$ECB.Inflation.Index))*-1

diff_ECB_News_inf_inf = normalized_news_inflation_index - normalized_ECB_inflation_index

normalized_Euro_inflation_prof = (data1$Eurozone.Inflation.Professionell.Forecasts - mean(data1$Eurozone.Inflation.Professionell.Forecasts))/sd(data1$Eurozone.Inflation.Professionell.Forecasts)
normalized_german_inflation_balanced = ((data1$German.Household.Inflation.Expectations.Balanced - mean(data1$German.Household.Inflation.Expectations.Balanced))/sd(data1$German.Household.Inflation.Expectations.Balanced))

diff_inflation_exp = normalized_Euro_inflation_prof - normalized_german_inflation_balanced

########################################################

########################################################
# replication of Lamla (2014) (- Teuro), slightly different time frame and Only one news index
########################################################

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Index + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

## same for relative ##

fit = lm(German.Relative.Expectations.Gap ~ News.Inflation.Count, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ News.Inflation.Count + German.Relative.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ News.Inflation.Count + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ News.Inflation.Index + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################
# Residuals - ECB and News Index
############################################

fit = lm(ECB.Inflation.Index ~ News.Inflation.Index + News.Inflation.Count, data1)
ECB_News_res_inf = fit$residuals

fit = lm(News.Inflation.Index ~ ECB.Inflation.Index, data1)
News_ECB_res_inf = fit$residuals

data1 = cbind(data1, ECB_News_res_inf)

fit = lm(German.Relative.Expectations.Gap ~ News.Inflation.Index + ECB_News_res_inf + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

for (col in colnames(data1)){
  
  name_role = paste(col, 'role', sep = '.')
  var_role = rollmean(data1[,col], step)
  var_role =c(rep(NA, step - 1), var_role)
  
  data1[,name_role] = var_role
}

data1 = data1[step:dim(data1)[1],]

#ECB_News_res_inf_roll =  rollmean(ECB_News_res_inf, step)
#ECB_News_res_inf_roll = c(rep(NA, step - 1), ECB_News_res_inf_roll)

#News_ECB_res_inf_roll =  rollmean(News_ECB_res_inf, step)
#News_ECB_res_inf_roll = c(rep(NA, step - 1), News_ECB_res_inf_roll)

#data1 = cbind(data1, ECB_News_res_inf)
#data1 = cbind(data1, ECB_News_res_inf_roll)

#data1 = cbind(data1, News_ECB_res_inf)
#data1 = cbind(data1, News_ECB_res_inf_roll)

fit = lm(ECB.Monetary.Index ~ News.Inflation.Index, data1)
ECB_News_res_mon = fit$residuals

fit = lm(ECB.Economic.Index ~ News.Inflation.Index, data1)
ECB_News_res_ec = fit$residuals

fit = lm(German.Inflation.Year.on.Year ~ News.Inflation.Index, data1)
German_News_res_inf = fit$residuals

data1$time = as.Date(strptime(data1$time, "%Y-%m-%d"))
years = as.Date(strptime(c(2005:2019), '%Y'))

############################################
# Regressions for Paper
############################################

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB.Inflation.Index.Lag1 + News.Inflation.Index.Lag1 + News.Inflation.Count.Lag1 + German.Inflation.Year.on.Year.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

###############################################
# Plots Paper
###############################################

coeff = max(data1$News.Inflation.Count)/max(data1$German.Inflation.Year.on.Year)

ggplot(data1, aes(x = time)) + 
  geom_line(aes(y = News.Inflation.Count.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff*1000, name = "Inflation News Coverage*10^(-3)")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
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
  geom_line(aes(y = News.Inflation.Index.role/coeff*-1), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff, name = "Inflation News Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

coeff = max(data1$News.Inflation.Direction.Index)/max(data1$German.Inflation.Year.on.Year)

ggplot(data1, aes(x = time)) + 
  geom_line(aes(y = News.Inflation.Direction.Index.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff, name = "News Direction Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
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
  geom_line(aes(y = News.Inflation.Sentiment.Index.role/coeff+0.1/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Inflation.Year.on.Year), colour="red", linetype = 2) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "German Inflation", sec.axis = sec_axis(~.*coeff-0.1, name = "News Sentiment Index")) +
  scale_x_date(date_labels="%Y", breaks = unique(years), name = "") +
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

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Absolute.Expectations.Gap)

ggplot(data1[step:dim(data1)[1],], aes(x = time)) + 
  geom_hline(yintercept = 0) + 
  geom_line(aes(y = ECB_News_res_inf.role/coeff+0.025/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = German.Absolute.Expectations.Gap.role), colour="red", linetype = 2) +
  scale_y_continuous(name = "Absolute Expectation Gap", sec.axis = sec_axis(~.*coeff-0.025, name = "Residuals from ECB Index on News Index")) +
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

ggplot(data1[step:dim(data1)[1],], aes(x = time)) + 
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

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[step:(dim(data1)[1]-60),], aes(x = time)) + 
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

coeff = max(data1$ECB_News_res_inf)/max(data1$German.Relative.Expectations.Gap)

ggplot(data1[(step+110):(dim(data1)[1]),], aes(x = time)) + 
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

###########################################################################

cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$Eurozone.Inflation.Professionell.Forecasts, data1$ECB.Inflation.Index, method = c("pearson"))

cor(data1$German.Household.Inflation.Expectations, data1$News.Inflation.Index*-1, method = c("pearson"))
cor(data1$German.Household.Inflation.Expectations, data1$ECB.Inflation.Index, method = c("pearson"))

################################################

# Plots Paper (old)

step = 3


###############################################################

############ Alternative: Differences between normalized ECB and News Index ###########

###############################################

# Plots for Analyzation

# ECB Inflation Index dipps to soon in 2014?

plot(data1$time[3:length(data1$time)], rollmean(data1$ECB.Inflation.Index, k =3), type = 'l', col = 'red', xlab = "Year")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(data1$News.Inflation.Index*-1, k = 3), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("ECB Inflation Index", "News Inflation Index"),
       col=c("red", "green"), lty=1, cex=0.8)

##############################################

###############################################
# Regression between NLP-Indizes and corresponding macro variables
###############################################

fit = lm(German.Inflation.Year.on.Year ~ News.Inflation.Index + ECB.Monetary.Index + ECB.Economic.Index + ECB.Inflation.Index + News.Inflation.Count + German.Industrial.Production + ECB.DFR + ECB.DFR.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

##############################################
# Test Regression
#############################################

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf.Lag1 + News.Inflation.Index.Lag1 + News.Inflation.Count.Lag1 + German.Inflation.Year.on.Year.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + News.Inflation.Index + News.Inflation.Index.Lag12 + News.Inflation.Index.Lag6 + News.Inflation.Count + German.Inflation.Year.on.Year.Lag1 + German.Inflation.Year.on.Year.Lag12 + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Industrial.Production + Eurozone.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + News.Inflation.Index + News.Inflation.Index.Lag12 + News.Inflation.Index.Lag6 + News.Inflation.Count + News.Inflation.Count.Lag6 + News.Inflation.Count.Lag12 + German.Inflation.Year.on.Year.Lag1 + German.Inflation.Year.on.Year.Lag12 + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Industrial.Production + Eurozone.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################
# Significant Results
#############################################
# Daten in zwei Teile ? (Nach und vor Kommunikationsänderung)
##
# Use Inflation Surprises as Variable
# Use Monetary Surprises as Variable

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + News.Inflation.Index + News.Inflation.Index.Lag12 + News.Inflation.Count + German.Inflation.Year.on.Year.Lag1 + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Industrial.Production + Eurozone.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + ECB.Inflation.Index + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + News.Inflation.Index + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(German.Relative.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + German.Industrial.Production.Lag1 + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ ECB.Monetary.Index + News.Inflation.Index + News.Inflation.Count + German.Industrial.Production.Lag1 + German.Relative.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(German.Relative.Expectations.Gap ~ ECB_News_res_inf + ECB.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + German.Relative.Expectations.Gap.Lag1 + German.Industrial.Production.Lag1 , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(Absolute.Expectations.Gap ~  abs(ECB_News_res_inf) + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  ECB_News_res_inf + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  abs(ECB_News_res_inf) +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(Absolute.Expectations.Gap ~  ECB_News_res_ec +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~  abs(ECB_News_res_ec) + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  ECB_News_res_ec + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  abs(ECB_News_res_ec) +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

##############################################


fit = lm(Absolute.Expectations.Gap ~ ECB.Inflation.Index + ECB_News_res_inf + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))


fit = lm(News.Inflation.Index ~ ECB.Inflation.Index + ECB.Monetary.Index, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))


fit = lm(Absolute.Expectations.Gap ~  ECB_News_res_mon +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~  abs(ECB_News_res_mon) + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  ECB_News_res_mon + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  abs(ECB_News_res_mon) +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

##############################################

fit = lm(Absolute.Expectations.Gap ~  diff_ECB_News_inf_inf + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  diff_ECB_News_inf_inf + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~  diff_ECB_News_inf_ec + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  diff_ECB_News_inf_ec + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~  diff_ECB_News_inf_mon + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Relative.Expectations.Gap ~  diff_ECB_News_inf_mon + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1 + German.Industrial.Production.Lag1 , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################

fit = lm(Relative.Expectations.Gap ~  ECB_News_res + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))