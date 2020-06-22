bnb_data <- read.csv("../AB_NYC_2019.csv")
View(bnb_data)
attach(bnb_data)
sapply(bnb_data,class)

#Change date of last review -> as date
bnb_data[,13] = as.Date(bnb_data[,13])

library(ggplot2)

#Density of airbnb's in nbhds:
ggplot(bnb_data,aes(x=neighbourhood_group,fill=neighbourhood_group))+xlab("Area")+
  geom_bar()+theme_minimal()+theme(legend.position = "none")+
  geom_text(aes(label=..count..),stat="count",position=position_stack())+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Bronx","Staten Island"))

levels(bnb_data$neighbourhood_group)
counts = rbind(nlevels(droplevels(bnb_data[neighbourhood_group=='Bronx',]$neighbourhood)),
          nlevels(droplevels(bnb_data[neighbourhood_group=='Brooklyn',]$neighbourhood)),
          nlevels(droplevels(bnb_data[neighbourhood_group=='Manhattan',]$neighbourhood)),
          nlevels(droplevels(bnb_data[neighbourhood_group=='Queens',]$neighbourhood)),
          nlevels(droplevels(bnb_data[neighbourhood_group=='Staten Island',]$neighbourhood))
)
nbhd_count = as.data.frame(cbind(levels(neighbourhood_group),counts))
colnames(nbhd_count) = c("Area","Number_of_sub_divisions")
nbhd_count$Number_of_sub_divisions = as.numeric(as.character(nbhd_count$Number_of_sub_divisions))

#Number of nbhds within each nbhd group
ggplot(nbhd_count,aes(Area,Number_of_sub_divisions,fill=Area)) + geom_bar(stat="identity",colour='black')+
  xlab("Area")+ylab("Number of Sub-Divisions")+theme_minimal()+theme(legend.position="none")+
  scale_x_discrete(limits=c("Manhattan","Staten Island","Brooklyn","Bronx","Queens"))

#Split of room types across area
library(ggrepel)
table(neighbourhood_group,room_type)
ggplot(bnb_data,aes(x=neighbourhood_group,fill=room_type))+geom_bar(position = position_dodge())+
  geom_text_repel(aes(label=..count..),stat="count",position=position_dodge(0.9))+
  scale_fill_brewer(palette="Paired")+theme_minimal()+xlab("Area")+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Bronx","Staten Island"))

#Price range for each area 
ggplot(bnb_data,aes(x=neighbourhood_group,y=price,fill=neighbourhood_group))+
  geom_violin()+ylim(c(0,600))+theme(legend.position= "none")+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Staten Island","Bronx"))

#Minimum nights for each area
ggplot(bnb_data,aes(x=neighbourhood_group,y=minimum_nights,fill=neighbourhood_group))+
  geom_violin()+theme(legend.position= "none")+ylim(c(0,35))+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Staten Island","Bronx"))

#split reviews into categories
num_reviews<-rep(NA,48895)
bnb_data=cbind(bnb_data,num_reviews)

bnb_data[number_of_reviews<=25 & number_of_reviews>=0,]$num_reviews <- c("0<=X<=25")
bnb_data[number_of_reviews>25 & number_of_reviews<=50,]$num_reviews <- c("25<X<=50")
bnb_data[number_of_reviews>50 & number_of_reviews<=75,]$num_reviews <- c("50<X<=75")
bnb_data[number_of_reviews>75 & number_of_reviews<=100,]$num_reviews <- c("75<X<=100")
bnb_data[number_of_reviews>100 & number_of_reviews<=200,]$num_reviews <- c("100<X<=200")
bnb_data[number_of_reviews>200,]$num_reviews <- c("X>200")

bnb_data$num_reviews=as.factor(bnb_data$num_reviews)
nrow(bnb_data[is.na(bnb_data$num_reviews),])

#Plot number of reviews
ggplot(bnb_data,aes(x=num_reviews,fill=num_reviews))+geom_bar()+theme_minimal()+
  theme(legend.position = "none")+labs(x="Number of Reviews (X)")+
  scale_x_discrete(limits=c("0<=X<=25","25<X<=50","50<X<=75","75<X<=100","100<X<=200","X>200"))

median(bnb_data$number_of_reviews)

#reviews per month
median(bnb_data$reviews_per_month,na.rm=T)
mean(bnb_data$reviews_per_month,na.rm=T)

#Host listings and neighbourhood group
ggplot(bnb_data,aes(x=neighbourhood_group,y=calculated_host_listings_count))+
  geom_violin()+ylim(c(0,10))

#Find better way to plot!
ggplot(bnb_data,aes(x=calculated_host_listings_count,fill=neighbourhood_group))+geom_bar()+theme_minimal()+
  xlim(c(0,10))

#Find better way to plot!
ggplot(bnb_data,aes(x=calculated_host_listings_count,fill=room_type))+geom_bar()+theme_minimal()+
  xlim(c(0,10))

median(bnb_data$calculated_host_listings_count,na.rm=T)
mean(bnb_data$calculated_host_listings_count,na.rm=T)

#Packages for plotting maps
install.packages("ggmap")
install.packages("hexbin")
library(hexbin)
library(ggmap)

summary(bnb_data)

#Create stamen map
height <- max(bnb_data$latitude) - min(bnb_data$latitude)
width <- max(bnb_data$longitude) - min(bnb_data$longitude)
ny_borders <- c(bottom  = min(bnb_data$latitude), 
                 top     = max(bnb_data$latitude),
                 left    = min(bnb_data$longitude),
                 right   = max(bnb_data$longitude))

map <- get_stamenmap(ny_borders, zoom = 10, maptype = "terrain",crop=T)
?get_stamenmap
ggmap(map)+stat_density2d(aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..),
                          geom = "polygon",
                          data = bnb_data) +
  scale_fill_gradient2(low = "yellow", mid="orange", high = "red",midpoint=60)

#geom_contour, geom_hex, geom_raster : 3d -> 2d (3 numeric variables)
#geom_count : 2 catagorical variables with propensity
#geom_jitter : x=catagorical,y=cts
#geom_smooth -> loess : local poly fitting
#            -> multiple lines for classes
