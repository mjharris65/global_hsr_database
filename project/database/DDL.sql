-- Group 90: Global High-Speed Rail Database
-- Michael Harris & Francisco Yinug
-- DDL.sql for CS340 Project Step 6



-- Citation: Schema design fully created by the team. ChatGPT (OpenAI, 2025)
-- was used only to proofread SQL syntax for clarity and style.





-- ###############################
-- RESET PROCEDURE FOR FULL SCHEMA
-- ###############################

DROP PROCEDURE IF EXISTS sp_ResetHSRDatabase;

DELIMITER //
CREATE PROCEDURE sp_ResetHSRDatabase()
BEGIN
    -- Disable constraints and speed up execution
    SET FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- DROP TABLES (must be in child → parent order)
    DROP TABLE IF EXISTS ProjectLines;
    DROP TABLE IF EXISTS LineStations;
    DROP TABLE IF EXISTS Projects;
    DROP TABLE IF EXISTS RailLines;
    DROP TABLE IF EXISTS Operators;
    DROP TABLE IF EXISTS Stations;
    DROP TABLE IF EXISTS Countries;

    -- ===========================
    -- RECREATE TABLES
    -- ===========================

    -- COUNTRIES
    CREATE TABLE Countries (
      countryID INT AUTO_INCREMENT PRIMARY KEY,
      countryName VARCHAR(100) NOT NULL UNIQUE,
      continent VARCHAR(45) NOT NULL,
      populationMillions DECIMAL(6,2)
    );

    -- OPERATORS
    CREATE TABLE Operators (
      operatorID INT AUTO_INCREMENT PRIMARY KEY,
      operatorName VARCHAR(45) NOT NULL UNIQUE,
      foundedYear YEAR,
      countryID INT NOT NULL,
      FOREIGN KEY (countryID) REFERENCES Countries(countryID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    -- STATIONS
    CREATE TABLE Stations (
      stationID INT AUTO_INCREMENT PRIMARY KEY,
      stationName VARCHAR(100) NOT NULL,
      city VARCHAR(100) NOT NULL,
      countryID INT NOT NULL,
      FOREIGN KEY (countryID) REFERENCES Countries(countryID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    -- RAIL LINES
    CREATE TABLE RailLines (
      lineID INT AUTO_INCREMENT PRIMARY KEY,
      lineName VARCHAR(100) NOT NULL UNIQUE,
      maxSpeed INT NOT NULL,
      lengthKM DECIMAL(6,1) NOT NULL,
      operatorID INT NOT NULL,
      FOREIGN KEY (operatorID) REFERENCES Operators(operatorID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    -- PROJECTS
    CREATE TABLE Projects (
      projectID INT AUTO_INCREMENT PRIMARY KEY,
      projectName VARCHAR(245) NOT NULL,
      status ENUM('Planned', 'Under Construction', 'Operational', 'Cancelled') NOT NULL,
      startYear YEAR NOT NULL,
      endYear YEAR DEFAULT NULL
    );

    -- PROJECT–LINE MAPPING
    CREATE TABLE ProjectLines (
      projectID INT NOT NULL,
      lineID INT NOT NULL,
      PRIMARY KEY (projectID, lineID),
      FOREIGN KEY (projectID) REFERENCES Projects(projectID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
      FOREIGN KEY (lineID) REFERENCES RailLines(lineID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    -- LINE–STATION MAPPING
    CREATE TABLE LineStations (
      lineID INT NOT NULL,
      stationID INT NOT NULL,
      stopOrder INT NOT NULL,
      PRIMARY KEY (lineID, stationID),
      FOREIGN KEY (lineID) REFERENCES RailLines(lineID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
      FOREIGN KEY (stationID) REFERENCES Stations(stationID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    );

    -- ===========================
    -- SAMPLE DATA INSERTS
    -- ===========================

    -- COUNTRIES
    INSERT INTO Countries (countryName, continent, populationMillions)
    VALUES
    ('Japan', 'Asia', 125.70),
    ('France', 'Europe', 67.00),
    ('China', 'Asia', 1411.00),
    ('Germany', 'Europe', 83.20),
    ('Spain', 'Europe', 47.60);

    -- OPERATORS
    INSERT INTO Operators (operatorName, foundedYear, countryID)
    VALUES
    ('JR East (Japan Railways East)', 1987, 1),
    ('SNCF (National Society of French Railways)', 1938, 2),
    ('China State Railway Group', 2013, 3),
    ('Renfe Operadora', 1941, 5),
    ('Deutsche Bahn (DB)', 1994, 4);

    -- STATIONS
    INSERT INTO Stations (stationName, city, countryID)
    VALUES
    ('Tokyo Station', 'Tokyo', 1),
    ('Beijing South', 'Beijing', 3),
    ('Gare de Lyon', 'Paris', 2),
    ('Madrid Atocha', 'Madrid', 5),
    ('Berlin Hauptbahnhof', 'Berlin', 4);

    -- RAIL LINES
    INSERT INTO RailLines (lineName, maxSpeed, lengthKM, operatorID)
    VALUES
    ('Tohoku Shinkansen', 320, 674.9, 1),
    ('LGV Sud-Est', 300, 409.0, 2),
    ('Beijing–Shanghai HSR', 350, 1318.0, 3),
    ('Berlin–Munich HSR', 300, 623.0, 4),
    ('Madrid–Barcelona HSR', 310, 621.0, 5);

    -- PROJECTS
    INSERT INTO Projects (projectName, status, startYear, endYear)
    VALUES
    ('Hokkaidō Shinkansen Extension', 'Under Construction', 2016, 2031),
    ('Grand Paris Express – HSR Links', 'Planned', 2020, 2035),
    ('China Western HSR Corridor', 'Under Construction', 2022, 2028),
    ('Madrid–Galicia HSR Project', 'Operational', 2011, 2021),
    ('Germany Digital Rail Program', 'Planned', 2019, NULL);

    -- PROJECT-LINE MAPPING
    INSERT INTO ProjectLines (projectID, lineID)
    VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 5),
    (5, 4);

    -- LINE-STATION MAPPING
    INSERT INTO LineStations (lineID, stationID, stopOrder)
    VALUES
    (1, 1, 1),
    (2, 3, 1),
    (3, 2, 1),
    (4, 5, 1),
    (5, 4, 1);

    -- Re-enable FK checks
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END //
DELIMITER ;