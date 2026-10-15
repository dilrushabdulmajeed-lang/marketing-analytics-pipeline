-- Project 1: Google Ads-style marketing data (synthetic)
CREATE TABLE IF NOT EXISTS analytics.campaigns
(
    campaign_id   UInt32,
    campaign_name String,
    campaign_type LowCardinality(String),   -- Search, Display, PMax, YouTube
    objective     LowCardinality(String),   -- Leads, Sales, Awareness
    market        LowCardinality(String),
    daily_budget  Decimal(10, 2)
)
ENGINE = ReplacingMergeTree
ORDER BY campaign_id;

CREATE TABLE IF NOT EXISTS analytics.ads_daily
(
    date             Date,
    campaign_id      UInt32,
    ad_group         LowCardinality(String),
    device           LowCardinality(String),
    impressions      UInt32,
    clicks           UInt32,
    cost             Decimal(12, 2),
    conversions      Float32,
    conversion_value Decimal(12, 2),
    loaded_at        DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(loaded_at)
PARTITION BY toYYYYMM(date)
ORDER BY (date, campaign_id, ad_group, device);

TRUNCATE TABLE analytics.campaigns;
INSERT INTO analytics.campaigns VALUES
 (101,'Search | Brand | UAE',           'Search', 'Sales',     'UAE', 150),
 (102,'Search | Generic | UAE',         'Search', 'Sales',     'UAE', 400),
 (103,'Search | Competitor | UAE',      'Search', 'Leads',     'UAE', 250),
 (104,'Search | Generic | KSA',         'Search', 'Sales',     'KSA', 350),
 (105,'PMax | All Products | UAE',      'PMax',   'Sales',     'UAE', 600),
 (106,'PMax | All Products | KSA',      'PMax',   'Sales',     'KSA', 450),
 (107,'Display | Remarketing | GCC',    'Display','Sales',     'GCC', 200),
 (108,'Display | Prospecting | GCC',    'Display','Awareness', 'GCC', 300),
 (109,'YouTube | Awareness | GCC',      'YouTube','Awareness', 'GCC', 350),
 (110,'Search | Lead Gen | Qatar',      'Search', 'Leads',     'QAT', 180);

TRUNCATE TABLE analytics.ads_daily;
-- 365 days x 10 campaigns x 3 ad groups x 3 devices, with weekly seasonality,
-- Ramadan/White Friday-ish uplifts, per-campaign efficiency, and noise.
INSERT INTO analytics.ads_daily (date, campaign_id, ad_group, device, impressions, clicks, cost, conversions, conversion_value)
WITH
    toDate(today() - 365 + d.number) AS dt,
    c.campaign_id AS cid,
    c.campaign_type AS ctype,
    ['Core', 'Offers', 'Long-tail'][ag.number + 1] AS adg,
    ['Mobile', 'Desktop', 'Tablet'][dv.number + 1] AS dev,
    cityHash64(dt, cid, adg, dev) AS h,
    (h % 1000) / 1000.0 AS r1,
    (bitShiftRight(h, 10) % 1000) / 1000.0 AS r2,
    (bitShiftRight(h, 20) % 1000) / 1000.0 AS r3,
    if(toDayOfWeek(dt) IN (5, 6), 0.85, 1.0)                                   -- Fri/Sat dip
      * if(toMonth(dt) = 11 AND toDayOfMonth(dt) >= 20, 1.6, 1.0)             -- White Friday
      * if(toMonth(dt) = 12, 1.25, 1.0) AS season,
    multiIf(dev = 'Mobile', 0.62, dev = 'Desktop', 0.31, 0.07) AS dev_share,
    multiIf(ctype = 'Search', 0.065, ctype = 'PMax', 0.022, ctype = 'Display', 0.006, 0.004) AS base_ctr,
    multiIf(ctype = 'Search', 1.9, ctype = 'PMax', 1.4, ctype = 'Display', 0.35, 0.12) AS base_cpc,
    multiIf(cid = 101, 0.08, cid = 103, 0.015, ctype = 'Search', 0.03, ctype = 'PMax', 0.025,
            cid = 107, 0.006, cid = 108, 0.003, 0.0008) AS base_cvr,                               -- 103 = wasted spend
    multiIf(cid = 110, 0, 300) AS aov,
    toUInt32(round(c.daily_budget / base_cpc / base_ctr / 3 * dev_share * season * (0.8 + 0.4 * r1))) AS imp,
    toUInt32(round(imp * base_ctr * if(dev = 'Desktop', 1.15, 1.0) * (0.85 + 0.3 * r2))) AS clk,
    -- anomaly: competitor campaign CPC spikes in the last 3 days
    round(clk * base_cpc * (0.85 + 0.3 * r3) * if(cid = 103 AND dt >= today() - 3, 2.8, 1.0), 2) AS cst,
    round(clk * base_cvr * if(dev = 'Mobile', 0.8, 1.15) * (0.7 + 0.6 * r1), 2) AS cnv
SELECT dt, cid, adg, dev, imp, clk, cst, cnv, round(cnv * aov * (0.8 + 0.4 * r2), 2)
FROM numbers(365) AS d
CROSS JOIN analytics.campaigns AS c
CROSS JOIN numbers(3) AS ag
CROSS JOIN numbers(3) AS dv;
