## Power BI & DAX 建模亮点 (DAX Technical Highlights)

除了 SQL 端的数据建模，本项目在 Power BI 端利用 DAX 实现了灵活的动态筛选上下文重写：

* **动态留存率计算**：使用 `CALCULATE` 与 `DISTINCTCOUNT` 捕捉特定 `day_diff` 的活跃用户。
* **累计 LTV 算法**：利用 `VAR` 局部变量与 `<= N` 条件计算累计收益，配合 `DIVIDE` 防范除零报错。

```dax
-- D7 LTV 核心度量值示例
D7_LTV = 
VAR D7_Revenue = 
    CALCULATE(
        SUM(fact_revenue[amount]),
        fact_revenue[day_diff] <= 7
    )
RETURN
    DIVIDE(D7_Revenue, [新增总人数], 0)
```

完整的 8 个核心 DAX 度量值源码及说明参见：reports/dax_measures.md
