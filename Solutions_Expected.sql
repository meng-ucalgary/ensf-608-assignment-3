# ENSF 608 Fall 2021
# Suggested solutions for Assignment 3
# Individual queries may vary
# Aliases are optional, but recommended
# Joins may be specified or default


USE OLYMPICARCHERY;


# 1. Write a query to list all athlete names (first and last) and the name of the country that they represent (1 mark).
SELECT P.FName, P.LName, P.Country FROM PARTICIPANT as P, ATHLETE as A WHERE P.OlympicID = A.OlympicID;


# 2. Write a query to list the names and countries of any coaches who have not yet completed their orientation workshop (1 mark).
SELECT P.FName, P.LName, P.Country FROM PARTICIPANT as P, COACH as C WHERE P.OlympicID = C.OlympicID AND C.Orientation = 'Pending';


# 3. Write a query to count how many athletes belong to each country (1 mark).
SELECT P.Country, COUNT(*) FROM (PARTICIPANT as P JOIN ATHLETE as A ON P.OlympicID = A.OlympicID) GROUP BY P.Country;


# 4. Write a query to list the Olympic ID number and birth year of all participants. If their birth year is not available, “null” should be listed instead. Order your list from oldest to youngest (2 marks).
SELECT P.OlympicID, A.BirthYear FROM PARTICIPANT AS P LEFT OUTER JOIN ATHLETE AS A ON P.OlympicID = A.OlympicID ORDER BY A.BirthYear;


# 5. Write a query to list the names of all countries that have more than one athlete listed in the database (1 mark).
SELECT P.Country, COUNT(*) FROM (PARTICIPANT as P JOIN ATHLETE as A ON P.OlympicID = A.OlympicID) GROUP BY P.Country HAVING COUNT(*) > 1;


# 6. Write a query to find the names of all athletes who have won a medal in this Olympics. Only list each name once (2 marks).
SELECT DISTINCT P.LName, P.FName FROM PARTICIPANT as P, ATHLETE as A, TEAM as T, INDIVIDUAL_RESULTS AS I, TEAM_RESULTS AS TR WHERE 
(P.OlympicID = A.OlympicID AND I.Olympian = P.OlympicID) OR
(TR.Team = T. TeamID AND (T.Member1 = P.OlympicID OR T.Member2 = P.OlympicID OR T.Member3 = P.OlympicID OR T.Member4 = P.OlympicID OR T.Member5 = P.OlympicID OR T.Member6 = P.OlympicID));


# 7. Write a query to list the names of all countries that have won at least five medals in archery overall since 1972 (1 mark).
SELECT CName FROM COUNTRY WHERE (AllTimeGold + AllTimeSilver + AllTimeBronze) > 4;


# 8. Write a query to find the number of archery medals won for each country in this Olympics (2 marks).
# Grading note: Students may assume that medals are per individual or per event. Both query results are shown below.

# 8. Count medals per individual
DROP VIEW IF EXISTS MEDAL_WINNERS;
CREATE VIEW MEDAL_WINNERS(Country, LName) AS
SELECT P.Country, P.LName FROM PARTICIPANT as P, INDIVIDUAL_RESULTS AS I WHERE I.Olympian = P.OlympicID
UNION ALL
SELECT P.Country, P.LName FROM PARTICIPANT as P, TEAM as T, TEAM_RESULTS AS TR WHERE
TR.Team = T. TeamID AND (T.Member1 = P.OlympicID OR T.Member2 = P.OlympicID OR T.Member3 = P.OlympicID OR T.Member4 = P.OlympicID OR T.Member5 = P.OlympicID OR T.Member6 = P.OlympicID);
SELECT Country, COUNT(*) FROM MEDAL_WINNERS GROUP BY Country;

# 8. Count medals per event
DROP VIEW IF EXISTS MEDAL_WINNERS;
CREATE VIEW MEDAL_WINNERS(Country, LName) AS
SELECT P.Country, P.LName FROM PARTICIPANT as P, INDIVIDUAL_RESULTS AS I WHERE I.Olympian = P.OlympicID
UNION ALL
SELECT P.Country, P.LName FROM PARTICIPANT as P, TEAM as T, TEAM_RESULTS AS TR WHERE
TR.Team = T. TeamID AND (T.Member1 = P.OlympicID);
SELECT Country, COUNT(*) FROM MEDAL_WINNERS GROUP BY Country;


# 9. Write a query to list the names of all athletes who are competing in the Olympic Games for the first time (1 mark).
SELECT P.FName, P.LName FROM PARTICIPANT as P, ATHLETE as A WHERE P.OlympicID = A.OlympicID AND A.FirstGames = 'Tokyo 2020';


# 10. Write a query to find the names of the oldest and youngest athletes (list multiple if there is a tie) (1 mark).
SELECT P.FName, P.LName, A.BirthYear FROM PARTICIPANT as P, ATHLETE as A WHERE P.OlympicID = A.OlympicID 
AND (A.BirthYear = (SELECT MAX(ATHLETE.BirthYear) FROM ATHLETE) OR A.BirthYear = (SELECT MIN(ATHLETE.BirthYear) FROM ATHLETE));


# 11. The media have requested the names and birth years of the athletes competing in team events, but they do not have permission to view all the other data. Create a view called TEAM_ATHLETES that only lists the desired data. Display the rows of TEAM_ATHLETES from the youngest to oldest athlete (3 marks).
DROP VIEW IF EXISTS TEAM_ATHLETES;
CREATE VIEW TEAM_ATHLETES(FName, LName, BirthYear) AS
SELECT DISTINCT P.LName, P.FName, A.BirthYear FROM PARTICIPANT as P, ATHLETE as A, TEAM as T WHERE P.OlympicID = A.OlympicID 
AND (T.Member1 = P.OlympicID OR T.Member2 = P.OlympicID OR T.Member3 = P.OlympicID OR T.Member4 = P.OlympicID OR T.Member5 = P.OlympicID OR T.Member6 = P.OlympicID);
SELECT * FROM TEAM_ATHLETES ORDER BY BirthYear DESC;


# 12. Organizers are printing the schedules for each archery event. Create a new table called INDIVID_W for all athletes who are competing on July 30th. Display the table, which should include the event date, venue name, last name of each competitor, and their country (3 marks).
DROP TABLE IF EXISTS INDIVID_W;
CREATE TABLE INDIVID_W AS
SELECT EventDate, Location, P.LName, P.Country FROM PARTICIPANT AS P, ATHLETE AS A, EVENT_SCHEDULE AS E
WHERE P.OlympicID = A.OlympicID AND A.Sex = 'F' AND EventDate = 'July 30';
SELECT * FROM INDIVID_W;


# 13. Written response: What will happen when the following query is run and why (1 mark)?
# INSERT INTO COACH VALUES ('T2020_046', 'Pending');

# Insertion will fail as there is no existing Participant with a primary key of T2020_046, so the foreign key of the new Coach has no matching tuple to refer back.


# 14. Written response: What would be the impact of the following deletion and why (1 mark)?
# DELETE FROM PARTICIPANT WHERE OlympicID = 'T2020_001';

# With the current database design, the deletion will fail. The Participant with a primary key of T2020_001 is referred to by other tables, such as results and team membership.


# 15. Written response: Describe a possible constraint that should be considered for the TEAM table. What other table(s) would need to be involved (1 mark)?
# Anwers may vary. Possible solutions include:
# - checking that all team members come from the same country (use Participant table)
# - checking that team members can only be on one team (check within Team table)
 
