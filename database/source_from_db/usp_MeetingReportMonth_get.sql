-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_MeetingReportMonth_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pYearsM nvarchar(6) = NULL,
	@pMonth nvarchar(2) = NULL

AS
BEGIN


if (@pMonth !=null  OR @pMonth !='' ) 
BEGIN
	select [Month],case when [1] is null then '' else concat([1],'') end [1],
	case when [2] is null then '' else concat([2],'') end [2],
	case when [3] is null then '' else concat([3],'') end [3],
	case when [4] is null then '' else concat([4],'') end [4],
	case when [5] is null then '' else concat([5],'') end [5]
	 ,SUMM from 
		(select [Month],[1],[2],[3],[4],[5]
		FROM (
		  SELECT N'Sum Metting Open' AS  [Month], 
		  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
		  sum(case when status='OPEN' then 1 else 0 end) statusopen
			--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
			FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsM and Month(Date_Meeting) =@pMonth
				group by Year(Date_Meeting),Month(Date_Meeting), (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
				) x
		  PIVOT (sum(statusopen) FOR  WeekM  IN([1],[2],[3],[4],[5])
		) pvt) a,

			(select pvt1.* from(
			select Year(Date_Meeting) AS YearM
			
			-- ,Month(Date_Meeting) AS MonthM
			--,Day(Date_Meeting) AS DayM
			--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
			, N'Sum Metting Open' AS status
			, concat(CAST (sum(case when status='OPEN' then 1 else 0 end) as nvarchar(20)),'') as  'SUMM'
			, sum(case when status='CLOSE' then 1 else 0 end) statusclose
			,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
			, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

			from Stb_MeetingAgenda
		
			where Year(Date_Meeting) = @pYearsM and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting)
			--, (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
			) pvt1)pvt2
			where  a.[Month] = pvt2.status 


	UNION
	select [Month],case when [1] is null then '' else concat([1],'') end [1],
	case when [2] is null then '' else concat([2],'') end [2],
	case when [3] is null then '' else concat([3],'') end [3],
	case when [4] is null then '' else concat([4],'') end [4],
	case when [5] is null then '' else concat([5],'') end [5]
	,SUMM from 
	(select [Month],[1],[2],[3],[4],[5]
	FROM (
	  SELECT N'Sum Meeting close' AS [Month], 
  
	  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  Month(Date_Meeting) AS MonthM,  sum(case when status='CLOSE' then 1 else 0 end) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
			where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting), (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
			) x
	  PIVOT (sum(statusopen) FOR  WeekM  IN([1],[2],[3],[4],[5])
	) pvt) a,

	(select pvt1.* from(
	select Year(Date_Meeting) AS YearM
			
			-- ,Month(Date_Meeting) AS MonthM
			--,Day(Date_Meeting) AS DayM
			--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
			, N'Sum Meeting close' AS status
			, CAST (sum(case when status='OPEN' then 1 else 0 end) as nvarchar(20)) as  statusopen
			, concat(sum(case when status='CLOSE' then 1 else 0 end),'') 'SUMM'
			,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
			, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

			from Stb_MeetingAgenda
		
			where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting)
			--, (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1
			) pvt1)pvt2
			where  a.[Month] = pvt2.status 
		
	UNION
	select [Month],case when [1] is null then '' else concat([1],'') end [1],
	case when [2] is null then '' else concat([2],'') end [2],
	case when [3] is null then '' else concat([3],'') end [3],
	case when [4] is null then '' else concat([4],'') end [4],
	case when [5] is null then '' else concat([5],'') end [5],SUMM from 
	(select [Month],[1],[2],[3],[4],[5]
	FROM (
	   SELECT N'Sum Meeting' AS [Month],
	   --Month(Date_Meeting) AS MonthM, 
	   (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  --sum(case when status='OPEN' then 1 else 0 end) statusopen
		-- sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting), (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		
			) x
	  PIVOT (sum(Total) FOR  WeekM  IN([1],[2],[3],[4],[5])
	) pvt) a,

	(select pvt1.* from(
	select Year(Date_Meeting) AS YearM
			
			-- ,Month(Date_Meeting) AS MonthM
			--,Day(Date_Meeting) AS DayM
			--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
			, N'Sum Meeting' AS status
			, CAST (sum(case when status='OPEN' then 1 else 0 end) as nvarchar(20)) as  statusopen
			, sum(case when status='CLOSE' then 1 else 0 end) statusclose
			,concat(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end),'') as 'SUMM'
			, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

			from Stb_MeetingAgenda
		
			where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting)
			--, (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
			)pvt1)pvt2
			where  a.[Month] = pvt2.status 

	UNION
	select [MONTH],case when [1] is null then '' else concat([1],'%') end [1],
	case when [2] is null then '' else concat([2],'%') end [2],
	case when [3] is null then '' else concat([3],'%') end [3],
	case when [4] is null then '' else concat([4],'%') end [4],
	case when [5] is null then '' else concat([5],'%') end [5]
	,SUMM from 
	(select [Month],[1],[2],[3],[4],[5]
	FROM (
	   SELECT N'Ratio' AS [Month], 
	   --Month(Date_Meeting) AS MonthM, 
	  --sum(case when status='OPEN' then 1 else 0 end) statusopen
		-- sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		--sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Weeks,
		ROUND(((CAST(sum(case when status='CLOSE' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio
		FROM Stb_MeetingAgenda
			where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting), (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
			) x
	  PIVOT (sum(Ratio) FOR  Weeks  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
	) pvt) a,

	(select pvt1.* from(
	select Year(Date_Meeting) AS YearM
			
			-- ,Month(Date_Meeting) AS MonthM
			--,Day(Date_Meeting) AS DayM
			--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
			, N'Ratio' AS status
			, CAST (sum(case when status='OPEN' then 1 else 0 end) as nvarchar(20)) as  statusopen
			, sum(case when status='CLOSE' then 1 else 0 end) statusclose
			,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as total
			, concat(ROUND(((CAST(sum(case when status='CLOSE' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2),'%')  as SUMM

			from Stb_MeetingAgenda
		
		where Year(Date_Meeting) = @pYearsM  and Month(Date_Meeting) =@pMonth
			group by Year(Date_Meeting),Month(Date_Meeting)
			--, (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
			) pvt1)pvt2
			where  a.[Month] = pvt2.status 
			
END
else
	SELECT '' Month,
	'' AS '1',
	'' AS '2',
	'' AS '3',
	'' AS '4',
	'' AS '5',
	'' SUMM FROM Stb_MeetingAgenda WHERE 1=2
--exec sp_executesql @pYears
	
END

--exec usp_MeetingReportMonth_get 'ngoloan','vi',2021,04