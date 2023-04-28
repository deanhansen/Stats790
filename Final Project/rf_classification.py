import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

adults_training = pd.read_csv("./data/adults_training.csv")
adults_testing  = pd.read_csv("./data/adults_testing.csv")
cols = ["workclass", "education", "marital_status", "occupation", "relationship", "race", "sex", "native_country"]  

adults_train = adults_training.drop('isGT50K', axis=1)  # input features
adults_train = pd.get_dummies(adults_train)
y_train = adults_training['isGT50K']  # target variable
adults_test =  adults_testing.drop('isGT50K', axis=1)  # input features
adults_test = pd.get_dummies(adults_test)
y_test =  adults_testing['isGT50K']  # target variable

# Define the random forest model
rf_classification = RandomForestClassifier(max_features=3, random_state=1)
rf_classification.fit(adults_train, y_train)

# Make predictions on the test data using the best model
y_pred = rf_classification.predict(adults_test)

# Evaluate the performance of the model
accuracy = accuracy_score(y_test, y_pred)
print("Accuracy:", accuracy) # Accuracy: 0.8522978836447357
print(confusion_matrix(y_pred, y_test))
