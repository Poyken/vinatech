-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_MeetingReportYear_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pYears int = null

AS
BEGIN

select [Year],case when [1] is null then '' else concat([1],'') end [1],
case when [2] is null then '' else concat([2],'') end [2],
case when [3] is null then '' else concat([3],'') end [3],
case when [4] is null then '' else concat([4],'') end [4],
case when [5] is null then '' else concat([5],'') end [5],
case when [6] is null then '' else concat([6],'') end [6],
case when [7] is null then '' else concat([7],'') end [7],
case when [8] is null then '' else concat([8],'') end [8],
case when [9] is null then '' else concat([9],'') end [9],
case when [10] is null then '' else concat([10],'') end [10],
case when [11] is null then '' else concat([11],'') end [11],
case when [12] is null then '' else concat([12],'') end [12] ,SUMM from 
	(select [Year],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
	FROM (
	  SELECT N'Sum Metting Open' AS  [Year], Month(Date_Meeting) AS MonthM,  sum(case when status='OPEN' then 1 else 0 end) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
			where Year(Date_Meeting) = @pYears 
			group by Year(Date_Meeting),Month(Date_Meeting)
			) x
	  PIVOT (sum(statusopen) FOR  MonthM  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
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
		
		where Year(Date_Meeting) = @pYears 
		group by Year(Date_Meeting)) pvt1)pvt2
		where  a.[Year] = pvt2.status 
	
UNION
select [Year],case when [1] is null then '' else concat([1],'') end [1],
case when [2] is null then '' else concat([2],'') end [2],
case when [3] is null then '' else concat([3],'') end [3],
case when [4] is null then '' else concat([4],'') end [4],
case when [5] is null then '' else concat([5],'') end [5],
case when [6] is null then '' else concat([6],'') end [6],
case when [7] is null then '' else concat([7],'') end [7],
case when [8] is null then '' else concat([8],'') end [8],
case when [9] is null then '' else concat([9],'') end [9],
case when [10] is null then '' else concat([10],'') end [10],
case when [11] is null then '' else concat([11],'') end [11],
case when [12] is null then '' else concat([12],'') end [12] ,SUMM from 
(select [Year],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM (
  SELECT N'Sum Meeting close' AS [Year], Month(Date_Meeting) AS MonthM,  sum(case when status='CLOSE' then 1 else 0 end) statusopen
	--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
	FROM Stb_MeetingAgenda
		where Year(Date_Meeting) = @pYears 
		group by Year(Date_Meeting),Month(Date_Meeting)
		) x
  PIVOT (sum(statusopen) FOR  MonthM  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
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
		
		where Year(Date_Meeting) = @pYears 
		group by Year(Date_Meeting)) pvt1)pvt2
		where  a.[Year] = pvt2.status 
		

UNION
select [Year],case when [1] is null then '' else concat([1],'') end [1],
case when [2] is null then '' else concat([2],'') end [2],
case when [3] is null then '' else concat([3],'') end [3],
case when [4] is null then '' else concat([4],'') end [4],
case when [5] is null then '' else concat([5],'') end [5],
case when [6] is null then '' else concat([6],'') end [6],
case when [7] is null then '' else concat([7],'') end [7],
case when [8] is null then '' else concat([8],'') end [8],
case when [9] is null then '' else concat([9],'') end [9],
case when [10] is null then '' else concat([10],'') end [10],
case when [11] is null then '' else concat([11],'') end [11],
case when [12] is null then '' else concat([12],'') end [12] ,SUMM from 
(select [Year],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM (
   SELECT N'Sum Meeting' AS [Year], Month(Date_Meeting) AS MonthM, 
  --sum(case when status='OPEN' then 1 else 0 end) statusopen
	-- sum(case when status='CLOSE' then 1 else 0 end) statusclose 
	sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
	FROM Stb_MeetingAgenda
		where Year(Date_Meeting) = @pYears  
		group by Year(Date_Meeting),Month(Date_Meeting)
		
		) x
  PIVOT (sum(Total) FOR  MonthM  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
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
		
		where Year(Date_Meeting) = @pYears  
		group by Year(Date_Meeting)) pvt1)pvt2
		where  a.[Year] = pvt2.status 
		
UNION
select [Year],case when [1] is null then '' else concat([1],'%') end [1],
case when [2] is null then '' else concat([2],'%') end [2],
case when [3] is null then '' else concat([3],'%') end [3],
case when [4] is null then '' else concat([4],'%') end [4],
case when [5] is null then '' else concat([5],'%') end [5],
case when [6] is null then '' else concat([6],'%') end [6],
case when [7] is null then '' else concat([7],'%') end [7],
case when [8] is null then '' else concat([8],'%') end [8],
case when [9] is null then '' else concat([9],'%') end [9],
case when [10] is null then '' else concat([10],'%') end [10],
case when [11] is null then '' else concat([11],'%') end [11],
case when [12] is null then '' else concat([12],'%') end [12] ,SUMM from 
(select [Year],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
FROM (
   SELECT N'Ratio' AS [Year], Month(Date_Meeting) AS MonthM, 
  --sum(case when status='OPEN' then 1 else 0 end) statusopen
	-- sum(case when status='CLOSE' then 1 else 0 end) statusclose 
	--sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
	ROUND(((CAST(sum(case when status='CLOSE' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio
	FROM Stb_MeetingAgenda
		where Year(Date_Meeting) = @pYears  
		group by Year(Date_Meeting),Month(Date_Meeting)
		) x
  PIVOT (sum(Ratio) FOR  MonthM  IN([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
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
		
		where Year(Date_Meeting) = @pYears  
		group by Year(Date_Meeting)) pvt1)pvt2
		where  a.[Year] = pvt2.status 
		
    
--exec sp_executesql @pYears
	
END

--exec usp_MeetingReportYear_get 'ngoloan','vi',2021