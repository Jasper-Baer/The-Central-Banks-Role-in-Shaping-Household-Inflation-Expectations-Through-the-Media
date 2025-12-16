#####################################################################################
# This file estimates the baseline inflation-expectations regressions (models [1]–[6]) on the
# monthly dataset using the news indicators directly (e.g., News.Inflation.Inc.).
#####################################################################################

library("readxl")
library("dplyr")
library("lmtest")
library("sandwich")
library("stats")
library("zoo")
library("ggplot2")
library("stargazer")
library("car")

#####################################################################################

DATA_PATH  <- "D:/Studium/PhD/Github/Single-Author/Code/Regression/Regession_data_monthly_2_processed_inf.xlsx"
START_DATE <- as.Date("2003-02-28")

source("D:/Studium/PhD/Github/Single-Author/Code/Regression/Inflation Expectations/Util.R")

dont_scale <- c(
  "draghi.Lag1","negative.Lag1","whatever.Lag1","Unmon.Lag1",
  "REC_2022_01","REC_2022_02","REC_2022_03","REC_2022_04","REC_2022_05","REC_2022_06",
  "REC_2022_07","REC_2022_08","REC_2022_09","REC_2022_10","REC_2022_11","REC_2022_12"
)

# Optional recession filter (set to NULL if not used)
recessions <- NULL
# recessions <- list(
#   c(as.Date("2001-02-01"), as.Date("2003-06-30")),
#   c(as.Date("2008-01-01"), as.Date("2009-04-30")),
#   c(as.Date("2020-02-01"), as.Date("2020-04-30"))
# )

data <- prepare_data(DATA_PATH, START_DATE, dont_scale, recessions)

#####################################################################################

# [1]

fit_no_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                               + German.Inflation.Balanced.difference.Lag1
                             + German.Inflation.Balanced.difference.Lag2
                             + German.Inflation.Balanced.difference.Lag3
                             
                             + News.Inflation.Inc.
                             + News.Inflation.Dec.
                             + News.Inflation.Pos.
                             + News.Inflation.Neg.
                             
                             + News.Monetary.Quote.Hawkish
                             + News.Monetary.Quote.Dovish
                             + News.Monetary.Quote.Pos.
                             + News.Monetary.Quote.Neg.
                             
                             + German.Inflation.Year.on.Year.difference.Lag1
                             + Reuter.Poll.Forecast.difference.Lag1
                             , data)

# [2]

fit_no_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                                   + German.Inflation.Balanced.difference.Lag1
                                 + German.Inflation.Balanced.difference.Lag2
                                 + German.Inflation.Balanced.difference.Lag3
                                 
                                 + News.Inflation.Inc.
                                 + News.Inflation.Dec.
                                 + News.Inflation.Pos.
                                 + News.Inflation.Neg.
                                 
                                 + News.Monetary.Non.Quote.Hawkish
                                 + News.Monetary.Non.Quote.Dovish
                                 + News.Monetary.Non.Quote.Pos.
                                 + News.Monetary.Non.Quote.Neg.
                                 
                                 + German.Inflation.Year.on.Year.difference.Lag1
                                 + Reuter.Poll.Forecast.difference.Lag1
                                 , data)

# [3]

fit_no_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                                     + German.Inflation.Balanced.difference.Lag1
                                   + German.Inflation.Balanced.difference.Lag2
                                   + German.Inflation.Balanced.difference.Lag3
                                   
                                   + News.Inflation.Inc.
                                   + News.Inflation.Dec.
                                   + News.Inflation.Pos.
                                   + News.Inflation.Neg.
                                   
                                   + News.Monetary.Quote.Hawkish*Quote_Ratio
                                   + News.Monetary.Quote.Dovish*Quote_Ratio
                                   + News.Monetary.Quote.Pos.*Quote_Ratio
                                   + News.Monetary.Quote.Neg.*Quote_Ratio
                                   
                                   + German.Inflation.Year.on.Year.difference.Lag1
                                   + Reuter.Poll.Forecast.difference.Lag1
                                   , data)

# [4]

fit_all_controls_quotes <- lm(German.Inflation.Balanced.difference ~
                                + German.Inflation.Balanced.difference.Lag1
                              + German.Inflation.Balanced.difference.Lag2
                              + German.Inflation.Balanced.difference.Lag3
                              
                              + News.Inflation.Inc.
                              + News.Inflation.Dec.
                              + News.Inflation.Pos.
                              + News.Inflation.Neg.
                              
                              + News.Monetary.Quote.Hawkish
                              + News.Monetary.Quote.Dovish
                              + News.Monetary.Quote.Pos.
                              + News.Monetary.Quote.Neg.
                              
                              + German.Inflation.Year.on.Year.difference.Lag1
                              + Reuter.Poll.Forecast.difference.Lag1
                              
                              + German.Industrial.Production.Gap.Lag1
                              + Germany.Unemployment.difference.Lag1
                              
                              + ECB.MRO.difference.Lag1
                              + draghi.Lag1
                              + negative.Lag1
                              + whatever.Lag1
                              
                              + Germany.Conf.difference.Lag1
                              
                              + ECB.MRO.POS.Lag1
                              + ECB.MRO.NEG.Lag1
                              + ED.Exchange.Rate.difference.Lag1
                              + Unmon.Lag1
                              + DAX.difference.Lag1
                              + VDAX.Lag1
                              , data)

# [5]

fit_all_controls_non_quotes <- lm(German.Inflation.Balanced.difference ~
                                    + German.Inflation.Balanced.difference.Lag1
                                  + German.Inflation.Balanced.difference.Lag2
                                  + German.Inflation.Balanced.difference.Lag3
                                  
                                  + News.Inflation.Inc.
                                  + News.Inflation.Dec.
                                  + News.Inflation.Pos.
                                  + News.Inflation.Neg.
                                  
                                  + News.Monetary.Non.Quote.Hawkish
                                  + News.Monetary.Non.Quote.Dovish
                                  + News.Monetary.Non.Quote.Pos.
                                  + News.Monetary.Non.Quote.Neg.
                                  
                                  + German.Inflation.Year.on.Year.difference.Lag1
                                  + Reuter.Poll.Forecast.difference.Lag1
                                  
                                  + German.Industrial.Production.Gap.Lag1
                                  + Germany.Unemployment.difference.Lag1
                                  
                                  + ECB.MRO.difference.Lag1
                                  + draghi.Lag1
                                  + negative.Lag1
                                  + whatever.Lag1
                                  
                                  + Germany.Conf.difference.Lag1
                                  
                                  + ECB.MRO.POS.Lag1
                                  + ECB.MRO.NEG.Lag1
                                  + ED.Exchange.Rate.difference.Lag1
                                  + Unmon.Lag1
                                  + DAX.difference.Lag1
                                  + VDAX.Lag1
                                  , data)

# [6]

fit_all_controls_quotes_count <- lm(German.Inflation.Balanced.difference ~
                                      + German.Inflation.Balanced.difference.Lag1
                                    + German.Inflation.Balanced.difference.Lag2
                                    + German.Inflation.Balanced.difference.Lag3
                                    
                                    + News.Inflation.Inc.
                                    + News.Inflation.Dec.
                                    + News.Inflation.Pos.
                                    + News.Inflation.Neg.
                                    
                                    + News.Monetary.Quote.Hawkish*Quote_Ratio
                                    + News.Monetary.Quote.Dovish*Quote_Ratio
                                    + News.Monetary.Quote.Pos.*Quote_Ratio
                                    + News.Monetary.Quote.Neg.*Quote_Ratio
                                    
                                    + Germany.Conf.difference.Lag1
                                    
                                    + German.Inflation.Year.on.Year.difference.Lag1
                                    + Reuter.Poll.Forecast.difference.Lag1
                                    
                                    + German.Industrial.Production.Gap.Lag1
                                    + Germany.Unemployment.difference.Lag1
                                    
                                    + ECB.MRO.difference.Lag1
                                    + draghi.Lag1
                                    + negative.Lag1
                                    + whatever.Lag1
                                    
                                    + ECB.MRO.POS.Lag1
                                    + ECB.MRO.NEG.Lag1
                                    
                                    + DAX.difference.Lag1
                                    + VDAX.Lag1
                                    
                                    + ED.Exchange.Rate.difference.Lag1
                                    
                                    + Unmon.Lag1
                                    , data)

#####################################################################################

fit1 <- fit_no_controls_quotes
fit2 <- fit_no_controls_non_quotes
fit3 <- fit_no_controls_quotes_count
fit4 <- fit_all_controls_quotes
fit5 <- fit_all_controls_non_quotes
fit6 <- fit_all_controls_quotes_count

res1 <- coeftable_df_nw12(fit1)
res2 <- coeftable_df_nw12(fit2)
res3 <- coeftable_df_nw12(fit3)
res4 <- coeftable_df_nw12(fit4)
res5 <- coeftable_df_nw12(fit5)
res6 <- coeftable_df_nw12(fit6)

adj1 <- round(summary(fit1)$adj.r.squared, 3)
adj2 <- round(summary(fit2)$adj.r.squared, 3)
adj3 <- round(summary(fit3)$adj.r.squared, 3)
adj4 <- round(summary(fit4)$adj.r.squared, 3)
adj5 <- round(summary(fit5)$adj.r.squared, 3)
adj6 <- round(summary(fit6)$adj.r.squared, 3)

obs1 <- nobs(fit1)
obs2 <- nobs(fit2)
obs3 <- nobs(fit3)
obs4 <- nobs(fit4)
obs5 <- nobs(fit5)
obs6 <- nobs(fit6)