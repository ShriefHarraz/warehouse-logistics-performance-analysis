select *
from orders_raw;

select *
from carriers;

select *
from warehouses;

USE warehouse_logistics;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS row_difference
FROM orders_raw;

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders_raw
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


SELECT *
FROM orders_raw
WHERE order_id IN (
    SELECT order_id
    FROM orders_raw
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id, order_date;


SELECT
    (SELECT COUNT(*) FROM orders_raw) AS total_rows,
    (SELECT COUNT(DISTINCT order_id) FROM orders_raw) AS unique_orders,
    (SELECT COUNT(*) FROM orders_raw)
      - (SELECT COUNT(DISTINCT order_id) FROM orders_raw) AS extra_rows,
    (
        SELECT COUNT(*)
        FROM (
            SELECT order_id
            FROM orders_raw
            GROUP BY order_id
            HAVING COUNT(*) > 1
        ) AS d
    ) AS duplicated_order_ids;
    
    ---- Remove Duplicates ---

USE warehouse_logistics;

CREATE TABLE orders_deduplicated AS
SELECT
    order_id,
    warehouse_id,
    carrier_id,
    order_date,
    processed_at,
    dispatched_at,
    promised_at,
    delivered_at,
    units_ordered,
    units_delivered,
    shipping_cost_aed,
    order_status
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_id
        ) AS row_num
    FROM orders_raw
) AS ranked_orders
WHERE row_num = 1;


SELECT
    COUNT(*) AS cleaned_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM orders_deduplicated;

SELECT
    COUNT(*) AS total_rows,
    SUM(carrier_id IS NULL) AS missing_carrier,
    SUM(processed_at IS NULL) AS missing_processed_at,
    SUM(dispatched_at IS NULL) AS missing_dispatched_at,
    SUM(promised_at IS NULL) AS missing_promised_at,
    SUM(delivered_at IS NULL) AS missing_delivered_at,
    SUM(shipping_cost_aed IS NULL) AS missing_shipping_cost
FROM orders_deduplicated;


SELECT
    SUM(processed_at < order_date) AS processed_before_order,
    SUM(dispatched_at < processed_at) AS dispatched_before_processing,
    SUM(delivered_at < dispatched_at) AS delivered_before_dispatch,
    SUM(promised_at < order_date) AS promised_before_order
FROM orders_deduplicated;


SELECT
    order_id,
    warehouse_id,
    carrier_id,
    order_date,
    processed_at,
    dispatched_at,
    delivered_at,
    order_status
FROM orders_deduplicated
WHERE dispatched_at < processed_at
ORDER BY order_id;


SELECT
    order_id,
    warehouse_id,
    carrier_id,
    order_date,
    processed_at,
    dispatched_at,
    delivered_at,
    promised_at,
    order_status
FROM orders_deduplicated
WHERE delivered_at < dispatched_at
ORDER BY order_id;

USE warehouse_logistics;

CREATE TABLE orders_clean AS
SELECT *
FROM orders_deduplicated
WHERE
    processed_at >= order_date
    AND dispatched_at >= processed_at
    AND (
        delivered_at IS NULL
        OR delivered_at >= dispatched_at
    )
    AND (
        shipping_cost_aed IS NULL
        OR shipping_cost_aed >= 0
    )
    AND units_delivered <= units_ordered;
    
SELECT
    COUNT(*) AS clean_orders,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(delivered_at IS NULL) AS undelivered_or_missing_date,
    SUM(shipping_cost_aed IS NULL) AS missing_shipping_cost
FROM orders_clean;

select *
from orders_clean;

--- Q1 Warehouse Performance ----
SELECT
    warehouse_id,
    COUNT(*) AS total_orders,

    ROUND(
        AVG(TIMESTAMPDIFF(
            MINUTE, order_date, processed_at
        )) / 60, 2
    ) AS avg_processing_hours,

    ROUND(
        AVG(shipping_cost_aed), 2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(shipping_cost_aed), 2
    ) AS total_shipping_cost

FROM orders_clean

GROUP BY warehouse_id

ORDER BY total_orders DESC;

--- Q2 Carrier Performance ---

SELECT
    carrier_id,
    COUNT(*) AS total_orders,

    ROUND(
        AVG(TIMESTAMPDIFF(
            MINUTE, dispatched_at, delivered_at
        )) / 60, 2
    ) AS avg_delivery_hours,

    ROUND(
        AVG(shipping_cost_aed), 2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(shipping_cost_aed), 2
    ) AS total_shipping_cost

FROM orders_clean

GROUP BY carrier_id

ORDER BY avg_delivery_hours DESC;


--- Q3 On-Time Delivery % ---

SELECT
    carrier_id,

    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN delivered_at <= promised_at THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN delivered_at > promised_at THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivered_at <= promised_at THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS on_time_delivery_pct

FROM orders_clean

WHERE delivered_at IS NOT NULL
  AND promised_at IS NOT NULL

GROUP BY carrier_id

ORDER BY on_time_delivery_pct DESC;

--- Q4 Monthly Logistics Performance ---

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,

    COUNT(*) AS total_orders,

    SUM(delivered_at IS NOT NULL) AS delivered_orders,

    SUM(
        CASE
            WHEN delivered_at <= promised_at THEN 1
            ELSE 0
        END
    ) AS on_time_orders,

    SUM(
        CASE
            WHEN delivered_at > promised_at THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivered_at <= promised_at THEN 1
                ELSE 0
            END
        ) /
        NULLIF(
            SUM(
                CASE
                    WHEN delivered_at IS NOT NULL
                     AND promised_at IS NOT NULL
                    THEN 1 ELSE 0
                END
            ), 0
        ), 2
    ) AS on_time_delivery_pct

FROM orders_clean

GROUP BY DATE_FORMAT(order_date, '%Y-%m')
	
ORDER BY order_month;

--- Q5 Why Performance decline in May ---

	SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    carrier_id,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN delivered_at <= promised_at THEN 1
        ELSE 0
    END) AS on_time_orders,
    ROUND(
        100.0 * SUM(CASE
            WHEN delivered_at <= promised_at THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS on_time_delivery_pct
FROM orders_clean
WHERE delivered_at IS NOT NULL
  AND promised_at IS NOT NULL
GROUP BY
    DATE_FORMAT(order_date, '%Y-%m'),
    carrier_id
ORDER BY
    order_month,
    on_time_delivery_pct;
    
    --- Q6 Does Carrier performance change depend on the warehouse? ---
    
    SELECT
    warehouse_id,
    carrier_id,
    COUNT(*) AS total_orders,

    ROUND(
        AVG(TIMESTAMPDIFF(HOUR, dispatched_at, delivered_at)),
        2
    ) AS avg_delivery_hours,

    ROUND(
        100.0 * SUM(
            CASE WHEN delivered_at <= promised_at
            THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS on_time_delivery_pct

FROM orders_clean

WHERE delivered_at IS NOT NULL
  AND promised_at IS NOT NULL

GROUP BY warehouse_id, carrier_id

ORDER BY warehouse_id, on_time_delivery_pct DESC;
    
    