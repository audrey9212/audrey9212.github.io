-- Script: F1 Team Database Full Creation and Data Insertion Script 
-- Purpose: To establish a complete F1 team database schema and insert a large volume of simulated data with potential for analytical insights.
-- Narrative Core: Revolves around the McLaren F1 Team's 2025 season first half (13 races),
--                  highlighting the performance differences between Lando Norris and Oscar Piastri, vehicle reliability,
--                  strategic impacts, and the correlation between driver wellbeing and performance.
--                  All tables related to 'events' and 'entities' contain more than 10 records, 
--                  with many tables having over 20 records, providing a richer foundation for analysis.



-- ============================================================================
-- Part 1: Environment Cleanup (DROP TABLES & SEQUENCES)
-- Purpose: To ensure the script starts in a clean environment upon each execution.
-- Handle materialized views first, then regular tables
-- Not attempt to delete system-generated sequences
-- ============================================================================
BEGIN
   -- Delete materialized views
   FOR MV IN (SELECT MVIEW_NAME FROM USER_MVIEWS) LOOP

   -- Delete tables
         EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || MV.MVIEW_NAME;
      EXCEPTION
         WHEN OTHERS THEN NULL; -- Ignore errors
      END;
   END LOOP;
   
   FOR T IN (SELECT TABLE_NAME FROM USER_TABLES 
             WHERE TABLE_NAME NOT IN (SELECT MVIEW_NAME FROM USER_MVIEWS)) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ' || T.TABLE_NAME || ' CASCADE CONSTRAINTS';
      EXCEPTION
         WHEN OTHERS THEN NULL; -- Ignore errors
      END;
   END LOOP;
   
   -- Only delete user-created sequences
   FOR S IN (SELECT SEQUENCE_NAME FROM USER_SEQUENCES 
             WHERE SEQUENCE_NAME NOT LIKE 'ISEQ$$%') LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP SEQUENCE ' || S.SEQUENCE_NAME;
      EXCEPTION
         WHEN OTHERS THEN NULL; -- Ignore errors
      END;
   END LOOP;
END;
/


-- ============================================================================
-- Part 2: Database Schema Definition (DDL - CREATE TABLES & SEQUENCES)
-- Purpose: To create all tables and sequences based on the latest analytical requirements.
-- ============================================================================

-- Create Sequences
CREATE SEQUENCE employee_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE vehicle_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE race_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE race_assignment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE strategy_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sponsor_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE sponsorship_contract_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE facility_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE training_session_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE wellbeing_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE wellbeing_level_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE vehicle_assignment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE driving_assessment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE performance_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE test_session_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE repair_log_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE pit_stop_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE telemetry_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE health_record_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE wellbeing_session_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mental_assessment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE media_appearance_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE role_assignment_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE contract_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE driver_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE engineer_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE mechanic_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE manager_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE nutrition_log_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE circuit_seq START WITH 1 INCREMENT BY 1;


-- Create Tables
CREATE TABLE Employee (
    EmployeeID NUMBER PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR2(20),
    HireDate DATE NOT NULL,
    DOB DATE,
    Nationality VARCHAR2(50),
    Salary NUMBER(10, 2) NOT NULL,
    Empl_Type VARCHAR2(20) NOT NULL
);
COMMENT ON TABLE Employee IS 'Stores general information about F1 team employees.';

CREATE TABLE DriverWellbeing (
    DriverWellbeingID NUMBER PRIMARY KEY,
    DriverRanking NUMBER,
    ExperienceYears NUMBER,
    SkillLevel NUMBER,
    AssessmentDate DATE,
    FitnessScore NUMBER(5, 2),
    SleepQualityScore NUMBER(3,1),
    RecoveryRate NUMBER(5,2)
);
COMMENT ON TABLE DriverWellbeing IS 'Stores driver wellbeing assessments, including sleep and recovery metrics.';

CREATE TABLE Driver (
    DriverID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL UNIQUE,
    DriverWellbeingID NUMBER NOT NULL,
    LicenseNumber VARCHAR2(50) UNIQUE,
    RaceNumber NUMBER UNIQUE,
    ExperienceYears NUMBER,
    CONSTRAINT fk_driver_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    CONSTRAINT fk_driver_wellbeing FOREIGN KEY (DriverWellbeingID) REFERENCES DriverWellbeing(DriverWellbeingID)
);
COMMENT ON TABLE Driver IS 'Stores specific information for F1 drivers, linking to employee and wellbeing data.';

CREATE TABLE Engineer (
    EngineerID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL UNIQUE,
    Specialisation VARCHAR2(100),
    Certification VARCHAR2(100),
    ShiftSchedule VARCHAR2(50),
    TeamAssigned VARCHAR2(50),
    PerformanceReviewScore NUMBER(3,1),
    CONSTRAINT fk_engineer_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
COMMENT ON TABLE Engineer IS 'Stores information for F1 engineers, including specialisation, certifications, and performance scores.';

CREATE TABLE Mechanic (
    MechanicID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL UNIQUE,
    Certification VARCHAR2(100),
    YearsInTeam NUMBER,
    TeamAssigned VARCHAR2(50),
    CONSTRAINT fk_mechanic_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
COMMENT ON TABLE Mechanic IS 'Stores information for F1 mechanics, including certifications and team assignments.';

CREATE TABLE Manager (
    ManagerID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL UNIQUE,
    Specialisation VARCHAR2(100),
    Certification VARCHAR2(100),
    ShiftSchedule VARCHAR2(50),
    TeamAssigned VARCHAR2(50),
    StrategicFocusArea VARCHAR2(100),
    CONSTRAINT fk_manager_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
COMMENT ON TABLE Manager IS 'Stores information for F1 managers, including specialisation and strategic focus areas.';

CREATE TABLE Contract (
    ContractID NUMBER PRIMARY KEY,
    EmployeeID NUMBER NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    ContractType VARCHAR2(50),
    ContractDetails CLOB,
    Status VARCHAR2(20),
    CONSTRAINT fk_contract_employee FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
COMMENT ON TABLE Contract IS 'Stores employee contract details.';

CREATE TABLE Vehicle (
    VehicleID NUMBER PRIMARY KEY,
    ChassisNumber VARCHAR2(50) UNIQUE NOT NULL,
    EngineType VARCHAR2(50),
    CarWeight NUMBER(6, 2),
    TopSpeed NUMBER(6, 2),
    AerodynamicsCO NUMBER(6, 4),
    Status VARCHAR2(20)
);
COMMENT ON TABLE Vehicle IS 'Stores specifications and status of F1 vehicles.';

CREATE TABLE VehicleAssignment (
    VehicleAssignmentID NUMBER PRIMARY KEY,
    VehicleID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    StartDate DATE,
    EndDate DATE,
    CONSTRAINT fk_v_assign_vehicle FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID),
    CONSTRAINT fk_v_assign_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE VehicleAssignment IS 'Records which vehicle is assigned to which driver for a specific period.';

CREATE TABLE DrivingAssessment (
    DriverAssessmentID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    TrackType VARCHAR2(50),
    SimulatorUsed VARCHAR2(3),
    SessionDuration NUMBER(5, 2),
    ReactionTime NUMBER(5, 3),
    AssessmentDate DATE,
    LapTimeConsistencyScore NUMBER(5,2),
    ErrorsCount NUMBER,
    CONSTRAINT fk_da_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE DrivingAssessment IS 'Records driver performance assessments, focusing on consistency and errors.';

CREATE TABLE Circuit (
    CircuitID NUMBER PRIMARY KEY,
    CircuitName VARCHAR2(100) UNIQUE NOT NULL,
    Country VARCHAR2(100),
    Location VARCHAR2(100),
    LengthKM NUMBER(5, 3),
    NumCorners NUMBER,
    AvgWidthMeters NUMBER,
    ElevationChangeMeters NUMBER,
    SurfaceType VARCHAR2(50),
    SurfaceRoughness VARCHAR2(50), -- e.g., Low, Medium, High
    CharacteristicType VARCHAR2(50) -- e.g., High-Speed, Technical, Balanced
);
COMMENT ON TABLE Circuit IS 'Stores detailed information about F1 race circuits, including physical characteristics that influence car setup and performance.';

CREATE TABLE Race (
    RaceID NUMBER PRIMARY KEY,
    DriverAssessmentID NUMBER NOT NULL,
    CircuitID NUMBER NOT NULL,
    RaceName VARCHAR2(100),
    Date_Race DATE,
    Country VARCHAR2(50),
    TotalDriver NUMBER,
    WeatherCondition VARCHAR2(50),
    CONSTRAINT fk_race_assessment FOREIGN KEY (DriverAssessmentID) REFERENCES DrivingAssessment(DriverAssessmentID),
    CONSTRAINT fk_race_circuit FOREIGN KEY (CircuitID) REFERENCES Circuit(CircuitID)
);
COMMENT ON TABLE Race IS 'Stores detailed information about F1 races, linking to a specific circuit and weather conditions.';

CREATE TABLE RaceAssignment (
    RaceAssignmentID NUMBER PRIMARY KEY,
    RaceID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    StartingGridPosition NUMBER,
    QualifyingPosition NUMBER,
    RadioUsed VARCHAR2(3),
    DNF VARCHAR2(3),
    CONSTRAINT fk_ra_race FOREIGN KEY (RaceID) REFERENCES Race(RaceID),
    CONSTRAINT fk_ra_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE RaceAssignment IS 'Records a driver''s participation and details in a specific race.';

CREATE TABLE RaceStrategy (
    StrategyID NUMBER PRIMARY KEY,
    RaceAssignmentID NUMBER NOT NULL,
    ManagerID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    RaceID NUMBER NOT NULL,
    PlannedPitStops NUMBER,
    TireSelection VARCHAR2(50),
    FuelLoadPlan VARCHAR2(100),
    StrategyNotes CLOB,
    StrategyOutcome VARCHAR2(50),
    ActualPitStops NUMBER,
    CONSTRAINT fk_rs_assignment FOREIGN KEY (RaceAssignmentID) REFERENCES RaceAssignment(RaceAssignmentID),
    CONSTRAINT fk_rs_manager FOREIGN KEY (ManagerID) REFERENCES Manager(ManagerID),
    CONSTRAINT fk_rs_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    CONSTRAINT fk_rs_race FOREIGN KEY (RaceID) REFERENCES Race(RaceID)
);
COMMENT ON TABLE RaceStrategy IS 'Stores details of race strategies, their outcomes, and adherence to the plan.';

CREATE TABLE DriverPerformance (
    PerformanceID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    RaceID NUMBER NOT NULL,
    LapTimes NUMBER(10, 3),
    PositionFinished NUMBER,
    Overtakes NUMBER,
    Pitstops NUMBER,
    TireDegradationRate NUMBER(5,2),
    EnergyManagementScore NUMBER(5,2),
    CONSTRAINT fk_dp_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    CONSTRAINT fk_dp_race FOREIGN KEY (RaceID) REFERENCES Race(RaceID)
);
COMMENT ON TABLE DriverPerformance IS 'Records driver performance metrics, including tire and energy management.';

CREATE TABLE TestSession (
    TestID NUMBER PRIMARY KEY,
    EngineerID NUMBER NOT NULL,
    VehicleID NUMBER NOT NULL,
    RaceID NUMBER,
    Date_Test DATE,
    TestType VARCHAR2(50),
    BrakeUsage NUMBER(5, 2),
    GearShifts NUMBER,
    FuelUsage NUMBER(6, 2),
    GForce NUMBER(4, 2),
    Duration NUMBER(6, 2),
    CONSTRAINT fk_ts_engineer FOREIGN KEY (EngineerID) REFERENCES Engineer(EngineerID),
    CONSTRAINT fk_ts_vehicle FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID),
    CONSTRAINT fk_ts_race_optional FOREIGN KEY (RaceID) REFERENCES Race(RaceID)
);
COMMENT ON TABLE TestSession IS 'Stores details of vehicle test sessions conducted by engineers.';

CREATE TABLE RepairLog (
    RepairID NUMBER PRIMARY KEY,
    MechanicID NUMBER NOT NULL,
    VehicleID NUMBER NOT NULL,
    RepairDate DATE,
    IssueResolved VARCHAR2(3),
    PartsReplaced VARCHAR2(200),
    RepairDescription CLOB,
    CONSTRAINT fk_rl_mechanic FOREIGN KEY (MechanicID) REFERENCES Mechanic(MechanicID),
    CONSTRAINT fk_rl_vehicle FOREIGN KEY (VehicleID) REFERENCES Vehicle(VehicleID)
);
COMMENT ON TABLE RepairLog IS 'Logs vehicle repairs performed by mechanics.';

CREATE TABLE PitStop (
    PitStopID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    RaceID NUMBER NOT NULL,
    LapNumber NUMBER,
    PitDuration NUMBER(8, 4),
    TireChanged VARCHAR2(3),
    FuelAdded NUMBER(5, 2),
    WorkPerformed VARCHAR2(200),
    Status VARCHAR2(20),
    CONSTRAINT fk_ps_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    CONSTRAINT fk_ps_race FOREIGN KEY (RaceID) REFERENCES Race(RaceID)
);
COMMENT ON TABLE PitStop IS 'Records details of pit stops during a race.';

CREATE TABLE Telemetry (
    TelemetryID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    RaceID NUMBER NOT NULL,
    "Timestamp" DATE,
    TopSpeed NUMBER(6, 2),
    BrakeUsage NUMBER(5, 2),
    GearShifts NUMBER,
    FuelUsage NUMBER(6, 2),
    GForce NUMBER(4, 2),
    Duration NUMBER(6, 2),
    EngineRPM NUMBER,
    ThrottlePosition NUMBER(5,2),
    TyreTemperatureFL NUMBER(5,2),
    TyreTemperatureFR NUMBER(5,2),
    TyreTemperatureRL NUMBER(5,2),
    TyreTemperatureRR NUMBER(5,2),
    CONSTRAINT fk_telemetry_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    CONSTRAINT fk_telemetry_race FOREIGN KEY (RaceID) REFERENCES Race(RaceID)
);
COMMENT ON TABLE Telemetry IS 'Stores real-time quantitative telemetry data captured during a race.';

CREATE TABLE WellbeingLevel (
    WellbeingLevelID NUMBER PRIMARY KEY,
    LevelScoreMin NUMBER(5, 2),
    LevelScoreMax NUMBER(5, 2),
    Description VARCHAR2(200)
);
COMMENT ON TABLE WellbeingLevel IS 'Defines score ranges and descriptions for different wellbeing levels.';

CREATE TABLE HealthRecord (
    HealthID NUMBER PRIMARY KEY,
    DriverWellbeingID NUMBER NOT NULL,
    CheckupDate DATE,
    Height NUMBER(5, 2),
    Weight NUMBER(5, 2),
    HeartRate NUMBER,
    VO2Max NUMBER(5,2),
    BodyFatPercentage NUMBER(4,2),
    CONSTRAINT fk_hr_wellbeing FOREIGN KEY (DriverWellbeingID) REFERENCES DriverWellbeing(DriverWellbeingID)
);
COMMENT ON TABLE HealthRecord IS 'Stores driver health checkup records, including key fitness metrics like VO2 Max.';

CREATE TABLE WellbeingSession (
    WellbeingSessionID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    HealthID NUMBER NOT NULL,
    SessionDate DATE,
    Duration NUMBER(5, 2),
    Trainer VARCHAR2(100),
    CONSTRAINT fk_ws_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    CONSTRAINT fk_ws_health FOREIGN KEY (HealthID) REFERENCES HealthRecord(HealthID)
);
COMMENT ON TABLE WellbeingSession IS 'Records wellbeing sessions for drivers with trainers.';

CREATE TABLE MentalAssessment (
    MentalID NUMBER PRIMARY KEY,
    DriverWellbeingID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    AssessmentType VARCHAR2(50),
    CounselorNotes CLOB,
    StressScore NUMBER,
    AssessmentDate DATE,
    FocusLevelScore NUMBER(3,1),
    CONSTRAINT fk_ma_wellbeing FOREIGN KEY (DriverWellbeingID) REFERENCES DriverWellbeing(DriverWellbeingID),
    CONSTRAINT fk_ma_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE MentalAssessment IS 'Stores details of driver mental assessments, including stress and focus levels.';

CREATE TABLE Sponsor (
    SponsorID NUMBER PRIMARY KEY,
    SponsorName VARCHAR2(100) NOT NULL,
    Industry VARCHAR2(100),
    ContractValue NUMBER(15, 2),
    StartDate DATE,
    EndDate DATE
);
COMMENT ON TABLE Sponsor IS 'Stores information about the F1 team''s sponsors.';

CREATE TABLE SponsorshipContract (
    ContractID NUMBER PRIMARY KEY,
    SponsorID NUMBER NOT NULL,
    DriverID NUMBER,
    ContractStartDate DATE,
    ContractEndDate DATE,
    ContractDetails CLOB,
    AnnualPaymentAmount NUMBER(15,2),
    MarketingDeliverables CLOB,
    CONSTRAINT fk_sc_sponsor FOREIGN KEY (SponsorID) REFERENCES Sponsor(SponsorID),
    CONSTRAINT fk_sc_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE SponsorshipContract IS 'Details sponsorship agreements, including financial terms and marketing obligations.';

CREATE TABLE TrainingFacility (
    FacilityID NUMBER PRIMARY KEY,
    FacilityName VARCHAR2(100),
    Location VARCHAR2(100),
    Capacity NUMBER,
    AvailableEquipment VARCHAR2(500)
);
COMMENT ON TABLE TrainingFacility IS 'Stores information about F1 training facilities.';

CREATE TABLE TrainingSession (
    TrainingID NUMBER PRIMARY KEY,
    FacilityID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    SessionType VARCHAR2(50),
    Date_Session DATE,
    Duration NUMBER(5, 2),
    TrainerName VARCHAR2(100),
    PerformanceScore NUMBER(5, 2),
    CONSTRAINT fk_ts_facility FOREIGN KEY (FacilityID) REFERENCES TrainingFacility(FacilityID),
    CONSTRAINT fk_tsession_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE TrainingSession IS 'Records details of training sessions conducted for drivers.';

CREATE TABLE MediaAppearance (
    MediaID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    Date_Media DATE,
    MediaType VARCHAR2(50),
    Channel VARCHAR2(100),
    Duration NUMBER(5, 2),
    EventName VARCHAR2(200),
    AudienceReachEstimate NUMBER,
    CONSTRAINT fk_media_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE MediaAppearance IS 'Logs driver media appearances and estimates their audience reach.';

CREATE TABLE RoleAssignment (
    RoleAssignmentID NUMBER PRIMARY KEY,
    MechanicID NUMBER NOT NULL,
    DriverID NUMBER NOT NULL,
    Role VARCHAR2(100),
    ShiftSchedule VARCHAR2(50),
    OilChange VARCHAR2(3),
    CONSTRAINT fk_ra_mechanic FOREIGN KEY (MechanicID) REFERENCES Mechanic(MechanicID),
    CONSTRAINT fk_rass_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE RoleAssignment IS 'Assigns roles and shifts to mechanics for specific drivers, including oil change duties.';

CREATE TABLE NutritionLog (
    NutritionID NUMBER PRIMARY KEY,
    DriverID NUMBER NOT NULL,
    RecordDate DATE NOT NULL,
    MealType VARCHAR2(50),
    Calories NUMBER(6,2),
    ProteinGrams NUMBER(6,2),
    HydrationLitres NUMBER(4,2),
    CONSTRAINT fk_nl_driver FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);
COMMENT ON TABLE NutritionLog IS 'Records daily nutrition and hydration intake for drivers.';
/

-- ============================================================================
-- Part 3: Bulk Data Insertion (DML - INSERT DATA)
-- Purpose: To insert a rich, coherent, and analytically valuable dataset.
-- ============================================================================
DECLARE
    -- Employee & Subtype IDs
    v_emp_lando_id NUMBER; v_driver_lando_id NUMBER;
    v_emp_oscar_id NUMBER; v_driver_oscar_id NUMBER;
    v_emp_andrea_id NUMBER; v_manager_andrea_id NUMBER;
    v_emp_rob_id NUMBER; v_manager_rob_id NUMBER;
    v_emp_gil_id NUMBER; v_manager_gil_id NUMBER;
    v_emp_david_id NUMBER; v_engineer_david_id NUMBER;
    v_emp_hiroshi_id NUMBER; v_engineer_hiroshi_id NUMBER;
    v_emp_kate_id NUMBER; v_engineer_kate_id NUMBER;
    v_emp_tom_id NUMBER; v_engineer_tom_id NUMBER;
    v_emp_josef_id NUMBER; v_engineer_josef_id NUMBER;
    v_emp_randy_id NUMBER; v_engineer_randy_id NUMBER;
    v_emp_megan_id NUMBER; v_engineer_megan_id NUMBER;
    v_emp_sara_id NUMBER; v_engineer_sara_id NUMBER; -- New Engineer
    v_emp_liam_id NUMBER; v_mechanic_liam_id NUMBER;
    v_emp_chloe_id NUMBER; v_mechanic_chloe_id NUMBER;
    v_emp_ben_id NUMBER; v_mechanic_ben_id NUMBER;
    v_emp_sofia_id NUMBER; v_mechanic_sofia_id NUMBER;
    v_emp_jack_id NUMBER; v_mechanic_jack_id NUMBER;
    v_emp_ollie_id NUMBER; v_mechanic_ollie_id NUMBER;
    v_emp_maria_id NUMBER; v_mechanic_maria_id NUMBER;
    v_emp_dave_id NUMBER; v_mechanic_dave_id NUMBER;
    v_emp_emma_id NUMBER; v_mechanic_emma_id NUMBER;
    v_emp_chris_id NUMBER; v_mechanic_chris_id NUMBER;
    v_emp_alex_id NUMBER; v_mechanic_alex_id NUMBER; -- New Mechanic

    -- Vehicle IDs
    v_vehicle_lando_id NUMBER;
    v_vehicle_oscar_id NUMBER;
    v_vehicle_spare_id NUMBER;
    v_vehicle_test_id NUMBER;

    -- Sponsor IDs
    v_sponsor_google_id NUMBER; v_sponsor_dell_id NUMBER;
    v_sponsor_okx_id NUMBER; v_sponsor_dpworld_id NUMBER;
    v_sponsor_cisco_id NUMBER; v_sponsor_unilever_id NUMBER;
    v_sponsor_bat_id NUMBER; v_sponsor_rm_id NUMBER;

    -- Facility IDs
    v_facility_mtc_sim_id NUMBER; v_facility_mtc_gym_id NUMBER;
    v_facility_wind_tunnel_id NUMBER; v_facility_jerez_id NUMBER;

    -- Wellbeing & Health IDs
    v_wb_lando1_id NUMBER; v_wb_lando2_id NUMBER; v_wb_lando3_id NUMBER; v_wb_lando4_id NUMBER;
    v_wb_oscar1_id NUMBER; v_wb_oscar2_id NUMBER; v_wb_oscar3_id NUMBER; v_wb_oscar4_id NUMBER;
    v_health_lando1_id NUMBER; v_health_oscar1_id NUMBER;
    v_health_lando2_id NUMBER; v_health_oscar2_id NUMBER;
    v_health_lando3_id NUMBER; v_health_oscar3_id NUMBER;
    v_health_lando4_id NUMBER; v_health_oscar4_id NUMBER;

    -- Circuit IDs
    v_circuit_bhr_id NUMBER;
    v_circuit_sau_id NUMBER;
    v_circuit_aus_id NUMBER;
    v_circuit_jpn_id NUMBER;
    v_circuit_chn_id NUMBER;
    v_circuit_mia_id NUMBER;
    v_circuit_imo_id NUMBER;
    v_circuit_mon_id NUMBER;
    v_circuit_can_id NUMBER;
    v_circuit_esp_id NUMBER;
    v_circuit_aut_id NUMBER;
    v_circuit_gbr_id NUMBER;
    v_circuit_hun_id NUMBER;

    -- Race, Assessment, Assignment IDs
    v_race_bhr_id NUMBER; v_assess_lando_bhr_id NUMBER; v_assess_oscar_bhr_id NUMBER; v_assign_lando_bhr_id NUMBER; v_assign_oscar_bhr_id NUMBER;
    v_race_sau_id NUMBER; v_assess_lando_sau_id NUMBER; v_assess_oscar_sau_id NUMBER; v_assign_lando_sau_id NUMBER; v_assign_oscar_sau_id NUMBER;
    v_race_aus_id NUMBER; v_assess_lando_aus_id NUMBER; v_assess_oscar_aus_id NUMBER; v_assign_lando_aus_id NUMBER; v_assign_oscar_aus_id NUMBER;
    v_race_jpn_id NUMBER; v_assess_lando_jpn_id NUMBER; v_assess_oscar_jpn_id NUMBER; v_assign_lando_jpn_id NUMBER; v_assign_oscar_jpn_id NUMBER;
    v_race_chn_id NUMBER; v_assess_lando_chn_id NUMBER; v_assess_oscar_chn_id NUMBER; v_assign_lando_chn_id NUMBER; v_assign_oscar_chn_id NUMBER;
    v_race_mia_id NUMBER; v_assess_lando_mia_id NUMBER; v_assess_oscar_mia_id NUMBER; v_assign_lando_mia_id NUMBER; v_assign_oscar_mia_id NUMBER;
    v_race_imo_id NUMBER; v_assess_lando_imo_id NUMBER; v_assess_oscar_imo_id NUMBER; v_assign_lando_imo_id NUMBER; v_assign_oscar_imo_id NUMBER;
    v_race_mon_id NUMBER; v_assess_lando_mon_id NUMBER; v_assess_oscar_mon_id NUMBER; v_assign_lando_mon_id NUMBER; v_assign_oscar_mon_id NUMBER;
    v_race_can_id NUMBER; v_assess_lando_can_id NUMBER; v_assess_oscar_can_id NUMBER; v_assign_lando_can_id NUMBER; v_assign_oscar_can_id NUMBER;
    v_race_esp_id NUMBER; v_assess_lando_esp_id NUMBER; v_assess_oscar_esp_id NUMBER; v_assign_lando_esp_id NUMBER; v_assign_oscar_esp_id NUMBER;
    v_race_aut_id NUMBER; v_assess_lando_aut_id NUMBER; v_assess_oscar_aut_id NUMBER; v_assign_lando_aut_id NUMBER; v_assign_oscar_aut_id NUMBER;
    v_race_gbr_id NUMBER; v_assess_lando_gbr_id NUMBER; v_assess_oscar_gbr_id NUMBER; v_assign_lando_gbr_id NUMBER; v_assign_oscar_gbr_id NUMBER;
    v_race_hun_id NUMBER; v_assess_lando_hun_id NUMBER; v_assess_oscar_hun_id NUMBER; v_assign_lando_hun_id NUMBER; v_assign_oscar_hun_id NUMBER;

BEGIN
    -- Enable DBMS_OUTPUT to display messages
    DBMS_OUTPUT.ENABLE(NULL);

    -- ========================================================================
    -- Stage 1: Standalone and Foundational Data
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('Inserting WellbeingLevels data...');
    INSERT INTO WellbeingLevel (WellbeingLevelID, LevelScoreMin, LevelScoreMax, Description) VALUES (wellbeing_level_seq.NEXTVAL, 90.0, 100.0, 'Excellent');
    INSERT INTO WellbeingLevel (WellbeingLevelID, LevelScoreMin, LevelScoreMax, Description) VALUES (wellbeing_level_seq.NEXTVAL, 80.0, 89.9, 'Very Good');
    INSERT INTO WellbeingLevel (WellbeingLevelID, LevelScoreMin, LevelScoreMax, Description) VALUES (wellbeing_level_seq.NEXTVAL, 60.0, 79.9, 'Good');
    INSERT INTO WellbeingLevel (WellbeingLevelID, LevelScoreMin, LevelScoreMax, Description) VALUES (wellbeing_level_seq.NEXTVAL, 40.0, 59.9, 'Fair');
    INSERT INTO WellbeingLevel (WellbeingLevelID, LevelScoreMin, LevelScoreMax, Description) VALUES (wellbeing_level_seq.NEXTVAL, 0.0, 39.9, 'Poor');

    DBMS_OUTPUT.PUT_LINE('Inserting TrainingFacilities data...');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'MTC Simulator Center', 'Woking, UK', 10, 'Dynisma Motion Sim') RETURNING FacilityID INTO v_facility_mtc_sim_id;
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'MTC Driver Performance Gym', 'Woking, UK', 25, 'G-Force Trainer, Cardio') RETURNING FacilityID INTO v_facility_mtc_gym_id;
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'MTC Wind Tunnel', 'Woking, UK', 15, 'Full-scale rolling road') RETURNING FacilityID INTO v_facility_wind_tunnel_id;
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Circuito de Jerez', 'Jerez, Spain', 50, 'Private Test Track') RETURNING FacilityID INTO v_facility_jerez_id;
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'MTC Media Center', 'Woking, UK', 30, 'Interview rooms, green screen');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Brand Centre', 'Mobile (at-track)', 100, 'Hospitality and meeting rooms');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'MTC Composites Lab', 'Woking, UK', 40, 'Carbon fibre manufacturing');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Mission Control', 'Woking, UK', 50, 'Live telemetry and strategy');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Silverstone Test Circuit', 'Silverstone, UK', 50, 'Filming Day Track');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Altus Performance', 'Perth, Australia', 15, 'Oscar Piastri Physio Center');
    INSERT INTO TrainingFacility (FacilityID, FacilityName, Location, Capacity, AvailableEquipment) VALUES (facility_seq.NEXTVAL, 'Mind-Body-Soul Clinic', 'Monaco', 10, 'Lando Norris Mental Coach');

    DBMS_OUTPUT.PUT_LINE('Inserting Sponsors data...');
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Google Chrome', 'Technology', 60000000, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_google_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Dell Technologies', 'Technology', 45000000, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_dell_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'OKX', 'Cryptocurrency', 55000000, TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2027-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_okx_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'DP World', 'Logistics', 25000000, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_dpworld_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Cisco', 'Networking', 30000000, TO_DATE('2022-02-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_cisco_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Unilever', 'Consumer Goods', 15000000, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_unilever_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'BAT (Vuse)', 'Tobacco', 40000000, TO_DATE('2019-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD')) RETURNING SponsorID INTO v_sponsor_bat_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Richard Mille', 'Luxury Goods', 18000000, TO_DATE('2017-01-01', 'YYYY-MM-DD'), NULL) RETURNING SponsorID INTO v_sponsor_rm_id;
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Splunk', 'Data Analytics', 22000000, TO_DATE('2020-02-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Hilton', 'Hospitality', 12000000, TO_DATE('2005-01-01', 'YYYY-MM-DD'), NULL);
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Coca-Cola', 'Beverages', 20000000, TO_DATE('2018-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));
    INSERT INTO Sponsor (SponsorID, SponsorName, Industry, ContractValue, StartDate, EndDate) VALUES (sponsor_seq.NEXTVAL, 'Darktrace', 'Cybersecurity', 18000000, TO_DATE('2021-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'));

    DBMS_OUTPUT.PUT_LINE('Inserting Circuit data...');
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Bahrain International Circuit', 'Bahrain', 'Sakhir', 5.412, 15, 14, 18, 'Asphalt', 'High', 'High-Speed') RETURNING CircuitID INTO v_circuit_bhr_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Jeddah Corniche Circuit', 'Saudi Arabia', 'Jeddah', 6.174, 27, 11, 5, 'Asphalt', 'Low', 'High-Speed') RETURNING CircuitID INTO v_circuit_sau_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Albert Park Circuit', 'Australia', 'Melbourne', 5.278, 14, 13, 8, 'Asphalt', 'Medium', 'Balanced') RETURNING CircuitID INTO v_circuit_aus_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Suzuka International Racing Course', 'Japan', 'Suzuka', 5.807, 18, 12, 40, 'Asphalt', 'High', 'Balanced') RETURNING CircuitID INTO v_circuit_jpn_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Shanghai International Circuit', 'China', 'Shanghai', 5.451, 16, 14, 11, 'Asphalt', 'Medium', 'Balanced') RETURNING CircuitID INTO v_circuit_chn_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Miami International Autodrome', 'USA', 'Miami Gardens', 5.412, 19, 12, 0, 'Asphalt', 'Low', 'High-Speed') RETURNING CircuitID INTO v_circuit_mia_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Autodromo Internazionale Enzo e Dino Ferrari', 'Italy', 'Imola', 4.909, 19, 11, 34, 'Asphalt', 'Medium', 'Technical') RETURNING CircuitID INTO v_circuit_imo_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Circuit de Monaco', 'Monaco', 'Monte Carlo', 3.337, 19, 10, 42, 'Street Asphalt', 'Low', 'Technical') RETURNING CircuitID INTO v_circuit_mon_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Circuit Gilles-Villeneuve', 'Canada', 'Montreal', 4.361, 14, 12, 6, 'Asphalt', 'Medium', 'High-Speed') RETURNING CircuitID INTO v_circuit_can_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Circuit de Barcelona-Catalunya', 'Spain', 'Montmeló', 4.657, 14, 12, 30, 'Asphalt', 'High', 'Balanced') RETURNING CircuitID INTO v_circuit_esp_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Red Bull Ring', 'Austria', 'Spielberg', 4.318, 10, 13, 65, 'Asphalt', 'Medium', 'High-Speed') RETURNING CircuitID INTO v_circuit_aut_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Silverstone Circuit', 'Great Britain', 'Silverstone', 5.891, 18, 15, 11, 'Asphalt', 'Medium', 'Balanced') RETURNING CircuitID INTO v_circuit_gbr_id;
    INSERT INTO Circuit (CircuitID, CircuitName, Country, Location, LengthKM, NumCorners, AvgWidthMeters, ElevationChangeMeters, SurfaceType, SurfaceRoughness, CharacteristicType) VALUES (circuit_seq.NEXTVAL, 'Hungaroring', 'Hungary', 'Mogyoród', 4.381, 14, 11, 36, 'Asphalt', 'Medium', 'Technical') RETURNING CircuitID INTO v_circuit_hun_id;

    DBMS_OUTPUT.PUT_LINE('Inserting Vehicles data...');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL39-01', 'Mercedes-AMG F1 M15', 798.0, 355.5, 0.2510, 'Active') RETURNING VehicleID INTO v_vehicle_lando_id;
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL39-02', 'Mercedes-AMG F1 M15', 798.5, 354.8, 0.2525, 'Active') RETURNING VehicleID INTO v_vehicle_oscar_id;
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL39-T1', 'Mercedes-AMG F1 M15', 799.0, 352.0, 0.2580, 'Spare') RETURNING VehicleID INTO v_vehicle_spare_id;
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL38-01', 'Mercedes-AMG F1 M14', 798.0, 350.0, 0.2650, 'Testing') RETURNING VehicleID INTO v_vehicle_test_id;
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL36-03', 'Mercedes-AMG F1 M13', 798.0, 345.0, 0.2800, 'Show Car');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MP4-4', 'Honda RA168E', 540.0, 312.0, 0.4500, 'Heritage');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MP4-23', 'Mercedes FO 108V', 605.0, 330.0, 0.3500, 'Heritage');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL35M-02', 'Mercedes-AMG F1 M12', 752.0, 348.0, NULL, 'Show Car');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL39-03', 'Mercedes-AMG F1 M15', 798.2, 355.0, 0.2515, 'In Build');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL39-04', 'Mercedes-AMG F1 M15', 798.3, 354.9, 0.2520, 'In Build');
    INSERT INTO Vehicle (VehicleID, ChassisNumber, EngineType, CarWeight, TopSpeed, AerodynamicsCO, Status) VALUES (vehicle_seq.NEXTVAL, 'MCL60-01', 'Mercedes-AMG F1 M14', 798.0, 352.0, 0.2600, 'Retired');

    -- ========================================================================
    -- Stage 2: Employee and Subtype Data (Expanded McLaren Team)
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('Inserting Employee and subtype data...');
    -- Managers
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Andrea', 'Stella', 'andrea.stella@mclaren.com', '100-001', TO_DATE('2015-02-01','YYYY-MM-DD'), TO_DATE('1971-02-22','YYYY-MM-DD'), 'Italian', 2500000, 'Manager') RETURNING EmployeeID INTO v_emp_andrea_id;
    INSERT INTO Manager (ManagerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, StrategicFocusArea) VALUES (manager_seq.NEXTVAL, v_emp_andrea_id, 'Team Principal', 'Exec Leadership', 'Full Time', 'Senior Management', 'Overall Team Performance') RETURNING ManagerID INTO v_manager_andrea_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Rob', 'Marshall', 'rob.marshall@mclaren.com', '100-002', TO_DATE('2024-01-02','YYYY-MM-DD'), TO_DATE('1968-06-03','YYYY-MM-DD'), 'British', 1800000, 'Manager') RETURNING EmployeeID INTO v_emp_rob_id;
    INSERT INTO Manager (ManagerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, StrategicFocusArea) VALUES (manager_seq.NEXTVAL, v_emp_rob_id, 'Chief Designer', 'MEng Masters', 'Full Time', 'Design and Engineering', 'Car Concept and Aero') RETURNING ManagerID INTO v_manager_rob_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Gil', 'de Ferran', 'gil.deferran@mclaren.com', '100-003', TO_DATE('2023-05-01','YYYY-MM-DD'), TO_DATE('1967-11-11','YYYY-MM-DD'), 'Brazilian', 1200000, 'Manager') RETURNING EmployeeID INTO v_emp_gil_id;
    INSERT INTO Manager (ManagerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, StrategicFocusArea) VALUES (manager_seq.NEXTVAL, v_emp_gil_id, 'Sporting Director', 'FIA Sporting License', 'Race Weekends',  'Race Strategy', 'Race Strategy and Logistics') RETURNING ManagerID INTO v_manager_gil_id;

    -- Engineers
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'David', 'Sanchez', 'david.sanchez@mclaren.com', '200-001', TO_DATE('2024-01-02','YYYY-MM-DD'), TO_DATE('1980-08-15','YYYY-MM-DD'), 'French', 1600000, 'Engineer') RETURNING EmployeeID INTO v_emp_david_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_david_id, 'Technical Director', 'PhD Aerodynamics', 'Flexible', 'Car Concept', 9.5) RETURNING EngineerID INTO v_engineer_david_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Hiroshi', 'Imai', 'hiroshi.imai@mclaren.com', '200-002', TO_DATE('2018-05-14','YYYY-MM-DD'), TO_DATE('1975-11-20','YYYY-MM-DD'), 'Japanese', 950000, 'Engineer') RETURNING EmployeeID INTO v_emp_hiroshi_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_hiroshi_id, 'Director, Race Engineering', 'Motorsport Eng.', 'Race Weekends', 'Race Operations', 9.2) RETURNING EngineerID INTO v_engineer_hiroshi_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Kate', 'Jones', 'kate.jones@mclaren.com', '200-003', TO_DATE('2021-09-01','YYYY-MM-DD'), TO_DATE('1992-04-10','YYYY-MM-DD'), 'British', 250000, 'Engineer') RETURNING EmployeeID INTO v_emp_kate_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_kate_id, 'Performance Engineer', 'Data Science MSc', 'Race Weekends', 'Car 81 Crew', 9.3) RETURNING EngineerID INTO v_engineer_kate_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Tom', 'Stallard', 'tom.stallard@mclaren.com', '200-004', TO_DATE('2017-03-10','YYYY-MM-DD'), TO_DATE('1978-08-11','YYYY-MM-DD'), 'British', 270000, 'Engineer') RETURNING EmployeeID INTO v_emp_tom_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_tom_id, 'Race Engineer', 'Cambridge Eng.', 'Race Weekends', 'Car 4 Crew', 9.8) RETURNING EngineerID INTO v_engineer_tom_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Josef', 'Newgarden', 'josef.newgarden@mclaren.com', '200-005', TO_DATE('2022-07-01','YYYY-MM-DD'), TO_DATE('1990-12-22','YYYY-MM-DD'), 'American', 260000, 'Engineer') RETURNING EmployeeID INTO v_emp_josef_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_josef_id, 'Race Engineer', 'Mechanical Eng.', 'Race Weekends', 'Car 81 Crew', 9.6) RETURNING EngineerID INTO v_engineer_josef_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Randy', 'Singh', 'randy.singh@mclaren.com', '200-006', TO_DATE('2016-01-15','YYYY-MM-DD'), TO_DATE('1985-02-18','YYYY-MM-DD'), 'Canadian', 350000, 'Engineer') RETURNING EmployeeID INTO v_emp_randy_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_randy_id, 'Head of Strategy', 'Game Theory Cert.', 'Flexible', 'Mission Control', 9.7) RETURNING EngineerID INTO v_engineer_randy_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Megan', 'Smith', 'megan.smith@mclaren.com', '200-007', TO_DATE('2020-03-01','YYYY-MM-DD'), TO_DATE('1993-10-01','YYYY-MM-DD'), 'Irish', 180000, 'Engineer') RETURNING EmployeeID INTO v_emp_megan_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_megan_id, 'Tire Performance', 'Chemical Eng.', 'Race Weekends', 'Race Operations', 9.4) RETURNING EngineerID INTO v_engineer_megan_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Sara', 'Fischer', 'sara.fischer@mclaren.com', '200-008', TO_DATE('2023-08-01','YYYY-MM-DD'), TO_DATE('1998-05-20','YYYY-MM-DD'), 'German', 120000, 'Engineer') RETURNING EmployeeID INTO v_emp_sara_id;
    INSERT INTO Engineer (EngineerID, EmployeeID, Specialisation, Certification, ShiftSchedule, TeamAssigned, PerformanceReviewScore) VALUES (engineer_seq.NEXTVAL, v_emp_sara_id, 'Junior Data Engineer', 'Computer Science BSc', 'Flexible', 'Mission Control', 8.9) RETURNING EngineerID INTO v_engineer_sara_id;

    -- Mechanics
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Liam', 'Parker', 'liam.parker@mclaren.com', '300-001', TO_DATE('2019-06-01','YYYY-MM-DD'), TO_DATE('1990-01-25','YYYY-MM-DD'), 'New Zealander', 120000, 'Mechanic') RETURNING EmployeeID INTO v_emp_liam_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_liam_id, 'Chief Mechanic L4', 6, 'Car 4 Crew') RETURNING MechanicID INTO v_mechanic_liam_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Chloe', 'Dubois', 'chloe.dubois@mclaren.com', '300-002', TO_DATE('2022-02-10','YYYY-MM-DD'), TO_DATE('1995-07-19','YYYY-MM-DD'), 'French', 95000, 'Mechanic') RETURNING EmployeeID INTO v_emp_chloe_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_chloe_id, 'Gearbox Specialist L3', 3, 'Car 81 Crew') RETURNING MechanicID INTO v_mechanic_chloe_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Ben', 'Carter', 'ben.carter@mclaren.com', '300-003', TO_DATE('2020-08-15','YYYY-MM-DD'), TO_DATE('1993-03-12','YYYY-MM-DD'), 'Australian', 110000, 'Mechanic') RETURNING EmployeeID INTO v_emp_ben_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_ben_id, 'Front End L3', 5, 'Car 81 Crew') RETURNING MechanicID INTO v_mechanic_ben_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Sofia', 'Rossi', 'sofia.rossi@mclaren.com', '300-004', TO_DATE('2021-04-01','YYYY-MM-DD'), TO_DATE('1996-09-05','YYYY-MM-DD'), 'Italian', 105000, 'Mechanic') RETURNING EmployeeID INTO v_emp_sofia_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_sofia_id, 'Hydraulics L2', 4, 'Car 4 Crew') RETURNING MechanicID INTO v_mechanic_sofia_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Jack', 'Williams', 'jack.williams@mclaren.com', '300-005', TO_DATE('2018-11-01','YYYY-MM-DD'), TO_DATE('1991-05-30','YYYY-MM-DD'), 'British', 98000, 'Mechanic') RETURNING EmployeeID INTO v_emp_jack_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_jack_id, 'Front Jack', 7, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_jack_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Ollie', 'Brown', 'ollie.brown@mclaren.com', '300-006', TO_DATE('2023-01-20','YYYY-MM-DD'), TO_DATE('1998-02-14','YYYY-MM-DD'), 'British', 85000, 'Mechanic') RETURNING EmployeeID INTO v_emp_ollie_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_ollie_id, 'Rear Jack', 2, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_ollie_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Maria', 'Garcia', 'maria.garcia@mclaren.com', '300-007', TO_DATE('2022-05-10','YYYY-MM-DD'), TO_DATE('1997-12-01','YYYY-MM-DD'), 'Spanish', 92000, 'Mechanic') RETURNING EmployeeID INTO v_emp_maria_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_maria_id, 'Tire Gunner (FL)', 3, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_maria_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Dave', 'Johnson', 'dave.johnson@mclaren.com', '300-008', TO_DATE('2017-09-01','YYYY-MM-DD'), TO_DATE('1989-11-15','YYYY-MM-DD'), 'American', 99000, 'Mechanic') RETURNING EmployeeID INTO v_emp_dave_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_dave_id, 'Tire Gunner (FR)', 8, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_dave_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Emma', 'Wilson', 'emma.wilson@mclaren.com', '300-009', TO_DATE('2023-03-01','YYYY-MM-DD'), TO_DATE('1999-06-20','YYYY-MM-DD'), 'British', 88000, 'Mechanic') RETURNING EmployeeID INTO v_emp_emma_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_emma_id, 'Tire Gunner (RL)', 2, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_emma_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Chris', 'Taylor', 'chris.taylor@mclaren.com', '300-010', TO_DATE('2021-01-01','YYYY-MM-DD'), TO_DATE('1994-04-04','YYYY-MM-DD'), 'British', 90000, 'Mechanic') RETURNING EmployeeID INTO v_emp_chris_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_chris_id, 'Tire Gunner (RR)', 4, 'Pit Crew') RETURNING MechanicID INTO v_mechanic_chris_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Alex', 'Miller', 'alex.miller@mclaren.com', '300-011', TO_DATE('2024-02-01','YYYY-MM-DD'), TO_DATE('2000-01-10','YYYY-MM-DD'), 'Canadian', 82000, 'Mechanic') RETURNING EmployeeID INTO v_emp_alex_id;
    INSERT INTO Mechanic (MechanicID, EmployeeID, Certification, YearsInTeam, TeamAssigned) VALUES (mechanic_seq.NEXTVAL, v_emp_alex_id, 'Junior Mechanic L1', 1, 'Car 4 Crew') RETURNING MechanicID INTO v_mechanic_alex_id;

    -- Drivers
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Lando', 'Norris', 'lando.norris@mclaren.com', '004-004', TO_DATE('2019-03-15','YYYY-MM-DD'), TO_DATE('1999-11-13','YYYY-MM-DD'), 'British', 25000000, 'Driver') RETURNING EmployeeID INTO v_emp_lando_id;
    INSERT INTO Employee (EmployeeID, FirstName, LastName, Email, PhoneNumber, HireDate, DOB, Nationality, Salary, Empl_Type) VALUES (employee_seq.NEXTVAL, 'Oscar', 'Piastri', 'oscar.piastri@mclaren.com', '081-081', TO_DATE('2023-03-01','YYYY-MM-DD'), TO_DATE('2001-04-06','YYYY-MM-DD'), 'Australian', 10000000, 'Driver') RETURNING EmployeeID INTO v_emp_oscar_id;

    -- DriverWellbeing records
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 4, 6, 95, TO_DATE('2025-02-15','YYYY-MM-DD'), 98.5, 8.8, 92.5) RETURNING DriverWellbeingID INTO v_wb_lando1_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 4, 6, 96, TO_DATE('2025-05-20','YYYY-MM-DD'), 95.0, 7.5, 88.0) RETURNING DriverWellbeingID INTO v_wb_lando2_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 3, 6, 97, TO_DATE('2025-07-25','YYYY-MM-DD'), 99.0, 9.2, 95.0) RETURNING DriverWellbeingID INTO v_wb_lando3_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 3, 6, 97, TO_DATE('2025-08-05','YYYY-MM-DD'), 98.8, 9.0, 94.5) RETURNING DriverWellbeingID INTO v_wb_lando4_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 8, 2, 92, TO_DATE('2025-02-16','YYYY-MM-DD'), 99.2, 9.1, 94.0) RETURNING DriverWellbeingID INTO v_wb_oscar1_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 6, 2, 94, TO_DATE('2025-05-21','YYYY-MM-DD'), 97.8, 8.5, 91.5) RETURNING DriverWellbeingID INTO v_wb_oscar2_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 5, 2, 95, TO_DATE('2025-07-26','YYYY-MM-DD'), 98.5, 9.0, 93.0) RETURNING DriverWellbeingID INTO v_wb_oscar3_id;
    INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 5, 2, 96, TO_DATE('2025-08-06','YYYY-MM-DD'), 99.5, 9.5, 96.0) RETURNING DriverWellbeingID INTO v_wb_oscar4_id;
    FOR i IN 1..7 LOOP
        INSERT INTO DriverWellbeing (DriverWellbeingID, DriverRanking, ExperienceYears, SkillLevel, AssessmentDate, FitnessScore, SleepQualityScore, RecoveryRate) VALUES (wellbeing_seq.NEXTVAL, 10+i, 1, 80+i, TO_DATE('2025-01-01','YYYY-MM-DD')+i*15, 90+i*0.5, 8.0 - i*0.2, 85.0 + i);
    END LOOP;

    -- Link employees to Driver subtype
    INSERT INTO Driver (DriverID, EmployeeID, DriverWellbeingID, LicenseNumber, RaceNumber, ExperienceYears) VALUES (driver_seq.NEXTVAL, v_emp_lando_id, v_wb_lando1_id, 'LN4-2019', 4, 6) RETURNING DriverID INTO v_driver_lando_id;
    INSERT INTO Driver (DriverID, EmployeeID, DriverWellbeingID, LicenseNumber, RaceNumber, ExperienceYears) VALUES (driver_seq.NEXTVAL, v_emp_oscar_id, v_wb_oscar1_id, 'OP81-2023', 81, 2) RETURNING DriverID INTO v_driver_oscar_id;

    -- ========================================================================
    -- Stage 3: Contracts, Assignments, and Logs
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('Inserting contracts, assignments, and log data...');
    -- Employee Contracts
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_lando_id, TO_DATE('2024-01-26', 'YYYY-MM-DD'), TO_DATE('2028-12-31', 'YYYY-MM-DD'), 'Driver', 'Multi-year extension', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_oscar_id, TO_DATE('2023-09-20', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 'Driver', 'Initial extension', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_andrea_id, TO_DATE('2023-01-12', 'YYYY-MM-DD'), NULL, 'Managerial', 'Team Principal contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_rob_id, TO_DATE('2024-01-02', 'YYYY-MM-DD'), NULL, 'Managerial', 'Chief Designer contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_david_id, TO_DATE('2024-01-02', 'YYYY-MM-DD'), NULL, 'Engineering', 'Technical Director contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_tom_id, TO_DATE('2017-03-10', 'YYYY-MM-DD'), NULL, 'Engineering', 'Race Engineer contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_liam_id, TO_DATE('2019-06-01', 'YYYY-MM-DD'), NULL, 'Mechanic', 'Chief Mechanic contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_ben_id, TO_DATE('2020-08-15', 'YYYY-MM-DD'), NULL, 'Mechanic', 'Mechanic contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_randy_id, TO_DATE('2016-01-15', 'YYYY-MM-DD'), NULL, 'Engineering', 'Head of Strategy contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_jack_id, TO_DATE('2018-11-01', 'YYYY-MM-DD'), NULL, 'Mechanic', 'Pit Crew contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_maria_id, TO_DATE('2022-05-10', 'YYYY-MM-DD'), NULL, 'Mechanic', 'Pit Crew contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_alex_id, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 'Mechanic', 'Junior Mechanic contract', 'Active');
    INSERT INTO Contract (ContractID, EmployeeID, StartDate, EndDate, ContractType, ContractDetails, Status) VALUES (contract_seq.NEXTVAL, v_emp_sara_id, TO_DATE('2023-08-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 'Engineering', 'Junior Engineer contract', 'Active');

    -- Sponsorship Contracts
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_google_id, v_driver_lando_id, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 'Helmet and suit branding', 15000000, '3 social media posts per quarter, 2 event appearances per year.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_okx_id, v_driver_oscar_id, TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2027-12-31', 'YYYY-MM-DD'), 'Sidepod and merchandise branding', 20000000, 'Primary branding on team kit, participation in crypto-related media events.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_dell_id, NULL, TO_DATE('2022-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 'IT hardware and infrastructure partner', 10000000, 'Use of Dell equipment during media appearances, "Powered by Dell" logo in garage setup.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_cisco_id, NULL, TO_DATE('2022-02-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 'Official networking partner', 8000000, 'Provides network infrastructure between track and factory.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_bat_id, NULL, TO_DATE('2019-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 'Vuse brand promotion', 40000000, 'Brand promotion activities in permitted markets.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_rm_id, v_driver_lando_id, TO_DATE('2017-01-01', 'YYYY-MM-DD'), NULL, 'Official watch partner', 5000000, 'Driver to wear designated watch at public appearances.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_rm_id, v_driver_oscar_id, TO_DATE('2023-03-01', 'YYYY-MM-DD'), NULL, 'Official watch partner', 3000000, 'Driver to wear designated watch at public appearances.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_dpworld_id, NULL, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 'Logistics partner', 12000000, 'Global logistics and freight services.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_unilever_id, NULL, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 'Personal care partner', 7500000, 'Co-branding on products, supply of personal care items to team.');
    INSERT INTO SponsorshipContract (ContractID, SponsorID, DriverID, ContractStartDate, ContractEndDate, ContractDetails, AnnualPaymentAmount, MarketingDeliverables) VALUES (sponsorship_contract_seq.NEXTVAL, v_sponsor_google_id, NULL, TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 'Official Partner, Android and Chrome', 25000000, 'Display of Android and Chrome branding on car and driver suits.');

    -- Vehicle Assignments
    INSERT INTO VehicleAssignment (VehicleAssignmentID, VehicleID, DriverID, StartDate, EndDate) VALUES (vehicle_assignment_seq.NEXTVAL, v_vehicle_lando_id, v_driver_lando_id, TO_DATE('2025-02-01', 'YYYY-MM-DD'), NULL);
    INSERT INTO VehicleAssignment (VehicleAssignmentID, VehicleID, DriverID, StartDate, EndDate) VALUES (vehicle_assignment_seq.NEXTVAL, v_vehicle_oscar_id, v_driver_oscar_id, TO_DATE('2025-02-01', 'YYYY-MM-DD'), NULL);
    FOR i IN 1..9 LOOP
        INSERT INTO VehicleAssignment (VehicleAssignmentID, VehicleID, DriverID, StartDate, EndDate) VALUES (vehicle_assignment_seq.NEXTVAL, v_vehicle_spare_id, v_driver_lando_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*5, TO_DATE('2025-01-01','YYYY-MM-DD')+i*5+2);
    END LOOP;

    -- Repair Logs (Narrative Core)
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_lando_id, TO_DATE('2025-03-03','YYYY-MM-DD'), 'Yes', 'Front Wing Endplate', 'Damage from minor collision during Bahrain GP.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_chloe_id, v_vehicle_oscar_id, TO_DATE('2025-03-20','YYYY-MM-DD'), 'Yes', 'Brake Discs', 'Routine replacement before Australian GP to ensure braking performance.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_lando_id, TO_DATE('2025-03-10','YYYY-MM-DD'), 'Yes', 'Full chassis inspection', 'Comprehensive check after DNF in Saudi Arabia.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_sofia_id, v_vehicle_lando_id, TO_DATE('2025-04-07','YYYY-MM-DD'), 'Yes', 'Radiator Sidepod', 'Hit by track debris during Japanese GP.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_ben_id, v_vehicle_oscar_id, TO_DATE('2025-05-15','YYYY-MM-DD'), 'No', 'Gearbox Sensor', 'Intermittent sensor issue, still under investigation.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_lando_id, TO_DATE('2025-05-26','YYYY-MM-DD'), 'Yes', 'Rear Suspension', 'Brushed the wall during Monaco qualifying.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_chloe_id, v_vehicle_oscar_id, TO_DATE('2025-06-10','YYYY-MM-DD'), 'Yes', 'Floor Stay', 'Upgraded floor stay for improved stability.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_test_id, TO_DATE('2025-06-20','YYYY-MM-DD'), 'Yes', 'Power Unit', 'Engine change after reaching mileage limit.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_ben_id, v_vehicle_oscar_id, TO_DATE('2025-07-01','YYYY-MM-DD'), 'Yes', 'Full Gearbox', 'End-of-life gearbox change.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_sofia_id, v_vehicle_lando_id, TO_DATE('2025-07-05','YYYY-MM-DD'), 'Yes', 'Hydraulic Pump', 'Precautionary replacement.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_spare_id, TO_DATE('2025-07-15','YYYY-MM-DD'), 'Yes', 'Full rebuild', 'Preparing spare chassis for second half of the season.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_chloe_id, v_vehicle_lando_id, TO_DATE('2025-07-28','YYYY-MM-DD'), 'No', 'ERS Battery', 'Battery cell fault detected, under investigation.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_lando_id, TO_DATE('2025-06-09','YYYY-MM-DD'), 'Yes', 'Floor Damage', 'Floor damaged from running over kerbs in wet Canadian GP.');
    INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_ben_id, v_vehicle_oscar_id, TO_DATE('2025-06-15','YYYY-MM-DD'), 'Yes', 'Gearbox Sensor', 'Replaced faulty gearbox sensor identified in May.');
    FOR i IN 1..5 LOOP -- Add extra routine checks for Oscar's car
        INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_ben_id, v_vehicle_oscar_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*10, 'Yes', 'Brake Pads', 'Routine check '||i);
    END LOOP;
    FOR i IN 1..3 LOOP -- Add extra performance checks for Lando's car
        INSERT INTO RepairLog (RepairID, MechanicID, VehicleID, RepairDate, IssueResolved, PartsReplaced, RepairDescription) VALUES (repair_log_seq.NEXTVAL, v_mechanic_liam_id, v_vehicle_lando_id, TO_DATE('2025-01-05','YYYY-MM-DD')+i*20, 'Yes', 'Aerodynamic element', 'Performance optimisation '||i);
    END LOOP;

    -- Role Assignments
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_jack_id, v_driver_lando_id, 'Front Jack', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_ollie_id, v_driver_lando_id, 'Rear Jack', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_maria_id, v_driver_lando_id, 'Front Left Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_dave_id, v_driver_lando_id, 'Front Right Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_emma_id, v_driver_lando_id, 'Rear Left Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_chris_id, v_driver_lando_id, 'Rear Right Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_jack_id, v_driver_oscar_id, 'Front Jack', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_ollie_id, v_driver_oscar_id, 'Rear Jack', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_maria_id, v_driver_oscar_id, 'Front Left Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_dave_id, v_driver_oscar_id, 'Front Right Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_emma_id, v_driver_oscar_id, 'Rear Left Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_chris_id, v_driver_oscar_id, 'Rear Right Tire', 'Race Day', 'No');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_liam_id, v_driver_lando_id, 'Car Chief', 'Race Day', 'Yes');
    INSERT INTO RoleAssignment (RoleAssignmentID, MechanicID, DriverID, Role, ShiftSchedule, OilChange) VALUES (role_assignment_seq.NEXTVAL, v_mechanic_chloe_id, v_driver_oscar_id, 'Car Chief', 'Race Day', 'Yes');

    -- ========================================================================
    -- Stage 4: Race-Specific Data (Expanded to 13 Races)
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('Inserting race-specific data (13 races)...');

    -- Race 1: Bahrain
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Sakhir', 'Yes', 3.0, 0.185, TO_DATE('2025-02-28','YYYY-MM-DD'), 0.25, 3) RETURNING DriverAssessmentID INTO v_assess_lando_bhr_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Sakhir', 'Yes', 3.0, 0.190, TO_DATE('2025-02-28','YYYY-MM-DD'), 0.21, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_bhr_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_bhr_id, v_circuit_bhr_id, 'Bahrain Grand Prix', TO_DATE('2025-03-02','YYYY-MM-DD'), 'Bahrain', 20, 'Clear, Windy') RETURNING RaceID INTO v_race_bhr_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_bhr_id, v_driver_lando_id, 2, 2, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_bhr_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_bhr_id, v_driver_oscar_id, 5, 5, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_bhr_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_bhr_id, 5235.1, 3, 4, 2, 0.12, 94.5);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_bhr_id, 5248.9, 5, 1, 2, 0.11, 96.2);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_bhr_id, v_manager_andrea_id, v_driver_lando_id, v_race_bhr_id, 2, 'S-H-S', 'Aggressive', 'Push hard in first stint', 'Optimal', 2);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_bhr_id, v_manager_andrea_id, v_driver_oscar_id, v_race_bhr_id, 2, 'S-H-S', 'Balanced', 'Focus on tire management', 'Optimal', 2);
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_bhr_id, 15, 22.1, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_bhr_id, 37, 21.8, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_bhr_id, 16, 22.5, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_bhr_id, 38, 22.3, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO Telemetry (TelemetryID, DriverID, RaceID, "Timestamp", TopSpeed, BrakeUsage, GearShifts, FuelUsage, GForce, Duration, EngineRPM, ThrottlePosition, TyreTemperatureFL, TyreTemperatureFR, TyreTemperatureRL, TyreTemperatureRR) VALUES (telemetry_seq.NEXTVAL, v_driver_lando_id, v_race_bhr_id, TO_DATE('2025-03-02 16:30:00', 'YYYY-MM-DD HH24:MI:SS'), 320.5, 85.2, 310, 2.5, 4.5, 92.1, 11500, 100, 105.5, 106.1, 95.3, 96.0);
    INSERT INTO Telemetry (TelemetryID, DriverID, RaceID, "Timestamp", TopSpeed, BrakeUsage, GearShifts, FuelUsage, GForce, Duration, EngineRPM, ThrottlePosition, TyreTemperatureFL, TyreTemperatureFR, TyreTemperatureRL, TyreTemperatureRR) VALUES (telemetry_seq.NEXTVAL, v_driver_oscar_id, v_race_bhr_id, TO_DATE('2025-03-02 16:31:00', 'YYYY-MM-DD HH24:MI:SS'), 318.0, 80.1, 305, 2.4, 4.2, 93.4, 11450, 100, 104.9, 105.5, 95.1, 95.8);

    -- Race 2: Saudi Arabia - Lando DNF
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Jeddah', 'Yes', 3.5, 0.180, TO_DATE('2025-03-07','YYYY-MM-DD'), 0.45, 5) RETURNING DriverAssessmentID INTO v_assess_lando_sau_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Jeddah', 'Yes', 3.5, 0.188, TO_DATE('2025-03-07','YYYY-MM-DD'), 0.33, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_sau_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_sau_id, v_circuit_sau_id, 'Saudi Arabian Grand Prix', TO_DATE('2025-03-09','YYYY-MM-DD'), 'Saudi Arabia', 20, 'Night Race') RETURNING RaceID INTO v_race_sau_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_sau_id, v_driver_lando_id, 4, 4, 'Yes', 'Yes') RETURNING RaceAssignmentID INTO v_assign_lando_sau_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_sau_id, v_driver_oscar_id, 6, 6, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_sau_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_sau_id, NULL, 18, 2, 1, 0.15, 90.1);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_sau_id, 5110.4, 4, 3, 1, 0.10, 97.5);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_sau_id, v_manager_andrea_id, v_driver_lando_id, v_race_sau_id, 1, 'M-H', 'Standard', 'Over-aggressive driving led to collision and retirement', 'Compromised', 1);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_sau_id, v_manager_andrea_id, v_driver_oscar_id, v_race_sau_id, 1, 'M-H', 'Standard', 'Capitalized on Safety Car, excellent performance', 'Optimal', 1);
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_sau_id, 10, 22.0, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO Telemetry (TelemetryID, DriverID, RaceID, "Timestamp", TopSpeed, BrakeUsage, GearShifts, FuelUsage, GForce, Duration, EngineRPM, ThrottlePosition, TyreTemperatureFL, TyreTemperatureFR, TyreTemperatureRL, TyreTemperatureRR) VALUES (telemetry_seq.NEXTVAL, v_driver_lando_id, v_race_sau_id, TO_DATE('2025-03-09 19:30:00', 'YYYY-MM-DD HH24:MI:SS'), 330.1, 90.5, 350, 2.8, 5.1, 88.1, 11950, 100, 109.8, 110.5, 100.2, 100.9);
    INSERT INTO Telemetry (TelemetryID, DriverID, RaceID, "Timestamp", TopSpeed, BrakeUsage, GearShifts, FuelUsage, GForce, Duration, EngineRPM, ThrottlePosition, TyreTemperatureFL, TyreTemperatureFR, TyreTemperatureRL, TyreTemperatureRR) VALUES (telemetry_seq.NEXTVAL, v_driver_oscar_id, v_race_sau_id, TO_DATE('2025-03-09 19:35:00', 'YYYY-MM-DD HH24:MI:SS'), 325.0, 87.0, 330, 2.6, 4.9, 89.4, 11850, 100, 108.2, 108.9, 99.5, 100.1);

    -- Race 3: Australia - Oscar podium
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Albert Park', 'Yes', 2.5, 0.187, TO_DATE('2025-03-21','YYYY-MM-DD'), 0.31, 2) RETURNING DriverAssessmentID INTO v_assess_lando_aus_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Albert Park', 'Yes', 2.5, 0.189, TO_DATE('2025-03-21','YYYY-MM-DD'), 0.24, 1) RETURNING DriverAssessmentID INTO v_assess_oscar_aus_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_aus_id, v_circuit_aus_id, 'Australian Grand Prix', TO_DATE('2025-03-23','YYYY-MM-DD'), 'Australia', 20, 'Overcast') RETURNING RaceID INTO v_race_aus_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_aus_id, v_driver_lando_id, 3, 3, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_aus_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_aus_id, v_driver_oscar_id, 4, 4, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_aus_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_aus_id, 5301.7, 5, 2, 2, 0.18, 88.7);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_aus_id, 5289.1, 2, 3, 2, 0.12, 95.3);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_aus_id, v_manager_andrea_id, v_driver_lando_id, v_race_aus_id, 2, 'M-H-S', 'Standard', 'Struggled with tire degradation', 'Sub-optimal', 2);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_aus_id, v_manager_andrea_id, v_driver_oscar_id, v_race_aus_id, 2, 'M-H-H', 'Aggressive', 'Team order position swap on lap 29', 'Optimal', 2);
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_aus_id, 18, 22.3, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_aus_id, 40, 22.0, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_aus_id, 19, 21.9, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_aus_id, 41, 22.1, 'Yes', 0, 'Tires only', 'Completed');

    -- Race 4: Japan - Lando pole position
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Suzuka', 'Yes', 4.0, 0.182, TO_DATE('2025-04-04','YYYY-MM-DD'), 0.28, 1) RETURNING DriverAssessmentID INTO v_assess_lando_jpn_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Suzuka', 'Yes', 4.0, 0.185, TO_DATE('2025-04-04','YYYY-MM-DD'), 0.30, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_jpn_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_jpn_id, v_circuit_jpn_id, 'Japanese Grand Prix', TO_DATE('2025-04-06','YYYY-MM-DD'), 'Japan', 20, 'Light Rain') RETURNING RaceID INTO v_race_jpn_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_jpn_id, v_driver_lando_id, 1, 1, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_jpn_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_jpn_id, v_driver_oscar_id, 3, 3, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_jpn_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_jpn_id, 5455.9, 2, 0, 3, 0.14, 93.8);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_jpn_id, 5472.3, 4, 1, 3, 0.13, 94.5);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_jpn_id, v_manager_andrea_id, v_driver_lando_id, v_race_jpn_id, 3, 'I-W-I-S', 'Aggressive', 'Early switch to inters, then slicks', 'Optimal', 3);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_jpn_id, v_manager_andrea_id, v_driver_oscar_id, v_race_jpn_id, 3, 'I-W-I-S', 'Balanced', 'Followed Lando''s strategy, good pace', 'Optimal', 3);

    -- Race 5: China
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Shanghai', 'Yes', 3.0, 0.183, TO_DATE('2025-04-18','YYYY-MM-DD'), 0.35, 4) RETURNING DriverAssessmentID INTO v_assess_lando_chn_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Shanghai', 'Yes', 3.0, 0.191, TO_DATE('2025-04-18','YYYY-MM-DD'), 0.38, 4) RETURNING DriverAssessmentID INTO v_assess_oscar_chn_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_chn_id, v_circuit_chn_id, 'Chinese Grand Prix', TO_DATE('2025-04-20','YYYY-MM-DD'), 'China', 20, 'Mixed') RETURNING RaceID INTO v_race_chn_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_chn_id, v_driver_lando_id, 5, 5, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_chn_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_chn_id, v_driver_oscar_id, 7, 7, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_chn_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_chn_id, 5390.1, 4, 5, 2, 0.16, 91.2);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_chn_id, 5405.6, 8, 2, 2, 0.14, 92.8);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_chn_id, v_manager_andrea_id, v_driver_lando_id, v_race_chn_id, 2, 'M-H-M', 'Standard', 'Aggressive strategy yielded overtakes', 'Sub-optimal', 2);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_chn_id, v_manager_andrea_id, v_driver_oscar_id, v_race_chn_id, 2, 'M-H-H', 'Balanced', 'Consistent pace but lost out in traffic', 'Sub-optimal', 2);

    -- Race 6: Miami - Lando's first win!
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Miami', 'Yes', 2.0, 0.178, TO_DATE('2025-05-02','YYYY-MM-DD'), 0.18, 1) RETURNING DriverAssessmentID INTO v_assess_lando_mia_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Miami', 'Yes', 2.0, 0.185, TO_DATE('2025-05-02','YYYY-MM-DD'), 0.29, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_mia_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_mia_id, v_circuit_mia_id, 'Miami Grand Prix', TO_DATE('2025-05-04','YYYY-MM-DD'), 'USA', 20, 'Hot, Humid') RETURNING RaceID INTO v_race_mia_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_mia_id, v_driver_lando_id, 1, 1, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_mia_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_mia_id, v_driver_oscar_id, 4, 4, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_mia_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_mia_id, 5201.5, 1, 2, 1, 0.08, 98.5);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_mia_id, 5245.2, 6, 0, 1, 0.10, 95.0);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_mia_id, v_manager_andrea_id, v_driver_lando_id, v_race_mia_id, 1, 'M-H', 'Standard', 'Perfect strategy call under Safety Car', 'Optimal', 1);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_mia_id, v_manager_andrea_id, v_driver_oscar_id, v_race_mia_id, 1, 'M-H', 'Standard', 'Solid race, but lost out on timing of pit stop', 'Sub-optimal', 1);
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_mia_id, 28, 21.0500, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_mia_id, 29, 22.0120, 'Yes', 0, 'Tires only', 'Completed');

    -- Race 7: Imola
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Imola', 'Yes', 3.0, 0.180, TO_DATE('2025-05-16','YYYY-MM-DD'), 0.22, 1) RETURNING DriverAssessmentID INTO v_assess_lando_imo_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Imola', 'Yes', 3.0, 0.187, TO_DATE('2025-05-16','YYYY-MM-DD'), 0.25, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_imo_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_imo_id, v_circuit_imo_id, 'Emilia Romagna GP', TO_DATE('2025-05-18','YYYY-MM-DD'), 'Italy', 20, 'Sunny') RETURNING RaceID INTO v_race_imo_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_imo_id, v_driver_lando_id, 3, 3, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_imo_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_imo_id, v_driver_oscar_id, 2, 2, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_imo_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_imo_id, 5155.8, 2, 1, 1, 0.09, 99.1);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_imo_id, 5170.1, 4, 0, 1, 0.11, 96.4);

    -- Race 8: Monaco
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Monaco', 'Yes', 2.0, 0.190, TO_DATE('2025-05-23','YYYY-MM-DD'), 0.40, 3) RETURNING DriverAssessmentID INTO v_assess_lando_mon_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Monaco', 'Yes', 2.0, 0.192, TO_DATE('2025-05-23','YYYY-MM-DD'), 0.35, 1) RETURNING DriverAssessmentID INTO v_assess_oscar_mon_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_mon_id, v_circuit_mon_id, 'Monaco Grand Prix', TO_DATE('2025-05-25','YYYY-MM-DD'), 'Monaco', 20, 'Sunny') RETURNING RaceID INTO v_race_mon_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_mon_id, v_driver_lando_id, 2, 2, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_mon_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_mon_id, v_driver_oscar_id, 5, 5, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_mon_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_mon_id, 6122.4, 2, 0, 1, 0.05, 97.2);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_mon_id, 6150.8, 5, 0, 1, 0.04, 98.1);

    -- Race 9: Canada
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Montreal', 'Yes', 3.5, 0.179, TO_DATE('2025-06-06','YYYY-MM-DD'), 0.33, 3) RETURNING DriverAssessmentID INTO v_assess_lando_can_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Montreal', 'Yes', 3.5, 0.186, TO_DATE('2025-06-06','YYYY-MM-DD'), 0.29, 2) RETURNING DriverAssessmentID INTO v_assess_oscar_can_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_can_id, v_circuit_can_id, 'Canadian Grand Prix', TO_DATE('2025-06-08','YYYY-MM-DD'), 'Canada', 20, 'Wet to Dry') RETURNING RaceID INTO v_race_can_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_can_id, v_driver_lando_id, 3, 3, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_can_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_can_id, v_driver_oscar_id, 8, 8, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_can_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_can_id, 7230.5, 2, 8, 4, 0.19, 90.5);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_can_id, 7255.1, 5, 6, 4, 0.15, 93.3);

    -- Race 10: Spain
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Barcelona', 'Yes', 2.5, 0.181, TO_DATE('2025-06-20','YYYY-MM-DD'), 0.26, 2) RETURNING DriverAssessmentID INTO v_assess_lando_esp_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Barcelona', 'Yes', 2.5, 0.188, TO_DATE('2025-06-20','YYYY-MM-DD'), 0.22, 1) RETURNING DriverAssessmentID INTO v_assess_oscar_esp_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_esp_id, v_circuit_esp_id, 'Spanish Grand Prix', TO_DATE('2025-06-22','YYYY-MM-DD'), 'Spain', 20, 'Hot, Sunny') RETURNING RaceID INTO v_race_esp_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_esp_id, v_driver_lando_id, 1, 1, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_esp_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_esp_id, v_driver_oscar_id, 6, 6, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_esp_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_esp_id, 5140.9, 2, 1, 2, 0.22, 85.6);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_esp_id, 5180.2, 7, 1, 2, 0.18, 90.1);

    -- Race 11: Austria - Oscar podium
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Red Bull Ring', 'Yes', 2.0, 0.177, TO_DATE('2025-06-27','YYYY-MM-DD'), 0.19, 1) RETURNING DriverAssessmentID INTO v_assess_lando_aut_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Red Bull Ring', 'Yes', 2.0, 0.182, TO_DATE('2025-06-27','YYYY-MM-DD'), 0.15, 0) RETURNING DriverAssessmentID INTO v_assess_oscar_aut_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_aut_id, v_circuit_aut_id, 'Austrian Grand Prix', TO_DATE('2025-06-29','YYYY-MM-DD'), 'Austria', 20, 'Sunny') RETURNING RaceID INTO v_race_aut_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_aut_id, v_driver_lando_id, 3, 3, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_aut_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_aut_id, v_driver_oscar_id, 4, 4, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_aut_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_aut_id, 4999.8, 3, 2, 1, 0.10, 96.8);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_aut_id, 5005.1, 2, 2, 1, 0.09, 98.2);

    -- Race 12: Great Britain
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Silverstone', 'Yes', 3.0, 0.175, TO_DATE('2025-07-04','YYYY-MM-DD'), 0.20, 1) RETURNING DriverAssessmentID INTO v_assess_lando_gbr_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Silverstone', 'Yes', 3.0, 0.180, TO_DATE('2025-07-04','YYYY-MM-DD'), 0.18, 1) RETURNING DriverAssessmentID INTO v_assess_oscar_gbr_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_gbr_id, v_circuit_gbr_id, 'British Grand Prix', TO_DATE('2025-07-06','YYYY-MM-DD'), 'Great Britain', 20, 'Cloudy, Dry') RETURNING RaceID INTO v_race_gbr_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_gbr_id, v_driver_lando_id, 2, 2, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_gbr_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_gbr_id, v_driver_oscar_id, 5, 5, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_gbr_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_gbr_id, 5210.6, 2, 1, 1, 0.11, 97.0);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_gbr_id, 5225.4, 4, 2, 1, 0.10, 97.8);

    -- Race 13: Hungary (New)
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_lando_id, 'Hungaroring', 'Yes', 3.0, 0.184, TO_DATE('2025-07-18','YYYY-MM-DD'), 0.29, 3) RETURNING DriverAssessmentID INTO v_assess_lando_hun_id;
    INSERT INTO DrivingAssessment (DriverAssessmentID, DriverID, TrackType, SimulatorUsed, SessionDuration, ReactionTime, AssessmentDate, LapTimeConsistencyScore, ErrorsCount) VALUES (driving_assessment_seq.NEXTVAL, v_driver_oscar_id, 'Hungaroring', 'Yes', 3.0, 0.189, TO_DATE('2025-07-18','YYYY-MM-DD'), 0.23, 1) RETURNING DriverAssessmentID INTO v_assess_oscar_hun_id;
    INSERT INTO Race (RaceID, DriverAssessmentID, CircuitID, RaceName, Date_Race, Country, TotalDriver, WeatherCondition) VALUES (race_seq.NEXTVAL, v_assess_lando_hun_id, v_circuit_hun_id, 'Hungarian Grand Prix', TO_DATE('2025-07-20','YYYY-MM-DD'), 'Hungary', 20, 'Hot, Sunny') RETURNING RaceID INTO v_race_hun_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_hun_id, v_driver_lando_id, 4, 4, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_lando_hun_id;
    INSERT INTO RaceAssignment (RaceAssignmentID, RaceID, DriverID, StartingGridPosition, QualifyingPosition, RadioUsed, DNF) VALUES (race_assignment_seq.NEXTVAL, v_race_hun_id, v_driver_oscar_id, 6, 6, 'Yes', 'No') RETURNING RaceAssignmentID INTO v_assign_oscar_hun_id;
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_lando_id, v_race_hun_id, 5415.2, 5, 2, 2, 0.25, 84.1);
    INSERT INTO DriverPerformance (PerformanceID, DriverID, RaceID, LapTimes, PositionFinished, Overtakes, Pitstops, TireDegradationRate, EnergyManagementScore) VALUES (performance_seq.NEXTVAL, v_driver_oscar_id, v_race_hun_id, 5401.9, 3, 3, 2, 0.19, 91.5);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_lando_hun_id, v_manager_andrea_id, v_driver_lando_id, v_race_hun_id, 2, 'M-H-S', 'Standard', 'High tire degradation in the heat, struggled for pace', 'Compromised', 2);
    INSERT INTO RaceStrategy (StrategyID, RaceAssignmentID, ManagerID, DriverID, RaceID, PlannedPitStops, TireSelection, FuelLoadPlan, StrategyNotes, StrategyOutcome, ActualPitStops) VALUES (strategy_seq.NEXTVAL, v_assign_oscar_hun_id, v_manager_andrea_id, v_driver_oscar_id, v_race_hun_id, 2, 'M-H-H', 'Balanced', 'Excellent tire management led to a podium finish', 'Optimal', 2);
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_hun_id, 22, 22.8, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_lando_id, v_race_hun_id, 48, 22.5, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_hun_id, 24, 22.2, 'Yes', 0, 'Tires only', 'Completed');
    INSERT INTO PitStop (PitStopID, DriverID, RaceID, LapNumber, PitDuration, TireChanged, FuelAdded, WorkPerformed, Status) VALUES (pit_stop_seq.NEXTVAL, v_driver_oscar_id, v_race_hun_id, 50, 22.4, 'Yes', 0, 'Tires only', 'Completed');

    -- ========================================================================
    -- Stage 5: Ancillary Data
    -- ========================================================================
    DBMS_OUTPUT.PUT_LINE('Inserting ancillary data...');
    -- Health & Wellbeing Records
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_lando1_id, TO_DATE('2025-02-10','YYYY-MM-DD'), 170, 68, 45, 65.5, 9.5) RETURNING HealthID INTO v_health_lando1_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_oscar1_id, TO_DATE('2025-02-11','YYYY-MM-DD'), 178, 68, 48, 68.2, 8.9) RETURNING HealthID INTO v_health_oscar1_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_lando2_id, TO_DATE('2025-05-15','YYYY-MM-DD'), 170, 67.5, 48, 64.9, 9.8) RETURNING HealthID INTO v_health_lando2_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_oscar2_id, TO_DATE('2025-05-16','YYYY-MM-DD'), 178, 68.2, 50, 67.8, 9.1) RETURNING HealthID INTO v_health_oscar2_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_lando3_id, TO_DATE('2025-07-20','YYYY-MM-DD'), 170, 68.5, 44, 66.0, 9.2) RETURNING HealthID INTO v_health_lando3_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_oscar3_id, TO_DATE('2025-07-21','YYYY-MM-DD'), 178, 69.0, 46, 68.5, 8.5) RETURNING HealthID INTO v_health_oscar3_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_lando4_id, TO_DATE('2025-08-01','YYYY-MM-DD'), 170, 68.2, 45, 66.2, 9.3) RETURNING HealthID INTO v_health_lando4_id;
    INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_oscar4_id, TO_DATE('2025-08-02','YYYY-MM-DD'), 178, 68.8, 45, 68.8, 8.4) RETURNING HealthID INTO v_health_oscar4_id;
    FOR i IN 1..5 LOOP
        INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_lando1_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*30, 170, 68+i*0.1, 45+i, 65.5 - i*0.2, 9.5 + i*0.1);
        INSERT INTO HealthRecord (HealthID, DriverWellbeingID, CheckupDate, Height, Weight, HeartRate, VO2Max, BodyFatPercentage) VALUES (health_record_seq.NEXTVAL, v_wb_oscar1_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*30, 178, 68+i*0.1, 48+i, 68.2 - i*0.1, 8.9 + i*0.05);
    END LOOP;

    -- Mental Assessments (Narrative Core)
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_lando1_id, v_driver_lando_id, 'Pre-Season', 'Highly motivated', 12, TO_DATE('2025-02-20','YYYY-MM-DD'), 9.5);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_oscar1_id, v_driver_oscar_id, 'Pre-Season', 'Calm and confident', 8, TO_DATE('2025-02-21','YYYY-MM-DD'), 9.8);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_lando2_id, v_driver_lando_id, 'Post-DNF Check', 'Frustrated but resilient', 25, TO_DATE('2025-03-15','YYYY-MM-DD'), 8.2);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_oscar2_id, v_driver_oscar_id, 'Post-Podium Check', 'Elated, managing expectations', 15, TO_DATE('2025-03-25','YYYY-MM-DD'), 9.7);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_lando2_id, v_driver_lando_id, 'Post-Win Debrief', 'Ecstatic, focusing on next race', 10, TO_DATE('2025-05-06','YYYY-MM-DD'), 9.9);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_oscar3_id, v_driver_oscar_id, 'Post-Podium Check (AUT)', 'Confidence building, excellent race craft', 12, TO_DATE('2025-06-30','YYYY-MM-DD'), 9.8);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_lando4_id, v_driver_lando_id, 'Mid-Season Review', 'Positive outlook, targeting consistency', 18, TO_DATE('2025-08-04','YYYY-MM-DD'), 9.1);
    INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_oscar4_id, v_driver_oscar_id, 'Mid-Season Review', 'Very strong, focused on converting pace', 10, TO_DATE('2025-08-05','YYYY-MM-DD'), 9.9);
    FOR i IN 1..6 LOOP
        INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_lando1_id, v_driver_lando_id, 'Routine Check-in', 'Maintaining focus', 15+i, TO_DATE('2025-01-01','YYYY-MM-DD')+i*45, 9.0 - i*0.1);
        INSERT INTO MentalAssessment (MentalID, DriverWellbeingID, DriverID, AssessmentType, CounselorNotes, StressScore, AssessmentDate, FocusLevelScore) VALUES (mental_assessment_seq.NEXTVAL, v_wb_oscar1_id, v_driver_oscar_id, 'Routine Check-in', 'Focused on consistency', 12+i, TO_DATE('2025-01-01','YYYY-MM-DD')+i*45, 9.2 - i*0.1);
    END LOOP;

    -- Training Sessions
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_lando_id, 'Race Simulation', TO_DATE('2025-02-25','YYYY-MM-DD'), 4.0, 'Sim Team', 9.8);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_lando_id, 'Reaction Training', TO_DATE('2025-02-26','YYYY-MM-DD'), 1.5, 'Michael Italiano', 9.9);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_oscar_id, 'Qualifying Simulation', TO_DATE('2025-02-27','YYYY-MM-DD'), 3.0, 'Sim Team', 9.5);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_oscar_id, 'Endurance Conditioning', TO_DATE('2025-02-28','YYYY-MM-DD'), 2.5, 'Kim Keedle', 9.7);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_lando_id, 'Jeddah Sim', TO_DATE('2025-03-05','YYYY-MM-DD'), 3.5, 'Sim Team', 9.7);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_oscar_id, 'Jeddah Sim', TO_DATE('2025-03-05','YYYY-MM-DD'), 3.5, 'Sim Team', 9.6);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_lando_id, 'Neck Strength', TO_DATE('2025-04-01','YYYY-MM-DD'), 1.0, 'Michael Italiano', 9.5);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_oscar_id, 'Cognitive Training', TO_DATE('2025-04-02','YYYY-MM-DD'), 1.0, 'Kim Keedle', 9.8);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_jerez_id, v_driver_lando_id, 'Tire Test', TO_DATE('2025-05-10','YYYY-MM-DD'), 8.0, 'Test Team', 9.2);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_jerez_id, v_driver_oscar_id, 'Aero Rake Test', TO_DATE('2025-05-11','YYYY-MM-DD'), 8.0, 'Test Team', 9.4);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_lando_id, 'Silverstone Sim', TO_DATE('2025-07-01','YYYY-MM-DD'), 4.0, 'Sim Team', 9.9);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_oscar_id, 'Hungaroring Sim', TO_DATE('2025-07-15','YYYY-MM-DD'), 3.0, 'Sim Team', 9.7);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_lando_id, 'Media Training', TO_DATE('2025-07-16','YYYY-MM-DD'), 2.0, 'Comms Team', 9.1);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_gym_id, v_driver_oscar_id, 'Media Training', TO_DATE('2025-07-16','YYYY-MM-DD'), 2.0, 'Comms Team', 9.4);
    INSERT INTO TrainingSession (TrainingID, FacilityID, DriverID, SessionType, Date_Session, Duration, TrainerName, PerformanceScore) VALUES (training_session_seq.NEXTVAL, v_facility_mtc_sim_id, v_driver_lando_id, 'Wet Weather Sim', TO_DATE('2025-08-10','YYYY-MM-DD'), 2.5, 'Sim Team', 9.3);

    -- Media Appearances
    FOR i IN 1..13 LOOP
      INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*20, 'Press Conference', 'Sky Sports F1', 0.5, 'Race '||i||' Preview', 2500000 + i*10000);
      INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-01-01','YYYY-MM-DD')+i*20, 'Press Conference', 'F1 TV', 0.5, 'Race '||i||' Preview', 1500000 + i*10000);
    END LOOP;
    INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-05-05','YYYY-MM-DD'), 'TV Interview', 'Good Morning America', 0.2, 'Post-Miami Win', 12000000);
    INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-03-24','YYYY-MM-DD'), 'Podcast', 'Beyond The Grid', 1.0, 'Post-Australia Podium', 500000);
    INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-07','YYYY-MM-DD'), 'Sponsor Event', 'Google HQ Visit', 2.0, 'Google Chrome Partnership Event', 25000);
    INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-06-15','YYYY-MM-DD'), 'Twitch Stream', 'LandoNorris', 3.0, 'Charity Gaming Stream', 85000);
    INSERT INTO MediaAppearance (MediaID, DriverID, Date_Media, MediaType, Channel, Duration, EventName, AudienceReachEstimate) VALUES (media_appearance_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-01','YYYY-MM-DD'), 'Sponsor Event', 'OKX Tech Talk', 1.5, 'Future of Finance Webcast', 150000);

    -- Wellbeing Sessions
    INSERT INTO WellbeingSession (WellbeingSessionID, DriverID, HealthID, SessionDate, Duration, Trainer) VALUES (wellbeing_session_seq.NEXTVAL, v_driver_lando_id, v_health_lando1_id, TO_DATE('2025-02-12','YYYY-MM-DD'), 1.0, 'Dr. Sarah Green');
    INSERT INTO WellbeingSession (WellbeingSessionID, DriverID, HealthID, SessionDate, Duration, Trainer) VALUES (wellbeing_session_seq.NEXTVAL, v_driver_oscar_id, v_health_oscar1_id, TO_DATE('2025-02-13','YYYY-MM-DD'), 1.0, 'Dr. Emily White');
    FOR i IN 1..12 LOOP
        INSERT INTO WellbeingSession (WellbeingSessionID, DriverID, HealthID, SessionDate, Duration, Trainer) VALUES (wellbeing_session_seq.NEXTVAL, v_driver_lando_id, v_health_lando1_id, TO_DATE('2025-03-01','YYYY-MM-DD')+i*15, 0.75, 'Dr. Sarah Green');
        INSERT INTO WellbeingSession (WellbeingSessionID, DriverID, HealthID, SessionDate, Duration, Trainer) VALUES (wellbeing_session_seq.NEXTVAL, v_driver_oscar_id, v_health_oscar1_id, TO_DATE('2025-03-05','YYYY-MM-DD')+i*15, 0.75, 'Dr. Emily White');
    END LOOP;

    -- Test Sessions
    INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_david_id, v_vehicle_test_id, NULL, TO_DATE('2025-02-05','YYYY-MM-DD'), 'Aerodynamic Correlation', 75.0, 450, 50.0, 3.5, 6.0);
    INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_hiroshi_id, v_vehicle_lando_id, v_race_aus_id, TO_DATE('2025-03-18','YYYY-MM-DD'), 'Setup Optimization', 80.0, 480, 45.0, 4.0, 4.0);
    INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_megan_id, v_vehicle_oscar_id, v_race_jpn_id, TO_DATE('2025-04-01','YYYY-MM-DD'), 'Tire Degradation', 70.0, 400, 55.0, 3.8, 5.0);
    INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_david_id, v_vehicle_spare_id, NULL, TO_DATE('2025-05-12','YYYY-MM-DD'), 'Shakedown', 50.0, 200, 25.0, 2.5, 2.0);
    INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_sara_id, v_vehicle_test_id, NULL, TO_DATE('2025-06-18','YYYY-MM-DD'), 'Data Logging', 65.0, 350, 40.0, 3.2, 4.0);
    FOR i IN 1..7 LOOP
        INSERT INTO TestSession (TestID, EngineerID, VehicleID, RaceID, Date_Test, TestType, BrakeUsage, GearShifts, FuelUsage, GForce, Duration) VALUES (test_session_seq.NEXTVAL, v_engineer_david_id, v_vehicle_test_id, NULL, TO_DATE('2025-01-01','YYYY-MM-DD')+i*7, 'Component Test', 60.0+i, 300+i*10, 40.0+i, 3.0+i*0.1, 3.0);
    END LOOP;

    -- Nutrition Logs
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-05', 'YYYY-MM-DD'), 'Pre-Race Dinner (GBR)', 1250, 85, 2.8);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-06', 'YYYY-MM-DD'), 'Race Day Breakfast (GBR)', 850, 60, 3.8);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-06', 'YYYY-MM-DD'), 'Post-Race Meal (GBR)', 1600, 110, 2.5);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-07', 'YYYY-MM-DD'), 'Recovery Day Lunch', 900, 70, 4.0);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-05', 'YYYY-MM-DD'), 'Pre-Race Dinner (GBR)', 1350, 90, 3.0);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-06', 'YYYY-MM-DD'), 'Race Day Breakfast (GBR)', 900, 65, 4.0);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-06', 'YYYY-MM-DD'), 'Post-Race Meal (GBR)', 1700, 120, 2.8);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-07', 'YYYY-MM-DD'), 'Recovery Day Lunch', 950, 75, 4.2);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-08', 'YYYY-MM-DD'), 'Training Day Total', 3500, 220, 5.0);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-08', 'YYYY-MM-DD'), 'Training Day Total', 3600, 230, 5.5);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-05-04', 'YYYY-MM-DD'), 'Post-Win Celebration', 2500, 120, 1.5);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-05-05', 'YYYY-MM-DD'), 'Recovery Day', 2200, 150, 4.0);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-19', 'YYYY-MM-DD'), 'Pre-Race Dinner (HUN)', 1300, 90, 3.2);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-19', 'YYYY-MM-DD'), 'Pre-Race Dinner (HUN)', 1400, 95, 3.5);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_lando_id, TO_DATE('2025-07-20', 'YYYY-MM-DD'), 'Race Day Breakfast (HUN)', 900, 65, 4.2);
    INSERT INTO NutritionLog (NutritionID, DriverID, RecordDate, MealType, Calories, ProteinGrams, HydrationLitres) VALUES (nutrition_log_seq.NEXTVAL, v_driver_oscar_id, TO_DATE('2025-07-20', 'YYYY-MM-DD'), 'Race Day Breakfast (HUN)', 950, 70, 4.5);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('McLaren F1 Team database bulk insertion completed successfully.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred during bulk data insertion: ' || SQLERRM);
END;
/