import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix
import time
import pickle

adults_training = pd.read_csv("./data/adults_training.csv")
adults_testing  = pd.read_csv("./data/adults_testing.csv")

adults_train = adults_training.drop('isGT50K', axis=1)  # input features
adults_train = pd.get_dummies(adults_train)
y_train = adults_training['isGT50K']  # target variable
adults_test =  adults_testing.drop('isGT50K', axis=1)  # input features
adults_test = pd.get_dummies(adults_test)
y_test =  adults_testing['isGT50K']  # target variable

# for later
adults_train.to_csv("adults_training_dummies.csv")
adults_test.to_csv("adults_testing_dummies.csv")

# fit random forest
rf_classification = RandomForestClassifier(max_features=3, random_state=1)
rf_classification.fit(adults_train, y_train)
pickle.dump(rf_classification, open("python_classification.pkl", "wb"), protocol = 2)

# get predicted values
y_pred = rf_classification.predict(adults_test)

# get accuracy
accuracy = accuracy_score(y_test, y_pred)
print("Accuracy:", accuracy) # Accuracy: 0.8522978836447357
print(confusion_matrix(y_pred, y_test))

# evalute the speed of code
times_classification = []

for i in range(25):
  start_classification = time.time()
  rf_classification.fit(adults_train, y_train)
  end_classification = time.time()
  times_classification.append(end_classification - start_classification)
  
python_classification_times = pd.DataFrame(times_classification)
python_classification_times.to_csv("./metrics/python_classification_times.csv")

