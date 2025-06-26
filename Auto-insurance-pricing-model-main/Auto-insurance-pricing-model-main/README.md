# Auto Insurance Pricing Model
This project develops a sophisticated pricing model for auto insurance using statistical and machine learning techniques. It includes exploratory data analysis, feature engineering, frequency and severity modeling, and risk-adjusted premium calculation.

## Key Features
- Exploratory Data Analysis (EDA) of claim frequency and severity
- Advanced feature engineering to create novel risk factors
- Frequency modeling using Poisson, Negative Binomial, and Zero-Inflated Poisson models
- Severity modeling using log-normal regression
- Risk-adjusted premium calculation system
- Visualization of pricing impacts and risk factor analysis

## Technologies Used
- R
- Libraries: data.table, dplyr, ggplot2, MASS, pscl, caret

## Project Structure
1. EDA.R: Exploratory Data Analysis
2. Feature_engineering.R: Creation of new risk factors
3. Frequency_model.R: Claim frequency modeling
4. Severity_model.R: Claim severity modeling
5. Risk_analysis.R: Risk factor analysis and premium calculation

## Risk Analysis Visualizations

### Feature Engineering Impact Analysis
![Feature Engineering Analysis](feature_engineering.png)

This visualization demonstrates the relationship between different risk factors and claim frequency. Key insights:
- Cars aged 6-10 years show the highest claim frequency
- Young drivers (18-25) have significantly higher claim rates
- Higher population density correlates with increased claim frequency
- Full year policies show different risk patterns compared to partial year coverage

### Risk Heat Map Analysis
![image](https://github.com/user-attachments/assets/074adc93-dbd3-477d-be35-d67b55b8f99d)


The heat map reveals the interaction between driver age and vehicle age groups:
- Highest risk concentration (red) appears in young drivers (18-25) with vehicles aged 6-10 years
- More experienced drivers (45+) with newer vehicles show lower claim rates (blue)
- Clear pattern of risk reduction as driver age increases
- Vehicle age has a non-linear impact on risk across different driver age groups

### Population Density Risk Analysis
![image](https://github.com/user-attachments/assets/c34e414b-7228-4600-a432-9cb20197f395)


Analysis of risk patterns across population density groups shows:
- Medium-High density areas have the highest risk score (2.45)
- Clear correlation between population density and risk
- Risk scores range from 1.80 to 2.45, showing significant variation
- The relationship is not perfectly linear, suggesting other factors influence risk in urban vs. rural areas

## Results
- 15% improvement in premium accuracy compared to baseline model
- Increase in model predictive power through novel risk factors


## Future Work
- Implement Generalized Additive Models (GAMs) for non-linear relationships
- Explore machine learning approaches like Random Forests or Gradient Boosting Machines
- Conduct competitive analysis and market basket analysis
