# 0. Objetives ------------------------------------------------------------
# Contruct a model with random Forest to predit test set.
# Note: For compile path of files are changed adding ../

# 1. Libraries ------------------------------------------------------------

require(caret)
require(ggplot2)
require(data.table)
require(testit)
require(rpart)
require(randomForest)
require(testit)
source("../functions/functions.R")

# 2. loading data  -------------------------------------------------------
data   <- read.csv("../data/pml-training.csv")

# 3. Cleaning data for training ----------------------------------------------

# Deleting data with high porcentage of NA or blank values.
data.clean      <- data       [, -getIndexWithPred(data,is.na,0)]
data.clean      <- data.clean [, -getIndexWithPred(data.clean,function(x) x=="",0)]
# Deleting X, user name a timeStamps variables
# Deleting open_window factor. It is not a variable factor in test data assigment.
data.clean      <- data.clean [,-c(1:6)]
assert("Less columns expected",ncol(data.clean )< ncol(data))

# Create partition and train and data 
inTrain   <- createDataPartition(data.clean$classe, p = 0.8,list=F)
training1 <- data.clean[ inTrain,]
testing1  <- data.clean[-inTrain,]
rm(data);rm(data.clean);

# 4. Training model ------------------------------------------------------
# Train Random Forest 
modelRF.1 <- randomForest(classe ~ ., 
                          data=training1,
                          mtry=3,
                          ntree=500, 
                          importance=TRUE, do.trace=50)
save(modelRF.1, file="models/randomForestForTraining1.RData")
modelRF.1

# 5. Check on testing set  ------------------------------------------------

# To check our estimations, we predict on test sample an calculate confussion Matrix
prediccionRF.1 <- predict(modelRF.1,newdata=testing1)
confusionMatrix(prediccionRF.1,testing1$classe)


# 6. Apply model to test assigment ----------------------------------------
# Function to write files of assigment
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("../solutions/problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}
# Load data for test assigment
test    <- read.csv("../data/pml-testing.csv")
# Now take the same variables in test set that those ones used in training set.
# classe column is not in test set, so we don't include it.
test        <- test[,names(training1[,-c(ncol(training1))])]

predictions <- predict(modelRF.1, newdata=test)

# write data into files
pml_write_files(predictions)
