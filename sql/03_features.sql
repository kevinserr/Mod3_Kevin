-- Feature 1
--Gets the number of hours a guest spent in the park.
ALTER TABLE fact_visits ADD COLUMN hours_spent_in_park INTEGER;

ALTER TABLE fact_visits RENAME COLUMN hours_spent_in_park TO stay_hours
  
UPDATE fact_visits
SET stay_hours = CAST(FLOOR((JULIANDAY(exit_time) - JULIANDAY(entry_time) )* 24)*100 AS REAL) / 100


-- Feature 2
-- Add Column with dollars spend
ALTER TABLE fact_visits ADD COLUMN spend_dollars REAL;

UPDATE fact_visits
SET spend_dollars = spend_cents_clean/100.0

-- ADD dollar sign
UPDATE fact_visits
SET spend_dollars = '$' || spend_dollars

-- Feature 3
-- Creates a new column satisfaction category with either satisfied or unsatisfied. 
ALTER TABLE fact_ride_events ADD COLUMN satisfaction_category

UPDATE fact_ride_events 
SET 
  satisfaction_category = CASE 
    WHEN satisfaction_rating <=3 THEN 'UNSATISFIED'
    WHEN satisfaction_rating >=4 THEN 'SATISFIED'
    WHEN satisfaction_rating IS NULL THEN null
  END 

SELECT satisfaction_category,count(*) AS num_of_visits
FROM fact_ride_events
GROUP BY satisfaction_category

-- Feature 4

ALTER TABLE fact_ride_events ADD COLUMN wait_category

UPDATE fact_ride_events
SET wait_category = CASE 
    WHEN wait_minutes <30 THEN 'Short Wait'
    WHEN wait_minutes BETWEEN 30 and 60 THEN 'Medium Wait'
    WHEN wait_minutes > 60 THEN 'Long Wait'
    ELSE 'NA'
  END
