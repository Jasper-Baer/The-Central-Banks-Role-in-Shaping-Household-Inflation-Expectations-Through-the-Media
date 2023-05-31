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

data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_quarterly.xlsx')
#data = read_excel('D:/Single Author/Github/Single-Author/Data/Regression/regression_data_monthly_2.xlsx')
data = data.frame(data)


#data$time = as.Date(strptime(data$time, "%Y-%m-%d"))

#data = data[9:dim(data)[1],]
#data = data[23:dim(data)[1],]

data = data[17:dim(data)[1],]

data1 = data %>% select(German.Industrial.Production, 
                        German.Inflation.Year.on.Year,
                        News.Inflation.Index, 
                        News.Inflation.Sentiment.Index, 
                        News.Inflation.Direction.Index,
                        News.Inflation.Count, 
                        News.ECB.Count, 
                        ECB.Inflation.Index, 
                        ECB.Monetary.Index, 
                        ECB.Economic.Index, 
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Real,
                        Reuter.Poll.Forecast) # mislabled

############################################
# Residuals - ECB and News Index
############################################

stand_ECB = scale(data$ECB.Inflation.Index)
stand_news = scale(data$News.Inflation.Index)

fit = lm(scale(ECB.Inflation.Index) ~ scale(News.Inflation.Index*-1), data1)
ECB_News_res_inf_1 = fit$residuals

#ECB_News_res_inf_1 = stand_ECB - stand_news

fit = lm(News.Inflation.Count ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_0_Reuter = fit$residuals

fit = lm(News.Inflation.Index*-1 ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_2_Reuter = fit$residuals

fit = lm(News.Inflation.Sentiment.Index ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_3_Reuter = fit$residuals

fit = lm(News.Inflation.Direction.Index*-1 ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_4_Reuter = fit$residuals

data1 = cbind(data1, ECB_News_res_inf_0_Reuter)
data1 = cbind(data1, ECB_News_res_inf_2_Reuter)
data1 = cbind(data1, ECB_News_res_inf_3_Reuter)
data1 = cbind(data1, ECB_News_res_inf_4_Reuter)

data1 = cbind(data1, ECB_News_res_inf_1)

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

data1$time = as.Date(strptime(data1$time, "%Y-%m-%d"))

write_xlsx(data1, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_quarterly_processed.xlsx')
#write_xlsx(data1, 'D:/Single Author/Github/Single-Author/Data/Regression/Regession_data_monthly_2_processed.xlsx')