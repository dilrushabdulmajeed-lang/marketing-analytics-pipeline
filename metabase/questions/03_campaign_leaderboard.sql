WITH (SELECT max(date) FROM analytics.ads_performance) AS last_day
SELECT
  campaign_name,
  campaign_type,
  sum(cost)                                                  AS spend,
  round(sum(conversions))                                    AS conv,
  round(sum(cost) / sum(conversions), 1)                     AS cpa,
  round(sum(conversion_value) / sum(cost), 2)                AS roas,
  round(sumIf(cost, date > last_day - 3)
      / sumIf(conversions, date > last_day - 3), 1)          AS cpa_last_3d,
  round((cpa_last_3d / cpa - 1) * 100)                       AS cpa_change_pct
FROM analytics.ads_performance
WHERE 1 = 1
  [[AND {{date_range}}]]
  [[AND {{campaign_type}}]]
GROUP BY campaign_name, campaign_type
ORDER BY spend DESC
