use ipl;

-- desc ipl_bidder_details;

-- ALTER TABLE ipl_bidder_details
-- ADD CONSTRAINT fk_constraint_name
-- FOREIGN KEY (bidder_id) REFERENCES ipl_bidding_details(bidder_id);

-- ALTER TABLE IPL_Match_Schedule
-- ADD CONSTRAINT fk_constraint_name1
-- FOREIGN KEY (Schedule_id) REFERENCES ipl_bidding_details(Schedule_id);

-- ALTER TABLE IPL_stadium
-- ADD CONSTRAINT fk_constraint_name2
-- FOREIGN KEY (stadium_id) REFERENCES IPL_Match_Schedule(stadium_id);

-- ALTER TABLE IPL_Match_Schedule
-- ADD CONSTRAINT fk_constraint_name3
-- FOREIGN KEY (match_id) REFERENCES IPL_match(match_id);

-- desc IPL_match;
-- desc ipl_bidder_points;

-- ALTER TABLE ipl_bidder_points
-- ADD CONSTRAINT fk_constraint_name5
-- FOREIGN KEY (bidder_id) REFERENCES ipl_bidder_details(bidder_id);

-- ALTER TABLE IPL_Match_Schedule
-- ADD CONSTRAINT fk_constraint_name6
-- FOREIGN KEY (stadium_id) REFERENCES IPL_stadium(stadium_id);

-- ALTER TABLE IPL_Match_Schedule
-- ADD CONSTRAINT fk_constraint_name7
-- FOREIGN KEY (tournmt_id) REFERENCES IPL_tournament(tournmt_id);

-- ALTER TABLE IPL_team_players
-- ADD CONSTRAINT fk_constraint_name8
-- FOREIGN KEY (player_id) REFERENCES IPL_player(player_id);

-- ALTER TABLE IPL_team_players
-- ADD CONSTRAINT fk_constraint_name9
-- FOREIGN KEY (team_id) REFERENCES IPL_team(team_id);

-- ALTER TABLE IPL_team_standings
-- ADD CONSTRAINT fk_constraint_name10
-- FOREIGN KEY (team_id) REFERENCES IPL_team(team_id);

-- ALTER TABLE IPL_match
-- ADD CONSTRAINT fk_constraint_name11
-- FOREIGN KEY (team_id1) REFERENCES IPL_team(team_id);



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



# Q1
SELECT bidder_id, bidder_name, 
IFNULL(Win_count, 0) AS Win_Count, 
IFNULL(Total_count, 0) AS Total_Count, 
IFNULL(Win_Percentage, 0) AS Win_Percentage FROM ipl_bidder_details
LEFT JOIN 
(Select *, ROUND((Win_count/Total_count*100), 2) AS Win_Percentage FROM
(SELECT Bidder_id, COUNT(*) AS Win_count FROM ipl_bidding_details
WHERE bid_status = "Won"
GROUP BY bidder_id) AS t1
JOIN 
(SELECT bidder_id, COUNT(*) AS Total_count FROM ipl_bidding_details
GROUP BY bidder_id) AS t2
USING(bidder_id)) AS t3
USING(bidder_id)
ORDER BY Win_Percentage DESC;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q2
SELECT stadium_id, stadium_name, city, No_of_matches_played FROM
(SELECT Stadium_id, COUNT(match_id) AS No_of_matches_played FROM ipl_match_schedule
GROUP BY stadium_id) AS t1
JOIN ipl_stadium
USING(stadium_id);



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q3
SELECT *, ROUND(Won_toss_and_match/No_of_matches_played * 100, 2) AS Percentage_of_won FROM
(SELECT stadium_id, stadium_name, city, No_of_matches_played FROM
(SELECT Stadium_id, COUNT(match_id) AS No_of_matches_played FROM ipl_match_schedule
GROUP BY stadium_id) AS t1
JOIN ipl_stadium
USING(stadium_id)) AS t3
JOIN
(SELECT stadium_id, COUNT(*) AS Won_toss_and_match FROM
(SELECT match_id FROM ipl_match
WHERE toss_winner = match_winner) AS t2
JOIN ipl_match_schedule
USING(match_id)
GROUP BY stadium_id) AS t4
USING(stadium_id);



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q4
SELECT Team_name, bid_team, Total_bids FROM
(SELECT bid_team, COUNT(bidder_id) as Total_bids FROM ipl_bidding_details
GROUP BY bid_team) AS t1
JOIN ipl_team
ON ipl_team.team_id = t1.bid_team;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q5
SELECT team_id, team_name, win_details, match_id FROM
(SELECT match_id, IF(match_winner = 1, team_id1, team_id2) AS team_id, win_details FROM ipl_match) AS t1
JOIN ipl_team
USING(team_id);



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q6
CREATE VIEW v2 AS
(SELECT team_id1 FROM ipl_match
UNION ALL
SELECT team_id2 FROM ipl_match);

SELECT * FROM v2;

SELECT *, (Total_matches_palyed - Total_matches_won) AS Total_matches_lost FROM
(WITH t3 AS
(SELECT *, COUNT(*) AS Total_matches_won FROM
(SELECT IF(match_winner = 1, team_id1, team_id2) AS team_id FROM ipl_match) AS t2
GROUP BY team_id)

SELECT team_id,team_name,
COUNT(team_id1) AS Total_matches_palyed,
Total_matches_won FROM ipl_team
JOIN v2
ON v2.team_id1 = ipl_team.team_id
JOIN t3 USING(team_id)
GROUP BY team_id) AS t4;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q7
SELECT player_id, player_name, player_role FROM ipl_team_players
JOIN ipl_player USING(player_id)
WHERE team_id = 5 AND player_role = "Bowler";



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q8
SELECT team_id, team_name, Count_of_allrounders FROM ipl_team
JOIN 
(SELECT team_id, COUNT(*) AS Count_of_allrounders FROM ipl_team_players
WHERE player_role = "All-Rounder"
GROUP BY team_id
HAVING Count_of_allrounders > 4
ORDER BY Count_of_allrounders DESC) AS T1
USING(team_id);



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q9
SELECT MIN(YEAR(bid_date)), bid_status, SUM(total_points) FROM ipl_match
JOIN ipl_match_schedule USING(match_id)
JOIN ipl_stadium USING(stadium_id)
JOIN ipl_bidding_details USING(schedule_id)
JOIN ipl_bidder_points USING(bidder_id)
WHERE (team_id1 = 1 OR team_id2 = 1) AND match_winner = 1 AND stadium_name = "M. Chinnaswamy Stadium"
GROUP BY bid_status
ORDER BY SUM(total_points) DESC;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q10
SELECT player_id, CONVERT(wickets_took, DECIMAL) AS wickets_took, player_role FROM ipl_team_players
JOIN
(SELECT player_id, wickets_took FROM
((SELECT *, SUBSTRING(performance_dtls, p1, p2-p1) AS Wickets_took FROM
(SELECT Player_id, performance_dtls, POSITION("wkt" IN performance_dtls) + 4 AS p1 FROM ipl_player) AS t1
JOIN
(SELECT Player_id, POSITION(" Dot" IN performance_dtls) p2 FROM ipl_player) AS t2
USING(player_id))) AS t3) AS t4
USING(player_id)
WHERE player_role = "bowler" OR player_role = "all-rounder"
ORDER BY wickets_took DESC
LIMIT 5;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q11
CREATE VIEW v1 AS
SELECT bidder_id, bid_team, IF(toss_winner = 1, team_id1, team_id2) AS toss_won_team FROM ipl_bidder_details
JOIN ipl_bidding_details USING(bidder_id)
JOIN ipl_match_schedule USING(schedule_id)
JOIN ipl_match USING(match_id);

SELECT * FROM v1; 

SELECT *, ROUND(Count_toss_won/Count_total * 100, 2) AS Percentage  FROM
(SELECT bidder_id, COUNT(*) AS Count_toss_won FROM v1
WHERE bid_team = toss_won_team
GROUP BY bidder_id
ORDER BY bidder_id) AS t1
JOIN
(SELECT bidder_id, COUNT(*) AS Count_total FROM v1
GROUP BY bidder_id
ORDER BY bidder_id) AS t2
USING(bidder_id)
ORDER BY percentage DESC;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q12
SELECT tournmt_id, tournmt_name, DATEDIFF(to_date, from_date) AS Duration FROM ipl_tournament
GROUP BY tournmt_id
ORDER BY duration DESC;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q13
SELECT bidder_id, bidder_name, MIN(YEAR(bid_date)) AS bid_year, MONTH(bid_date) AS bid_month, SUM(Total_points) AS total_points FROM ipl_bidder_details
JOIN ipl_bidding_details USING(bidder_id)
JOIN ipl_bidder_points USING(bidder_id)
WHERE YEAR(bid_date) = 2017
GROUP BY bidder_id,bidder_name, bid_month
ORDER BY total_points DESC, bid_month;



###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################

USE classicmodels;

#Q14
SELECT c.customernumber, c.country, c.creditlimit,
(SELECT COUNT(ordernumber) FROM orders
WHERE customernumber = c.customernumber) AS ordernumber 
FROM customers AS c;

SELECT * FROM
(SELECT customernumber, ROW_NUMBER() OVER(PARTITION BY customernumber) AS orders_rank FROM orders) AS t1
ORDER BY customernumber, orders_rank DESC;

SELECT ordernumber, (priceeach * quantityordered) FROM orderdetails; 

SELECT DISTINCT o.ordernumber, (SELECT SUM(priceeach * quantityordered) FROM orderdetails WHERE ordernumber = o.ordernumber) AS totalOrderValue FROM orderdetails AS o;

SELECT *,(SELECT COUNT(ordernumber) FROM orders WHERE customernumber = t1.customernumber) AS counts FROM
(SELECT c.customernumber, c.country, c.creditlimit, (SELECT AVG(creditlimit) FROM customers WHERE country = c.country) AS avg_CL FROM customers c) AS t1
WHERE creditlimit > avg_cl;

SELECT * FROM 
(SELECT c.customernumber, c.customername, (SELECT COUNT(ordernumber) FROM orders WHERE c.customernumber = customernumber) AS counts FROM customers c) AS t1
WHERE counts = 0;

SELECT * FROM customers;

SELECT DISTINCT customernumber FROM orders;

SELECT * FROM orders WHERE EXISTS(SELECT null);

select "";

USE classicmodels;


SELECT c.customernumber, c.customername FROM customers c
WHERE NOT EXISTS(SELECT ordernumber FROM orders WHERE customernumber = c.customernumber);

SELECT c.customernumber, c.customername, c.addressline2 FROM customers c
WHERE EXISTS(SELECT addressline2 FROM customers WHERE addressline2 IS NULL);

SELECT c.customernumber, c.customername, c.addressline2 FROM customers c
WHERE EXISTS(SELECT addressline2 FROM customers WHERE customernumber = c.customernumber AND addressline2 IS NULL);

SELECT *, (SELECT COUNT(*) FROM orderdetails WHERE p.productcode = productcode) FROM products AS p
WHERE productline = "motorcycles";




###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q15

SELECT * FROM
(SELECT bidder_id, bidder_name, total_points, 
ROW_NUMBER() OVER(ORDER BY total_points) AS Least_Ranking, 
ROW_NUMBER() OVER(ORDER BY total_points DESC) AS Highest_Ranking FROM ipl_bidder_points
JOIN ipl_bidder_details USING(bidder_id)) As t1
WHERE Least_Ranking <= 3
UNION
SELECT * FROM
(SELECT bidder_id, bidder_name, total_points, 
ROW_NUMBER() OVER(ORDER BY total_points) AS Least_Ranking, 
ROW_NUMBER() OVER(ORDER BY total_points DESC) AS Highest_Ranking FROM ipl_bidder_points
JOIN ipl_bidder_details USING(bidder_id)) As t1
WHERE Highest_Ranking <= 3;






###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################



#Q16
CREATE TABLE student_details
(Student_id INT,
Student_name VARCHAR(50),
mail_id VARCHAR(50),
mobile_no INT);

ALTER TABLE student_details
MODIFY mobile_no BIGINT;

CREATE TABLE student_details_backup
(Student_id INT,
Student_name VARCHAR(50),
mail_id VARCHAR(50),
mobile_no INT);

ALTER TABLE student_details_backup
MODIFY mobile_no BIGINT;

INSERT INTO student_details
VALUES(152, "Dileep", "Dileep@student.com", 9676150614);

SELECT * FROM student_details;

DELETE FROM student_details_backup;

DROP TRIGGER insert_student_backup4;


-- ---------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER insert_student_backup4
AFTER UPDATE ON Student_details
FOR EACH ROW
BEGIN
    INSERT INTO student_details_backup
	VALUES (OLD.student_id, OLD.student_name, OLD.mail_id, OLD.mobile_no);
END$$
DELIMITER ;

-- ---------------------------------------------------------------------------------------------------------

UPDATE student_details
SET mobile_no = 9676150611
WHERE student_id = 152;

SELECT * FROM student_details;
SELECT * FROM student_details_backup;


###################################################################################
-- --------------------------------------------------------------------------------
###################################################################################

USE dileepdatabase;

CREATE TABLE customers
(cust_id INT PRIMARY KEY,
cust_name VARCHAR(50));


CREATE TABLE stock
(prod_id INT PRIMARY KEY,
prod_name VARCHAR(50),
stock INT);


CREATE TABLE orders
(ord_id INT PRIMARY KEY,
cust_id INT,
prod_id INT,
qty INT,
FOREIGN KEY (cust_id) REFERENCES customers(cust_id),
FOREIGN KEY (prod_id) REFERENCES stock(prod_id));

INSERT INTO customers
VALUES
(1, "Dileep"),
(2, "Kill Bill Pandey");

INSERT INTO stock
VALUES
(101, "AK-47", 100),
(102, "AKM", 10),
(103, "Bullet Proof Vest", 450);


DELIMITER $$
CREATE TRIGGER stockupdate
AFTER INSERT ON orders
FOR EACH ROW
BEGIN

UPDATE stock
SET stock = stock - new.qty
WHERE prod_id = new.prod_id;

END$$
DELIMITER ;

INSERT INTO orders
VALUES(201, 1, 102, 3);





























