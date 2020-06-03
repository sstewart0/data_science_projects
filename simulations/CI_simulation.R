set.seed(1)

X<-abs(round(rnorm(1000,0,10),0))
X2<-X^2
X3<-X^3
ONE <- rep(1,1000)

INPUT <- cbind(ONE,scale(X),scale(X2),scale(X3))
B0<-round(runif(1000,0,100),0)
B1<-round(runif(1000,0,100),0)
B2<-round(runif(1000,0,100),0)
B3<-round(runif(1000,0,100),0)
E<-rnorm(1000,0,100)
Y<-round(B0*X+B1*X2+B2*X3+E,0)

MODEL <- lm(Y~X+X2+X3)
summary(MODEL)
plot(MODEL)
View(X)
#CI for x_0=15
pred<-predict(MODEL,data.frame(X=0,X2=0,X3=0),interval="confidence")
#[15675,15697]
#PI for x_0=15
pred2<-predict(MODEL,data.frame(X=0,X2=0,X3=0),interval="prediction")
#[15481,15891]
View(pred)

library(matlib)
a=data.frame(1,X=0,X2=0,X3=0)
X_0<-as.matrix(a)%*%as.matrix(MODEL$coefficients)
#aT(B_HAT) +/- (aT(XTX)^(-1)a)^(0.5)(sigma_hat)
XTX<-t(as.matrix(INPUT)) %*% as.matrix(INPUT)
XTX_inv <- inv(XTX)
mse<- (sum(MODEL$residuals^2)/MODEL$df.residual)^.5
std_error <- ((as.matrix(a)%*%XTX_inv%*%t(as.matrix(a))+1)*mse^2)^0.5
PI_l <- aTB - 1.96*std_error
PI_U <- aTB +1.96*std_error

