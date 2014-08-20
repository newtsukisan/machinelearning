machinelearning
===============

Machine Learning of Coursera.

This repository is dedicated to assigment of:

https://class.coursera.org/predmachlearn-004.

1. Background:

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about 
personal activity relatively inexpensively. These type of devices are part of the quantified self movement –
a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns 
in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a 
particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use 
data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell 
lifts correctly and incorrectly in 5 different ways. 
More information is available from the website here: http://groupware.les.inf.puc-rio.br/har 
(see the section on the Weight Lifting Exercise Dataset).

2. Data 


The training data for this project are available here: 

https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv

The test data are available here: 

https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv

The data for this project come from this source: http://groupware.les.inf.puc-rio.br/har. If you use the document you create for this class for any purpose please cite them as they have been very generous in allowing their data to be used for this kind of assignment.

3. Objetive of assigment.

The goal of your project is to predict the manner in which they did the exercise. This is the "classe" variable in the training set. You may use any of the other variables to predict with. You should create a report describing how you built your model, how you used cross validation, what you think the expected out of sample error is, and why you made the choices you did. You will also use your prediction model to predict 20 different test cases.

4. Structure of repository.

There are three directories.

cleancode	-> Contains:
              Exploratory.R     -> to compile html file showing all process.
              Exploratory.html  -> file showing all process.
              Solution.R        -> script used to find and save models.
              SolutionFinal.R   -> script used to calculate final model and apply it to data.
functions	-> Contains:
              functions.R       -> script with some functions used in the analisys.
test      -> Contains:
              runTest.R	        -> script to run simple test using testthat library.
              test1.R           -> script with test.
              
5. Process.

The proccess is showed in Exploratory.html. After an exploratory analisys is found that some variables have few information. So we consider several hypothesis:
Hipothesis 1. Predictors with high number of NA have no information for training model.
Hipothesis 2. Predictors with high number of empty values have no information for training model.

Colunms 1 to 6 are not considered for training purposes. 

After that three differents groups are formed. 
Group 1 for training. All data cleaned. tidy1

Group 2 for training. Subtitue 6 high correlated predictor with PCA equivalents containing 80 % of variance.

Group 3 for training. Substitue all numeric predictors with PCA equivalents containing 80 % of variance.

Lastly, two kind of models are used. Trees and random Forest. Trees have high error level even in training sets, random Forest have better performance. Definitive model is selected from random Forest with low OOB error. OOB is considered as an estimation of Error out of sample. Definitive model is used on test set to estimate Error out of Sample again, and is similar to OOB estimated. 

6. When we have found a valid model, we apply it to predict test data of assigment. In SolutionFinal.R is reflected this complete proccess.