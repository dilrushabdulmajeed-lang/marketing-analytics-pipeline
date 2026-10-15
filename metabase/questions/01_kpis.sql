SELECT
  sum(cost)                                   AS spend,
  sum(conversion_value)                       AS revenue,
  round(sum(conversion_value) / sum(cost), 2) AS roas,
  round(sum(cost) / sum(conversions), 1)      AS cpa
FROM analytics.ads_performance
WHERE 1 = 1
  [[AND {{date_range}}]]
  [[AND {{campaign_type}}]]
