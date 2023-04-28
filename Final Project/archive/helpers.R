## create a bootstrap sample
create_bootstrap_data <- function(x) {
  x <- as.data.frame(x)
  boot_index <- sample(x=nrow(x), replace=TRUE) 
  boot_data <- x[boot_index,]
  oob_data <- x[-boot_index,]
  return(list("boot_data"=boot_data, "oob_data"=oob_data))
}

## sample random subset of features
sample_features <- function(data, target_name, mtry=max(floor(ncol(data)/3), 1)) {
  x <- data[!names(data) %in% target_name]
  x <- data[sample(names(x), mtry)]
  return(cbind(x, data[target_name]))
}

## fit regression tree using rpart
tree_fit <- function(formula, data){
  rpart(formula=formula, data=data)
}

## get regression tree predictions
tree_pred <- function(x, newdata) {
  pred <- predict(x, newdata=newdata)
  return(pred)
}

n_trees <- 500

# set up list to hold trees
tree_data <- vector(mode = "list", length = n_trees)

# bootstrap n_tree models
for(i in 1:n_trees) tree_data[[i]] <- sample_features(create_bootstrap_data(housing)$boot_data, target_name="median_house_value")
rf_model <- lapply(tree_data, tree_fit, formula = median_house_value ~ .)

rf_avg <- do.call(rbind, lapply(tree_fit, tree_pred, create_bootstrap_data(housing)$oob_data))

## grow a tree using bootstrapped data
grow_tree <- function(formula, data, mtry) {
  
  # get the target variable
  target_name <- all.vars(formula)[1]
  
  # split data
  boot_data <- bootstrap_data(data)
  train_data <- boot_data$train_data
  oob_data <- boot_data$oob_data

  # not correct
  train_names <- names(train_data[, !names(train_data) %in% target_name])
  sample_names <- sample(x=train_names, size=mtry, replace=FALSE)
  
  # create new formula with subset of features
  formula_new <- as.formula(paste0(target_name, " ~ ", paste0(sample_names, collapse=" + ")))
  
  # fit a regression tree with subset of features - minsplit is 5 to match randomForest settings
  tree <- rpart(formula=formula_new, data=train_data, control=c(minsplit=5L))

  
  # get oob error
  tree_pred <- predict(tree, newdata=oob_data)
  tree_rsme <- sqrt(sum((oob_data[,target_name] - tree_pred)^2)/dim(oob_data)[1])

  return(list("tree"=tree, "oob_pred"=tree_pred, "oob_rmse"=tree_rsme, "train_data"=train_data, "oob_data"=oob_data))
}
