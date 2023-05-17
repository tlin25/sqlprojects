-- Sample SQL project on Q1CY2023 US financial customer complaints data
-- Source: https://www.consumerfinance.gov/data-research/consumer-complaints/
CREATE TABLE complaints (
	date_received date,
    product text,
    subproduct text,
    issue text,
    subissue text,
    consumer_complaint_narrative text,
    company_public_response text,
    company text,
    state text,
    zip_code varchar(255),	
    tags text,
    consumer_consent text,
    submitted_via text,
    date_sent_to_company date,
    company_response text,
    timely_response text,
    consumer_disputed text,
    complaint_id int
    );
/* Dates in this file are presented as 'MM/dd/yy' (per File Explorer preview of csv) which resulted in an error in
 data upload
 Updated data types to receive this format and inserted new columns with correct date type to perform calculations */

ALTER TABLE complaints
MODIFY COLUMN date_received varchar(255);

ALTER TABLE complaints
MODIFY COLUMN date_sent_to_company varchar(255);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/complaints.csv"
INTO TABLE complaints
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

-- Check that the data was loaded correctly
SELECT *
FROM complaints
LIMIT 100;

-- Add date columns that can be used in calculations
ALTER TABLE complaints
ADD date_received_2 date,
ADD date_sent_to_company_2 date;
UPDATE complaints
SET date_received_2 = STR_TO_DATE(date_received, '%m/%d/%y');
UPDATE complaints
SET date_sent_to_company_2 = STR_TO_DATE(date_sent_to_company, '%m/%d/%y');

-- Check that dates are output correctly
SELECT *
FROM complaints
LIMIT 10;

-- Identify the products with most complaints, how many products exist in total
-- Results are that credit reporting / repair services have the most complaints
-- There are a total of 9 financial products: Credit reporting, debt collections, cards, loans and transfer services
SELECT ROW_NUMBER() OVER(ORDER BY COUNT(*) DESC) AS 'row',
 product, 
 COUNT(*) AS 'num_complaints'
FROM complaints
GROUP BY product
ORDER BY 3 DESC;

-- Realised that data download included complaints from 31/12/2022 which was on the cusp of the download period (Q12023)
-- Remove this data from the dataset
DELETE FROM complaints
WHERE EXTRACT(MONTH FROM date_received_2) = '12';

-- Is there a particular month in which more complaints are received?
SELECT CASE 
		WHEN EXTRACT(MONTH FROM date_received_2) = 1 THEN 'Jan'
		WHEN EXTRACT(MONTH FROM date_received_2) = 2 THEN 'Feb'    
		WHEN EXTRACT(MONTH FROM date_received_2) = 3 THEN 'Mar'
    END	AS 'month',
    product,
    COUNT(*) AS 'num_complaints'
FROM complaints
GROUP BY 1, 2
ORDER BY 3 DESC;
/* In March, 107,612 complaints were received compared to 94k in Jan and 86.5k in February. One explanation may 
	be that Jan has more public holidays, and Feb has less calendar days, which would reduce the number of complaints */

-- Targeting Credit reporting which has the most complaints, what is the biggest issue?
SELECT issue, COUNT(*) AS 'no_complaints'
FROM complaints
WHERE product LIKE '%Credit reporting%'
GROUP BY 1
ORDER BY 2 DESC;

-- Of "Improper use of your report", largest sub-issue?
SELECT subissue, COUNT(*) AS 'no_complaints'
FROM complaints
WHERE product LIKE '%Credit reporting%' AND issue LIKE '%Improper use%'
GROUP BY 1
ORDER BY 2 DESC;

-- Read some narratives to understand what the issue is? Seems like the problem is with companies using personal 
-- customer information without explicit consent
SELECT consumer_complaint_narrative
FROM complaints
WHERE product LIKE '%Credit reporting%' 
	AND issue LIKE '%Improper use%' 
    AND subissue LIKE '%Reporting company%';

-- Try to identify which companies?
-- Seems the main companies in question are Equifax, Transunion and Experian Information Solutions
SELECT company, COUNT(*) AS no_complaints
FROM complaints
WHERE product LIKE '%Credit reporting%' 
	AND issue LIKE '%Improper use%' 
    AND subissue LIKE '%Reporting company%'
GROUP BY 1
ORDER BY 2 DESC;

-- On the customer service side, calculate average response time by staff?
SELECT product,
	AVG(date_sent_to_company_2 - date_received_2) AS avg_response_time
FROM complaints
GROUP BY 1
ORDER BY 2;
