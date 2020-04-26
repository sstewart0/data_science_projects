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

#Lasso regression on logistic regression to choose param's
library(glmnet)
#scale some columns
train$Fare <- as.numeric(scale(train$Fare))

#deal with missing age values
  # -> is there a pattern in missing values. There are 177/891 missing age values
  # -> regress age onto Survived, Pclass, SibSp, Title
  # -> train: Non-NA,   test: NA

age.test <- train[which(is.na(train$Age)),]
age.train <- train[which(!is.na(train$Age)),]

#replace age with nonscaled age

View(age.train)
lm.age <- lm(Age~Survived+Pclass+SibSp+Title,data = age.train)
plot(lm.age)
#Observations from lm.age: residuals-vs-fitted => heteroskedasticity, 
#residuals -vs- leverage => NO outliers/high leverage points.

#Test for heteroskedasticity:
library(lmtest)
bptest(lm.age)
#BP = 30.562, df = 6, p-value = 3.072e-05

#transform dependent variable
lm.age2 <- lm(sqrt(Age)~Survived+Pclass+SibSp+Title,data = age.train)
plot(lm.age2)
#Observations from lm.age2: residuals-vs-fitted => much less heteroskedasticity
  #however nonlinearity may exist. Solution: Add higher order terms for Pclass and/or SipSp?
    #chosen model below
lm.age5 <- lm(sqrt(Age)~Survived+poly(Pclass,2)+poly(SibSp,2)+Title,data = age.train)
summary(lm.age5)
plot(lm.age5)
#Still not happy with above model because the BP test still "detects" heteroskedasticity
#need to look into WLS and/or GLS

#predictions for test set (i.e. NA values)
pred <- predict(lm.age5,train[which(is.na(train$Age)),])
pred <- round(pred^2,0)
train[is.na(train$Age),]$Age <- pred

#training error
pred.train <- predict(lm.age5)
pred.t <- round(pred.train^2,1)
sse <- sum((as.numeric(pred.t)-as.numeric(age.train$Age))^2)
mse<-sse/(nrow(age.train)-7)
#Scale the age variable now
train$Age <- as.numeric(scale(train$Age))
summary(train2[is.na(train2$Age),])

nrow(age.test[age.test$Survived==0,])/nrow(age.test) #0.7062147
nrow(train[train$Survived==0,])/nrow(train) #0.6161616

nrow(age.test[age.test$Pclass==1,])/nrow(age.test)#0.1694915
nrow(train[train$Pclass==1,])/nrow(train)#0.2424242

nrow(age.test[age.test$Pclass==2,])/nrow(age.test)#0.06214689
nrow(train[train$Pclass==2,])/nrow(train)#0.2065095

nrow(age.test[age.test$Pclass==3,])/nrow(age.test)#0.7683616
nrow(train[train$Pclass==3,])/nrow(train)#0.5510662
boxplot(train2[train2$Pclass==3,]$Age)

