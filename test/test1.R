# Basic test file. 
# This file must be used from runTest file.


# Test Function for getting index with an predicate of the columns. 
test_that("", {
  da <- data.frame(a=c(1,2,3,4,5,6,NA,NA,NA),b=c(1,2,3,4,5,6,7,8,NA))
  getIndexWithPred(da,is.na,2)
  expect_true( getIndexWithPred(da,is.na,2) == 1)
})

