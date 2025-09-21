-- =========================================
-- Patient Estimate Analysis (BigQuery SQL)
-- Project: fleet-cirrus-472420-f5
-- Dataset: price_estimate_demo
-- Table:   patient_estimates   (PascalCase columns)
-- =========================================

-- 0) Row count + total estimates (sanity)
SELECT COUNT(*) AS row_count,
       ROUND(SUM(EstimateValue), 2) AS total_estimate
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`;

-- 1) Monthly trend (totals & visits)
SELECT DATE_TRUNC(VisitDate, MONTH) AS Month,
       SUM(EstimateValue)           AS TotalEstimateValue,
       SUM(PatientResponsibility)   AS TotalPatientResp,
       SUM(InsuranceCovered)        AS TotalInsuranceCovered,
       COUNT(*)                     AS Visits
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
GROUP BY Month
ORDER BY Month;

-- 2) Q1→Q3 per-visit KPI (Commercial, Calendar-Year, In-Network)
WITH q AS (
  SELECT EXTRACT(QUARTER FROM VisitDate) AS Quarter,
         AVG(EstimateValue)              AS AvgEstimatePerVisit,
         AVG(PatientResponsibility)      AS AvgOOPPerVisit
  FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
  WHERE InsuranceType = 'Commercial'
    AND PlanYearType  = 'Calendar Year'
    AND NetworkStatus = 'In-Network'
  GROUP BY Quarter
)
SELECT
  MAX(CASE WHEN Quarter=1 THEN AvgEstimatePerVisit END) AS Q1_AvgEstimate,
  MAX(CASE WHEN Quarter=3 THEN AvgEstimatePerVisit END) AS Q3_AvgEstimate,
  ROUND(100 * (1 - SAFE_DIVIDE(
    MAX(CASE WHEN Quarter=3 THEN AvgEstimatePerVisit END),
    NULLIF(MAX(CASE WHEN Quarter=1 THEN AvgEstimatePerVisit END), 0)
  )), 1) AS PctDecline_Estimate_Q1_to_Q3,
  MAX(CASE WHEN Quarter=1 THEN AvgOOPPerVisit END)      AS Q1_AvgOOP,
  MAX(CASE WHEN Quarter=3 THEN AvgOOPPerVisit END)      AS Q3_AvgOOP,
  ROUND(100 * (1 - SAFE_DIVIDE(
    MAX(CASE WHEN Quarter=3 THEN AvgOOPPerVisit END),
    NULLIF(MAX(CASE WHEN Quarter=1 THEN AvgOOPPerVisit END), 0)
  )), 1) AS PctDecline_OOP_Q1_to_Q3
FROM q;

-- 3) Service category + copay profile (Commercial/Medicare)
SELECT ServiceCategory,
       COUNT(*)                                         AS Visits,
       AVG(CopayPortion)                                AS AvgCopay,
       COUNTIF(CopayPortion >= 250) * 100.0 / COUNT(*)  AS PctHighCopay_250Plus,
       AVG(PatientResponsibility)                       AS AvgOOPPerVisit
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
WHERE InsuranceType IN ('Commercial','Medicare')
GROUP BY ServiceCategory
ORDER BY AvgCopay DESC;

-- 4) Monthly per-visit averages (normalizes uneven months)
SELECT DATE_TRUNC(VisitDate, MONTH) AS Month,
       AVG(EstimateValue)           AS AvgEstimatePerVisit,
       AVG(PatientResponsibility)   AS AvgOOPPerVisit
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
GROUP BY Month
ORDER BY Month;

-- 5) OPTIONAL Views (useful if you stay in BigQuery)
CREATE OR REPLACE VIEW `fleet-cirrus-472420-f5.price_estimate_demo.v_monthly_summary` AS
SELECT DATE_TRUNC(VisitDate, MONTH) AS Month,
       SUM(EstimateValue)           AS TotalEstimateValue,
       SUM(PatientResponsibility)   AS TotalPatientResp,
       SUM(InsuranceCovered)        AS TotalInsuranceCovered,
       COUNT(*)                     AS Visits
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
GROUP BY Month;

CREATE OR REPLACE VIEW `fleet-cirrus-472420-f5.price_estimate_demo.v_comm_cal_innet_quarterly` AS
SELECT EXTRACT(QUARTER FROM VisitDate) AS Quarter,
       SUM(EstimateValue)              AS TotalEstimateValue,
       COUNT(*)                        AS Visits,
       AVG(EstimateValue)              AS AvgEstimatePerVisit,
       AVG(PatientResponsibility)      AS AvgOOPPerVisit
FROM `fleet-cirrus-472420-f5.price_estimate_demo.patient_estimates`
WHERE InsuranceType = 'Commercial'
  AND PlanYearType  = 'Calendar Year'
  AND NetworkStatus = 'In-Network'
GROUP BY Quarter;

