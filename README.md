# Snapshot-Personalized-Auto-Insurance-Pricing-project
# 🚗 Snapshot® Personalized Auto Insurance Pricing (ML Project)

This project uses telematics data from Progressive's Snapshot® program to build a dynamic pricing engine using ML.

## 🔍 Objective
- Predict fair insurance premiums based on driving behavior
- Improve retention and risk segmentation using real-time data

## 🧠 Technologies
- Python, Pandas, XGBoost
- Jupyter Notebook, Matplotlib, Seaborn
- Scikit-learn for preprocessing
- Joblib for model saving

## 📈 Features Used
- `average_braking_intensity`
- `percentage_night_driving`
- `days_with_no_risky_behavior`
- `phone_use_rate`
- `distance_travelled`, `trip_frequency`, etc.

## 📊 Model Performance
- MAE: ~$11.50
- R² Score: ~0.89

## 🗂️ Folder Structure
snapshot-pricing-ml/
├── data/ (telematics data)
├── src/ (training pipeline)
├── notebooks/ (EDA)

bash
Copy
Edit

## ⚙️ How to Run
```bash
pip install -r requirements.txt
python src/snapshot_pricing_model.py
yaml
Copy
Edit

---

### 📦 `requirements.txt`

```txt
pandas
numpy
matplotlib
seaborn
scikit-learn
xgboost
joblib
jupyter
📊 Sample Data (in data/snapshot_sample.csv)
Make sure your sample file contains columns like:

csv
Copy
Edit
average_braking_intensity,percentage_night_driving,phone_use_rate,days_with_no_risky_behavior,premium_amount
0.8,35,0.05,12,120
1.2,45,0.12,6,180
...
