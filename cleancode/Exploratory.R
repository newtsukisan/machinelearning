# Exploratory Analisys of data.

# 0. Objetives ------------------------------------------------------------
# Explore data and decide which predictors are important or significative.

# 1. Libraries ------------------------------------------------------------

require(caret)
require(ggplot2)
require(data.table)
require(testit)
require(data.table)
require(rpart)
require(randomForest)
# Functions
source("../functions/functions.R")

# 2. loading data  -------------------------------------------------------
 data   <- read.csv("../data/pml-training.csv")

# 3. Preview of the data --------------------------------------------------

# In a simple inspection looks like a lot of variables with NA values have a great number
# of NA values. To look for these values, number of NA in each column is calculated. 
plot1 <- data.frame(apply(data, 2, function(x) sum(is.na(x))))
setnames(plot1,names(plot1),c('value'))
# Create an histogram to see distribution of NA values. We can see there are only two values.
# 0 NA or 19216. So, in column with NA, the number of NA represents 98% of the values. 
hist <- ggplot(plot1, aes(x=value))
hist+geom_histogram()
# We can see what is the proportion of preditors with this high number of NA.
prop.table(table(plot1$value))
# 41 % of predictors have 95 % of NA.
# The number of NA values are a great proportion of all data. 97 % of the data in the predictors
# with NA values are NA values. So there are no much information in those variables.
max(plot1$value)/nrow(data)
# Hipothesis 1. Predictors with high number of NA are discarted. 
indexHNA  <- which(plot1$value>0)    # column index of predictors with high NAs
# Simple check for right predictors with no NAs.
assert("Right predictors",all(apply(data[,-indexHNA],  2, function(x) sum(is.na(x)))==0))
assert("Right predictors discarted",all(apply(data[, indexHNA],  2, function(x) sum(is.na(x)))==19216))

# Similar situation occurs with predictors  with empty values. 
# Hipothesis 2. Predictors with high number of empty vaulues are discarted.


# 3. Preparing data -------------------------------------------------------

# Deleting data with high porcentage of NA or blank values.
data.clean      <- data       [, -getIndexWithPred(data,is.na,0)]
data.clean      <- data.clean [, -getIndexWithPred(data.clean,function(x) x=="",0)]
# Deleting X, user name a timeStamps variables
data.clean      <- data.clean [,-c(1:5)]
assert("Less columns expected",ncol(data.clean )< ncol(data))
# Create partition and train and data 
inTrain   <- createDataPartition(data.clean$classe, p = 0.8,list=F)
tidy1     <- data.clean[ inTrain,]
testing1  <- data.clean[-inTrain,]
rm(data);rm(data.clean);


# 4. Look for correlations ------------------------------------------------

# Now we can look for correlations in numeric predictors. But only using training data.

indNumeric  <- which(lapply(tidy1, class)=="numeric")    # columns with numeric data
numericData <- tidy1[,indNumeric]                        # for correlations study
M           <- abs(cor(numericData))                     # correlation matrix
index       <- columnOf(which(upper.tri(M) & M > 0.8),
                        dim(M)[[1]])                     # Where cor is greater than 0.8
highCorPredictornames <- names(numericData)[index]       # Predictor with high correlation
#Identify Predictor with high correlation
PredictorForPCA       <- numericData[,highCorPredictornames]
# Now Transform these predictors into pca mantaining 80 % of variance.
preProcPCA    <- preProcess(PredictorForPCA, method = "pca",thresh = 0.80)
PredictorsPCA <- predict(preProcPCA, PredictorForPCA)     # Predictores  pca

# Group 1 for training. All data cleaned. tidy1

# Group 2 for training. Subtitue 6 high correlated predictor with PCA equivalents with 80 %
# of variance. tidy2
predictorNumeric  <- cbind(numericData[,-index], PredictorsPCA) 
tidy2 <- cbind(tidy1[,-indNumeric],predictorNumeric)

# Group 3 for training. Substitue all numeric predictors with PCA equivalents with 80 % of
# variance. tidy3
preProcPCAall    <- preProcess(numericData, method = "pca",thresh = 0.80)
allPredictorsPCA <- predict(preProcPCAall , numericData)
tidy3            <- cbind(tidy1[,-indNumeric],allPredictorsPCA)

# 5. Training models ------------------------------------------------------
# Create a partition
training1        <- tidy1                  # training with all variables.
# Training with pca variables of 6 with high correlation.
training2        <- tidy2
index.test2      <- which(lapply(testing1, class)=="numeric")
numericDataTest  <- testing1[,indNumeric]
PredictorPCATest <- numericDataTest[,highCorPredictornames]
t2.1             <- predict(preProcPCA, PredictorPCATest)     # Predictores  pca
t2.2             <- cbind(numericDataTest[,-index], t2.1) 
testing2         <- cbind(testing1[,-indNumeric],t2.2)
# Training with pca variables instead of all numeric variables.
training3          <- tidy3
allPredictorsPCA   <- predict(preProcPCAall, numericDataTest)
testing3           <- cbind(testing1[,-index.test2 ],allPredictorsPCA)
# Removing some variables to free memory.
rm(tidy1)
rm(tidy2)
rm(tidy3)
rm(numericDataTest)
rm(allPredictorsPCA)
rm(t2.2)
rm(t2.1)

# Train First with trees. All these models have high errors in training sets, so we expect
# worse performance in test and more general data sets. 
modelrpart.1  <- train(classe ~.,data=training1, method="rpart")
tpredict      <- predict(modelrpart.1$finalModel,type="class")
confusionMatrix(tpredict,training1$classe)

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelrpart.2  <- train(classe ~.,data=training2, method="rpart")
tpredict.2    <- predict(modelrpart.2$finalModel,type="class")
confusionMatrix(tpredict.2,training2$classe)

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelrpart.3  <- train(classe ~.,data=training3, method="rpart")
# Accuracy estimated is 0.54 from cross validation.
tpredict.3    <- predict(modelrpart.3$finalModel,type="class")
confusionMatrix(tpredict.3,training3$classe)

# After we use random forest to model the three groups and try to find the one with the best
# performance.

# Train now using random Forest. Model 1 use all variables.
modelRF.1 <- randomForest(classe ~ ., 
                          data=training1,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
modelRF.1

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelRF.2 <- randomForest(classe ~ ., 
                          data=training2,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
modelRF.2
# Train second model. 
modelRF.3 <- randomForest(classe ~ ., 
                          data=training3,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
modelRF.3


# Considering OOB error as a estimation of Error out of sample, we decided to use model with
# minimun OOB. To check our estimations, we predict on test sample an calculate confussion Matrix
prediccionRF.1 <- predict(modelRF.1,newdata=testing1)
confusionMatrix(prediccionRF.1,testing1$classe)
