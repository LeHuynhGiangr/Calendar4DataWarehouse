IF OBJECT_ID('func_gen_day_seq') IS NOT NULL  
    DROP FUNCTION [func_gen_day_seq];  
GO 
CREATE FUNCTION func_gen_day_seq
(
	@year INT,
	@month INT
)
RETURNS TABLE
AS
RETURN
(
	WITH seq(d) AS
	(
		SELECT d = 1
		UNION ALL
		SELECT d + 1 FROM seq WHERE d < DATEPART(DAY, EOMONTH(DATEFROMPARTS(@year, @month, 1)))
	)
	SELECT seq.d FROM seq
)
GO
IF OBJECT_ID('func_gen_calendar') IS NOT NULL  
    DROP FUNCTION [func_gen_calendar];  
GO 
CREATE FUNCTION func_gen_calendar
(
	@start_year INT,
	@end_year INT
)
RETURNS TABLE
AS
RETURN
(
	WITH year_seq(y) AS
	(
		SELECT y = @start_year
		UNION ALL
		SELECT y + 1 FROM year_seq WHERE y < @end_year
	),	
	month_seq(m) AS
	(
		SELECT m = 1
		UNION ALL
		SELECT m + 1 FROM month_seq WHERE m < 12
	),	
	year_month_seq(y, m) AS
	(
		SELECT y = year_seq.y, m = month_seq.m FROM year_seq, month_seq
	)
	SELECT DATEFROMPARTS(year_month_seq.y, year_month_seq.m, day_seq.d) AS [id]
	, year_month_seq.y AS [year]
	, year_month_seq.m AS [month]
	, day_seq.d AS [day_of_month]
	FROM year_month_seq 
	CROSS APPLY func_gen_day_seq(year_month_seq.y, year_month_seq.m) day_seq
)
GO

SELECT d.[id]
,d.[year]
,DATEPART(QUARTER, d.[id]) AS [quarter]
,d.[month]
,d.[day_of_month]
,DATENAME(WEEKDAY, d.[id]) AS [day_of_week]
FROM func_gen_calendar(2013, 2023) d
GO