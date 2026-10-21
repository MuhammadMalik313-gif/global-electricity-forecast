# Global Electricity Outlook 2025-2034

End-to-end forecasting project on World Bank data: **SQL, Pandas, time-series backtesting and a Power BI dashboard**. It estimates how much electricity each country may generate over the next 10 years, linked to SDG-7 (Affordable and Clean Energy).

> All forecasts are model-projected estimates based on trend extrapolation, not guaranteed predictions.

---

## 1. Problem

How will electricity generation change by country as population and income grow, and how reliable can such a forecast be with the available data?

## 2. Data

- **Source:** "Global Electricity Access & Economic Indicators" (World Bank indicators, Kaggle).
- **Raw file:** 7,381 rows, 9 columns, years 2000-2024.
- **Columns:** country, year, GDP per capita, total population, female/male %, urban/rural electricity access %, total electricity output (GWh).
- **Key constraint:** electricity output exists only for **2000-2015**. Population and GDP run to 2024.

## 3. Pipeline

| Stage | Tool | What was done |
|---|---|---|
| Exploration | SQL | Country-wise comparisons, totals, averages and derived columns on the imported table |
| Cleaning | Pandas | Removed regional/income aggregates (World, High income, etc.), merged duplicate country names (e.g. Turkey/Turkiye), dropped territories with no population data |
| EDA | Pandas | Correlation on log scale, skewness check, year-wise data availability |
| Modeling | scikit-learn | Growth-based linear regression with time-based validation |
| Forecast | Python | 2025-2034 projection per country |
| Dashboard | Power BI | Actual vs forecast charts, country slicer, growth and kWh-per-person measures |

### Data quality issues found and fixed
- Regional aggregates mixed with countries caused double counting and extreme outliers.
- The same country appeared under two names, splitting its data.
- An early mean-imputation attempt put fake values into the target column. It was caught (one value repeated in 3,706 rows) and the work restarted from the raw file. The target column is never imputed.

**Result after cleaning:** 216 countries; 3,277 usable rows (2000-2015) with output, population and GDP all present.

## 4. Method

**Log-scale features.** Population, GDP per capita and electricity output vary by orders of magnitude, so all are modeled in logs.

**Time-based split.** Train on 2000-2011, test on 2012-2015 (no random split, which would leak the future).

**Baseline first.** A naive model (carry each country's 2011 value forward) is the benchmark.

**Why plain regression failed.** Regressing the electricity *level* on population, GDP and year lost to the naive baseline (Model A: 92% MAPE; with country effects: 26% MAPE vs naive 11.5%).

**Reformulation: predict growth, not level.** Start from the last known value and predict the change in log output from the change in log population and log GDP over the horizon:

`Δlog(electricity) = b0·h + b1·Δlog(population) + b2·Δlog(GDP per capita)`

**Country drift.** Each country's growth not explained by the model is its "drift". A fraction `lam` of it is carried forward. `lam` was chosen by backtest, not guessed.

## 5. Results

### Backtest (train 2000-2011, test 2012-2015)

| Model | MAPE |
|---|---|
| Naive (2011 carried forward) | 11.50% |
| Growth model (`lam = 0`) | 10.07% |
| **Growth model + drift (`lam = 0.25`)** | **9.90%** |
| `lam = 0.50` | 10.00% |
| `lam = 0.75` | 10.38% |
| `lam = 1.00` | 11.01% |

The growth model beats the naive baseline; a small share of country drift helps slightly, while full drift hurts. The improvement is modest (11.5% to 9.9%) and is reported as such.

### Learned relationship (full data)
- Population coefficient ≈ **1.16**: a 1% population increase goes with roughly 1.16% more electricity.
- GDP per capita coefficient ≈ **0.085**: a weak effect.
- Time coefficient ≈ **0.012**: about 1.2% yearly growth beyond population and GDP.

### Forecast (2025-2034, 208 countries)
Example, 2034: India ≈ 2.47 million GWh and Pakistan ≈ 0.17 million GWh.

## 6. Dashboard (Power BI)

- Actual vs forecast charts for electricity and population, with a country slicer.
- DAX measures: electricity growth, population growth (2015 to 2034) and kWh per person.
- The 2015-2025 gap in the charts is intentional: no electricity data exists after 2015.

## 7. Limitations

- **Long extrapolation.** The last electricity observation is 2015, so a 2034 forecast reaches 19 years beyond the data, while the backtest covers only 1-4 years. Real error at this horizon will be larger than 10%.
- **Population is a simple trend.** Future population comes from a log-linear fit on 2015-2024, not from UN projections. Some small countries (e.g. Albania, American Samoa) show falling population because of recent emigration trends continuing.
- **GDP assumption.** GDP growth was capped at 0-5% per year. Its model effect is small, so results are driven mostly by population.
- **Growth boom bias.** Drift is learned from 2000-2015, a period of rapid growth in several countries, and was capped at ±5% per year and weighted at 25%.
- **MAPE weighs all countries equally,** so a small island counts as much as China.
- **Coverage.** Territories without population data (e.g. Taiwan) are excluded from the model.
- **Not causal.** The model describes association between growth in population, GDP and electricity, not cause and effect.

## 8. Next steps

- Replace the population trend with UN World Population Prospects projections.
- Add prediction intervals to the forecast.
- Time-series cross-validation instead of a single split.
- Compare against tree-based models inside the training range.
- Add classification (countries by electricity access level) and K-Means clustering of similar countries.

## 9. Repository contents

```
global-electricity-forecast/
├── electricity_forecasting.ipynb   # cleaning, backtest, model, forecast
├── powerbi_final.csv               # actual + forecast table used by Power BI
├── dashboard.pbix                  # Power BI report
├── screenshots/                    # dashboard images
└── README.md
```

## 10. Tech stack

Python (Pandas, NumPy, scikit-learn), SQL, Power BI (DAX).
