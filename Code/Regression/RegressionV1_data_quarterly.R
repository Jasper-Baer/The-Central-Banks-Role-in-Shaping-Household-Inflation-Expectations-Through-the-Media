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
#data = read_excel('D:/Studium/PhD/Github/Single-Author/Data/Regression/regression_data_monthly_2.xlsx')
#data = read_excel('D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/regression_data_quarterly.xlsx')
#data = read_excel('D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/regression_data_monthly_2.xlsx')

data = data.frame(data)

#data = data[9:dim(data)[1],]
data = data[17:dim(data)[1],]
#data = data[13:dim(data)[1],]

#data = data[17:dim(data)[1],]

data1 = data %>% select(PRINTO01DEQ659S,
                        German.Industrial.Production, 
                        German.Inflation.Year.on.Year,
                        News.Inflation.Index, 
                        News.Inflation.Sentiment.Index, 
                        News.Inflation.Direction.Index,
                        News.Inflation.Count, 
                        News.ECB.Count, 
                        ECB.Inflation.Index, 
                        ECB.Monetary.Index, 
                        ECB.Economic.Index, 
                        German.Absolute.Real.Inflation.Expectations.Gap.Stm.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Stm.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Stm.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Stm.Real,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Mean.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Mean.Real,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.Median.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.Median.Real,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.1stQuartile.Real,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Reuter,
                        German.Absolute.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Real,
                        German.Relative.Real.Inflation.Expectations.Gap.Quant.3rdQuartile.Real,
                        Reuter.Poll.Forecast) # mislabled

############################################
# Residuals - ECB and News Index
############################################

data1$News.Inflation.Index = data1$News.Inflation.Index*-1

ECB_News_diff_inf_1 = scale(data1$ECB.Inflation.Index) - scale(data1$News.Inflation.Index)

fit = lm(scale(ECB.Inflation.Index) ~ scale(News.Inflation.Index), data1)
ECB_News_diff_inf_2 = fit$residuals

ECB_News_res_inf_1 = lm(ECB.Inflation.Index ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_1 = fit$residuals

fit = lm(News.Inflation.Count ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_0_Reuter = fit$residuals

fit = lm(News.Inflation.Index ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_2_Reuter = fit$residuals

fit = lm(News.Inflation.Sentiment.Index ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_3_Reuter = fit$residuals

fit = lm(News.Inflation.Direction.Index ~ Reuter.Poll.Forecast, data1)
ECB_News_res_inf_4_Reuter = fit$residuals

data1 = cbind(data1, ECB_News_res_inf_0_Reuter)
data1 = cbind(data1, ECB_News_res_inf_2_Reuter)
data1 = cbind(data1, ECB_News_res_inf_3_Reuter)
data1 = cbind(data1, ECB_News_res_inf_4_Reuter)

data1 = cbind(data1, ECB_News_res_inf_1)

data1 = cbind(data1, ECB_News_diff_inf_1)
data1 = cbind(data1, ECB_News_diff_inf_2)

###### Lags

# lag_order = 4
# nvar = dim(data1)[2]
# 
# data_lags = data.frame(matrix(nrow = (dim(data1) - lag_order), ncol = (lag_order*nvar)))
# 
# lag_names = c()
# 
# for (l in 1:lag_order)
# {
#   data_lags[,((l-1)*nvar+1):(l*nvar)] = data1[(l):(dim(data1)[1]-lag_order + l -1),]
#   col_names = names(data1[(l):(dim(data1)[1]-lag_order + l -1),])
#   lag_names = c(lag_names, paste(col_names, gsub(" ", "", paste("Lag",as.character(l), "")), sep="."))
# }
# 
# names(data_lags) = lag_names
# time = data[,1]
# names(time) = "Date"
# data1 = cbind(data1, time)
# data1 = data1[(lag_order+1):dim(data1)[1],]
# data1 = cbind(data1, data_lags)
# 
# test1 = data1


library(dplyr)

lag_order = 4
nvar = dim(data1)[2]

# Create a new data frame to store the lagged data
#data_lags = data.frame()
data_lags = data.frame(matrix(nrow = nrow(data1), ncol = 0))

# Loop over each variable in the data
for (var in names(data1)[2:dim(data1)[2]]) {
  # Loop over each lag order
  for (l in 1:lag_order) {
    # Create a new variable name for the lagged variable
    new_var_name = paste(var, gsub(" ", "", paste("Lag", as.character(l), "")), sep=".")

    # Create the lagged variable and add it to the data_lags data frame
    data_lags[[new_var_name]] = lag(data1[[var]], l)
  }
}

# Bind the original data and the lagged data together
data1 = cbind(data1, data_lags)


#step = 3

###### Rolling average

#for (col in colnames(data1)){
  
#  name_role = paste(col, 'role', sep = '.')
#  var_role = rollmean(data1[,col], step)
#  var_role =c(rep(NA, step - 1), var_role)
  
#  data1[,name_role] = var_role
#}

#data1 = data1[step:dim(data1)[1],]

data1$time = as.Date(strptime(data1$PRINTO01DEQ659S, "%Y-%m-%d"))

###

# Add time effect dummies

data1$GR = ifelse(data1$time > as.Date("2008-09-15"), 1, 0)
data1$debt = ifelse(data1$time > as.Date("2010-01-01"), 1, 0)
data1$whatever = ifelse(data1$time > as.Date("2012-07-01"), 1, 0)
data1$forward = ifelse(data1$time > as.Date("2013-07-01"), 1, 0)
data1$ni = ifelse(data1$time > as.Date("2014-06-05"), 1, 0)
data1$qe = ifelse(data1$time > as.Date("2015-01-22"), 1, 0)
data1$brexit = ifelse(data1$time > as.Date("2016-06-23"), 1, 0)

data1$trichet = ifelse(data1$time >= as.Date("2003-11-01") & data1$time <= as.Date("2011-10-31"), 1, 0)
data1$draghi = ifelse(data1$time >= as.Date("2011-11-01") & data1$time <= as.Date("2019-10-31"), 1, 0)
data1$lagarde = ifelse(data1$time >= as.Date("2019-11-01"), 1, 0)

###

write_xlsx(data1, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_quarterly_processed.xlsx')
#write_xlsx(data1, 'D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_processed.xlsx')
#write_xlsx(data1, 'D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/Regession_data_quarterly_processed.xlsx')
#write_xlsx(data1, 'D:/Single Author/Github_fresh/Single_Author_fresh/Data/Regression/Regession_data_monthly_processed.xlsx')