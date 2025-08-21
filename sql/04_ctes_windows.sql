-- 1. Daily Performance
WITH daily_performance AS (
  SELECT 
    d.day_name, 
    COUNT(v.visit_id) AS daily_visits,
    ROUND(SUM(v.spend_dollars),2) AS daily_spent
  FROM fact_visits v
  INNER JOIN dim_date d ON v.date_id = d.date_id
  WHERE spend_dollars IS NOT NULL
  GROUP BY d.day_name
),
daily_with_running AS (
  SELECT 
    day_name, daily_visits, daily_spent,
    SUM(daily_visits) OVER (ORDER BY day_name) AS running_visits,
    ROUND(SUM(daily_spent) OVER (ORDER BY day_name),2) AS running_spent
  FROM daily_performance
  
)
SELECT *
FROM daily_with_running
ORDER BY day_name 

-- 2. RFM & CLV 
WITH customer_individual_perf AS(
  SELECT
    g.guest_id, -- displays guest_id from dim_guest table
    g.first_name || ' ' || g.last_name AS full_name, -- concats first_name and last_name as full_name
    g.home_state, -- displays home_state from dim_guest
    ROUND(SUM(v.spend_dollars),2) AS total_spent, -- rounds the sums of total spent in dollars displays as total_spent
    MAX(v.visit_date) AS last_visit_date, -- Finds most recent visit_date
    COUNT(v.visit_id) AS frequency -- counts the number of visits
  FROM dim_guest g
  INNER JOIN fact_visits v ON g.guest_id = v.guest_id -- Joins dim_guest with facts_visits
  INNER JOIN dim_date d ON v.date_id = d.date_id -- joins dim_date with fact_visits
  WHERE v.spend_dollars IS NOT NULL -- displays results where spend_dollars is not null
  GROUP BY g.guest_id, g.first_name, g.last_name, g.home_state -- groups by guest_id, first and last name, homestate
),
guest_rfm AS ( -- second CTE to display days since last vist
  SELECT 
    g.*, -- selects all column names from previous table
    JULIANDAY(CURRENT_DATE) - JULIANDAY(last_visit_date)  AS recency_days -- display days since last vist
  FROM customer_individual_perf g
),
ranked AS ( -- CTE to rank within state
  SELECT *, -- SELECTS ALL COLUMNS
    RANK() OVER ( -- RANKS based on total_spent within home_state
      PARTITION BY home_state
      ORDER BY total_spent DESC
    ) AS customer_rank_in_state
  FROM guest_rfm
)
SELECT -- FINAL SELECT statement to display results
  *
FROM ranked 
ORDER BY home_state, customer_rank_in_state -- orders the query by home_state, and their respective rank

-- 3 Behavior Change
/**
visit_deltas CTE: for each guest looks at its visits
Orders them by d.day_name(visit_date)
Uses LAG() to pull in the previous visit's spend for comparison

deltas CTE : keeps only rows where we have a prior fact_visit
  Computes delta = spend_dollars - prior_spend which is the change
  in spend from last time. 
**/
WITH visit_deltas AS (
  SELECT v.visit_id,
  g.guest_id,
  d.day_name AS visit_date,
  v.spend_dollars,
  LAG(v.spend_dollars) OVER ( -- gets previous spent
    PARTITION BY g.guest_id
    ORDER BY d.day_name
  ) AS prior_spend
  FROM fact_visits v
  INNER JOIN dim_guest g ON v.guest_id = g.guest_id
  INNER JOIN dim_date d ON v.date_id = d.date_id
  WHERE v.spend_dollars IS NOT NULL 
),deltas AS (
  SELECT
    guest_id,
    visit_id,
    visit_date,
    spend_dollars,
    prior_spend,
    (spend_dollars - prior_spend) AS delta -- computes delta spend_dollars minus prior spent
  FROM visit_deltas
  WHERE prior_spend IS NOT NULL   -- exclude first visits
)
/**
Counts how many visits were increased, decreased, or no change
  when compared to their prior visit.
Divides by total visits to get percentage 
**/
SELECT
  -- Multiples by 100 to get percentage and rounds to the second decimal place
  -- the sum of when delta is more than 0, less than 0 or equal to 0 divided by the number of overall frequency
  ROUND((100.0 * SUM(CASE WHEN delta > 0 THEN 1 ELSE 0 END) / COUNT(*)),2) || '%' AS pct_increased,
  ROUND((100.0 * SUM(CASE WHEN delta < 0 THEN 1 ELSE 0 END) / COUNT(*)),2) || '%' AS pct_decreased,
  ROUND((100.0 * SUM(CASE WHEN delta = 0 THEN 1 ELSE 0 END) / COUNT(*)),2) || '%' AS pct_same
FROM deltas


-- 4. Ticket switching
/**
ticket_switching CTE : selects ticket_name as current_ticket_name
uses FIRST_value to get a guest's first ticket_type and ticket_type_price

switch_case CTE: compares cases where if the current ticket price is more then the initial then its the guest 'UPGRADED'
if current is less than inital then they downgraded
other wise its the same
**/
WITH ticket_switching AS (
  SELECT 
    v.guest_id,t.ticket_type_name AS current_ticket_name,
    t.base_price_cents /100.0 AS current_ticket_price,
    FIRST_VALUE(t.ticket_type_name) OVER (PARTITION BY v.guest_id ORDER BY guest_id ) AS initial_ticket,
    FIRST_VALUE(base_price_cents) OVER (PARTITION BY v.guest_id ORDER BY guest_id )/100.0 AS initial_ticket_price
  FROM fact_visits v
  INNER JOIN dim_ticket t ON v.ticket_type_id = t.ticket_type_id
), 
switch_case AS (
  SELECT *,
    CASE 
      WHEN current_ticket_price > initial_ticket_price THEN 'UPGRADED'
      WHEN current_ticket_price < initial_ticket_price THEN 'DOWNGRADED'
      WHEN current_ticket_price = initial_ticket_price THEN 'SAME'
     END AS outcome
  FROM ticket_switching
) -- FINAL SELECT displays outcome, and its frequency, grouped outcome and sorted by frequency
SELECT 
  outcome, 
  COUNT(*) AS frequency
FROM switch_case
GROUP BY outcome
ORDER BY frequency DESC