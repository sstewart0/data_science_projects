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

#plot survival of large families
t5 <- table(train$Ticket,train$Survived)
colnames(t5) <- c("Survived","Died")
t5 <- cbind(t5,rowSums(t5))
colnames(t5)[3]<-c("Total")
length(which(t5[,2]==t5[,3]))/nrow(t5)

  