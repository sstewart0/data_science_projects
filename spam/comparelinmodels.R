library(DAAG)
spam_data<-spam7
YN <- rep(0,nrow(spam_data))
spam_data <- cbind(spam_data,YN)
spam_data[spam_data$yesno=="y",]$YN<-1

#normalise input
spam_data[,-c(7,8)]<-scale(spam_data[,-c(7,8)])

#Visualisation
library(tidyverse)
#CV-methods
library(caret)
names(getModelInfo())
set.seed(123)
train.control <- trainControl(method = "cv", number = 10)

#LS
ls_model <- train(YN ~.-yesno, data = spam_data, method = "lm",
               trControl = train.control)
print(ls_model)

#PLS
pls_model <- train(YN ~.-yesno, data = spam_data, method = "pls",
                  trControl = train.control)
print(pls_model)

#Ridge
ridge_model <- train(YN ~.-yesno, data = spam_data, method = "ridge",
                   trControl = train.control)
print(ridge_model)

#Lasso
lasso_model <- train(YN ~.-yesno, data = spam_data, method = "lasso",
                     trControl = train.control)
print(lasso_model)

#PCR
pcr_model <- train(YN ~.-yesno, data = spam_data, method = "pcr",
                     trControl = train.control)
print(pcr_model)

#Compare RMSE of models
results <- resamples(list(LS=ls_model,RIDGE=ridge_model,LASSO=lasso_model,PCR=pcr_model,PLS=pls_model))
bwplot(results,metric = "RMSE")
