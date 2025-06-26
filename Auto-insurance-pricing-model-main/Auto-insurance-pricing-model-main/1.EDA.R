# Load necessary libraries
library(data.table)
library(dplyr)
library(ggplot2)

# Read the CSV files using fread for faster processing
freq_data <- fread("C:/pricing new proj/freMTPLfreq.csv")
sev_data <- fread("C:/pricing new proj/freMTPLsev.csv")

# Function to print basic information about a dataset
print_dataset_info <- function(data, name) {
  cat("\nDataset:", name, "\n")
  cat("Dimensions:", dim(data)[1], "rows,", dim(data)[2], "columns\n")
  cat("Column names:", paste(names(data), collapse = ", "), "\n")
  cat("First few rows:\n")
  print(head(data))
  cat("\nSummary statistics:\n")
  print(summary(data))
}

# Analyze frequency data
print_dataset_info(freq_data, "Frequency Data")

# Analyze severity data
print_dataset_info(sev_data, "Severity Data")

# Check for missing values
cat("\nMissing values in Frequency Data:\n")
print(colSums(is.na(freq_data)))

cat("\nMissing values in Severity Data:\n")
print(colSums(is.na(sev_data)))

# Basic visualizations
# Histogram of ClaimNb for Frequency Data
ggplot(freq_data, aes(x = ClaimNb)) +
  geom_histogram(binwidth = 1, fill = "blue", alpha = 0.7) +
  labs(title = "Distribution of Claim Numbers", x = "Number of Claims", y = "Count")

# Boxplot of ClaimAmount for Severity Data
ggplot(sev_data, aes(y = ClaimAmount)) +
  geom_boxplot(fill = "red", alpha = 0.7) +
  labs(title = "Distribution of Claim Amounts", y = "Claim Amount")

# Save plots
ggsave("claim_numbers_histogram.png", width = 8, height = 6)
ggsave("claim_amounts_boxplot.png", width = 8, height = 6)

# Print session info for reproducibility
sessionInfo()




# Load necessary libraries
library(data.table)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(corrplot)
library(MASS)


# 1. Explore Claim Severity Distribution
# Log-transform claim amounts
sev_data$log_ClaimAmount <- log(sev_data$ClaimAmount)

p1 <- ggplot(sev_data, aes(x = ClaimAmount)) +
  geom_histogram(bins = 50, fill = "blue", alpha = 0.7) +
  scale_x_log10() +
  labs(title = "Distribution of Claim Amounts\n(Log Scale)", x = "Claim Amount", y = "Count")

p2 <- ggplot(sev_data, aes(x = log_ClaimAmount)) +
  geom_histogram(bins = 50, fill = "red", alpha = 0.7) +
  labs(title = "Distribution of Log-Transformed\nClaim Amounts", x = "Log(Claim Amount)", y = "Count")

grid.arrange(p1, p2, ncol = 2)

summary(sev_data$ClaimAmount)



# Remove zeros and very small values
sev_data_filtered <- sev_data[sev_data$ClaimAmount > 1, ]

# Try fitting the gamma distribution again
fit_gamma <- try(fitdistr(sev_data_filtered$ClaimAmount, "gamma"))

if(class(fit_gamma) != "try-error") {
  print(fit_gamma)
} else {
  print("Gamma distribution fitting failed. Consider using another distribution.")
}

top_claims <- sev_data %>%
  count(ClaimAmount) %>%
  arrange(desc(n)) %>%
  head(10)

print(top_claims)

# Fit distributions
fit_lnorm <- fitdistr(sev_data$ClaimAmount, "lognormal")
print(fit_lnorm)

# Plot histogram with fitted log-normal distribution
ggplot(sev_data, aes(x = ClaimAmount)) +
  geom_histogram(aes(y = ..density..), bins = 50, fill = "blue", alpha = 0.7) +
  scale_x_log10() +
  stat_function(fun = dlnorm, args = list(meanlog = fit_lnorm$estimate[1], sdlog = fit_lnorm$estimate[2]), color = "red", size = 1) +
  labs(title = "Claim Amount Distribution with Fitted Log-Normal", x = "Claim Amount (log scale)", y = "Density")

severity_model <- glm(ClaimAmount ~ ., data = sev_data, family = gaussian(link = "log"))
summary(severity_model)

# Compare AIC
# AIC for log-normal
aic_lnorm <- -2 * fit_lnorm$loglik + 2 * length(fit_lnorm$estimate)



print(paste("AIC for Log-normal:", aic_lnorm))


# 2. Analyze Categorical Variables
# Function to plot claim frequency by category
plot_freq_by_category <- function(data, cat_var) {
  data %>%
    group_by(!!sym(cat_var)) %>%
    summarise(avg_claims = mean(ClaimNb)) %>%
    ggplot(aes(x = reorder(!!sym(cat_var), -avg_claims), y = avg_claims)) +
    geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = paste("Average Claims by", cat_var), x = cat_var, y = "Average Claims")
}

# Plot for each categorical variable
cat_vars <- c("Power", "Brand", "Gas", "Region")
cat_plots <- lapply(cat_vars, function(var) plot_freq_by_category(freq_data, var))
do.call(grid.arrange, c(cat_plots, ncol = 2))

# 3. Continuous Variables Analysis
# Function to plot boxplots for continuous variables
plot_boxplot <- function(data, cont_var) {
  ggplot(data, aes(x = cut_number(!!sym(cont_var), n = 10), y = ClaimNb)) +
    geom_boxplot() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = paste("Claims by", cont_var), x = cont_var, y = "Number of Claims")
}

# Plot for each continuous variable
cont_vars <- c("CarAge", "DriverAge", "Density")
cont_plots <- lapply(cont_vars, function(var) plot_boxplot(freq_data, var))
do.call(grid.arrange, c(cont_plots, ncol = 2))

# 4. Exposure Analysis
# Plot claim frequency vs exposure
ggplot(freq_data, aes(x = Exposure, y = ClaimNb)) +
  geom_point(alpha = 0.1) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Claim Frequency vs Exposure", x = "Exposure", y = "Number of Claims")

# Create log(Exposure) for modeling
freq_data$log_Exposure <- log(freq_data$Exposure)



3# Save plots
ggsave("claim_severity_distribution.png", plot = grid.arrange(p1, p2, ncol = 2), width = 12, height = 6)
ggsave("categorical_variables_analysis.png", plot = do.call(grid.arrange, c(cat_plots, ncol = 2)), width = 12, height = 10)
ggsave("continuous_variables_analysis.png", plot = do.call(grid.arrange, c(cont_plots, ncol = 2)), width = 12, height = 10)
ggsave("exposure_analysis.png", width = 8, height = 6)
