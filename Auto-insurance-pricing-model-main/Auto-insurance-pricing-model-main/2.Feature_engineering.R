# Load necessary libraries
library(data.table)
library(dplyr)
library(ggplot2)



# 1. Create age groups for CarAge
freq_data$CarAgeGroup <- cut(freq_data$CarAge, 
                             breaks = c(-Inf, 2, 5, 10, 15, Inf),
                             labels = c("0-2", "3-5", "6-10", "11-15", "15+"))

# 2. Create age groups for DriverAge
freq_data$DriverAgeGroup <- cut(freq_data$DriverAge, 
                                breaks = c(-Inf, 25, 35, 45, 55, 65, Inf),
                                labels = c("18-25", "26-35", "36-45", "46-55", "56-65", "65+"))

# 3. Bin the Density variable
freq_data$DensityGroup <- cut(freq_data$Density, 
                              breaks = quantile(freq_data$Density, probs = seq(0, 1, 0.25)),
                              labels = c("Low", "Medium-Low", "Medium-High", "High"),
                              include.lowest = TRUE)

# 4. Create interaction term between Power and Brand
freq_data$PowerBrand <- interaction(freq_data$Power, freq_data$Brand)

# 5. Create binary feature for high-risk regions
high_risk_regions <- c("Bretagne", "Limousin")  # Add more based on your analysis
freq_data$HighRiskRegion <- ifelse(freq_data$Region %in% high_risk_regions, 1, 0)

# 6. Create feature for policies with exposures close to 1
freq_data$FullYearExposure <- ifelse(freq_data$Exposure > 0.9, 1, 0)

# Function to print summary of new features
print_feature_summary <- function(data, feature) {
  cat("\nSummary of", feature, ":\n")
  print(table(data[[feature]]))
  cat("\nMean ClaimNb by", feature, ":\n")
  print(tapply(data$ClaimNb, data[[feature]], mean))
}

# Print summaries of new features
new_features <- c("CarAgeGroup", "DriverAgeGroup", "DensityGroup", "PowerBrand", "HighRiskRegion", "FullYearExposure")
lapply(new_features, function(feature) print_feature_summary(freq_data, feature))

# Visualize the effect of new features on claim frequency
plot_feature_effect <- function(data, feature) {
  ggplot(data, aes(x = !!sym(feature), y = ClaimNb)) +
    stat_summary(fun = mean, geom = "bar") +
    labs(title = paste("Average Claims by", feature), x = feature, y = "Average Claims") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# Create plots for each new feature
feature_plots <- lapply(new_features, function(feature) plot_feature_effect(freq_data, feature))

# Arrange and display plots
do.call(gridExtra::grid.arrange, c(feature_plots, ncol = 2))

# Save the updated dataset
fwrite(freq_data, "freq_data_engineered.csv")

# Print session info for reproducibility
sessionInfo()
