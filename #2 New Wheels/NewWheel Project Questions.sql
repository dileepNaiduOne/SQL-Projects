USE supply_chain;
/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*[Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/

SELECT state, COUNT(customer_id) FROM customer_t
GROUP BY state;

/* 
= = = OBSERVATION = = =
By Executing the above query we get California & Texas has highest number of customers.
That is 97. And, Maine, Wyoming, & Vermont have least customer count that is 1.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.*/

SELECT Quarter_number, AVG(IF(customer_feedback = "Very Bad", 1,
IF(customer_feedback = "Bad", 2, 
IF(customer_feedback = "Okay", 3, 
IF(customer_feedback = "Good", 4, 5))))) 
AS `Average Rating`
FROM order_t
GROUP BY Quarter_number
ORDER BY quarter_number;

/* 
= = = OBSERVATION = = =
By Executing the above query we get 
Quarter 1 - 3.5548, 
Quarter 2 - 3.3550,
Quarter 3 - 2.9563,
Quarter 4 - 2.3970.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. 
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  And find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
SELECT quarter_number, 
CONCAT(ROUND(SUM(IF(customer_feedback = "Very Bad", 1, 0))/COUNT(customer_feedback) * 100, 2), "%") AS `Very Bad`,
CONCAT(ROUND(SUM(IF(customer_feedback = "Bad", 1, 0))/COUNT(customer_feedback) * 100, 2), "%") AS Bad, 
CONCAT(ROUND(SUM(IF(customer_feedback = "Okay", 1, 0))/COUNT(customer_feedback) * 100, 2), "%") AS `Okay`,
CONCAT(ROUND(SUM(IF(customer_feedback = "Good", 1, 0))/COUNT(customer_feedback) * 100, 2), "%") AS Good, 
CONCAT(ROUND(SUM(IF(customer_feedback = "Very Good", 1, 0))/COUNT(customer_feedback) * 100, 2), "%") AS `Very Good` FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

/* 
= = = OBSERVATION = = =
By Executing the above query we can highlight that in Quarter 1, 2, & 3 most of the people gave very good feedback.
But suddenly is Quarter 4, around 60% of people gave bad feedback.
May be this is because of the transport medium. Most of the Air shipping products got bad feedback.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT vehicle_maker, COUNT(order_id) AS order_count FROM product_t
JOIN order_t
ON product_t.product_id = order_t.product_id
GROUP BY vehicle_maker
ORDER BY order_count DESC
LIMIT 5;

/* 
= = = OBSERVATION = = =
By Executing the above query we can showcase that
Chevrolet with order count 83,
Ford with 63,
Toyota with 52,
Pontiac with 50,
Dodge with 50 count got ordered most times.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

#doubt
/*[Q5] What is the most preferred vehicle make in each state?*/

SELECT State, vehicle_maker, COUNT(order_t.order_id) AS count FROM customer_t
JOIN order_t
ON customer_t.customer_id = order_t.customer_id
JOIN product_t
ON product_t.product_id = order_t.product_id
GROUP BY state, vehicle_maker
ORDER BY state, count DESC;

/* 
= = = OBSERVATION = = =
By Executing the above query we can tell that In Texas Chevrolet is preferred most.
Remaining data can be seen in the output table.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT quarter_number, COUNT(order_id) FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;



/* 
= = = OBSERVATION = = =
By Executing the above query we get 
Quarter 1 - 310 orders, 
Quarter 2 - 262,
Quarter 3 - 229,
Quarter 4 - 199.
*/



-- ---------------------------------------------------------------------------------------------------------------------------------

#doubt
/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      
*/
      
SELECT quarter_number, SUM(Vehicle_price) AS Price FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

/* 
= = = OBSERVATION = = =
By Executing the above query we get 
Quarter 1 - 26,519,199.19, 
Quarter 2 - 21,595,874.35,
Quarter 3 - 19,719,917.59,
Quarter 4 - 15,280,009.98.
*/

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

SELECT quarter_number, SUM(Vehicle_price) AS Price, COUNT(order_id) AS Count FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number; 

/* 
= = = OBSERVATION = = =
By Executing the above query we get the result. 
The is answer is none another but the joining of the above two queries.
*/

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT credit_card_type, AVG(discount) FROM order_t
RIGHT JOIN customer_t
ON order_t.customer_id = customer_t.customer_id
GROUP BY credit_card_type;

/* 
= = = OBSERVATION = = =
By Executing the above query we get 
That most discount is given on laser Credit Card
And least is Diners Club International
*/

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT quarter_number, AVG(DATEDIFF(ship_date, order_date)) AS Average_delay FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

/* 
= = = OBSERVATION = = =
By Executing the above query we get 
Quarter 1 - 57 Days, 
Quarter 2 - 71 Days,
Quarter 3 - 117 Days,
Quarter 4 - 174 Days.
*/

-- --------------------------------------------------------Final Verdict----------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------- 
-- The reason for the bad feedback, least orders and bad rating is because of the delay in delivery. 
-- It took on an average 174 days to get an order. This triggered the customer and made their experience bad.
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



