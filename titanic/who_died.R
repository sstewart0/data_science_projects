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
View(age.train)
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
#need to look into WLS and/or GLS

#predictions for test set (i.e. NA values)
pred <- predict(lm.age5,train[which(is.na(train$Age)),])
pred <- round(pred^2,0)
train[is.na(train$Age),]$Age <- pred

#training error
pred.train <- predict(lm.age2)
pred.t <- round(pred.train^2,1)
sse <- sum((as.numeric(pred.t)-as.numeric(age.train$Age))^2)
mse1<-sse/(nrow(age.train)-7)

#Scale the age variable now
train$Age <- as.numeric(scale(train$Age))

#Age -vs- survival and Age -vs- Pclass
library(ggplot2)
ggplot(data=train2, aes(x=Age, group=Pclass, fill=Pclass)) +
  geom_density(adjust=1.5, alpha=.4)
#Age follows normal distribution in each class however each have different mean,sd.
#it appears that ages from pclass 2,3 could be drawn from the same (normal) distribution
#So; fit models separately to predict Age for each class and assess training error.

  #pclass==1
age.pclass1 <- lm(Age~Survived+Title+Parch,data = age.train[age.train$Pclass==1,])
summary(age.pclass1)
plot(age.pclass1)#heteroskedasticity possibly present
bptest(age.pclass1)#BP = 8.0288, df = 5, p-value = 0.1547 => cannot reject H_0:homoskedasticity
#assess training error
p1<-predict(age.pclass1)
mse1 <- (sum((as.numeric(p1)-as.numeric(age.train[age.train$Pclass==1,]$Age))^2))/(nrow(age.train)-6)#44.188

  #pclass==2,3
age.pclass23 <- lm(Age~Survived+Title+SibSp+Embarked,data = age.train[age.train$Pclass!=1,])
summary(age.pclass23)
plot(age.pclass23)#some funneling, no non-linearity
bptest(age.pclass2)#BP = 11.947, df = 6, p-value = 0.06317 => cannot reject H_0:homoskedasticity at alpha=0.05
#assess training error
p23<-predict(age.pclass23)
summary(p23)
mse23 <- (sum((as.numeric(p23)-as.numeric(age.train[age.train$Pclass!=1,]$Age))^2))/(nrow(age.train)-8)

#y ~ ... ; mse = 79.25 #negative ages present!!
#sqrt(y) ~ ... ; mse = 80.33

#pclass==2
age.pclass2 <- lm(Age~Title+SibSp+Embarked,data = age.train[age.train$Pclass==2,])
summary(age.pclass2)
plot(age.pclass2)#funneling, some non-linearity
bptest(age.pclass2)#BP = 11.947, df = 6, p-value = 0.06317 => cannot reject H_0:homoskedasticity at alpha=0.05
#assess training error
p2<-predict(age.pclass2)
summary(p2)
mse2 <- (sum((as.numeric(p2)-as.numeric(age.train[age.train$Pclass==2,]$Age))^2))/(nrow(age.train)-7)#30.25


#pclass==3
age.pclass3 <- lm(sqrt(Age)~Title+SibSp+Embarked+Survived,data = age.train[age.train$Pclass==3,])
summary(age.pclass3)
plot(age.pclass3)#very little/no funneling, possible non-linearity
bptest(age.pclass3)

#BP = 15.117, df = 7, p-value = 0.03453 => reject H_0
#try sqrt(y): BP = 12.338, df = 7, p-value = 0.08998 => do not reject H_0. better model, no more negative ages

#assess training error
p3<-predict(age.pclass3)^2
summary(p3)
mse3 <- (sum((as.numeric(p3)-as.numeric(age.train[age.train$Pclass==3,]$Age))^2))/(nrow(age.train)-8)#45.51

#average mse:
(mse1+mse2+mse3)/3 #39.99 much better result than fitting together but still not happy; 

#add cabin Y/N and refit?
cab<-rep(c(1),891)
train<-cbind(train,cab)
train[train$Cabin=="",]$cab<-c(0)
train$Age<-train2$Age
age.train <- train[which(!is.na(train$Age)),]
age.test <- train[which(is.na(train$Age)),]

#pclass==3
new.age.pclass3 <- lm(sqrt(Age)~Title+SibSp+Embarked+Survived+Survived+cab,data = age.train[age.train$Pclass==3,])
summary(new.age.pclass3)
View(new.age.pclass3$fitted.values^2)
plot(new.age.pclass3)#looks ok?
bptest(new.age.pclass3)#BP = 15.926, df = 8, p-value = 0.04345, add sqrt! BP = 9.8806, df = 8, p-value = 0.2735 => uh huh eskeetit
#transformed model has MSE = (0.956)^2 !!!


#predict NA ages:
na.pred1<-predict(age.pclass1,age.test[age.test$Pclass==1,])
na.pred2<-predict(age.pclass2,age.test[age.test$Pclass==2,])
#need to correct for E[y] since we took sqrt
na.pred3<-(predict(new.age.pclass3,age.test[age.test$Pclass==3,]))^2+sigma(new.age.pclass3)^2

#happy with ages from pclass 1 but not 2 or 3. H_0: underage
View(train[which(!is.na(train$Age)&train$Pclass!=1),])
train$Age<-train2$Age

train[is.na(train$Age)&train$Pclass==1,]$Age <- round(na.pred1,1)
train[is.na(train$Age)&train$Pclass==2,]$Age <- round(na.pred2,1)
train[is.na(train$Age)&train$Pclass==3,]$Age <- round(na.pred3,1)
View(train)



