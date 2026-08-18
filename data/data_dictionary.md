# 📚 数据字典 (Data Dictionary)

### 1. `dim_users` (用户维度表)
| 字段名 | 数据类型 | 主键/外键 | 说明 | 示例值 |
| :--- | :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR(20) | PRIMARY KEY | 用户唯一标识 | U10001 |
| `install_date` | DATE | - | 注册/安装日期 | 2026-01-01 |
| `channel` | VARCHAR(50) | - | 获客渠道 | Facebook_Ads / Organic |
| `country` | VARCHAR(10) | - | 国家地区代码 | US, JP, DE |
| `os` | VARCHAR(20) | - | 操作系统 | iOS / Android |

### 2. `fact_user_activity` (活跃事实表)
| 字段名 | 数据类型 | 主键/外键 | 说明 | 示例值 |
| :--- | :--- | :--- | :--- | :--- |
| `user_id` | VARCHAR(20) | FOREIGN KEY | 关联 dim_users.user_id | U10001 |
| `activity_date` | DATE | - | 活跃登录日期 | 2026-01-02 |
| `day_diff` | INT | - | 距注册日期的天数差 (0=注册当天) | 1 |

### 3. `fact_revenue` (变现事实表)
| 字段名 | 数据类型 | 主键/外键 | 说明 | 示例值 |
| :--- | :--- | :--- | :--- | :--- |
| `transaction_id`| VARCHAR(30) | PRIMARY KEY | 订单流水号 | T1001 |
| `user_id` | VARCHAR(20) | FOREIGN KEY | 关联 dim_users.user_id | U10001 |
| `event_date` | DATE | - | 变现发生日期 | 2026-01-02 |
| `revenue_type` | VARCHAR(10) | - | 变现类型 (IAP 内购 / IAA 广告) | IAP |
| `amount` | DECIMAL(10,4)| - | 变现金额 (USD) | 4.9900 |
| `day_diff` | INT | - | 距注册日期的天数差 | 1 |
