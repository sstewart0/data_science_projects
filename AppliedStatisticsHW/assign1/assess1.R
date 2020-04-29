Auto <- read.csv("~/OneDrive - University of Birmingham/Year3/AS/autumn/RStudio/Auto.csv", sep="")
View(Auto)
range(Auto$mpg)
range(Auto$cylinders)
range(Auto$displacement)
range(Auto$horsepower)
range(Auto$horsepower)
Auto <- read.csv("~/OneDrive - University of Birmingham/Year3/AS/autumn/RStudio/Auto.csv", sep="")
range(Auto$weight)
range(Auto$acceleration)
range(Auto$year)
range(Auto$origin)
range(as.numeric(Auto$horsepower))
mean(Auto$mpg)
sd(Auto$mpg)
mean(Auto$cylinders)
Auto$horsepower <- replace(as.character(Auto$horsepower), Auto$horsepower == "?", "NA")
range(Auto$horsepower,na.rm=FALSE)
is.na(Auto$horsepower)
Auto$horsepower <- replace(as.character(Auto$horsepower), Auto$horsepower == "NA", "")
is.na(Auto$horsepower)
Auto$horsepower <- replace(as.character(Auto$horsepower), Auto$horsepower == "",NA)
is.na(Auto$horsepower)
range(as.numeric(Auto$horsepower),na.rm=TRUE)
transform(Auto,as.numeric(Auto$horsepower))
data.class(Auto$horsepower)
Auto$horsepower <- as.numeric(as.character(Auto$horsepower))
data.class(Auto$horsepower)
range(Auto$horsepower,na.rm=TRUE)
mean(Auto$cylinders)
sd(Auto$cylinders)
colMeans(Auto[sapply(Auto, is.numeric,)])
mean(Auto$horsepower,na.rm=TRUE)
apply(Auto,2,sd,na.rm=TRUE)
newAuto <- Auto[1:9,]
newAuto + Auto[11:397,]
View(newAuto)
newAuto <- Auto[-c[10,,85]]
newAuto <- Auto[-c(10:85),]
View(newAuto)
apply(newAuto[1:8],2,sd,na.rm=TRUE)
apply(newAuto,2,mean)
colMeans(newAuto[sapply(newAuto, is.numeric)],na.rm=TRUE)
apply(newAuto,2,range,na.rm=TRUE)
lm1.fit=lm(mpg~cylinders+cylinders+displacement+horsepower+weight+acceleration+year,data=Auto)
plot(lm1.fit)
par(mfrow=c(2,2))
plot(lm1)
View(Auto)
Auto <- read.csv("~/OneDrive - University of Birmingham/Year3/AS/autumn/RStudio/Auto.csv", sep="")
View(Auto)
b <- boxplot(Auto$cylinders,Auto$mpg,xlabel="mpg",ylabel="cylinders",log = "",data=Auto,na.rm=TRUE)
plot(b)
library(ggplot2)
g <- ggplot(data=Auto,aes(x=Auto$weight,y=Auto$mpg))+geom_point(aes(colour=factor(Auto$cylinders)))
plot(g)
g+labs(x="weight",y="mpg",colour="Cylinders",title = "Scatter plot to show relationship between mpg and weight of cars from 1970-82")
Auto$horsepower <- as.numeric(as.character(Auto$horsepower))
data.class(Auto$horsepower)
g1 <- ggplot(data=Auto, aes(x=Auto$year,y=Auto$mpg))
g1 + geom_point() + 
  geom_smooth(method="lm",se=F) +
  labs(y="mpg", 
       x="Year(19__._)", 
       title="Scatterplot with overlapping points", 
       caption="Source: Auto data")
g2 <- ggplot(data=Auto,aes(x=Auto$acceleration,y=Auto$horsepower))+labs(x="accel",y="hp",title="accel .vs. hp")+geom_point()
g2+geom_smooth(method="lm",se=F)

g3 <- ggplot(data=Auto,aes(x=Auto$displacement,y=Auto$horsepower))+labs(x="displacement",y="hp",title="displacement .vs. hp")+geom_point()
g3+geom_smooth(method="lm",se=F)

g4 <- ggplot(data=Auto,aes(x=Auto$acceleration,y=Auto$mpg))
g4+geom_point(aes(colour=factor(Auto$cylinders)))+labs(x="acceleration",y="mpg",title="accel vs mpg",colour="Cylinders")

g5 <- ggplot(data=Auto,aes(x=Auto$horsepower,y=Auto$weight))+labs(x="hp",y="weifght",title="hp .vs. weight")+geom_point()
g5+geom_smooth(method="lm",se=F)

g6 <- ggplot(data=Auto,aes(x=Auto$weight,y=Auto$acceleration))+labs(x="weight",y="accel",title="weight .vs. accel")+geom_point()
plot(g6)

Auto <- read.csv("~/OneDrive - University of Birmingham/Year3/AS/autumn/RStudio/Auto.csv", sep="")
View(Auto)
Auto$horsepower <- as.numeric(as.character(Auto$horsepower))
apply(Auto[1:8],2,range,na.rm=T)

colMeans(Auto,2,na.rm = T)

apply(Auto[1:8],2,sd,na.rm=T)


