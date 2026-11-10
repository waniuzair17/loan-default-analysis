-- Loan Default Analysis (Lending Club, 2007-2018)
-- Table "loans" was loaded from pandas into PostgreSQL (database: loan_db)

-- Setup: rename the reserved word "default" to is_default (1 = defaulted, 0 = fully paid)
ALTER TABLE loans RENAME COLUMN "default" TO is_default;

-- Check: total rows loaded (expected 1,328,453)
SELECT COUNT(*) FROM loans;

-- 1. Default rate by grade
SELECT grade,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY grade
ORDER BY grade;

-- 2. Default rate by loan purpose
SELECT purpose,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY purpose
ORDER BY default_rate_pct DESC;

-- 3. Default rate by loan term (36 vs 60 months)
SELECT term,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY term;

-- 4. Default rate by income band
SELECT CASE
         WHEN annual_inc < 40000 THEN '1. Under 40K'
         WHEN annual_inc < 80000 THEN '2. 40K-80K'
         WHEN annual_inc < 120000 THEN '3. 80K-120K'
         ELSE '4. 120K+'
       END AS income_band,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY income_band
ORDER BY income_band;

-- 5. Default rate by grade and term
-- Tests whether term adds risk on its own, or only because riskier grades pick 60 months
SELECT grade, term,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY grade, term
ORDER BY grade, term;

-- 6. Default rate by issue year
-- Note: recent years are understated because many loans had not matured yet
SELECT issue_year,
       COUNT(*) AS total_loans,
       ROUND(AVG(is_default) * 100, 1) AS default_rate_pct
FROM loans
GROUP BY issue_year
ORDER BY issue_year;

-- 7. Summary table for the Power BI dashboard
CREATE TABLE loan_summary AS
SELECT grade,
       term,
       purpose,
       CASE
         WHEN annual_inc < 40000 THEN '1. Under 40K'
         WHEN annual_inc < 80000 THEN '2. 40K-80K'
         WHEN annual_inc < 120000 THEN '3. 80K-120K'
         ELSE '4. 120K+'
       END AS income_band,
       issue_year,
       COUNT(*) AS total_loans,
       SUM(is_default) AS defaults
FROM loans
GROUP BY grade, term, purpose, income_band, issue_year;

-- Check: summary table totals (expected 1,328,453 loans and 266,274 defaults)
SELECT COUNT(*) AS rows, SUM(total_loans) AS loans, SUM(defaults) AS defaults
FROM loan_summary;