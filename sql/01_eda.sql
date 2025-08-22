-- Q0: Row counts per table
SELECT 'dim_guest' AS table_name, COUNT(*) AS n FROM dim_guest
UNION ALL SELECT 'dim_ticket', COUNT(*) FROM dim_ticket
UNION ALL SELECT 'dim_attraction', COUNT(*) FROM dim_attraction
UNION ALL SELECT 'fact_visits', COUNT(*) FROM fact_visits
UNION ALL SELECT 'fact_ride_events', COUNT(*) FROM fact_ride_events
UNION ALL SELECT 'fact_purchases', COUNT(*) FROM fact_purchases;



-- Q1 :Date range of visit_date; number of distinct dates; visits per date 
-- (use GROUP BY + ORDER BY).
SELECT DISTINCT(visit_date), -- SELECTS the distinct visit dates
  COUNT(*) AS Number_of_Visits -- Counts of the number of visits
FROM fact_visits 
GROUP BY visit_date -- Groups by visit_date
ORDER BY Number_of_Visits DESC -- sorted by number of visits from large to small

-- Q2 Visits by ticket_type_name (join to dim_ticket), ordered by most to least
SELECT 
  DISTINCT(dt.ticket_type_name) AS ticket_name, -- selects distinct name of ticket type
  COUNT(*) AS number_of_visits -- counts the number of visits
FROM fact_visits fv
INNER JOIN dim_ticket dt ON fv.ticket_type_id = dt.ticket_type_id -- joins fact_visits with dim_ticket
GROUP BY ticket_name -- groups by ticket name
ORDER BY number_of_visits DESC -- sorted by number of visits from large to small

-- Q3 Distribution of wait_minutes (include NULL count separately).
/**
Creates categories based on the wait_minutes
less than 30 is short, between 30 and 60 is medium and more than 60 is long
**/
WITH bins AS (
  SELECT 
    attraction_id, wait_minutes,
    CASE 
      WHEN wait_minutes <30 THEN 'Short Wait'
      WHEN wait_minutes BETWEEN 30 and 60 THEN 'Medium Wait'
      WHEN wait_minutes > 60 THEN 'Long Wait'
      ELSE 'NULL'
    END AS wait_category    
  FROM fact_ride_events
  ORDER BY wait_category
)
-- displays the number of guest who experience short, medium and long wait times
SELECT wait_category, COUNT(*) AS quantity
FROM bins
GROUP BY wait_category
ORDER BY quantity DESC
  

-- Q4. Average satisfaction_rating by attraction_name and by category.
-- dim_attraction & fact_ride_events
-- Joins ride_event with dim_atttraction to display the name of each attraction
-- its category and average satisfaction rating
SELECT 
  dim_attraction.attraction_name AS name,
  dim_attraction.category, 
  ROUND(AVG(fact_ride_events.satisfaction_rating),2) AS satisfaction_rating
FROM dim_attraction
INNER JOIN fact_ride_events ON dim_attraction.attraction_id = fact_ride_events.attraction_id
GROUP BY dim_attraction.attraction_name, dim_attraction.category
ORDER BY satisfaction_rating DESC
  
-- Q5 Duplicates check: exact duplicate fact_ride_events rows (match on all columns) with counts.
SELECT visit_id, count(*) AS number_of_duplicates
FROM fact_ride_events
GROUP BY visit_id, attraction_id, ride_time, wait_minutes, satisfaction_rating, photo_purchase
HAVING count(*) >1

-- Q6. Null audit for key columns you care about (report counts).
SELECT COUNT(*) AS total_spend_cents_missing, (
  SELECT COUNT(*)
  FROM fact_purchases
  WHERE amount_cents IS NULL 
)AS amount_cents_missing
FROM fact_visits
WHERE total_spend_cents IS NULL

-- Q7. Average party_size by day of week (dim_date.day_name)
SELECT DISTINCT(dte.day_name) AS day_of_week, ROUND(AVG(vist.party_size),2) AS avg_party_size
FROM fact_visits AS vist
INNER JOIN dim_date dte ON vist.date_id = dte.date_id
GROUP BY day_of_week
ORDER BY avg_party_size DESC




  