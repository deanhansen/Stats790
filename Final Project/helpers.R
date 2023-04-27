## create a bootstrap sample
bootstrap_data <- function(data) {
  data <- as.data.frame(data)
  boot_index <- sample(x=nrow(data), replace=TRUE) 
  train_data <- data[boot_index,]
  oob_data <- data[-boot_index,]
  return(list("train_data"=train_data, "oob_data"=oob_data))
}

## grow a tree using bootstrapped data
grow_tree <- function(formula, data, mtry) {
  
  # get the target variable
  target_name <- all.vars(formula)[1]
  
  # split data
  boot_data <- bootstrap_data(data)
  train_data <- boot_data$train_data
  oob_data <- boot_data$oob_data

  # get subset of names
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





# y <- housing$median_house_value
# var_y <- var(y) * (length(y)-1)
# split_points <- sort(unique(housing$population))
# 
# unique_sort <- function(x){
#   lapply(lapply(x, unique), sort)
# }
# 
# split_points <- unique_sort(housing)
# len <- lapply(split_points, length)
# x <- data.frame(variable=NULL, split=NULL, s=NULL)
# 
# sum(housing[housing$median_income <= split_points[i],]$median_house_value - mean(housing[housing$median_income <= split_points[i],]$median_house_value))^2 + sum(housing[housing$median_income < split_points[i],]$median_house_value - mean(housing[housing$median_income < split_points[i],]$median_house_value))^2
# 
# t <- data.frame(split_points, s)
# t[which.min(t),]


