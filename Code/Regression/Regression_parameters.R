model <- arima(data$News.ECB.Count, order = c(1, 0, 0))
model <- arima(data$ECB_News_res_inf_1, order = c(1, 0, 0))