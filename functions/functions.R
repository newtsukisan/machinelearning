# simple function for obtaining  index of columns which have certain number of cases
# data.frame, (function (x) -> Boolean), integer -> list of integer
# data      -> data frame where we are looking for
# predicado -> function to be apply in each column of data frame
# cutoff    -> value of cut 
getIndexWithPred  <- function(data,predicado,cutoff){
  which (apply(data, 2, function(x) sum(predicado(x))) > cutoff)
}

# some simple functions for obtaining data from matrix
columnOf <- function(i,size) (i-1) %%  size + 1
rowOf    <- function(i,size) (i-1) %/% size + 1  