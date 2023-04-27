# Fits a random forest regression model
#
# formula - an object of class formula
# data - a data.frame or matrix
# n_trees - the number of regression trees to be sprouted
# mtry - total features to be used in each regression tree (page 592 ESL recommendation)

# library(rpart) - requires installation of rpart

random_forest <- function(formula, data, n_trees=500, mtry=NULL) {
  
  # package to build regression tree
  require(rpart)
  
  # number of variables to be selected in tree fitting
  mtry <- if(is.null(mtry)) max(floor(ncol(data)/3), 1) else mtry
}
