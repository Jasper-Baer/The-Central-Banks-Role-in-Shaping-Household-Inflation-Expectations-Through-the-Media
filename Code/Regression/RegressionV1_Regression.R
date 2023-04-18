# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))
years = as.Date(strptime(c(2002:2019), '%Y'))

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk.Lag1[is.na(data$German.Absolute.Expectations.Gap.Berk.Lag1)] <- 0

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_3 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.Lag1 ~ News.Inflation.Count + ECB_News_res_inf_3 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Lag2 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count, data[100:(dim(data)[1]),])
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data[100:(dim(data)[1]),])
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data[100:(dim(data)[1]),])
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Lag1 + German.Inflation.Year.on.Year.Lag1, data[100:(dim(data)[1]),])
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data[100:(dim(data)[1]),])
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))