# 0. Objetives ------------------------------------------------------------
# tidy data
# correlations for looking for possibles pca

# Pero es necesario realizar la division entre training y test antes de hacer las transforamciones
# Para realizar poder utilzar la estimacion de cross validation es necesario obtener antes
# la division entre training y data test.
# 1. Libraries ------------------------------------------------------------

require(caret)
require(ggplot2)
require(data.table)
require(testit)
require(rpart)
require(randomForest)
require(testit)
source("functions/functions.R")

# 2. loading data  -------------------------------------------------------
data   <- read.csv("data/pml-training.csv")
# Inspect some data
head(data$classe)
summary(data)



# Cleaning data for training ----------------------------------------------

# Deleting data with high porcentage of NA or blank values.
data.clean      <- data       [, -getIndexWithPred(data,is.na,0)]
data.clean      <- data.clean [, -getIndexWithPred(data.clean,function(x) x=="",0)]
# Deleting X, user name a timeStamps variables
data.clean      <- data.clean [,-c(1:6)]
assert("Less columns expected",ncol(data.clean )< ncol(data))
# Create partition and train and data 
inTrain   <- createDataPartition(data.clean$classe, p = 0.8,list=F)
tidy1     <- data.clean[ inTrain,]
testing1  <- data.clean[-inTrain,]
# rm(data);rm(data.clean);

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


# 3. Training models ------------------------------------------------------
# Create a partition
training1 <- tidy1

training2        <- tidy2
index.test2      <- which(lapply(testing1, class)=="numeric")
numericDataTest  <- testing1[,indNumeric]
PredictorPCATest <- numericDataTest[,highCorPredictornames]
t2.1             <- predict(preProcPCA, PredictorPCATest)     # Predictores  pca
t2.2             <- cbind(numericDataTest[,-index], t2.1) 
testing2         <- cbind(testing1[,-indNumeric],t2.2)

dim(numericDataTest[,-index])
dim(PredictorPCATest)

training3          <- tidy3
allPredictorsPCA   <- predict(preProcPCAall, numericDataTest)
testing3           <- cbind(testing1[,-index.test2 ],allPredictorsPCA)



# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelrpart.1  <- train(classe ~.,data=training1, method="rpart")
# Accuracy estimated is 0.54 from cross validation.
tpredict      <- predict(modelrpart.1$finalModel,type="class")
confusionMatrix(tpredict,training1$classe)

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelrpart.2  <- train(classe ~.,data=training2, method="rpart")
# Accuracy estimated is 0.54 from cross validation.
tpredict.2    <- predict(modelrpart.2$finalModel,type="class")
confusionMatrix(tpredict.2,training2$classe)

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelrpart.3  <- train(classe ~.,data=training3, method="rpart")
# Accuracy estimated is 0.54 from cross validation.
tpredict.3    <- predict(modelrpart.3$finalModel,type="class")
confusionMatrix(tpredict.3,training3$classe)

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
set.seed(1234)
modelRF.3 <- randomForest(classe ~ ., 
                          data=training3,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)

prediccionRF.3 <- predict(modelRF.3,newdata=trainOver)
confusionMatrix(prediccionOver,trainOver$type)
save(modelRF.3, file="models/randomForestForTraining3.RData")

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelRF.1 <- randomForest(classe ~ ., 
                          data=training1,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
save(modelRF.1, file="models/randomForestForTraining1.RData")

# Train First ModelmodelCompleto <- train(diagnosis~.,data=training,method="glm")
modelRF.2 <- randomForest(classe ~ ., 
                          data=training2,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
save(modelRF.2, file="models/randomForestForTraining2.RData")
