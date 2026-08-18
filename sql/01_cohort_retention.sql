-- =========================================================
-- 文件名: 01_cohort_retention.sql
-- 描述: 计算每日 Cohort 组及各买量渠道的 D1, D7 留存率
-- =========================================================

-- 1. 按注册日期 (install_date) 汇总 Cohort 留存看板
SELECT 
    u.install_date AS [注册日期],
    COUNT(DISTINCT u.user_id) AS [新增用户数],
    
    -- D1 留存指标
    COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) AS [D1留存人数],
    FORMAT(
        COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), '0.00%'
    ) AS [D1留存率],
    
    -- D7 留存指标
    COUNT(DISTINCT CASE WHEN a.day_diff = 7 THEN a.user_id END) AS [D7留存人数],
    FORMAT(
        COUNT(DISTINCT CASE WHEN a.day_diff = 7 THEN a.user_id END) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), '0.00%'
    ) AS [D7留存率]

FROM dim_users u
LEFT JOIN fact_user_activity a ON u.user_id = a.user_id
GROUP BY u.install_date
ORDER BY u.install_date;

-- 2. 按买量渠道 (channel) 汇总留存对比
SELECT 
    u.channel AS [渠道],
    COUNT(DISTINCT u.user_id) AS [新增用户数],
    COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) AS [D1留存人数],
    FORMAT(
        COUNT(DISTINCT CASE WHEN a.day_diff = 1 THEN a.user_id END) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), '0.00%'
    ) AS [D1留存率],
    COUNT(DISTINCT CASE WHEN a.day_diff = 7 THEN a.user_id END) AS [D7留存人数],
    FORMAT(
        COUNT(DISTINCT CASE WHEN a.day_diff = 7 THEN a.user_id END) * 1.0 
        / NULLIF(COUNT(DISTINCT u.user_id), 0), '0.00%'
    ) AS [D7留存率]
FROM dim_users u
LEFT JOIN fact_user_activity a ON u.user_id = a.user_id
GROUP BY u.channel
ORDER BY [新增用户数] DESC;
