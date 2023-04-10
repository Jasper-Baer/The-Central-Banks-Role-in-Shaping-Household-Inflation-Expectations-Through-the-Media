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

data1 = data %>% select(German.Absolute.Expectations.Gap,German.Absolute.Expectations.Gap,
                        EA.Absolute.Expectations.Gap, ECB.DFR ,Eurozone.Industrial.Production, 
                        German.Industrial.Production, News.Inflation.Index, News.Inflation.Count, 
                        ECB.Inflation.Index, ECB.Monetary.Index, ECB.Economic.Index, EA.Relative.Expectations.Gap, 
                        Eurozone.Inflation, German.Inflation.Year.on.Year)
#time = data %>% select(FRED.Graph.Observations)

data1$ECB.DFR = c(0,diff(data1$ECB.DFR))

lag_order = 4
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

#data1 = data1[95:dim(data1)[1],]

#time = time[((lag_order+1):(dim(data1)[1]+lag_order)),]

# replicawtion of Lamla (2014) (- Teuro), slightly different time frame, European data instead of German, Only one news index

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Index + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################
# Additional Regressions
############################################

############################################

fit = lm(Relative.Expectations.Gap ~ News.Inflation.Index + News.Inflation.Count + ECB.Inflation.Index + Eurozone.Inflation.Lag1 + Relative.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ News.Inflation.Index + News.Inflation.Count + ECB.Inflation.Index + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ News.Inflation.Index + News.Inflation.Count +  Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(News.Inflation.Index ~ ECB.Inflation.Index + ECB.Monetary.Index, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(ECB.Inflation.Index ~ News.Inflation.Index, data1)
ECB_News_res_inf = fit$residuals

fit = lm(ECB.Monetary.Index ~ News.Inflation.Index, data1)
ECB_News_res_mon = fit$residuals

fit = lm(ECB.Economic.Index ~ News.Inflation.Index, data1)
ECB_News_res_ec = fit$residuals

plot(data1$time, ECB_News_res_inf, type = "l")
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

plot(data1$time[5:length(data1$time)], rollmean(ECB_News_res_inf, k = 5), type = "l")
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

plot(data1$time, abs(ECB_News_res_inf), type = "l")
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

plot(data1$time, ECB_News_res_mon, type = "l")
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

plot(data1$time, ECB_News_res_ec, type = "l")
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################
# Regression between NLP-Indizes and corresponding macro variables
############################################

fit = lm(Eurozone.Inflation ~ News.Inflation.Index + ECB.Monetary.Index + ECB.Economic.Index + ECB.Inflation.Index + News.Inflation.Count + Eurozone.Industrial.Production + ECB.DFR + ECB.DFR.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Eurozone.Inflation ~ News.Inflation.Index + ECB.Inflation.Index + News.Inflation.Count + Eurozone.Industrial.Production + ECB.DFR + ECB.DFR.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Eurozone.Inflation ~ News.Inflation.Index + ECB.Monetary.Index + News.Inflation.Count + Eurozone.Industrial.Production + ECB.DFR + ECB.DFR.Lag1 + Eurozone.Inflation.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Industrial.Production ~ News.Inflation.Index + ECB.Inflation.Index + ECB.Economic.Index + ECB.Monetary.Index + News.Inflation.Count + Eurozone.Inflation, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Industrial.Production ~ News.Inflation.Index + ECB.Economic.Index + News.Inflation.Count + Eurozone.Inflation, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

############################################

rolling_abs_gap = rollmean(data1$Absolute.Expectations.Gap, k = 3, fill = NA)

plot(time, data1$News.Inflation.Index, type = "l", col = 'red', ylim = c(-0.15,0.1))
lines(time, data1$ECB.Inflation.Index*-1, type = "l", col = 'blue')
lines(time, ECB_News_res_inf, type = "l", col = 'green')

plot(time, data1$Relative.Expectations.Gap, type = "l")

plot(time, data1$Absolute.Expectations.Gap, type = "l", col = "blue")
lines(time, rolling_abs_gap, col ="red")

plot(time, rolling_abs_gap, col ="red")
lines(time, ECB_News_res_inf, type = "l", col = 'green')

diff_ECB_News_inf_inf = scale(data1$News.Inflation.Index) - scale(data1$ECB.Inflation.Index*-1)
diff_ECB_News_inf_ec = scale(data1$News.Inflation.Index) - scale(data1$ECB.Economic.Index*-1)
diff_ECB_News_inf_mon = scale(data1$News.Inflation.Index) - scale(data1$ECB.Monetary.Index*-1)

plot(time, diff_ECB_News_inf_inf, type = "l", col = "red")
par(new = TRUE)
plot(time, ECB_News_res, type = "l", col = 'green', axes = FALSE, bty = "n", xlab = "", ylab = "")

plot(time, rolling_abs_gap, type = "l", col = 'red')
par(new = TRUE)
plot(time, ECB_News_res_inf, type = "l", col = 'green', axes = FALSE, bty = "n", xlab = "", ylab = "")

############################################

data1 = cbind(data1, ECB_News_res_inf)
data1 = cbind(data1, diff_ECB_News_inf_inf)

fit = lm(Absolute.Expectations.Gap ~ ECB.Inflation.Index + ECB_News_res_inf + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################
# Significant Results
#############################################
# Daten in zwei Teile ? (Nach und vor Kommunikationsänderung)
##
# Use Inflation Surprises as Variable
# Use Monetary Surprises as Variable

fit = lm(German.Absolute.Expectations.Gap ~ ECB_News_res_inf + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1 + Eurozone.Industrial.Production + Eurozone.Industrial.Production.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ ECB.Inflation.Index + News.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + German.Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ ECB_News_res_inf + ECB.Inflation.Index + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(Absolute.Expectations.Gap ~ ECB_News_res_inf + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1, data1)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#############################################

fit = lm(Absolute.Expectations.Gap ~ ECB_News_res_inf + ECB.Inflation.Index + News.Inflation.Count + Eurozone.Inflation.Lag1 + Absolute.Expectations.Gap.Lag1 + German.Industrial.Production , data1)
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