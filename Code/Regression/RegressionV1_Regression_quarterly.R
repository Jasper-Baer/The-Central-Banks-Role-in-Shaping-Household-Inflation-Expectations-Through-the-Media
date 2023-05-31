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

data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_quarterly_processed.xlsx')
#data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data <- data[data$ECB_News_res_inf_1 < 0,]
#data <- data[data$ECB_News_res_inf_1 > 0,]

#data = data[0:80,]

#data = data[25:dim(data),]

# Quant - Reuter

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Quant - Real

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)