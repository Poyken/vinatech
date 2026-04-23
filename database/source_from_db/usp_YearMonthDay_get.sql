CREATE  PROCEDURE [dbo].[usp_YearMonthDay_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)

AS
BEGIN
	select Year(getdate()) as Years, Year(getdate()) as YearsM, Year(getdate()) as YearsW,  Year(getdate()) as YearsD
	union 
	select Year(getdate()) -5 as Years, Year(getdate()) -5 as YearsM, Year(getdate()) -5 as YearsW, Year(getdate()) -5 as YearsD
	union 
	select Year(getdate()) -4 as Years, Year(getdate()) -4 as YearsM, Year(getdate()) -4 as YearsW, Year(getdate()) -4 as YearsD
	union 
	select Year(getdate()) -3 as Years, Year(getdate()) -3 as YearsM, Year(getdate()) -3 as YearsW, Year(getdate()) -3 as YearsD
	union 
	select Year(getdate()) -2 as Years, Year(getdate()) -2 as YearsM, Year(getdate()) -2 as YearsW, Year(getdate()) -2 as YearsD
	union 
	select Year(getdate()) -1 as Years, Year(getdate()) -1 as YearsM, Year(getdate()) -1 as YearsW, Year(getdate()) -1 as YearsD
	union
	select Year(getdate()) as Years, Year(getdate()) as YearsM, Year(getdate()) as YearsW, Year(getdate()) as YearsD
	union
	select Year(getdate()) +1 as Years, Year(getdate()) +1 as YearsM, Year(getdate()) +1 as YearsW, Year(getdate()) +1 as YearsD
	union
	select Year(getdate()) +2 as Years, Year(getdate()) +2 as YearsM, Year(getdate()) +2 as YearsW, Year(getdate()) +2 as YearsD
	union
	select Year(getdate()) +3 as Years, Year(getdate()) +3 as YearsM, Year(getdate()) +3 as YearsW, Year(getdate()) +3 as YearsD
	union
	select Year(getdate()) +4 as Years, Year(getdate()) +4 as YearsM, Year(getdate()) +4 as YearsW, Year(getdate()) +4 as YearsD
	union
	select Year(getdate()) +5 as Years, Year(getdate()) +5 as YearsM, Year(getdate()) +5 as YearsW, Year(getdate()) +5 as YearsD
	union
	select Year(getdate()) +6 as Years, Year(getdate()) +6 as YearsM, Year(getdate()) +6 as YearsW, Year(getdate()) +6 as YearsD
	union
	select Year(getdate()) +7 as Years, Year(getdate()) +7 as YearsM, Year(getdate()) +7 as YearsW, Year(getdate()) +7 as YearsD
	union
	select Year(getdate()) +8 as Years, Year(getdate()) +8 as YearsM, Year(getdate()) +8 as YearsW, Year(getdate()) +8 as YearsD
	union
	select Year(getdate()) +9 as Years, Year(getdate()) +9 as YearsM, Year(getdate()) +9 as YearsW, Year(getdate()) +9 as YearsD
	union
	select Year(getdate()) +10 as Years, Year(getdate()) +10 as YearsM, Year(getdate()) +10 as YearsW, Year(getdate()) +10 as YearsD

END