# 移动 App 用户留存率 (Cohort Retention) 与 LTV 变现分析项目

## 1. 项目背景与商业痛点 (Business Background)
随着移动应用（Mobile App）获客成本（CAC）不断上升，单纯依赖新增下载量已无法衡量产品的健康度。本项目基于 SQL Server 构建了数据仓库星型模型，旨在回答以下核心商业问题：
1. **用户留存走势**：各买量渠道（Channel）的新增用户，其 D1、D7 留存率是否存在显著差异？
2. **生命周期价值 (LTV)**：不同渠道用户的累计变现贡献（D1 LTV / D7 LTV）是否能够覆盖获客成本？
3. **策略优化建议**：如何通过数据驱动，对营销预算分配与产品留存策略进行优化？

---

## 2. 数据架构与模型 (Data Architecture)
项目采用标准的数据仓库**星型模型（Star Schema）**设计，包含 1 张维度表与 2 张事实表：

- **`dim_users`（用户维度表）**：存储用户静态属性（注册日期、渠道、国家、操作系统）。
- **`fact_user_activity`（活跃事实表）**：记录用户每日登录活跃打卡（`day_diff` 记录距注册天数）。
- **`fact_revenue`（变现事实表）**：记录用户变现流水（内购 IAP / 广告 IAA、变现金额）。

---

## 3. 核心 SQL 分析逻辑与亮点 (Technical Highlights)

### 留存率条件聚合计算 (Conditional Aggregation)
相比传统多次 Join，采用 `CASE WHEN + COUNT(DISTINCT)` 实现了在单次表扫描中并行计算多天留存率，显著提升查询性能：

```sql
-- 计算 D1 与 D7 留存率核心逻辑
SELECT 
    u.channel,
    COUNT(DISTINCT u.user_id) AS cohort_size,
    -- 条件聚合：仅当 day_diff = 1 时记入分子，NULL 值被 COUNT 自动忽略
    COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) AS d1_retained,
    FORMAT(
        COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), '0.00%'
    ) AS d1_retention_rate
FROM dim_users u
LEFT JOIN fact_user_activity a ON u.user_id = a.user_id
GROUP BY u.channel;
```
---

## 4. 关键分析结论 (Key Insights)
1. **渠道留存分化**：Organic（自然流量）与 Facebook_Ads 的 D1 留存率明显优于其他渠道（高于 40%），而 TikTok_Ads 的留存衰减较快，存在部分低意向或误点击用户。
2. **变现效率差异**：Google_Ads 虽留存率居中，但由于 iOS 用户占比高，其 D7 LTV 表现稳健，拥有更高的内购（IAP）转化潜力。

---

## 5.落地决策建议 (Actionable Recommendations)
- **预算调优**：建议减少 15% 的 TikTok 渠道低效买量预算，倾斜至 Facebook_Ads 与 Google_Ads。
- **产品干预**：针对 TikTok 渠道用户，在注册后 24 小时内（D0-D1）优化新手引导（Onboarding）流程，提升次留转化。

