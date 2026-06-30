SELECT *
from project3.cleaned_sales_satisfaction;


USE project3;

CREATE VIEW segment_tiering AS
with overall_average AS (SELECT
avg(Sales_Growth) as overall_sales_average
from project3.cleaned_sales_satisfaction
)
select
Customer_Segment,
avg(Sales_Growth) as average_sales_by_segment,
CASE
WHEN AVG(Sales_Growth)>=(SELECT overall_sales_average *1.2 from overall_average) THEN 'high'
WHEN avg(Sales_Growth)>=(select overall_sales_average * 0.8 from overall_average) THEN 'medium'
ELSE 'low'
end as performer_tier
from project3.cleaned_sales_satisfaction
GROUP by Customer_Segment;

SELECT * FROM segment_tiering;


USE project3;
CREATE VIEW ranked_segment AS
select
`Group`,
Customer_Segment,
avg(ROI_index) as average_index,
rank() OVER (PARTITION BY `Group` ORDER by avg(ROI_index) DESC) as rnk
from project3.cleaned_sales_satisfaction
GROUP BY `Group`,Customer_Segment;

SELECT * from ranked_segment;


USE project3;
CREATE VIEW cust_conversion_rate AS
SELECT
Customer_Segment,
count(*) as total_customer,
sum(CASE WHEN Purchase_Made='Yes' THEN 1 ELSE 0 end) as yes_customer,
round((sum(CASE WHEN Purchase_Made='Yes' THEN 1 ELSE 0 end)/count(*))*100,2) as cust_conv_per
from project3.cleaned_sales_satisfaction
GROUP BY Customer_Segment;

SELECT * FROM cust_conversion_rate;



USE project3;
CREATE VIEW impact_corr AS
with quartile_rate AS(SELECT
Sales_Growth,
Satisfaction_Growth,
NTILE(4) over(ORDER by Satisfaction_Growth) as satisfaction_quartile
from project3.cleaned_sales_satisfaction
)
select
satisfaction_quartile,
avg(Sales_Growth) as average_sales,
count(*) as sample_size
from quartile_rate
Group by satisfaction_quartile
ORDER by satisfaction_quartile;

select *
from impact_corr;


USE project3;
CREATE VIEW runing_total as
with seg_sum as (
select
Customer_Segment,
sum(Sales_After) as segment_total_sales
from project3.cleaned_sales_satisfaction
Group by Customer_Segment
),
running_total as(
    Customer_Segment,
    segment_total_sales,
    sum(Customer_Segment) over (ORDER by segment_total_sales DESC) as runni_tot,
    sum(Customer_Segment) over() as total_sum 
    from seg_sum
)
select
segment_total_sales,Customer_Segment,
runni_tot,
total_sum,
round((runni_tot/total_sum*100),2) as cumsum_per
from running_total
ORDER by segment_total_sales DESC

