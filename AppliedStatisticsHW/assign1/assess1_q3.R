library(MASS)
?Boston
g0 <- ggplot(data=Boston,aes(Boston$medv,Boston$crim))+geom_point()
plot(g0)
View(Boston)
apply(Boston,2,range)
h <- boxplot(Boston$crim,ylab="crime rate")
iqr = IQR(Boston$crim)
upperq=quantile(Boston$crim)[4]
mild.thresh.upper=(iqr*1.5)+upperq
extreme.thresh.upper=(iqr*3)+upperq
which(Boston$crim>mild.thresh.upper)
which(Boston$crim>extreme.thresh.upper)
apply(Boston[c(which(Boston$crim>extreme.thresh.upper)),],2,range)

upperq1=quantile(Boston$tax)[4]
mild.thresh.upper1=(iqr1*1.5)+upperq1
extreme.thresh.upper1=(iqr1*3)+upperq1
which(Boston$tax>mild.thresh.upper1)
which(Boston$tax>extreme.thresh.upper1)

iqr2 = IQR(Boston$ptratio)
upperq2=quantile(Boston$ptratio)[4]
mild.thresh.upper2=(iqr2*1.5)+upperq2
extreme.thresh.upper2=(iqr2*3)+upperq2
which(Boston$ptratio>mild.thresh.upper2)
which(Boston$ptratio>extreme.thresh.upper2)

length(which(Boston$chas==1))
median(Boston$ptratio)
which(Boston$medv==min(Boston$medv))
Boston[c(399,406),]
length(which(Boston$rm>7))
length(which(Boston$rm>8))
Boston[c(which(Boston$rm>8)),]

colMeans(Boston,2)
colMeans(Boston[c(which(Boston$rm>8)),],2)

apply(Boston,2,range)
apply(Boston[c(which(Boston$rm>8)),],2,range)

colMeans(Boston[c(which(Boston$rm>8)),])

apply(Boston[c(which(Boston$rm>8)),],2,median)

m <- lm(crim~.-age-chas-tax-rm-indus-lstat-ptratio,data=Boston)
m
summary(m)
g<-ggplot(data=Boston,aes(Boston$rad,Boston$crim))+labs(x="index of accessibility to radial highways.",y="per capita crime rate by town.")
g+geom_point(shape=1,size=2)+xlim(0,50)+ylim(0,100)

g1<-ggplot(data=Boston,aes(Boston$medv,Boston$crim))+labs(x="median value of owner occupied homes",y="per capita crime rate by town.")
g1+geom_point(shape=22,size=4,fill="blue")

g2<-ggplot(data=Boston,aes(Boston$dis,Boston$crim))+labs(x="weighted mean of distances to five Boston employment centres.",y="per capita crime rate by town.")
g2+geom_point(size=2,fill="red")

g3<-ggplot(data=Boston,aes(Boston$zn,Boston$crim))+labs(x="proportion of residential land zoned for lots over 25,000 sq.ft.",y="per capita crime rate by town.")
g3+geom_point(shape=23,fill="blue",size=3)

g4<-ggplot(data=Boston,aes(Boston$nox,Boston$crim))+labs(x="nox",y="per capita crime rate by town.")
g4+geom_point(size=2,shape=4)

