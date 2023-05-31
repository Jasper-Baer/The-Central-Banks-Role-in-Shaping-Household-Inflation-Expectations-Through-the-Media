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

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed.xlsx')
data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')
data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data <- data[data$ECB_News_res_inf_1 < 0,]
#data <- data[data$ECB_News_res_inf_1 > 0,]

#data = data[0:80,]
#data = data[45:dim(data)[1],]

#data = data[25:dim(data),]

#years = as.Date(strptime(c(2005:2019), '%Y'))
#data = data[9:dim(data)[1],]

#data = data[1:(dim(data)[1]-140),]

#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk[is.na(data$German.Absolute.Expectations.Gap.Berk)] <- 0
#data$German.Absolute.Expectations.Gap.Berk.Lag1[is.na(data$German.Absolute.Expectations.Gap.Berk.Lag1)] <- 0

# Change signs of ECB_News_res_inf_3 and ECB_News_res_inf_1? (Because INI is reversed)

#####################################################################################

#########################################################

### Reuter - Stm

# Run the regressions
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Berk 5
# Run the regressions
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Role
# Run the regressions
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Role - Reuter
# Run the regressions
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

###################

# Quant - Reuter

# Run the regressions
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

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
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

###############################################################################


# mu_t = alpha_t(1-lambda_t) + Psi_t (Eq. 8)
# mu_t - Psi_t  - alpha_t = alpha_t * (-) lambda_t
# alpha_t + Psi_t - mu_t = alpha_t * lambda_t
# 1 + Psi_t/alpha_t - mu_t/alpha_t = lambda_t

# Define a function to identify outliers
identify_outliers <- function(x) {
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  iqr <- q3 - q1
  outliers <- (x < (q1 - 1.5 * iqr)) | (x > (q3 + 1.5 * iqr))
  return(outliers)
}

# Use the function to identify outliers and replace them with 0


data_forecast = scale(data$Reuter.Poll.Forecast/data$ECB_News_res_inf_1)
data_inflation = scale(data$German.Household.Inflation.Expectations.Stm/data$ECB_News_res_inf_1)

data$News.ECB.Count.role = scale(data$News.ECB.Count.role)

data_inflation[identify_outliers(data_inflation)] <- 0
data_forecast[identify_outliers(data_forecast)] <- 0
data$News.ECB.Count.role[identify_outliers(data$News.ECB.Count.role)] <- 0

# Create the initial plot with the first series
plot(data_inflation[], col = 'green',type = "l", ylim = range(c(data_inflation, data_forecast, data$News.ECB.Count.role)), ylab = "Value", xlab = "Index")

# Add the second series to the plot
lines(data_forecast, col = "red")

# Add the third series to the plot
lines(data$News.ECB.Count.role, col = "blue")

plot(data$News.ECB.Count.role, col = "blue",type = "l")
plot(data_forecast, col = "red", type = "l")
plot(data_inflation, col = "green", type = "l")

fit_lambda = lm(data[100:166,]$News.ECB.Count ~ 1 + data_forecast[100:166] + data_inflation[100:166])
summary(fit_lambda)

fit_lambda = lm(News.ECB.Count ~ 1 + I(Reuter.Poll.Forecast/ECB_News_res_inf_1) + I(German.Household.Inflation.Expectations.Stm/ECB_News_res_inf_1), data[100:166,])
summary(fit_lambda)

fit_lambda = lm(News.ECB.Count ~ 1 + Reuter.Poll.Forecast/ECB_News_res_inf_1 - German.Household.Inflation.Expectations.Stm/ECB_News_res_inf_1, data)
summary(fit_lambda)

coeftest(fit_lambda, vcov.=NeweyWest(fit_lambda, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))
fitted_lambda = fit_lambda$fitted.values

predict(fit_lambda, newdata = data[100:166])

################################################################################

# Relative Bias

################################################################################

### Reuter - Stm

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1*News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_2_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Berk 5
# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1*News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_3_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Role
# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

######

# Quant - Reuter

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_2_Reuter + ECB_News_res_inf_1 + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))
coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))

# Quant - Real

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Real ~ ECB_News_res_inf_0_Quant + ECB_News_res_inf_2_Quant + ECB_News_res_inf_1 + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Real.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)



## Fitted Lambda Regression

### Reuter - Stm
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Berk 5
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Berk5.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

# Reuter - Role
fit1 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter, data)
fit2 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + fitted_lambda + German.Absolute.Real.Inflation.Expectations.Gap.Role.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)



























recessions <- data.frame(
  start = as.Date(c("2003-01-01",  "2008-03-01", "2011-07-01", "2017-12-01")),
  end = as.Date(c("2005-02-28", "2009-06-30", "2015-05-30","2019-01-01")) # "2020-05-30"
)

coeff = max(data$News.ECB.Count)/max(fitted_lambda)

ggplot(data, aes(x = time)) + 
  geom_rect(data = recessions, aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf),
            inherit.aes = FALSE, fill = "grey", alpha = 0.5) +
  #geom_line(aes(y = News.Inflation.Count.role/coeff), colour="blue", linetype = 1) +
  geom_line(aes(y = News.ECB.Count.role / coeff), stat = "identity", fill = "blue", width = 10) +
  geom_line(aes(y = fitted_lambda), colour="red", linetype = 2, size = 0.75) +
  geom_hline(yintercept = 0) + 
  scale_y_continuous(name = "Measured Lambda", sec.axis = sec_axis(~.*coeff*1000, name = "Fitted Lambda")) +
  scale_x_date(date_labels="%Y", breaks = seq(as.Date("2003-01-01"), max(data$time), by = "1 year"), name = "", limits = c(min(data$time), max(data$time))) +
  theme_classic() + 
  theme(axis.text.y.left = element_text(color = "red"),
        axis.text.y.right = element_text(color = "blue"),
        axis.title.y = element_text(color = "red"),
        axis.title.y.right = element_text(color = "blue", vjust = 2),
        axis.text.x = element_text(angle = 45, vjust = 0.5, size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_blank()) 

################################################################################

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

### RWI - Stm

# Run the regressions
fit1 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI, data)
fit2 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit3 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit4 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + fitted_lambda + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)
fit5 <- lm(German.Absolute.Expectations.Gap.Stm.RWI ~ ECB_News_res_inf_0_RWI + ECB_News_res_inf_1 + fitted_lambda + German.Absolute.Expectations.Gap.Stm.RWI.Lag1 + German.Inflation.Year.on.Year.Lag1, data)

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
