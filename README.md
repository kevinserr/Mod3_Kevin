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
``` sqlite
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
``` sqlite
SELECT a.attraction_name, a.category, 
       AVG(r.satisfaction_rating) AS avg_rating
FROM fact_ride_events r
JOIN dim_attraction a ON r.attraction_id = a.attraction_id
GROUP BY a.attraction_name, a.category
ORDER BY avg_rating DESC;
```
**WHY:** Identifies which rides have long waits so operations can target fixes.

### Average Party Size by Day of Week
I joined fact_visits with dim_date to understand how group size vary across weekdays. Larger average party sizes may indicate higher group traffic which affects staffing. 
``` sqlite
SELECT DISTINCT(dte.day_name) AS day_of_week, ROUND(AVG(vist.party_size),2) AS avg_party_size
FROM fact_visits AS vist
INNER JOIN dim_date dte ON vist.date_id = dte.date_id
GROUP BY day_of_week
ORDER BY avg_party_size DESC
```
**WHY:** Identifies peak party-size days in order to align weekend staffing and targeted marketing for families/groups

- 3 MAIN things that you explored and why (no giant query dumps –
but can embed code snippets; link to /sql/01_eda.sql)

# Feature Engineering (SQL) 
- features you created + short rationale

# CTEs & Window Functions (SQL) 
- include short code snippets of your key CTE/window queries and link to the SQL Query file

# Visuals (Python) 
- embed your 3 saved images with 1–2 line captions each

# Insights & Recommendations
-concrete actions for GM, Ops, AND Marketing
# Ethics & Bias 
- data quality, missing values, duplicates, margin not modeled,
time window, etc.
# Repo Navigation 
- /sql, /notebooks, /figures, /data
