-- ==========================================
-- PRCA Survey Data Processing Pipeline
-- Purpose: Import, combine, and merge Prolific
-- and Qualtrics survey data
-- ==========================================


-- 1. Create SQLite database
-- Run in terminal:
-- sqlite3 prca.db


-- 2. Import CSV files into SQLite tables

.mode csv
.import "original_data/PRCAProlificExport_FileA.csv" prolific_a

.mode csv
.import "original_data/PRCAProlificExport_FileB.csv" prolific_b

.mode csv
.import "original_data/PRCAQualtricsExport_FileC.csv" qualtrics


-- 3. Check imported tables

.tables


-- 4. Combine two Prolific exports

CREATE TABLE prolific AS
SELECT *
FROM prolific_a

UNION ALL

SELECT *
FROM prolific_b;


-- 5. Validate Prolific data size

SELECT COUNT(*)
FROM prolific;
-- Expected: 262 observations


-- 6. Check duplicate participant IDs

SELECT 
    "Participant id",
    COUNT(*) AS n
FROM prolific
GROUP BY "Participant id"
HAVING COUNT(*) > 1;


-- 7. Merge Prolific and Qualtrics data

CREATE TABLE merged_data AS
SELECT 
    p.*,
    q.*
FROM prolific AS p
INNER JOIN qualtrics AS q
ON p."Participant id" = q.Q0;


-- 8. Validate merged dataset size

SELECT COUNT(*)
FROM merged_data;
-- Expected: 252 matched observations


-- 9. Check Qualtrics-only observations

SELECT COUNT(*)
FROM qualtrics AS q
LEFT JOIN prolific AS p
ON q.Q0 = p."Participant id"
WHERE p."Participant id" IS NULL;
-- Expected: 21


-- 10. Check Prolific-only observations

SELECT COUNT(*)
FROM prolific AS p
LEFT JOIN qualtrics AS q
ON p."Participant id" = q.Q0
WHERE q.Q0 IS NULL;
-- Expected: 10


-- 11. Export final merged dataset (local use only)

.headers on
.mode csv
.output merged_data.csv

SELECT *
FROM merged_data;

.output stdout