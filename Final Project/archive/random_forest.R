## Fits a random forest regression model
##
## formula - an object of class formula
## data - a data.frame or matrix
## n_trees - the number of regression trees to be sprouted
## mtry - total features to be used in each regression tree (page 592 ESL recommendation)

## library(rpart)

create_bootstrap_data <- function(data) {
  data <- as.data.frame(data)
  boot_index <- sample(x=nrow(data), replace=TRUE) 
  boot_data <- data[boot_index,]
  oob_data <- data[-boot_index,]
  return(list("boot_data"=boot_data, "oob_data"=oob_data))
}




##################################################################################

random_forest <- function(formula, data, n_trees=500, mtry=NULL) {
  
  # package to build regression tree
  if(!require(rpart)) library(rpart) else require(rpart)
  
  # number of variables to be selected in tree fitting
  mtry <- if(is.null(mtry)) max(floor(ncol(data)/3), 1) else mtry

  for (i in 1:n_trees) {

    
    
    
    
    
  }
  return(results)
}

rf_test <- random_forest(formula=median_house_value ~., data=housing)
tree_features <- get_rf_features(rf=rf_test)


get_pred <- function(rf_features, values = NULL) {
  tree_features <- list()
  for (i in 1:length(rf_features)) {
    tree_features[i] <- list("labels" = attr(rf_features[[i]]$tree$terms, which = "term.labels"))
  }
}


