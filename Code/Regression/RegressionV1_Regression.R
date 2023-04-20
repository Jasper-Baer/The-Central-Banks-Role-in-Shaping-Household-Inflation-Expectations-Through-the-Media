# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

#####################################################################################

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_2.xlsx')
data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))
#years = as.Date(strptime(c(2005:2019), '%Y'))
#data = data[45:dim(data)[1],]
data = data[45:dim(data)[1],]

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk.Lag1[is.na(data$German.Absolute.Expectations.Gap.Berk.Lag1)] <- 0

# Change signs of ECB_News_res_inf_3 and ECB_News_res_inf_1? (Because INI is reversed)

#####################################################################################

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count +  ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + German.ECB.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

########################################################################################

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_1  + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################
#######################################################################################
#######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + German.ECB.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

########################################################################################

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))