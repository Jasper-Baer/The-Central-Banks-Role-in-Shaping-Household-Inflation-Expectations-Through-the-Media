# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")

library("lmtest")
library("sandwich")
library("stargazer")


#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed.xlsx')
#data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))
#years = as.Date(strptime(c(2005:2019), '%Y'))
#data = data[9:dim(data)[1],]
#data = data[45:dim(data)[1],]
#data = data[1:(dim(data)[1]-140),]

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk.Lag1[is.na(data$German.Absolute.Expectations.Gap.Berk.Lag1)] <- 0

# Change signs of ECB_News_res_inf_3 and ECB_News_res_inf_1? (Because INI is reversed)

#####################################################################################

### RWI - Stm

# Run the regressions
fit1 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# RWI - Berk 1
fit1 <- lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Berk.1.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text", title = "RWI - Berk 1", se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

# RWI - Berk 5
fit1 <- lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ ECB_News_res_inf_0_RWI, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Berk.5.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.5.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ ECB_News_res_inf_0_RWI + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Berk.5.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text", title = "RWI - Berk 5", se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

#####################

# GD - Stm
fit6 <- lm(German.Absolute.Expectations.Gap.Stm.GD ~ ECB_News_res_inf_0_GD, data)
fit7 <- lm(German.Absolute.Expectations.Gap.Stm.GD ~ ECB_News_res_inf_0_GD + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit8 <- lm(German.Absolute.Expectations.Gap.Stm.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit9 <- lm(German.Absolute.Expectations.Gap.Stm.GD ~ ECB_News_res_inf_0_GD + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit10 <- lm(German.Absolute.Expectations.Gap.Stm.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Stm.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit6, fit7, fit8, fit9, fit10, type = "text", title = "GD - Stm", se = list(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                     coeftest(fit7, vcov.=NeweyWest(fit7, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                     coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                     coeftest(fit9, vcov.=NeweyWest(fit9, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                     coeftest(fit10, vcov.=NeweyWest(fit10, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))
### GD - Berk 1

fit1 <- lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ ECB_News_res_inf_0_GD, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ ECB_News_res_inf_0_GD + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ ECB_News_res_inf_0_GD + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Berk.1.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.1.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text", title = "GD - Berk 1", se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                         coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))
### GD - Berk 5

fit1 <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ ECB_News_res_inf_0_GD, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ ECB_News_res_inf_0_GD + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ ECB_News_res_inf_0_GD + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~ ECB_News_res_inf_0_GD + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text", title = "GD - Berk 5", se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                        coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                        coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                        coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                        coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

fit_extra <- lm(German.Absolute.Expectations.Gap.Berk.5.GD ~  ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.Absolute.Expectations.Gap.Berk.5.GD.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Stm

fit16 <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu, data)
fit17 <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit18 <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit19 <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit20 <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit16, fit17, fit18, fit19, fit20, type = "text", title = "ECB - Stm", se = list(coeftest(fit16, vcov.=NeweyWest(fit16, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit17, vcov.=NeweyWest(fit17, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit18, vcov.=NeweyWest(fit18, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit19, vcov.=NeweyWest(fit19, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit20, vcov.=NeweyWest(fit20, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

fit_extra <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

fit_extra <- lm(German.ECB.Absolute.Expectations.Gap.Stm ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Stm.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Quant

fit16 <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_0_eu, data)
fit17 <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit18 <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit19 <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit20 <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Quant.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit16, fit17, fit18, fit19, fit20, type = "text", title = "ECB - Quant", se = list(coeftest(fit16, vcov.=NeweyWest(fit16, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit17, vcov.=NeweyWest(fit17, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit18, vcov.=NeweyWest(fit18, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit19, vcov.=NeweyWest(fit19, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                           coeftest(fit20, vcov.=NeweyWest(fit20, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

fit_extra <- lm(German.ECB.Absolute.Expectations.Gap.Quant ~ ECB_News_res_inf_1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Berk 1

fit21 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu, data)
fit22 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit23 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit24 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit25 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.1.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit21, fit22, fit23, fit24, fit25, type = "text", title = "ECB - Berk 1", se = list(coeftest(fit21, vcov.=NeweyWest(fit21, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit22, vcov.=NeweyWest(fit22, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit23, vcov.=NeweyWest(fit23, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit24, vcov.=NeweyWest(fit24, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit25, vcov.=NeweyWest(fit25, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

fit_extra <- lm(German.ECB.Absolute.Expectations.Gap.Berk.1 ~ ECB_News_res_inf_1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

### ECB - Berk 5

fit26 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu, data)
fit27 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit28 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit29 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit30 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit26, fit27, fit28, fit29, fit30, type = "text", title = "ECB - Berk 5", se = list(coeftest(fit26, vcov.=NeweyWest(fit26, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit27, vcov.=NeweyWest(fit27, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit28, vcov.=NeweyWest(fit28, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit29, vcov.=NeweyWest(fit29, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit30, vcov.=NeweyWest(fit30, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))


fit_extra <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~  ECB_News_res_inf_0_eu + ECB_News_res_inf_1 + ECB_News_res_inf_2_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
coeftest(fit_extra, vcov.=NeweyWest(fit_extra, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

########################################################
# Lamala ?

fit26 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu, data)
fit27 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit28 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_3_ger + ECB_News_res_inf_4_ger + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit29 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit30 <- lm(German.ECB.Absolute.Expectations.Gap.Berk.5 ~ ECB_News_res_inf_0_eu + ECB_News_res_inf_3_ger + ECB_News_res_inf_4_ger + News.ECB.Count + German.ECB.Absolute.Expectations.Gap.Berk.5.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit26, fit27, fit28, fit29, fit30, type = "text", title = "ECB - Berk 1", se = list(coeftest(fit26, vcov.=NeweyWest(fit26, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit27, vcov.=NeweyWest(fit27, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit28, vcov.=NeweyWest(fit28, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit29, vcov.=NeweyWest(fit29, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"],
                                                                                              coeftest(fit30, vcov.=NeweyWest(fit30, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[,"Std. Error"]))

#########################################################


