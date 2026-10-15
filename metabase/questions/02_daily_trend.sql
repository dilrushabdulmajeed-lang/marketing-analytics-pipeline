SELECT
  date,
  sum(cost)                                   AS spend,
  round(sum(conversion_value) / sum(cost), 2) AS roas
FROM analytics.ads_performance
WHERE 1 = 1
  [[AND {{date_range}}]]
  [[AND {{campaign_type}}]]
GROUP BY date
ORDER BY date
