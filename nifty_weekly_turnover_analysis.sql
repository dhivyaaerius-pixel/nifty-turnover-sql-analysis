use stock_analysis

/* On days where today’s turnover is higher than last week’s average turnover,
    what tends to happen tomorrow?” */



IF OBJECT_ID('tempdb..#Signal') IS NOT NULL
DROP TABLE #Signal;   ---- to drop temporary table

SET DATEFIRST 1; -- monday 

WITH weekly_avg AS (
    SELECT                                          -- finding weekly average turnover
        DATEADD(DAY, 1 - DATEPART(WEEKDAY, [date]), [date]) AS week_start,
        AVG(Turnover_Cr) AS avg_weekly_turnover
    FROM niftyOneYear
	GROUP BY DATEADD(DAY, 1 - DATEPART(WEEKDAY, [date]), [date])
),
weekly_with_prev AS (
    SELECT
        week_start,
        avg_weekly_turnover,                        -- finding previous week avg using lag
        LAG(avg_weekly_turnover) OVER (ORDER BY week_start) AS prev_week_avg
    FROM weekly_avg
),
next_day_oc AS (
	SELECT   
		date,
		LEAD([OPEN]) OVER (Order by Date asc) AS Tomorrows_Open, -- next day open price
		LEAD([HIGH]) OVER (Order by Date asc) AS Tomorrows_High -- next day high
	FROM niftyOneYear
)

SELECT
    d.[Close] as Todays_close, 
	d.[High] as Todays_high,
	
    CASE
		WHEN  Tomorrows_Open > d.[Close] THEN 1 --- gapup calculation
		ELSE 0 	
	END AS GapUpFlag,	
	CASE
		WHEN Tomorrows_Open <  d.[Close] THEN 1 -- gapdown calculation
		ELSE 0 
	END AS GapDownFlag,
	CASE
		WHEN Tomorrows_High > d.[High] THEN 1 --- stregth continuation
		ELSE 0
	END  AS HigherHighFlag	
into #Signal
FROM niftyOneYear d
JOIN weekly_with_prev w
    ON DATEADD(DAY, 1 - DATEPART(WEEKDAY, d.[date]), d.[date]) = w.week_start
		JOIN next_day_oc n
			ON d.date = n.date
WHERE w.prev_week_avg IS NOT NULL
and Tomorrows_Open IS NOT NULL
and d.Turnover_Cr > w.prev_week_avg 
ORDER BY d.[date];

--------------Final output--------------------------------

Select 

'If turnover > Previous_week_avg' as Title,

SUM(GapUpFlag) AS Nextday_GapUpCount,
ROUND(1.0 * SUM(GapUpFlag) / COUNT(*), 3) AS GapUp_probability,

SUM(GapDownFlag) AS Nextday_GapDownCount,
ROUND(1.0 * SUM(GapDownFlag) / count(*), 3) AS GapDown_probability,

SUM(HigherHighFlag) AS Nextday_HHcount,
ROUND(1.0 * SUM(HigherHighFlag) / COUNT(*), 3) AS HH_probability

from #Signal

