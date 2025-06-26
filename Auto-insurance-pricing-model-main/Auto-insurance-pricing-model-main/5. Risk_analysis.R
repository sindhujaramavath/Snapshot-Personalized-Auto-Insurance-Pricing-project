# Load necessary libraries
library(data.table)
library(dplyr)

# Load the best frequency model and severity model
best_freq_model <- readRDS("best_frequency_model.rds")
severity_model <- readRDS("severity_model.rds")

# Load the full dataset
full_data <- fread("freq_data_engineered.csv")

# Function to calculate pure premium
calculate_pure_premium <- function(data, freq_model, sev_model) {
  freq_pred <- predict(freq_model, newdata = data, type = "response")
  sev_pred <- exp(predict(sev_model, newdata = data, type = "response"))
  pure_premium <- freq_pred * sev_pred
  return(pure_premium)
}

# Calculate pure premium for the full dataset
full_data$PurePremium <- calculate_pure_premium(full_data, best_freq_model, severity_model)

# Calculate baseline premium
baseline_premium <- mean(full_data$PurePremium)

# Print the baseline premium
print(paste("Baseline Premium:", baseline_premium))

# Print summary of PurePremium
print("Summary of PurePremium:")
print(summary(full_data$PurePremium))

# Analyze pure premium by risk factors
risk_factors <- c("CarAgeGroup", "DriverAgeGroup", "DensityGroup", "Power", "Brand", "Gas", "Region")
risk_analysis <- lapply(risk_factors, function(factor) {
  full_data %>%
    group_by(!!sym(factor)) %>%
    summarise(AvgPurePremium = mean(PurePremium),
              RelativeRisk = AvgPurePremium / mean(full_data$PurePremium))
})
names(risk_analysis) <- risk_factors

# Print risk analysis
print("Risk Factor Analysis:")
print(risk_analysis)

# Extract relative risk factors
rating_factors <- lapply(risk_analysis, function(x) setNames(x$RelativeRisk, x[[1]]))


# 1. Calculate baseline premium
baseline_premium <- mean(full_data$PurePremium)
print(paste("Baseline Premium:", baseline_premium))

# 2. Function to get relative risk for a given factor and value
get_relative_risk <- function(factor_name, value) {
  risk_factor <- risk_analysis[[factor_name]]
  if (is.null(risk_factor)) {
    warning(paste("Risk factor not found:", factor_name))
    return(1)
  }
  relative_risk <- risk_factor$RelativeRisk[risk_factor[[1]] == value]
  if (length(relative_risk) == 0) {
    warning(paste("Value not found for factor", factor_name, ":", value))
    return(1)
  }
  return(relative_risk)
}

# 3. Calculate individualized premium for each policy
full_data <- full_data %>%
  rowwise() %>%
  mutate(IndividualizedPremium = baseline_premium *
           get_relative_risk("CarAgeGroup", CarAgeGroup) *
           get_relative_risk("DriverAgeGroup", DriverAgeGroup) *
           get_relative_risk("DensityGroup", DensityGroup) *
           get_relative_risk("Power", Power) *
           get_relative_risk("Brand", Brand) *
           get_relative_risk("Gas", Gas) *
           get_relative_risk("Region", Region))



# 5. Summary statistics of final premiums
print("Summary of Final Premiums:")
print(summary(full_data$FinalPremium))

# 6. Compare average final premium to baseline premium
avg_final_premium <- mean(full_data$FinalPremium)
print(paste("Average Final Premium:", avg_final_premium))
print(paste("Ratio to Baseline Premium:", avg_final_premium / baseline_premium))

# 7. Distribution of final premiums
hist(full_data$FinalPremium, main="Distribution of Final Premiums", xlab="Premium", breaks=50)



# 9. Correlation between Pure Premium and Final Premium
correlation <- cor(full_data$PurePremium, full_data$FinalPremium)
print(paste("Correlation between Pure Premium and Final Premium:", correlation))

# 10. Save results
fwrite(full_data, "final_premiums.csv")






# Remove duplicate columns
cols_to_keep <- !duplicated(names(full_data))
full_data <- full_data[, ..cols_to_keep]

# Verify the changes
print(names(full_data))

# Create the plot
library(ggplot2)

# Create the improved plot
ggplot(full_data, aes(x = PurePremium, y = IndividualizedPremium)) +
  geom_point(alpha = 0.05) +  # Increased transparency
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  labs(title = "Risk-Adjusted Premium vs Pure Premium",
       x = "Pure Premium",
       y = "Risk-Adjusted Premium (Individualized)") +
  theme_minimal() +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +  # Adjust limits as needed
  scale_x_continuous(breaks = seq(0, 200, by = 50)) +
  scale_y_continuous(breaks = seq(0, 200, by = 50))

# Save the plot
ggsave("improved_risk_adjusted_vs_pure_premium.png", width = 10, height = 8)

# Print summary statistics for context
print(summary(full_data$PurePremium))
print(summary(full_data$IndividualizedPremium))


# Ensure we're working with a data.table
setDT(full_data)

# Add loading factor to create final premium
full_data[, FinalPremium := IndividualizedPremium * 1.2]

