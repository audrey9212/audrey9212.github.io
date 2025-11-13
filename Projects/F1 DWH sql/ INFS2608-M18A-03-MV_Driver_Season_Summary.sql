-- Driver Season Performance Comparison View (Lando vs. Oscar)
-- This view provides a high-level summary of each driver's performance throughout an entire season. 
-- It's designed to give a quick overview of who performed better overall using key metrics like total wins and average finish position.
CREATE MATERIALIZED VIEW MV_Driver_Season_Summary
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    d.FullName AS DriverName,
    d.Nationality,
    COUNT(f.RacePerformanceKey) AS TotalRaces,
    SUM(CASE WHEN f.PositionFinished = 1 THEN 1 ELSE 0 END) AS TotalWins,
    SUM(CASE WHEN f.PositionFinished <= 3 THEN 1 ELSE 0 END) AS TotalPodiums,
    SUM(f.isDNF) AS TotalDNFs,
    ROUND(AVG(f.PositionFinished), 2) AS AverageFinishPosition,
    SUM(f.Overtakes) AS TotalOvertakes,
    ROUND(AVG(f.TireDegradationRate), 4) AS AverageTireDegradationRate,
    ROUND(AVG(f.PreRace_StressScore), 2) AS AveragePreRaceStressScore,
    ROUND(AVG(f.QualifyingPosition), 2) AS AverageQualifyingPosition
FROM
    Fact_RacePerformance f
JOIN
    DW_Driver_Dim d ON f.DriverKey = d.DriverKey
GROUP BY
    d.FullName,
    d.Nationality;
    
    
