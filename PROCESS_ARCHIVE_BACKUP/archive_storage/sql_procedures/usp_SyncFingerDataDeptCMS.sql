-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_SyncFingerDataDeptCMS] -- exec usp_SyncFingerData '2022-05-01','2022-05-13'
@pFromDate date,
@pToDate date

AS
BEGIN
	SET NOCOUNT ON;
     
	 DECLARE @Userfullcode nvarchar(20)
	 DECLARE @UserEnrollNumber nvarchar(20)
	 DECLARE @UserFullName nvarchar(50)
	 DECLARE @dept nvarchar(50)
	 DECLARE @Positiontb nvarchar(50)
	 DECLARE @timedate date
	 DECLARE @timein nvarchar(20)
	 DECLARE @timeout nvarchar(20)
	 DECLARE @shift nvarchar(20)
	 DECLARE @sumtime int
	 DECLARE @TimeOT nvarchar(10)
	 DECLARE @cnt int

	 DECLARE @minute int
	 --insert no




				--DECLARE c Cursor FOR 
				--select Userfullcode,UserEnrollNumber,UserFullName,dept,Positiontb,timedate,timein,timeout ,Shift,
				--case when shift='NGAY' then case when  ABS(DATEDIFF(HH, timeout,  timein)) -1 >0 then cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				--				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1 else NULL end
				--else 
				--		case when  ABS(DATEDIFF(HH, timeout,  timein)) -1 >0 then cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				--				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1 else NULL end
				--end
				--as sumtime,
				----ABS(DATEDIFF(HH,timeout, timein)) -1  as sumtime,
				----case when ABS(DATEDIFF(HH,timeout, timein)) -1 > 8 then (ABS(DATEDIFF(HH,timeout, timein)) -1) - 8 else NULL end TimeOT
				--case when Shift='NGAY' 
				----then case when ABS(DATEDIFF(HH, timeout,  timein)) -1 > 8 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				----				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1) - 8 else NULL end 
				----else
				----case when ABS(DATEDIFF(HH, timeout,  timein)) -1 > 8 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) end,'HH') as int) +
				----				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1) - 8 else NULL end
				
				----	then	case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '13:30',108) as datetime) then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) else NULL end,'HH') as int)+
				----	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else NULL 
				----	end 
			 ----   else
				----					case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:30',108) as datetime) then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) else NULL end,'HH') as int)+
				----cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else NULL end
				----end as sumOT
				--then case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '17:30',108) as datetime) then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) else NULL end,'HH') as int)+
				--cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime)  and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime)then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else NULL 
				--end
			 --   else
				--					case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:30',108) as datetime) then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:30', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:30',108) as datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) else NULL end,'HH') as int)+
				--cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:30', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:30',108) as datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else NULL end
				--end as TimeOT
				--from 
				--(select  abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.dept, abc.Positiontb,abc.timedate,FORMAT(min(abc.timein),'HH:mm')  as timein,FORMAT( max(abc1.timeout),'HH:mm')  as timeout,
				--case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift' from

				--(
				----chay tu day

    --          (select 		 Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift',timedate,
	   --        min(timein) as timein from
				--(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.machineno,
				--case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21) then  min(a.TimeStr) else null end as timein,
				--case when a.MachineNo in (2,4,6,8,10,12,14,16,18,20) then max(a.TimeStr)  else null end as timeout,TimeDate


				--from stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				--left join stb_FingerDept c on b.IDD = c.IDD
				--left join Stb_FingerPosition d on b.IDP = d.IDP
				--where 1=1
				--and b.IDZ not in (5,15)
			 --  	and (c.dept like '%VVC%' or c.dept like '%MANUALINE%' or c.dept like '%VVMD%' )
				----and a.Userfullcode='3181157'
				--and (a.TimeDate between @pFromDate and @pToDate)
			 --   group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.timedate, a.MachineNo) abc
				--group by  Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,timedate) abc
    --            FULL OUTER JOIN

    --           (select 		 Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10 then 'DEM' else 'NGAY' end as 'Shift',
	   --          case when datepart(hh,min(timein)) >=18 then max(timeout)-1 else max(timeout) end as  timeout,
				--  case when datepart(hh,min(timein)) >=18 or ( min(timein) IS NULL)then timedate-1 else TimeDate end as  timedate
				-- from
				--(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.machineno,
				--case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21) then  min(a.TimeStr) else null end as timein,
				--case when a.MachineNo in (2,4,6,8,10,12,14,16,18,20) then max(a.TimeStr)  else null end as timeout,TimeDate


				--from stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				--left join stb_FingerDept c on b.IDD = c.IDD
				--left join Stb_FingerPosition d on b.IDP = d.IDP
				--where 1=1
				--and b.IDZ not in (5,15)
				--and (c.dept like '%VVC%' or c.dept like '%MANUALINE%' )
				----and a.Userfullcode='3181157'
				--and (a.TimeDate between @pFromDate and @pToDate)
			 --   group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.timedate, a.MachineNo) abc
				--group by  Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,timedate) abc1
				
				--on abc.userfullcode = abc1.UserFullCode 
				--and abc.timedate = abc1.timedate
				--)
				
				--where abc.UserFullCode is not null
				--group by abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.dept, abc.Positiontb,abc.timedate) aaa

 
	
				DECLARE c Cursor FOR 
		

		 WITH cte AS
(
   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY EMPLOYEESID ORDER BY EFFECTIVEDATE DESC) AS rn
   FROM STB_VN_EMPLOYEESTRANSFERLINE
)
		

select Userfullcode,UserEnrollNumber,UserFullName,CODELINEMOVE,Positiontb,timedate,timein,timeout ,Shift,
				case when shift='NGAY' then
			
						case when  CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime)  = CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) then 0
						when timein is null or timeout is null then 0
						when CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime)  - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) < 0 then 0
					    when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'HH') as int)+
						case when	 cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) ,'mm') as int) >=30 then 0.5 else 0 end =0 then 0
						
						when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
						then (cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
						else
							 case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end
						end
				 
				else 
							case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
						then cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end
						else
							 case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
								case when CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) ='24:00'
								 then
									 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST('00:00' as datetime), 'HH') as int)+
									 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) -  CAST('00:00' as datetime) ,'mm') as int) >=30 
									 then 0.5 else 0 end
									 
								 else
									 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
									 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
									 then 0.5 else 0 end
								 end
							 
							 end
						end
				end 
				as sumtime,
				case when Shift='NGAY' 
				then case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
				and DATEPART(dw,timedate) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  
				else 
					(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  


				end
			    else
				case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,timedate) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else 

					(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )
					
				end
				end as TimeOT
				from 
				(select  abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.CODELINEMOVE, abc.Positiontb,abc.timedate,FORMAT(min(abc.timein),'HH:mm')  as timein,FORMAT( max(abc1.timeout),'HH:mm')  as timeout,
				case when datepart(hh,min(timein)) >=17 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift' from

				(
				--chay tu day

              (select 		 Userfullcode, UserEnrollNumber,UserFullName, CODELINEMOVE, Positiontb,case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift',timedate,
	           min(timein) as timein from
				(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.CODELINEMOVE, d.Positiontb,a.machineno,
				case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21,33) then  min(a.TimeStr) else null end as timein,
				case when a.MachineNo in (2,4,6,8,10,12,14,16,17,18,19,20,33) then max(a.TimeStr)  else null end as timeout,TimeDate


				from dbo.stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				left join cte  c on a.UserFullCode = c.EMPLOYEESID
				--left join stb_FingerDept c on b.IDD = c.IDD
				left join Stb_FingerPosition d on b.IDP = d.IDP
				where 1=1 and  rn = 1
				--and b.IDZ not in (5,15,17)
			   --	and c.dept ='VVC-18'
				--and (a.Userfullcode=@pEmpnoNo or @pEmpnoNo='')
				and  (c.CODELINEMOVE like '%VVC%' or c.CODELINEMOVE like '%MANUALINE%' or c.CODELINEMOVE like '%VVMD%'   or c.CODELINEMOVE like '%VVMM%')
				-- and c.Dept !='module'
				and (a.TimeDate  between @pFromDate and @pToDate)
			    group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.CODELINEMOVE, d.Positiontb,a.timedate, a.MachineNo) abc
				group by  Userfullcode, UserEnrollNumber,UserFullName, CODELINEMOVE, Positiontb,timedate) abc
                FULL OUTER JOIN

               (select 		 Userfullcode, UserEnrollNumber,UserFullName, CODELINEMOVE, Positiontb,case when datepart(hh,min(timein)) >=17 and datepart(hh,min(timeout)) <=10 then 'DEM' else 'NGAY' end as 'Shift',
	             case when datepart(hh,min(timein)) >=17 then max(timeout)-1 else max(timeout) end as  timeout,
				  case when datepart(hh,min(timein)) >=17  or ( min(timein) IS NULL and datepart(hh,max(timeout)) < 12 ) then timedate-1 else TimeDate end as  timedate
				 from
				(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.CODELINEMOVE, d.Positiontb,a.machineno,
				case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21,33) then  min(a.TimeStr) else null end as timein,
				case when a.MachineNo in (2,4,6,8,10,12,14,16,17,18,19,20,33) then max(a.TimeStr)  else null end as timeout,TimeDate


				from stb_fingerPrint  a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				left join cte  c on a.UserFullCode = c.EMPLOYEESID
				--left join stb_FingerDept  c on b.IDD = c.IDD
				left join Stb_FingerPosition d on b.IDP = d.IDP
				where 1=1 and rn = 1
			--	and b.IDZ not in (5,15,17)
				-- and c.Dept !='module'
				--and c.dept ='VVC-18'
				--and a.Userfullcode='3181157'
				--and  (c.dept like '%VVC%' or c.dept like '%MANUALINE%' or c.dept like '%VVMD%'  or c.dept like '%VVMM%')
				and  (c.CODELINEMOVE like '%VVC%' or c.CODELINEMOVE like '%MANUALINE%' or c.CODELINEMOVE like '%VVMD%'  or c.CODELINEMOVE like '%VVMM%' or c.CODELINEMOVE like 'TCX2')
				--and (a.Userfullcode=@pEmpnoNo or @pEmpnoNo='')
				and (a.TimeDate  between @pFromDate and @pToDate)
			    group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.CODELINEMOVE, d.Positiontb,a.timedate, a.MachineNo) abc
				group by  Userfullcode, UserEnrollNumber,UserFullName, CODELINEMOVE, Positiontb,timedate) abc1
				
				on abc.userfullcode = abc1.UserFullCode 
				and abc.timedate = abc1.timedate
				)
				
				where abc.UserFullCode is not null
				--and timein is not null and timeout  is not null
				group by abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.CODELINEMOVE, abc.Positiontb,abc.timedate) aaa






  
	Open c
	Fetch next From c into @Userfullcode, @UserEnrollNumber, @UserFullName, @dept, @Positiontb,  @timedate , @timein , @timeout , @shift, @sumtime , @TimeOT 
	While @@Fetch_Status=0 
	Begin
	    
		if @sumtime >=5 
		begin
			set @minute = @sumtime -1
		end
		else
		begin
			set @minute = @sumtime
		end
	
		select @cnt=count(*) from STB_VN_ATTENDANCE_TIME where EMPLOYEES_ID=@userfullcode and WORK_DATE = @timedate 
		if @cnt  = 0
		begin
		    
			insert into STB_VN_ATTENDANCE_TIME(employees_id, employees_name,code_line, work_date,start_time,end_time,total_time,CREATEDATETIME,CREATEUSSERID) values (@Userfullcode,@UserFullName,@dept,@timedate,@timein,@timeout,@minute * 60,getdate(),'system')
		END
		ELSE
		BEGIN
			update STB_VN_ATTENDANCE_TIME set start_time = @timein, end_time = @timeout, total_time=@minute*60, CODE_LINE=@dept where EMPLOYEES_ID = @userfullcode and WORK_DATE = @timedate
		end
		
    Fetch next From c into @Userfullcode, @UserEnrollNumber, @UserFullName, @dept, @Positiontb,  @timedate , @timein , @timeout , @shift, @sumtime , @TimeOT 
	end
	Close c
	DEALLOCATE  c
END



