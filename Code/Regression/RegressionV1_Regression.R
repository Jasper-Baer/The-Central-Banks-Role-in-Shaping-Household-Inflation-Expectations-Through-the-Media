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

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))
#years = as.Date(strptime(c(2005:2019), '%Y'))
#data = data[9:dim(data)[1],]
#data = data[45:dim(data)[1],]
#data = data[1:(dim(data)[1]-120),]

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk.Lag1[is.na(data$German.Absolute.Expectations.Gap.Berk.Lag1)] <- 0

# Change signs of ECB_News_res_inf_3 and ECB_News_res_inf_1? (Because INI is reversed)

#####################################################################################

### RWI - Stm

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### RWI - Berk 1

fit = lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### GD - Stm

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### GD - Berk 1

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Stm

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_eu, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Berk 1

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

###

fit = lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Stm.RWI ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Stm.GD ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Role.RWI ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Role.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role.GD ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Role.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Quant.RWI ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Quant.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Quant.GD ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Quant.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Quant ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################

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

#####

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1  + ECB_News_res_inf_3_ger  + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1  + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
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

#####

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_3_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + ECB_News_res_inf_3_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_3_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######

fit = lm(German.ECB.Absolute.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
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


#####

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_3_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_3_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Role ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#######################################################################################
#######################################################################################
#######################################################################################

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))


#####

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_3_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.1 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
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

########################################################################################

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

#####

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_3_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.5 ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

##################################################################################################

#####

fit = lm(German.Absolute.Expectations.Gap.Berk.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_3_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit = lm(German.Absolute.Expectations.Gap.Berk.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

######

fit = lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk.Stm ~ News.Inflation.Count + ECB_News_res_inf_0_ger + ECB_News_res_inf_1 + ECB_News_res_inf_2_ger + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit, vcov.=NeweyWest(fit, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))
