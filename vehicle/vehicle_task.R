# Load libraries
library(tidyverse)
library(corrplot)
library(caret)
library(ggplot2)
library(gridExtra)
library(glmnet)
library(boot)
library(randomForest)

# Read data
vehicle_data = read.csv("Vehiclefile_Test.csv")
vehicle_data3=read.csv("Vehiclefile_Test.csv")

# Assess feature variable types
lapply(vehicle_data,class)

# Remove £ symbol from premium
vehicle_data$Premium = gsub("£","",vehicle_data$Premium)

# Split vehicle registration years into start and end year
vehicle_data$start_year = as.data.frame(str_split_fixed(vehicle_data$Vehicle_Years, "-", 2))[[1]]
vehicle_data$end_year = as.data.frame(str_split_fixed(vehicle_data$Vehicle_Years, "-", 2))[[2]]

# If vehicle currently registered then enter 2020 as end year
vehicle_data$end_year = as.character(vehicle_data$end_year)
vehicle_data[vehicle_data$end_year=="",]$end_year = "2020"

# List of variables to amend
numeric_variables = c("ABI__8_Digit_","Vehicle_Doors","Vehicle_Engine_CC","Vehicle_length",
                      "Vehicle_Maximum_Speed","Vehicle_MPG","Vehicle_Power Vehicle_Power_to_Weight_Ratio",
                      "Premium","P2W.v2","start_year","end_year")
catagorical_variables = c("Vehicle_Model","Vehicle_Brand","Vehicle_Transmission")
remove_variables = c("Vehicle_Years")

# Amend numerical data (NA's introduced)
vehicle_data[,which(names(vehicle_data) %in% numeric_variables)]=
  lapply(vehicle_data[,which(names(vehicle_data) %in% numeric_variables)],
         function(x) as.numeric(as.character(x)))

# Amend catagorical data
vehicle_data[,which(names(vehicle_data) %in% catagorical_variables)]=
  lapply(vehicle_data[,which(names(vehicle_data) %in% catagorical_variables)],
         function(x) as.factor(as.character(x)))

# Remove variables
vehicle_data=vehicle_data[,-which(names(vehicle_data) %in% remove_variables)]

# Check corrections
lapply(vehicle_data,class)
View(vehicle_data)
# Create colour palette for corrplot
col = colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))

# Pearson correlation coefficient, use only numeric variables
corr = cor(vehicle_data[,sapply(vehicle_data, is.numeric)],use = "pairwise.complete.obs")

# Significance levels
res =cor.mtest(vehicle_data[,sapply(vehicle_data, is.numeric)],use = "pairwise.complete.obs", conf.level = .95)

# Plot of correlation for all numeric variables
corrplot(corr,method="color",col=col(200),type="upper",tl.col = "black", addCoef.col = "black",
         tl.srt = 90,order="hclust",p.mat=res$p,insig="blank",sig.level=0.01,diag=F)

# Missing values:
summary(vehicle_data)
# There are 2030 missing Vehicle: Length, Power to Weigh Ratio and MPG (and 4060 missing premiums):
#   (1) Missing values intersect?
na_length = which(is.na(vehicle_data$Vehicle_Length))
na_ptwr = which(is.na(vehicle_data$Vehicle_Power_to_Weight_Ratio))
na_mpg = which(is.na(vehicle_data$Vehicle_MPG))
na_premium = which(is.na(vehicle_data$Premium))
length(Reduce(intersect, list(na_length,na_mpg,na_ptwr)))
#       Yes, all of them.
# Same overlap with premium?
length(Reduce(intersect, list(na_length,na_mpg,na_ptwr,na_premium)))
# No, only 396.

#   (2) Pattern of 2030 missing values or missing at random?

# Add a category for missing or not in new dataframe:
missed = rep(F,nrow(vehicle_data))
vehicle_data2 = cbind(vehicle_data,missed)
remove(missed)
vehicle_data2[na_length,]$missed = T

# Density plots of continuous numerical variables to assess distributions
p1 = ggplot(data=vehicle_data2,aes(x=Vehicle_Engine_CC,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle Engine CC")+theme_minimal()+
  theme(legend.position = "none")
p2 = ggplot(data=vehicle_data2,aes(x=Vehicle_Maximum_Speed,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle Maximum Speed")+theme_minimal()+
  theme(legend.position = "none")
p3 = ggplot(data=vehicle_data2,aes(x=Vehicle_Power,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle Power")+theme_minimal()+
  theme(legend.position = "none")
p4 = ggplot(data=vehicle_data2,aes(x=P2W.v2,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") + xlim(c(0,220))+theme_minimal()+
  theme(legend.position = "none")
p5 = ggplot(data=vehicle_data2,aes(x=Premium,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3")+theme_minimal()

# Plot together on a grid
grid.arrange(
  p1,p2,p3,p4,p5,
  nrow = 2,
  top = "Density plots for continuous numerical variables"
  )

# It appears that the values are not missing from random, in fact, the missing values seem to have
# much lower P2W.v2.

# Boxplots for discrete numerical data
b1 = ggplot(data=vehicle_data2,aes(x=missed,y=Vehicle_Doors,fill=missed))+geom_boxplot(alpha=.6)+
  scale_fill_brewer(palette="Set3")+theme_minimal()+labs(y="Vehicle Doors")+
  theme(legend.position = "none")
b2 = ggplot(data=vehicle_data2,aes(x=missed,y=start_year,fill=missed))+geom_boxplot(alpha=0.6)+
  scale_fill_brewer(palette="Set3")+theme_minimal()+labs(y="Start Year")+
  theme(legend.position = "none")
b3 = ggplot(data=vehicle_data2,aes(x=missed,y=end_year,fill=missed))+geom_boxplot(alpha=0.6)+
  scale_fill_brewer(palette="Set3")+theme_minimal()+labs(y="End Year")

# Plot together on a grid
grid.arrange(
  b1,b2,b3,
  nrow = 1,
  top = "Boxplots for discrete numerical variables"
)
# From these boxplots, all variables seem to have been picked at random

# distribution of car brands within missing values
round(prop.table(table(vehicle_data2$Vehicle_Brand,vehicle_data2$missed),2)*100,2)
# The proportions of car brand in missing and non-missing data are similar, 
# i.e. appear to be chosen at random.

# distribution of transmission within missing values
round(prop.table(table(vehicle_data2$Vehicle_Transmission,vehicle_data2$missed),2)*100,2)
# Distribution similar => random

# distribution of fuel type within missing values
round(prop.table(table(vehicle_data2$Vehicle_Fuel,vehicle_data2$missed),2)*100,2)
# Distribution similar => random

#   Conclude: Missing data pattern only appears for P2W.v2 as mentioned before
summary(vehicle_data[(na_length),]$P2W.v2)
summary(vehicle_data[-(na_length),]$P2W.v2)

levels(as.factor(vehicle_data[(na_length),]$P2W.v2))
# Upon further inspection, it appears that P2W.v2 takes either a value of 0 or 15 for missing values
# => this variable is unreliable (lowest P2W.v2 is 31.5)
# We will not be able to use this variable in predicting missing values.

# Multivariate missing data:
#   1. Are all of the same type, that is, numeric,
#   2. Do not appear to have strong correlations,
#   3. Imputation may create combinations that are impossible in real-life scenarios.
#   4. Missing at random.

# Method:
#   -> Predict missing values separately using relevant non-missing features,
#   If there was not the same time-constraint:
#   -> Predict missing values using relevant non-missing features and 1 predicted feature
#   -> Predict missing values using relevant non-missing features and all other predicted features (if relevant)
#   -> Store the average result.

# Predicting MPG (assumptions):
#   -> Most likely relevant: Emgine-CC, max-speed, power, (Predicted:power to weight ratio)
#   -> Possibly relevant: Doors (more doors => heavier => lower mpg?),
#                         Fuel-type (similar reasoning to above)
#                         Transmission (automatic more fule efficient?)
#                         (Predicted:Length (longer => lower mpg?)) 

# Strong positive multicollinearity between vehicle power, max-speed and power
# (in particular vehicle power highly positively correlated to other 2)

# doors-mpg:
ggplot(vehicle_data[-na_length,],aes(Vehicle_Power,Vehicle_MPG,colour=as.factor(Vehicle_Doors)))+
  geom_point(alpha=0.1)+
  geom_smooth(se=F,method=lm,formula = y ~ splines::bs(x, degree=2,df=3))+theme_minimal()+
  labs(x="Power",y="MPG")
#Violin plot:
ggplot(vehicle_data[-na_length,],aes(as.factor(Vehicle_Doors),Vehicle_MPG,fill=as.factor(Vehicle_Doors)))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Doors",y="MPG")
# Not a huge difference. 3 door cars seem to have higher mpg in general.

# fuel-type-mpg:
ggplot(vehicle_data[-na_length,],aes(Vehicle_Power,Vehicle_MPG,colour=as.factor(Vehicle_Fuel)))+
  geom_point(alpha=0.1)+
  geom_smooth(se=F,method=lm,formula = y ~ splines::bs(x, degree=2,df=3))+theme_minimal()+
  labs(x="Power",y="MPG")
# Violin plot:
ggplot(vehicle_data[-na_length,],aes(Vehicle_Fuel,Vehicle_MPG,fill=Vehicle_Fuel))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Fuel-Type",y="MPG")
# Appears that Diesal cars have higher mpg

# transmission-mpg: violin plot
ggplot(vehicle_data[-na_length,],aes(Vehicle_Transmission,Vehicle_MPG,fill=Vehicle_Transmission))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Transmission",y="MPG")
# Appears that there are some manual cars with higher mpg

# Length-mpg
ggplot(vehicle_data[-na_length,],aes(Vehicle_Length,Vehicle_MPG,colour=as.factor(Vehicle_Doors)))+
  geom_point(alpha=.2)+theme_minimal()+labs(x="Length",y="MPG")
# Appears to be no meaningful effect

# Predicting length assumptions:
#   -> Most likely relevant: !doors!, max-speed, engine-cc, power
#   -> possibly relevant: transmission?, fuel-type?

# Doors-length: 
ggplot(vehicle_data[-na_length,],aes(Vehicle_Power,Vehicle_Length,colour=as.factor(Vehicle_Doors)))+
  geom_point(alpha=0.1)+
  geom_smooth(se=F,method=lm,formula = y ~ splines::bs(x, degree=2,df=3))+theme_minimal()+
  labs(x="Power",y="Length")
# Violin plot:
ggplot(vehicle_data[-na_length,],aes(as.factor(Vehicle_Doors),Vehicle_Length,fill=as.factor(Vehicle_Doors)))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Doors",y="Length")+ylim(c(2500,5500))
# 3 door cars are shortest, 4 door cars are longest, 5 door cars are eavenly spread out.

#transmission-length:
ggplot(vehicle_data[-na_length,],aes(Vehicle_Transmission,Vehicle_Length,fill=Vehicle_Transmission))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Transmission",y="Length")
# Manual slightly shorter? not much difference

#fueltype-length:
ggplot(vehicle_data[-na_length,],aes(Vehicle_Fuel,Vehicle_Length,fill=Vehicle_Fuel))+
  geom_violin()+theme_minimal()+theme(legend.position= "none")+
  scale_fill_brewer(palette="Set3")+labs(x="Fuel Type",y="Length")
# Petrol slightly shorter? not much difference

# Predicting p2wr assumptions:
#   -> Most likely relevant: max-speed, power, engine-cc, (pred:mpg) (from corrplot)
#   -> other catagorical variables not as relevant here?

# Due to time constraints I am not considering interaction terms and will only consider higher order terms
# of numerical variables up to cubic terms.

# Choosing a model for MPG:
# Variables chosen: fuel-type, engine-cc, maxspeed, power & power-to-weight-ratio.
# Assess what level of higher order terms to choose:

set.seed(123)
# Choose K=9 for cross-validation => test set will be ~2000 = size of missing values
cv.errors=rep(0,9)
for (i in 1:3){
  for (j in 1:3){
    # Build linear model
    mpg_lm1 = glm(Vehicle_MPG~Vehicle_Fuel+poly(Vehicle_Maximum_Speed,i)+poly(Vehicle_Power,j),
                  data=vehicle_data[-na_length,])
    # Save cross-validation estimate of test error
    cv.errors[(i-1)*3+j]=cv.glm(vehicle_data[-na_length,],mpg_lm1,K=9)$delta[1]
  }
}
cv.errors
# Choose quadratic vehicle_power and linear max-speed variables
# (reduction in error for higher terms negligable compared to
# the increase in polynomial term overfitting caused.)

# Assess linear model
mpg_lm1_fin = lm(Vehicle_MPG~Vehicle_Fuel+Vehicle_Maximum_Speed+poly(Vehicle_Power,2),
                 data=vehicle_data[-na_length,])

# Check params ---> all highly significant
summary(mpg_lm1_fin)

# Assess linearity assumptions:
plot(mpg_lm1_fin)
# Residuals-vs-fitted => no heteroskedasticity
# QQ plot and residuals-vs-levarage => outliers may skew parameter results

# Compare various models using cross-validation:
set.seed(1)
train.control <- trainControl(method = "cv", number = 9)
summary(vehicle_data[-which(is.na(vehicle_data)),])
#LS
ls_model <- train(Vehicle_MPG ~ Vehicle_Engine_CC+poly(Vehicle_Power,2)+
                    Vehicle_Maximum_Speed+Vehicle_Fuel, data = vehicle_data[-na_length,],
                  method = "lm",trControl = train.control,na.action = na.exclude)
#Ridge
ridge_model <- train(Vehicle_MPG ~ Vehicle_Engine_CC+poly(Vehicle_Power,2)+
                       Vehicle_Maximum_Speed+Vehicle_Fuel, data = vehicle_data[-na_length,], method = "ridge",
                     trControl = train.control,na.action = na.exclude)
#Lasso
lasso_model <- train(Vehicle_MPG ~ Vehicle_Engine_CC+poly(Vehicle_Power,2)+
                       Vehicle_Maximum_Speed+Vehicle_Fuel, data=vehicle_data[-na_length,], method = "lasso",
                     trControl = train.control,na.action = na.exclude)
#PCR
pcr_model <- train(Vehicle_MPG ~ Vehicle_Engine_CC+poly(Vehicle_Power,2)+
                     Vehicle_Maximum_Speed+Vehicle_Fuel, data=vehicle_data[-na_length,], method = "pcr",
                   trControl = train.control,na.action = na.exclude)

#Compare linear models using the root mean square error metric (estimate of model standard error)
results <- resamples(list(LS=ls_model,RIDGE=ridge_model,LASSO=lasso_model,PCR=pcr_model))
bwplot(results,metric = "RMSE")
# From the plot it is clear that ridge regression is the best performing

# The final value used for the model was lambda = 1e-04 (regularisation parameter)

# Predict missing MPG:
mpg_pred = predict(ridge_model,newdata = vehicle_data[na_length,])
#Round to 1dp and insert missing values (there are two eronious data points with various NA's that I ignore)
missing_ids = intersect(names(mpg_pred),rownames(missing_data))
vehicle_data[missing_ids,]$Vehicle_MPG=round(mpg_pred,1)
"
METHOD:
  PROS:
    -> Prediction accuracy of the ridge regression model for mpg was good.
    -> Variance of RMSE was low (from boxplot)
    -> More accurate than imputing mean/median/mode
  CONS:
    -> Error in prediction unavoidable
    -> May create MPG values that are impossible in real-life
"

#Simple linear model to predict length
simple_lin_length = glm(Vehicle_Length~Vehicle_Doors+Vehicle_Maximum_Speed+Vehicle_Engine_CC+Vehicle_Power,
                       data=vehicle_data[-na_length,])
cv_errs_length = cv.glm(vehicle_data[-na_length,],simple_lin_length,K=9)

# Assess cv-error
cv_errs_length$delta[1]
# 70784.57 => linear modelling not appropriate (error far too high)

# Hence a better method to handle missing length is to impute group median/mean length for each door type:
vehicle_data %>%
  group_by(Vehicle_Doors) %>%
  summarise(MEDIAN=median(Vehicle_Length,na.rm=T),MEAN=mean(Vehicle_Length,na.rm=T),FREQ = n())
# The mean length for each group is lower than median => mean not skewed by outliers

# Hence impute group mean length for missing length values
vehicle_data$Vehicle_Length=ave(vehicle_data$Vehicle_Length,vehicle_data$Vehicle_Doors,
                                FUN=function(x) ifelse(is.na(x), mean(x,na.rm=TRUE), x))
"
METHOD:
  PROS:
    -> There will be no impossible values (i.e. negative or massive lengths)
    -> Computationally time and cost efficient (unlike, say, random forest)
  CONS:
    -> The true test error will be high
    -> May create impossible combinations with other variables, but less likely than with predicting.

Build model for power to weight ratio?
variables: max-speed, power, engine-cc, (pred:mpg)
(If P2W.v2 was available the prediction would be much more accurate since their correlation ≈ perfect positive)
"
for (i in 1:2){
  for (j in 1:2){
    for (k in 1:2){
      lm_p2w = glm(Vehicle_Power_to_Weight_Ratio~poly(Vehicle_Maximum_Speed,k)+
                     poly(Vehicle_Power,j)+poly(Vehicle_Engine_CC,i)+Vehicle_MPG,
        data = vehicle_data[-na_length,])
      print(cv.glm(vehicle_data[-na_length,],lm_p2w,K=9)$delta[1])
    }
  }
}
# Choose max-speed quadratic, all else linear (largest reduction in cv-error)
# Train multiple linear models as before:
# LS
ls_model2 <- train(Vehicle_Power_to_Weight_Ratio~poly(Vehicle_Maximum_Speed,2)+
                     Vehicle_Power+Vehicle_Engine_CC+Vehicle_MPG, data = vehicle_data[-na_length,],
                  method = "lm",trControl = train.control,na.action = na.exclude)
#Ridge
ridge_model2 <- train(Vehicle_Power_to_Weight_Ratio~poly(Vehicle_Maximum_Speed,2)+
                        Vehicle_Power+Vehicle_Engine_CC+Vehicle_MPG, data = vehicle_data[-na_length,], method = "ridge",
                     trControl = train.control,na.action = na.exclude)
#Lasso
lasso_model2 <- train(Vehicle_Power_to_Weight_Ratio~poly(Vehicle_Maximum_Speed,2)+
                        Vehicle_Power+Vehicle_Engine_CC+Vehicle_MPG, data=vehicle_data[-na_length,], method = "lasso",
                     trControl = train.control,na.action = na.exclude)
#PCR
pcr_model2 <- train(Vehicle_Power_to_Weight_Ratio~poly(Vehicle_Maximum_Speed,2)+
                      Vehicle_Power+Vehicle_Engine_CC+Vehicle_MPG, data=vehicle_data[-na_length,], method = "pcr",
                   trControl = train.control,na.action = na.exclude)

#Compare linear models using the root mean square error metric (estimate of model standard error)
results2 <- resamples(list(LS=ls_model2,RIDGE=ridge_model2,LASSO=lasso_model2,PCR=pcr_model2))
bwplot(results2,metric = "RMSE")
# From the plot it shows that, by RMSE, ridge is best performing. However, lasso is not too far behind,
# and the variance in error is much lower so this is a better choice.

# Predict power to weight ratio using lasso model
pred_p2wr = predict(lasso_model2,newdata=vehicle_data[na_length,])
# Insert predicted values:
vehicle_data[missing_ids,]$Vehicle_Power_to_Weight_Ratio=round(pred_p2wr,1)
View(vehicle_data)

length(levels(vehicle_data$Vehicle_Brand))
"
METHOD pro's and con's same as with predicting mpg. As mentioned before if P2W.v2 was available predictions
would be far more accurate. It would be interesting to see how MICE algorithm would have dealt with the NA's.
"

# How does the lasso model handle adding car-brand?
large_lasso<- train(Vehicle_Power_to_Weight_Ratio~Vehicle_Maximum_Speed+
                      Vehicle_Power+Vehicle_Engine_CC+Vehicle_MPG+Vehicle_Brand, 
                    data=vehicle_data[-na_length,], method = "lasso",
                      trControl = train.control,na.action = na.exclude)

results2 <- resamples(list(LS=ls_model2,RIDGE=ridge_model2,LASSO=lasso_model2,PCR=pcr_model2,LargeLasso=large_lasso))
bwplot(results2,metric = "RMSE")
# Addition of brand variable reduces the RMSE by ~ 0.5. This is a great improvement, however the model failed to
# fit at 3 folds on the optimal regularisation parameter due to zero variance of some columns.

"
Issues with using imputed variables in predicting premium:
  -> Error in imputed values will create inaccurate param's in the fitted model
    => use non-imputed values to train and assess error initially.
"
vehicle_data$missed=vehicle_data2[-which(is.na(vehicle_data2$ABI__8_Digit_)),]$missed
# Assess distribution of imputated/predicted values:
plot1 = ggplot(data=vehicle_data,aes(x=Vehicle_Length,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle Length")+theme_minimal()+
  theme(legend.position = "none")
plot2 = ggplot(data=vehicle_data,aes(x=Vehicle_MPG,fill=missed))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle MPG")+theme_minimal()+
  theme(legend.position = "none")
plot3 = ggplot(data=vehicle_data,aes(x=Vehicle_Power_to_Weight_Ratio,fill=missed))+
  geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Vehicle P2WR")+theme_minimal()
# Plot together on a grid
grid.arrange(
  plot1,plot2,plot3,
  nrow = 1,
  top = "Assess how imputation has affected distribution"
)
"
imputed vehicle lengths distributed about the group means as expected (group=no.doors)
imputed Vehicle-MPG is has been heavily skewed towards the mean,
imputed power to weight ratio is almost perfectly distributed as non-missing data

Improvement:
  Model power to weight ratio (P2WR) as before, but without MPG. Then model MPG as before but with the addition
  of the P2WR variable. Average the predicted mpg and P2WR variables.
  ... and further ...
  i.e. model (MPG,Length, P2WR) ~ multivariate_gaussian(mean,var-cov).
"

length(intersect(missing_ids,which(is.na(vehicle_data$Premium))))
# 394 entries have missing (imputed) feature values and missing premium.
length(which(is.na(vehicle_data$Premium)))-394
# This leaves 3636 entries that can be predicted using non-imputed feature values.
# missing feature and not missing premium:
length(intersect(missing_ids,which(!is.na(vehicle_data$Premium))))
# 1634 premiums are not missing but have missing features.
length(union(missing_ids,which(is.na(vehicle_data$Premium))))
5664/20112
# 5664 entries have missing premium and features, this is 28% of the data, i.e. a lot.
non_valid_ids = as.numeric(union(missing_ids,which(is.na(vehicle_data$Premium))))

"
This is important to know because we need to be able to assess how much effect the imputed values
has on the predicted premium.

I want to use Support Vector Machines to try to predict Premium, this requires manual k-fold-CV
"
#remove entries with missing premium & features.
shuffled_data = vehicle_data[-non_valid_ids,]
#Randomly shuffle the data
shuffled_data=shuffled_data[sample(nrow(shuffled_data)),]
#Create 4 equally size folds (creates test size roughly equal to number of missing premiums)
folds = cut(seq(1,nrow(shuffled_data)),breaks=9,labels=F)

#Perform 4 fold cross validation
cv.errs.prem = rep(0,4)
for(i in 1:4){
  #Segement your data by fold using the which() function 
  testIndexes = which(folds==i,arr.ind=TRUE)
  testData = shuffled_data[testIndexes, ]
  trainData = shuffled_data[-testIndexes, ]
  svm_premium = svm(Premium~.-ABI__8_Digit_-Vehicle_Model-P2W.v2,
                    data=trainData,
                    type="eps-regression",
                    kernel="linear")
  pred_premium = predict(svm_premium,newdata=testData)
  cv.errs.prem[i]=(sum((pred_premium-testData$Premium)^2)/nrow(testData))
}
svm_premium$SV
sqrt(sum(cv.errs.prem)/4)
"
Even without addition of any imputed values we get a 4-fold cross validated root mean squared error of 86.29757.
CON - this method is coputationally expensive and time consuming.
Let's see if previous regression methods outperform SVM.
As before, lasso regression can perform variable selection so let's try, but repeat 5 times since fold are small in number:
"
set.seed(1)
train.control2 <- trainControl(method = "repeatedcv", number = 4, repeats = 5)
large_lasso2<- train(Premium~.-ABI__8_Digit_-Vehicle_Model-P2W.v2,
                    data=vehicle_data[-non_valid_ids,],
                    method = "lasso",
                    trControl = train.control2,
                    na.action = na.exclude)
# Fails to fit model for many folds with fraction=0.9
plot(large_lasso2)
large_lasso2$results$RMSESD
# However, at fraction=0.5, the RMSE is ≈ 86 which is lower than SVM and computationally this method
# is much more efficient. Also the cv is repeated, so the RMSE is more accurate than that of the SVM model.

# Let's fit the lasso model to the data with imputed values included
set.seed(1)
large_lasso_with_imputed=train(Premium~.-ABI__8_Digit_-Vehicle_Model-P2W.v2,
                               data=vehicle_data[-na_premium,],
                               method = "lasso",
                               trControl = train.control2,
                               na.action = na.exclude)
large_lasso_with_imputed$results$RMSE
large_lasso_with_imputed$results$RMSESD
plot(large_lasso_with_imputed)
# As expected, there is an increase in the RMSE due to imputed values.

# Finally, let's try without brand feature:
set.seed(1)
large_lasso_with_imputed_no_brand=train(Premium~.-ABI__8_Digit_-Vehicle_Model-P2W.v2-Vehicle_Brand,
                                        data=vehicle_data[-na_premium,],
                                        method = "lasso",
                                        trControl = train.control2,
                                        na.action = na.exclude)
large_lasso_with_imputed_no_brand$results$RMSE
large_lasso_with_imputed_no_brand$results$RMSESD
plot(large_lasso_with_imputed_no_brand)
plot(large_lasso_with_imputed_no_brand$finalModel)
"
PROS: 
  The model can be fitted for all fractions,
  Computationally much quicker & negligable difference in RMSE compared to the previous lasso regression.
Predict Premiums:
"
pred_prem = predict(large_lasso_with_imputed_no_brand,newdata = vehicle_data[na_premium,])
na_ids = intersect(names(pred_prem),na_premium)
vehicle_data[na_ids,]$Premium=round(pred_prem,1)

# Finally delete the eronious NA's that have plagued our data:
vehicle_data=vehicle_data[-which(is.na(vehicle_data$ABI__8_Digit_)),]

#Plot distribution of premiums:
vehicle_data$missing_premium = rep(F,nrow(vehicle_data))
vehicle_data[na_premium,]$missing_premium = T
ggplot(data=vehicle_data,aes(x=Premium,fill=missing_premium))+geom_density(alpha=0.4)+
  scale_fill_brewer(palette="Set3") +labs(x="Premium")+theme_minimal()
"
Distribution of predicted premiums not similar to available premiums,
this would imply that the accuray of the predictions could be better.
If the missing features were given/(predicted more accurately) the distribution would be similar.

It would be interesting to see how (some form of) neural-net would perform,
how natural-language processing in the vehicle-model could help to more accurately
predict missing features and premiums.

These predictions do not properly reflect the true premiums and would therefore 
cost the customer - too much => reduces custom for AXA
                  - too little => cost AXA a lot (not enough reserves)
"

