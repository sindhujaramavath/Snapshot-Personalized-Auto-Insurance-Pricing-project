# Load required libraries
library(data.table)
library(dplyr)
library(ggplot2)
library(MASS)
library(pscl)
library(caret)

# Main debugging and plotting code
tryCatch({
  # 1. Load the original data
  cat("Loading data...\n")
  freq_data <- fread("freq_data_engineered.csv")
  cat("Data loaded. Number of rows:", nrow(freq_data), "\n")
  
  # Print first few rows to verify data structure
  cat("First few rows of data:\n")
  print(head(freq_data))
  
  # 2. Create train/test split
  set.seed(123)
  train_indices <- createDataPartition(freq_data$ClaimNb, p = 0.7, list = FALSE)
  train_data <- freq_data[train_indices]
  test_data <- freq_data[-train_indices]
  
  # Print data summaries
  cat("\nData summaries:\n")
  cat("Training set rows:", nrow(train_data), "\n")
  cat("Test set rows:", nrow(test_data), "\n")
  
  # 3. Create and execute Plot 1
  cat("\nCreating risk heatmap...\n")
  risk_summary <- freq_data %>%
    group_by(CarAgeGroup, DriverAgeGroup) %>%
    summarise(
      avg_claims = mean(ClaimNb),
      total_exposure = sum(Exposure),
      claim_rate = sum(ClaimNb) / sum(Exposure),
      .groups = 'drop'
    )
  
  print("Risk summary created. First few rows:")
  print(head(risk_summary))
  
  risk_heatmap <- ggplot(risk_summary, 
                         aes(x = CarAgeGroup, y = DriverAgeGroup, fill = claim_rate)) +
    geom_tile() +
    scale_fill_gradient2(
      low = "blue", 
      high = "red", 
      mid = "white",
      midpoint = median(risk_summary$claim_rate),
      name = "Claim Rate"
    ) +
    labs(
      title = "Risk Heat Map: Claim Rates by Age Groups",
      x = "Car Age Group",
      y = "Driver Age Group"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )
  
  cat("Saving risk heatmap...\n")
  ggsave("risk_heatmap.png", risk_heatmap, width = 12, height = 8, dpi = 300)
  cat("Risk heatmap saved.\n")
  
  # 4. Create and execute Plot 2
  cat("\nCreating risk analysis plot...\n")
  risk_metrics <- freq_data %>%
    group_by(DensityGroup) %>%
    summarise(
      avg_claims = mean(ClaimNb),
      total_policies = n(),
      claim_frequency = sum(ClaimNb) / n(),
      avg_exposure = mean(Exposure),
      risk_score = (claim_frequency * avg_exposure * 100),
      .groups = 'drop'
    ) %>%
    arrange(desc(risk_score))
  
  print("Risk metrics created. Results:")
  print(risk_metrics)
  
  risk_analysis <- ggplot(risk_metrics, 
                          aes(x = reorder(DensityGroup, risk_score), y = risk_score)) +
    geom_bar(stat = "identity", fill = "darkblue", alpha = 0.7) +
    geom_text(aes(label = sprintf("%.2f", risk_score)), 
              vjust = -0.5, 
              color = "black", 
              size = 3.5) +
    labs(
      title = "Risk Score Analysis by Population Density",
      subtitle = "Risk Score = (Claim Frequency × Average Exposure × 100)",
      x = "Density Group",
      y = "Risk Score"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold"),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  cat("Saving risk analysis plot...\n")
  ggsave("risk_analysis.png", risk_analysis, width = 12, height = 8, dpi = 300)
  cat("Risk analysis plot saved.\n")
  
  # 5. Display plots in R
  cat("\nDisplaying plots...\n")
  print(risk_heatmap)
  print(risk_analysis)
  
}, error = function(e) {
  cat("\nError occurred:", conditionMessage(e), "\n")
  cat("Debug information:\n")
  cat("Working directory:", getwd(), "\n")
  cat("Available objects:", ls(), "\n")
})