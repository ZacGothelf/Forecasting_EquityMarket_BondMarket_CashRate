##STAT3038/6045 Actuarial Techniques
##Assignment 2
##Economic Modelling
##----------------------------------

#Uploading the dataset to the R environment
getwd()
library(tidyverse)


InvData <- read.csv("STAT 3038_6045 Assignment 2 - 2024 - Investment Details.csv")
names(InvData) <- c("Date", "Cash_rate", "Bond_index", "Equity_index")
InvData$Date <- as.Date(InvData$Date, format = "%d-%b-%Y")
InvData$Cash_rate <- sub("%","",InvData$Cash_rate)
InvData$Cash_rate <- as.numeric(InvData$Cash_rate)/100
InvData$Equity_index <- sub(",","",InvData$Equity_index)
InvData$Equity_index <- as.numeric(InvData$Equity_index)

#Creating plots
plot(InvData$Date, InvData$Cash_rate,
     main = "RBA Cash Rate Evolution (1976-2024)",
     xlab = "Date", ylab = "RBA Cash Rate",
     xlim = as.Date(c("1976-01-31","2024-06-30")),
     xaxs = "i", type = "l", col = "darkgreen")
plot(InvData$Date, InvData$Bond_index,
     main = "Bond Index Evolution (1987-2024)",
     xlab = "Date", ylab = "Domestic Bond Index",
     xlim = as.Date(c("1987-02-28","2024-06-30")),
     xaxs = "i", type = "l", col = "blue")
plot(InvData$Date, InvData$Equity_index,
     main = "Equity Index Evolution (1979-2024)",
     xlab = "Date", ylab = "Domestic Shares Index",
     xlim = as.Date(c("1979-12-31","2024-06-30")),
     xaxs = "i", type = "l", col = "red")

#Calculating the quarterly growth rates
InvDataQ <- subset(InvData, month(Date) == 3 | month(Date) == 6 | month(Date) == 9 | month(Date) == 12)
InvDataQ <- InvDataQ[InvDataQ$Date >= as.Date("1987-03-31"),]
plot(InvDataQ$Date, InvDataQ$Cash_rate,
     main = "RBA Cash Rate Evolution (1987-2024)",
     xlab = "Date", ylab = "RBA Cash Rate",
     xlim = as.Date(c("1987-03-31","2024-06-30")),
     xaxs = "i", type = "l", col = "darkgreen")
plot(InvDataQ$Date, InvDataQ$Bond_index,
     main = "Bond Index Evolution (1987-2024)",
     xlab = "Date", ylab = "Domestic Bond Index",
     xlim = as.Date(c("1987-03-31","2024-06-30")),
     xaxs = "i", type = "l", col = "blue")
plot(InvDataQ$Date, InvDataQ$Equity_index,
     main = "Equity Index Evolution (1987-2024)",
     xlab = "Date", ylab = "Domestic Shares Index",
     xlim = as.Date(c("1987-03-31","2024-06-30")),
     xaxs = "i", type = "l", col = "red")
Cash_rate.Inc <- numeric(length(InvDataQ$Cash_rate))
Cash_rate.Inc[1] <- NA
for(i in 2:length(InvDataQ$Cash_rate)){
  Cash_rate.Inc[i]<-InvDataQ$Cash_rate[i]-InvDataQ$Cash_rate[i-1]
}
Bond_index.Inc <- numeric(length(InvDataQ$Bond_index))
Bond_index.Inc[1] <- NA
for(i in 2:length(InvDataQ$Bond_index)){
  Bond_index.Inc[i]<-InvDataQ$Bond_index[i]/InvDataQ$Bond_index[i-1]-1
}
Equity_index.Inc <- numeric(length(InvDataQ$Equity_index))
Equity_index.Inc[1] <- NA
for(i in 2:length(InvDataQ$Equity_index)){
  Equity_index.Inc[i]<-InvDataQ$Equity_index[i]/InvDataQ$Equity_index[i-1]-1
}

#Selecting the period
InvDataQ <- cbind(InvDataQ, Cash_rate.Inc, Bond_index.Inc, Equity_index.Inc)
head(InvDataQ)
nrow(InvDataQ)
summary(InvDataQ)
round(cor(InvDataQ[, -c(1,5,6,7)]),2) #Correlation matrix
plot(InvDataQ$Date, InvDataQ$Equity_index.Inc,
     main = "Quarterly Returns per Asset Class (1987-2024)",
     xlab = "Date", ylab = "Quarterly Return",
     xlim = as.Date(c("1987-06-30","2024-06-30")),
     xaxs = "i", type = 'l', col = "red")
lines(InvDataQ$Date, InvDataQ$Bond_index.Inc, type = "l", col = "blue")
legend(9861, -0.3, legend = c("Bond Index","Equity Index"), 
       cex = 0.8, horiz = T, col = c("blue","red"), lty = c(1,1))
plot(InvDataQ$Date, InvDataQ$Cash_rate.Inc,
     main = "Cash Rate Quarterly Variation (1987-2024)",
     xlab = "Date", ylab = "Quarterly Variation",
     xlim = as.Date(c("1987-06-30","2024-06-30")),
     xaxs = "i", type = 'l', col = "darkgreen")
InvDataAdjQ <- InvDataQ[InvDataQ$Date >= as.Date("1997-06-30"),]
head(InvDataAdjQ)
nrow(InvDataAdjQ)
View(InvDataAdjQ)
round(cor(InvDataAdjQ[, -c(1,5,6,7)]),2)
round(cor(InvDataAdjQ[, -c(1,2,3,4)]),2)

install.packages("corrplot")
library(corrplot)

data <- data.frame(Cash_rate.Inc, Bond_index.Inc, Equity_index.Inc)
names(data) <- c("Cash Rate Change","Bond Index Return","Shares Index Return")
cor_matrix <- round(cor(data, use = "complete.obs"),2)

corrplot(cor_matrix, method = "number", col = colorRampPalette(c("red3","red2","red","white","green","green2","green3"))(100), 
         tl.col = "black", tl.cex = 0.8, cl.cex = 0.8,number.cex = 1.6)

#Estimating the initial models
pacf(InvDataAdjQ$Equity_index.Inc,na.action=na.pass)
acf(InvDataAdjQ$Equity_index.Inc,na.action=na.pass)
pacf(InvDataAdjQ$Bond_index.Inc,na.action=na.pass)
acf(InvDataAdjQ$Bond_index.Inc,na.action=na.pass)
pacf(InvDataAdjQ$Cash_rate.Inc,na.action=na.pass)
acf(InvDataAdjQ$Cash_rate.Inc,na.action=na.pass)
#Cash rate model
Cash_rate.model <- arima(InvDataAdjQ$Cash_rate.Inc, 
                         order = c(0,0,1), include.mean = T)
Cash_rate.model <- arima(InvDataAdjQ$Cash_rate.Inc, 
                         order = c(1,0,1), include.mean = T)
Cash_rate.model <- arima(InvDataAdjQ$Cash_rate.Inc, 
                         order = c(1,0,0), include.mean = T)
Cash_rate.model <- arima(InvDataAdjQ$Cash_rate.Inc, 
                         order = c(1,0,0), include.mean = F)
Cash_rate.model
qqnorm(as.numeric(residuals(Cash_rate.model)))
qqline(residuals(Cash_rate.model)) 
pacf(residuals(Cash_rate.model),na.action=na.pass)
acf(residuals(Cash_rate.model),na.action=na.pass)
#Bond index model
Bond_index.model <- lm(InvDataAdjQ$Bond_index.Inc~1)
summary(Bond_index.model)
qqnorm(as.numeric(residuals(Bond_index.model)))
qqline(residuals(Bond_index.model))
#Equity index model
Equity_index.model <- lm(InvDataAdjQ$Equity_index.Inc~1)
summary(Equity_index.model)
qqnorm(as.numeric(residuals(Equity_index.model)))
qqline(residuals(Equity_index.model))

#Estimating the final models

Cash_rate.Inc <- InvDataAdjQ$Cash_rate.Inc
Bond_index.Inc <- InvDataAdjQ$Bond_index.Inc
Equity_index.Inc <- InvDataAdjQ$Equity_index.Inc
ccf(Cash_rate.Inc,Equity_index.Inc)
acf(cbind(residuals(Cash_rate.model),
          residuals(Bond_index.model),
          residuals(Equity_index.model)))
#Cash Rate Final Model
Cash_rate.model <- arima(InvDataAdjQ$Cash_rate.Inc,order = c(1,0,0), 
                         include.mean = F)
pacf(residuals(Cash_rate.model),na.action=na.pass)
acf(residuals(Cash_rate.model),na.action=na.pass)
qqnorm(as.numeric(residuals(Cash_rate.model)))
qqline(residuals(Cash_rate.model)) 
#Bond Index Final Model
Bond_index.model <- lm(Bond_index.Inc ~ Cash_rate.Inc + Equity_index.Inc)
summary(Bond_index.model)
qqnorm(as.numeric(residuals(Bond_index.model)))
qqline(residuals(Bond_index.model))
#Equity Index Final Model
Equity_index.model <- lm(InvDataAdjQ$Equity_index.Inc ~ 1)
summary(Equity_index.model)
qqnorm(as.numeric(residuals(Equity_index.model)))
qqline(residuals(Equity_index.model))
#Check for no autocorrelation of residuals
Box.test(residuals(Cash_rate.model), lag = 10, type = "Ljung-Box")
Box.test(residuals(Bond_index.model), lag = 10, type = "Ljung-Box")
Box.test(residuals(Equity_index.model), lag = 10, type = "Ljung-Box")
#Checking everything is in order
length(residuals(Cash_rate.model))
length(residuals(Bond_index.model))
length(residuals(Equity_index.model))
acf(cbind(residuals(Cash_rate.model)[-1],
          residuals(Bond_index.model)[-1],
          residuals(Equity_index.model)[-1]))