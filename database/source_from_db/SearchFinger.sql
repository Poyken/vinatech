
CREATE PROCEDURE [dbo].[SearchFinger]
	-- Add the parameters for the stored procedure here
	@pEmpID nvarchar(50) = null,
	@pEmpName nvarchar(50) = null,
	@pFromDate date,
	@pToDate date

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select Userfullcode,UserEnrollNumber,UserFullName,dept,Positiontb,timedate,timein,timeout ,Shift,
case when shift='NGAY' then case when  ABS(DATEDIFF(HH, timeout,  timein)) -1 >0 then cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1 else NULL end
else 
		case when  ABS(DATEDIFF(HH, timeout,  timein)) -1 >0 then cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1 else NULL end
end
as sumtime,
--ABS(DATEDIFF(HH,timeout, timein)) -1  as sumtime,
--case when ABS(DATEDIFF(HH,timeout, timein)) -1 > 8 then (ABS(DATEDIFF(HH,timeout, timein)) -1) - 8 else NULL end TimeOT
case when Shift='NGAY' then case when ABS(DATEDIFF(HH, timeout,  timein)) -1 > 8 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1) - 8 else NULL end 
else
case when ABS(DATEDIFF(HH, timeout,  timein)) -1 > 8 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1) - 8 else NULL end
end as sumOT
from 
(select  abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.dept, abc.Positiontb,abc.timedate,FORMAT(min(abc.timein),'HH:mm')  as timein,FORMAT( max(abc1.timeout),'HH:mm')  as timeout,
case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift' from

(
--chay tu day

(select 		 Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10  then 'DEM' else 'NGAY' end as 'Shift',timedate,
	min(timein) as timein from
				(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.machineno,
				case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21) then  min(a.TimeStr) else null end as timein,
				case when a.MachineNo in (2,4,6,8,10,12,14,16,18,20) then max(a.TimeStr)  else null end as timeout,TimeDate


				from stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				left join stb_FingerDept c on b.IDD = c.IDD
				left join Stb_FingerPosition d on b.IDP = d.IDP
				where 1=1
				and b.IDZ not in (5,15)
			    and (@pEmpID is null or @pEmpID='' or a.Userfullcode=@pEmpID)
				and (@pEmpName is null or @pEmpName='' or b.UserFullName like '%'+@pEmpName+'%')
				and (a.TimeDate between @pFromDate and @pToDate)
			    group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.timedate, a.MachineNo) abc
				group by  Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,timedate) abc
FULL OUTER JOIN

(select 		 Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,case when datepart(hh,min(timein)) >=18 and datepart(hh,min(timeout)) <=10 then 'DEM' else 'NGAY' end as 'Shift',
	             case when datepart(hh,min(timein)) >=18 then max(timeout)-1 else max(timeout) end as  timeout,
				  case when datepart(hh,min(timein)) >=18 or ( min(timein) IS NULL)then timedate-1 else TimeDate end as  timedate
				 from
				(select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.machineno,
				case when a.MachineNo in (1,3,5,7,9,11,13,15,17,19,21) then  min(a.TimeStr) else null end as timein,
				case when a.MachineNo in (2,4,6,8,10,12,14,16,18,20) then max(a.TimeStr)  else null end as timeout,TimeDate


				from stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				left join stb_FingerDept c on b.IDD = c.IDD
				left join Stb_FingerPosition d on b.IDP = d.IDP
				where 1=1
				--AND a.UserFullCode='31908003'
				and b.IDZ not in (5,15)
				and (@pEmpID is null or @pEmpID='' or a.Userfullcode=@pEmpID)
				and (@pEmpName is null or @pEmpName='' or b.UserFullName like '%'+@pEmpName+'%')
				and (a.TimeDate between @pFromDate and @pToDate)
			    group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.timedate, a.MachineNo) abc
				group by  Userfullcode, UserEnrollNumber,UserFullName, dept, Positiontb,timedate) abc1
				
				on abc.userfullcode = abc1.UserFullCode 
				and abc.timedate = abc1.timedate
				)
				
				where abc.UserFullCode is not null
				group by abc.Userfullcode, abc.UserEnrollNumber,abc.UserFullName, abc.dept, abc.Positiontb,abc.timedate) aaa

UNION 



select   a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,timedate,
				--	SUBSTRING( convert(varchar, min(a.TimeStr),108),1,5) as timein,
				--	SUBSTRING( convert(varchar, max(a.TimeStr),108),1,5) as timout,
				  FORMAT( min(a.TimeStr),'HH:mm') as timein,
				 FORMAT(max(a.TimeStr),'HH:mm')  as timeout,'NGAY' as calamviec,
				--case when  ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1 >0 then ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1 else NULL end as sumtime,
				--case when ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1 > 8 then (ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1) - 8 else NULL end TimeOT
				case when  ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1 >0 then cast (Format(case when CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1 else NULL end as sumtime,
				case when ABS(DATEDIFF(HH, max(a.TimeStr),  min(a.TimeStr))) -1 > 8 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) end,'HH') as int) +
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) <CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then  CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) else CAST(CONVERT(VARCHAR(5), max(a.TimeStr), 108) AS datetime) - CAST(CONVERT(VARCHAR(5), min(a.TimeStr), 108) AS datetime) end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) -1) - 8 else NULL end TimeOT


				from stb_FingerPrint a left join Stb_fingerUserInfo b on a.UserEnrollNumber= b.UserEnrollNumber 
				left join stb_FingerDept c on b.IDD = c.IDD
				left join Stb_FingerPosition d on b.IDP = d.IDP
				where 1=1
				--AND a.UserFullCode='31908003'
				and (@pEmpID is null or @pEmpID='' or a.Userfullcode=@pEmpID)
				and (@pEmpName is null or @pEmpName='' or b.UserFullName like '%'+@pEmpName+'%')
				and (a.TimeDate between @pFromDate and @pToDate)
				and b.IDZ  in (5,15)
			    group by  a.Userfullcode, a.UserEnrollNumber,b.UserFullName, c.dept, d.Positiontb,a.timedate


END

