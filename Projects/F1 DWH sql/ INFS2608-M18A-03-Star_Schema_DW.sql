-- Script:         F1 Race Performance Data Warehouse Creation Script
-- Narrative Core: Build a star schema data warehouse centered on "Driver Race Performance". This structure
--                 aims to analyze how driver's physical/mental condition, vehicle performance, track
--                 characteristics, and race strategy collectively impact final race results.
-- Source DB:      Transactional database (OLTP) created by F1_DB_final.sql
-- Target Schema:  Star Schema (Fact_RacePerformance)




-- ====================================================================================================
-- Step 1: Environment Cleanup (DROP DWH TABLES)
-- Purpose: Delete existing DWH tables to ensure the script can be executed repeatedly without errors.
-- Note: Drop order is reverse of creation order to avoid foreign key constraint issues.
-- ====================================================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Fact_RacePerformance CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DW_Driver_Dim CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DW_Vehicle_Dim CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DW_Race_Circuit_Dim CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DW_Strategy_Dim CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DW_F1_Date_Dim CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Old DWH tables successfully dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -942 THEN
            DBMS_OUTPUT.PUT_LINE('DWH tables do not exist, no need to drop, ready to start creation.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Similarly, drop possibly existing materialized views
BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW MV_Driver_Performance_Summary';
    DBMS_OUTPUT.PUT_LINE('Old materialized view successfully dropped.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -12003 THEN
            DBMS_OUTPUT.PUT_LINE('Materialized view does not exist, no need to drop.');
        ELSE
            RAISE;
        END IF;
END;
/


-- ====================================================================================================
-- Step 2: Create Dimension Tables (CREATE DIMENSION TABLES)
-- Purpose: Extract data from multiple source tables through denormalization to build dimension tables.
-- ====================================================================================================

-- Dimension Table 1: DW_F1_Date_Dim (Time Dimension)
-- Source: Extract unique race dates from Race table
-- ========================================================
CREATE TABLE DW_F1_Date_Dim AS
SELECT DISTINCT
    Date_Race AS Date_Key,
    Date_Race AS FullDate,
    TRIM(TO_CHAR(Date_Race, 'Day')) AS DayOfWeek,
    TRIM(TO_CHAR(Date_Race, 'Month')) AS MonthName,
    TO_CHAR(Date_Race, 'Q') AS Quarter,
    EXTRACT(YEAR FROM Date_Race) AS Year
FROM Race
WHERE Date_Race IS NOT NULL;

ALTER TABLE DW_F1_Date_Dim
ADD CONSTRAINT PK_DW_F1_Date_Dim PRIMARY KEY (Date_Key);

BEGIN
    DBMS_OUTPUT.PUT_LINE('DW_F1_Date_Dim dimension table created successfully.');
END;
/


-- Dimension Table 2: DW_Driver_Dim (Driver Dimension)
-- Source: Integrate information from Employee, Driver, DriverWellbeing, HealthRecord, MentalAssessment tables.
-- Description: This is a complex dimension that integrates driver basic information, experience, and 
--              various health/mental status snapshots. For simplification, we only take the latest 
--              health and mental assessment records as representatives.
-- ========================================================
CREATE TABLE DW_Driver_Dim AS
WITH LastHealthRecord AS (
    SELECT
        hr.DriverWellbeingID,
        hr.VO2Max,
        hr.BodyFatPercentage,
        ROW_NUMBER() OVER(PARTITION BY dw.DriverWellbeingID ORDER BY hr.CheckupDate DESC) as rn
    FROM HealthRecord hr
    JOIN DriverWellbeing dw ON hr.DriverWellbeingID = dw.DriverWellbeingID
),
LastMentalAssessment AS (
    SELECT
        ma.DriverID,
        ma.StressScore,
        ma.FocusLevelScore,
        ROW_NUMBER() OVER(PARTITION BY ma.DriverID ORDER BY ma.AssessmentDate DESC) as rn
    FROM MentalAssessment ma
)
SELECT
    d.DriverID AS DriverKey,
    d.DriverID AS DriverID_Natural,
    e.FirstName || ' ' || e.LastName AS FullName,
    e.Nationality,
    d.RaceNumber,
    d.ExperienceYears,
    dw.FitnessScore AS FitnessScore_Snapshot,
    dw.SleepQualityScore AS SleepQualityScore_Snapshot,
    dw.RecoveryRate AS RecoveryRate_Snapshot,
    lma.StressScore AS LastStressScore,
    lma.FocusLevelScore AS LastFocusLevel,
    lhr.VO2Max AS LastVO2Max,
    lhr.BodyFatPercentage AS LastBodyFatPercentage
FROM Driver d
JOIN Employee e ON d.EmployeeID = e.EmployeeID
JOIN DriverWellbeing dw ON d.DriverWellbeingID = dw.DriverWellbeingID
LEFT JOIN LastHealthRecord lhr ON dw.DriverWellbeingID = lhr.DriverWellbeingID AND lhr.rn = 1
LEFT JOIN LastMentalAssessment lma ON d.DriverID = lma.DriverID AND lma.rn = 1;

ALTER TABLE DW_Driver_Dim
ADD CONSTRAINT PK_DW_Driver_Dim PRIMARY KEY (DriverKey);

BEGIN
    DBMS_OUTPUT.PUT_LINE('DW_Driver_Dim dimension table created successfully.');
END;
/


-- Dimension Table 3: DW_Vehicle_Dim (Vehicle Dimension)
-- Source: Vehicle table
-- ========================================================
CREATE TABLE DW_Vehicle_Dim AS
SELECT
    VehicleID AS VehicleKey,
    VehicleID AS VehicleID_Natural,
    ChassisNumber,
    EngineType,
    CarWeight,
    TopSpeed,
    AerodynamicsCO,
    Status
FROM Vehicle;

ALTER TABLE DW_Vehicle_Dim
ADD CONSTRAINT PK_DW_Vehicle_Dim PRIMARY KEY (VehicleKey);

BEGIN
    DBMS_OUTPUT.PUT_LINE('DW_Vehicle_Dim dimension table created successfully.');
END;
/


-- Dimension Table 4: DW_Race_Circuit_Dim (Race and Circuit Dimension)
-- Source: Integrate Race and Circuit tables
-- ========================================================
CREATE TABLE DW_Race_Circuit_Dim AS
SELECT
    r.RaceID AS RaceKey,
    r.RaceID AS RaceID_Natural,
    r.RaceName,
    r.WeatherCondition,
    c.CircuitName,
    c.Country,
    c.Location,
    c.LengthKM AS CircuitLengthKM,
    c.NumCorners,
    c.AvgWidthMeters,
    c.ElevationChangeMeters,
    c.SurfaceType,
    c.SurfaceRoughness,
    c.CharacteristicType
FROM Race r
JOIN Circuit c ON r.CircuitID = c.CircuitID;

ALTER TABLE DW_Race_Circuit_Dim
ADD CONSTRAINT PK_DW_Race_Circuit_Dim PRIMARY KEY (RaceKey);

BEGIN
    DBMS_OUTPUT.PUT_LINE('DW_Race_Circuit_Dim dimension table created successfully.');
END;
/


-- Dimension Table 5: DW_Strategy_Dim (Strategy Dimension)
-- Source: Integrate RaceStrategy, Manager, Employee tables
-- ========================================================
CREATE TABLE DW_Strategy_Dim AS
SELECT
    rs.StrategyID AS StrategyKey,
    rs.StrategyID AS StrategyID_Natural,
    rs.PlannedPitStops,
    rs.ActualPitStops,
    rs.TireSelection,
    rs.FuelLoadPlan,
    rs.StrategyOutcome,
    emp.FirstName || ' ' || emp.LastName AS StrategyManagerName
FROM RaceStrategy rs
JOIN Manager m ON rs.ManagerID = m.ManagerID
JOIN Employee emp ON m.EmployeeID = emp.EmployeeID;

ALTER TABLE DW_Strategy_Dim
ADD CONSTRAINT PK_DW_Strategy_Dim PRIMARY KEY (StrategyKey);

BEGIN
    DBMS_OUTPUT.PUT_LINE('DW_Strategy_Dim dimension table created successfully.');
END;
/


-- ====================================================================================================
-- I use surrogate keys because they provide a consistent, non-business-dependent identifier for each record, 
-- which aligns with industry-standard best practices for building scalable and maintainable data warehouses.
-- ====================================================================================================

-- ====================================================================================================
-- Step 3: Create Fact Table (CREATE FACT TABLE) 
-- Purpose: Build core fact table and use ROW_NUMBER() to clean potential duplicate data caused by JOINs,
--          ensuring each driver/race has only one record.
-- ====================================================================================================

CREATE TABLE Fact_RacePerformance AS
WITH FactData_Pre AS (
    SELECT
        -- Foreign Keys to Dimensions
        dp.DriverID AS DriverKey,
        r.Date_Race AS DateKey,
        dp.RaceID AS RaceKey,
        va.VehicleID AS VehicleKey,
        rs.StrategyID AS StrategyKey,

        -- Degenerate Dimensions
        ra.QualifyingPosition,
        ra.StartingGridPosition,
        
        -- Measures
        dp.LapTimes,
        dp.PositionFinished,
        dp.Overtakes,
        dp.Pitstops AS ActualPitStops_DP,
        dp.TireDegradationRate,
        dp.EnergyManagementScore,
        CASE WHEN ra.DNF = 'Yes' THEN 1 ELSE 0 END AS isDNF,
        (SELECT nl.Calories FROM NutritionLog nl WHERE nl.DriverID = dp.DriverID AND nl.RecordDate = r.Date_Race AND ROWNUM = 1) AS RaceDayCalories,
        (SELECT nl.HydrationLitres FROM NutritionLog nl WHERE nl.DriverID = dp.DriverID AND nl.RecordDate = r.Date_Race AND ROWNUM = 1) AS RaceDayHydrationLitres,
        (SELECT ma.StressScore FROM MentalAssessment ma WHERE ma.DriverID = dp.DriverID AND ma.AssessmentDate < r.Date_Race ORDER BY ma.AssessmentDate DESC FETCH FIRST 1 ROW ONLY) AS PreRace_StressScore,
        (SELECT ma.FocusLevelScore FROM MentalAssessment ma WHERE ma.DriverID = dp.DriverID AND ma.AssessmentDate < r.Date_Race ORDER BY ma.AssessmentDate DESC FETCH FIRST 1 ROW ONLY) AS PreRace_FocusLevel,

        -- Create a row number to partition by the intended natural key.
        -- This handles cases where a driver has multiple vehicle assignments or strategies for a single race.
        ROW_NUMBER() OVER(PARTITION BY dp.DriverID, r.Date_Race, dp.RaceID ORDER BY va.VehicleID DESC, rs.StrategyID DESC) as rn

    FROM DriverPerformance dp
    JOIN Race r ON dp.RaceID = r.RaceID
    JOIN RaceAssignment ra ON dp.DriverID = ra.DriverID AND dp.RaceID = ra.RaceID
    LEFT JOIN RaceStrategy rs ON ra.RaceAssignmentID = rs.RaceAssignmentID
    LEFT JOIN VehicleAssignment va ON dp.DriverID = va.DriverID AND r.Date_Race BETWEEN va.StartDate AND NVL(va.EndDate, SYSDATE)
)
SELECT
    -- Add a new surrogate key column. This will be populated automatically.
    ROWNUM AS RacePerformanceKey, -- Simple surrogate key for this example
    DriverKey, DateKey, RaceKey, VehicleKey, StrategyKey,
    QualifyingPosition, StartingGridPosition, LapTimes, PositionFinished, Overtakes, ActualPitStops_DP,
    TireDegradationRate, EnergyManagementScore, isDNF, RaceDayCalories, RaceDayHydrationLitres,
    PreRace_StressScore, PreRace_FocusLevel
FROM FactData_Pre
WHERE rn = 1;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Fact_RacePerformance fact table created successfully.');
END;
/

-- ====================================================================================================
-- Step 4: Add Primary and Foreign Key Constraints (ADD PRIMARY & FOREIGN KEYS)
-- ====================================================================================================
-- Adding the new Surrogate Primary Key to the Fact Table

-- (Note: A better way in production is GENERATED AS IDENTITY, but for a CTAS this works)
ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT PK_Fact_RacePerformance PRIMARY KEY (RacePerformanceKey);

-- Foreign Key constraints remain the same
ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT FK_Fact_Driver FOREIGN KEY (DriverKey) REFERENCES DW_Driver_Dim(DriverKey);

ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT FK_Fact_Date FOREIGN KEY (DateKey) REFERENCES DW_F1_Date_Dim(Date_Key);

ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT FK_Fact_RaceCircuit FOREIGN KEY (RaceKey) REFERENCES DW_Race_Circuit_Dim(RaceKey);

ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT FK_Fact_Vehicle FOREIGN KEY (VehicleKey) REFERENCES DW_Vehicle_Dim(VehicleKey);

ALTER TABLE Fact_RacePerformance
ADD CONSTRAINT FK_Fact_Strategy FOREIGN KEY (StrategyKey) REFERENCES DW_Strategy_Dim(StrategyKey);

BEGIN
    DBMS_OUTPUT.PUT_LINE('Primary key and foreign key constraints created successfully.');
END;
/

-- ====================================================================================================
-- Step 6: Commit Transaction
-- ====================================================================================================
COMMIT;

BEGIN
    DBMS_OUTPUT.PUT_LINE('All transactions committed, F1 Data Warehouse construction completed!');
END;
/