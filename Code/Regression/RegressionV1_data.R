# Loading
library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")
library("openxlsx")

#####################################################################################

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly.xlsx')
#data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/regression_data_monthly.xlsx')
data = data.frame(data)

data1 = data %>% select(German.Absolute.Expectations.Gap.Berk,German.Relative.Expectations.Gap.Berk,German.Absolute.Expectations.Gap.Role,German.Relative.Expectations.Gap.Role,
                        ECB.DFR ,Eurozone.Industrial.Production, German.Industrial.Production, News.Inflation.Index, News.Inflation.Count, 
                        ECB.Inflation.Index, ECB.Monetary.Index, ECB.Economic.Index, News.ECB.Count, Germany.Inflation.Professionell.Forecasts, 
                        Eurozone.Inflation, German.Inflation.Year.on.Year, German.Household.Inflation.Expectations, German.Household.Inflation.Expectations.Berk,
                        Eurozone.Inflation.Professionell.Forecasts, German.Household.Inflation.Expectations.Balanced,
                        News.Inflation.Sentiment.Index, News.Inflation.Direction.Index)

############################################
# Residuals - ECB and News Index
############################################

fit = lm(ECB.Inflation.Index ~ News.Inflation.Index + News.Inflation.Count, data1)
ECB_News_res_inf_1 = fit$residuals

fit = lm(News.Inflation.Index ~ Germany.Inflation.Professionell.Forecasts, data1)
ECB_News_res_inf_2 = fit$residuals

data1 = cbind(data1, ECB_News_res_inf_1)
data1 = cbind(data1, ECB_News_res_inf_2)

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
step = 3

###### Rolling average

for (col in colnames(data1)){
  
  name_role = paste(col, 'role', sep = '.')
  var_role = rollmean(data1[,col], step)
  var_role =c(rep(NA, step - 1), var_role)
  
  data1[,name_role] = var_role
}

data1 = data1[step:dim(data1)[1],]

fit = lm(ECB.Inflation.Index.role ~ News.Inflation.Index + News.Inflation.Count, data1)
ECB_News_res_inf_3 = fit$residuals

data1 = cbind(data1, ECB_News_res_inf_3)

data1$time = as.Date(strptime(data1$time, "%Y-%m-%d"))

write.xlsx(data1, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data.xlsx')
#write.xlsx(data1, 'D:/Single Author/Github/Single-Author/Data/Regression/regression_data_monthly.xlsx')