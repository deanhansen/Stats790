# Fits a random forest regression model
#
# formula - an object of class formula
# data - a data.frame or matrix
# n_trees - the number of regression trees to be sprouted
# mtry - total features to be used in each regression tree (page 592 ESL recommendation)

library(rpart)

random_forest <- function(formula, data, n_trees=500, mtry=NULL) {
  
  # package to build regression tree
  if(!require(rpart)) library(rpart) else require(rpart)
  
  # number of variables to be selected in tree fitting
  mtry <- if(is.null(mtry)) max(floor(ncol(data)/3), 1) else mtry
  
  # create empty list
  results <- list()
  
  for (i in 1:n_trees) {
    tree <- grow_tree(formula=formula, data=housing, mtry=mtry)
    results[[i]] <- list("tree_id"=i, "tree"=tree$tree, "train_data"=tree$train_data, "oob_data"=tree$oob_data, "oob_rmse"=tree$tree_rsme)
  }
  return(results)
}

rf_test <- random_forest(formula=median_house_value ~., data=housing)
