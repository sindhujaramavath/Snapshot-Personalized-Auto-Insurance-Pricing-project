# Load necessary libraries
library(data.table)
library(dplyr)
library(MASS)
library(pscl)
library(caret)

# Load the data (assuming it's in your working directory)
freq_data <- fread("freq_data_engineered.csv")

# Split the data into training and testing sets
set.seed(123)
train_indices <- createDataPartition(freq_data$ClaimNb, p = 0.7, list = FALSE)
train_data <- freq_data[train_indices]
test_data <- freq_data[-train_indices]

# Poisson GLM
poisson_model <- glm(ClaimNb ~ offset(log(Exposure)) + CarAgeGroup + DriverAgeGroup + 
                       DensityGroup + Power + Brand + Gas + Region,
                     family = poisson(), data = train_data)

summary(poisson_model)

# Check for overdispersion
dispersion_test <- sum(residuals(poisson_model, type = "pearson")^2) / poisson_model$df.residual
print(paste("Dispersion parameter:", dispersion_test))

# Negative Binomial GLM
nb_model <- glm.nb(ClaimNb ~ offset(log(Exposure)) + CarAgeGroup + DriverAgeGroup + 
                     DensityGroup + Power + Brand + Gas + Region,
                   data = train_data)

summary(nb_model)

# Zero-Inflated Poisson model
zip_model <- zeroinfl(ClaimNb ~ offset(log(Exposure)) + CarAgeGroup + DriverAgeGroup + 
                        DensityGroup + Power + Brand + Gas + Region | 
                        DriverAgeGroup + DensityGroup,
                      data = train_data)

summary(zip_model)

# Compare models using AIC
aic_poisson <- AIC(poisson_model)
aic_nb <- AIC(nb_model)
aic_zip <- AIC(zip_model)

print(data.frame(Model = c("Poisson", "Negative Binomial", "Zero-Inflated Poisson"),
                 AIC = c(aic_poisson, aic_nb, aic_zip)))

# Select the best model based on AIC
best_model <- list(poisson_model, nb_model, zip_model)[[which.min(c(aic_poisson, aic_nb, aic_zip))]]

# Predict on test set
predictions <- predict(best_model, newdata = test_data, type = "response")

# Evaluate model performance
mse <- mean((test_data$ClaimNb - predictions)^2)
rmse <- sqrt(mse)
mae <- mean(abs(test_data$ClaimNb - predictions))

print(paste("MSE:", mse))
print(paste("RMSE:", rmse))
print(paste("MAE:", mae))

# Save the best model
saveRDS(best_model, "best_frequency_model.rds")
