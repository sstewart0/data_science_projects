man_data = bnb_data[bnb_data$neighbourhood_group=="Manhattan",]
types = (levels(bnb_data$room_type))

?word_list
for (i in types){
  w = word_list(man_data[man_data$room_type==i,]$name)
  print(head(w$fwl$all,20))
}

#Create unique numeric data with no missing values
man_numeric=man_data[,unlist(lapply(man_data,is.numeric))]
man_numeric=na.exclude(man_numeric)
man_numeric=man_numeric[,-c(1,2,3,4)]

names(man_data)

#Amend name from factor to character:
man_data$name=as.character(man_data$name)


w = word_list(man_data[1,]$name)
w$fwl$all
man_data[1,]$name
man_data[1,]

