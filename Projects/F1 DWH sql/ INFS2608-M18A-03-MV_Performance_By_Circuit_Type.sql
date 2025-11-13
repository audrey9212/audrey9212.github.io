-- Circuit Characteristics and Driver Performance Correlation View
-- This view analyzes how drivers and their cars perform on different types of circuits.
-- It helps identify which drivers excel on specific track layouts, such as high-speed or technical tracks.


CREATE MATERIALIZED VIEW MV_Performance_By_Circuit_Type
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    -- Dimension
    d.FullName AS DriverName,
    rc.CharacteristicType AS CircuitCharacteristicType,

    -- Indicator
    COUNT(f.RacePerformanceKey) AS RacesOnThisType,
    ROUND(AVG(f.PositionFinished), 2) AS AvgFinishPosition,
    ROUND(AVG(f.Overtakes), 2) AS AvgOvertakes,
    ROUND(AVG(f.TireDegradationRate), 4) AS AvgTireDegradation,
    SUM(f.isDNF) AS DNFsOnThisType
FROM
    Fact_RacePerformance f
JOIN
    DW_Driver_Dim d ON f.DriverKey = d.DriverKey
JOIN
    DW_Race_Circuit_Dim rc ON f.RaceKey = rc.RaceKey
GROUP BY
    d.FullName,
    rc.CharacteristicType;