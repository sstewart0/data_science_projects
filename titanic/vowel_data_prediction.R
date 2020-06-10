install.packages("mlbench")
library(mlbench)
View(train)
train<-Vowel[1:528,]
test<-Vowel[-c(1:528),]

library(MASS)
?qda
qda1 <- qda(Class~.-V1,data=train)
qda1$scaling
pred<-predict(qda1,type= "class")
#Training error
length(which(pred$class!=train$Class))/nrow(train)
table(train$Class,pred$class)
#Very low

#Test error
pred2<-predict(qda1,newdata=test,type= "class")
length(which(pred2$class!=test$Class))
table(test$Class,pred2$class)
#Very high => severe overfitting

#Cross validation using caret package
library(caret)
library(tidyverse)

set.seed(1)
qda2<-train(Class ~ .-V1,
            data = train,
            method = "qda",
            trControl = trainControl(method = "cv",number=5))
predtrain<-predict(qda2)
length(which(predtrain!=train$Class))
table(train$Class,predtrain)

set.seed(1)
predtest<-predict(qda2,newdata=test)
length(which(predtest!=test$Class))
table(test$Class,predtest)

#LDA better?
lda1<-train(Class ~ .-V1,
            data = train,
            method = "lda",
            trControl = trainControl(method = "cv"))
lda.pred.train<-predict(lda1)
length(which(lda.pred.train!=train$Class))

lda.pred.test<-predict(lda1,newdata=test)
length(which(lda.pred.test!=test$Class))
table(test$Class,lda.pred.test)

#Multinomial (with tuning parameter -> neural network)
multinom1<-train(Class ~ .-V1,
            data = train,
            method = "multinom",
            trControl = trainControl(method = "cv"),
            trace=F)

multinom.pred.test<-predict(multinom1,newdata=test)
length(which(multinom.pred.test!=test$Class))
table(test$Class,multinom.pred.test)

results <- resamples(list(LDA=lda1,QDA=qda2,MULTINOM=multinom1))
bwplot(results,metric = "Accuracy")

#CV on removing each person and fitting qda on remaining people
#Manual CV -> representative of predicting on "new people".

err<-rep(0,8)
for (i in 0:7){
  q<-qda(Class~.-V1,data=train[train$V1!=i,])
  p<-predict(q,newdata=train[train$V1==i,],type="class")
  err[i+1]<-length(which(p$class!=train[train$V1==i,]$Class))
}
View(err)
avg_err<-(mean(err)/66)
#~59% misclassification error rate which is closer to the error rate observed
