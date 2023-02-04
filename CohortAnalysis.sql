---Cleaning Data
SELECT COUNT(*)
FROM [Online Retail]
---The data contains 541909 rows including null values.


--Changing null values to 0 for CustomerID
UPDATE [Online Retail]
SET CustomerID=0
WHERE CustomerID IS NULL


---135,080 have no customerID in our dataset
---We want to remove those CustomerIDs
SELECT [InvoiceNo],
		  [StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
FROM [Online Retail]
Where CustomerID = 0

---406829 Rows in our dataset have valid CustomerIDs(We want to focus on these ones)
SELECT [InvoiceNo],
		  [StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
FROM [Online Retail]
Where CustomerID != 0 ---CustomerIDs that are not null

--CTE function for CustomerIDs that are not null,records I want to continue to work with
;with online_retail as
(SELECT [InvoiceNo],
		  [StockCode]
		  ,[Description]
		  ,[Quantity]
		  ,[InvoiceDate]
		  ,[UnitPrice]
		  ,[CustomerID]
		  ,[Country]
FROM [Online Retail]
Where CustomerID != 0
)
---Reduced the data from 406829 to 397,884 rows
---with quantity and unit price greater than 0
,quantity_unit_price as (
SELECT *
FROM online_retail
WHERE Quantity >0 and UnitPrice>0
)
,dup_check as (
---duplicate check

SELECT * ,ROW_NUMBER() over (PARTITION BY InvoiceNo,StockCode,Quantity ORDER BY InvoiceDate) dup_flag
---For the dup flag it simply means if the value for invoiceno,stockcode and quantity are the same over different invoice date add to show duplicated if it comes up a second time.
FROM quantity_unit_price
)
SELECT *
into #online_retail_ ---creating temp table
FROM dup_check
WHERE dup_flag=1
---After only filtering the values that are unique we are left with 392,669 rows that we are interest in our dataset.This is what we would consider our clean data for cohort analysis.
--Our dup_flag shows we have about 5,215 rows of duplicated records in our dataset
---The problem with a CTE is we would have to run everything together everytime we would like to call a function so Instead of this we will create a temp table to make work more efficient.

---	Clean Data
--BEGIN COHORT ANALYSIS 
SELECT *
FROM #online_retail_
--For a cohort analysis we need:Unique Identifier(CustomerID),Initial Start Date(First Inoice Date),Revenue Data
SELECT CustomerID,min(InvoiceDate) first_purchase_date,
DATEFROMPARTS(year(min(InvoiceDate)),month(min(InvoiceDate)),1) Cohort_Date
INTO #COHORT
FROM #online_retail_
GROUP BY CustomerID

SELECT *
FROM #COHORT
---A cohort analysis table is used to understand the behaviour of Customers to help see patterns and trends.
---A cohort analysis is an analysis of several different cohorts to get a better understanding of behaviors,patterns and trends.

--Create Cohort Index
--Integer representation of the number of months that has passed since the customers' first engagement.
SELECT m.*,c.Cohort_Date,year(m.InvoiceDate) invoice_year,month(m.InvoiceDate) invoice_month,year(c.Cohort_Date) cohortyear,month(c.Cohort_Date) cohortmonth
FROM #online_retail_ m
left join #COHORT c
ON m.CustomerID=c.CustomerID

SELECT mm.*,year_diff=invoice_year - cohortyear,month_diff=invoice_month - cohortmonth
FROM (SELECT m.*,c.Cohort_Date,year(m.InvoiceDate) invoice_year,month(m.InvoiceDate) invoice_month,year(c.Cohort_Date) cohortyear,month(c.Cohort_Date) cohortmonth
FROM #online_retail_ m
left join #COHORT c
ON m.CustomerID=c.CustomerID) mm

SELECT 
mmm.*,cohort_index=year_diff*12+month_diff+1
from(
SELECT
mm.*,
year_diff=invoice_year-cohortyear,
month_diff=invoice_month-cohortmonth
FROM(
SELECT m.*,c.Cohort_Date,year(m.InvoiceDate) invoice_year,month(m.InvoiceDate) invoice_month,year(c.Cohort_Date) cohortyear,month(c.Cohort_Date) cohortmonth
FROM #online_retail_ m
left join #COHORT c
ON m.CustomerID=c.CustomerID
)mm
)mmm

---Creating temporary table called Cohort Retention for the cohort index
SELECT 
mmm.*,cohort_index=year_diff*12+month_diff+1
into #cohort_retention
from(
SELECT
mm.*,
year_diff=invoice_year-cohortyear,
month_diff=invoice_month-cohortmonth
FROM(
SELECT m.*,c.Cohort_Date,year(m.InvoiceDate) invoice_year,month(m.InvoiceDate) invoice_month,year(c.Cohort_Date) cohortyear,month(c.Cohort_Date) cohortmonth
FROM #online_retail_ m
left join #COHORT c
ON m.CustomerID=c.CustomerID
)mm
)mmm

SELECT *
FROM #cohort_retention
---The results from the #cohort_retention temptable are going to be used to create a dashboard on Tableau.

--Pivot Data to see cohort table
SELECT DISTINCT CustomerID,Cohort_Date,cohort_index
FROM #cohort_retention
ORDER BY 1,3

SELECT *
INTO #cohort_pivot 
FROM(
SELECT DISTINCT CustomerID,Cohort_Date,cohort_index
FROM #cohort_retention
) tbl
pivot(
COUNT(CustomerID)
for cohort_index In 
(
[1],
[2],
[3],
[4],
[5],
[6],
[7],
[8],
[9],
[10],
[11],
[12],
[13],
[14],
[15],
[16],
[17],
[18],
[19],
[20],
[21],
[22],
[23],
[24])
)as pivottable
WHERE Cohort_Date IS NOT NULL
ORDER BY Cohort_Date

--we use the unique ID  for our cohort_index to form our pivottable
SELECT DISTINCT cohort_index
FROM #cohort_retention
ORDER BY 1

SELECT *,1.0*[1]/[1] * 100,1.0*[2]/[1]*100 
FROM #cohort_pivot 
ORDER BY Cohort_Date