-- ================================================================
-- Group 90: Global High-Speed Rail Database
-- Michael Harris & Francisco Yinug
-- PL.sql (Stored Procedures)
-- ================================================================

-- Citation: ChatGPT (OpenAI, 2025) was used to help verify stored procedure
-- patterns, confirm DROP/CREATE ordering, and clarify MySQL DELIMITER syntax.
-- All SQL content was written, structured, and validated by the team.

-- ###############################################################
-- COUNTRIES
-- ###############################################################

-- COUNTRIES: CREATE
DROP PROCEDURE IF EXISTS sp_CreateCountry;
DELIMITER //
CREATE PROCEDURE sp_CreateCountry(
    IN p_countryName VARCHAR(100),
    IN p_continent VARCHAR(100),
    IN p_populationMillions DECIMAL(10,2)
)
BEGIN
    -- Duplicate guard
    IF EXISTS (
        SELECT 1 FROM Countries
        WHERE countryName = p_countryName
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A country with this name already exists.';
    END IF;

    INSERT INTO Countries (countryName, continent, populationMillions)
    VALUES (p_countryName, p_continent, p_populationMillions);
END //
DELIMITER ;


-- COUNTRIES: UPDATE
DROP PROCEDURE IF EXISTS sp_UpdateCountry;
DELIMITER //
CREATE PROCEDURE sp_UpdateCountry(
    IN p_countryID INT,
    IN p_countryName VARCHAR(100),
    IN p_continent VARCHAR(100),
    IN p_populationMillions DECIMAL(10,2)
)
BEGIN
    -- Duplicate guard for updates
    IF EXISTS (
        SELECT 1 FROM Countries
        WHERE countryName = p_countryName
          AND countryID <> p_countryID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Another country already has this name.';
    END IF;

    UPDATE Countries
    SET countryName = p_countryName,
        continent = p_continent,
        populationMillions = p_populationMillions
    WHERE countryID = p_countryID;
END //
DELIMITER ;


-- COUNTRIES: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteCountry;
DELIMITER //
CREATE PROCEDURE sp_DeleteCountry(
    IN p_countryID INT
)
BEGIN
    DELETE FROM Countries
    WHERE countryID = p_countryID;
END //
DELIMITER ;


-- ###############################################################
-- OPERATORS
-- ###############################################################

-- OPERATORS: CREATE
DROP PROCEDURE IF EXISTS sp_CreateOperator;
DELIMITER //
CREATE PROCEDURE sp_CreateOperator(
    IN p_operatorName VARCHAR(100),
    IN p_foundedYear YEAR,
    IN p_countryID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Operators WHERE operatorName = p_operatorName
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Operator name already exists.';
    END IF;

    INSERT INTO Operators (operatorName, foundedYear, countryID)
    VALUES (p_operatorName, p_foundedYear, p_countryID);
END //
DELIMITER ;


-- OPERATORS: UPDATE
DROP PROCEDURE IF EXISTS sp_UpdateOperator;
DELIMITER //
CREATE PROCEDURE sp_UpdateOperator(
    IN p_operatorID INT,
    IN p_operatorName VARCHAR(100),
    IN p_foundedYear YEAR,
    IN p_countryID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Operators
        WHERE operatorName = p_operatorName
          AND operatorID <> p_operatorID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Another operator already has this name.';
    END IF;

    UPDATE Operators
    SET operatorName = p_operatorName,
        foundedYear = p_foundedYear,
        countryID = p_countryID
    WHERE operatorID = p_operatorID;
END //
DELIMITER ;


-- OPERATORS: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteOperator;
DELIMITER //
CREATE PROCEDURE sp_DeleteOperator(
    IN p_operatorID INT
)
BEGIN
    DELETE FROM Operators
    WHERE operatorID = p_operatorID;
END //
DELIMITER ;


-- ###############################################################
-- RAIL LINES
-- ###############################################################

-- RAIL LINES: CREATE
DROP PROCEDURE IF EXISTS sp_CreateRailLine;
DELIMITER //
CREATE PROCEDURE sp_CreateRailLine(
    IN p_lineName VARCHAR(200),
    IN p_maxSpeed INT,
    IN p_lengthKM DECIMAL(6,1),
    IN p_operatorID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM RailLines WHERE lineName = p_lineName
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rail line name already exists.';
    END IF;

    INSERT INTO RailLines (lineName, maxSpeed, lengthKM, operatorID)
    VALUES (p_lineName, p_maxSpeed, p_lengthKM, p_operatorID);
END //
DELIMITER ;


-- RAIL LINES: UPDATE
DROP PROCEDURE IF EXISTS sp_UpdateRailLine;
DELIMITER //
CREATE PROCEDURE sp_UpdateRailLine(
    IN p_lineID INT,
    IN p_lineName VARCHAR(200),
    IN p_maxSpeed INT,
    IN p_lengthKM DECIMAL(6,1),
    IN p_operatorID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM RailLines
        WHERE lineName = p_lineName
          AND lineID <> p_lineID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Another rail line already uses that name.';
    END IF;

    UPDATE RailLines
    SET lineName = p_lineName,
        maxSpeed = p_maxSpeed,
        lengthKM = p_lengthKM,
        operatorID = p_operatorID
    WHERE lineID = p_lineID;
END //
DELIMITER ;


-- RAIL LINES: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteRailLine;
DELIMITER //
CREATE PROCEDURE sp_DeleteRailLine(
    IN p_lineID INT
)
BEGIN
    DELETE FROM RailLines
    WHERE lineID = p_lineID;
END //
DELIMITER ;


-- ###############################################################
-- STATIONS
-- ###############################################################
-- Note: Website includes Create + Delete but NO Update.

-- STATIONS: CREATE
DROP PROCEDURE IF EXISTS sp_CreateStation;
DELIMITER //
CREATE PROCEDURE sp_CreateStation(
    IN p_stationName VARCHAR(200),
    IN p_city VARCHAR(100),
    IN p_countryID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Stations
        WHERE stationName = p_stationName
          AND city = p_city
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A station with this name already exists in that city.';
    END IF;

    INSERT INTO Stations (stationName, city, countryID)
    VALUES (p_stationName, p_city, p_countryID);
END //
DELIMITER ;


-- STATIONS: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteStation;
DELIMITER //
CREATE PROCEDURE sp_DeleteStation(
    IN p_stationID INT
)
BEGIN
    DELETE FROM Stations
    WHERE stationID = p_stationID;
END //
DELIMITER ;


-- ###############################################################
-- PROJECTS
-- ###############################################################

-- PROJECTS: CREATE
DROP PROCEDURE IF EXISTS sp_CreateProject;
DELIMITER //
CREATE PROCEDURE sp_CreateProject(
    IN p_projectName VARCHAR(200),
    IN p_status VARCHAR(50),
    IN p_startYear YEAR,
    IN p_endYear YEAR
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Projects
        WHERE projectName = p_projectName
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A project with this name already exists.';
    END IF;

    INSERT INTO Projects (projectName, status, startYear, endYear)
    VALUES (p_projectName, p_status, p_startYear, p_endYear);
END //
DELIMITER ;


-- PROJECTS: UPDATE
DROP PROCEDURE IF EXISTS sp_UpdateProject;
DELIMITER //
CREATE PROCEDURE sp_UpdateProject(
    IN p_projectID INT,
    IN p_projectName VARCHAR(200),
    IN p_status VARCHAR(50),
    IN p_startYear YEAR,
    IN p_endYear YEAR
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Projects
        WHERE projectName = p_projectName
          AND projectID <> p_projectID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Another project already uses that name.';
    END IF;

    UPDATE Projects
    SET projectName = p_projectName,
        status = p_status,
        startYear = p_startYear,
        endYear = p_endYear
    WHERE projectID = p_projectID;
END //
DELIMITER ;


-- PROJECTS: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteProject;
DELIMITER //
CREATE PROCEDURE sp_DeleteProject(
    IN p_projectID INT
)
BEGIN
    DELETE FROM Projects
    WHERE projectID = p_projectID;
END //
DELIMITER ;


-- ###############################################################
-- PROJECT-LINE MAPPING (M:N)
-- ###############################################################

-- PROJECT-LINES: CREATE
DROP PROCEDURE IF EXISTS sp_CreateProjectLine;
DELIMITER //
CREATE PROCEDURE sp_CreateProjectLine(
    IN p_projectID INT,
    IN p_lineID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM ProjectLines
        WHERE projectID = p_projectID
          AND lineID = p_lineID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'That project–line mapping already exists.';
    END IF;

    INSERT INTO ProjectLines (projectID, lineID)
    VALUES (p_projectID, p_lineID);
END //
DELIMITER ;


-- PROJECT-LINES: UPDATE
DROP PROCEDURE IF EXISTS sp_UpdateProjectLine;
DELIMITER //
CREATE PROCEDURE sp_UpdateProjectLine(
    IN p_oldProjectID INT,
    IN p_oldLineID INT,
    IN p_newProjectID INT,
    IN p_newLineID INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM ProjectLines
        WHERE projectID = p_newProjectID
          AND lineID = p_newLineID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: mapping already exists.';
    END IF;

    UPDATE ProjectLines
    SET projectID = p_newProjectID,
        lineID = p_newLineID
    WHERE projectID = p_oldProjectID
      AND lineID = p_oldLineID;
END //
DELIMITER ;


-- PROJECT-LINES: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteProjectLine;
DELIMITER //
CREATE PROCEDURE sp_DeleteProjectLine(
    IN p_projectID INT,
    IN p_lineID INT
)
BEGIN
    DELETE FROM ProjectLines
    WHERE projectID = p_projectID
      AND lineID = p_lineID;
END //
DELIMITER ;


-- ###############################################################
-- LINE-STATION MAPPING (M:N)
-- ###############################################################
-- Website supports Create + Delete but NOT Update.

-- LINE-STATIONS: CREATE
DROP PROCEDURE IF EXISTS sp_CreateLineStation;
DELIMITER //
CREATE PROCEDURE sp_CreateLineStation(
    IN p_lineID INT,
    IN p_stationID INT,
    IN p_stopOrder INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM LineStations
        WHERE lineID = p_lineID
          AND stationID = p_stationID
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'That line–station mapping already exists.';
    END IF;

    INSERT INTO LineStations (lineID, stationID, stopOrder)
    VALUES (p_lineID, p_stationID, p_stopOrder);
END //
DELIMITER ;


-- LINE-STATIONS: DELETE
DROP PROCEDURE IF EXISTS sp_DeleteLineStation;
DELIMITER //
CREATE PROCEDURE sp_DeleteLineStation(
    IN p_lineID INT,
    IN p_stationID INT
)
BEGIN
    DELETE FROM LineStations
    WHERE lineID = p_lineID
      AND stationID = p_stationID;
END //
DELIMITER ;