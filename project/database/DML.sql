-- Active: 1763190115995@@classmysql.engr.oregonstate.edu@3306@cs340_harrim22
-- Group 90: Global High-Speed Rail Database
-- Michael Harris & Francisco Yinug
-- DML.sql for CS340 Project Step 6
-- All SQL DML manually authored by Group 90 members.


----------------------------------------------------------------
-- COUNTRIES
----------------------------------------------------------------

-- READ
SELECT countryID, countryName, continent, populationMillions
FROM Countries
ORDER BY countryName;

-- CREATE
INSERT INTO Countries (countryName, continent, populationMillions)
VALUES (@countryName, @continent, @populationMillions);

-- UPDATE  
UPDATE Countries
SET countryName = @countryName,
    continent = @continent,
    populationMillions = @populationMillions
WHERE countryID = @countryID;

-- DELETE
DELETE FROM Countries
WHERE countryID = @countryID;



----------------------------------------------------------------
-- OPERATORS
----------------------------------------------------------------

-- READ 
SELECT Operators.operatorID,
       Operators.operatorName,
       Operators.foundedYear,
       Countries.countryName
FROM Operators
JOIN Countries ON Operators.countryID = Countries.countryID
ORDER BY operatorID;


-- CREATE
INSERT INTO Operators (operatorName, foundedYear, countryID)
VALUES (@operatorName, @foundedYear, @countryID);

-- UPDATE  
UPDATE Operators
SET operatorName = @operatorName,
    foundedYear = @foundedYear,
    countryID = @countryID
WHERE operatorID = @operatorID;

-- DELETE
DELETE FROM Operators
WHERE operatorID = @operatorID;



----------------------------------------------------------------
-- RAIL LINES
----------------------------------------------------------------

-- READ 
SELECT lineID, lineName, maxSpeed, lengthKM, operatorID
FROM RailLines
ORDER BY lineID;

-- CREATE
INSERT INTO RailLines (lineName, maxSpeed, lengthKM, operatorID)
VALUES (@lineName, @maxSpeed, @lengthKM, @operatorID);

-- UPDATE 
UPDATE RailLines
SET lineName = @lineName,
    maxSpeed = @maxSpeed,
    lengthKM = @lengthKM,
    operatorID = @operatorID
WHERE lineID = @lineID;

-- DELETE
DELETE FROM RailLines
WHERE lineID = @lineID;



----------------------------------------------------------------
-- STATIONS  
----------------------------------------------------------------

-- READ
SELECT stationID, stationName, city, countryID
FROM Stations
ORDER BY stationID;

-- CREATE
INSERT INTO Stations (stationName, city, countryID)
VALUES (@stationName, @city, @countryID);

-- DELETE
DELETE FROM Stations
WHERE stationID = @stationID;



----------------------------------------------------------------
-- PROJECTS
----------------------------------------------------------------

-- READ 
SELECT projectID, projectName, status, startYear, endYear
FROM Projects
ORDER BY projectID;

-- CREATE
INSERT INTO Projects (projectName, status, startYear, endYear)
VALUES (@projectName, @status, @startYear, @endYear);

-- UPDATE 
UPDATE Projects
SET projectName = @projectName,
    status = @status,
    startYear = @startYear,
    endYear = @endYear
WHERE projectID = @projectID;

-- DELETE
DELETE FROM Projects
WHERE projectID = @projectID;



----------------------------------------------------------------
-- PROJECT–LINE MAPPING (M:N)  
----------------------------------------------------------------

-- READ 
SELECT ProjectLines.projectID,
       Projects.projectName,
       ProjectLines.lineID,
       RailLines.lineName
FROM ProjectLines
JOIN Projects ON ProjectLines.projectID = Projects.projectID
JOIN RailLines ON ProjectLines.lineID = RailLines.lineID
ORDER BY ProjectLines.projectID, ProjectLines.lineID;

-- CREATE
INSERT INTO ProjectLines (projectID, lineID)
VALUES (@projectID, @lineID);

-- DELETE
DELETE FROM ProjectLines
WHERE projectID = @projectID
  AND lineID = @lineID;



----------------------------------------------------------------
-- LINE–STATION MAPPING (M:N)  
----------------------------------------------------------------

-- READ 
SELECT LineStations.lineID,
       RailLines.lineName,
       LineStations.stationID,
       Stations.stationName,
       LineStations.stopOrder
FROM LineStations
JOIN RailLines ON LineStations.lineID = RailLines.lineID
JOIN Stations ON LineStations.stationID = Stations.stationID
ORDER BY LineStations.lineID, LineStations.stopOrder;

-- CREATE
INSERT INTO LineStations (lineID, stationID, stopOrder)
VALUES (@lineID, @stationID, @stopOrder);

-- DELETE
DELETE FROM LineStations
WHERE lineID = @lineID
  AND stationID = @stationID;