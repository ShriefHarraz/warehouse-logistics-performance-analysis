# Warehouse & Logistics Performance Analysis

A SQL and Power BI project analyzing warehouse operations, carrier performance, delivery reliability, and shipping costs using a synthetic UAE retail logistics dataset.

## 1. Project Overview

The objective of this project is to evaluate warehouse and logistics performance across four warehouses and five delivery carriers.

The analysis focuses on identifying operational bottlenecks, measuring delivery reliability, comparing logistics costs, and translating data insights into practical business recommendations.

**Business Questions**
- Which warehouses process the highest number of orders?
- Which warehouses have the fastest processing times?
- Which carriers provide the most reliable deliveries?
- Which carriers have the highest delivery delays and shipping costs?
- How does on-time delivery performance change over time?
- Are certain carriers underperforming at specific warehouses?

## 2. Tools & Technologies

- **SQL (MySQL):** Data cleaning, validation, transformation, and analysis.
- **Power BI:** Data modeling, KPI development, and interactive dashboards.
- **Excel / CSV:** Dataset handling and preparation.

## 3. Dataset

The project uses a synthetic UAE retail logistics dataset containing order-level information.

**Main data entities:**
- Orders
- Warehouses
- Carriers

**Key fields include:**
- Order date
- Processing, dispatch, promised, and delivery timestamps
- Warehouse and carrier IDs
- Units ordered and delivered
- Shipping cost (AED)
- Order status

*Note: The dataset is synthetic and intended for analytical and portfolio purposes. Findings should not be interpreted as actual company performance.*

## 4. Data Cleaning & Preparation

The raw orders dataset was inspected and prepared using SQL.

Key steps included:
- Identifying and removing duplicate order IDs.
- Validating timestamp sequences across order, processing, dispatch, and delivery stages.
- Identifying invalid shipping costs.
- Checking delivered quantities against ordered quantities.
- Creating a cleaned dataset for analysis.

The final `orders_clean` table contains **4,919 orders**.

The cleaning process reduced the deduplicated dataset from 4,970 to 4,919 records. Therefore, the analysis is based on the retained cleaned records.

## 5. Key Performance Indicators (KPIs)

| KPI | Result |
|---|---:|
| Total Orders | 4,919 |
| On-Time Delivery Rate | 80.18% |
| Average Shipping Cost | AED 19.92 |
| Total Shipping Cost | AED 97,988 |

## 6. Key Findings

### Warehouse Performance

- **Dubai** handled the highest order volume with 1,694 orders.
- Dubai also recorded the highest average processing time (4.73 hours) and average shipping cost (AED 20.17).
- **Al Ain** recorded the fastest average processing time (4.48 hours) and lowest average shipping cost (AED 19.72).
- Sharjah achieved the highest warehouse on-time delivery rate at 81.20%.
- Dubai recorded the lowest warehouse on-time delivery rate at 79.16%.

### Carrier Performance

- **FalconLogistics** achieved the highest on-time delivery rate at 86.78%.
- **GulfExpress** recorded the shortest average delivery time (15.18 hours) and lowest average shipping cost (AED 19.22).
- **QuickRoute** had the weakest delivery performance, with an on-time rate of 72.17%, an average delivery time of 26.28 hours, and 285 late orders.
- **DesertLine** also underperformed, achieving a 75.73% on-time delivery rate and recording 233 late orders.

### Monthly Delivery Trends

On-time delivery performance fluctuated throughout 2025 rather than improving consistently.

The dashboard highlights a noticeable decline in May and a recovery in June, followed by further fluctuations during the second half of the year.

This suggests that delivery reliability should be monitored continuously rather than assessed using annual averages alone.

## 7. Business Recommendations

### 1. Review QuickRoute and DesertLine Performance

QuickRoute and DesertLine recorded the weakest on-time delivery rates and the highest late-order counts.

**Recommended actions:**
- Review delivery routes and dispatch schedules.
- Investigate recurring causes of late deliveries.
- Agree on measurable service-level improvement targets.
- Monitor weekly on-time delivery performance.

### 2. Use High-Performing Carriers as Benchmarks

FalconLogistics achieved the highest on-time delivery rate, while GulfExpress delivered the fastest average delivery time at the lowest average shipping cost.

**Recommended actions:**
- Study the operational practices of both carriers.
- Compare their service performance across warehouses.
- Evaluate opportunities for reallocating some orders through controlled pilot tests, subject to capacity and service-level agreements.

### 3. Investigate Dubai Warehouse Performance

Dubai processed the highest order volume but also recorded the highest average processing time, highest average shipping cost, and lowest on-time delivery rate among the four warehouses.

**Recommended actions:**
- Review workload distribution and staffing during peak periods.
- Investigate processing and dispatch bottlenecks.
- Compare performance with Al Ain, which recorded the fastest processing time and lowest average cost.
- Monitor improvement using processing time and on-time delivery KPIs.

### 4. Monitor Carrier-Warehouse Combinations

The carrier-by-warehouse analysis shows that carrier performance differs across warehouse locations.

**Recommended actions:**
- Identify combinations with consistently weak delivery reliability.
- Investigate whether specific routes or operational conditions contribute to delays.
- Evaluate carrier allocation based on location-level performance rather than overall averages alone.

### 5. Establish Continuous Performance Monitoring

Use a regular KPI review to track:
- On-time delivery rate
- Late orders
- Average delivery time
- Average processing time
- Average shipping cost

This will help management identify operational problems earlier and evaluate whether corrective actions are working.

## 8. Project Limitations

- The dataset is synthetic and does not represent actual company operations.
- The analysis uses 4,919 cleaned orders from the imported dataset.
- Some operational factors, such as route distance, traffic, driver availability, and weather, are not included.
- The findings identify performance differences and potential areas for investigation; they do not establish the causes of those differences.

## 9. Project Files

| File | Description |
|---|---|
| `orders_raw.csv` | Raw order-level dataset |
| `warehouses.csv` | Warehouse reference data |
| `carriers.csv` | Carrier reference data |
| `warehouse_logistics_analysis.sql` | SQL cleaning and analysis queries |
| `Warehouse_Logistics_Performance_Analysis.pbix` | Interactive Power BI dashboard |

## 10. Dashboard Preview

The Power BI report contains three analytical pages:

1. **Overview:** Overall KPIs, warehouse performance, carrier performance, and monthly delivery trends.
2. **Carrier Deep Dive:** Delivery time, shipping cost, and late orders by carrier.
3. **Warehouse Deep Dive:** Processing time, shipping cost, on-time delivery, and carrier performance by warehouse.
## Dashboard Preview

### Executive Overview
![Executive Overview](<Screenshot 2026-11-14 201958.png>)

### Carrier Performance Analysis
![Carrier Performance](<Screenshot 2026-11-14 202028.png>)

### Warehouse Deep Dive
![Warehouse Performance](<Screenshot 2026-11-14 202057.png>)

---

**Project Focus:** Turning operational data into actionable insights for warehouse efficiency, carrier selection, and logistics performance improvement.
