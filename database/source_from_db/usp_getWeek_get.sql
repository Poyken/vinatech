CREATE  PROCEDURE [dbo].[usp_getWeek_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
	select 1 as Weeks
	UNION 
	select 2 as Weeks
	UNION
	select 3 as Weeks
	UNION
	select 4 as Weeks
	UNION
	select 5 as Weeks
END