SELECT
  device,
  sum(cost)                                        AS spend,
  round(sum(clicks) / sum(impressions) * 100, 2)   AS ctr_pct,
  round(sum(conversions) / sum(clicks) * 100, 2)   AS cvr_pct,
  round(sum(cost) / sum(conversions), 1)           AS cpa,
  round(sum(conversion_value) / sum(cost), 2)      AS roas
FROM analytics.ads_performance
WHERE 1 = 1
  [[AND {{date_range}}]]
  [[AND {{campaign_type}}]]
GROUP BY device
ORDER BY spend DESC
