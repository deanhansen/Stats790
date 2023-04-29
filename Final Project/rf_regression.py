import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
import time
import pickle

housing_training = pd.read_csv("./data/housing_training.csv")
housing_testing  = pd.read_csv("./data/housing_testing.csv")

housing_train = housing_training.drop('median_house_value', axis=1)  # input features
y_train = housing_training['median_house_value']  # target variable
housing_test =  housing_testing.drop('median_house_value', axis=1)  # input features
y_test =  housing_testing['median_house_value']  # target variable

# using default parameters
# rf_regression = RandomForestRegressor(max_features=3, random_state=1)
rf_regression = RandomForestRegressor(max_features=3)
rf_regression.fit(housing_train, y_train)
pickle.dump(rf_regression, open("python_regression.pkl", "wb"), protocol = 2)

# get predictions
y_pred = rf_regression.predict(housing_test)

# get rmse
mse = mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)
print("RMSE:", rmse) # RMSE: 49397.928321747604

# evalute the speed of code
times_regression = []

for i in range(25):
  start_regression = time.time()
  rf_regression.fit(housing_train, y_train)
  end_regression = time.time()
  times_regression.append(end_regression - start_regression)

python_regression_times = pd.DataFrame(times_regression)
python_regression_times.to_csv("./metrics/python_regression_times.csv")
