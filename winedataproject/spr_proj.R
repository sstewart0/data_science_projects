install.packages("glmnet", repos = "http://cran.us.r-project.org")
install.packages("corrplot")

install.packages("sjPlot")
library(sjPlot)
library(sjmisc)
library(sjlabelled)
View(winedata_unique)
winequality.white<- read.csv("~/OneDrive - University of Birmingham/Year3/AS/spring/project/wine_data/winequality-white.csv", sep=";")
winequality.red<- read.csv("~/OneDrive - University of Birmingham/Year3/AS/spring/project/wine_data/winequality-red.csv", sep=";")

#add dummy variable for wine colour
winequality.red['color'] <- 'red'
winequality.white['color'] <- 'white'

#combine wines
winedata <- rbind(winequality.red,winequality.white)
str(winedata)

#check for missing values
sum(is.na(winedata)) #none
#check for duplicate values
library(tidyverse)
sum(duplicated(winedata))

#remove them
library(dplyr)
winedata_unique <- winedata[!duplicated(winedata),]
wd_red <- winedata_unique[winedata_unique$color=='red',]
wd_wt <- winedata_unique[winedata_unique$color=='white',]

#correlation matrix
library(corrplot)
cor_red <- corrplot.mixed(corr=cor(wd_red[,c(1:12)]),lower.col = "black",tl.pos = "lt",order="FPC")
cor_white <- corrplot.mixed(corr=cor(wd_wt[,c(1:12)]),lower.col = "black",tl.pos = "lt",order="FPC")

#boxplots
summary(winedata_unique[winedata_unique$color=="red",])
summary(winedata_unique[winedata_unique$color=="white",])

#fixed.acidity
boxplot(fixed.acidity~color,data=winedata_unique,xlab = "Colour",ylab="Fixed Acidity",col="yellow",border="blue")
#volatile.acidity
boxplot(volatile.acidity~color,data=winedata_unique,xlab = "Colour",ylab="Volatile Acidity",col="yellow",border="blue")
#citric.acid
boxplot(citric.acid~color,data=winedata_unique,xlab = "Colour",ylab="Citric Acid",col="yellow",border="blue")
#residual.sugar
boxplot(residual.sugar~color,data=winedata_unique,xlab = "Colour",ylab="Residual Sugar",col="yellow",border="blue")
#chlorides
boxplot(chlorides~color,data=winedata_unique,xlab = "Colour",ylab="Chlorides",col="yellow",border="blue")
#free.sulfur.dioxide
boxplot(free.sulfur.dioxide~color,data=winedata_unique,xlab = "Colour",ylab="Free Sulfur Dioxide",col="yellow",border="blue")
#total.sulfur.dioxide
boxplot(total.sulfur.dioxide~color,data=winedata_unique,xlab = "Colour",ylab="Total Sulfur Dioxide",col="yellow",border="blue")
#density
boxplot(density~color,data=winedata_unique,xlab = "Colour",ylab="Density",col="yellow",border="blue")
#pH
boxplot(pH~color,data=winedata_unique,xlab = "Colour",ylab="pH",col="yellow",border="blue")
#sulphates
boxplot(sulphates~color,data=winedata_unique,xlab = "Colour",ylab="Sulphates",col="yellow",border="blue")
#alcohol
boxplot(alcohol~color,data=winedata_unique,xlab = "Colour",ylab="Alcohol",col="yellow",border="blue")


#property plots for red and white wines
ggplot(data = winedata, aes(y = fixed.acidity, x = quality)) +
  geom_point(alpha = 1/4, position = position_jitter(h = 0), size = 2) +
  facet_wrap(~ color)


#plot density of properties for red and white wines to assess normality

#Fixed Acidity
qplot(fixed.acidity, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Fixed Acidity",ylab="Density",main="Density Plot of Fixed Acidity")
#Volatile Acidity
qplot(volatile.acidity, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Volatile Acidity",ylab="Density",main="Density Plot of Volatile Acidity")
#Citric Acid
qplot(citric.acid, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Citric Acid",ylab="Density",main="Density Plot of Citric Acid")
#residual sugar
qplot(residual.sugar, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Residual Sugar",ylab="Density",main="Density Plot of Residual Sugar")+
  xlim(c(0,20))
#Chlorides
qplot(chlorides, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Chlorides",ylab="Density",main="Density Plot of Chlorides")+
  xlim(c(0,.2))
#free.sulfur.dioxide
qplot(free.sulfur.dioxide, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Free Sulfur Dioxide",ylab="Density",main="Density Plot of Free Sulfur Dioxide")+
xlim(c(0,100))
#total.sulfur.dioxide
qplot(total.sulfur.dioxide, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Total Sulfur Dioxide",ylab="Density",main="Density Plot of Total Sulfur Dioxide")+
  xlim(c(0,270))
#density
qplot(density, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Density",ylab="Density",main="Density Plot of Density")+
  xlim(c(.98,1.01))
#pH
qplot(pH, data = winedata_unique, geom="density",color=color,linetype=color,xlab="pH",ylab="Density",main="Density Plot of pH")
#sulphates
qplot(sulphates, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Sulphates",ylab="Density",main="Density Plot of Sulphates")+
  xlim(c(0,1.5))
#alcohol
qplot(alcohol, data = winedata_unique, geom="density",color=color,linetype=color,xlab="Alcohol",ylab="Density",main="Density Plot of Alcohol")
  xlim(c(0,1.5))


#test if means of properties are similar for red and white data
var.test(winequality.red$quality,winequality.white$quality)
t.test(winequality.red$quality,winequality.white$quality,paired=FALSE,var.equal = F)

#standardise data
winedata_unique[1:11] <- scale(winedata_unique[1:11],center=T,scale=T)

#Add column for quality classification

winedata_unique$rating[5>=winedata_unique$quality]='Poor'
winedata_unique$rating[winedata_unique$quality>5 & winedata_unique$quality<8]='Good'
winedata_unique$rating[winedata_unique$quality>7]='Excellent'

winedata_unique$rating = as.factor(winedata_unique$rating)
winedata_unique$rating=relevel(winedata_unique$rating, 'Poor')

table(winedata_unique$rating[winedata_unique$color=='red'])
table(winedata_unique$rating[winedata_unique$color=='white'])

# count plot
library(ggplot2)
qplot(rating, data = winedata_unique,fill = color,xlab="Rating",ylab="Number of Observations",main = "Ratings of Wines")


#PCA
pr.out <- prcomp(winedata_unique[1:11],scale=F)
library(ggfortify)
autoplot(pr.out, data = winedata_unique, colour = 'rating', loadings = T,loadings.colour = 'red',
         loadings.label = T, loadings.label.size = 3,loadings.label.colour='black')

pve <- ((pr.out$sdev)^2)/(sum((pr.out$sdev)^2))
summary(winedata_unique$quality)

plot(pve,xlab="Principal Component",ylab="Proportion of Variation Explained",ylim=c(0,1),type='b')
plot(cumsum(pve),xlab="Principal Component",ylab="Cumulative Proportion of Variation Explained",ylim=c(0,1),type='b')


#PCA for red and white seperately
pr.out.red <- prcomp(subset(winedata_unique[1:11],winedata_unique$color=='red'),scale=T)
library(ggfortify)
autoplot(pr.out.red, data = winedata_unique[winedata_unique$color=='red',], colour = 'rating', loadings = T,loadings.colour = 'red',
         loadings.label = T, loadings.label.size = 3,loadings.label.colour='black')


pr.out.white <- prcomp(subset(winedata_unique[1:11],winedata_unique$color=='white'),scale=T)
library(ggfortify)
autoplot(pr.out.white, data = winedata_unique[winedata_unique$color=='white',], colour = 'rating', loadings = T,loadings.colour = 'red',
         loadings.label = T, loadings.label.size = 3,loadings.label.colour='black')

#Feature plots for good,poor and excellent wines.

#red -> tsd,fsd
p1 <- ggplot(data=winedata_unique[winedata_unique$color=='red',],
             aes(x=total.sulfur.dioxide,y=free.sulfur.dioxide,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)
p1
#red -> fa,ca
p2 <- ggplot(data=winedata_unique[winedata_unique$color=='red',],
             aes(x=fixed.acidity,y=citric.acid,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)
p2
#red -> d,fa
p3 <- ggplot(data=winedata_unique[winedata_unique$color=='red',],
             aes(x=density,y=fixed.acidity,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)
p3
#red -> pH,fa
p4<- ggplot(data=winedata_unique[winedata_unique$color=='red',],
             aes(x=pH,y=fixed.acidity,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)
p4


#white -> d, rs
p5<- ggplot(data=winedata_unique[winedata_unique$color=='white',],
            aes(x=density,y=residual.sugar,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)+xlim(c(-3,3))
p5
#white -> a,d
p6<- ggplot(data=winedata_unique[winedata_unique$color=='white',],
            aes(x=density,y=alcohol,color=rating))+geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)+xlim(c(-3,3))
p6


  #VIF for multicollinearity
library(car)

#create training and test data set
set.seed(1)
train <- sample(seq_len(nrow(winedata_unique)), size = floor(.8*nrow(winedata_unique)))

train.data <- winedata_unique[train,]

redtrain <- train.data[which(train.data$color=='red'),]
whitetrain <- train.data[train.data$color=='white',]

test.data <- winedata_unique[-train,]

redtest <- test.data[test.data$color=='red',]
whitetest <- test.data[test.data$color=='white',]

#Fit two seperate models for white and red wine data

#red lin model
redtrain<-redtrain[-c(13)]
lm.red <- lm(quality~.-rating,data=redtrain)
tab_model(lm.red)

#white lin model
whitetrain<-whitetrain[-c(13)]
lm.white <- lm(quality~.-rating,data=whitetrain)
tab_model(lm.white)

summary(lm.red)
summary(lm.white)

library(car)
v1<-vif(lm.red)
v2<-vif(lm.white)
tab_df(v1)
tab_df(v2)

#Red predictions
red.predict <- predict(lm.red,redtest)
red.predict

mse.red.predict <- mean((red.predict-as.numeric(unlist(redtest$quality)))^2)
mse.red.predict
#White predictions
white.predict <- predict(lm.white,whitetest)
mse.white.predict <- mean((white.predict-as.numeric(unlist(whitetest$quality)))^2)
mse.white.predict


#red -> best subset selection
install.packages("leaps")
library(leaps)
fit <- regsubsets(quality~.-rating,data=redtrain)
summary(fit)$rsq
plot(summary(fit)$bic,xlab="Number of Variables",ylab="BIC",main="Best Subset Selection",type="l")
plot(fit,scale="bic",main="Best Subset Selection Variables",col="lightblue")

#white -> best subset selection
fit2 <- regsubsets(quality~.-rating,data=whitetrain)
plot(summary(fit2)$bic,xlab="Number of Variables",ylab="BIC",main="Best Subset Selection",type="l")
plot(fit2,scale="bic",main="Best Subset Selection Variables",col="lightblue")

#red
#Improved models
  #red wine
lm.red.improv <- lm(quality~.-rating-fixed.acidity-citric.acid-residual.sugar-free.sulfur.dioxide-density-pH,data=redtrain)
s1 <- summary(lm.red.improv)
#train-mse
msetrain <- (sum(s1$residuals^2))/length(s1$residuals)
msetrain
tab_df(s1$coefficients[,2],title="Original Standard Deviation's",digits = 4)
tab_model(lm.red.improv)

#LR assumptions hold?
set.seed(1)
plot(lm.red.improv)
#assess quality
boot.fn2 <- function(data, index){
  return(coef(lm(quality~volatile.acidity+total.sulfur.dioxide+
                         sulphates+alcohol+chlorides,data,subset=index)))
}
library(boot)
b1 <- boot(d,boot.fn2,100)
#sd from bootstrap stats
sd1 <- apply(b1$t,2,sd)
head1 <- c("intercept","volatile.acidity","total.sulfur.dioxide",
  "sulphates","alcohol","chlorides")
names(sd1) <- head1
tab_df(sd1,title="Bootstrap Standard Deviation's",digits = 4)

#white wine
lm.white.improv <- lm(quality~.-rating-fixed.acidity-chlorides-citric.acid-total.sulfur.dioxide,data=whitetrain)
s2 <- summary(lm.white.improv)
#SD's
tab_df(s2$coefficients[,2],title="Original Standard Deviation's",digits = 4)
#train mse
sum(s2$residuals^2)/length(s2$residuals)

#LR assumptions hold?
plot(lm.white.improv)

#assess quality->white
boot.fn3 <- function(data, index){
  return(coef(lm(quality~volatile.acidity+residual.sugar+free.sulfur.dioxide+
                   density+pH+sulphates+alcohol,data,subset=index)))
}
library(boot)
d2 <- winedata_unique[winedata_unique$color=='white',]
b2 <- boot(d2,boot.fn3,100)
#sd from bootstrap stats
sd2 <- apply(b2$t,2,sd)
head2 <- c("intercept","volatile.acidity","residual.sugar","free.sulfur.dioxide",
             "density","pH","sulphates","alcohol")
names(sd2) <- head2
tab_df(sd2,title="Bootstrap Standard Deviation's",digits = 4)

      #Red predictions
      red.pred2 <- predict(lm.red.improv,redtest)
      mse.red.pred2 <- mean((red.pred2-as.numeric(unlist(redtest$quality)))^2)
      mse.red.pred2
      #White predictions
      white.pred2<- predict(lm.white.improv,whitetest)
      mse.white.pred2 <- mean((white.pred2-as.numeric(unlist(whitetest$quality)))^2)
      mse.white.pred2

####Classification
      library(nnet)
  #Red Logistic Regression
  glm.red <- multinom(rating~.-quality,data=redtrain,family = binomial)
  summary(glm.red)
  tab_model(glm.red)
  
    #param signif
  z.red <- summary(glm.red)$coefficients/summary(glm.red)$standard.errors
  p.red <- (1 - pnorm(abs(z.red), 0, 1)) * 2
  View(p.red)
  
  #White Logistic Regression
  glm.white <- multinom(rating~.-quality,data=whitetrain,family = binomial)
  summary(glm.white)
  tab_model(glm.white)
  
    #param signif
  z.white <- summary(glm.white)$coefficients/summary(glm.white)$standard.errors
  p.white <- (1 - pnorm(abs(z.white), 0, 1)) * 2
  tab_df(p.white)
  
  #model accuracy - red
  glm.red.class <- predict(glm.red,redtest,"class")
  incorrect<- which(glm.red.class != redtest$rating)
  64/282
  a<- glm.red.class[which(glm.red.class != redtest$rating)]
  t<- table(a)
  t
  
  #model accuracy - white
  glm.white.class <- predict(glm.white,whitetest,"class")
  incorrect.w<- which(glm.white.class != whitetest$rating)
  213/782
  t2<- table(glm.white.class[which(glm.white.class != whitetest$rating)])
  t2
  
  #updated model -red
  glm.red.new <- multinom(rating~volatile.acidity+total.sulfur.dioxide+
                            sulphates+alcohol,data=redtrain,family = binomial)
    tab_model(glm.red.new)
    #train error
    set.seed(123)
    a <- predict(glm.red.new,type="class")
    length(which(a != redtrain$rating))
    table(a[which(a!= redtrain$rating)])
    length(redtrain$rating)
    length(which(a != redtrain$rating))/length(redtrain$rating)
    
    0.277623
    
  glm.red.class2 <- predict(glm.red.new,redtest,"class")
  incorrect2<- which(glm.red.class2 != redtest$rating)
  65/282
  t3<- table(glm.red.class2[which(glm.red.class2 != redtest$rating)])
  t3
  
  #assess quality -> red
  boot.fn <- function(data, index){
    return(coef(multinom(rating~volatile.acidity+total.sulfur.dioxide+
                    sulphates+alcohol,data,family = binomial,subset=index)))
  }
  library(boot)
  B3<- boot(d,boot.fn,100)
  B3
  sd3 <- apply(B3$t,2,sd)
  sd3
  h3 <- c("E:intercept","G:intercept","E:volatile.acidity","G:volatile.acidity","E:total.sulfur.dioxide",
          "G:total.sulfur.dioxide","E:sulphates","G:sulphates","E:alcohol","G:alcohol")
  names(sd3) <- h3
  #SD's
  tab_df(sd3[1:10],title="Bootstrap Standard Deviation's",digits = 4)
  
  #updated model -white
  glm.w.new <- multinom(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                          pH+sulphates+alcohol,data=whitetrain,family = binomial)
  tab_model(glm.w.new)
  
  glm.w.class2 <- predict(glm.w.new,whitetest,"class")
  incorrect2.w<- which(glm.w.class2 != whitetest$rating)
  214/782  
  t4<- table(glm.w.class2[which(glm.w.class2 != whitetest$rating)])
  t4
  
  
  #train error
  set.seed(123)
  a <- predict(glm.w.new,type="class")
  length(which(a != whitetrain$rating))
  table(a[which(a!= whitetrain$rating)])
  length(whitetrain$rating)
  length(which(a != whitetrain$rating))/length(whitetrain$rating)
  
  #assess quality -> white
  boot.fn4 <- function(data, index){
    return(coef(multinom(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                           pH+sulphates+alcohol,data,family = binomial,subset=index)))
  }
  library(boot)
  B4<- boot(d2,boot.fn4,100)
  sd4 <- apply(B4$t,2,sd)
  sd4
  h4 <- c("E:intercept","G:intercept","E:volatile.acidity","G:volatile.acidity","E:residual.sugar",
          "G:residual.sugar","E:free.sulfur.dioxide","G:free.sulfur.dioxide",
          "E:density","G:density","E:pH","G:pH","E:sulphates","G:sulphates","E:alcohol","G:alcohol")
  names(sd4) <- h4
  tab_df(sd4,title="Bootstrap Standard Deviation's",digits = 4)
  
  View(summary(glm.w.new)$standard.errors)
  
  
    #LDA#
  #RED
  library(MASS)
  lda.red <- lda(rating~volatile.acidity+total.sulfur.dioxide+
                   sulphates+alcohol,data=redtrain)
  lda.red
  lda.pred.r <- predict(lda.red,redtest)
  inc1<- which(lda.pred.r$class != redtest$rating)
  67/282
  tab1<- table(lda.pred.r$class[which(lda.pred.r$class != redtest$rating)])
  tab1
  #WHITE
  lda.white <- lda(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                     pH+sulphates+alcohol,data=whitetrain)
  lda.white
  lda.pred.w <- predict(lda.white,whitetest)
  inc2<- which(lda.pred.w$class != whitetest$rating)
  212/782
  tab2<- table(lda.pred.w$class[which(lda.pred.w$class != whitetest$rating)])
  tab2
  
    #QDA
  #RED
  qda.red <- qda(rating~volatile.acidity+total.sulfur.dioxide+
                   sulphates+alcohol,data=redtrain)
  qda.red
  qda.pred.r <- predict(qda.red,redtest)
  inc3<- which(qda.pred.r$class != redtest$rating)
  62/282
  tab3<- table(qda.pred.r$class[which(qda.pred.r$class != redtest$rating)])
  tab3
  
  #WHITE
  qda.w<- qda(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                pH+sulphates+alcohol,data=whitetrain)
  qda.w
  qda.pred.w <- predict(qda.w,whitetest)
  inc4<- which(qda.pred.w$class != whitetest$rating)
  224/782
  tab4<- table(qda.pred.w$class[which(qda.pred.w$class != whitetest$rating)])
  tab4
  
  #SVC -> red
  library(e1071)
  svm.red <- svm(rating~volatile.acidity+total.sulfur.dioxide+
                   sulphates+alcohol,data=redtrain,scale=T,type="C-classification",kernel="linear",cost=1)
  summary(svm.red)  
  pred.red <- predict(svm.red,redtest)
  table(pred.red)  
  pm.red <- length(which(pred.red!=redtest$rating))/nrow(redtest)
  pm.red  
  
  #SVM(radial) -> red
  set.seed(123)
  svm.red2 <- svm(rating~volatile.acidity+total.sulfur.dioxide+
                    sulphates+alcohol,data=redtrain,scale=T,type="C-classification",kernel="radial")
  summary(svm.red2)  
  pred.red2 <- predict(svm.red2,redtest)
  table(pred.red2)  
  pm.red2 <- length(which(pred.red2!=redtest$rating))/nrow(redtest)
  pm.red2
  
  length(which(svm.red2$fitted!=redtrain$rating))/nrow(redtrain)
  
  #SVC -> white
  library(e1071)
  svm.w<- svm(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                pH+sulphates+alcohol,data=whitetrain,scale=T,type="C-classification",kernel="linear",cost=1)
  summary(svm.w)  
  pred.w <- predict(svm.w,whitetest)
  table(pred.w)  
  pm.red <- length(which(pred.w!=whitetest$rating))/nrow(whitetest)
  pm.red  
  length(which(svm.w$fitted!=whitetrain$rating))/nrow(whitetrain)
  
  #SVM(radial) -> wihte
  set.seed(123)
  svm.w2 <- svm(rating~volatile.acidity+residual.sugar+free.sulfur.dioxide+density+
                  pH+sulphates+alcohol,data=whitetrain,scale=T,type="C-classification",kernel="radial")
  summary(svm.w2)  
  pred.w2 <- predict(svm.w2,whitetest)
  table(pred.w2)  
  pm.w2 <- length(which(pred.w2!=whitetest$rating))/nrow(whitetest)
  pm.w2
  
  length(which(svm.w2$fitted!=whitetrain$rating))/nrow(whitetrain)
  
  
  
    