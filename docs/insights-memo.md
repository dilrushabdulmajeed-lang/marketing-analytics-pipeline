# Google Ads Performance Review: GCC Account

**Period:** 15 Sep – 14 Oct 2026 (30 days) · **Prepared by:** dilrushabdulmajeed · **Data:** ClickHouse `analytics.ads_performance`, loaded daily by n8n

> Portfolio note: the data is synthetic but modelled on realistic GCC benchmarks. The pipeline, SQL and dashboard work exactly as they would against the live Google Ads API.

## Summary

| Spend | Revenue | ROAS | CPA | Conversions |
|---|---|---|---|---|
| AED 98.4k | AED 413.2k | **4.19** | **AED 68.1** | 1,446 |

Performance is stable month on month (prior 30 days: ROAS 4.23, CPA 67.5), but this hides **three fixable leaks**. Fixing them could add about **240 conversions/month (+17%) at the same budget**.

## Findings and recommendations

### 1. Competitor Search costs 2.3× more per conversion than Generic Search
- *Search | Competitor | UAE* spends **AED 8.7k/month (9% of budget)** at a **CPA of AED 154**, against AED 65–66 for Generic Search in the UAE and KSA. ROAS is 1.97 against an account average of 4.19.
- **Recommendation:** pause it, or cut it to a brand-defence minimum, and move the budget to PMax (CPA AED 58).
- **Impact:** about **+90 conversions/month** (AED 8.7k ÷ 58 = 149 conversions instead of 57).

### 2. A cost spike went undetected for 3 days
- 8–10 Oct: Competitor Search **CPC jumped from AED 1.90 to 5.40 (2.8×)** and **CPA from about 135 to about 400**. Most likely cause: aggressive competitor bidding or a broad-match change.
- **About AED 1,130 of excess spend** over the 7-day baseline (AED 249/day) before it settled down by itself on 11 Oct.
- **Recommendation:** an automated anomaly alert that compares daily CPC/CPA with a 7-day baseline and notifies the team within 24 hours. *(Built as the next project: an n8n + ClickHouse alert workflow.)*
- **Impact:** would have flagged it on day 1, saving about AED 750 in this incident alone.

### 3. Mobile converts 30% worse than desktop and takes 59% of the budget
| Device | Spend | Conv. rate | CPA | ROAS |
|---|---|---|---|---|
| Mobile | AED 58.1k | 0.71% | AED 80 | 3.55 |
| Desktop | AED 33.6k | 1.01% | AED 56 | 5.12 |
| Tablet | AED 6.7k | 1.01% | AED 56 | 5.12 |

- Click-through rates are similar, so mobile users are interested but drop off **after** the click. That points to the landing page, not the ads.
- **Recommendation:** (a) audit mobile page speed and checkout UX; (b) apply a −15% mobile bid adjustment until the fix ships.
- **Impact:** closing half the gap (CVR 0.71% → 0.86%) adds about **+150 conversions/month**.

## Also checked (no action needed)
- **Weekday pattern:** Fri/Sat spend and conversions are both about 15% lower (the UAE weekend), but **ROAS is flat at 4.18–4.27 every day**. Dayparting or weekend budget changes **are not justified**.
- **Awareness campaigns** (YouTube 1.92, Display Prospecting 2.48 ROAS) should be judged on reach and cost per view, not ROAS. They aren't underperformers by design.
- **Search | Lead Gen | Qatar** reports no conversion value. **Assign lead values or import offline conversions** so Smart Bidding can optimise for value.

## Next steps
1. Pause or cut Competitor Search and reallocate to PMax. *Owner: PPC · this week*
2. Mobile landing-page audit and an interim bid adjustment. *Owner: Web + PPC · 2 weeks*
3. Deploy the automated CPC/CPA anomaly alert. *Owner: Analytics · 1 week*
4. Re-review in 30 days against this baseline.

---
*Dashboard: Metabase → "Google Ads Performance" · Pipeline: n8n "Ads → ClickHouse daily loader" · SQL: `sql/`*
