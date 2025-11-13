-- Driver Mental and Physical Condition vs. Race Outcome Correlation View
-- This view links a driver's mental and physical state (quantified as "stress level") to their on-track results. 
-- It can show how factors like high stress affect performance, DNF rates, and average finishing positions.


CREATE MATERIALIZED VIEW MV_Wellbeing_Performance_Link
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    d.FullName AS DriverName,
    CASE
        WHEN f.PreRace_StressScore <= 15 THEN 'Low Stress'
        WHEN f.PreRace_StressScore > 15 AND f.PreRace_StressScore <= 24 THEN 'Medium Stress'
        WHEN f.PreRace_StressScore >= 25 THEN 'High Stress'
        ELSE 'Unknown'
    END AS StressLevel,
    COUNT(f.RacePerformanceKey) AS TotalRacesInLevel,
    ROUND(AVG(f.PositionFinished), 2) AS AvgFinishPosition,
    SUM(f.isDNF) AS TotalDNFs,
    ROUND(SUM(f.isDNF) * 100.0 / COUNT(f.RacePerformanceKey), 2) AS DNF_Rate_Percent
FROM
    Fact_RacePerformance f
JOIN
    DW_Driver_Dim d ON f.DriverKey = d.DriverKey
WHERE
    f.PreRace_StressScore IS NOT NULL
GROUP BY
    d.FullName,
    CASE
        WHEN f.PreRace_StressScore <= 15 THEN 'Low Stress'
        WHEN f.PreRace_StressScore > 15 AND f.PreRace_StressScore <= 24 THEN 'Medium Stress'
        WHEN f.PreRace_StressScore >= 25 THEN 'High Stress'
        ELSE 'Unknown'
    END;