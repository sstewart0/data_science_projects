library(ISLR)
cardata <- Carseats
View(cardata)

#2a -> Create train and test data sets
set.seed(123)
train_ind <- sample(seq_len(nrow(cardata)), size = 300)

train <- cardata[train_ind, ]
test <- cardata[-train_ind, ]


#2b -> fit a regression tree

install.packages("tree")
library(tree)

reg.tree <- tree(Sales~.,data=train)
summary(reg.tree)

plot(reg.tree)
text(reg.tree,pretty=0)

#Test prediction accuracy of regression tree
tree.pred <- predict(reg.tree,test)
test.mse <- mean((test$Sales-tree.pred)^2)
test.mse


#2c -> find optimal tree size using CV
cv.reg.tree <- cv.tree(reg.tree, ,FUN=prune.tree)
plot(cv.reg.tree$size,cv.reg.tree$dev,type='b')

#prune tree
prune.reg.tree <- prune.tree(reg.tree,best = 10)
plot(prune.reg.tree)
text(prune.reg.tree,pretty=0)

pred.prune <- predict(prune.reg.tree,test)
prune.mse <- mean((pred.prune-test$Sales)^2)
prune.mse

#2d -> perform bagging (rf with m=p)
install.packages("randomForest")
library(randomForest)
set.seed(1)
bag.carseats <- randomForest(Sales~.,data=train,mtry=10,importance=T)
bag.carseats

#Test prediction accuracy of bagging
bag.pred <- predict(bag.carseats,test)
mse.bag <- mean((bag.pred-test$Sales)^2)
mse.bag

#2e -> random forest with different m
set.seed(1)
rf.mse.carseats <- c(1:9)
for (i in 1:9){
  rf.carseats <- randomForest(Sales~.,data=train,mtry=i,importance=T)
  rf.pred <- predict(rf.carseats,test)
  mse.rf <- mean((rf.pred-test$Sales)^2)
  rf.mse.carseats[i]=mse.rf
}
rf.mse.carseats
plot(rf.mse.carseats)

#rf with m=6
set.seed(1)
rf.carseats.6 <- randomForest(Sales~.,data=train,mtry=6,importance=T)
rf.pred.6 <- predict(rf.carseats.6,test)
mse.rf.6 <- mean((rf.pred.6-test$Sales)^2)
mse.rf.6

#importance
importance(bag.carseats)
importance(rf.carseats.6)

