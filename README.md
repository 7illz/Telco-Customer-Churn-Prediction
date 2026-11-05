# Telco Customer Churn Analysis

An end-to-end customer churn portfolio project combining an interactive Power BI dashboard,
data-quality controls, and a Python machine-learning notebook. The project analyzes 7,043
telecommunications customers to identify high-risk segments, quantify monthly revenue at
risk, and translate the findings into practical retention actions.

[View the exported dashboard (PDF)](deliverables/Telco%20Churn%20Dashboard.pdf)

![Telco Customer Churn dashboard](deliverables/dashboard-overview.png)

## Business objective

Customer churn directly affects recurring revenue and acquisition costs. This project helps a
manager answer four questions:

- How many customers are leaving, and how much monthly revenue is at risk?
- Which contract, tenure, payment, and service segments have the highest churn rates?
- Where should retention activity be prioritized?
- Can the underlying data be trusted for decision-making?

## Key results

| Finding | Result | Business interpretation |
| --- | ---: | --- |
| Overall churn | 26.5% (1,869 of 7,043 customers) | More than one in four customers in the dataset churned. |
| Monthly revenue at risk | $139,130.85 | This is the sum of monthly charges for churned customers, not an annual forecast. |
| Month-to-month churn | 42.7% | Contract flexibility is strongly associated with higher churn. |
| First-year churn | 47.4% for 0-12 months tenure | The earliest stage of the customer lifecycle is the highest-risk period. |
| Electronic-check churn | 45.3% | This payment segment has the highest observed churn rate. |
| Fiber-optic churn | 41.9% | Fiber-optic customers show the highest churn among internet-service groups. |

These are descriptive associations within this dataset. They do not establish causation.

## Dashboard design

### 1. Churn Overview

The management page includes:

- KPI cards for total customers, churn rate, monthly revenue at risk, and average tenure
- churn rate by contract type and tenure band
- churn analysis by internet service and payment method
- customer-segment comparisons for senior citizens, partners, and dependents
- monthly charges versus tenure scatter plot, colored by churn status
- slicers for contract, internet service, tenure band, and senior-citizen status
- tooltips showing the customer and churn counts behind each rate

### 2. Data Quality

The validation page checks row counts, required fields, duplicate customer IDs, and the
`TotalCharges` correction. All documented checks currently return `PASS`.

![Data Quality dashboard](deliverables/data-quality.png)

## Data preparation

Power Query performs the following transformations:

1. Assigns appropriate text, whole-number, decimal, and currency data types.
2. Converts the 11 blank `TotalCharges` values to zero only where `tenure = 0`.
3. Converts `SeniorCitizen` from `0/1` to `No/Yes`.
4. Adds a numeric `Churn Flag` where churn is `1` and retention is `0`.
5. Creates tenure bands: `0-12`, `13-24`, `25-48`, and `49-72` months.
6. Creates monthly-charge bands: `Low` below $35, `Medium` from $35 to below $70,
   and `High` from $70 upward.

The `TotalCharges` choice preserves valid new-customer records without inventing accumulated
revenue: all 11 blank values belong to customers with zero completed months of tenure.

The complete transformation script is available in
[Telco Churn Power Query.m](Telco%20Churn%20Power%20Query.m).

## Semantic model and DAX

The Power BI semantic model contains 17 documented measures, including:

- `Total Customers`
- `Churned Customers`
- `Churn Rate %`
- `Avg Monthly Charges`
- `Avg Tenure`
- `Revenue at Risk`
- `Churn Rate vs Overall`
- data-quality and reconciliation measures

Two central measures are:

```DAX
Churn Rate % =
DIVIDE([Churned Customers], [Total Customers], 0)
```

```DAX
Revenue at Risk =
CALCULATE(
    SUM('Telco Churn'[MonthlyCharges]),
    KEEPFILTERS('Telco Churn'[Churn] = "Yes")
)
```

The version-controlled model definition is in
[Telco Churn.tmdl](Telco%20Churn%20Dashboard/Telco%20Churn%20Dashboard.SemanticModel/definition/tables/Telco%20Churn.tmdl).

## Data-quality results

| Check | Result |
| --- | ---: |
| Source rows | 7,043 |
| Null customer IDs | 0 |
| Duplicate customer IDs | 0 |
| Null tenure values | 0 |
| Null monthly charges | 0 |
| Null `TotalCharges` after correction | 0 |
| Null churn labels | 0 |
| Tenure-zero customers | 11 |
| Zero-`TotalCharges` customers after correction | 11 |
| Overall data-quality status | PASS |

## Machine-learning notebook

The included notebook explores churn prediction using:

- Logistic Regression
- K-Nearest Neighbors
- an Artificial Neural Network

Among the recorded notebook runs, Logistic Regression achieved the highest test accuracy at
80.52%. This result is an experiment rather than a production deployment: the notebook does
not include a pinned environment, model registry, drift monitoring, or a live scoring service.
Accuracy should also be considered alongside class-specific precision, recall, and the
business cost of false negatives.

Open [17_22241013__22241055 (2).ipynb](17_22241013__22241055%20%282%29.ipynb) to review the
data exploration, preprocessing, training, and evaluation workflow.

## Repository structure

```text
.
|-- Telco Churn Dashboard/
|   |-- Telco Churn Dashboard.pbip       # Power BI project entry point
|   |-- Telco Churn Dashboard.Report/    # Version-controlled report definition
|   `-- Telco Churn Dashboard.SemanticModel/
|                                           # TMDL semantic model
|-- deliverables/
|   |-- dashboard-overview.png
|   |-- data-quality.png
|   `-- Telco Churn Dashboard.pdf
|-- Telco-Customer-Churn.csv              # Source dataset
|-- Telco Churn Power Query.m             # Power Query transformation script
|-- Part 2 Measures.tmdl                   # Core DAX measure definitions
|-- Part 2 Validation.dax                  # DAX validation queries
|-- 17_22241013__22241055 (2).ipynb       # Predictive-analysis notebook
`-- README.md
```

## Open the Power BI project

Requirements:

- Windows
- a recent version of Power BI Desktop with Power BI Project (`.pbip`) support

Steps:

1. Clone or download this repository.
2. Open
   [Telco Churn Dashboard.pbip](Telco%20Churn%20Dashboard/Telco%20Churn%20Dashboard.pbip)
   in Power BI Desktop.
3. If Power BI cannot find the CSV, select **Home > Transform data > Data source settings**.
4. Select the current CSV source, choose **Change Source**, and point it to
   `Telco-Customer-Churn.csv` in the repository root.
5. Select **Close & Apply**, then **Refresh**.

The project includes both PBIR report definitions and TMDL semantic-model files, allowing the
dashboard logic to be reviewed through Git instead of relying only on a binary `.pbix` file.

## Recommended business actions

1. Prioritize onboarding and retention outreach during the first 12 months.
2. Test contract-migration incentives for eligible month-to-month customers.
3. Investigate the fiber-optic customer experience, including service expectations and
   support interactions.
4. Test payment-method migration campaigns for electronic-check customers.
5. Evaluate each intervention through a controlled pilot using incremental churn reduction
   and monthly revenue retained as success measures.

## Skills demonstrated

- Power BI report design and interactive data visualization
- Power Query data cleaning and transformation
- DAX measure development and filter-context reasoning
- data-quality validation and reconciliation
- customer segmentation and business analysis
- Python-based exploratory analysis and predictive modeling
- version-controlled Power BI development with PBIP, PBIR, and TMDL

## Project limitations

- The analysis uses a static historical dataset and does not demonstrate causal effects.
- Monthly revenue at risk is a descriptive monthly-charge total, not predicted lifetime value.
- The notebook results have not been validated through cross-validation, deployment, or
  production monitoring in this repository.
- The Power Query source path may need to be updated after cloning the project.
- Recommended actions should be tested before organization-wide implementation.

---

Repository: [7illz/Telco-Customer-Churn-Prediction](https://github.com/7illz/Telco-Customer-Churn-Prediction)
