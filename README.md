# RETENTION-ANALYSIS
A time-based cohort analysis for an online retail dataset to better understand behaviors, patterns and trends for customers.
#  :large_blue_diamond:	:green_circle:  :large_blue_diamond:
Cohort analysis is a data analysis technique that is used to understand the behavior of a group of individuals (cohort) over time. It categorizes customers into groups based on common characteristics, such as when they first became customers (cohort period), and tracks their behaviors and purchasing patterns over time.
To create our cohort index we first identified the cohort period, which is typically the month in which a customer first made a purchase. Then we made a table that categorizes each customer into a cohort based on their first purchase date such that it would show customer's return after their initial purchase(return customers), and calculated the retention rate for each cohort.

![](Images/Screenshot%20(292).png)
![](Images/Screenshot%20(293).png)
To create the cohort index, combine the customer and purchase data, grouping the data by cohort period and purchase date, and calculating the number of customers who made a purchase in each cohort and time period.
![](Images/Screenshot%20(294).png)
From tableau we could clearly see the customers that came back again after their first purchase in January 2010 were 95 compared to returning customers in January 2011 as 331.
