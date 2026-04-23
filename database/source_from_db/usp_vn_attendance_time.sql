CREATE PROC [dbo].[usp_vn_attendance_time] -- EXEC usp_vn_attendance_time '','','VVT_F2'
@pLine NVARCHAR(50) = NULL,
@pUtcOffset INT = NULL,
@pWorkCenterCode NVARCHAR(50) = NULL
AS
BEGIN

--exec usp_transfer_TimeSupport

--CREATE TABLE #Tbl
--(
--				EMPLOYEES_ID NVARCHAR(50),
--				EMPLOYEES_NAME NVARCHAR(50),
--				CODE_LINE NVARCHAR(50),
--				NAME_LINE NVARCHAR(50),
--				WORK_DATE NVARCHAR(50),
--				START_TIMES NVARCHAR(50),
--				END_TIMES NVARCHAR(50),
--				TOTALHOURS NVARCHAR(50),
--				CODELINETRANSFER NVARCHAR(50),
--				LINETRANSFER NVARCHAR(50),
--				START_TIME NVARCHAR(50),
--				END_TIME NVARCHAR(50),
--				TOTALMINUTE FLOAT,
--				TOTALHOUR FLOAT,
--				Shifts NVARCHAR(50),
--				TOTALTIMESUPPORT FLOAT
--)
				
		DECLARE @LINE NVARCHAR(50) = @pLine
		DECLARE @WorkCenterCode NVARCHAR(50) = @pWorkCenterCode


IF @WorkCenterCode = 'VVT_F1'
BEGIN
	;with a1 as(
	SELECT 
				EMPLOYEES_ID,
				EMPLOYEES_NAME,
				CODE_LINE,
				line.linename as NAME_LINE,
				dbo.fnGetLocalTime(WORK_DATE, @pUtcOffset) AS  WORK_DATE,
				att.START_TIME,
				att.END_TIME,

				--case when  (att.start_time is  null or att.end_time is  null) then 0
				--     when att.start_time='00:00' and att.end_time='00:00' then 0
				--else
				--	case when datepart(hh,min(att.start_time)) >=18 and datepart(hh,min(att.end_time)) <=10  then
				--		case when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				--		then cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
				--			case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) ,'mm') as int) >=30 
				--			then 0.5 else 0 end
				--		else
				--			 case when format(CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'mm')  <= 30 
				--			 then cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime), 'HH') as int) + 
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 else   
				--				case when CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) ='24:00'
				--				 then
				--					 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST('00:00' as datetime), 'HH') as int)+
				--					 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST('00:00' as datetime) ,'mm') as int) >=30 
				--					 then 0.5 else 0 end
									 
				--				 else
				--					 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
				--					 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
				--					 then 0.5 else 0 end
				--				 end
							 
				--			 end
				--		end
				--	else
				--	case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				--	then 
				--		case when  CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime)  = CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) then 0
				--		when att.start_time is null or att.end_time is null then 0
				--		when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and 
				--		CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
				--		then 0
				--		when CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime)  - CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) < 0 then 0
				--	    when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'HH') as int)+
				--		case when	 cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) ,'mm') as int) >=30 then 0.5 else 0 end =0 then 0
						
				--		when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				--		then (cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
				--			case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) ,'mm') as int) >=30 
				--			then 0.5 else 0 end)
				--		else
				--			 case when format(CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'mm')  <= 30 
				--			 then cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime), 'HH') as int) + 
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 else   
				--			 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 end
							
				--		end
				--		end
				--	end
				--end
				--as loantest,
				case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime)
				and CAST(CONVERT(VARCHAR(5),att.END_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'10:00', 108) AS datetime)
				
				then 
					abs(DATEDIFF(minute, att.start_time,DATEADD(DAY,1,DATEADD(minute,0, att.END_TIME))))
					
				else abs( DATEDIFF(minute, att.start_time,att.END_TIME))
					 end loantest,
				--	 case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--and CAST(CONVERT(VARCHAR(5),att.END_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'10:00', 108) AS datetime)
				
				--then 
				--	abs(DATEDIFF(minute, att.start_time,DATEADD(DAY,1,DATEADD(minute,0, att.END_TIME))))/60
					
				--else abs( DATEDIFF(minute, att.start_time,att.END_TIME))/60
				--	 end loantest1,


				case when TOTAL_TIME = 660 then 610
					 when TOTAL_TIME = 720 then 610
					 when total_time= 420 then 400
				    else total_time end as TOTAL_TIME,
				--TOTAL_TIME,
				case when TOTAL_TIME = 660 then   cast(610 as decimal(6,2))/ cast(60 as decimal(6,2) )
					 when total_time =720 then    cast(610 as decimal(6,2))/ cast(60 as decimal(6,2) )
					 
				    else TOTAL_TIME/60 end as   TOTALHOURS,
				--TOTAL_TIME / 60 AS TOTALHOURS,
				ETS.CODELINETRANSFER,
				ETS.LINETRANSFER,
				RIGHT(ETS.START_TIME,8)AS START_TIME1,
				RIGHT(ETS.END_TIME,8)AS END_TIME1,
				'' + replace(ETS.TOTALMINUTES, '0', '') AS TOTALMINUTE,
				ETS.TOTALHOUR,
				ETS.Shifts,
					CASE
					WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
					WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
				ELSE ''
				END AS 'TOTALTIMESUPPORT'
				
				

				
				--CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) AS TOTALTIMESUPPORT
		FROM 
			    STB_VN_ATTENDANCE_TIME att WITH(NOLOCK) 
				left join STB_LineInfo line ON att.CODE_LINE = line.linecode
				LEFT JOIN STB_VN_EMPLOYEESTRANSFER ETS ON att.EMPLOYEES_ID = ETS.EMPLOYEESID  AND LEFT(att.WORK_DATE,12) = LEFT(ETS.START_DATES,12)
		WHERE  (att.start_time is not null or att.end_time is not null)
		  and (CODE_LINE = @pLine or @pLine is null or  @pLine ='')
		group by EMPLOYEES_ID,EMPLOYEES_NAME,CODE_LINE,linename,WORK_DATE,att.START_TIME,att.END_TIME,att.TOTAL_TIME,ETS.CODELINETRANSFER,ets.LINETRANSFER,ets.START_TIME,ets.END_TIME,ets.TOTALMINUTES,ets.TOTALHOUR,ets.Shifts
		)

	--	select *  from a1
		select EMPLOYEES_ID,
				EMPLOYEES_NAME,
				CODE_LINE,NAME_LINE,
				WORK_DATE,
				START_TIME,
				END_TIME,

				case when loantest/60 >=11 then loantest -110
				    when loantest/60 >=9 then loantest -80
					when loantest/60 < 9 and loantest/60 >= 6 then loantest - 70
					else loantest
				end as TOTAL_TIME,
				case when loantest/60 >=11 then (loantest -110)/cast(60 as decimal(6,2))
				     when loantest/60 >=9 then (loantest -80)/cast(60 as decimal(6,2))
					 when loantest/60 < 9 and loantest/60 >= 6 then (loantest -70)/cast(60 as decimal(6,2))
					 else loantest/cast(60 as decimal(6,2))
				end as TOTALHOURS,

				--case when loantest=12 then 12*60-110		
				--	 when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 320
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then 7*60-50
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 7*60-80
				--	 when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then 7*60-80
				--	  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then 7*60-70
				--	 when loantest=5.5 then 5*60+30-70
				--	 when loantest =11.5 then 11*60+30-110
				--	 when loantest =11.0 then 11*60-110
				--	 when loantest =12.5 then 12*60+30-110
				--	 when loantest =13.5 then 13*60+30-110
				--	 when loantest =13.0 then 13*60-110
				--	 when loantest =14.5 then 14*60+30-110
				--	  when loantest =15 then 15*60-110
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 10*60-80
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'06:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'06:30', 108) AS datetime) then 10*60-80
				--	when loantest=10.5 then 10*60+30-110
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then 5*60-70
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
				--	 then 5*60-10
				--	 when loantest=9.5 then 9*60+30-80
				--	 when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then 6*60-70
				--	 when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--		and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then 6*60-40
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then 8*60-80
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then 8*60-100
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 8*60-80
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then 7*60+30-40
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 7*60+30-100
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then 7*60+30-80
				--	when loantest =9.0 then 9*60-80
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 6*60+30-40
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then 6*60+30-70
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 8*60+30-100
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then 8*60+30-80
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then 8*60+30-80
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then 8*60+30-100
				--	end as TOTAL_TIME,

				--case when loantest=12 then cast(12*60-110 as  decimal(6,2))/ cast(60 as  decimal(6,2))		
				--	 when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast (320 as  decimal(6,2)) / cast(60 as  decimal(6,2))	
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then cast(7*60-50 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(7*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60-80 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then cast(7*60-70 as decimal(6,2)) / cast (60 as decimal(6,2))
				--	 when loantest=5.5 then cast(5*60+30-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest =11 then cast(11*60+30-110 as  decimal(6,2))/cast(60 as decimal(6,2))
				--	 when loantest =11.5 then cast(11*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =12.5 then cast(12*60+30-110 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =13.5 then cast(13*60+30-110 as  decimal(6,2)) / cast(60 as  decimal(6,2))
				--	 when loantest =13.0 then cast (13*60-110 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =14.5 then cast(14*60+30-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest =15 then cast (15*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then  cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'06:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'06:30', 108) AS datetime) then cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=10.5 then cast(10*60+30-110 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then cast (5*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
				--	 then cast (5*60-10 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=9.5 then cast(9*60+30-80 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then cast(6*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--		and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then cast(6*60-40 as decimal(6,2)) / cast (60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then cast(8*60-80 as  decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then  cast(8*60-100 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(8*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60+30-40 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(7*60+30-100 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then cast(7*60+30-80 as  decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =9.0 then cast(9*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(6*60+30-40 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then cast(6*60+30-70 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/cast(60 as decimal(6,2))
				--	end as TOTALHOURS,
					CODELINETRANSFER,
					LINETRANSFER,
					START_TIME1 as START_TIME,
				    END_TIME1 as END_TIME,
					TOTALMINUTE,
				    TOTALHOUR,
				    Shifts,

					--case when loantest=12 then cast(12*60-110 as  decimal(6,2))/ cast(60 as  decimal(6,2))	- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast (320 as  decimal(6,2)) / cast(60 as  decimal(6,2))	- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
					-- and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then cast(7*60-50 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(7*60-80 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60-80 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then cast(7*60-70 as decimal(6,2)) / cast (60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.5 then cast(5*60+30-70 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =11.5 then cast(11*60+30-110 as  decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =11.5 then cast(11*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =12.5 then cast(12*60+30-110 as  decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =13.5 then cast(13*60+30-110 as  decimal(6,2)) / cast(60 as  decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =13.0 then cast (13*60-110 as  decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =14.5 then cast(14*60+30-110 as decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					--  when loantest =15 then cast (15*60-110 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then  cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=10.5 then cast(10*60+30-110 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then cast (5*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
					-- then cast (5*60-10 as decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=9.5 then cast(9*60+30-80 as decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then cast(6*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
					--	and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then cast(6*60-40 as decimal(6,2)) / cast (60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then cast(8*60-80 as  decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then  cast(8*60-100 as decimal(6,2))/cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(8*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60+30-40 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(7*60+30-100 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then cast(7*60+30-80 as  decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =9.0 then cast(9*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(6*60+30-40 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then cast(6*60+30-70 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--end as TOTALTIMESUPPORT

				case when loantest/60 >=11 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) - cast(110 as decimal(6,2)  ))/cast(60 as decimal(6,2))
				     when loantest/60 >=9 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) -  cast(80 as decimal(6,2) ))/cast(60 as decimal(6,2))
					 when loantest/60 < 9 and loantest/60 >= 6 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) - cast(70 as decimal(6,2) ) )/cast(60 as decimal(6,2))
					 else loantest -cast(TOTALHOUR  as decimal(6,2))
				end as TOTALTIMESUPPORT
					--CASE
					--WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
					--WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
					--ELSE ''
					--END AS 'TOTALTIMESUPPORT'
			from a1
			WHERE a1.CODE_LINE IN (
			'ACN',
'ACT',
'BCT',
'BG',
'BigSize',
'DR01',
'DR02',
'KTSP',
'KVHD',
'PACKING',
'QC',
'R-KR',
'SB202211300202',
'SB202211300247',
'SB202211300259',
'SB202211300314',
'SB202211300329',
'SB202211300348',
'SB202211300353',
'SB202211300439',
'SB202211300450',
'SB202211300551',
'SB202211300954',
'SB202211301112',
'SB202212011003',
'SB202212011050',
'SB202212050217',
'SB202212050244',
'SB202212050248',
'SB202212070223',
'SB202212070238',
'SB202212070247',
'SB202212140914',
'SB202212200502',
'SB202212200506',
'SB202212200510',
'SB202212200519',
'SB202212200520',
'SB202212200522',
'SB202212200523',
'SB202212200526',
'SB202212200530',
'SB202212200534',
'SB202212200537',
'SB202212200539',
'SB202212200540',
'SB202212200545',
'SB202212200553',
'SB202212200555',
'Tape1',
'Tape2',
'Tape3',
'TCX1',
'TCX2',
'TQC-VVT-LINE',
'TVNCC',
'VPC 1 THU CONG',
'VPC 2 THU CONG',
'VPC 3 THU CONG',
'VPCBending',
'VPCBending2',
'VPC-OQC',
'VVC-01',
'VVC-02',
'VVC-03',
'VVC-04',
'VVC-05',
'VVC-06',
'VVC-07',
'VVC-08',
'VVC-09',
'VVC-10',
'VVC-11',
'VVC-12',
'VVC-13',
'VVC-14',
'VVC-15',
'VVC-16',
'VVC-17',
'VVC-18',
'VVC-19',
'VVC-20',
'VVC-21',
'VVC-22',
'VVC-23',
'VVC-26(35 size auto)',
'VVC-ELECTRODE-LINE',
'VVMB-01',
'VVMB-02',
'VVMB-03',
'VVMB-04',
'VVMB-05',
'VVMB-06',
'VVMD',
'VVMM-01',
'VVMM-02',
'VVMM-03',
'VVMM-04',
'VVMM-05',
'VVMM-06',
'VVMM-07',
'VVMM-08',
'VVMM-09',
'VVMM-10',
'VVMM-12',
'VVMM-13',
'VVMM-14',
'VVVPC-01(#8)',
'VVVPC-02(#6)',
'VVVPC-03(#11)',
'XCDMDSD',
'XK',
'XTH'
)
			order by WORK_DATE desc


END

IF @WorkCenterCode = 'VVT_F2'
BEGIN


			;with a1 as(
	SELECT 
				EMPLOYEES_ID,
				EMPLOYEES_NAME,
				CODE_LINE,
				line.linename as NAME_LINE,
				dbo.fnGetLocalTime(WORK_DATE, @pUtcOffset) AS  WORK_DATE,
				att.START_TIME,
				att.END_TIME,

				--case when  (att.start_time is  null or att.end_time is  null) then 0
				--     when att.start_time='00:00' and att.end_time='00:00' then 0
				--else
				--	case when datepart(hh,min(att.start_time)) >=18 and datepart(hh,min(att.end_time)) <=10  then
				--		case when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				--		then cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
				--			case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) ,'mm') as int) >=30 
				--			then 0.5 else 0 end
				--		else
				--			 case when format(CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'mm')  <= 30 
				--			 then cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime), 'HH') as int) + 
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 else   
				--				case when CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) ='24:00'
				--				 then
				--					 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST('00:00' as datetime), 'HH') as int)+
				--					 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST('00:00' as datetime) ,'mm') as int) >=30 
				--					 then 0.5 else 0 end
									 
				--				 else
				--					 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
				--					 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
				--					 then 0.5 else 0 end
				--				 end
							 
				--			 end
				--		end
				--	else
				--	case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				--	then 
				--		case when  CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime)  = CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) then 0
				--		when att.start_time is null or att.end_time is null then 0
				--		when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and 
				--		CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
				--		then 0
				--		when CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime)  - CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) < 0 then 0
				--	    when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'HH') as int)+
				--		case when	 cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) ,'mm') as int) >=30 then 0.5 else 0 end =0 then 0
						
				--		when CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				--		then (cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
				--			case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) ,'mm') as int) >=30 
				--			then 0.5 else 0 end)
				--		else
				--			 case when format(CAST(CONVERT(VARCHAR(5), att.start_time, 108) AS datetime),'mm')  <= 30 
				--			 then cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime), 'HH') as int) + 
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(att.start_time,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 else   
				--			 cast(format(CAST(CONVERT(VARCHAR(5),att.end_time, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
				--			 case when  cast(format(CAST(CONVERT(VARCHAR(5), att.end_time, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(att.start_time,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
				--			 then 0.5 else 0 end
				--			 end
							
				--		end
				--		end
				--	end
				--end
				--as loantest,
				case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime)
				and CAST(CONVERT(VARCHAR(5),att.END_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'10:00', 108) AS datetime)
				
				then 
					abs(DATEDIFF(minute, att.start_time,DATEADD(DAY,1,DATEADD(minute,0, att.END_TIME))))
					
				else abs( DATEDIFF(minute, att.start_time,att.END_TIME))
					 end loantest,
				--	 case when CAST(CONVERT(VARCHAR(5),att.start_time, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--and CAST(CONVERT(VARCHAR(5),att.END_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'10:00', 108) AS datetime)
				
				--then 
				--	abs(DATEDIFF(minute, att.start_time,DATEADD(DAY,1,DATEADD(minute,0, att.END_TIME))))/60
					
				--else abs( DATEDIFF(minute, att.start_time,att.END_TIME))/60
				--	 end loantest1,


				case when TOTAL_TIME = 660 then 610
					 when TOTAL_TIME = 720 then 610
					 when total_time= 420 then 400
				    else total_time end as TOTAL_TIME,
				--TOTAL_TIME,
				case when TOTAL_TIME = 660 then   cast(610 as decimal(6,2))/ cast(60 as decimal(6,2) )
					 when total_time =720 then    cast(610 as decimal(6,2))/ cast(60 as decimal(6,2) )
					 
				    else TOTAL_TIME/60 end as   TOTALHOURS,
				--TOTAL_TIME / 60 AS TOTALHOURS,
				ETS.CODELINETRANSFER,
				ETS.LINETRANSFER,
				RIGHT(ETS.START_TIME,8)AS START_TIME1,
				RIGHT(ETS.END_TIME,8)AS END_TIME1,
				'' + replace(ETS.TOTALMINUTES, '0', '') AS TOTALMINUTE,
				ETS.TOTALHOUR,
				ETS.Shifts,
					CASE
					WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
					WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
				ELSE ''
				END AS 'TOTALTIMESUPPORT'
				
				

				
				--CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) AS TOTALTIMESUPPORT
		FROM 
			    STB_VN_ATTENDANCE_TIME att WITH(NOLOCK) 
				left join STB_LineInfo line ON att.CODE_LINE = line.linecode
				LEFT JOIN STB_VN_EMPLOYEESTRANSFER ETS ON att.EMPLOYEES_ID = ETS.EMPLOYEESID  AND LEFT(att.WORK_DATE,12) = LEFT(ETS.START_DATES,12)
		WHERE  (att.start_time is not null or att.end_time is not null)
		  and (CODE_LINE = @pLine or @pLine is null or  @pLine ='')
		group by EMPLOYEES_ID,EMPLOYEES_NAME,CODE_LINE,linename,WORK_DATE,att.START_TIME,att.END_TIME,att.TOTAL_TIME,ETS.CODELINETRANSFER,ets.LINETRANSFER,ets.START_TIME,ets.END_TIME,ets.TOTALMINUTES,ets.TOTALHOUR,ets.Shifts
		)

	--	select *  from a1
		select EMPLOYEES_ID,
				EMPLOYEES_NAME,
				CODE_LINE,NAME_LINE,
				WORK_DATE,
				START_TIME,
				END_TIME,

				case when loantest/60 >=11 then loantest -110
				    when loantest/60 >=9 then loantest -80
					when loantest/60 < 9 and loantest/60 >= 6 then loantest - 70
					else loantest
				end as TOTAL_TIME,
				case when loantest/60 >=11 then (loantest -110)/cast(60 as decimal(6,2))
				     when loantest/60 >=9 then (loantest -80)/cast(60 as decimal(6,2))
					 when loantest/60 < 9 and loantest/60 >= 6 then (loantest -70)/cast(60 as decimal(6,2))
					 else loantest/cast(60 as decimal(6,2))
				end as TOTALHOURS,

				--case when loantest=12 then 12*60-110		
				--	 when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 320
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then 7*60-50
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 7*60-80
				--	 when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then 7*60-80
				--	  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then 7*60-70
				--	 when loantest=5.5 then 5*60+30-70
				--	 when loantest =11.5 then 11*60+30-110
				--	 when loantest =11.0 then 11*60-110
				--	 when loantest =12.5 then 12*60+30-110
				--	 when loantest =13.5 then 13*60+30-110
				--	 when loantest =13.0 then 13*60-110
				--	 when loantest =14.5 then 14*60+30-110
				--	  when loantest =15 then 15*60-110
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 10*60-80
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'06:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'06:30', 108) AS datetime) then 10*60-80
				--	when loantest=10.5 then 10*60+30-110
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then 5*60-70
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
				--	 then 5*60-10
				--	 when loantest=9.5 then 9*60+30-80
				--	 when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then 6*60-70
				--	 when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--		and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then 6*60-40
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then 8*60-80
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then 8*60-100
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then 8*60-80
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then 7*60+30-40
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 7*60+30-100
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then 7*60+30-80
				--	when loantest =9.0 then 9*60-80
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 6*60+30-40
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then 6*60+30-70
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then 8*60+30-100
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then 8*60+30-80
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then 8*60+30-80
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then 8*60+30-100
				--	end as TOTAL_TIME,

				--case when loantest=12 then cast(12*60-110 as  decimal(6,2))/ cast(60 as  decimal(6,2))		
				--	 when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast (320 as  decimal(6,2)) / cast(60 as  decimal(6,2))	
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then cast(7*60-50 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(7*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60-80 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then cast(7*60-70 as decimal(6,2)) / cast (60 as decimal(6,2))
				--	 when loantest=5.5 then cast(5*60+30-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest =11 then cast(11*60+30-110 as  decimal(6,2))/cast(60 as decimal(6,2))
				--	 when loantest =11.5 then cast(11*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =12.5 then cast(12*60+30-110 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =13.5 then cast(13*60+30-110 as  decimal(6,2)) / cast(60 as  decimal(6,2))
				--	 when loantest =13.0 then cast (13*60-110 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest =14.5 then cast(14*60+30-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest =15 then cast (15*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then  cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	  when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'06:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'06:30', 108) AS datetime) then cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=10.5 then cast(10*60+30-110 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then cast (5*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
				--	 and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
				--	 then cast (5*60-10 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=9.5 then cast(9*60+30-80 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	 when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then cast(6*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	 when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
				--		and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then cast(6*60-40 as decimal(6,2)) / cast (60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then cast(8*60-80 as  decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then  cast(8*60-100 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(8*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60+30-40 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(7*60+30-100 as decimal(6,2)) / cast(60 as decimal(6,2))
				--	when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then cast(7*60+30-80 as  decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =9.0 then cast(9*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(6*60+30-40 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then cast(6*60+30-70 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/ cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2))
				--	when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/cast(60 as decimal(6,2))
				--	end as TOTALHOURS,
					CODELINETRANSFER,
					LINETRANSFER,
					START_TIME1 as START_TIME,
				    END_TIME1 as END_TIME,
					TOTALMINUTE,
				    TOTALHOUR,
				    Shifts,

					--case when loantest=12 then cast(12*60-110 as  decimal(6,2))/ cast(60 as  decimal(6,2))	- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and START_TIME='12:00' and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast (320 as  decimal(6,2)) / cast(60 as  decimal(6,2))	- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
					-- and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) then cast(7*60-50 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(7*60-80 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime)
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60-80 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--  when loantest = 7 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'15:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'15:30', 108) AS datetime) then cast(7*60-70 as decimal(6,2)) / cast (60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.5 then cast(5*60+30-70 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =11.5 then cast(11*60+30-110 as  decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =11.5 then cast(11*60-110 as decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =12.5 then cast(12*60+30-110 as  decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =13.5 then cast(13*60+30-110 as  decimal(6,2)) / cast(60 as  decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =13.0 then cast (13*60-110 as  decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =14.5 then cast(14*60+30-110 as decimal(6,2)) / cast(60 as decimal(6,2))- (coalesce(TOTALHOUR, null,0)) 	
					--  when loantest =15 then cast (15*60-110 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=10.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then  cast(10*60-80 as  decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=10.5 then cast(10*60+30-110 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:30', 108) AS datetime) then cast (5*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=5.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) 
					-- and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  > CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),start_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime) 
					-- then cast (5*60-10 as decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=9.5 then cast(9*60+30-80 as decimal(6,2)) / cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest=6.0 and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'14:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'14:30', 108) AS datetime) then cast(6*60-70 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					-- when loantest =6.0 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'12:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'13:00', 108) AS datetime)
					--	and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'19:30', 108) AS datetime) then cast(6*60-40 as decimal(6,2)) / cast (60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'16:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'16:30', 108) AS datetime) then cast(8*60-80 as  decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  < CAST(CONVERT(VARCHAR(5),'20:30', 108) AS datetime) then  cast(8*60-100 as decimal(6,2))/cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=8.0 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'18:30', 108) AS datetime) then cast(8*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) then cast(7*60+30-40 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'19:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(7*60+30-100 as decimal(6,2)) / cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest=7.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime)  then cast(7*60+30-80 as  decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =9.0 then cast(9*60-80 as decimal(6,2))/ cast(60 as decimal(6,2))  - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(6*60+30-40 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =6.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) then cast(6*60+30-70 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),end_time, 108) AS datetime)  >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/ cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'08:30', 108) AS datetime) then cast(8*60+30-80 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--when loantest =8.5 and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'10:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),START_TIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5),'11:00', 108) AS datetime) then cast(8*60+30-100 as decimal(6,2))/cast(60 as decimal(6,2)) - (coalesce(TOTALHOUR, null,0)) 	
					--end as TOTALTIMESUPPORT

				case when loantest/60 >=11 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) - cast(110 as decimal(6,2)  ))/cast(60 as decimal(6,2))
				     when loantest/60 >=9 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) -  cast(80 as decimal(6,2) ))/cast(60 as decimal(6,2))
					 when loantest/60 < 9 and loantest/60 >= 6 then (cast(loantest as decimal(6,2)) - COALESCE( cast(TOTALHOUR  as decimal(6,2)),0) - cast(70 as decimal(6,2) ) )/cast(60 as decimal(6,2))
					 else loantest -cast(TOTALHOUR  as decimal(6,2))
				end as TOTALTIMESUPPORT
					--CASE
					--WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
					--WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
					--ELSE ''
					--END AS 'TOTALTIMESUPPORT'
			from a1
			WHERE a1.CODE_LINE IN ('VVBGC-01','VVBGC-02','VVBGC-03','VVBGC-04','VVBGC-05','VVBGC-06','VVBGC-07','VVBGC-08','VVBGC-09'
			,'VVBGC-10','VVBGC-11','VVBGC-12','VVBGC-13','VVBGC-14','VVBGC-15','VVBGC-16','VVBGC-17','VVBGC-18','VVBGC-19','VVBGC-20','VVBGTC-01','VVBGTC-02')
			order by WORK_DATE desc



				
END

		--IF @LINE IS NOT NULL

		--BEGIN
		

--INSERT INTO #Tbl

		--		SELECT

		--		EMPLOYEES_ID,
		--		EMPLOYEES_NAME,
		--		CODE_LINE,
		--		line.linename as NAME_LINE,
		--		dbo.fnGetLocalTime(WORK_DATE, @pUtcOffset) AS  WORK_DATE,
		--		att.START_TIME,
		--		att.END_TIME,
		--		TOTAL_TIME / 60 AS TOTALHOURS,
		--		ETS.CODELINETRANSFER,
		--		ETS.LINETRANSFER,
		--		RIGHT(ETS.START_TIME,8)AS START_TIME,
		--		RIGHT(ETS.END_TIME,8)AS END_TIME,
		--		'' + replace(ETS.TOTALMINUTES, '0', '') AS TOTALMINUTE,
		--		ETS.TOTALHOUR,
		--		ETS.Shifts,

		--		CASE
		--			WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
		--			WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
		--		ELSE ''
		--		END AS 'TOTALTIMESUPPORT'
				
		--FROM 
		--	    STB_VN_ATTENDANCE_TIME att 
		--		left join STB_LineInfo line ON att.CODE_LINE = line.linecode
		--		LEFT JOIN STB_VN_EMPLOYEESTRANSFER ETS ON att.EMPLOYEES_ID = ETS.EMPLOYEESID  AND LEFT(att.WORK_DATE,12) = LEFT(ETS.START_DATES,12)
		--WHERE   CODE_LINE = @LINE


		--END
		
		--ELSE
		
		--BEGIN

	
		--SELECT
		--		EMPLOYEES_ID,
		--		EMPLOYEES_NAME,
		--		CODE_LINE,
		--		line.linename as NAME_LINE,
		--		dbo.fnGetLocalTime(WORK_DATE, @pUtcOffset) AS  WORK_DATE,
		--		att.START_TIME,
		--		att.END_TIME,
		--		TOTAL_TIME,
		--		TOTAL_TIME / 60 AS TOTALHOURS,
		--		ETS.CODELINETRANSFER,
		--		ETS.LINETRANSFER,
		--		RIGHT(ETS.START_TIME,8)AS START_TIME,
		--		RIGHT(ETS.END_TIME,8)AS START_TIME,
		--		'' + replace(ETS.TOTALMINUTES, '0', '') AS TOTALMINUTE,
		--		ETS.TOTALHOUR,
		--		ETS.Shifts,
		--			CASE
		--			WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NULL THEN TOTAL_TIME / 60
		--			WHEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR))  IS NOT NULL THEN CONVERT(FLOAT,(TOTAL_TIME / 60) - (ETS.TOTALHOUR)) 
		--		ELSE ''
		--		END AS 'TOTALTIMESUPPORT'
				
				
		--FROM 
		--	    STB_VN_ATTENDANCE_TIME att WITH(NOLOCK) 
		--		left join STB_LineInfo line ON att.CODE_LINE = line.linecode
		--		LEFT JOIN STB_VN_EMPLOYEESTRANSFER ETS ON att.EMPLOYEES_ID = ETS.EMPLOYEESID  AND LEFT(att.WORK_DATE,12) = LEFT(ETS.START_DATES,12)
		--WHERE  (att.start_time is not null or att.end_time is not null)


	--END
END


