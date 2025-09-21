Create project_summary.md
Project Title: Deductible Impact on Patient Price Estimates

Goal
This project investigates why patient price estimate requests decline as the year progresses. The working hypothesis is that once patients meet their deductible or out-of-pocket maximum, they are less motivated to request estimates.

Dataset
A semi-synthetic dataset of 521 patient price estimates was created, totaling $3.9M in estimated services. The dataset includes fields for Visit Date, Insurance Type, Plan Year Type, Payer Name, Network Status, Service Category, Estimate Value, Insurance Covered, Patient Responsibility, Deductible Portion, Copay Portion, and Coinsurance Portion. Data was anonymized and modeled with realistic insurance/payment rules (e.g., Medicaid fully covered, higher copays for advanced imaging and surgery).

Tools

BigQuery (SQL): Data import, validation, and analysis queries.

Tableau Public: Interactive visualizations and dashboard.

Methods

Aggregated patient estimate values monthly to track trends.

Compared Q1 vs Q3 average estimates per visit for Commercial, Calendar-Year, In-Network plans.

Analyzed service category copay patterns, highlighting high-cost services.

Normalized results by per-visit averages to account for uneven quarter coverage.

Findings

Decline in Demand: Average estimate per visit declined significantly from Q1 to Q3, supporting the deductible/OOP hypothesis.

Insurance Mix: Commercial plans showed the sharpest decline in estimates, while Medicaid/Medicare remained stable.

Service Category Impact: Advanced Imaging and Surgery consistently carried higher copays, with a large proportion of patients exceeding $250.

Patient vs Provider Perspective: Both average estimate values and patient out-of-pocket responsibilities declined over time, showing insurers absorbed more cost share later in the year.

Deliverables

SQL scripts (patient_estimate_analysis.sql).

Tableau Dashboard: Deductible Impact on Patient Price Estimates (published to Tableau Public).

Written project summary
