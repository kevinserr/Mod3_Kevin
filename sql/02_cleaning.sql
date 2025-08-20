-- Part A 37 rows affected in fact_visits.spend_cents_clean
WITH c AS (
  SELECT
  rowid AS rid,
  REPLACE(REPLACE(REPLACE(REPLACE(UPPER(COALESCE(total_spend_cents,'')),
  'USD',''), '$',''), ',', ''), ' ', '') AS cleaned
  FROM fact_visits
)
UPDATE fact_visits
SET spend_cents_clean = CAST((SELECT cleaned FROM c WHERE c.rid = fact_visits.rowid)
AS INTEGER)
WHERE LENGTH((SELECT cleaned FROM c WHERE c.rid = fact_visits.rowid)) > 0;

-- 54 rows were affected in fact_purchases.amount_cents_clean
WITH c AS (
  SELECT
  rowid AS rid,
  REPLACE(REPLACE(REPLACE(REPLACE(UPPER(COALESCE(amount_cents,'')),
  'USD',''), '$',''), ',', ''), ' ', '') AS cleaned
  FROM fact_purchases
)
UPDATE fact_purchases
SET amount_cents_clean = CAST((SELECT cleaned FROM c WHERE c.rid = fact_purchases.rowid)
AS INTEGER)
WHERE LENGTH((SELECT cleaned FROM c WHERE c.rid = fact_purchases.rowid)) > 0;

-- B) Exact Duplicates USING CTE
-- find duplicates in fact_ride_events
WITH dups_ride_count AS (
  SELECT count(*) AS duplicated_event 
  FROM fact_ride_events
  GROUP BY visit_id, attraction_id, ride_time, wait_minutes, satisfaction_rating, photo_purchase
  HAVING duplicated_event > 1
),
-- finds duplicates in fact_purchases
dups_purchase AS (
  SELECT count(*) AS duplicated_purchase
  FROM fact_purchases
  GROUP BY visit_id, category,item_name,amount_cents,payment_method,amount_cents_clean
  HAVING duplicated_purchase >1
),
-- finds duplicates in fact_visits
dups_visits AS(
  SELECT count(*) AS duplicated_visits
  FROM fact_visits
  GROUP BY guest_id,ticket_type_id,visit_date, date_id,party_size,entry_time,exit_time,total_spend_cents,promotion_code,spend_cents_clean
  HAVING duplicated_visits > 1
)
SELECT 
  IFNULL(SUM(duplicated_event),0) AS count_of_duplicated_ride_events,
  (
    SELECT IFNULL(SUM(duplicated_purchase),0)
    FROM dups_purchase
  )AS count_of_duplicated_purchases ,
  (SELECT 
    IFNULL(SUM(duplicated_visits),0)
    FROM dups_visits
  ) AS count_of_duplicated_visits
FROM dups_ride_count

/*
Think: If there are duplicates how can you decide which one to keep? Is there a
way you could code this in SQL? Add your thoughts as a comment in your .sql
file
I would use rowid to assign each row a unique identifier
I would then use MIN(ROW) to select the first occurence of a row
grouped by all_column names. For example for fact_purchases
DELETE FROM fact_purchases
WHERE ROWID NOT IN (
  SELECT MIN(ROWID)
  FROM fact_purchases
  GROUP BY visit_id, category,item_name,amount_cents,payment_method,amount_cents_clean
)
*/

-- Part C Validate keys (what it mean + an example)
SELECT v.visit_id, v.guest_id
FROM fact_visits v
LEFT JOIN dim_guest g ON g.guest_id = v.guest_id
WHERE g.guest_id IS NULL

SELECT v.visit_id, v.ticket_type_id
FROM fact_visits v
LEFT JOIN dim_ticket t ON t.ticket_type_id = v.ticket_type_id
WHERE t.ticket_type_id  IS NULL

SELECT d.date_id
FROM dim_date d
LEFT JOIN fact_visits v ON v.date_id = d.date_id
WHERE d.date_id IS NULL

SELECT e.visit_id
FROM fact_ride_events e
LEFT JOIN fact_visits v ON v.visit_id = e.visit_id
WHERE e.visit_id IS NULL

SELECT e.attraction_id
FROM fact_ride_events e
LEFT JOIN dim_attraction da ON e.attraction_id = da.attraction_id
WHERE e.attraction_id IS NULL 

SELECT p.visit_id
FROM fact_purchases p 
LEFT JOIN fact_visits v ON p.visit_id = v.visit_id
WHERE p.visit_id IS NULL

-- No orphans 

-- D Handling Missing Values

-- in promotion_code, I replaced the dash with space, trim and upper
-- 47 rows were affected
UPDATE fact_visits
SET promotion_code = UPPER(REPLACE(TRIM(promotion_code),'-',''))

-- Uppers and Removes white space in dim_guest.home_state, 10 rows affected
UPDATE dim_guest
SET home_state = UPPER(TRIM(home_state))

-- replaces New York with NY and California with CA
-- 10 rows affected
UPDATE dim_guest
SET home_state = REPLACE(home_state, 'NEW YORK', 'NY'),
  home_state = REPLACE(home_state, 'CALIFORNIA', 'CA')


