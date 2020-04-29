library(ISLR)
data("Default")

#fit logistic regression model
glm.fit = glm(default~income+balance,data=Default,family = binomial)
summary(glm.fit)
View(Default)

#create function to return coefficients of models
boot.fn = function(data,index){
  return(coef(glm(default~income+balance, data=data, family=binomial, subset=index)))
}

#perform bootstrap calc
set.seed(1)
library(boot)
boot(Default,boot.fn,1000)

View(Wage)

#perform 10-fold CV
set.seed(1)
cv.error.10=rep(0,10)
for(i in 1:10){
  glm.fit=glm(wage~poly(age,i), data=Wage)
  cv.error.10[i]=cv.glm(Wage, glm.fit, K=10)$delta[1]
}
cv.error.10

#plot degree of polynomial -vs- CV-error
plot(cv.error.10)

#perform anova
p.val=rep(0,10)
model.null=glm(wage~1, data=Wage)
model.deg1=glm(wage~age, data=Wage)

p.val[1]=anova(model.null,model.deg1,test='F')$"Pr(>F)"[2]

for (i in 1:10){
  model=glm(wage~poly(age,i), data=Wage)
  model2=glm(wage~poly(age,i+1), data=Wage)
  p.val[i+1]=anova(model,model2,test='F')$"Pr(>F)"[2]
}
plot(p.val)
abline(h=.05)

final_model = glm(wage~poly(age,2),data=Wage)
plot(final_model)

#plot model
library(ggplot2)
ggplot(data=Wage,aes(age,wage))+ggtitle("Quadratic model fit to data")+geom_point(color = "black", size =.1)+geom_smooth(method='glm', formula=y~poly(x,2), se=FALSE, col="blue", lwd=.5)

#local constant (N-W) Kernel Estimator

library(KernSmooth)
install.packages("sm")
library(sm)
help(sm)

#optimal bandwidth
h <- hcv(Wage$age,Wage$wage)
h
#fit local constant (N-W) Kernel Estimator
x <- Wage$age
y <- Wage$wage


plot(x, y)
h1 <- dpill(x, y)
h1
fit <- locpoly(x, y, bandwidth = h1)
lines(fit)


kern.model.box <- ksmooth(x,y,"box",bandwidth=h,range.x=range(x))
kern.model.gaussian <- ksmooth(x,y,"normal",bandwidth=h,range.x=range(x))
plot(x,y)
lines(kern.model.box)
lines(kern.model.gaussian)

#Pretty plots
plot(x,y,main ="Box Kernel")+lines(kern.model.box,lwd=2,col=2)
plot(x,y,main ="Gaussian Kernel")+lines(kern.model.gaussian,lwd=2,col=2)
ksmooth(x,y,"box",bandwidth=h1,range.x=range(x))


