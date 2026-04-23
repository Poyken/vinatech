CREATE  PROCEDURE [dbo].[usp_YearMonthW_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
	select 1 as Month, 1 as MonthW, 1 as MonthsD
	UNION 
	select 2 as Month, 2 as MonthW, 2 as MonthsD
	UNION 
	select 3 as Month, 3 as MonthW, 3 as MonthsD
	UNION 
	select 4 as Month, 4 as MonthW, 4 as MonthsD
	UNION 
	select 5 as Month, 5 as MonthW, 5 as MonthsD
	UNION 
	select 6 as Month, 6 as MonthW, 6 as MonthsD
	UNION 
	select 7 as Month, 7 as MonthW, 7 as MonthsD
	UNION 
	select 8 as Month, 8 as MonthW, 8 as MonthsD
	UNION 
	select 9 as Month, 9 as MonthW, 9 as MonthsD
	UNION 
	select 10 as Month, 10 as MonthW, 10 as MonthsD
	UNION 
	select 11 as Month, 11 as MonthW, 11 as MonthsD
	UNION 
	select 12 as Month, 12 as MonthW, 12 as MonthsD

END

