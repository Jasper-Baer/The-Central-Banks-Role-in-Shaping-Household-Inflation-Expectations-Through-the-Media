# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/regression_data.xlsx')
data =  data.frame(data)

data1 = data %>% select(News.Inflation.Index, News.Inflation.Count, ECB.Inflation.Index, ECB.Monetary.Index, ECB.Economic.Index, Relative.Expectations.Gap, Eurozone.Inflation)
time = data %>% select(FRED.Graph.Observations)

lag_order = 2
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
data1 = data1[(lag_order+1):dim(data1)[1],]
data1 = cbind(data1, data_lags)

time = time[((lag_order+1):dim(data1)[1]),]

#ydata = data1 %>% select(Relative.Expectations.Gap)
#xdata = data1[, !names(data1) %in% c("Relative.Expectations.Gap")] 

#data1 = data1[1:32,]
#data1 = data1[38:dim(data1)[1],]

# OCED Definition for Recessions
time[4:13]
time[32:37]
time[45:52]
rec = c(4:13, 32:37, 45:52)
#data1 = data1[-rec,]
#data1 = data1[rec,]

fit = lm(Relative.Expectations.Gap ~ ., data1)

fit = lm(Relative.Expectations.Gap ~ News.Inflation.Index + News.Inflation.Count + ECB.Inflation.Index +  ECB.Monetary.Index + ECB.Economic.Index + Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1, data1)

coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=FALSE, adjust=TRUE, verbose=TRUE))
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))
coeftest(fit, vcov.=NeweyWest(fit, lag=1, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#####################################################################################

fit = lm(Relative.Expectations.Gap ~ ., data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=FALSE, adjust=TRUE, verbose=TRUE))

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/regression_data_monthly.xlsx')
data = data.frame(data)

data1 = data %>% select(German.Absolute.Expectations.Gap,German.Relative.Expectations.Gap,
                        ECB.DFR ,Eurozone.Industrial.Production, German.Industrial.Production, News.Inflation.Index, News.Inflation.Count, 
                        ECB.Inflation.Index, ECB.Monetary.Index, ECB.Economic.Index, 
                        Eurozone.Inflation, German.Inflation.Year.on.Year, German.Household.Inflation.Expectations,
                        Eurozone.Inflation.Professionell.Forecasts)
#time = data %>% select(FRED.Graph.Observations)

data1$ECB.DFR = c(0,diff(data1$ECB.DFR))

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

#time = time[((lag_order+1):(dim(data1)[1]+lag_order)),]

#######################################################
# Differences
#######################################################

normalized_news_inflation_index = (data1$News.Inflation.Index - mean(data1$News.Inflation.Index))/sd(data1$News.Inflation.Index)
normalized_ECB_inflation_index = ((data1$ECB.Inflation.Index - mean(data1$ECB.Inflation.Index))/sd(data1$ECB.Inflation.Index))*-1

diff_ECB_News_inf_inf = normalized_news_inflation_index - normalized_ECB_inflation_index

########################################################

########################################################
# replication of Lamla (2014) (- Teuro), slightly different time frame, European data instead of German, Only one news index
########################################################

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Index + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################
# Residuals - ECB and News Index
############################################

fit = lm(ECB.Inflation.Index ~ News.Inflation.Index, data1)
ECB_News_res_inf = fit$residuals

fit = lm(ECB.Monetary.Index ~ News.Inflation.Index, data1)
ECB_News_res_mon = fit$residuals

fit = lm(ECB.Economic.Index ~ News.Inflation.Index, data1)
ECB_News_res_ec = fit$residuals

fit = lm(German.Inflation.Year.on.Year ~ News.Inflation.Index, data1)
German_News_res_inf = fit$residuals

data1$time = as.Date(strptime(data1$time, "%Y-%m-%d"))
years = as.Date(strptime(c(2005:2019), '%Y'))

###############################################
# Plots
###############################################

# Plots Paper

step = 3

plot(data1$time[step:length(data1$time)], rollmean(data1$German.Inflation.Year.on.Year, k =step), type = 'l', col = 'red', xlab = "Year", axes = F, ylab = "")
axis(2, ylim=c(0,1),col="red",las=1,col.axis="red") 
mtext("",side=2, col="red", line=2.5)
#par(mar=c(5,6,4,3)+.1)
par(new = TRUE, mar=c(5,6,4,4)+.1)
plot(data1$time[step:length(data1$time)], rollmean(data1$News.Inflation.Count, k = step), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("German Inflation", "News Inflation Count"),
       col=c("red", "green"), lty=1, cex=0.8)
mtext("",side=4,col="green",line=4) 
axis(4, ylim=c(-0.5,3.5), col="green",col.axis="green",las=1)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(data1$Eurozone.Inflation, k =step), type = 'l', col = 'red', xlab = "Year", axes = F, ylab = "")
axis(2, ylim=c(0,1),col="red",las=1,col.axis="red") 
#par(mar=c(5,6,4,3)+.1)
par(new = TRUE, mar=c(5,6,4,4)+.1)
plot(data1$time[step:length(data1$time)], rollmean(data1$ECB.Inflation.Index, k = step), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("Eurozone Inflation", "ECB Inflation Index"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(4, ylim=c(-0.5,3.5), col="green",col.axis="green",las=1)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(data1$Eurozone.Industrial.Production, k =step), type = 'l', col = 'red', xlab = "Year", axes = F, ylab = "")
axis(2, ylim=c(0,1),col="red",las=1,col.axis="red") 
#par(mar=c(5,6,4,3)+.1)
par(new = TRUE, mar=c(5,6,4,4)+.1)
plot(data1$time[step:length(data1$time)], rollmean(data1$ECB.Economic.Index, k = step), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("Eurozone Industrial Production", "ECB Economic Outlook Index"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(4, ylim=c(-0.5,3.5), col="green",col.axis="green",las=1)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(data1$ECB.DFR, k =step), type = 'l', col = 'red', xlab = "Year", axes = F, ylab = "")
axis(2, ylim=c(0,1),col="red",las=1,col.axis="red") 
#par(mar=c(5,6,4,3)+.1)
par(new = TRUE, mar=c(5,6,4,4)+.1)
plot(data1$time[step:length(data1$time)], rollmean(data1$ECB.Monetary.Index, k = step), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("ECB Deposit Facility Rate", "ECB Monetary Index"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(4, ylim=c(-0.5,3.5), col="green",col.axis="green",las=1)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(data1$German.Household.Inflation.Expectations, k =step), type = 'l', col = 'red', xaxt = "n", xlab = "Year", ylab = "", ylim = c(0.5,2.5))
#par(mar=c(5,6,4,3)+.1)
lines(data1$time[step:length(data1$time)], rollmean(data1$Eurozone.Inflation.Professionell.Forecasts, k = step), type = 'l', col = 'green')
legend("topleft", legend=c("German Household Inflation Expectations", "Eurozone Inflation Professionell Forecasts"),
       col=c("red", "green"), lty=1, cex=0.8)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

################################################

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Absolute.Expectations.Gap[1:length(data1$German.Absolute.Expectations.Gap)], k = 3), type = 'l', ann = F, col = 'red', xaxt = "n")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(ECB_News_res_inf[1:length(ECB_News_res_inf)], k = 3), col = 'green', axes = FALSE, bty = "n", xlab = "Year", ylab = "", type = 'l')
legend("topleft", legend=c("Absolute Expectation Gap", "Residuals from ECB Index on News Index"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Relative.Expectations.Gap[1:length(data1$German.Absolute.Expectations.Gap)], k = 3), type = 'l', ann = F, col = 'red', xaxt = "n")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(ECB_News_res_inf[1:length(ECB_News_res_inf)]*-1, k = 3), col = 'green', axes = FALSE, bty = "n", xlab = "Year", ylab = "", type = 'l')
legend("topleft", legend=c("Relative Expectation Gap", "Residuals from ECB Index on News Index (Multiplied with -1)"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

############ Alternative: Differences between normalized ECB and News Index ###########

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Absolute.Expectations.Gap[1:length(data1$German.Absolute.Expectations.Gap)], k = 3), type = 'l', ann = F, col = 'red', xaxt = "n")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(diff_ECB_News_inf_inf[1:length(diff_ECB_News_inf_inf)], k = 3), col = 'green', axes = FALSE, bty = "n", xlab = "Year", ylab = "", type = 'l')
legend("topleft", legend=c("Absolute Expectation Gap", "Differences from ECB Index on News Index"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Relative.Expectations.Gap[1:length(data1$German.Absolute.Expectations.Gap)], k = 3), type = 'l', ann = F, col = 'red', xaxt = "n")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(diff_ECB_News_inf_inf[1:length(diff_ECB_News_inf_inf)]*-1, k = 3), col = 'green', axes = FALSE, bty = "n", xlab = "Year", ylab = "", type = 'l')
legend("topleft", legend=c("Relative Expectation Gap", "Differences from ECB Index on News Index (Multiplied with -1)"),
       col=c("red", "green"), lty=1, cex=0.8)
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

################################################

plot(data1$time[step:length(data1$time)], rollmean(ECB_News_res_inf, k = step), type = 'l', col = 'red', xlab = "Year", axes = F, ylab = "")
axis(2, ylim=c(0,1),col="black",las=1) 
mtext("",side=2,line=2.5)
par(new = TRUE)
plot(data1$time[step:length(data1$time)], rollmean(data1$News.Inflation.Count, k = step), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("Residuals", "News Inflation Count"),
       col=c("red", "green", "black"), lty=1, cex=0.8)
mtext("",side=4,col="red",line=4) 
axis(4, ylim=c(-0.5,3.5), col="red",col.axis="red",las=1)
#axis.Date(1, at = data1$time[step:length(data1$time)]) #labels=format(data1$time[step:length(data1$time)],"%Y"))
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(ECB_News_res_inf, k = step), type = "l", col = 'red', lwd = 1.75, xlab = "Year")
par(new = TRUE)
plot(data1$time[step:length(data1$time)], rollmean(diff_ECB_News_inf_inf, k = step), col = 'green', ann=FALSE, axes = FALSE, bty = "n", xlab = "", ylab = "", type = 'l')
legend("topleft", legend=c("Residuals", "Differences"),
      col=c("red", "green"), lty=1, cex=0.8)
axis(1, at=years, labels = format(years,"%Y"), lwd.ticks = 1)

plot(data1$time[step:length(data1$time)], rollmean(data1$German.Inflation.Year.on.Year, k = step), type = 'l', col = 'red', xlab = "Year")
lines(data1$time[step:length(data1$time)], rollmean(data1$German.Household.Inflation.Expectations, k = step), type = 'l', axes = F, ann= F, col = 'green')
lines(data1$time[step:length(data1$time)], rollmean(data1$Eurozone.Inflation.Professionell.Forecasts, k = step), type = 'l', axes = F, ann= F, col = 'black')
legend("topleft", legend=c("German Inflation", "German Household Inflation Expectations", "Eurozone Inflation Professionell Forecasts"),
       col=c("red", "green", 'black'), lty=1, cex=0.8)

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Inflation.Year.on.Year, k =3), type = 'l', col = 'red', xlab = "Year")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(data1$News.Inflation.Index*-1, k = 3), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("German Inflation", "News Inflation Index"),
       col=c("red", "green", "black"), lty=1, cex=0.8)

plot(data1$time[3:length(data1$time)], rollmean(data1$German.Household.Inflation.Expectations, k =3), type = 'l', col = 'red', xlab = "Year")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(data1$News.Inflation.Index*-1, k = 3), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("German Inflation Expectations", "News Index"),
       col=c("red", "green"), lty=1, cex=0.8)

plot(data1$time[3:length(data1$time)], rollmean(data1$Eurozone.Inflation, k =3), type = 'l', col = 'red', xlab = "Year")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(data1$ECB.Inflation.Index, k = 3), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("Eurozone Inflation", "ECB Inflation Index"),
       col=c("red", "green"), lty=1, cex=0.8)

plot(data1$time[3:length(data1$time)], rollmean(data1$ECB.Inflation.Index, k =3), type = 'l', col = 'red', xlab = "Year")
par(new = TRUE)
plot(data1$time[3:length(data1$time)], rollmean(data1$Eurozone.Inflation.Professionell.Forecasts, k = 3), type = 'l', axes = F, ann= F, col = 'green')
legend("topleft", legend=c("ECB Inflation Index", "Eurozone Inflation Professionell Forecasts"),
       col=c("red", "green"), lty=1, cex=0.8)

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

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(German.Relative.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + German.Industrial.Production.Lag1 + German.Relative.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Relative.Expectations.Gap ~ ECB.Monetary.Index + News.Inflation.Index + News.Inflation.Count + German.Industrial.Production.Lag1 + German.Relative.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(German.Relative.Expectations.Gap ~ ECB_News_res_inf + ECB.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
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