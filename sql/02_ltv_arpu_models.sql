-- =========================================================
-- 文件名: 02_ltv_arpu_models.sql
-- 描述: 计算用户 ARPU 及 D1、D7 累计 LTV (生命周期价值)
-- 注意: LTV 是累计值，必须使用 day_diff <= N 条件
-- =========================================================

SELECT 
    u.channel AS [渠道],
    COUNT(DISTINCT u.user_id) AS [新增用户数],
    
    -- 总变现金额
    ISNULL(SUM(r.amount), 0) AS [总变现金额($)],
    
    -- ARPU: 平均每用户收入 (Total Revenue / Total Users)
    ROUND(
        ISNULL(SUM(r.amount), 0) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), 4
    ) AS [ARPU($)],
    
    -- D1 LTV: 注册当天至第 1 天产生的累计人均收入
    ROUND(
        ISNULL(SUM(CASE WHEN r.day_diff <= 1 THEN r.amount ELSE 0 END), 0) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), 4
    ) AS [D1_LTV($)],
    
    -- D7 LTV: 注册当天至第 7 天产生的累计人均收入
    ROUND(
        ISNULL(SUM(CASE WHEN r.day_diff <= 7 THEN r.amount ELSE 0 END), 0) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), 4
    ) AS [D7_LTV($)]

FROM dim_users u
LEFT JOIN fact_revenue r ON u.user_id = r.user_id
GROUP BY u.channel
ORDER BY [新增用户数] DESC;
