/*========================================================

SQL ANALYSIS 1

Question:
Which industry has the highest churn rate?

========================================================*/

SELECT
    a.industry,

    COUNT(DISTINCT a.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id)
        /
        COUNT(DISTINCT a.account_id)
        * 100,
        2
    ) AS churn_rate

FROM ravenstack_accounts a

LEFT JOIN ravenstack_churn_events c
    ON a.account_id = c.account_id

GROUP BY a.industry

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 2

Question:
Which referral source has the highest churn rate?

========================================================*/

SELECT
    a.referral_source,

    COUNT(DISTINCT a.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id)
        /
        COUNT(DISTINCT a.account_id)
        * 100,
        2
    ) AS churn_rate

FROM ravenstack_accounts a

LEFT JOIN ravenstack_churn_events c
    ON a.account_id = c.account_id

GROUP BY a.referral_source

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 3

Question:
Do trial customers churn more than non-trial customers?

========================================================*/
SELECT
    a.is_trial,

    COUNT(DISTINCT a.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id)
        /
        COUNT(DISTINCT a.account_id)
        * 100,
        2
    ) AS churn_rate

FROM ravenstack_accounts a

LEFT JOIN ravenstack_churn_events c
    ON a.account_id = c.account_id

GROUP BY a.is_trial

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 4

Question:
Which subscription plans have the highest churn rate?

========================================================*/

SELECT

    plan_tier,

    COUNT(DISTINCT account_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn_flag = 'TRUE'
        THEN account_id
    END) AS churned_customers,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN churn_flag = 'TRUE'
            THEN account_id
        END) * 100.0
        /
        NULLIF(COUNT(DISTINCT account_id), 0),
        2
    ) AS churn_rate

FROM ravenstack_subscriptions

GROUP BY plan_tier

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 5 Question:
Are customers who downgrades more likely to churn?

========================================================*/
SELECT
    s.downgrade_flag,
    COUNT(DISTINCT s.account_id) AS total_customers,
    COUNT(DISTINCT c.account_id) AS churned_customers,
    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 / NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS churn_rate
FROM ravenstack_subscriptions s
LEFT JOIN ravenstack_subscriptions c
    ON s.account_id = c.account_id 
    AND c.churn_flag = 'TRUE'
GROUP BY s.downgrade_flag
ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 6 Question:
Are customers who upgrade less likely to churn?

========================================================*/
SELECT
    s.upgrade_flag,
    COUNT(DISTINCT s.account_id) AS total_customers,
    COUNT(DISTINCT c.account_id) AS churned_customers,
    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 / NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS churn_rate
FROM ravenstack_subscriptions s
LEFT JOIN ravenstack_subscriptions c
    ON s.account_id = c.account_id 
    AND c.churn_flag = 'TRUE'
GROUP BY s.upgrade_flag
ORDER BY churn_rate DESC;


/*========================================================

SQL ANALYSIS 7

Question:
Do customers with lower satisfaction scores churn more?

========================================================*/

SELECT

    CASE
        WHEN satisfaction_score <= 2 THEN 'Low Satisfaction'
        WHEN satisfaction_score <= 4 THEN 'Medium Satisfaction'
        ELSE 'High Satisfaction'
    END AS satisfaction_group,

    COUNT(DISTINCT s.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS churn_rate

FROM ravenstack_support_tickets s

LEFT JOIN ravenstack_churn_events c
    ON s.account_id = c.account_id

GROUP BY satisfaction_group

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 8

Question:
Do escalated tickets lead to higher churn?

========================================================*/

SELECT

    escalation_flag,

    COUNT(DISTINCT s.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS churn_rate

FROM ravenstack_support_tickets s

LEFT JOIN ravenstack_churn_events c
    ON s.account_id = c.account_id

GROUP BY escalation_flag

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 9

Question:
Do customers with longer resolution times churn more?

========================================================*/

SELECT

    CASE
        WHEN resolution_time_hours <= 24 THEN 'Short Resolution'
        WHEN resolution_time_hours <= 72 THEN 'Medium Resolution'
        ELSE 'Long Resolution'
    END AS resolution_group,

    COUNT(DISTINCT s.account_id) AS total_customers,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT s.account_id), 0),
        2
    ) AS churn_rate

FROM ravenstack_support_tickets s

LEFT JOIN ravenstack_churn_events c
    ON s.account_id = c.account_id

GROUP BY resolution_group

ORDER BY churn_rate DESC;

/*========================================================

SQL ANALYSIS 10

Question:
Which subscription plans generate the highest churn-related revenue loss?

========================================================*/

SELECT

    s.plan_tier,

    COUNT(DISTINCT c.account_id) AS churned_customers,

    ROUND(SUM(c.refund_amount_usd),2) AS revenue_loss

FROM ravenstack_subscriptions s

INNER JOIN ravenstack_churn_events c
    ON s.account_id = c.account_id

GROUP BY s.plan_tier

ORDER BY revenue_loss DESC;
