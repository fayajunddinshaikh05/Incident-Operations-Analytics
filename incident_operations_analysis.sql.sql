-- ─────────────────────────────────────────────
-- INCIDENT OPERATIONS ANALYTICS PROJECT
-- Advanced SQL Analysis Queries
-- Database: MySQL
-- ─────────────────────────────────────────────

USE Incident_Operations_analytics;

-- ─────────────────────────────────────────────
-- 1. View Sample Incident Records
-- ─────────────────────────────────────────────

SELECT *
FROM incident_analytics
LIMIT 10;

-- ─────────────────────────────────────────────
-- 2. Total Incidents + SLA Breach %
-- ─────────────────────────────────────────────

SELECT 
    COUNT(*) AS total_incidents,

    SUM(
        CASE 
            WHEN SLA_Breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS breached_incidents,

    ROUND(
        SUM(
            CASE 
                WHEN SLA_Breached = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS breach_percentage

FROM incident_analytics;

-- ─────────────────────────────────────────────
-- 3. Incidents by Priority with %
-- ─────────────────────────────────────────────

SELECT 
    Priority,

    COUNT(*) AS total_incidents,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS incident_percentage

FROM incident_analytics

GROUP BY Priority

ORDER BY total_incidents DESC;

-- ─────────────────────────────────────────────
-- 4. SLA Breach Analysis by Priority
-- ─────────────────────────────────────────────

SELECT
    Priority,

    COUNT(*) AS total_incidents,

    SUM(
        CASE 
            WHEN SLA_Breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS breached_incidents,

    SUM(
        CASE 
            WHEN SLA_Breached = 'No' THEN 1
            ELSE 0
        END
    ) AS met_sla,

    ROUND(
        SUM(
            CASE 
                WHEN SLA_Breached = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        1
    ) AS breach_rate_pct,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_mttr_mins

FROM incident_analytics

GROUP BY Priority

ORDER BY
    CASE Priority
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 2
        WHEN 'Medium'   THEN 3
        WHEN 'Low'      THEN 4
    END;

-- ─────────────────────────────────────────────
-- 5. System-wise Performance Analysis
-- ─────────────────────────────────────────────

SELECT 
    Systems,

    COUNT(*) AS total_incidents,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_mttr_mins,

    ROUND(
        AVG(Resolution_Time_mins) / 60,
        2
    ) AS avg_mttr_hours,

    SUM(
        CASE 
            WHEN SLA_Breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches,

    ROUND(
        SUM(
            CASE 
                WHEN SLA_Breached = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        1
    ) AS sla_breach_percentage

FROM incident_analytics

GROUP BY Systems

ORDER BY sla_breaches DESC;

-- ─────────────────────────────────────────────
-- 6. Critical vs Non-Critical Analysis
-- ─────────────────────────────────────────────

SELECT 
    Critical_Flag,

    COUNT(*) AS total_incidents,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_resolution_mins

FROM incident_analytics

GROUP BY Critical_Flag;

-- ─────────────────────────────────────────────
-- 7. Daily Incident Trend
-- ─────────────────────────────────────────────

SELECT 
    DATE(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS incident_date,

    COUNT(*) AS total_incidents

FROM incident_analytics

GROUP BY incident_date

ORDER BY incident_date;

-- ─────────────────────────────────────────────
-- 8. Monthly Incident Trends
-- ─────────────────────────────────────────────

SELECT 
    MONTHNAME(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS month_name,

    MONTH(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS month_number,

    COUNT(*) AS total_incidents,

    SUM(
        CASE 
            WHEN Priority = 'Critical' THEN 1
            ELSE 0
        END
    ) AS critical_incidents,

    SUM(
        CASE 
            WHEN Priority = 'High' THEN 1
            ELSE 0
        END
    ) AS high_incidents,

    SUM(
        CASE 
            WHEN SLA_Breached = 'Yes' THEN 1
            ELSE 0
        END
    ) AS sla_breaches,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_mttr_mins

FROM incident_analytics

GROUP BY month_name, month_number

ORDER BY month_number;

-- ─────────────────────────────────────────────
-- 9. Peak Incident Hours
-- ─────────────────────────────────────────────

SELECT 
    HOUR(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS incident_hour,

    COUNT(*) AS total_incidents

FROM incident_analytics

GROUP BY incident_hour

ORDER BY incident_hour;

-- ─────────────────────────────────────────────
-- 10. Average Resolution Time by Day
-- ─────────────────────────────────────────────

SELECT 
    DATE(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS incident_date,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_resolution_mins

FROM incident_analytics

GROUP BY incident_date

ORDER BY incident_date;

-- ─────────────────────────────────────────────
-- 11. Last 7 Days Incidents
-- ─────────────────────────────────────────────

SELECT *

FROM incident_analytics

WHERE STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i') >=
(
    SELECT 
        MAX(
            STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        )
    FROM incident_analytics
) - INTERVAL 7 DAY;

-- ─────────────────────────────────────────────
-- 12. Running Total of Daily Incidents
-- ─────────────────────────────────────────────

SELECT 
    DATE(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS incident_date,

    COUNT(*) AS daily_incidents,

    SUM(COUNT(*)) OVER (
        ORDER BY DATE(
            STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        )
    ) AS running_total

FROM incident_analytics

GROUP BY incident_date;

-- ─────────────────────────────────────────────
-- 13. Frequent Incident Gap Analysis
-- ─────────────────────────────────────────────

SELECT 
    Incident_ID,

    Start_Time,

    LAG(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) OVER (
        ORDER BY STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS previous_incident_time,

    TIMESTAMPDIFF(
        MINUTE,

        LAG(
            STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        ) OVER (
            ORDER BY STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        ),

        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')

    ) AS gap_minutes

FROM incident_analytics;

-- ─────────────────────────────────────────────
-- 14. Increasing Incident Trend by System
-- ─────────────────────────────────────────────

SELECT 
    Systems,

    incident_date,

    total_incidents,

    LAG(total_incidents) OVER (
        PARTITION BY Systems
        ORDER BY incident_date
    ) AS previous_day_incidents

FROM
(
    SELECT 
        Systems,

        DATE(
            STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        ) AS incident_date,

        COUNT(*) AS total_incidents

    FROM incident_analytics

    GROUP BY Systems, incident_date

) t;

-- ─────────────────────────────────────────────
-- 15. High Risk Systems using CTE
-- ─────────────────────────────────────────────

WITH system_stats AS
(
    SELECT
        Systems,

        COUNT(*) AS total_incidents,

        SUM(
            CASE 
                WHEN SLA_Breached = 'Yes' THEN 1
                ELSE 0
            END
        ) AS sla_breaches,

        ROUND(
            AVG(Resolution_Time_mins),
            1
        ) AS avg_mttr,

        ROUND(
            SUM(
                CASE 
                    WHEN SLA_Breached = 'Yes' THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            1
        ) AS breach_rate

    FROM incident_analytics

    GROUP BY Systems
),

risk_ranked AS
(
    SELECT *,

        RANK() OVER (
            ORDER BY sla_breaches DESC
        ) AS risk_rank

    FROM system_stats
)

SELECT *

FROM risk_ranked

WHERE risk_rank <= 5

ORDER BY risk_rank;

-- ─────────────────────────────────────────────
-- 16. Running Total by Month
-- ─────────────────────────────────────────────

SELECT
    MONTHNAME(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS month_name,

    MONTH(
        STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
    ) AS month_number,

    COUNT(*) AS monthly_incidents,

    SUM(COUNT(*)) OVER (
        ORDER BY MONTH(
            STR_TO_DATE(Start_Time, '%d-%m-%Y %H:%i')
        )
    ) AS running_total,

    ROUND(
        AVG(Resolution_Time_mins),
        1
    ) AS avg_mttr

FROM incident_analytics

GROUP BY month_name, month_number

ORDER BY month_number;