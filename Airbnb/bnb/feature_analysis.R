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
#map of density of airbnb's in NY
ggmap(map)+stat_density2d(aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..),
                          geom = "polygon",
                          data = bnb_data) +
  scale_fill_gradient2(low = "yellow", mid="orange", high = "red",midpoint=60)

#geom_contour, geom_hex, geom_raster : 3d -> 2d (3 numeric variables)
#geom_count : 2 catagorical variables with propensity
#geom_jitter : x=catagorical,y=cts
#geom_smooth -> loess : local poly fitting
#            -> multiple lines for classes

#Map of price of airbnb's in NY (price > 1000)
?scale_fill_gradientn
ggmap(map)+geom_point(data=bnb_data[bnb_data$price>1000,],aes(x=longitude,y=latitude,colour=price,size=price,alpha=price))+
  scale_color_gradientn(colours=rainbow(5))+scale_size(range=c(0.5,7))

#Map of room-type and price
summary(bnb_data$price)
#less than median price
ggmap(map)+geom_point(data=bnb_data[bnb_data$price<106,],
                      aes(x=longitude,y=latitude,colour=room_type,size=price,alpha=price))+
  scale_size(range=c(0.1,1))
#(median -> third quartile) price
ggmap(map)+geom_point(data=bnb_data[bnb_data$price>106 & bnb_data$price<175,],
                      aes(x=longitude,y=latitude,colour=room_type,alpha=price))
# >third quartile price
ggmap(map)+geom_point(data=bnb_data[bnb_data$price>175,],
                      aes(x=longitude,y=latitude,colour=room_type,alpha=price))

#Proportion contingency tables
attach(bnb_data)
#The proportion of room types within each area
t1 = prop.table(table(room_type,neighbourhood_group),margin=2)

#The proportion of room types over all areas
t2 = prop.table(table(neighbourhood_group,room_type),margin=2)

#Room type and nbhd group independent?:
chisq.test(table(room_type,neighbourhood_group))
#(p-value < 2.2e-16) Reject null, i.e. dependent.

#Most/Least expensive neighbourhoods and their location on map
a1 = aggregate( price ~ neighbourhood, bnb_data, mean )
a2 = aggregate( price ~ neighbourhood, bnb_data, median )
a3 = cbind(a1,a2[,2],as.data.frame(table(neighbourhood))[,2])

colnames(a3)[2]="Mean_Price"
colnames(a3)[3]="Median_Price"
colnames(a3)[4]="Frequency"

library(dplyr)
summary(a3[,4])#cutoff freq=10 (lower quartile)
a4 = a3[a3[,4]>10,]

#Top ten most expensive nbhds (median), with at least 10 listings:
tail(a4[order(a4[,3]),],n=10)
l=c("Tribeca","NoHo","Flatiron District","Midtown","West Village","Financial District","SoHo",
    "Chelsea","Greenwich Village","Battery Park City")
?table
prop.table(table(bnb_data[bnb_data$neighbourhood %in% l,]$room_type))
ggmap(map)+geom_point(data=bnb_data[bnb_data$neighbourhood %in% l,],
                      aes(x=longitude,y=latitude,fill=neighbourhood,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))
#fill,shape,stroke

#Top ten cheapest nbhds (median), with at least 10 listings:
head(a4[order(a4[,3]),],n=10)
l2=c("Concord","Corona","Hunts Point","Tremont","Soundview","Whitestone","Bronxdale","Van Nest",
     "Morris Heights","Woodhaven")
prop.table(table(bnb_data[bnb_data$neighbourhood %in% l2,]$room_type))
ggmap(map)+geom_point(data=bnb_data[bnb_data$neighbourhood %in% l2,],
                      aes(x=longitude,y=latitude,fill=neighbourhood,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#correlation numeric variables:
bnb_data$num_reviews=as.factor(bnb_data$num_reviews)
library(corrplot)
col = colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
#Pearson correlation coefficient, use only numeric variables and remove irrelevant id column
corr = cor(bnb_data[,!(names(bnb_data)=="id") & sapply(bnb_data, is.numeric)],use = "pairwise.complete.obs")
res =cor.mtest(bnb_data[,!(names(bnb_data)=="id") & sapply(bnb_data, is.numeric)],use = "pairwise.complete.obs", conf.level = .95)
corrplot(corr,method="color",col=col(200),type="upper",tl.col = "black", addCoef.col = "black",
         tl.srt = 90,order="hclust",p.mat=res$p,insig="blank",sig.level=0.01,diag=F)


#Plot Mean prices of nbhds with standard error bars, increasing order, colour=nbhd_group

#Calculate standard errors:
se = aggregate( price ~ neighbourhood, bnb_data, function(x) sd(x)/sqrt(length(x)) )[,2]
a3=cbind(a3,se)

#Add nbhd_group
group=rep("Bronx",221)
for (i in 0:nrow(a3)){
  group[i]=as.character(bnb_data[bnb_data$neighbourhood==a3[,1][i],]$neighbourhood_group[1])
}
a3=cbind(a3,group)
colnames(a3)[2]=c("Mean_Price")
colnames(a3)[3]=c("Median_Price")

ggplot(a3[a3$Frequency>10,], aes(x=reorder(neighbourhood,Mean_Price), y=Mean_Price,colour=group)) + 
  geom_errorbar(aes(ymin=Mean_Price-se, ymax=Mean_Price+se), width=.1)+geom_point(shape=4,size=2)+
  theme(axis.text.x = element_blank())+
  labs(x="Neighbourhood",y="Mean Price",title="Mean Prices of Neighbourhoods (with more than 10 listings)")

#bar plot for room_types
ggplot(bnb_data,aes(x=room_type,fill=neighbourhood_group))+
  geom_bar(position="stack")+
  geom_text_repel(aes(label=scales::percent(..count../sum(..count..))),stat="count",position=position_stack())

#How many hosts have more than 10 listings
nrow(distinct(bnb_data[bnb_data$calculated_host_listings_count>10,],host_id))
#List of unique host id's with more than 10 listings, in decreasing order.
l3=head(distinct(bnb_data[order(bnb_data$calculated_host_listings_count,decreasing = T),],host_id),n=94)[,1]

#Map of hosts with >100 listings
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count>100),],
                      aes(x=longitude,y=latitude,fill=host_name,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#Map of hosts with  49<listings<101
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count<101 &
                                       bnb_data$calculated_host_listings_count>49),],
                      aes(x=longitude,y=latitude,fill=host_name,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#Map of hosts with  10<listings<50
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count<50),],
                      aes(x=longitude,y=latitude,shape=room_type,fill=neighbourhood_group))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#Any trends in hosts with >10 listings?
tycoons = bnb_data[bnb_data$host_id %in% l3,]
summary(tycoons)
#room_type,availability,price,location,reviews,min-nights?

#function for mode of catagorical variable:
calculate_mode = function(x) {
  uniqx = unique(x)
  uniqx[which.max(tabulate(match(x, uniqx)))]
}

gd = tycoons %>%
  group_by(host_id) %>%
  summarise(price=mean(price),availability_365=mean(availability_365),minimum_nights=mean(minimum_nights),
            reviews_per_month=mean(reviews_per_month),number_of_reviews=mean(number_of_reviews),
            neighbourhood=calculate_mode(neighbourhood),neighbourhood_group=calculate_mode(neighbourhood_group),
            calculated_host_listings_count=mean(calculated_host_listings_count))
h=mean(bnb_data$price)
#Plot mean prices of host listings
ggplot(gd,aes(x=reorder(host_id,price),y=price,fill=neighbourhood_group,size=calculated_host_listings_count))+
  geom_point(data=tycoons,alpha=.4,size=.5,shape=4)+geom_point(shape=21)+theme(axis.text.x = element_blank())+
  geom_hline(yintercept = h,colour="red",linetype="dashed")+
  ylim(c(0,1000))+labs(x="Host",y="Price",title = "Tycoon's Mean Airbnb Price")

library(qdap)
#Areas included in name of airbnb?
manhattan_areas=distinct(bnb_data[bnb_data$neighbourhood_group=="Manhattan",],neighbourhood)
manhattan_areas[,1]=as.character(manhattan_areas[,1])
neighbourhood=manhattan_areas[,1]

brooklyn_areas=distinct(bnb_data[bnb_data$neighbourhood_group=="Brooklyn",],neighbourhood)
brook_areas=as.character(brooklyn_areas[,1])

bronx_areas=distinct(bnb_data[bnb_data$neighbourhood_group=="Bronx",],neighbourhood)
brnx_areas=as.character(bronx_areas[,1])

stat_isl_areas=distinct(bnb_data[bnb_data$neighbourhood_group=="Staten Island",],neighbourhood)
stat_areas=as.character(stat_isl_areas[,1])

queens_areas=distinct(bnb_data[bnb_data$neighbourhood_group=="Queens",],neighbourhood)
qns_areas=as.character(queens_areas[,1])

areas = list(neighbourhood,brook_areas,brnx_areas,stat_areas,qns_areas)

#Manhattan
man_words=termco(bnb_data[bnb_data$neighbourhood_group=="Manhattan",]$name,match.list=neighbourhood,short.term = T,
             ignore.case=T,apostrophe.remove = T,digit.remove = T)
man_words$rnp[,order(man_words$prop,decreasing = T)]

m1=neighbourhood
x0=rep(0,length(neighbourhood))
m1=cbind(neighbourhood,x0,x0,x0,x0)
colnames(m1)[1:5]=c("neighbourhood","True_Claims","True_Claims_Perc","False_Claims","False_Claims_Perc")
m1[colnames(m1)[2:5]] <- sapply(m1[colnames(m1)[2:5]],as.numeric)
m1=as.data.frame(m1)

for (i in 1:nrow(m1)){
  t=termco(bnb_data[bnb_data$neighbourhood==neighbourhood[i],]$name,match.list=neighbourhood[i],short.term = T,
           ignore.case=T,apostrophe.remove = T,digit.remove = T)
  m1[i,2]=as.numeric(t$raw[3])
  m1[i,3]=as.numeric(round(t$prop[3],2))
}
for (i in 1:nrow(m1)){
  t=termco(bnb_data[(bnb_data$neighbourhood!=neighbourhood[i])&(bnb_data$neighbourhood_group=="Manhattan"),]$name,
           match.list=neighbourhood[i],short.term = T,ignore.case=T,apostrophe.remove = T,digit.remove = T)
  m1[i,4]=as.numeric(t$raw[3])
  m1[i,5]=as.numeric(round(t$prop[3],2))
}
#Add price, reviews and frquency to improve plots
gm = bnb_data[bnb_data$neighbourhood_group=="Manhattan",] %>%
  group_by(neighbourhood) %>%
  summarise(price=median(price),number_of_reviews=median(number_of_reviews),
            Freq=n())

m1=merge(m1,gm,by=c("neighbourhood"))
#Which Manhattan neighbourhoods use neighbourhood name in Airbnb Title
ggplot(m1,aes(reorder(x=neighbourhood,True_Claims_Perc),y=True_Claims_Perc,fill=Freq))+
  geom_point(shape=21,size=2)+theme_minimal()+scale_fill_gradient(low="yellow",high="red")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(x="Neighbourhood",y="%",title="Which Manhattan neighbourhoods use neighbourhood name in Airbnb Title")

#Which Manhattan neighbourhoods "falsely" use neighbourhood name in Airbnb Title
ggplot(m1,aes(reorder(x=neighbourhood,False_Claims),y=False_Claims,fill=Freq))+
  geom_point(shape=21,size=2)+theme_minimal()+scale_fill_gradient(low="yellow",high="red")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  labs(x="Neighbourhood",y="Count",title="Which Manhattan neighbourhoods have name 'falsely' used in Airbnb Title")

m1[order(-m1$False_Claims),]
Total_Claims = m1[,2]+m1[,4]
Total_Claims_Perc = round((Total_Claims/m1$Freq)*100,2)
m1 = cbind(m1,Total_Claims,Total_Claims_Perc)

m1[order(-m1$Total_Claims_Perc),]
View(bnb_data)
colnames(bnb_data)
#Brooklyn
brook_words=termco(bnb_data[bnb_data$neighbourhood_group=="Brooklyn",]$name,match.list=brook_areas,short.term = T,
                 ignore.case=T,apostrophe.remove = T,digit.remove = T)
brook_words$rnp[,order(brook_words$prop,decreasing = T)]


allwords=word_list(bnb_data$name)
head(allwords$fswl$all,30)





