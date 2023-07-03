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

#library("car")

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_quarterly_processed.xlsx')
data = read_excel('D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/Regession_data_quarterly_processed.xlsx')

data = data.frame(data)

data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data = data[6:dim(data)[1],]
data = data[2:dim(data)[1],]
#data = data[11:dim(data)[1],]
#data = data[15:dim(data)[1],]
#data = data[19:dim(data)[1],]
#data = data[21:dim(data)[1],]

#data <- data[data$ECB_News_res_inf_1 < 0,]
#data <- data[data$ECB_News_res_inf_1 > 0,]

#data = data[0:80,]

#data = data[25:dim(data),]

# Quant - Reuter

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ News.Inflation.Count 
           + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ News.Inflation.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ News.Inflation.Count
           + ECB_News_diff_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ News.Inflation.Count
           + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ News.Inflation.Count
           + ECB_News_diff_inf_1 * News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

###

fit71 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ 
             New.Inflation.Count
           + ECB_News_res_inf_2_Reuter
           #* News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1
           + forward
           #+ whatever
           , data)

print(coeftest(fit71, vcov.=NeweyWest(fit71, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

vif(fit71, type = 'predictor')

###

fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ 
             News.Inflation.Count 
           + ECB_News_res_inf_2_Reuter 
          # * News.ECB.Count 
           + ECB_News_diff_inf_2
          # + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           #+ German.Industrial.Production.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit81 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter ~ 
             News.Inflation.Count 
          # + ECB_News_res_inf_2_Reuter
           + News.ECB.Count 
           + ECB_News_diff_inf_2 
           #* News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward
           , data)

print(coeftest(fit81, vcov.=NeweyWest(fit81, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

# Stm - Reuter

fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + German.Industrial.Production.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit81 <- lm(German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter ~ 
              #   ECB_News_res_inf_0_Reuter 
           # + ECB.Inflation.Index
          #  + News.Inflation.Index
            + ECB_News_diff_inf_2
            + News.ECB.Count 
            + News.Inflation.Count
            # + ECB_News_res_inf_2_Reuter * News.ECB.Count 
            # + ECB_News_res_inf_1 * News.ECB.Count 
            + German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter.Lag1
            + German.Inflation.Year.on.Year.Lag1 
            + forward
            , data)

print(coeftest(fit81, vcov.=NeweyWest(fit81, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

####

# Quant - Real

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + German.Industrial.Production.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ 
             ECB_News_res_inf_0_Reuter 
           #+ ECB_News_res_inf_1 
           #+ ECB_News_diff_inf_2
          # + News.ECB.Count 
          # + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit7 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
           + ECB_News_res_inf_1 
           * News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward
           , data)

print(coeftest(fit7, vcov.=NeweyWest(fit7, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit7 <- summary(fit7)
print(summary_fit7$r.squared)

###

fit75 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
           + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 
           + German.Inflation.Year.on.Year.Lag1 + German.Inflation.Year.on.Year.Lag2
           + German.Inflation.Year.on.Year.Lag3 + German.Inflation.Year.on.Year.Lag4 + forward + trichet, data)

print(coeftest(fit75, vcov.=NeweyWest(fit75, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit75 <- summary(fit7)
print(summary_fit75$r.squared)

###

fit71 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
            + ECB_News_res_inf_1 * News.ECB.Count 
          #  + German.Inflation.Year.on.Year.Lag1 
           # + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 
            + forward, data)

print(coeftest(fit71, vcov.=NeweyWest(fit71, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit79 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
            + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 
            + German.Inflation.Year.on.Year.Lag1 + German.Industrial.Production.Lag1 + forward, data)

print(coeftest(fit79, vcov.=NeweyWest(fit79, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
           + ECB_News_res_inf_2_Reuter * News.ECB.Count + ECB_News_res_inf_1 * News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 
           + German.Industrial.Production.Lag1 + forward + trichet, data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit81 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real ~ ECB_News_res_inf_0_Reuter 
           + ECB_News_res_inf_2_Reuter * News.ECB.Count + ECB_News_res_inf_1 * News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 
           + forward , data)

print(coeftest(fit81, vcov.=NeweyWest(fit81, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit8 <- summary(fit8)
print(summary_fit8$r.squared)

vif(fit8, type = 'predictor')

################################################################################
################################################################################
################################################################################

# Quant - Reuter

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ 
             News.Inflation.Count
           + ECB_News_diff_inf_2
           + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
          # + German.Industrial.Production.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit7 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ 
             News.Inflation.Count 
           + ECB_News_res_inf_2_Reuter 
           + ECB_News_diff_inf_2
           + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
          # + German.Industrial.Production.Lag1 
           + forward
           , data)

print(coeftest(fit7, vcov.=NeweyWest(fit7, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ 
             News.Inflation.Count
           + ECB_News_diff_inf_2
           #* News.ECB.Count 
         #  + ECB_News_res_inf_2_Reuter 
           #* News.ECB.Count 
           #+ ECB_News_res_inf_1 
           + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           #+ German.Industrial.Production.Lag1 
           #+ trichet 
           + forward
           , data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

vif(fit8 , type = 'predictor')

summary_fit8 <- summary(fit8)
print(summary_fit8$r.squared)

###

# Quant - Real

# Run the regressions
fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ ECB_News_res_inf_0_Reuter + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Real.Lag1 + German.Inflation.Year.on.Year.Lag1 + German.Industrial.Production.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real ~ 
             News.Inflation.Count  
           + ECB_News_diff_inf_2
           + ECB_News_res_inf_2_Reuter
           + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

##########

fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ 
             News.Inflation.Count
           + ECB_News_diff_inf_2
           #* News.ECB.Count 
           + ECB_News_res_inf_2_Reuter 
          # * News.ECB.Count 
           #+ ECB_News_res_inf_1 
           + News.ECB.Count 
           + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit7 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

print(coeftest(fit7, vcov.=NeweyWest(fit7, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit7 <- summary(fit7)
print(summary_fit7$r.squared)

###

fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_2_Reuter * News.ECB.Count + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit8 <- summary(fit8)
print(summary_fit8$r.squared)

vif(fit8, type = 'predictor')

###

fit1 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + forward, data)
fit2 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit3 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit4 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)
fit5 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

stargazer(fit1, fit2, fit3, fit4, fit5, type = "text",
          se = list(coeftest(fit1, vcov.=NeweyWest(fit1, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit2, vcov.=NeweyWest(fit2, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit3, vcov.=NeweyWest(fit3, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit4, vcov.=NeweyWest(fit4, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"],
                    coeftest(fit5, vcov.=NeweyWest(fit5, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE))[, "Std. Error"]),
          title = "Regression Results",
          header = FALSE, 
          align = TRUE)

fit6 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ 
             News.Inflation.Count
           #+ ECB_News_diff_inf_2
           #* News.ECB.Count 
           + ECB_News_res_inf_2_Reuter 
           # * News.ECB.Count 
           #+ ECB_News_res_inf_1 
           + News.ECB.Count 
           #+ German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           + forward 
           #+ trichet
           , data)

print(coeftest(fit6, vcov.=NeweyWest(fit6, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

###

fit7 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

print(coeftest(fit7, vcov.=NeweyWest(fit7, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit7 <- summary(fit7)
print(summary_fit7$r.squared)

###

fit75 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter 
            + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter.Lag1 
            + German.Inflation.Year.on.Year.Lag1 + German.Inflation.Year.on.Year.Lag2
            + German.Inflation.Year.on.Year.Lag3 + German.Inflation.Year.on.Year.Lag4 + forward + trichet, data)

print(coeftest(fit75, vcov.=NeweyWest(fit75, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit75 <- summary(fit7)
print(summary_fit75$r.squared)

###

fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter ~ ECB_News_res_inf_0_Reuter + ECB_News_res_inf_2_Reuter * News.ECB.Count + ECB_News_res_inf_1 * News.ECB.Count + German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter.Lag1 + German.Inflation.Year.on.Year.Lag1 + forward, data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))

summary_fit8 <- summary(fit8)
print(summary_fit8$r.squared)

vif(fit8, type = 'predictor')

##########

# Get the coefficients
coefficients <- coef(results)

coefficients["ECB_News_res_inf_0_Reuter"]

# Get the names of the coefficients
names <- names(coefficients)

coefficients["ECB_News_res_inf_0_Reuter"]*sd(data$ECB_News_res_inf_0_Reuter)/sd(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)
coefficients["ECB_News_res_inf_1"]*sd(data$ECB_News_res_inf_1)/sd(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)
coefficients["News.ECB.Count"]*sd(data$News.ECB.Count)/sd(data$German.Relative.Real.Inflation.Expectations.Gap.Quant.Real)

###

g <- function(theta, x){
  # Extract variables from data
  y <- x[, "German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter"]
  News_Inflation_Count <- x[, "News.Inflation.Count"]
  ECB_News_diff_inf_2 <- x[, "ECB_News_diff_inf_2"]
  News_ECB_Count <- x[, "News.ECB.Count"]
  y_lag1 <- x[, "German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1"]
  German_Inflation_Year_on_Year_Lag1 <- x[, "German.Inflation.Year.on.Year.Lag1"]
  forward <- x[, "forward"]
  ECB_News_res_inf_2_Reuter <- x[, "ECB_News_res_inf_2_Reuter"]
  
  # Define model
  y_hat <- theta[1] + theta[2]*News_Inflation_Count + theta[3]*ECB_News_diff_inf_2 + theta[4]*News_ECB_Count + theta[5]*y_lag1 + theta[6]*German_Inflation_Year_on_Year_Lag1 + theta[7]*forward + theta[8]*ECB_News_res_inf_2_Reuter
  
  # Define moment conditions
  m1 <- (y - y_hat)
  m2 <- (y - y_hat)*News_Inflation_Count
  m3 <- (y - y_hat)*ECB_News_diff_inf_2
  m4 <- (y - y_hat)*News_ECB_Count
  m5 <- (y - y_hat)*y_lag1
  m6 <- (y - y_hat)*German_Inflation_Year_on_Year_Lag1
  m7 <- (y - y_hat)*forward
  m8 <- (y - y_hat)*ECB_News_res_inf_2_Reuter
  
  return(cbind(m1, m2, m3, m4, m5, m6, m7, m8))
}


# Initial values for parameters
theta_init <- rep(0, 8)

# Estimate model
res <- gmm(g, x = data, t0 = theta_init, type = "twoStep")

# Print results
summary(res)


fit8 <- lm(German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter ~ 
             News.Inflation.Count
           + ECB_News_diff_inf_1
           #* News.ECB.Count 
           #  + ECB_News_res_inf_2_Reuter 
           #* News.ECB.Count 
           #+ ECB_News_res_inf_1 
           * News.ECB.Count 
           #  + German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter.Lag1 
           + German.Inflation.Year.on.Year.Lag1 
           #+ German.Industrial.Production.Lag1 
           #+ trichet 
           + forward
           , data)

print(coeftest(fit8, vcov.=NeweyWest(fit8, lag=0, prewhite=TRUE, adjust=TRUE, verbose=TRUE)))