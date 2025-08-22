# Beyond the Gate: Driving Guest Satisfaction and Profitability Together
By Kevin Serrano Lopez

# Business Problem
The Supernova theme park is struggling with uneven guest satisfaction and inconsistent revenue, driven by long attraction wait times, unpredictable ride availability, and overcrowding. At the same time, marketing campaigns are drawing visitors but not always the most profitable ones, as discount-driven guests often spend less in-park. Leadership needs a coordinated strategy that balances operational efficiency with targeted marketing to improve both guest experience and overall profitability.

# Stakeholders
## Primary Stakeholder: 
 - Park General Manager (GM) – accountable for overall park performance, satisfaction, and revenue outcomes.
## Supporting Stakeholders:
- Operations Director – focused on staffing, queue management, and ride uptime, since these directly impact guest satisfaction
- Marketing Director – responsible for promotions and ticket sales strategy, ensuring campaigns attract high-value guests and support revenue growth.

# Overview of Database & Schema
## Dimension vs. Fact Tables in themepark.db
### Dimension tables: 
- dim_guest, dim_ticket, dim_attraction, dim_date
- stores descriptive attributes about guests, tickets, attractions (rides) and time. They store the context behind each visit.
### Fact Tables :
- fact_visits, fact_ride_events, fact_purchases
- They capture measurable events like park entry, ride usage and purchases
- Hold numeric values that can be aggregated.

### Star Schema Benefits
- Simplifies analysis, facts are in the middle and easy to join with descriptive dimensions
- Faster queries - Aggregations are efficient
- Flexiblity - easier to look into performance by guest without restructuring the data

# EDA (SQL) 
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
