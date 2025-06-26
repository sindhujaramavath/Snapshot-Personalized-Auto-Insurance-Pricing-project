# Load necessary libraries
library(data.table)
library(dplyr)
library(caret)


# Merge severity data with frequency data to get all predictors
sev_data <- merge(sev_data, freq_data[, .(PolicyID, CarAgeGroup, DriverAgeGroup, DensityGroup, Power, Brand, Gas, Region)], by = "PolicyID")

# Split the data into training and testing sets
set.seed(123)
train_indices <- createDataPartition(sev_data$ClaimAmount, p = 0.7, list = FALSE)
train_data <- sev_data[train_indices]
test_data <- sev_data[-train_indices]

# Log-normal model
lognormal_model <- glm(log(ClaimAmount) ~ CarAgeGroup + DriverAgeGroup + DensityGroup + 
                         Power + Brand + Gas + Region,
                       family = gaussian(), data = train_data)

summary(lognormal_model)

# Predict on test set
predictions <- exp(predict(lognormal_model, newdata = test_data, type = "response"))

# Evaluate model performance
mse <- mean((test_data$ClaimAmount - predictions)^2)
rmse <- sqrt(mse)
mae <- mean(abs(test_data$ClaimAmount - predictions))

print(paste("MSE:", mse))
print(paste("RMSE:", rmse))
print(paste("MAE:", mae))

# Save the model
saveRDS(lognormal_model, "severity_model.rds")
