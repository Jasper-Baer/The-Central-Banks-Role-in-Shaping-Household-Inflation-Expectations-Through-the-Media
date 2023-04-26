# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")
#library("openxlsx")
library("writexl") 

#####################################################################################

#data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly_2.xlsx')
data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/regression_data_monthly_2.xlsx')
data = data.frame(data)

#data = data[9:dim(data)[1],]
data = data[21:dim(data)[1],]

data1 = data %>% select(Eurozone.Industrial.Production,
                        Eurozone.Inflation, 
                        German.Industrial.Production, 
                        German.Inflation.Year.on.Year,
                        German.Inflation.Year.on.Year.Harmonised, 
                        ECB.DFR,
                        News.Inflation.Index, 
                        News.Inflation.Sentiment.Index, 
                        News.Inflation.Direction.Index,
                        News.Inflation.Count, 
                        News.ECB.Count, 
                        ECB.Inflation.Index, 
                        ECB.Monetary.Index, 
                        ECB.Economic.Index, 
                        German.Household.Inflation.Expectations.Berk.1,
                        German.Household.Inflation.Expectations.Berk.5,
                        German.Household.Inflation.Expectations.Role,
                        German.Household.Inflation.Expectations.Stm,
                        German.Household.Inflation.Expectations.EU.Median,
                        Eurozone.Inflation.Professionell.Forecasts, 
                        Germany.Inflation.Professionell.Forecasts.GD, 
                        Germany.Inflation.Professionell.Forecasts.RWI, 
                        German.Absolute.Expectations.Gap.Role.GD,
                        German.Relative.Expectations.Gap.Role.GD,
                        German.Absolute.Expectations.Gap.Role.RWI,
                        German.Relative.Expectations.Gap.Role.RWI,
                        German.ECB.Absolute.Expectations.Gap.Role,
                        German.ECB.Relative.Expectations.Gap.Role,
                        German.Absolute.Real.Inflation.Expectations.Gap.Role,
                        German.Relative.Real.Inflation.Expectations.Gap.Role,
                        German.Absolute.Expectations.Gap.Berk.1.GD,
                        German.Relative.Expectations.Gap.Berk.1.GD,
                        German.Absolute.Expectations.Gap.Berk.1.RWI,
                        German.Relative.Expectations.Gap.Berk.1.RWI,
                        German.ECB.Absolute.Expectations.Gap.Berk.1,
                        German.ECB.Relative.Expectations.Gap.Berk.1,
                        German.Absolute.Real.Inflation.Expectations.Gap.Berk.1,
                        German.Relative.Real.Inflation.Expectations.Gap.Berk.1,
                        German.Absolute.Expectations.Gap.Berk.5.GD,
                        German.Relative.Expectations.Gap.Berk.5.GD,
                        German.Absolute.Expectations.Gap.Berk.5.RWI,
                        German.Relative.Expectations.Gap.Berk.5.RWI,
                        German.ECB.Absolute.Expectations.Gap.Berk.5,
                        German.ECB.Relative.Expectations.Gap.Berk.5,
                        German.Absolute.Real.Inflation.Expectations.Gap.Berk.5,
                        German.Relative.Real.Inflation.Expectations.Gap.Berk.5,
                        German.Absolute.Expectations.Gap.Stm.GD,
                        German.Relative.Expectations.Gap.Stm.GD,
                        German.Absolute.Expectations.Gap.Stm.RWI,
                        German.Relative.Expectations.Gap.Stm.RWI,
                        German.ECB.Absolute.Expectations.Gap.Stm,
                        German.ECB.Relative.Expectations.Gap.Stm,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant,
                        German.Absolute.Expectations.Gap.Quant.GD,
                        German.Relative.Expectations.Gap.Quant.GD,
                        German.Absolute.Expectations.Gap.Quant.RWI,
                        German.Relative.Expectations.Gap.Quant.RWI,
                        German.ECB.Absolute.Expectations.Gap.Quant,
                        German.ECB.Relative.Expectations.Gap.Quant,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant)

############################################
# Residuals - ECB and News Index
############################################

stand_ECB = scale(data$ECB.Inflation.Index)
stand_news = scale(data$News.Inflation.Index)

fit = lm(ECB.Inflation.Index ~ News.Inflation.Index*-1, data1)
ECB_News_res_inf_1 = fit$residuals

#ECB_News_res_inf_1 = stand_ECB - stand_news

fit = lm(News.Inflation.Count ~ Germany.Inflation.Professionell.Forecasts.RWI, data1)
ECB_News_res_inf_0_RWI = fit$residuals

fit = lm(News.Inflation.Count ~ Germany.Inflation.Professionell.Forecasts.GD, data1)
ECB_News_res_inf_0_GD = fit$residuals

fit = lm(News.Inflation.Count ~ Eurozone.Inflation.Professionell.Forecasts, data1)
ECB_News_res_inf_0_eu = fit$residuals

fit = lm(News.Inflation.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.RWI, data1)
ECB_News_res_inf_2_RWI = fit$residuals

fit = lm(News.Inflation.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.GD, data1)
ECB_News_res_inf_2_GD = fit$residuals

fit = lm(News.Inflation.Index*-1 ~ Eurozone.Inflation.Professionell.Forecasts, data1)
ECB_News_res_inf_2_eu = fit$residuals

fit = lm(News.Inflation.Sentiment.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.RWI, data1)
ECB_News_res_inf_3_RWI = fit$residuals

fit = lm(News.Inflation.Sentiment.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.GD, data1)
ECB_News_res_inf_3_GD = fit$residuals

fit = lm(News.Inflation.Sentiment.Index*-1 ~ Eurozone.Inflation.Professionell.Forecasts, data1)
ECB_News_res_inf_3_eu = fit$residuals

fit = lm(News.Inflation.Direction.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.RWI, data1)
ECB_News_res_inf_4_RWI = fit$residuals

fit = lm(News.Inflation.Direction.Index*-1 ~ Germany.Inflation.Professionell.Forecasts.GD, data1)
ECB_News_res_inf_4_GD = fit$residuals

fit = lm(News.Inflation.Direction.Index*-1 ~ Eurozone.Inflation.Professionell.Forecasts, data1)
ECB_News_res_inf_4_eu = fit$residuals

data1 = cbind(data1, ECB_News_res_inf_0_RWI)
data1 = cbind(data1, ECB_News_res_inf_0_GD)
data1 = cbind(data1, ECB_News_res_inf_0_eu)
data1 = cbind(data1, ECB_News_res_inf_1)
data1 = cbind(data1, ECB_News_res_inf_2_RWI)
data1 = cbind(data1, ECB_News_res_inf_2_GD)
data1 = cbind(data1, ECB_News_res_inf_2_eu)
data1 = cbind(data1, ECB_News_res_inf_3_RWI)
data1 = cbind(data1, ECB_News_res_inf_3_GD)
data1 = cbind(data1, ECB_News_res_inf_3_eu)
data1 = cbind(data1, ECB_News_res_inf_4_RWI)
data1 = cbind(data1, ECB_News_res_inf_4_GD)
data1 = cbind(data1, ECB_News_res_inf_4_eu)

###### Lags

lag_order = 12
nvar = dim(data1)[2]

data_lags = data.frame(matrix(nrow = (dim(data1) - lag_order), ncol = (lag_order*nvar)))

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
step = 5

###### Rolling average

for (col in colnames(data1)){
  
  name_role = paste(col, 'role', sep = '.')
  var_role = rollmean(data1[,col], step)
  var_role =c(rep(NA, step - 1), var_role)
  
  data1[,name_role] = var_role
}

data1 = data1[step:dim(data1)[1],]

data1$time = as.Date(strptime(data1$time, "%Y-%m-%d"))

#write_xlsx(data1, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed.xlsx')
write_xlsx(data1, 'D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')