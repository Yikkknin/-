# Power BI DAX 度量值计算手册 (DAX Measures Manual)

本文档记录了在 Power BI Desktop 中构建 App 留存率（Cohort Retention）与 LTV 变现看板所使用的全部 DAX（Data Analysis Expressions）度量值代码及核心解析。

---

## 1. 基础度量值 (Basic Measures)

用于计算看板顶部的核心 KPI 卡片及作为后续复杂度量值的分母。

```dax
-- 1.1 新增总人数 (用作留存率与 LTV 计算的基础分母)
新增总人数 = 
DISTINCTCOUNT(dim_users[user_id])

-- 1.2 总变现金额
总变现金额 = 
SUM(fact_revenue[amount])
```

## 2. 留存率度量值 (Cohort Retention Measures)
利用 CALCULATE 进行筛选上下文重写，仅统计符合特定 day_diff 的独立用户数。
```dax
-- 2.1 D1 留存人数
D1留存人数 = 
CALCULATE(
    DISTINCTCOUNT(fact_user_activity[user_id]),
    fact_user_activity[day_diff] = 1
)

-- 2.2 D1 留存率 (建议在格式栏设置为 "%")
D1留存率 = 
DIVIDE(
    [D1留存人数],
    [新增总人数],
    0
)

-- 2.3 D7 留存人数
D7留存人数 = 
CALCULATE(
    DISTINCTCOUNT(fact_user_activity[user_id]),
    fact_user_activity[day_diff] = 7
)

-- 2.4 D7 留存率
D7留存率 = 
DIVIDE(
    [D7留存人数],
    [新增总人数],
    0
)
```

## 3.变现与 LTV 度量值 (Monetization & LTV Measures)
注意：LTV 为累计指标，必须使用 <= N（如 day_diff <= 7）来筛选注册当天至第 N 天产生的全部累计流水。
```dax
-- 3.1 ARPU (每用户平均收入)
ARPU = 
DIVIDE(
    [总变现金额],
    [新增总人数],
    0
)

-- 3.2 D1 LTV (注册当天至第 1 天的累计人均收入)
D1_LTV = 
VAR D1_Revenue = 
    CALCULATE(
        SUM(fact_revenue[amount]),
        fact_revenue[day_diff] <= 1
    )
RETURN
    DIVIDE(D1_Revenue, [新增总人数], 0)

-- 3.3 D7 LTV (注册当天至第 7 天的累计人均收入)
D7_LTV = 
VAR D7_Revenue = 
    CALCULATE(
        SUM(fact_revenue[amount]),
        fact_revenue[day_diff] <= 7
    )
RETURN
    DIVIDE(D7_Revenue, [新增总人数], 0)
```

## 4. DAX 核心语法与技术解析 (Technical Insights)
在商业分析场景中，写出高性能 DAX 的核心在于理解其底层计算机制：
| DAX 函数 | 对应 SQL 概念 | 技术解析与性能优势 |
| :--- | :--- | :--- |
| CALCULATE() | WHERE / CASE WHEN | 修改/覆盖筛选上下文（Filter Context）。 |
| DIVIDE(A, B, 0) | A * 1.0 / NULLIF(B, 0) | 安全除法函数。当分母为 0 或 BLANK 时，会自动输出第三个参数（如 0），防止报除零错误。 |
| VAR ... RETURN | SQL 中的变量 / CTE 局部计算 | 声明局部变量。既能提高 DAX 代码的可读性，又能避免重复计算相同的表达式，显著提升 Power BI 报表刷新性能。 |
