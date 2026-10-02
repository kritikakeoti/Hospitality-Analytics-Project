Use Hospitality_Data;
SELECT * FROM dim_date;

SELECT * FROM dim_hotels;

SELECT * FROM dim_rooms;
SELECT * FROM fact_aggregated_bookings;
CREATE TABLE fact_bookings (
booking_id VARCHAR(30),
property_id INT,
booking_date DATE,
check_in_date DATETIME,
checkout_date DATETIME,
no_guests INT,
room_category VARCHAR(10),
booking_platform VARCHAR(50),
ratings_given FLOAT,
booking_status VARCHAR(50),
revenue_generated FLOAT,
revenue_realized FLOAT,
customer_id INT,
payment_method VARCHAR(50),
stay_duration INT,
cancellation_reason VARCHAR(100),
is_loyalty_member BOOLEAN,
country VARCHAR(50),
customer_age INT,
special_requests VARCHAR(50),
discount_applied FLOAT,
booking_channel VARCHAR(50),
successful_bookings INT
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_bookings.csv'
INTO TABLE fact_bookings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
booking_id,
property_id,
@booking_date,
@check_in_date,
@checkout_date,
no_guests,
room_category,
booking_platform,
@ratings_given,
booking_status,
revenue_generated,
revenue_realized,
customer_id,
payment_method,
stay_duration,
cancellation_reason,
@is_loyalty_member,
country,
customer_age,
special_requests,
discount_applied,
booking_channel
)

SET
booking_date = STR_TO_DATE(@booking_date,'%d-%m-%Y'),
check_in_date = STR_TO_DATE(@check_in_date,'%d-%m-%Y %H:%i'),
checkout_date = STR_TO_DATE(@checkout_date,'%d-%m-%Y %H:%i'),

ratings_given =
CASE
WHEN @ratings_given = '' THEN NULL
WHEN @ratings_given = 'NaN' THEN NULL
ELSE @ratings_given
END,

is_loyalty_member =
CASE
WHEN @is_loyalty_member = 'TRUE' THEN 1
WHEN @is_loyalty_member = 'FALSE' THEN 0
ELSE NULL
END,

successful_bookings =
CASE
WHEN booking_status = 'Checked Out' THEN 1
ELSE 0
END;

SELECT COUNT(*) FROM fact_bookings;
SELECT * FROM fact_bookings LIMIT 10;

-- 1 TOTAL REVENUE --

SELECT SUM(revenue_realized) AS Total_Revenue_Realized
FROM fact_bookings;

-- 2 TOTAL BOOKINGS --

SELECT COUNT(*) AS Total_Bookings
FROM fact_bookings;

-- 3 OCCUPANCY % --

SELECT SUM(successful_bookings) / SUM(capacity) * 100 AS Occupancy_Rate
FROM fact_aggregated_bookings;

-- 4 CANCELLATION % --

SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS Cancellation_Percentage
FROM fact_bookings
WHERE booking_status = 'Cancelled';

-- 5 UTILIZED CAPACITY --

SELECT COUNT(*) AS Utilized_Capacity
FROM fact_bookings;

-- 6 CAPACITY OF THE TOTAL ROOMS --

SELECT SUM(capacity) AS Total_Room_Capacity
FROM fact_aggregated_bookings;

-- 7 TOTAL SUCCESSFUL BOOKINGS --

SELECT SUM(successful_bookings) AS Total_Successful_Bookings
FROM fact_aggregated_bookings;

-- 8 AVERAGE RATINGS --

SELECT AVG(ratings_given) AS Average_Rating
FROM fact_bookings;

-- 9 TOTAL NO OF DAYS --

SELECT DATEDIFF('2024-07-31', '2024-05-01') + 1 AS total_days;

-- 10 TOTAL CANCELLED BOOKINGS --

SELECT COUNT(*) AS Total_Cancelled_Bookings
FROM fact_bookings
WHERE booking_status = 'Cancelled';

-- 11 TOTAL CHECKED OUT --

SELECT COUNT(*) AS Total_Checked_Out
FROM fact_bookings
WHERE booking_status = 'Checked Out';

-- 12 NO SHOW --

SELECT COUNT(*) AS Total_No_Show_Bookings
FROM fact_bookings
WHERE booking_status = 'No Show';

-- 13 NO SHOW % --

SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings)) AS No_Show_Percentage
FROM fact_bookings
WHERE booking_status = 'No Show';

-- 14 Booking platform & Booking platform % --

SELECT 
    booking_platform, 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings) AS Booking_Platform_Percentage
FROM 
    fact_bookings
GROUP BY 
    booking_platform;
    
-- 15 Room Class & Room Class % --

SELECT 
    room_class, 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings) AS Room_Class_Percentage
FROM 
    fact_bookings fb
JOIN 
    dim_rooms dr ON fb.room_category = dr.room_id
GROUP BY 
    room_class;  
    
-- 16 ADR --

SELECT 
    SUM(revenue_realized) / COUNT(DISTINCT check_in_date) AS ADR
FROM 
    fact_bookings;
    
-- 17 REALIZATION % --   

SELECT 
1 - (
    (SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) +
    (SUM(CASE WHEN booking_status = 'No Show' THEN 1 ELSE 0 END) * 1.0 / COUNT(*))
) AS Realisation_Percentage
FROM fact_bookings;

-- 18 RevPAR --

SELECT 
SUM(revenue_realized) /
(SELECT SUM(capacity) FROM fact_aggregated_bookings) AS RevPAR
FROM fact_bookings;

-- 19 DBRN --

SELECT 
SUM(successful_bookings) / 92 AS DBRN
FROM fact_aggregated_bookings;


-- 20 DSRN --

SELECT 
SUM(capacity) / 92 AS DSRN
FROM fact_aggregated_bookings;

-- 21 DURN --

SELECT 
COUNT(*) / 92 AS DURN
FROM fact_bookings
WHERE booking_status = 'Checked Out';

