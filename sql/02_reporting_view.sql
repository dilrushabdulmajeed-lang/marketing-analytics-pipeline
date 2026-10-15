-- Reporting layer: one wide view for BI tools (no joins needed in Metabase)
CREATE OR REPLACE VIEW analytics.ads_performance AS
SELECT
    a.date, a.campaign_id,
    c.campaign_name, c.campaign_type, c.objective, c.market,
    a.ad_group, a.device,
    a.impressions, a.clicks, a.cost, a.conversions, a.conversion_value
FROM analytics.ads_daily AS a FINAL
INNER JOIN analytics.campaigns AS c FINAL USING (campaign_id);
