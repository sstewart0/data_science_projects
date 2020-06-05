train <- read.csv("train.csv")
test <- read.csv("test.csv")
View(train)

#missing values
summary(train)
train_na <- train[is.na(train$Age),] #177 missing ages

tab <- table(train_na$Pclass)
x <- c(tab[1]/length(which(train$Pclass==1)),tab[2]/length(which(train$Pclass==2)),tab[3]/length(which(train$Pclass==3)))
t_na <- rbind(tab,x)
rownames(t_na) <- c("Number","%")
#1:=216 , 2:=184 , 3:=491

#duplicates
nrow(duplicated(train)) #none

#Classes of embarkation destination
library(ggplot2)
t<-table(train$Pclass,train$Embarked)
t<-t[,-c(1)]
barplot(t, main="Embarkation Class",xlab="Embark Location",ylab="Count",
        col = c("red","green","blue"),beside=TRUE)+
  legend("topleft",c("1","2","3"),fill = c("red","green","blue"),title = "Class")

#survival  of classes
t2<-table(train$Survived,train$Pclass)
b<-barplot(t2, main="Survival of class",xlab="Class",ylab="Count",
        col = c("red","blue"),beside=TRUE)+
  legend("topleft",c("Died","Survived"),fill = c("red","blue"))

#boxplot of fare and class
boxplot(Fare~Pclass,data=train[train$Fare<500,],xlab = "Class",ylab="Fare",col="yellow",border="blue")

#survival  of sex
t3<-table(train$Survived,train$Sex)
t3<- round(prop.table(t3,2)*100,digits=0)
b2<-barplot(t3, main="Survival of Sex",xlab="Sex",ylab="%",
           col = c("red","blue"))+
  legend("topleft",c("Died","Survived"),fill = c("red","blue"))

#class and sex
t4<-table(train$Sex,train$Pclass)
rownames(t4)<-c("% Female", "% Male")
t4<- round(prop.table(t4,2)*100,digits=0)
b2<-barplot(t4, main="Sex breakdown of Class",xlab="Class",ylab="%",
            col = c("lightblue","lightgreen"))+
  legend("top",c("Female","Male"),fill = c("lightblue","lightgreen"))

#Name -> ["Mr,Mrs,..." , "Surname" , "Other names"]
titles <- rep(factor(c("Mr")),891)
train <- cbind(train,titles)
colnames(train)[13] <- "Title"
train$Title <- as.character(train$Title)
for (i in 1:891){
  if (grepl("Master",train$Name[i])==T){
    train$Title[i]<-"Master"
  }
  else if (grepl("Miss",train$Name[i])==T){
    train$Title[i]<-"Miss"
  }
  else if (grepl("Mrs",train$Name[i])==T){
    train$Title[i]<-"Mrs"
  }
}
train$Title <-as.factor(train$Title)
#surname
train <- cbind(train,sub('\\,.*', '', train$Name))
colnames(train)[14] <- "Surname"
#other names
train <- cbind(train,sub('.*\\.', '', train$Name))
colnames(train)[15] <- "OtherNames"

#survival of families
t5 <- table(train$Ticket,train$Survived)
colnames(t5) <- c("Died","Survived")
t5 <- cbind(t5,rowSums(t5))
colnames(t5)[3]<-c("Total")
prob <- round(((t5[,2]/t5[,3])*100),digits = 0)
t5 <- cbind(t5,prob)
colnames(t5)[4]<-c("percsurvive")
fam_name <- rep(NA,681)
t5 <- cbind(t5,fam_name)

ticket_class <- rep(NA,681)
t5 <- cbind(t5,ticket_class)

for ( i in 1:nrow(t5)) {
    if(all(as.character(train[train$Ticket==rownames(t5)[i],]$Surname[1])==as.character(train[train$Ticket==rownames(t5)[i],]$Surname))){
        t5[i,5] <- as.character(train[train$Ticket==rownames(t5)[i],]$Surname[1])
    }
    t5[i,6] <- train[train$Ticket==rownames(t5)[i],]$Pclass[1]
}
families <- as.data.frame(t5)
View(families)
families[!is.na(families$fam_name) & as.numeric(families$Total)>2 & families$ticket_class==1,]

#Age -vs- survival and Age -vs- Pclass
library(ggplot2)
ggplot(data=train2, aes(x=Age, group=Pclass, fill=Pclass)) +
  geom_density(adjust=1.5, alpha=.4)
#Age follows normal distribution in each class however each have different mean,sd.
#it appears that ages from pclass 2,3 could be drawn from the same (normal) distribution
#So; fit models separately to predict Age for each class and assess training error.

#pclass==2
age.pclass2 <- lm(Age~Title+SibSp+Embarked,data = age.train[age.train$Pclass==2,])
summary(age.pclass2)
plot(age.pclass2)#funneling, some non-linearity
bptest(age.pclass2)#BP = 11.947, df = 6, p-value = 0.06317 => cannot reject H_0:homoskedasticity at alpha=0.05
#assess training error
p2<-predict(age.pclass2)
summary(p2)
mse2 <- (sum((as.numeric(p2)-as.numeric(age.train[age.train$Pclass==2,]$Age))^2))/(nrow(age.train)-7)#30.25

#add cabin Y/N
cab<-rep(c(1),891)
train<-cbind(train,cab)
train[train$Cabin=="",]$cab<-c(0)

train$cab <- as.factor(train$cab)
train$Embarked <- as.factor(train$Embarked)
train$Title <- as.factor(train$Title)

#PCA
library(ggfortify)
train$Age <- scale(train$Age)
pca <- prcomp(dplyr::select_if(train[,-c(1,2,3,16)], is.numeric))
pca #72% of variation in data explained by pca1,pca2.
summary(pca)
autoplot(pca,data=train,colour='Survived',loadings=T,loadings.label=T)

#correlation between PC_k and X_j? = (lambda_k . v_jk)/sd(X_j)
cor.pc1.age <- (pca$sdev[1]*pca$rotation[1,1])/sd(train$Age)#0.6219
cor.pc1.SibSp <- (pca$sdev[1]*pca$rotation[2,1])/sd(train$SibSp)#-0.8942
cor.pc1.Parch <- (pca$sdev[1]*pca$rotation[3,1])/sd(train$Parch)#-0.6218
cor.pc1.Fare <- (pca$sdev[1]*pca$rotation[4,1])/sd(train$Fare)#-0.2863

cor.pc2.age <- (pca$sdev[2]*pca$rotation[1,2])/sd(train$Age)#0.5566
cor.pc2.SibSp <- (pca$sdev[2]*pca$rotation[2,2])/sd(train$SibSp)#0.0219
cor.pc2.Parch <- (pca$sdev[2]*pca$rotation[3,2])/sd(train$Parch)#0.1773
cor.pc2.Fare <- (pca$sdev[2]*pca$rotation[4,2])/sd(train$Fare)#0.8756

#clustering
#k-means
set.seed(1)
k.clus <- kmeans(dplyr::select_if(train[,-c(1)], is.numeric),2,nstart = 20)
k.clus$centers

#treat class,survived,cab as catagorical
train$Survived<-as.factor(train$Survived)
train$Pclass<-as.factor(train$Pclass)
train$cab<-as.factor(train$cab)

#Add relevant columns to test set
  #Name -> ["Mr,Mrs,..." , "Surname" , "Other names"]
titles_test <- rep(factor(c("Mr")),nrow(test))
test <- cbind(test,titles_test)
colnames(test)[12] <- "Title"
test$Title <- as.character(test$Title)
for (i in 1:nrow(test)){
  if (grepl("Master",test$Name[i])==T){
    test$Title[i]<-"Master"
  }
  else if (grepl("Miss",test$Name[i])==T){
    test$Title[i]<-"Miss"
  }
  else if (grepl("Mrs",test$Name[i])==T){
    test$Title[i]<-"Mrs"
  }
}
test$Title<-as.factor(test$Title)

#Add cabin Y or N ->
cab_test<-rep(c(1),nrow(test))
test<-cbind(test,cab_test)
colnames(test)[13]<-"cab"
test[test$Cabin=="",]$cab<-c(0)

#Change variable to factor
test$Pclass<-as.factor(test$Pclass)
test$cab<-as.factor(test$cab)

#Age as numeric
test$Age<-as.numeric(test$Age)

#Add survived
Survived<-rep(0,418)
library(tibble)
test<-add_column(test, Survived, .after = "PassengerId")

#deal with missing age values
age.test <- train[which(is.na(train$Age)),]
age.train <- train[which(!is.na(train$Age)),]

age.train <- rbind(age.train,test[which(!is.na(test$Age)),])
age.test<- rbind(age.test,test[which(is.na(test$Age)),])

apply(is.na(age.train),2,which)#1531,836
age.train<-age.train[-c(836,1531),]

library(tidyverse)
library(caret)
set.seed(123)
train.control <- trainControl(method = "cv", number = 10)
lasso_model <- train(log(Age) ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "lasso",
                     trControl = train.control)
ages<-predict(lasso_model)
ages<-exp(ages)*exp(lasso_model$finalModel$sigma2^2)
r<-(age.train$Age-ages)

#LS
ls_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "lm",
                  trControl = train.control)
print(ls_model)

#PLS
pls_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "pls",
                   trControl = train.control)
print(pls_model)

#Ridge
ridge_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "ridge",
                     trControl = train.control)
print(ridge_model)

#Lasso
lasso_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "lasso",
                     trControl = train.control)
print(lasso_model)

#PCR
pcr_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "pcr",
                   trControl = train.control)
print(pcr_model)

#KNN
knn_model <- train(Age ~ Pclass+Sex+SibSp+Parch+Fare+Embarked+Title+cab, data = age.train, method = "knn",
                   trControl = train.control)
print(pcr_model)

#Compare RMSE of models
results <- resamples(list(LS=ls_model,RIDGE=ridge_model,LASSO=lasso_model,PCR=pcr_model,PLS=pls_model,KNN=knn_model))
bwplot(results,metric="RMSE")

#log-linear model => less funneling however slight non-linear trend in residual-vs-response
plot(ages, r, ylab = "residual")+abline(0,0,col="red")
mse.ages<-sum((ages-age.train$Age)^2)/length(ages)

#Predicted ages -> data
age_test<-test[is.na(test$Age),]
age_train<-train[is.na(train$Age),]

#missing test ages
new_ages_test<-predict(lasso_model,newdata=age_test)
new_ages_test<-exp(new_ages_test)*exp(lasso_model$finalModel$sigma2^2)

#missing train ages
new_ages_train<-predict(lasso_model,newdata=age_train)
new_ages_train<-exp(new_ages_train)*exp(lasso_model$finalModel$sigma2^2)

#insert ages into respective datasets
train[is.na(train$Age),]$Age<-round(new_ages_train,1)
test[is.na(test$Age),]$Age<-round(new_ages_test,1)

apply(is.na(test),2,which)
apply(is.na(train),2,which)

#penalised logistic regression using lasso -> model selection
#glmnet cannot handle factors directly we must create dummy variables using model.matrix
library(glmnet)
set.seed(1)
train$Pclass<-as.factor(train$Pclass)
train[train$Embarked=="",]#62,830
train<-train[-c(62,830),]
train$Embarked<-as.factor(train$Embarked)
x <- model.matrix( ~ .-1, train[,c(3,5,6,7,8,10,12,13,14)])
fit <- glmnet(x,train$Survived,family = "binomial", alpha = 1)
plot(fit, xvar = "dev", label = TRUE)
cvfit = cv.glmnet(x, train$Survived, family = "binomial", type.measure = "class")
coef(cvfit, s = "lambda.min")

#has removed EmbarkedQ,Pclass2
pred.glm <- predict(cvfit, newx = x,type = "class", s = "lambda.min")

err_1st <- nrow(train[train$Survived!=pred.glm &train$Pclass==1,])/nrow(train[train$Pclass==1,])
err_2nd <- nrow(train[train$Survived!=pred.glm &train$Pclass==2,])/nrow(train[train$Pclass==2,])
err_3rd <- nrow(train[train$Survived!=pred.glm &train$Pclass==3,])/nrow(train[train$Pclass==3,])

#Test[153,]$Fare missing
E_Fare<-(sum(train[train$Pclass==3,]$Fare)+sum(test[test$Pclass==3 &!is.na(test$Fare),]$Fare))/
  (nrow(train[train$Pclass==3,])+nrow(test[test$Pclass==3 &!is.na(test$Fare),]))
test[153,]$Fare<-round(E_Fare,2)

#Make survived predictions:
set.seed(1)
x2 <- model.matrix( ~ .-1, test[,c(3,5,6,7,8,10,12,13,14)])
pred.surv <- predict(cvfit, newx = x2,type = "class", s = "lambda.min")
test$Survived<-pred.surv
summary(test$Survived)

#Output predictions
my_pred<-cbind(test$PassengerId,test$Survived)
colnames(my_pred)[1]<-"PassengerId"
colnames(my_pred)[2]<-"Survived"
write.csv(my_pred,'my-predictions.csv',row.names = F)


