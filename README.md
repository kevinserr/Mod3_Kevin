# Beyond the Gate: Driving Guest Satisfaction and Profitability Together
By Kevin Serrano Lopez

# Business Problem
The Supernova theme park is struggling with uneven guest satisfaction and inconsistent revenue, driven by long attraction wait times, unpredictable ride availability, and overcrowding. At the same time, marketing campaigns are drawing visitors but not always the most profitable ones, as discount-driven guests often spend less in-park. Leadership needs a coordinated strategy that balances operational efficiency with targeted marketing to improve both guest experience and overall profitability.

# Stakeholders
### Primary Stakeholder: 
 - Park General Manager (GM) – accountable for overall park performance, satisfaction, and revenue outcomes.
### Supporting Stakeholders:
- Operations Director – focused on staffing, queue management, and ride uptime, since these directly impact guest satisfaction
- Marketing Director – responsible for promotions and ticket sales strategy, ensuring campaigns attract high-value guests and support revenue growth.

# Overview of Database & Schema
### Dimension tables: 
- dim_guest, dim_ticket, dim_attraction, dim_date
- stores descriptive attributes about guests, tickets, attractions (rides) and time. They store the context behind each visit.
### Fact Tables :
- fact_visits, fact_ride_events, fact_purchases
- They capture measurable events like park entry, ride usage and purchases
- Hold numeric values that can be aggregated.

#### Star Schema Benefits
- Simplifies analysis, facts are in the middle and easy to join with descriptive dimensions
- Faster queries - Aggregations are efficient
- Flexiblity - easier to look into performance by guest without restructuring the data

# [**EDA (SQL)**](./sql/01_eda.sql)

### Visits by Ticket Type
I explored visit patterns over time and by ticket type, joinng fact_visits to dim_ticket. This highlights which ticket category drives the most visits and the distribution of volumn across days of the week.
```sql
SELECT 
  DISTINCT(dt.ticket_type_name) AS ticket_name,
  COUNT(*) AS number_of_visits -- counts the number of visits
FROM fact_visits fv
INNER JOIN dim_ticket dt ON fv.ticket_type_id = dt.ticket_type_id
GROUP BY ticket_name 
ORDER BY number_of_visits DESC 
```
**WHY:** Helps marketing understand which promotions/ticket types attract volume, and operations gauge crowding trends

### Guest Experience: Waits & Satisfaction
I analyzed fact_ride_events for wait time distributions and average satisfiaction ratings by attraction (full code in link above). This connects wait time  with guest rating.
```sql
SELECT
  a.attraction_name,
  a.category, 
  AVG(r.satisfaction_rating) AS avg_rating
FROM fact_ride_events r
JOIN dim_attraction a ON r.attraction_id = a.attraction_id
GROUP BY a.attraction_name, a.category
ORDER BY avg_rating DESC;
```
**WHY:** Identifies which rides have long waits so operations can target fixes.

### Average Party Size by Day of Week
I joined fact_visits with dim_date to understand how group size vary across weekdays. Larger average party sizes may indicate higher group traffic which affects staffing. 
```sql
SELECT
  DISTINCT(dte.day_name) AS day_of_week,
  ROUND(AVG(vist.party_size),2) AS avg_party_size
FROM fact_visits AS vist
INNER JOIN dim_date dte ON vist.date_id = dte.date_id
GROUP BY day_of_week
ORDER BY avg_party_size DESC
```
**WHY:** Identifies peak party-size days in order to align weekend staffing and targeted marketing for families/groups



# [**Feature Engineering (SQL)**](./sql/03_eda.sql)


| **Feature**  | **Description** | **Why it Matters** |
|---|---|---|
| `stay_hours`| Number of hours a guest spent in the park (exit_time – entry_time).| GM & Ops care because longer stays mean more spending opportunities and higher operational load. |
| `spend_dollars` | Converts spend from cents to dollars; enables per-person spend analysis.| Marketing values spend-per-person to identify high-value guests, not just large groups. |
| `satisfaction_category` | Groups satisfaction ratings into **Satisfied (≥4)** or **Unsatisfied (≤3)**.  | Easier for Ops & leadership to see which attractions drive poor experiences.                     |
| `wait_category`  | Buckets wait times into **Short (<30)**, **Medium (30–60)**, **Long (>60)**.  | Helps Ops adjust staffing, throughput, and scheduling at attractions with long queues. |


# [**CTEs & Window Functions (SQL)**](./sql/03_eda.sql)
This sql query demonstrates advanced SQL patterns with CTEs and window functions.  
Key highlights:

| **Query**          | **Techniques**                   | **Business Value** |
|---------------------|-----------------------------------|---------------------|
| Daily Performance   | CTEs, Running Totals (`SUM OVER`) | Track visits/spend and cumulative trends |
| RFM & CLV           | Multi-CTEs, Ranking (`RANK OVER`) | Identify high-value customers by state |


---
### 1. Daily Performance  
Track visits and spend per day, with running totals.  

```sql
WITH daily_performance AS (
  SELECT d.day_name,
         COUNT(v.visit_id) AS daily_visits,
         ROUND(SUM(v.spend_dollars),2) AS daily_spent
  FROM fact_visits v
  INNER JOIN dim_date d ON v.date_id = d.date_id
  GROUP BY d.day_name
),
daily_with_running AS (
  SELECT day_name, daily_visits, daily_spent,
         SUM(daily_visits) OVER (ORDER BY day_name) AS running_visits,
         SUM(daily_spent) OVER (ORDER BY day_name) AS running_spent
  FROM daily_performance
)
SELECT * FROM daily_with_running;
```

### 2. RFM & CLV
Rank customers by spend within their home state.
```sql
WITH customer_perf AS (
  SELECT g.guest_id,
         g.home_state,
         ROUND(SUM(v.spend_dollars),2) AS total_spent,
         MAX(v.visit_date) AS last_visit_date,
         COUNT(v.visit_id) AS frequency
  FROM dim_guest g
  INNER JOIN fact_visits v ON g.guest_id = v.guest_id
  GROUP BY g.guest_id
),
ranked AS (
  SELECT *,
         RANK() OVER (
           PARTITION BY home_state
           ORDER BY total_spent DESC
         ) AS customer_rank_in_state
  FROM customer_perf
)
SELECT * FROM ranked
ORDER BY home_state, customer_rank_in_state;
```



# Visuals (Python) 

### Figure 1
![Chart showing daily performance](figures/daily_attendance.png)


### Figure 2
![Chart showing Rating VS Attraction](figures/ratingByAttraction.png)


### Figure 3
![Chart showing wait times](figures/waitTimes.png)


- embed your 3 saved images with 1–2 line captions each

# Insights & Recommendations
-concrete actions for GM, Ops, AND Marketing
# Ethics & Bias 
- data quality, missing values, duplicates, margin not modeled,
time window, etc.
# Repo Navigation 
- /sql, /notebooks, /figures, /data
