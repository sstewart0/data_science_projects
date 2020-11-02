bnb_data <- read.csv("../AB_NYC_2019.csv")
View(bnb_data)
attach(bnb_data)
sapply(bnb_data,class)

nrow(bnb_data)
#Change date of last review -> as date
bnb_data[,13] = as.Date(bnb_data[,13])

library(ggplot2)
library(RColorBrewer)

#Density of airbnb's in nbhds:
ggplot(bnb_data,aes(x=neighbourhood_group,fill=neighbourhood_group))+
  geom_bar()+theme_minimal()+theme_minimal()+theme(legend.position = "none")+
  scale_fill_brewer(palette="Set3")+
  geom_text(aes(label=..count..),stat="count",position=position_stack())+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Bronx","Staten Island"))+
  labs(x="Neighbourhood Group",y="Count",title="Number of Airbnb's located in each neighbourhood group.")

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
ggplot(nbhd_count,aes(Area,Number_of_sub_divisions,fill=Area)) + geom_bar(stat="identity")+
  labs(x="Neighbourhood Group",y="Number of neighbourhoods",
       title="Number of neighbourhoods within each neighbourhood group")+
  scale_fill_brewer(palette="Set3")+
  theme_minimal()+theme(legend.position="none")+
  scale_x_discrete(limits=c("Manhattan","Staten Island","Brooklyn","Bronx","Queens"))

#Split of room types across area
library(ggrepel)
table(neighbourhood_group,room_type)

ggplot(bnb_data,aes(x=neighbourhood_group,fill=room_type))+geom_bar(position = position_dodge())+
  geom_text_repel(aes(label=..count..),stat="count",position=position_dodge(0.9))+
  scale_fill_brewer(palette="Set3")+theme_minimal()+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Bronx","Staten Island"))+
  labs(x="Neighbourhood Group",y="Count",title="Room types within each neighbourhood group")

#Price range for each area 
ggplot(bnb_data,aes(x=neighbourhood_group,y=price,fill=neighbourhood_group))+
  geom_violin()+ylim(c(0,600))+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Staten Island","Bronx"))+
  labs(x="Neighbourhood Group",y="Price",
       title="Distribution of Airbnb price (per night) within each neighbouhood group")

#Minimum nights for each area
ggplot(bnb_data,aes(x=neighbourhood_group,y=minimum_nights,fill=neighbourhood_group))+
  scale_fill_brewer(palette="Set3")+theme_minimal()+
  geom_violin()+theme(legend.position= "none")+ylim(c(0,35))+
  scale_x_discrete(limits=c("Manhattan","Brooklyn","Queens","Staten Island","Bronx"))+
  labs(x="Neighbourhood Group",y="Minimum nights",
       title="Distribution of Airbnb minimum nights within each neighbouhood group")



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
#reviews per month
median(bnb_data$reviews_per_month,na.rm=T)
mean(bnb_data$reviews_per_month,na.rm=T)
#Find better way to plot!
ggplot(bnb_data,aes(x=calculated_host_listings_count,fill=neighbourhood_group))+geom_bar()+theme_minimal()+
  xlim(c(0,10))
#Find better way to plot!
ggplot(bnb_data,aes(x=calculated_host_listings_count,fill=room_type))+geom_bar()+theme_minimal()+
  xlim(c(0,10))

#Apply mean (and median) calculated host listings to nbhd groups
install.packages("gt")
library(gt)
library(tidyverse)
library(glue)

bnb_data %>%
  group_by(neighbourhood_group) %>%
  summarise(Median = median(calculated_host_listings_count,na.rm=T),
            Mean = round(mean(calculated_host_listings_count,na.rm=T),1),
            Freq = n()) %>%
  gt() %>%
  tab_header(
    title = "Calculated Host Listings"
  ) %>%
  tab_spanner(
    label = "Statistics",
    columns = vars(Median,Mean,Freq)
  )

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

#map of density of airbnb's in NY
ggmap(map)+stat_density2d(aes(x = longitude, y = latitude, fill = ..level.., alpha = ..level..),
                          geom = "polygon",data = bnb_data) +
  scale_fill_gradient2(low = "yellow", mid="orange", high = "red",midpoint=60)+
  theme(legend.position = "none")+
  labs(x="Longitude",y="Latitude",title="Density of Airbnb properties in NY")

#Map of price of airbnb's in NY (price > 1000)
ggmap(map)+geom_point(data=bnb_data[bnb_data$price>1000,],aes(x=longitude,y=latitude,fill=price,alpha=price),
                      shape=23,size=3)+
  scale_fill_gradientn(colours=rainbow(5))+
  labs(x="Longitude",y="Latitude",title="Map of the most expensive Airbnb properties.")

#Map of room-type and price
summary(bnb_data$price)
#less than median price
ggmap(map)+geom_point(data=bnb_data[bnb_data$price<106,],
                      aes(x=longitude,y=latitude,shape=room_type,fill=room_type,size=-price,alpha=-price))+
  scale_size(range=c(0.1,1))+
  labs(x="Longitude",y="Latitude",title="Properties priced less than median price")+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#(median -> third quartile) price
ggmap(map)+geom_point(data=bnb_data[bnb_data$price>106 & bnb_data$price<175,],
                      aes(x=longitude,y=latitude,shape=room_type,fill=room_type))+
  labs(x="Longitude",y="Latitude",title="Properties priced between median and third quartile price")+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))

#Proportion contingency tables
attach(bnb_data)
#The proportion of room types within each area
t1 = prop.table(table(room_type,neighbourhood_group),margin=2)
bnb_data %>%
  group_by(neighbourhood_group,room_type) %>%
  summarise(Percentage = n()) %>%
  group_by(neighbourhood_group) %>% 
  mutate(Percentage=round(Percentage/sum(Percentage)*100,1)) %>%
  gt() %>%
  tab_header(
    title="Distribution of room type within each neighbourhood group"
  )%>%
  tab_spanner(
    label="Neighbourhood Group",
    columns=vars(neighbourhood_group)
  )

#The proportion of room types over all areas
t2 = prop.table(table(neighbourhood_group,room_type),margin=2)

bnb_data %>%
  group_by(room_type,neighbourhood_group) %>%
  summarise(Percentage = n()) %>%
  group_by(room_type) %>% 
  mutate(Percentage=round(Percentage/sum(Percentage)*100,1)) %>%
  gt() %>%
  tab_header(
    title="Distribution of neighbourhood group within each room type"
  )

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
a4 = a3[a3[,4]>10,]

#Top ten most expensive nbhds (median), with at least 10 listings:
l = as.character(tail(a4[order(a4[,3]),],n=10)$neighbourhood)
prop.table(table(bnb_data[bnb_data$neighbourhood %in% l,]$room_type))

ggmap(map)+geom_point(data=bnb_data[bnb_data$neighbourhood %in% l,],
                      aes(x=longitude,y=latitude,fill=neighbourhood,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Top 10 most expensive neighbourhoods")

#Top ten cheapest nbhds (median), with at least 10 listings:
l2 = as.character(head(a4[order(a4[,3]),],n=10)$neighbourhood)
prop.table(table(bnb_data[bnb_data$neighbourhood %in% l2,]$room_type))
ggmap(map)+geom_point(data=bnb_data[bnb_data$neighbourhood %in% l2,],
                      aes(x=longitude,y=latitude,fill=neighbourhood,shape=room_type))+
  scale_shape_manual(values=c(21,22,23))+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Top 10 cheapest neighbourhoods")

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
  theme_minimal()+theme(axis.text.x = element_blank())+
  scale_colour_brewer(palette="Set2")+
  labs(x="Neighbourhood",y="Mean Price",title="Mean Prices of Neighbourhoods (with more than 10 listings)")

#How many hosts have more than 10 listings
nrow(distinct(bnb_data[bnb_data$calculated_host_listings_count>10,],host_id))
#List of unique host id's with more than 10 listings, in decreasing order.
l3=head(distinct(bnb_data[order(bnb_data$calculated_host_listings_count,decreasing = T),],host_id),n=94)[,1]

#Map of hosts with >100 listings
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count>100),],
                      aes(x=longitude,y=latitude,fill=host_name,shape=room_type),size=2)+
  scale_shape_manual(values=c(21,22,23))+
  theme_minimal()+scale_fill_brewer(palette="Set3")+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Hosts with more than 100 listings")

#Map of hosts with  49<listings<101
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count<101 &
                                       bnb_data$calculated_host_listings_count>49),],
                      aes(x=longitude,y=latitude,fill=host_name,shape=room_type),size=2)+
  scale_shape_manual(values=c(21,22,23))+
  theme_minimal()+scale_fill_brewer(palette="Set3")+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Hosts with between 50 and 100 listings")

#Map of hosts with  10<listings<50
ggmap(map)+geom_point(data=bnb_data[((bnb_data$host_id %in% l3) & bnb_data$calculated_host_listings_count<50),],
                      aes(x=longitude,y=latitude,shape=room_type,fill=neighbourhood_group),size=2)+
  scale_shape_manual(values=c(21,22,23))+
  theme_minimal()+scale_fill_brewer(palette="Set3")+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Hosts with between 10 and 50 listings")

#Map of hosts with  10<listings<50
ggmap(map)+geom_point(data=bnb_data[(bnb_data$host_id %in% l3),],
                      aes(x=longitude,y=latitude,shape=room_type,fill=neighbourhood_group),size=2)+
  scale_shape_manual(values=c(21,22,23))+
  theme_minimal()+scale_fill_brewer(palette="Set3")+
  guides(fill = guide_legend(override.aes=list(shape=21)))+
  labs(x="Longitude",y="Latitude",title="Hosts with more than 10 listings.")


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
  geom_point(data=tycoons,alpha=.4,size=.5,shape=4)+geom_point(shape=21)+theme_minimal()+
  theme(axis.text.x = element_blank())+
  geom_hline(yintercept = h,colour="red",linetype="dashed")+
  scale_fill_brewer(palette="Set3")+
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
colnames(m1)[1:5]=c("neighbourhood","True_Claims","True_Claims_Perc","Other_Claims","Other_Claims_Perc")
m1[colnames(m1)[2:5]] <- sapply(m1[colnames(m1)[2:5]],as.numeric)
m1=as.data.frame(m1)

for (i in 1:nrow(m1)){
  t=termco(bnb_data[bnb_data$neighbourhood==neighbourhood[i],]$name,match.list=neighbourhood[i],short.term = T,
           ignore.case=T,apostrophe.remove = T,digit.remove = T)
  m1[i,2]=as.numeric(t$raw[3])
}
for (i in 1:nrow(m1)){
  t=termco(bnb_data[(bnb_data$neighbourhood!=neighbourhood[i])&(bnb_data$neighbourhood_group=="Manhattan"),]$name,
           match.list=neighbourhood[i],short.term = T,ignore.case=T,apostrophe.remove = T,digit.remove = T)
  m1[i,4]=as.numeric(t$raw[3])
}
#Add frquency to create %
gm = bnb_data[bnb_data$neighbourhood_group=="Manhattan",] %>%
  group_by(neighbourhood) %>%
  summarise(Freq=n())

#Add total claims column, correlation with hipness/"popularity"?:
m1$Total_Claims=m1$True_Claims+m1$Other_Claims

#Add percentages
m1=merge(m1,gm,by=c("neighbourhood"))
m1$True_Claims_Perc=round((m1$True_Claims/m1$Freq)*100,2)
m1[order(-m1$Total_Claims),]
View(bnb_data)

#Which Manhattan neighbourhoods use neighbourhood name in Airbnb Title
ggplot(m1,aes(reorder(x=neighbourhood,True_Claims_Perc),y=True_Claims_Perc,fill=Freq))+
  geom_point(shape=21,size=2)+theme_minimal()+scale_fill_gradient(low="yellow",high="red")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(x="Neighbourhood",y="%",title="Which Manhattan neighbourhoods use neighbourhood name in Airbnb Title")

#Total references of Manhattan neighbourhoods in Airbnb title
ggplot(m1,aes(reorder(x=neighbourhood,Total_Claims),y=Total_Claims,fill=Total_Claims))+
  geom_point(shape=21,size=2)+theme_minimal()+scale_fill_gradient(low="yellow",high="red")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),legend.position="none")+
  labs(x="Neighbourhood",y="Count",title="Total references of Manhattan neighbourhoods in Airbnb title")


# (1) what areas are quasi-areas, e.g. Civic Center is quasi-(SoHo/Tribeca/...)
# (2) which properties claim distance to areas, e.g. near/to/from/... SoHo
# (3) are there more popular names for the neighbourhoods, 
#    e.g. Flatiron District is more commonly known as simply Flatiron
#
w=word_list(bnb_data[bnb_data$neighbourhood==neighbourhood[1],]$name)
head(w$fwl$all,30)

#Individual Case analysis
for (i in 1:5){
  print(neighbourhood[i])
  print(head(word_list(bnb_data[bnb_data$neighbourhood==neighbourhood[i],]$name)$fwl$all,20))
}

#(3) -> create list of the names associated with areas
z=as.data.frame(neighbourhood)
aka=rep("",nrow(z))
z=cbind(z,aka)
z$aka=as.character(z$aka)
z$neighbourhood=as.character(z$neighbourhood)

z[z$neighbourhood=="Marble Hill",]$aka=list(c(MarbleHill=list(c("Marble Hill"))))
z[z$neighbourhood=="Stuyvesant Town",]$aka = list(c(EastVillage=list(c("East Village")),DTown=list(c("Downtown")),
                                                    Stuytown=list(c("Stuytown")),Gramercy=list(c("Gramercy"))))
z[z$neighbourhood=="Civic Center",]$aka=list(c(DTown=list(c("Downtown")),Tribeca=list(c("Tribeca"))))
z[z$neighbourhood=="Battery Park City",]$aka=list(c(Battery=list(c("Battery")),DTown=list(c("Downtown")),
                                                    Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Tribeca",]$aka=list(c(Tribeca=list(c("Tribeca")),Blueground=list(c("Blueground"))))
z[z$neighbourhood=="Theater District",]$aka=list(c(TimesSquare=list(c("Times Square")),
                                                   Midtown=list(c("Midtown"))))
z[z$neighbourhood=="Gramercy",]$aka=list(c(Gramercy=list(c("Gramercy")),EastVillage=list(c("East Village")),
                                           UnionSquare=list(c("Union Square"))))
z[z$neighbourhood=="Nolita",]$aka=list(c(Nolita=list(c("Nolita")),SoHo=list(c("SoHo"))))
z[z$neighbourhood=="Two Bridges",]$aka=list(c(CTown=list(c("Chinatown")),DTown=list(c("Downtown")),
                                              Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Little Italy",]$aka=list(c(SoHo=list(c("Soho")),Nolita=list(c("Nolita"))))
z[z$neighbourhood=="Greenwich Village",]$aka=list(c(Village=list(c("Village")),SoHo=list(c("Soho")),
                                                    Greenwich=list(c("Greenwich"))))
z[z$neighbourhood=="Roosevelt Island",]$aka=list(c(Roosevelt=list(c("Roosevelt")),
                                                   Island=list(c("Island")),Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Flatiron District",]$aka=list(c(Flatiron=list(c("Flatiron")),
                                                    Gramercy=list(c("Gramercy")),Chelsea=list(c("Chelsea"))))
z[z$neighbourhood=="NoHo",]$aka=list(c(NoHo=list(c("NoHo")),SoHo=list(c("SoHo")),
                                       GreenwichVillage="Greenwich Village",EastVillage=list(c("East Village"))))
z[z$neighbourhood=="Morningside Heights",]$aka=list(c(Columbia=list(c("Columbia")),UpperWest=list(c("Upper West"))))
z[z$neighbourhood=="Financial District",]$aka=list(c(Sonder=list(c("Sonder")),StockExchange=list(c("Stock Exchange")),
                                                     FDistrict=list(c("fidi","Financial District")),
                                                     DTown=list(c("Downtown"))))
z[z$neighbourhood=="Washington Heights",]$aka=list(c(WHeights=list(c("Washington Heights")),
                                                     Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Upper East Side",]$aka=list(c(UES=list(c("Upper East","UES"))))
z[z$neighbourhood=="SoHo",]$aka=list(c(SoHo=list(c("SoHo"))))
z[z$neighbourhood=="Kips Bay",]$aka=list(c(Midtown=list(c("Midtown")),Manhattan=list(c("Manhattan")),
                                           Gramercy=list(c("Gramercy"))))
z[z$neighbourhood=="Lower East Side",]$aka=list(c(LES=list(c("LES","Lower East Side"))))
z[z$neighbourhood=="East Village",]$aka=list(c(EastVillage=list(c("East Village"))))
z[z$neighbourhood=="Inwood",]$aka=list(c(Inwood=list(c("Inwood")),Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Chelsea",]$aka=list(c(Chelsea=list(c("Chelsea"))))
z[z$neighbourhood=="West Village",]$aka=list(c(Village=list(c("Village"))))
z[z$neighbourhood=="Chinatown",]$aka=list(c(CTown=list(c("Chinatown")),LES=list(c("Lower East Side","LES"))))
z[z$neighbourhood=="Upper West Side",]$aka=list(c(UWS=list(c("Upper West Side","UWS")),
                                                  CentralPark=list(c("Central Park"))))
z[z$neighbourhood=="Hell's Kitchen",]$aka=list(c(HellsKitchen=list(c("Kitchen")),
                                                 TimesSquare=list(c("Times Square")),Midtown=list(c("Midtown"))))
z[z$neighbourhood=="Murray Hill",]$aka=list(c(Midtown=list(c("Midtown")),Manhattan=list(c("Manhattan")),
                                              Sonder=list(c("Sonder")),MurrayHill=list(c("Murray Hill"))))
z[z$neighbourhood=="East Harlem",]$aka=list(c(Harlem=list(c("Harlem")),CentralPark=list(c("Central Park")),
                                              Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Harlem",]$aka=list(c(Harlem=list(c("Harlem")),CentralPark=list(c("Central Park")),
                                         Manhattan=list(c("Manhattan"))))
z[z$neighbourhood=="Midtown",]$aka=list(c(CentralPark=list(c("Central Park")),
                                          Manhattan=list(c("Manhattan"))))
#create unique list of akas
akas=list()
for (i in z$aka){
  akas=append(akas,i)
}
un = unlist(akas)
res = Map(`[`, akas, relist(!duplicated(un), skeleton = akas))
akas = res[lapply(res,length)>0]

#Create DF for counts of akas
m = matrix(0,ncol=length(akas)+1,nrow=length(neighbourhood))
myDF = as.data.frame(m)
colnames(myDF)=c("neighbourhood",names(akas))
myDF$neighbourhood=neighbourhood

#Populate columns
for (i in 1:nrow(myDF)){
  t = termco(bnb_data[bnb_data$neighbourhood==z[i,1],]$name,match.list=z[[i,2]],short.term = T,
           ignore.case=T,apostrophe.remove = T,digit.remove = T)
  for (j in 3:length(t$raw)){
    myDF[myDF$neighbourhood==z[i,1],names(t$raw[j])]=t$raw[[j]]
  }
}

#Add Frequency to create proportions:
myfreq = bnb_data[bnb_data$neighbourhood_group=="Manhattan",] %>%
  group_by(neighbourhood) %>%
  summarise(freq=n())
myDF=merge(myDF,myfreq,by=c("neighbourhood"))

#Change to proportions
for (i in 1:nrow(myDF)){
  myDF[i,2:(ncol(myDF)-1)]=myDF[i,2:(ncol(myDF)-1)]/myDF[i,ncol(myDF)]
}
#Remove freq column
myDF=myDF[,-which(names(myDF) %in% c("freq"))]
View(myDF)

#Use melt to 'classify' columns:
library(reshape2)
myDF = melt(myDF,id.vars = "neighbourhood",variable.name = "AKA")

#Plot popularity of the named areas used to describe neighbourhoods
ggplot(myDF[myDF$value>0,],aes(neighbourhood,value))+
  geom_point(aes(alpha=value),shape=21,fill="pink")+
  geom_text_repel(aes(label = ifelse(value >0.3, as.character(AKA),"")))+theme_minimal()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(x="Neighbourhood",y="%",title="Popularity of the named areas used to describe neighbourhoods")

allwords=word_list(bnb_data$name)
head(allwords$fswl$all,30)
