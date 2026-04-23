-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_MeetingReportWeek1_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pYearsW nvarchar(6) = NULL,
	@pMonthW nvarchar(2) = NULL,
	@pWeek nvarchar(1) = NULL

AS
BEGIN

if (@pMonthW !=null  OR @pMonthW !='' )  and (@pWeek != null OR @pWeek !='') 
BEGIN
	;WITH N(N)AS 
	(SELECT 1 FROM(VALUES(1),(1),(1),(1),(1),(1))M(N)),
	tally(N)AS(SELECT ROW_NUMBER()OVER(ORDER BY N.N)FROM N,N a)




	select [Month],case when [Sunday] is null then '' else concat([Sunday],'') end [Sunday],
	case when [Monday] is null then '' else concat([Monday],'') end [Monday],
case when [Tuesday] is null then '' else concat([Tuesday],'') end [Tuesday],
case when [Wednessday] is null then '' else concat([Wednessday],'') end [Wednessday],
case when [Thusday] is null then '' else concat([Thusday],'') end [Thusday],
case when [Friday] is null then '' else concat([Friday],'') end [Friday],
case when [Saturday] is null then '' else concat([Saturday],'') end [Saturday]

 ,SUMM from 
	(select [Month],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday],[Sunday]
	FROM (
	  SELECT N'Day' AS  [Month], 
		case when DATENAME(dw,date1)='일요일' then 'Sunday' 
		 when DATENAME(dw,date1)='월요일' then 'Monday'
		 when DATENAME(dw,date1)='화요일' then 'Tuesday' 
		 when DATENAME(dw,date1)='수요일' then 'Wednessday' 
		 when DATENAME(dw,date1)='목요일' then 'Thusday' 
		 when DATENAME(dw,date1)='금요일' then 'Friday' 
		else 'Saturday' end
		as DayinWeek ,
	--  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  max(date1) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM (	select  datefromparts(@pYearsW,@pMonthW,N) as date1  FROM tally
	WHERE N <= day(EOMONTH(datefromparts(@pYearsW,@pMonthW,1))) and (DATEPART(week, datefromparts(@pYearsW,@pMonthW,N)) - DATEPART(week, DATEADD(day, 1, EOMONTH(datefromparts(@pYearsW,@pMonthW,N), -1)))) + 1 = @pWeek
	
) abc group by date1
			) x
	  PIVOT (max(statusopen) FOR  DayinWeek  IN([Sunday],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday])
	) pvt) a,

		(select pvt1.* from( select
			
        -- ,Month(Date_Meeting) AS MonthM
        --,Day(Date_Meeting) AS DayM
		--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
		 N'Day' AS status
		, concat('','') as  'SUMM'
		, sum(case when status='CLOSE' then 1 else 0 end) statusclose
		,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
			    group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Month] = pvt2.status 			
    

UNION
select [Month],case when [Sunday] is null then '' else concat([Sunday],'') end [Sunday],
case when [Monday] is null then '' else concat([Monday],'') end [Monday],
case when [Tuesday] is null then '' else concat([Tuesday],'') end [Tuesday],
case when [Wednessday] is null then '' else concat([Wednessday],'') end [Wednessday],
case when [Thusday] is null then '' else concat([Thusday],'') end [Thusday],
case when [Friday] is null then '' else concat([Friday],'') end [Friday],
case when [Saturday] is null then '' else concat([Saturday],'') end [Saturday]
 ,SUMM from 
	(select [Month],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday],[Sunday]
	FROM (
	  SELECT N'Sum Metting Open' AS  [Month], 
		case when DATENAME(dw,Date_Meeting)='일요일' then 'Sunday' 
		 when DATENAME(dw,Date_Meeting)='월요일' then 'Monday'
		 when DATENAME(dw,Date_Meeting)='화요일' then 'Tuesday' 
		 when DATENAME(dw,Date_Meeting)='수요일' then 'Wednessday' 
		 when DATENAME(dw,Date_Meeting)='목요일' then 'Thusday' 
		 when DATENAME(dw,Date_Meeting)='금요일' then 'Friday' 
		else 'Saturday' end
		as DayinWeek ,
	--  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  sum(case when status='OPEN' then 1 else 0 end) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
				group by Date_Meeting
			) x
	  PIVOT (sum(statusopen) FOR  DayinWeek  IN([Sunday],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday])
	) pvt) a,

		(select pvt1.* from( select
			
        -- ,Month(Date_Meeting) AS MonthM
        --,Day(Date_Meeting) AS DayM
		--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
		 N'Sum Metting Open' AS status
		, concat(CAST (sum(case when status='OPEN' then 1 else 0 end) as nvarchar(20)),'') as  'SUMM'
		, sum(case when status='CLOSE' then 1 else 0 end) statusclose
		,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
			    group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Month] = pvt2.status 
UNION

select [Month],case when [Sunday] is null then '' else concat([Sunday],'') end [Sunday],
case when [Monday] is null then '' else concat([Monday],'') end [Monday],
case when [Tuesday] is null then '' else concat([Tuesday],'') end [Tuesday],
case when [Wednessday] is null then '' else concat([Wednessday],'') end [Wednessday],
case when [Thusday] is null then '' else concat([Thusday],'') end [Thusday],
case when [Friday] is null then '' else concat([Friday],'') end [Friday],
case when [Saturday] is null then '' else concat([Saturday],'') end [Saturday]
 ,SUMM from 
	(select [Month],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday],[Sunday]
	FROM (
	  SELECT N'Sum Metting Close' AS  [Month], 
		case when DATENAME(dw,Date_Meeting)='일요일' then 'Sunday' 
		 when DATENAME(dw,Date_Meeting)='월요일' then 'Monday'
		 when DATENAME(dw,Date_Meeting)='화요일' then 'Tuesday' 
		 when DATENAME(dw,Date_Meeting)='수요일' then 'Wednessday' 
		 when DATENAME(dw,Date_Meeting)='목요일' then 'Thusday' 
		 when DATENAME(dw,Date_Meeting)='금요일' then 'Friday' 
		else 'Saturday' end
		as DayinWeek ,
	--  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  sum(case when status='Close' then 1 else 0 end) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
				group by Date_Meeting
			) x
	  PIVOT (sum(statusopen) FOR  DayinWeek  IN([Sunday],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday])
	) pvt) a,

		(select pvt1.* from( select
			
        -- ,Month(Date_Meeting) AS MonthM
        --,Day(Date_Meeting) AS DayM
		--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
		 N'Sum Metting Close' AS status
		, concat(CAST (sum(case when status='CLOSE' then 1 else 0 end) as nvarchar(20)),'') as  'SUMM'
		, sum(case when status='CLOSE' then 1 else 0 end) statusclose
		,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
			    group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Month] = pvt2.status 
UNION



select [Month],case when [Sunday] is null then '' else concat([Sunday],'') end [Sunday],
case when [Monday] is null then '' else concat([Monday],'') end [Monday],
case when [Tuesday] is null then '' else concat([Tuesday],'') end [Tuesday],
case when [Wednessday] is null then '' else concat([Wednessday],'') end [Wednessday],
case when [Thusday] is null then '' else concat([Thusday],'') end [Thusday],
case when [Friday] is null then '' else concat([Friday],'') end [Friday],
case when [Saturday] is null then '' else concat([Saturday],'') end [Saturday]
 ,SUMM from 
	(select [Month],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday],[Sunday]
	FROM (
	  SELECT N'Sum Metting' AS  [Month], 
		case when DATENAME(dw,Date_Meeting)='일요일' then 'Sunday' 
		 when DATENAME(dw,Date_Meeting)='월요일' then 'Monday'
		 when DATENAME(dw,Date_Meeting)='화요일' then 'Tuesday' 
		 when DATENAME(dw,Date_Meeting)='수요일' then 'Wednessday' 
		 when DATENAME(dw,Date_Meeting)='목요일' then 'Thusday' 
		 when DATENAME(dw,Date_Meeting)='금요일' then 'Friday' 
		else 'Saturday' end
		as DayinWeek ,
	--  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) statusopen
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
				group by Date_Meeting
			) x
	  PIVOT (sum(statusopen) FOR  DayinWeek  IN([Sunday],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday])
	) pvt) a,

		(select pvt1.* from( select
			
        -- ,Month(Date_Meeting) AS MonthM
        --,Day(Date_Meeting) AS DayM
		--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
		 N'Sum Metting' AS status
		, concat(CAST (sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as nvarchar(20)),'') as  'SUMM'
		, sum(case when status='CLOSE' then 1 else 0 end) statusclose
		,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		, ROUND(((CAST(sum(case when status='OPEN' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2)  as Ratio

		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
			    group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Month] = pvt2.status 

UNION
select [Month],case when [Sunday] is null then '' else concat([Sunday],'') end [Sunday],
case when [Monday] is null then '' else concat([Monday],'') end [Monday],
case when [Tuesday] is null then '' else concat([Tuesday],'') end [Tuesday],
case when [Wednessday] is null then '' else concat([Wednessday],'') end [Wednessday],
case when [Thusday] is null then '' else concat([Thusday],'') end [Thusday],
case when [Friday] is null then '' else concat([Friday],'') end [Friday],
case when [Saturday] is null then '' else concat([Saturday],'') end [Saturday]
 ,SUMM from 
	(select [Month],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday],[Sunday]
	FROM (
	  SELECT N'Ratio' AS  [Month], 
		case when DATENAME(dw,Date_Meeting)='일요일' then 'Sunday' 
		 when DATENAME(dw,Date_Meeting)='월요일' then 'Monday'
		 when DATENAME(dw,Date_Meeting)='화요일' then 'Tuesday' 
		 when DATENAME(dw,Date_Meeting)='수요일' then 'Wednessday' 
		 when DATENAME(dw,Date_Meeting)='목요일' then 'Thusday' 
		 when DATENAME(dw,Date_Meeting)='금요일' then 'Friday' 
		else 'Saturday' end
		as DayinWeek ,
	--  (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as WeekM,
	  concat(ROUND(((CAST(sum(case when status='CLOSE' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2),'%')  as Ratio
		--	, sum(case when status='CLOSE' then 1 else 0 end) statusclose 
		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
				group by Date_Meeting
			) x
	  PIVOT (max(Ratio) FOR  DayinWeek  IN([Sunday],[Monday],[Tuesday],[Wednessday],[Thusday],[Friday],[Saturday])
	) pvt) a,

		(select pvt1.* from( select
			
        -- ,Month(Date_Meeting) AS MonthM
        --,Day(Date_Meeting) AS DayM
		--,(DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 as Week,
		 N'Ratio' AS status
		--, concat(CAST (sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as nvarchar(20)),'') as  'SUMM'
		--, sum(case when status='CLOSE' then 1 else 0 end) statusclose
		--,sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as Total
		, concat(ROUND(((CAST(sum(case when status='CLOSE' then 1 else 0 end) as float)/ cast(sum(case when status in ('CLOSE','OPEN') then 1 else 0 end) as float)))*100,2),'%')  as SUMM

		FROM Stb_MeetingAgenda
				where Year(Date_Meeting) = @pYearsW and Month(Date_Meeting) =@pMonthW and (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1  =@pWeek
			    group by (DATEPART(week, Date_Meeting) - DATEPART(week, DATEADD(day, 1, EOMONTH(Date_Meeting, -1)))) + 1 
		) pvt1)pvt2
		where  a.[Month] = pvt2.status 
END
ELSE
	SELECT '' Month,
	'' AS 'Sunday',
	'' AS 'Monday',
	'' AS 'Tuesday',
	'' AS 'Wednessday',
	'' AS 'Thusday',
	'' AS 'Friday',
	'' AS 'Saturday',
	'' SUMM FROM Stb_MeetingAgenda WHERE 1=2


--exec sp_executesql @pYears
	
END

--exec usp_MeetingReportWeek1_get 'ngoloan','vi',2021,04,01

--exec  usp_MeetingReportWeek1_get 'ngoloan','vi',2021,04,01