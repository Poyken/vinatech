-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_MeetingReportWeek_get_j]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pYearsW int = 2005,
	@pMonthW int = 01,
	@pWeek int = 01

AS
BEGIN
	
	

    DECLARE @date nvarchar(max)
	DECLARE @query  AS NVARCHAR(MAX)
	DECLARE @year nvarchar(20) =@pYearsW
	DECLARE @Month nvarchar(20) = @pMonthW
	DECLARE @Week nvarchar(20) =@pWeek

	PRINT @year
	PRINT @Month
	PRINT @Week



	;WITH N(N)AS 
	(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
	tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)
  
	--select @date = datefromparts(@pYears,@pMonth,N) as date1  FROM tally
	--WHERE N <= day(EOMONTH(datefromparts(@pYears,@pMonth,1))) and (DATEPART(week, datefromparts(@pYears,@pMonth,N)) - DATEPART(week, DATEADD(day, 1, EOMONTH(datefromparts(@pYears,@pMonth,N), -1)))) + 1 = @pWeek

	select @date = STUFF((SELECT  '],[' + convert(varchar, datefromparts(@pYearsW,@pMonthW,N), 120) 
                    FROM tally WHERE N <= day(EOMONTH(datefromparts(@pYearsW,@pMonthW,1))) and (DATEPART(week, datefromparts(@pYearsW,@pMonthW,N)) - DATEPART(week, DATEADD(day, 1, EOMONTH(datefromparts(@pYearsW,@pMonthW,N), -1)))) + 1 = @pWeek
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,2,'')
		select @date = @date + ']'

	PRINT @date

SELECT @query=N'	select  a.*,SUMM from (select  *
		FROM (
		  SELECT ''Sum Metting Open'' AS  [Weeks], 
		  Date_Meeting as Date_Meeting,
		  concat(sum(case when status=''OPEN'' then 1 else 0 end),'''') statusopen
			FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
				group by Date_Meeting
				) x
		 PIVOT 
	(
		max(statusopen)
		for [Date_Meeting] in (' + @date + N')
	) P) a,
	
			(select pvt1.* from(
		select 
		''Sum Metting Open'' AS status
		, concat(CAST (sum(case when status=''OPEN'' then 1 else 0 end) as nvarchar(20)),'''') as  SUMM
		, ROUND(((CAST(sum(case when status=''CLOSE'' then 1 else 0 end) as float)/ cast(sum(case when status in (''CLOSE'',''OPEN'') then 1 else 0 end) as float)))*100,2)  as Ratio

		from Stb_MeetingAgenda
		
		where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
		group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Weeks] = pvt2.status 

		union 
		select  a.*,SUMM from (select  *
		FROM (
		  SELECT ''Sum Metting Close'' AS  [Weeks], 
		  Date_Meeting as Date_Meeting,
		  concat(sum(case when status=''CLOSE'' then 1 else 0 end),'''') statusopen
			FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
				group by Date_Meeting
				) x
		 PIVOT 
	(
		max(statusopen)
		for [Date_Meeting] in (' + @date + N')
	) P) a,
	
			(select pvt1.* from(
		select 
		''Sum Metting Close'' AS status
		, concat(CAST (sum(case when status=''CLOSE'' then 1 else 0 end) as nvarchar(20)),'''') as  SUMM
		, ROUND(((CAST(sum(case when status=''CLOSE'' then 1 else 0 end) as float)/ cast(sum(case when status in (''CLOSE'',''OPEN'') then 1 else 0 end) as float)))*100,2)  as Ratio

		from Stb_MeetingAgenda
		
		where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
		group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Weeks] = pvt2.status

		union 
		select  a.*,SUMM from (select  *
		FROM (
		  SELECT ''Sum Metting'' AS  [Weeks], 
		  Date_Meeting as Date_Meeting,
		  concat(sum(case when status IN (''CLOSE'',''OPEN'') then 1 else 0 end),'''') statusopen
			FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
				group by Date_Meeting
				) x
		 PIVOT 
	(
		max(statusopen)
		for [Date_Meeting] in (' + @date + N')
	) P) a,
	
			(select pvt1.* from(
		select 
		''Sum Metting'' AS status
		, concat(concat(CAST (sum(case when status IN (''OPEN'',''CLOSE'') then 1 else 0 end) as nvarchar(20)),''''),'''') as  SUMM
		, ROUND(((CAST(sum(case when status=''CLOSE'' then 1 else 0 end) as float)/ cast(sum(case when status in (''CLOSE'',''OPEN'') then 1 else 0 end) as float)))*100,2)  as Ratio

		from Stb_MeetingAgenda
		
		where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
		group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Weeks] = pvt2.status

		UNION 

	 
		select  a.*,SUMM from (select  *
		FROM (
		  SELECT ''Ratio'' AS  [Weeks], 
		  Date_Meeting as Date_Meeting,
		 concat(ROUND(((CAST(sum(case when status=''CLOSE'' then 1 else 0 end) as float)/ cast(sum(case when status in (''CLOSE'',''OPEN'') then 1 else 0 end) as float)))*100,2),''%'')  as Ratio
			FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
				group by Date_Meeting
				) x
		 PIVOT 
	(
		Max(Ratio)
		for [Date_Meeting] in (' + @date + N')
	) P) a,
	
			(select pvt1.* from(
		select 
		''Ratio'' AS status
		, concat(ROUND(((CAST(sum(case when status=''CLOSE'' then 1 else 0 end) as float)/ cast(sum(case when status in (''CLOSE'',''OPEN'') then 1 else 0 end) as float)))*100,2),''%'')  as SUMM

		from Stb_MeetingAgenda
		
		where Year(Date_Meeting) = '+@year+' and Month(Date_Meeting) ='+@Month+' and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  ='+ @Week+'
		group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Weeks] = pvt2.status

	'

EXEC SP_EXECUTESQL @query
--SELECT @query
	
	
END

--exec usp_MeetingReportWeek_get_j 'ngoloan','vi',2021,04,01