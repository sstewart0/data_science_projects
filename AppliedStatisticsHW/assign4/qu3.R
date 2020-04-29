#3a -> create data set with quadratic decision boundary
x1=runif (500) -0.5
x2=runif (500) -0.5
y=1*( x1^2-x2^2 > 0)

my.data <- data.frame(x1,x2,y)
View(my.data)


#3b -> plot data
plot(x1[y == 0], x2[y == 0], col = "red", xlab = "X1", ylab = "X2", pch = 1)
points(x1[y == 1], x2[y == 1], col = "blue", pch = 8)

install.packages("e1071")
library(e1071)

#3c -> support vector classifier (svm using linear kernel)
svc.fit <- svm(as.factor(y)~.,data=my.data,kernel="linear",cost=10,scale=F)

#create predictions using svc
svc.pred = predict(svc.fit, my.data)

#split predictions
data.pos = my.data[svc.pred == 1, ]
data.neg = my.data[svc.pred == 0, ]

#Create plots of predicted points
plot(data.pos$x1, data.pos$x2, col = "blue", xlab = "X1", ylab = "X2", pch = 8)
points(data.neg$x1, data.neg$x2, col = "red", pch = 1)


#3d -> support vector machine (svm using radial kernel)
svc.fit <- svm(as.factor(y)~.,data=my.data,kernel="radial",gamma=1,cost=1)

#create predictions using svm
svm.pred = predict(svm.fit, my.data)

#split predictions
data.pos.svm = my.data[svm.pred == 1, ]
data.neg.svm = my.data[svm.pred == 0, ]

#Create plots of predicted points
plot(data.pos.svm$x1, data.pos.svm$x2, col = "blue", xlab = "X1", ylab = "X2", pch = 8)
points(data.neg.svm$x1, data.neg.svm$x2, col = "red", pch = 1)
