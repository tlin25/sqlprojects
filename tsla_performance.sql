-- personal SQL project to identify the stock performance trends of Tesla
-- Data downloaded from Yahoo Finance

CREATE TABLE tesla_stock (
	date DATE,
    day_open FLOAT(2),
    day_high FLOAT(2),
    day_low FLOAT(2),
    day_close FLOAT(2),
    day_adj_close FLOAT(2),
    volume int
);
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/TSLA.csv"
INTO TABLE tesla_stock
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY "\n"
IGNORE 1 ROWS;

-- Identify the days on which TSLA stock experienced the greatest increase / decrease
SELECT date,
	day_adj_close,
    volume,
    (1.0 * day_adj_close / day_open) - 1.0 AS day_change
FROM tesla_stock
ORDER BY day_change DESC
LIMIT 5;
SELECT date,
	day_adj_close,
    volume,
    (1.0 * day_adj_close / day_open) - 1.0 AS day_change
FROM tesla_stock
ORDER BY day_change
LIMIT 5;
/* Results show biggest day-on-day increase was at 2010-06-29 (stock listing), then 2010-11-10 when a broker report
	suggested TSLA was a strong buy. 
	Largest decrease on 2012-01-13 following departure of an executive, then 2010-07-06 as markets calmed down
    after TSLA's initial IPO*/
    
-- Identify which month the largest daily average volume of TSLA stock was traded in 2022
SELECT date_format(date, '%m') AS month,
		AVG(volume) AS avg_volume
FROM tesla_stock
WHERE date_format(date, '%Y') = 2022
GROUP BY 1
ORDER BY 2 DESC;
/* In 2022, TSLA stock was most traded in December (by daily average). Delve into which days had the most
trading volume in December */

SELECT date,
	volume
FROM tesla_stock
WHERE date_format(date, '%Y-%m') = '2022-12'
ORDER BY 2 DESC;

/* Most stock was traded towards the end of December (27/28/29th). A quick google indicates that this was due to
consumer response to the US Labor Department release of employment data which indicated a softening of the labour market
