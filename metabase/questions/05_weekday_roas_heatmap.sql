SELECT
  campaign_type,
  round(sumIf(conversion_value, toDayOfWeek(date) = 1) / sumIf(cost, toDayOfWeek(date) = 1), 2) AS Mon,
  round(sumIf(conversion_value, toDayOfWeek(date) = 2) / sumIf(cost, toDayOfWeek(date) = 2), 2) AS Tue,
  round(sumIf(conversion_value, toDayOfWeek(date) = 3) / sumIf(cost, toDayOfWeek(date) = 3), 2) AS Wed,
  round(sumIf(conversion_value, toDayOfWeek(date) = 4) / sumIf(cost, toDayOfWeek(date) = 4), 2) AS Thu,
  round(sumIf(conversion_value, toDayOfWeek(date) = 5) / sumIf(cost, toDayOfWeek(date) = 5), 2) AS Fri,
  round(sumIf(conversion_value, toDayOfWeek(date) = 6) / sumIf(cost, toDayOfWeek(date) = 6), 2) AS Sat,
  round(sumIf(conversion_value, toDayOfWeek(date) = 7) / sumIf(cost, toDayOfWeek(date) = 7), 2) AS Sun
FROM analytics.ads_performance
WHERE 1 = 1
  [[AND {{date_range}}]]
  [[AND {{campaign_type}}]]
GROUP BY campaign_type
ORDER BY campaign_type
