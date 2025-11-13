-- ====================================================================================================
-- Script:         車手策略影響分析視圖 (MV_Driver_Strategy_Impact_Enhanced) - **最終加強版**
-- Author:         [Gemini for Group3/Audrey]
-- Purpose:        此腳本為最終的加強版本。它整合了原始策略視圖的所有詳細維度和指標，
--                 並加入了 DriverName，使其具備最強的分析能力和關聯性。
--                 它完全基於星狀結構，並預先計算了所有必要的匯總數據。
-- ====================================================================================================

CREATE MATERIALIZED VIEW MV_Driver_Strategy_Impact_Enhanced
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    -- ===================================
    -- 維度 (Dimensions) - 包含了原始版本的所有維度，並新增了DriverName
    -- ===================================
    d.FullName AS DriverName,
    rc.WeatherCondition,
    s.StrategyOutcome,
    s.TireSelection,
    s.PlannedPitStops,

    -- ===================================
    -- 指標 (Metrics) - 包含了原始版本的所有指標
    -- ===================================
    COUNT(f.RacePerformanceKey) AS TimesUsed, -- 該組合被使用的次數
    ROUND(AVG(f.PositionFinished), 2) AS AvgFinishPosition, -- 平均完賽名次
    
    -- 計算名次提升率：(起跑名次 > 完賽名次的比賽次數 / 總比賽次數) * 100
    ROUND(SUM(CASE WHEN f.isDNF = 0 AND f.StartingGridPosition > f.PositionFinished THEN 1 ELSE 0 END) * 100.0 / COUNT(f.RacePerformanceKey), 2) AS PositionGained_Rate_Percent,
    
    ROUND(AVG(f.Overtakes), 2) AS AvgOvertakes, -- 平均超車次數
    
    -- 額外加入的指標，增加分析維度
    SUM(f.isDNF) AS TotalDNFs

FROM
    Fact_RacePerformance f
JOIN
    DW_Driver_Dim d ON f.DriverKey = d.DriverKey
JOIN
    DW_Race_Circuit_Dim rc ON f.RaceKey = rc.RaceKey
JOIN
    DW_Strategy_Dim s ON f.StrategyKey = s.StrategyKey
GROUP BY
    d.FullName,
    rc.WeatherCondition,
    s.StrategyOutcome,
    s.TireSelection,
    s.PlannedPitStops;