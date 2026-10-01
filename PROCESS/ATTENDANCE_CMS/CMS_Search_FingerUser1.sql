

CREATE procedure [dbo].[Search_FingerUser1]-- exec Search_FingerUser1 '2026-06-01','2026-06-30','42208001','','',''
@pFromDate date,
@pToDate date,
@EmpID NVARCHAR(50),
@EmpName NVARCHAR(50),
@Depart NVARCHAR(50),
@TypeEmployee nvarchar(50)

AS
BEGIN
	--SET NOCOUNT ON;
     
 --   DECLARE @Userfullcode nvarchar(20)
	--DECLARE @datel date
	--DECLARE @cnt int 

	
 -- create table #tempfinger (EMPLOYEESID varchar(50), dateinmonth datetime )

 --  DECLARE c Cursor LOCAL FOR select EMPLOYEESID from Tbl_Employees where STATUSEMPLOYESS=1;

	--DECLARE c1 Cursor LOCAL  FOR SELECT  TOP (DATEDIFF(DAY, @FromDate, @ToDate) + 1)
 --       Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate)
	--FROM    sys.all_objects a
 --       CROSS JOIN sys.all_objects b

	--Open c
	--Fetch next From c into @Userfullcode
	--While @@Fetch_Status=0 
	--Begin
	    
	--	Open c1
	--	fetch next from c1 into @datel
	--	while @@FETCH_STATUS= 0
	--	begin

	--		select @cnt=count(*) from #tempfinger where EMPLOYEESID=@Userfullcode and dateinmonth=@datel
	--		if @cnt  = 0
	--		begin
		    
	--			insert into #tempfinger(EMPLOYEESID,dateinmonth) values (@Userfullcode,@datel)
	--		END
	--		ELSE

	--	fetch next from c1 into @datel
	--	end
	--	close c1
	----	deallocate c1

 --   Fetch next From c into @Userfullcode
	--end
	--Close c
	--DEALLOCATE  c



	
	--	;with dt as ( select EMPLOYEESID, DATEREGISTER from Tbl_FingerRegister 
	-- where typegroup is not null AND
	--		 (((STATUSAPPROVERONE = 'True' AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True')
	--		 OR (STATUSAPPROVERONE = 'True'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		 OR (STATUAPPROVERTWO = 'True'  AND STATUAPPROVERTHREE = 'True' and USERIDAPPROVERONE= 'Please select person approver team leader')
	--		  OR (STATUAPPROVERTWO = 'True'  AND STATUSAPPROVERONE = 'True' and USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		    OR (STATUAPPROVERTWO = 'True'  AND USERIDAPPROVERONE = 'Please select person approver team leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		  OR (USERIDAPPROVERONE = 'Please select person approver team leader'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and STATUAPPROVERTHREE= 'True')
	--		 OR (STATUSAPPROVERONE = 'True'  AND STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))
	--		 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True')
	--		 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))
	--		 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND (USERIDAPPROVERTWO= 'Please select person approver group leader' OR USERIDAPPROVERTWO IS NULL) and STATUAPPROVERTHREE = 'True'))
			

	--)
	--)


	--select 
	--		 distinct
	--			a1.EMPLOYEESID,
	--			c11.EMPLOYEESNAME as FULLNAME,
	--			c11.DEPARTMENTNAME as DEPARTMENT,
	--			c11.POSITTION,
	--			a1.dateinmonth as DATEREGISTER,
	--			case when substring(a1.EMPLOYEESID, 1,1)=8 then N'Thời vụ' else N'Chính thức' end as TypeEmployee,
	--			b1.DATEREGISTER,
	--			case when h1.NOTE ='1' then N'Ngày Lễ' 
	--			     when h1.DATEHOLIDAY  is not null then N'Ngày nghỉ'
	--				 else N'Ngày thường' end as NgayLamViec,
	--			case when DATEPART(dw,a1.dateinmonth)  = 1 then N'CN'
	--				 when DATEPART(dw,a1.dateinmonth)  = 2 then N'Thứ 2'
	--				 when DATEPART(dw,a1.dateinmonth)  = 3 then N'Thứ 3'
	--				 when DATEPART(dw,a1.dateinmonth)  = 4 then N'Thứ 4'
	--				 when DATEPART(dw,a1.dateinmonth)  = 5 then N'Thứ 5'
	--				 when DATEPART(dw,a1.dateinmonth)  = 6 then N'Thứ 6'
	--			else N'Thứ 7' end as DayinWeek,
	--			case 
	--				when TIMEIN is null and timeout is null then ''	
	--			when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime)   then '1' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
	--			when   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) AND  CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then '1'
				
	--			end as checkOT,



	--			case 
	--				when TIMEIN is null and timeout is null then ''	
	--			when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then N'Ngày' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
	--			else N'Đêm' end as Shift,
	--			CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) as totalworktime,

	--			case  when DATEPART(dw,b1.DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 8
	--				 when DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 9 then 9
	--				 when  DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5,6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >=5 then CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 5.5 then 5
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 4.5 then 4
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) =5 and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then 4
	--				 when h1.DATEHOLIDAY is not null 
	--				 and ((CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) and   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime)) 
	--				 or (CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime))) then  
	--			CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) -1 

	--			else 	CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))
	--			end as WorkTimeStand,
	--			TIMEIN,
	--			TIMEOUT,
	--			HOURTIME

	--			,CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) * 60 AS TOTALTIME,
	--			case when h1.DATEHOLIDAY is not null then 0
	--			else CAST(round(REPLACE(TOTALTIMEOVER,',','.'),2) AS decimal(18,2))  end TOTALTIMEOVER,
	--				CASE
	--			   when (b1.TYPEGROUP is not null and b1.STATUSAPPROVERONE = 'True' AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True') then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.STATUSAPPROVERONE = 'True'   AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader') then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND b1.STATUAPPROVERTHREE = 'True' and b1.USERIDAPPROVERONE= 'Please select person approver team leader')  then N'Đã đăng ký vân tay'
	--		        when (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'   AND b1.STATUSAPPROVERONE = 'True' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					
	--				when  (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND b1.USERIDAPPROVERONE = 'Please select person approver team leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.STATUAPPROVERTHREE= 'True')  then N'Đã đăng ký vân tay'
	--				when ( b1.typegroup is not null and  b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
	--				when ( b1.typegroup is not null and   ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True'))  then N'Đã đăng ký vân tay'
	--				when  ( b1.typegroup is not null and  (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
	--				when  ( b1.typegroup is not null and  (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.USERIDAPPROVERTWO IS NULL) and b1.STATUAPPROVERTHREE = 'True')  then N'Đã đăng ký vân tay'
					
	--				WHEN TIMEIN IS NULL AND TIMEOUT IS NULL THEN N'Không đi làm'
	--			ELSE N'Hệ thống'

	--				END AS Statuss 

				
	--from #tempfinger a1
	--left join 
	--		Tbl_FingerRegister b1 ON 
	--		a1.dateinmonth = b1.DATEREGISTER
	--		and a1.EMPLOYEESID = b1.EMPLOYEESID COLLATE DATABASE_DEFAULT
 --    left join Tbl_Employees c11 on a1.EMPLOYEESID=c11.EMPLOYEESID COLLATE DATABASE_DEFAULT
	-- left outer join dt dt1 on a1.EMPLOYEESID = dt1.EMPLOYEESID COLLATE DATABASE_DEFAULT and a1.dateinmonth =dt1.DATEREGISTER
	-- left join Tbl_Holidaycalendar h1 on h1.DATEHOLIDAY = a1.dateinmonth
	-- left join Tbl_OverTime o1 on a1.EMPLOYEESID=o1.EMPLOYEESID COLLATE DATABASE_DEFAULT and a1.dateinmonth= o1.DATEOVERTIME  
	--	Where 1=1 
	--		 AND (@EmpID ='' or a1.EMPLOYEESID = @EmpID)
	--		 AND (@EmpName ='' or c11.EMPLOYEESNAME like '%'+@EmpName+'%')
	--		 AND (@Depart ='' or c11.DEPARTMENTNAME=@Depart)
	--		 AND ((@FromDate='' and @ToDate='') OR a1.dateinmonth between @FromDate and @ToDate)
	--		 AND (@TypeEmployee='' or (@TypeEmployee=N'Thời vụ' and substring(a1.EMPLOYEESID,1,1) = 8) or (@TypeEmployee=N'Chính thức' and substring(a1.EMPLOYEESID,1,1) != 8) )

	--	   and (   b1.typegroup is  null 

	--	   ) and dt1.EMPLOYEESID is  null and dt1.DATEREGISTER is  null
	--union
	
	--select 
	--		 distinct
	--			a1.EMPLOYEESID,
	--			c11.EMPLOYEESNAME as FULLNAME,
	--			c11.DEPARTMENTNAME as DEPARTMENT,
	--			c11.POSITTION,
	--			a1.dateinmonth as DATEREGISTER,
				
	--			case when substring(a1.EMPLOYEESID, 1,1)=8 then N'Thời vụ' else N'Chính thức' end as TypeEmployee,
	--			DATEREGISTER,
	--			case when h1.NOTE ='1' then N'Ngày Lễ' 
	--			     when h1.DATEHOLIDAY  is not null then N'Ngày nghỉ'
	--				 else N'Ngày thường' end as NgayLamViec,
	--			case when DATEPART(dw,a1.dateinmonth)  = 1 then N'CN'
	--				 when DATEPART(dw,a1.dateinmonth)  = 2 then N'Thứ 2'
	--				 when DATEPART(dw,a1.dateinmonth)  = 3 then N'Thứ 3'
	--				 when DATEPART(dw,a1.dateinmonth)  = 4 then N'Thứ 4'
	--				 when DATEPART(dw,a1.dateinmonth)  = 5 then N'Thứ 5'
	--				 when DATEPART(dw,a1.dateinmonth)  = 6 then N'Thứ 6'
	--			else N'Thứ 7' end as DayinWeek,

	--			case 
	--				when TIMEIN is null and timeout is null then ''	
	--			when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime)   then '1' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
	--			when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
	--			when   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) AND  CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) then '1'
				
	--			end as checkOT,

	--			case 
	--				when TIMEIN is null and timeout is null then ''	
	--			when DATEPART(dw,DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then N'Ngày' 
	--			when  DATEPART(dw,DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
	--			when  DATEPART(dw,DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
	--			else N'Đêm' end as Shift,

	--			CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) as totalworktime,

	--			case  when DATEPART(dw,DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 8
	--				 when DATEPART(dw,DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 9 then 9
	--				 when  DATEPART(dw,DATEREGISTER) in ( 2,3,4,5,6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >=5 then CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 5.5 then 5
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 4.5 then 4
	--				 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) =5 and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then 4
	--				 when h1.DATEHOLIDAY is not null
	--				 and ((CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) and   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime)) 
	--				 or (CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime))) then  
	--			CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) -1 

	--			else 	CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))
	--			end as WorkTimeStand,
	--			TIMEIN,
	--			TIMEOUT,
	--			HOURTIME


	--			,CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) * 60 AS TOTALTIME,



	--				case when h1.DATEHOLIDAY is not null then 0
	--			else 
	--					case when DATEPART(dw,DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
	--			then case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
	--			and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
	--			then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
	--			and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
	--			then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
	--			cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
	--			and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
	--			then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
	--			then 0.5 else 0 end as decimal(18,2)) )  
	--			else 
	--				(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
	--				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
	--				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
	--				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
	--				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
	--				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
	--				then 0.5 else 0 end as decimal(18,2)) )  


	--			end
	--		    else
	--			case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
	--			then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
	--				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
	--			then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
	--			else NULL end,'HH') as int)+
	--			cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
	--			and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
	--			then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
	--			else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  else 

	--				(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
	--				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
	--				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
	--				else NULL end,'HH') as int)+
	--				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
	--				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
	--				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
	--				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )
					
	--			end
	--			end
				
	--			end TOTALTIMEOVER,

	--			CASE
	--			   when (b1.TYPEGROUP is not null and b1.STATUSAPPROVERONE = 'True' AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True') then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.STATUSAPPROVERONE = 'True'   AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader') then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND b1.STATUAPPROVERTHREE = 'True' and b1.USERIDAPPROVERONE= 'Please select person approver team leader')  then N'Đã đăng ký vân tay'
	--		        when (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'   AND b1.STATUSAPPROVERONE = 'True' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					
	--				when  (b1.typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND b1.USERIDAPPROVERONE = 'Please select person approver team leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
	--				when (b1.typegroup is not null and  b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.STATUAPPROVERTHREE= 'True')  then N'Đã đăng ký vân tay'
	--				when ( b1.typegroup is not null and  b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
	--				when ( b1.typegroup is not null and   ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True'))  then N'Đã đăng ký vân tay'
	--				when  ( b1.typegroup is not null and  (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
	--				when  ( b1.typegroup is not null and  (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.USERIDAPPROVERTWO IS NULL) and b1.STATUAPPROVERTHREE = 'True')  then N'Đã đăng ký vân tay'
					
	--				WHEN TIMEIN IS NULL AND TIMEOUT IS NULL THEN N'Không đi làm'
	--			ELSE N'Hệ thống'

	--				END AS Statuss 
	
	--from #tempfinger a1
	--left join 
	--		Tbl_FingerRegister b1 ON 
	--		a1.dateinmonth = b1.DATEREGISTER
	--		and a1.EMPLOYEESID = b1.EMPLOYEESID COLLATE DATABASE_DEFAULT
 --    left join Tbl_Employees c11 on a1.EMPLOYEESID=c11.EMPLOYEESID COLLATE DATABASE_DEFAULT
	-- left join Tbl_Holidaycalendar h1 on h1.DATEHOLIDAY = a1.dateinmonth
	-- left join Tbl_OverTime o1 on a1.EMPLOYEESID=o1.EMPLOYEESID COLLATE DATABASE_DEFAULT and a1.dateinmonth= o1.DATEOVERTIME  
	--	Where 1=1 
	--		 AND (@EmpID ='' or a1.EMPLOYEESID = @EmpID)
	--		 AND (@EmpName ='' or c11.EMPLOYEESNAME like '%'+@EmpName+'%')
	--		 AND (@Depart ='' or c11.DEPARTMENTNAME=@Depart)
	--		 AND ((@FromDate='' and @ToDate='') OR a1.dateinmonth between @FromDate and @ToDate)
	--		 AND (@TypeEmployee='' or (@TypeEmployee=N'Thời vụ' and substring(a1.EMPLOYEESID,1,1) = 8) or (@TypeEmployee=N'Chính thức' and substring(a1.EMPLOYEESID,1,1) != 8) )
	--		and ((  (b1.typegroup is not null   
		
	--			and ((b1.STATUSAPPROVERONE = 'True' AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True')
	--		 OR (b1.STATUSAPPROVERONE = 'True'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		 OR (b1.STATUAPPROVERTWO = 'True'  AND b1.STATUAPPROVERTHREE = 'True' and b1.USERIDAPPROVERONE= 'Please select person approver team leader')
	--		  OR (b1.STATUAPPROVERTWO = 'True'  AND b1.STATUSAPPROVERONE = 'True' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		    OR (b1.STATUAPPROVERTWO = 'True'  AND b1.USERIDAPPROVERONE = 'Please select person approver team leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
	--		  OR (b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.STATUAPPROVERTHREE= 'True')
	--		 OR (b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))
	--		 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True')
	--		 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))
	--		 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.USERIDAPPROVERTWO IS NULL) and b1.STATUAPPROVERTHREE = 'True'))
	--		)
			 
	--	   ) 

	--	   )



	--	   order by  EMPLOYEESID,dateinmonth desc
    

	--drop table #tempfinger




	--NEW SQL

    Declare @cnt int
	Declare @cnt_confirm int

    Declare @Date date
	Declare @Userfullcode nvarchar(10) 
	Declare @FromDate date
	Declare @ToDate date 
	Declare @TimeIn nvarchar(10)
	Declare @TimeOut nvarchar(10)
	Declare @CodeLeave nvarchar(10)
	Declare @ReasonLeave nvarchar(200)
	Declare @Shirt nvarchar(20)


	--thong tin de chay vong lap
	Declare @Emp nvarchar(10)
	Declare @FullName nvarchar(50)
	Declare @Department nvarchar(100)
	Declare @StartWork nvarchar(10)
	Declare @Position nvarchar(10)
	Declare @NghiLeTV nvarchar(10)
	Declare @NghiLeCT nvarchar(10)
	Declare @TotalWorkTimeStand nvarchar(10)
	Declare @CongCaNgayTV nvarchar(10)
	Declare @CongCaNgayCT nvarchar(10)
	Declare @CongCaDemTV nvarchar(10)
	Declare @CongCaDemCT nvarchar(10)
	Declare @OTBefore22hCT nvarchar(10)
	Declare @OTBefore22hTV nvarchar(10)
	Declare @OTAfter22hCT nvarchar(10)
	Declare @OTAfter22hTV nvarchar(10)
	Declare @OTDemCT nvarchar(10)
	Declare @OTDemTV nvarchar(10)
	Declare @OTNgayChuNhatCT nvarchar(10)
	Declare @OTNgayChuNhatTV nvarchar(10)
	Declare @OTDemChuNhatCT nvarchar(10)
	Declare @OTDemChuNhatTV nvarchar(10)
	Declare @OTNgayLeCT nvarchar(10)
	Declare @OTNgayLeTV nvarchar(10)
	Declare @OTDemLeCT nvarchar(10)
	Declare @OTDemLeTV nvarchar(10)
	Declare @TimeNghiPhep nvarchar(10)
	Declare @timenghikhamthai nvarchar(10)
	Declare @timeNghiKhongLuong nvarchar(10)
	Declare @TimeNghiBHXH nvarchar(10)
	Declare @TimeNghiDacBiet nvarchar(10)
	Declare @QuenVanTay nvarchar(10)
	Declare @TimeKhongLuong nvarchar(10)
	Declare @TimeStand nvarchar(10)

	Declare @PhuCap15PDemCT nvarchar(10)
	Declare @PhuCap15PDemTV nvarchar(10)
	Declare @PhuCapChuyenCan nvarchar(20)
	Declare @TongCongHuongLuong nvarchar(10)
	Declare @TrangThaiDongBH nvarchar(20)
	Declare @Seniority nvarchar(20)

	CREATE TABLE #temp_leave
	( EmpID nvarchar(10),
	  DateLeave date,
	  TimeIn nvarchar(10),
	  TimeOut nvarchar(10),
	  CodeLeave nvarchar(10),
	  ReasonLeave nvarchar(200),
	  Shirt nvarchar(20)
	) 
   
   --tạo ra con trỏ c 
   DECLARE c Cursor LOCAL FOR (SELECT
			
				
				EMPLOYEESID,
				CONVERT(DATE,FROMDATE) AS 'FROMDATE',
				CONVERT(DATE,TODATE) AS 'TODATE',
				

				TIMEIN,
				TIMEOUT,
				
				
				T3.CODEROT,
				T1.OTHERREASON,
				T1.SHIRT
				
		FROM
				Tbl_EmployeesLeaves T1 WITH(NOLOCK)
		LEFT JOIN
					Tbl_Shift T2 ON T2.CODEIDS = T1.SHIRT
		LEFT JOIN
					Tbl_ReasonActions T3 ON T1.REASONLEAVE = T3.CODEROT
		Where 1=1

		 AND ( CONVERT(DATE,t1.FROMDATE) between  @pFromDate and @pToDate ) 
	       AND (
		 (T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1' AND T1.STATUAPPROVERFOUR = '1')
		 OR ((NAMEAPPROVERONE is null or  NAMEAPPROVERONE ='Please select person approver team leader') and T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1' AND (NAMEAPPROVERFOUR is null or  NAMEAPPROVERFOUR ='Please select person headquarter'))
		 OR (T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTWO = '1' AND (T1.NAMEAPPROVERTHREE = 'Please select person headquarter' or NAMEAPPROVERTHREE is null) AND (T1.NAMEAPPROVERFOUR = 'Please select person headquarter' or NAMEAPPROVERFOUR is null))
		 OR (T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1' AND (T1.NAMEAPPROVERFOUR = 'Please select person headquarter' or NAMEAPPROVERFOUR is null))
		 OR (T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERFOUR = '1'  AND (T1.USERIDAPPROVERTWO = 'Please select person approver group leader' or NAMEAPPROVERTWO is null) AND (T1.USERIDAPPROVERTHREE = 'Please select person sector leader' or t1.NAMEAPPROVERTHREE IS NULL))
		 OR (T1.STATUSAPPROVERONE = '1' AND (T1.NAMEAPPROVERTWO = 'Please select person approver group leader' or NAMEAPPROVERTWO is null) AND (T1.NAMEAPPROVERTHREE = 'Please select person sector leader'  or NAMEAPPROVERTHREE is null)  AND T1.STATUAPPROVERFOUR = '1')
		 OR (T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERFOUR = '1' AND  (T1.NAMEAPPROVERTHREE = 'Please select person sector leader' or NAMEAPPROVERTHREE is null)  AND (T1.NAMEAPPROVERONE = 'Please select person approver team leader' or NAMEAPPROVERONE is null))
		 OR (T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1' AND T1.STATUAPPROVERFOUR = '1' AND (T1.USERIDAPPROVERONE = 'Please select person approver team leader' or USERIDAPPROVERONE is null))
		  OR (T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1'  AND (T1.USERIDAPPROVERONE = 'Please select person approver team leader' or USERIDAPPROVERONE is null)) --update
		 OR (T1.STATUAPPROVERTHREE = '1' AND T1.STATUAPPROVERFOUR = '1' AND (T1.USERIDAPPROVERONE = 'Please select person approver team leader' or USERIDAPPROVERONE is null)  AND (T1.USERIDAPPROVERTWO = 'Please select person approver group leader' or USERIDAPPROVERTWO is null) )
		 OR (T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERFOUR = '1' AND T1.STATUSAPPROVERONE = '1' AND (T1.USERIDAPPROVERTHREE = 'Please select person sector leader' or USERIDAPPROVERTHREE is null))
		 OR (T1.STATUAPPROVERFOUR = '1'  AND (T1.USERIDAPPROVERTWO = 'Please select person approver group leader') AND (T1.USERIDAPPROVERTHREE = 'Please select person sector leader') AND (T1.USERIDAPPROVERONE ='Please select person approver team leader'))
	     OR (T1.STATUSAPPROVERONE = '1'  AND (T1.USERIDAPPROVERTWO = 'Please select person approver group leader') AND (T1.STATUAPPROVERTHREE = '1') AND (T1.STATUAPPROVERFOUR = '1'))
		 OR (T1.STATUAPPROVERTWO = '1') AND (T1.STATUAPPROVERFOUR IS NULL) AND (T1.STATUAPPROVERTHREE IS NULL) AND (T1.STATUSAPPROVERONE IS NULL) AND (T1.USERIDAPPROVERFOUR = 'Please select person headquarter') AND (T1.USERIDAPPROVERTHREE = 'Please select person sector leader') AND (T1.USERIDAPPROVERONE = 'Please select person approver team leader')
		 OR (T1.STATUSAPPROVERONE = '1') AND (T1.STATUAPPROVERTWO = '1') AND (T1.USERIDAPPROVERFOUR = 'Please select person headquarter') AND (T1.USERIDAPPROVERTHREE = 'Please select person sector leader')
		 OR (T1.USERIDAPPROVERTWO = 'Please select person approver group leader'  AND T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTHREE = '1' AND T1.USERIDAPPROVERFOUR ='Please select person headquarter'))
	)


	Open c
	Fetch next From c into @Userfullcode, @FromDate,@ToDate, @TimeIn,@TimeOut, @CodeLeave,@ReasonLeave,@Shirt
	While @@Fetch_Status=0 
	Begin
		
		DECLARE c1 Cursor LOCAL  FOR 
		 SELECT  TOP (abs(DATEDIFF(DAY, @FromDate, @ToDate)) + 1)
        Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate)
		FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b

		Open c1
		fetch next from c1 into @Date
		while @@FETCH_STATUS= 0
		begin
		insert into #temp_leave values (@Userfullcode,@Date,@TimeIn,@TimeOut,@CodeLeave, @ReasonLeave, @Shirt)

		fetch next from c1 into @Date
		end
		close c1
		deallocate c1

   fetch next from c into @Userfullcode, @FromDate,@ToDate, @TimeIn,@TimeOut, @CodeLeave,@ReasonLeave,@Shirt
	end
	Close c
	DEALLOCATE  c
	--kết thúc vòng con trỏ c


	--tao bang tam de load thong tin cham cong cac ngay trong thang
   DECLARE @datel date
   create table #tempfinger (EMPLOYEESID varchar(50), dateinmonth datetime )

   DECLARE d Cursor LOCAL FOR select EMPLOYEESID from Tbl_Employees where STATUSEMPLOYESS=1 and (EMPLOYEESID=@EmpID or @EmpID='') ;

	DECLARE d1 Cursor LOCAL  FOR SELECT  TOP (DATEDIFF(DAY, @pFromDate, @pToDate) + 1)
        Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @pFromDate)
	FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b

	Open d
	Fetch next From d into @Userfullcode
	While @@Fetch_Status=0 
	Begin
	    
		Open d1
		fetch next from d1 into @datel
		while @@FETCH_STATUS= 0
		begin

			select @cnt=count(*) from #tempfinger where EMPLOYEESID=@Userfullcode and dateinmonth=@datel
			if @cnt  = 0
			begin
		    
				insert into #tempfinger(EMPLOYEESID,dateinmonth) values (@Userfullcode,@datel)
			END
			ELSE

		fetch next from d1 into @datel
		end
		close d1
	--	deallocate c1

    Fetch next From d into @Userfullcode
	end
	Close d
	DEALLOCATE  d

	;with dt as ( select EMPLOYEESID, DATEREGISTER from Tbl_FingerRegister 
	 where typegroup is not null AND
			 (((STATUSAPPROVERONE = 'True' AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True')
			 OR (STATUSAPPROVERONE = 'True'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')
			 OR (STATUAPPROVERTWO = 'True'  AND STATUAPPROVERTHREE = 'True' and USERIDAPPROVERONE= 'Please select person approver team leader')
			  OR (STATUAPPROVERTWO = 'True'  AND STATUSAPPROVERONE = 'True' and USERIDAPPROVERTHREE= 'Please select person sector leader')
			    OR (STATUAPPROVERTWO = 'True'  AND USERIDAPPROVERONE = 'Please select person approver team leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')
			  OR (USERIDAPPROVERONE = 'Please select person approver team leader'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and STATUAPPROVERTHREE= 'True')
			 OR (STATUSAPPROVERONE = 'True'  AND STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))
			 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True')
			 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))
			 OR ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND (USERIDAPPROVERTWO= 'Please select person approver group leader' OR USERIDAPPROVERTWO IS NULL) and STATUAPPROVERTHREE = 'True'))
			

	)
	)
   
	,tbl_ChamCong	as(
	

			
select 
			 distinct  
				a1.EMPLOYEESID,
				c11.EMPLOYEESNAME as FULLNAME,
				c11.PARTCODE as DEPARTMENT,
				c11.POSITTION,
				c11.PARTCODE,
				a1.dateinmonth as DATEREGISTER,
				case when substring(b1.EMPLOYEESID, 1,1)=8 then N'Thời vụ' else N'Chính thức' end as TypeEmployee,
				
				case when DATEPART(dw,a1.dateinmonth)  = 1 then N'CN'
					 when DATEPART(dw,a1.dateinmonth)  = 2 then N'Thứ 2'
					 when DATEPART(dw,a1.dateinmonth)  = 3 then N'Thứ 3'
					 when DATEPART(dw,a1.dateinmonth)  = 4 then N'Thứ 4'
					 when DATEPART(dw,a1.dateinmonth)  = 5 then N'Thứ 5'
					 when DATEPART(dw,a1.dateinmonth)  = 6 then N'Thứ 6'
				else N'Thứ 7' end as DayinWeek,
				case when h1.NOTE ='1' then N'Ngày Lễ' 
				     when h1.DATEHOLIDAY  is not null then N'Ngày nghỉ'
					 else N'Ngày thường' end as NgayLamViec,
				case 
					when TIMEIN is null and timeout is null then ''	
				when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then N'Ngày' 
				when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
				when  DATEPART(dw,b1.DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
				else N'Đêm' end as Shift,
				--case when DATEPART(dw,DATEREGISTER) in ( 2,3,4,5,6,7) and CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) > 4 then CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) + 1
				--else CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) end as totalworktime,
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) as totalworktime,

				case  when DATEPART(dw,b1.DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 8
					 when DATEPART(dw,b1.DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 7 then 8
					when DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 9 then 9
					when DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry  and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 9
					when  DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5,6,7) and (m1.EmpID is  null or b1.DATEREGISTER > m1.DateExpiry) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >=5 then CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1
					when  DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5,6,7) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >=5 then CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))
					
					when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 5.5 then 5
					 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 4.5 then 4
					 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) =5 and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then 4
					 when h1.DATEHOLIDAY is not null
					 and ((CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) and   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime)) 
					 or (CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime))) then  
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) -1 

				else 	CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))
				end as WorkTimeStand,
			
				TIMEIN,
				TIMEOUT,
				HOURTIME,
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) * 60 AS TOTALTIME,
				case when h1.DATEHOLIDAY is not null then 0
				
				else 
				  
				  case 
				 
                
				  when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				 then 
		
					 case
					--  Thêm trường hợp nếu mà là ngày 2026-04-11 và 2026-04-25 thì sẽ tính tăng ca từ 18h 
					
					 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and(DATEPART(dw, b1.DATEREGISTER) IN (2,3,4,5) OR b1.DATEREGISTER in( '2026-04-11','2026-04-25','2026-08-29')) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  
					

					 
					 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

					 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

					
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  


					
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) ) 

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) ) 



						
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

				
				--else 
				--	case when  ((m1.EmpID is null and  m1.DateExpiry is null) or  (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				--	then
				--	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				--	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				--	then 0.5 else 0 end as decimal(18,2)) )  
				--	end
					

				end

					
			    else

					 

				case 
					-- Với ca đêm		
           	
			
			when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in( '2026-04-11','2026-04-25','2026-08-29')) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  




				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  



				
				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29')) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  

				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  



				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

					when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )


				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then 	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '00:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then 	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime)between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) between CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) and CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

			
					end
			
				end
				
				end TOTALTIMEOVER,
				   
					case when h1.DATEHOLIDAY is not null then 0
				else  
				  
				case 
				          
				  when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 
				 
				case 
				--xư láy 2 ngày đặc biêt
		       	when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))

				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in( '2026-04-11','2026-04-25','2026-08-29')) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)

				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) ) 



				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))

				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)

				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) ) 
				



					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)  and b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then 
					(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then 
						(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				--else 
				--	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				--	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				--	then 0.5 else 0 end as decimal(18,2)) )  

				end

				when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 
				
				case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  
				/*
				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  
				*/
				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then
				(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then
						(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				--else 
				--	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				--	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				--	then 0.5 else 0 end as decimal(18,2)) )  

				end
			    end
				
				end OTBefore22H,

				case when h1.DATEHOLIDAY is not null then 0
				else 
						case when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 
				
				case
				-- xử lý 2 ngày đặc biêt
				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) or b1.DATEREGISTER in( '2026-04-11','2026-04-25','2026-08-29') ) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) ) 

				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  


				--else 
				--	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				--	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				--	then 0.5 else 0 end as decimal(18,2)) )  


					end
			    end
				
				end OTAfter22H,



				CASE
				   when (TYPEGROUP is not null and b1.STATUSAPPROVERONE = 'True' AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True') then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.STATUSAPPROVERONE = 'True'   AND USERIDAPPROVERTWO = 'Please select person approver group leader' and USERIDAPPROVERTHREE= 'Please select person sector leader') then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND STATUAPPROVERTHREE = 'True' and USERIDAPPROVERONE= 'Please select person approver team leader')  then N'Đã đăng ký vân tay'
			        when (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'   AND STATUSAPPROVERONE = 'True' and USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					
					when  (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND USERIDAPPROVERONE = 'Please select person approver team leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and STATUAPPROVERTHREE= 'True')  then N'Đã đăng ký vân tay'
					when ( typegroup is not null and  b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
					when ( typegroup is not null and   ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True'))  then N'Đã đăng ký vân tay'
					when  ( typegroup is not null and  (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
					when  ( typegroup is not null and  (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND (USERIDAPPROVERTWO= 'Please select person approver group leader' OR USERIDAPPROVERTWO IS NULL) and STATUAPPROVERTHREE = 'True')  then N'Đã đăng ký vân tay'
					
					WHEN TIMEIN IS NULL AND TIMEOUT IS NULL THEN N'Không đi làm'
				ELSE N'Hệ thống'

					END AS Statuss 
	
	 	from #tempfinger a1
	left join 
			Tbl_FingerRegister b1 ON 
			a1.dateinmonth = b1.DATEREGISTER 
			and a1.EMPLOYEESID = b1.EMPLOYEESID COLLATE DATABASE_DEFAULT
		 left outer join dt dt1 on a1.EMPLOYEESID = dt1.EMPLOYEESID COLLATE DATABASE_DEFAULT and a1.dateinmonth =dt1.DATEREGISTER
     left join Tbl_Employees c11 on a1.EMPLOYEESID=c11.EMPLOYEESID COLLATE DATABASE_DEFAULT
	 left join Tbl_Holidaycalendar h1 on h1.DATEHOLIDAY = a1.dateinmonth
	 left join Tbl_ChildMode m1 on a1.EMPLOYEESID = m1.EmpID COLLATE DATABASE_DEFAULT
		Where 1=1 
			 AND (@EmpID ='' or a1.EMPLOYEESID = @EmpID)
			  AND (@EmpName ='' or c11.EMPLOYEESNAME like '%'+@EmpName+'%')
			 AND (@Depart ='' or c11.DEPARTMENTNAME=@Depart)
			  AND (@TypeEmployee='' or (@TypeEmployee=N'Thời vụ' and substring(a1.EMPLOYEESID,1,1) = 8) or (@TypeEmployee=N'Chính thức' and substring(a1.EMPLOYEESID,1,1) != 8) )
			 AND ((@pFromDate='' and @pToDate='') OR a1.dateinmonth between @pFromDate and @pToDate)
			 and   b1.typegroup is  null 
		
		    and dt1.EMPLOYEESID is  null and dt1.DATEREGISTER is  null
union
select 
			 distinct
				a1.EMPLOYEESID,
				c11.EMPLOYEESNAME as FULLNAME,
				c11.PARTCODE as DEPARTMENT,
				c11.POSITTION,
				c11.PARTCODE,
				a1.dateinmonth as DATEREGISTER,
				case when substring(b1.EMPLOYEESID, 1,1)=8 then N'Thời vụ' else N'Chính thức' end as TypeEmployee,
				
				case when DATEPART(dw,a1.dateinmonth)  = 1 then N'CN'
					 when DATEPART(dw,a1.dateinmonth)  = 2 then N'Thứ 2'
					 when DATEPART(dw,a1.dateinmonth)  = 3 then N'Thứ 3'
					 when DATEPART(dw,a1.dateinmonth)  = 4 then N'Thứ 4'
					 when DATEPART(dw,a1.dateinmonth)  = 5 then N'Thứ 5'
					 when DATEPART(dw,a1.dateinmonth)  = 6 then N'Thứ 6'
				else N'Thứ 7' end as DayinWeek,
				case when h1.NOTE ='1' then N'Ngày Lễ' 
				     when h1.DATEHOLIDAY  is not null then N'Ngày nghỉ'
					 else N'Ngày thường' end as NgayLamViec,
				case 
					when TIMEIN is null and timeout is null then ''	
				when DATEPART(dw,DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then N'Ngày' 
				when  DATEPART(dw,DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  then 'NCN' 
				when  DATEPART(dw,DATEREGISTER) =1 and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) then 'DCN' 
				else N'Đêm' end as Shift,
				--case when DATEPART(dw,DATEREGISTER) in ( 2,3,4,5,6,7) and CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) > 4 then CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) + 1
				--else CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) end as totalworktime,
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) as totalworktime,

				case  when DATEPART(dw,b1.DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 8
					 when DATEPART(dw,b1.DATEREGISTER) in ( 6,7) and h1.DATEHOLIDAY is null and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 7 then 8
					when DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 9 then 9
					when DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry  and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >= 8 then 9
					when  DATEPART(dw,b1.DATEREGISTER) in ( 2,3,4,5,6,7) and h1.DATEHOLIDAY is null and CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) > 0 and  CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1 >=5 then CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))-1
					 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 5.5 then 5
					 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2)) = 4.5 then 4
					 when CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) =5 and CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) then 4
					 when h1.DATEHOLIDAY is not null
					 and ((CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) and   CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime)) 
					 or (CAST(CONVERT(VARCHAR(5),TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime))) then  
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) -1 

				else 	CAST(REPLACE(HOURTIME,',','.')  AS DECIMAL(18,2)) -  CAST(round(REPLACE(coalesce(coalesce(TOTALTIMEOVER, cast(0 as decimal(18,2))),0),',','.'),2) AS decimal(18,2))
				end as WorkTimeStand,
				TIMEIN,
				TIMEOUT,
				HOURTIME,
				CAST(round(REPLACE(HOURTIME,',','.'),2) AS decimal(18,2)) * 60 AS TOTALTIME,
		

					case when h1.DATEHOLIDAY is not null then 0
				else 
				  case when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				 then 
				 
				     

					 case
					   -- xử 2 ngày dặc biêt
					 	 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR  b1.DATEREGISTER in ('2026-04-25','2026-04-11','2026-08-29')) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  



					 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  



					 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
					 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
					 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

					
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29') and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						 then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  


					
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) ) 

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) ) 



						
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
						 and DATEPART(dw,b1.DATEREGISTER) in (6,7) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:00',108) as datetime)
						  then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
						cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
						and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
						then  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
						then 0.5 else 0 end as decimal(18,2)) )  

				
				--else 
				--	case when  ((m1.EmpID is null and  m1.DateExpiry is null) or  (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				--	then
				--	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				--	cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				--	and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				--	then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				--	then 0.5 else 0 end as decimal(18,2)) )  
				--	end
					

				end

					
			    else
				case 
				 --xủ lý 2 ngày dặc biêt
				  when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) or b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29')) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  
				
				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '06:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  

				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
				then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
				else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )  



				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

					when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '04:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )


				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then 	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

				when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '01:00',108) as datetime) and DATEPART(dw,b1.DATEREGISTER) in (6,7) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry)) and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00',108) as datetime) 
				then 	(cast (Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime)  
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
					and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >CAST(CONVERT(VARCHAR(5), '05:00',108) as datetime) 
					then  CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
					else NULL end,'mm') >=30 then 0.5 else 0 end as decimal(18,2)) )

			
					
				end
				end
				
				end TOTALTIMEOVER,

					case when h1.DATEHOLIDAY is not null then 0
				else 
				 
    
				case when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 
				case 
				-- xử lý trương 2 ngày đặc biêt
					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER IN ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

				 
				
				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry 
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then 
					(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

					when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then 
						(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  


				end

				when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 
				
				case

				--xử lsy 2 ngày dặc biet
				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) OR b1.DATEREGISTER IN ('2026-04-11','2026-04-25','2026-08-29'))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  

				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then
				(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				 when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime)  and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then
						(cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  


				end
			    end
				
				end OTBefore22H,

				case when h1.DATEHOLIDAY is not null then 0
				else 
						case when DATEPART(dw,b1.DATEREGISTER)  in (2,3,4,5,6,7) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) >=CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '22:00',108) as datetime) 
				then 

				case 
				-- XỬ LÝ 2 NGAT
				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
				and (DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) or b1.DATEREGISTER in ('2026-04-11','2026-04-25','2026-08-29')) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  


				
				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00',108) as datetime) 
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) )  


				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (2,3,4,5)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
				cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
				and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
				then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
				then 0.5 else 0 end as decimal(18,2)) ) 

				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and m1.EmpID is not null and b1.DATEREGISTER <= m1.DateExpiry
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  

				when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00',108) as datetime) and ((m1.EmpID is null and  m1.DateExpiry is null) or (m1.EmpID is not null and b1.DATEREGISTER > m1.DateExpiry))
				and DATEPART(dw,b1.DATEREGISTER) in (6,7)
				then (cast (Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '15:30', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'HH') as int)+
					cast( case when Format(case when CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  
					and  CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)
					then  CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) else NULL end,'mm') >=30 
					then 0.5 else 0 end as decimal(18,2)) )  




					end
			    end
				
				end OTAfter22H,




				CASE
				   when (TYPEGROUP is not null and b1.STATUSAPPROVERONE = 'True' AND STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True') then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.STATUSAPPROVERONE = 'True'   AND USERIDAPPROVERTWO = 'Please select person approver group leader' and USERIDAPPROVERTHREE= 'Please select person sector leader') then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND STATUAPPROVERTHREE = 'True' and USERIDAPPROVERONE= 'Please select person approver team leader')  then N'Đã đăng ký vân tay'
			        when (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'   AND STATUSAPPROVERONE = 'True' and USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					
					when  (typegroup is not null and  b1.STATUAPPROVERTWO = 'True'  AND USERIDAPPROVERONE = 'Please select person approver team leader' and USERIDAPPROVERTHREE= 'Please select person sector leader')  then N'Đã đăng ký vân tay'
					when (typegroup is not null and  b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND USERIDAPPROVERTWO = 'Please select person approver group leader' and STATUAPPROVERTHREE= 'True')  then N'Đã đăng ký vân tay'
					when ( typegroup is not null and  b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
					when ( typegroup is not null and   ( (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND STATUAPPROVERTHREE = 'True'))  then N'Đã đăng ký vân tay'
					when  ( typegroup is not null and  (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (USERIDAPPROVERTHREE= 'Please select person approver group leader' OR USERIDAPPROVERTHREE IS NULL))  then N'Đã đăng ký vân tay'
					when  ( typegroup is not null and  (USERIDAPPROVERTWO= 'Please select person approver group leader' OR STATUAPPROVERTWO IS NULL) AND (USERIDAPPROVERTWO= 'Please select person approver group leader' OR USERIDAPPROVERTWO IS NULL) and STATUAPPROVERTHREE = 'True')  then N'Đã đăng ký vân tay'
					
					WHEN TIMEIN IS NULL AND TIMEOUT IS NULL THEN N'Không đi làm'
				ELSE N'Hệ thống'

					END AS Statuss 
	
	 	from #tempfinger a1
	left join 
			Tbl_FingerRegister b1 ON 
			a1.dateinmonth = b1.DATEREGISTER 
			and a1.EMPLOYEESID = b1.EMPLOYEESID COLLATE DATABASE_DEFAULT
		
     left join Tbl_Employees c11 on a1.EMPLOYEESID=c11.EMPLOYEESID COLLATE DATABASE_DEFAULT
	 left join Tbl_Holidaycalendar h1 on h1.DATEHOLIDAY = a1.dateinmonth
	  left join Tbl_ChildMode m1 on a1.EMPLOYEESID = m1.EmpID COLLATE DATABASE_DEFAULT
	Where 1=1 


			 AND (@EmpID ='' or a1.EMPLOYEESID = @EmpID)
		 AND (@EmpName ='' or c11.EMPLOYEESNAME like '%'+@EmpName+'%')
			 AND (@Depart ='' or c11.DEPARTMENTNAME=@Depart)
			  AND (@TypeEmployee='' or (@TypeEmployee=N'Thời vụ' and substring(a1.EMPLOYEESID,1,1) = 8) or (@TypeEmployee=N'Chính thức' and substring(a1.EMPLOYEESID,1,1) != 8) )
			 AND ((@pFromDate='' and @pToDate='') OR a1.dateinmonth between @pFromDate and @pToDate)
			and (  (b1.typegroup is not null   
			--and  (a1.EMPLOYEESID + convert(varchar(10),a1.dateinmonth,120) COLLATE DATABASE_DEFAULT )  in (select EMPLOYEESID  + convert(varchar(10),DATEREGISTER,120) from dt) 
				and ((b1.STATUSAPPROVERONE = 'True' AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True')
			 OR (b1.STATUSAPPROVERONE = 'True'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
			 OR (b1.STATUAPPROVERTWO = 'True'  AND b1.STATUAPPROVERTHREE = 'True' and b1.USERIDAPPROVERONE= 'Please select person approver team leader')
			  OR (b1.STATUAPPROVERTWO = 'True'  AND b1.STATUSAPPROVERONE = 'True' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
			    OR (b1.STATUAPPROVERTWO = 'True'  AND b1.USERIDAPPROVERONE = 'Please select person approver team leader' and b1.USERIDAPPROVERTHREE= 'Please select person sector leader')
			  OR (b1.USERIDAPPROVERONE = 'Please select person approver team leader'  AND b1.USERIDAPPROVERTWO = 'Please select person approver group leader' and b1.STATUAPPROVERTHREE= 'True')
			 OR (b1.STATUSAPPROVERONE = 'True'  AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))
			 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' AND b1.STATUAPPROVERTHREE = 'True')
			 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND b1.STATUAPPROVERTWO = 'True' and (b1.USERIDAPPROVERTHREE= 'Please select person approver group leader' OR b1.USERIDAPPROVERTHREE IS NULL))
			 OR ( (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.STATUAPPROVERTWO IS NULL) AND (b1.USERIDAPPROVERTWO= 'Please select person approver group leader' OR b1.USERIDAPPROVERTWO IS NULL) and b1.STATUAPPROVERTHREE = 'True'))
			)
			 
		   
		   )
)
		   

		, tbl_CheckPhep1 as (
			select distinct a.EmpID, a.CodeLeave, a.DateLeave,a.shirt,a.TIMEIN,a.TIMEOUT,b.TIMEIN as TimeInReal,b.TimeOut as TimeOutReal
			    ,case when  a.shirt='S01' and CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) <=CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),b.TimeIn, 108) AS datetime) <=CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) and (CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TIMEOUT, 108) AS datetime) or (DATEPART(dw,DateLeave) in (6,7)  and  CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >=  CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime)))   then 'N'
				 when a.Shirt='S01' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when a.Shirt='S01' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'08:00', 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when a.Shirt='S01' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when  a.shirt='S02' and CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) <=CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),b.TimeIn, 108) AS datetime) <=CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TIMEOUT, 108) AS datetime) then 'N'
				 when a.Shirt='S02' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),a.TIMEIN, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'06:00', 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when a.Shirt='S02' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),'20:00', 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when a.Shirt='S02' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when a.Shirt='S02' and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) and b.TIMEIN is not null and b.TIMEOUT is not null then 'Y'
				 when b.TIMEIN is null and b.TimeOut is null then 'Y'
				  when b.TIMEIN is not null and b.TimeOut is null then 'Y'
				 when b.timein is null  and b.timeout is not null then 'Y'
			--, case when  CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5),a.TimeIn, 108) AS datetime) then 'Y'
			--       when a.shirt='S01' and CAST(CONVERT(VARCHAR(5),a.TimeIn, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'09:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) and b.TIMEIN is null and b.TimeOut is null then 'Y'
			--	   when a.shirt='S02' and CAST(CONVERT(VARCHAR(5),a.TimeIn, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5),'21:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) and b.TIMEIN is null and b.TimeOut is null then 'Y'
			  --else 'N' 
			  end as Status,
			   (case		
				 --nghi buoi sang 4h
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) 
				--and  CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime) 
			--	and  CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				then 4

				-- nghi buoi sang 5h
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
			--	and  CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
			--	and  CAST(CONVERT(VARCHAR(5),a.TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				then 4

				-- nghi buoi chieu
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '14:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime)
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 5


				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '02:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),b.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),b.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 5
				
				
				--nghi ca ngay
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in ( 6,7) and b.TIMEIN is null and b.TIMEOUT is null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in ( 6,7) and b.TIMEIN is not null and b.TIMEOUT is null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in ( 6,7) and b.TIMEIN is null and b.TIMEOUT is not null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in (2,3,4,5) and b.TIMEIN is null and b.TIMEOUT is null then 9
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in (2,3,4,5) and b.TIMEIN is not null and b.TIMEOUT is null then 9
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate  and DATEPART(dw,DateLeave) in (2,3,4,5) and b.TIMEIN is  null and b.TIMEOUT is not null then 9




			end) as TimeNghiPhep1

			from  #temp_leave a  left join tbl_ChamCong b on a.EmpID = b.EMPLOYEESID COLLATE DATABASE_DEFAULT and a.DateLeave = b.DATEREGISTER
			where DateLeave between @pFromDate and @pToDate and (EmpID = @EmpID or @EmpID='')
		)


		
				,dates_CTE (date) as (
				select @pFromDate 
				Union ALL
				select DATEADD(day, 1, date)
				from dates_CTE
				where date < @pToDate
			)


		,tbl_OT as(
		 SELECT distinct
			  --T1.ID
			  -- ,
			   T1.EMPLOYEESID as EMP
			  ,T1.FULLNAME as NAMES
			  ,T1.DEPARTMENT as DEPT
			  ,t3.POSITTION
			  ,t3.partcode
			  ,CONVERT(DATE,DATEOVERTIME) AS 'DATEOT'
			  ,STARTOVERTIME as STARTS
			  ,ENDOVERTIME as ENDTIME
			 , t4.dateholiday
			 ,t3.Shift á


			   ,COALESCE ( cast(datepart(HOUR, case when convert(datetime, timein) < convert(datetime, '08:00') 
			   then   CONVERT(datetime, '08:00') -convert(datetime, STARTOVERTIME) 
			   else   case when  convert(datetime, timein) > convert(datetime, STARTOVERTIME) then  convert(datetime, timein) - convert(datetime, STARTOVERTIME)  else 
			   convert(datetime, STARTOVERTIME) - convert(datetime, TIMEIN)
			   end 
			   end) as int) ,0) as HourIN

			     ,COALESCE( cast(datepart(minute, case when convert(datetime, timein) < convert(datetime, '08:00') 
			   then   CONVERT(datetime, '08:00') -convert(datetime, STARTOVERTIME) 
			   else   case when  convert(datetime, timein) > convert(datetime, STARTOVERTIME) then  convert(datetime, timein) - convert(datetime, STARTOVERTIME)  else 
			   convert(datetime, STARTOVERTIME) - convert(datetime, TIMEIN)
			   end 
			   end) as int),0) as MinuteIN



			   , COALESCE(case when  convert(datetime, timeout) < convert(datetime, ENDOVERTIME) then cast(datepart(HOUR, convert(datetime, ENDOVERTIME) - convert(datetime, timeout)) as int) else cast(datepart(HOUR, convert(datetime, TIMEOUT) - convert(datetime, ENDOVERTIME) ) as int) end,0) as HourOut
			  
			  , COALESCE(case when  convert(datetime, timeout) < convert(datetime, ENDOVERTIME) then cast(datepart(minute, convert(datetime, ENDOVERTIME) - convert(datetime, timeout)) as int) else cast(datepart(minute, convert(datetime, TIMEOUT) - convert(datetime, ENDOVERTIME) ) as int) end,0) as MinuteOut
			--  ,  COALESCE(cast(datepart(minute,convert(datetime, timeout) - convert(datetime, ENDOVERTIME))   as int),0)  as MinuteOut
			 ,case when  convert(datetime, COALESCE(timein,'00:00')) < convert(datetime, COALESCE(STARTOVERTIME,'00:00')) then 'nho' else 'lon' end as valueIn
			  ,case when  convert(datetime, COALESCE(timeout,'00:00')) < convert(datetime, COALESCE(ENDOVERTIME,'00:00')) then 'nho' else 'lon' end as valueT
			   ,T3.timein
			  ,T3.TIMEOUT 
			  ,T2.SHIFTVIETNAMESE as SHIFTS
			  ,T1.TOTALHOUR as TOTALHOUR



				 ,
					 --tinh thoi gian tang ca ngay le
				 case  
		   when T3.TIMEIN is null or t3.TIMEOUT is null then 0
		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null   and ( ( (t3.Shift='NCN' or t3.Shift=N'Ngày') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)) or  ( (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime)))
			then 
				 case when format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm')  <= 30 and format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm') >=1
							 then case when  (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and  (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
							 then 
								(cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) -1
							 else
							    (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end)
							 end

					   when format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm')  = 0
							 then case when  (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and  (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
							 then 
								(cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) -1
							 else
							    (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end)
							 end

					else   
								 case when (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end) > =5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
								 then 
								   (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end) -1
								 else

								  (cast(format(CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end)
							 end	
							 

				end
			

		  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null  and (t3.Shift='NCN' or t3.Shift=N'Ngày') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
			then case when  (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
				 then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				 else (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)	
				 end

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null  and (t3.Shift='DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime)
			then case when  (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
				 then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				 else (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)	
				 end

			
		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <  CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null and ( ((t3.Shift=N'NCN' or t3.Shift=N'Ngày') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)) or  ((t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime)))

			then
				
				 case when format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm')  <= 30 and format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm') >=1
							 then case when  (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) >=5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
							 then 
								(cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) -1
							 else
							    (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end)
							 end

						when format(CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'mm')  =0
							 then case when  (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) >=5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
							 then 
								(cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end) -1
							 else
							    (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(T3.TIMEIN,1,2)+':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end)
							 end
					else   
								 case when (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end) > =5  and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
								 then 
								   (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end) -1
								 else

								  (cast(format(CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
								 case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(T3.TIMEIN,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
								 then 0.5 else 0 end)
							 end	

			end


		  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <  CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null  and (t3.Shift='DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime)
		   then  case when (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
				then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				else (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
				end


		    when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <  CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null  and (t3.Shift='NCN' or t3.Shift=N'Ngày') and CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		   then  case when (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
				then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				else (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
				end



		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >=  CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null 
		   then case when (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))
				then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				else (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
				end

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <  CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is not null 
		   then case when (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) >=5 and ((CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)  and (t3.Shift='NCN' or t3.Shift=N'Ngày')) or (CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '23:59', 108) AS datetime) and (t3.Shift=N'DCN' or t3.Shift=N'Đêm') and CAST(CONVERT(VARCHAR(5),T3.TIMEOUT, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) ))

				then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) -1
				else (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5),  T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
				end
				end
				as OTNgayNghi,

			-- tinh thoi gian tang ca thuc te ngoai 20h voi cong nhan vien lam viec theo ca

		COALESCE(case 
		when t6.DateJoin is not null and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) and  ((t7.EmpID is not  null and t1.DATEOVERTIME > t7.DateExpiry) or t7.EmpID is  null)
		then 

		(case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

	

		 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			-- tinh thoi gian tang ca thuc te doi voi nhan vien lam viec hanh chinh
			--lam viec tu thu 2 toi t5
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


				 --lam viec tu th6 toi thu 7

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			end	) - 1


			-- doi voi che do con nho

		when t6.DateJoin is not null and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) and  (t7.EmpID is not  null and t1.DATEOVERTIME <= t7.DateExpiry)
		then 

		(case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


		 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			-- tinh thoi gian tang ca thuc te doi voi nhan vien lam viec hanh chinh
			--lam viec tu thu 2 toi t5
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



				 --lam viec tu th6 toi thu 7

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			 and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
			and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			end	) - 1

			--hoc vien vina 

			 when t5.DateLearn is not null and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '19:00', 108) AS datetime)  and  ((t7.EmpID is not  null and t1.DATEOVERTIME > t7.DateExpiry) or t7.EmpID is  null)
		then 

		(case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



		 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			-- tinh thoi gian tang ca thuc te doi voi nhan vien lam viec hanh chinh
			--lam viec tu thu 2 toi t5
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



				 --lam viec tu th6 toi thu 7

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			end	) - 1.5

			--con nho tham gia hoc ngoai ngu
		 when t5.DateLearn is not null and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '19:00', 108) AS datetime)  and  (t7.EmpID is not  null and t1.DATEOVERTIME <= t7.DateExpiry)
		then 

		(case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


		 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' )
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP') or  POSITTION ='OP' ) 
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			-- tinh thoi gian tang ca thuc te doi voi nhan vien lam viec hanh chinh
			--lam viec tu thu 2 toi t5
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%'  and POSITTION !='OP'and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.EmpID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.EmpID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.EmpID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

					 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%'  and POSITTION !='OP'and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


				 --lam viec tu th6 toi thu 7

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



			end	) - 1.5
			

	 else
		
		(case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		  

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '08:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and ((PARTCODE like '%shift%' and POSITTION !='OP')   or POSITTION ='OP')
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		    and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '20:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			-- tinh thoi gian tang ca thuc te doi voi nhan vien lam viec hanh chinh
			--lam viec tu thu 2 toi t5
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		  -- and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
		  and  COALESCE (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end,0) >=20 then 0
		  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) and 
		   COALESCE (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end,0) <20
			then COALESCE (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end,0) 
			


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

				 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (2,3,4,5)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '06:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

						when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '05:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '18:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

						 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

		when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '05:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


	   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (2,3,4,5) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '06:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

				 --lam viec tu th6 toi thu 7

		   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5),T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			   when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			
					  when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) and DATEPART(dw,DATEREGISTER) in (6,7)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '05:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

					when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '04:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '04:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)



			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

						 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '17:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


						when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '16:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


		when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and ((t7.EmpID is not null and t1.DATEOVERTIME > t7.DateExpiry) or t7.empID is null)
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '05:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '05:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '05:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) 

				when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '16:00', 108) AS datetime) and PARTCODE not like '%shift%' and POSITTION !='OP' and DATEPART(dw,DATEREGISTER) in (6,7) and t7.EmpID is not null and t1.DATEOVERTIME <= t7.DateExpiry
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '04:30', 108) AS datetime) and t3.Shift=N'Đêm'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '04:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '04:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end) 

			end	)

			end,0) 	-- check OT đi làm sớm

			+COALESCE(Case when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' and t1.ENDOVERTIME='08:00'
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  t3.timein, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		 when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' and t1.ENDOVERTIME='08:00'
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
			
			 when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' and t1.ENDOVERTIME='08:00'
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  t3.timein, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		 when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' and t1.ENDOVERTIME='08:00'
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

				 when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' 
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		  and CAST(CONVERT(VARCHAR(5),  T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		    AND CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  t3.timein, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
		 when CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) and t3.Shift=N'Ngày' 
		  and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		  and CAST(CONVERT(VARCHAR(5),  T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		    AND CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		    AND CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime)
		  AND CAST(CONVERT(VARCHAR(5), t3.timein, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), T1.STARTOVERTIME, 108) AS datetime)
				then (cast(format(CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),T1.STARTOVERTIME, 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  T1.STARTOVERTIME, 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)
							end,0)

			as OTTruoc22H,

			case	when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE like '%shift%'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '22:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE like '%shift%'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		 
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '22:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			-- voi nhan vien lam viec tu t2-5

			
			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) 
		   and DATEHOLIDAY is  null and CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) and t3.Shift=N'Ngày'
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			then (cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '22:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)

			 when  CAST(CONVERT(VARCHAR(5), T3.TIMEIN, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) and PARTCODE not like '%shift%' 
		   and CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), T1.ENDOVERTIME, 108) AS datetime)
		   and  CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime)
		   and DATEHOLIDAY is  null and t3.Shift=N'Ngày'
			then (cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '22:00', 108) AS datetime),'HH') as int)+
							case when  cast(format(CAST(CONVERT(VARCHAR(5), T3.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),  '22:00', 108) AS datetime) ,'mm') as int) >=30 
							then 0.5 else 0 end)


			



			end	as OTSau22H

 
			--end as OTReal
			 

	    FROM
			   Tbl_OverTime T1 WITH(NOLOCK)
		LEFT JOIN

				Tbl_Shift T2 ON T1.SHIRT = T2.CODEIDS

		--left join Tbl_FingerRegister T3 ON t1.EMPLOYEESID = t3.EMPLOYEESID COLLATE DATABASE_DEFAULT and t1.DATEOVERTIME = t3.DATEREGISTER
		left join tbl_ChamCong T3 ON t1.EMPLOYEESID = t3.EMPLOYEESID COLLATE DATABASE_DEFAULT and t1.DATEOVERTIME = t3.DATEREGISTER
		left join TBL_HOLIDAYCALENDAR t4 on t1.DATEOVERTIME = t4.dateholiday
		left join tbl_LearnLanguage t5 on t1.DATEOVERTIME = t5.DateLearn and t1.EMPLOYEESID = t5.EmpNo
		left join tbl_VinaAcademy t6 on t1.DATEOVERTIME = t6.DateJoin and t1.EMPLOYEESID = t6.EmpNo
		left join Tbl_ChildMode t7 on t1.EMPLOYEESID=t7.EmpID COLLATE DATABASE_DEFAULT

		 WHERE ( CONVERT(DATE,CONVERT(DATE,DATEOVERTIME)) BETWEEN @pFromDate and @pToDate) 
		 and (T1.EMPLOYEESID =@EmpID or @EmpID ='')
		 and (
		   (t1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERTHREE = '1' AND T1.NAMEAPPROVERFOUR = '1')
		    or (t1.STATUSAPPROVERONE = '1' AND t1.USERIDAPPROVERTWO='Please select person approver group leader' AND t1.USERIDAPPROVERTHREE = 'Please select person sector leader')
		 or (t1.STATUAPPROVERTWO = '1' AND t1.STATUAPPROVERTHREE = '1' AND T1.USERIDAPPROVERONE = 'Please select person approver team leader')
		 or (t1.STATUAPPROVERTWO = '1' AND t1.STATUAPPROVERTHREE = '1' AND t1.STATUSAPPROVERONE= '1')
		 or (t1.STATUAPPROVERTWO = '1' AND t1.STATUAPPROVERTHREE = '1' AND T1.STATUSAPPROVERONE = '1' AND T1.USERIDAPPROVERFOUR IS NULL)
		 or (t1.STATUAPPROVERTWO = '1'  AND T1.STATUSAPPROVERONE = '1' AND T1.USERIDAPPROVERTHREE = 'Please select person sector leader')
		 or (t1.STATUAPPROVERTWO = '1'  AND T1.STATUSAPPROVERONE = '1' AND T1.STATUAPPROVERTHREE = '1' AND T1.USERIDAPPROVERFOUR IS NULL)
		 or (t1.STATUAPPROVERTWO = '1' AND t1.STATUAPPROVERTHREE = '1' AND T1.STATUSAPPROVERONE = '1' AND T1.USERIDAPPROVERFOUR = 'Please select person headquarter')
		 or (t1.STATUAPPROVERTHREE = '1' AND t1.STATUSAPPROVERONE= '1' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader')
		 or (t1.STATUAPPROVERTWO ='1' and t1.USERIDAPPROVERTHREE ='Please select person sector leader' and t1.USERIDAPPROVERONE='Please select person approver team leader')
		 or (T1.STATUAPPROVERTHREE = '1' AND T1.STATUAPPROVERFOUR = '1' AND T1.USERIDAPPROVERONE = 'Please select person approver team leader' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader')
		 or (T1.STATUAPPROVERTHREE = '1'  AND T1.USERIDAPPROVERONE = 'Please select person approver team leader' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader')
		 or (T1.STATUAPPROVERTHREE = '1'  AND T1.USERIDAPPROVERONE = 'Please select person approver team leader' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader' AND T1.USERIDAPPROVERFOUR = 'Please select person headquarter')
		 or (T1.STATUAPPROVERFOUR = '1' AND T1.USERIDAPPROVERONE = 'Please select person approver team leader' AND T1.USERIDAPPROVERTHREE = 'Please select person sector leader' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader')
		 or (T1.STATUAPPROVERFOUR = '1' AND T1.USERIDAPPROVERONE = 'Please select person approver team leader' AND T1.USERIDAPPROVERTWO = 'Please select person approver group leader' AND t1.USERIDAPPROVERTHREE = 'Please select person sector leader')
		 or ( T1.STATUAPPROVERTWO = '1' AND T1.STATUAPPROVERFOUR = '1' AND T1.STATUSAPPROVERONE = '1' AND T1.USERIDAPPROVERTHREE = 'Please select person sector leader'))

		 )
	    
	    , tbl_CheckPhep as (
		select EmpID,dateleave,
		sum(case		
				-- nghi buoi sang 4h
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR06','CDR16')and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				then 4

				-- nghi buoi sang 5h
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				then 4

				-- nghi buoi chieu
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '14:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime)
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when  CodeLeave in ('CDR06','CDR16')and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:30', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 5


				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '02:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 5

				
				--nghi ca ngay
				-- Mr.Triều(Mr.Dev) Thêm điều kiện nếu mà là 2 ngày này thì tính là 9 tiếng
				when CodeLeave in ('CDR06','CDR16') and  DateLeave in ('2026-04-25','2026-04-11','2026-08-29') and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 7) and TimeInReal is null and TimeOutReal is null then 9
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is not null and TimeOutReal is null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is not null then 8
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is null and TimeOutReal is null then 9
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is not null and TimeOutReal is null then 9
				when CodeLeave in ('CDR06','CDR16') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is  null and TimeOutReal is not null then 9


			end) as TimeNghiPhep,
			--sum(case  
			--		 when h1.DATEHOLIDAY is not null then 0
			--		 when CodeLeave in ('CDR07','CDR19')  and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=8 then 8
			--		 when CodeLeave in ('CDR07','CDR19') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is  null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=9 then 9
			--		 when CodeLeave in ('CDR07','CDR19') and   Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=6 then 5
			--		 when  CodeLeave in ('CDR07','CDR19') and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=5 then 4
			--	     when  CodeLeave in ('CDR07','CDR19')  and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) )) <=4 then 
			--		   case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
			--				 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
			--				 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
			--				 then 0.5 else 0 end
			--				 else   
			--				 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
			--				 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
			--				 then 0.5 else 0 end
			--				 end
					
			--	end) as TimeNghiKhamThai,
			sum(case		
				-- nghi buoi sang 4h
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				then 4

				-- nghi buoi sang 5h
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				then 4

				-- nghi buoi chieu
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '14:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 5


				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '02:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 5
				
				
				--nghi ca ngay
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is null then 8
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is not null and TimeOutReal is null then 8
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is not null then 8
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is null and TimeOutReal is null then 9
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is not null and TimeOutReal is null then 9
				when CodeLeave in ('CDR07','CDR19') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is  null and TimeOutReal is not null then 9

					end) 
				
				as TimeNghiKhamThai,

			sum(case  
					 when h1.DATEHOLIDAY is not null then 0
					  when CodeLeave in ('CDR05','CDR08','CDR17')  and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and (TimeInReal is null or TimeOutReal is null)then 8
					  when CodeLeave in ('CDR05','CDR08','CDR17')  and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and (TimeInReal is null or TimeOutReal is null)  then 9
					  when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) >=9 then 8

					  when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime)  and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) >=9 then 8


					 when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) and
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) <=8  then  8 -   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) 

					 when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) and
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) <=8  then  8 -   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'17:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '17:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) 



					 when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) >=10 then 9


					
					when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)  and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) >=10 then 9

					
					 when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)   and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) <=9  then 9 - 
							 (
							 case when  CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) and CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime)
							 then
								 
								 	 case when format(CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'12:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'12:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end
								
							 else

							 
							 case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), TimeOutReal, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end
							 end
							 )

					 when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is null and    CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime)   and 
					   (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end) <=9 then 9 -    (case when format(CAST(CONVERT(VARCHAR(5), TimeInReal, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(TimeInReal,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),'18:00', 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(TimeInReal,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end)



					 --when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=8 then 8
					 --when CodeLeave in ('CDR05','CDR08','CDR17') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is  null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=9 then 9
					 --when CodeLeave in ('CDR05','CDR08','CDR17') and   Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=6 then 5
					 --when  CodeLeave in ('CDR05','CDR08','CDR17') and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=5 then 4
				  --   when  CodeLeave in ('CDR05','CDR08','CDR17')  and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) )) <=4 then 
					 -- case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
						--	 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
						--	 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
						--	 then 0.5 else 0 end
						--	 else   
						--	 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
						--	 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
						--	 then 0.5 else 0 end
						--	 end
				
				end) as TimeNghiKhongLuong,

			--sum(case -- when CodeLeave='CDR04' and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=8 then 8
			--		 --when CodeLeave='CDR04' and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is  null and Abs( DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=9 then 9
			--		  when h1.DATEHOLIDAY is not null then 0
			--		 when CodeLeave in ('CDR04','CDR18') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and TimeInReal is null and TimeOutReal is null then 8
			--		 when CodeLeave in ('CDR04','CDR18') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is  null  and TimeInReal is null and TimeOutReal is null then 9
					 
			--		 when CodeLeave in ('CDR04','CDR18') and   Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >6 then 5
			--		 when  CodeLeave in ('CDR04','CDR18') and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=5 then 4
			--	     when  CodeLeave in ('CDR04','CDR18')  and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) )) <=4 then 
			--		  case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
			--				 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
			--				 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
			--				 then 0.5 else 0 end
			--				 else   
			--				 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
			--				 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
			--				 then 0.5 else 0 end
			--				 end
					
					
			--	end) as TimeNghiBHXH,

				
					sum(case		
				-- nghi buoi sang 4h
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				then 4

				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				then 4

				-- nghi buoi sang 5h
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
				then 5

				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) > CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and  CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '06:00', 108) AS datetime) 
				then 5

				-- nghi buoi chieu
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '14:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S01' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '12:00', 108) AS datetime) 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '13:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '08:00', 108) AS datetime) 
				then 5


				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' 
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '02:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in ( 6,7)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '00:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 4
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and Shirt='S02' and DATEPART(dw,DateLeave) in  (2,3,4,5)
				and   CAST(CONVERT(VARCHAR(5),TimeOutReal, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '01:00', 108) AS datetime) 
				and CAST(CONVERT(VARCHAR(5),TimeInReal, 108) AS datetime) <= CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) 
				then 5
				
				
				--nghi ca ngay
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null  and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is null then 8
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is not null and TimeOutReal is null then 8
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in ( 6,7) and TimeInReal is null and TimeOutReal is not null then 8
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is null and TimeOutReal is null then 9
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is not null and TimeOutReal is null then 9
				when CodeLeave in ('CDR04','CDR18','CDR02') and  DateLeave between @pFromDate and @pToDate and h1.DATEHOLIDAY is null and DATEPART(dw,DateLeave) in (2,3,4,5) and TimeInReal is  null and TimeOutReal is not null then 9

					
				end) as TimeNghiBHXH,

			sum(case  
					  when h1.DATEHOLIDAY is not null then 0
					 when CodeLeave in ('CDR01','CDR03','CDR20') and DATEPART(dw,DateLeave) in ( 6,7) and h1.DATEHOLIDAY is null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=8 then 8
					 when CodeLeave in ('CDR01','CDR03','CDR20') and DATEPART(dw,DateLeave) in ( 2,3,4,5) and h1.DATEHOLIDAY is  null and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),TimeIn, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) -1) >=9 then 9
					 when CodeLeave in ('CDR01','CDR03','CDR20') and   Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=6 then 5
					 when  CodeLeave in ('CDR01','CDR03','CDR20') and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) ) >=5 then 4
				     when  CodeLeave in ('CDR01','CDR03','CDR20')  and  Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) )) <=4 then 
					 --Abs(DATEDIFF ( HOUR , CAST(CONVERT(VARCHAR(5),Timein, 108) AS datetime) , CAST(CONVERT(VARCHAR(5),TimeOut, 108) AS datetime) ) )
					   case when format(CAST(CONVERT(VARCHAR(5), timein, 108) AS datetime),'mm')  <= 30 
							 then cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime), 'HH') as int) + 
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5),SUBSTRING(timein,1,2)+':30',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 else   
							 cast(format(CAST(CONVERT(VARCHAR(5),timeout, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime), 'HH') as int)+
							 case when  cast(format(CAST(CONVERT(VARCHAR(5), timeout, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), cast(cast(SUBSTRING(timein,1,2) as int) +1 as nvarchar(2)) +':00',108) as datetime) ,'mm') as int) >=30 
							 then 0.5 else 0 end
							 end
				end) as TimeNghiDacBiet
			
	
			 
	from tbl_CheckPhep1 a left join Tbl_Holidaycalendar h1 on a.DateLeave =h1.DATEHOLIDAY where
	 Status='Y'
	--and EmpID='31811048' 
	group by EmpID,DateLeave
		 
	--CDR01
		  )

			, tbl_CheckOT as  (select 
		 a.EMPLOYEESID,
		 -- tang ca ngay chu nhat chinh thuc
		 sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and   @pToDate  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER between DATEADD(month, 1, c.StartWork) and   @pToDate  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		   --when c.POSITTION='Group Leader' and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and   @pToDate and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayChuNhatCT,
		 -- tang ca ngay chu nhat thu viec
		  sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		   --when c.POSITTION='Group Leader' and Shift in (N'NCN',N'Ngày') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayChuNhatTV,
		 -- tang ca dem chu nhat chinh thuc
		  sum(case when c.POSITTION in ('Staff','Team Leader','OP','Group Leader', 'Assistant Manager','Manager') and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER between  DATEADD(month, 2, c.StartWork) and  @pToDate  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			  when c.POSITTION in ('OP') and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER between  DATEADD(month, 1, c.StartWork) and  @pToDate and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		  -- when c.POSITTION='Group Leader' and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER between  DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemChuNhatCT,

		 -- tang ca dem chu nhat thu viec
		   sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 2, c.StartWork)  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		 --  when c.POSITTION='Group Leader' and Shift in (N'DCN',N'Đêm') and a.DATEREGISTER >= @pFromDate and a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemChuNhatTV,

		 --tang ca ngay le chinh thuc
		   sum(case when c.POSITTION in ('Staff','Team Leader','OP','Group Leader', 'Assistant Manager','Manager') and Shift in( N'Ngày',N'NCN') and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and @pToDate  and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift = N'Ngày'  and a.DATEREGISTER between DATEADD(month, 1, c.StartWork) and @pToDate  and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		  -- when c.POSITTION='Group Leader' and Shift = N'Ngày'  and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and @pToDate and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayLeCT,
		 -- tang ca ngay le thu viec
		 sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in( N'Ngày',N'NCN') and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift = N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		--   when c.POSITTION='Group Leader' and Shift = N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayLeTV,
		 --tang ca dem le chinh thuc
		   sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in ( N'Đêm' ,N'DCN') and a.DATEREGISTER between  DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift = N'Đêm' and a.DATEREGISTER between  DATEADD(month, 1, c.StartWork) and  @pToDate and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		 --  when c.POSITTION='Group Leader' and Shift = N'Đêm' and a.DATEREGISTER between  DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemLeCT,
		 -- tang ca dem le thu viec
		   sum(case when c.POSITTION in ('Staff','Team Leader','Group Leader', 'Assistant Manager','Manager') and Shift in ( N'Đêm' ,N'DCN') and a.DATEREGISTER >=  @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift = N'Đêm' and a.DATEREGISTER >=  @pFromDate and  a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		 --  when c.POSITTION='Group Leader' and Shift = N'Đêm' and a.DATEREGISTER >=  @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemLeTV,

		 --OT truoc 22H CT
		 --sum( case when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER > DATEADD(month, 1, c.StartWork) and  a.DATEREGISTER <= @pToDate and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and COALESCE(OTReal,0) > 0
			-- then COALESCE(a.OTBefore22H,0)
			-- when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER > DATEADD(month, 1, c.StartWork) and  a.DATEREGISTER <= @pToDate and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and COALESCE(OTReal,0) = 0.0
			-- then 
			--	 COALESCE(a.OTBefore22H,0) -( cast(format(CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
			--				case when  cast(format(CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) ,'mm') as int) >=30 
			--				then 0.5 else 0 end)

			--when  c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER > DATEADD(month, 1, c.StartWork) and  a.DATEREGISTER <= @pToDate and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) 	
			-- then COALESCE(a.OTBefore22H,0)
			--when c.POSITTION !='OP' and Shift=N'Ngày' and a.DATEREGISTER > DATEADD(month, 2, c.StartWork) and  a.DATEREGISTER <= @pToDate and NgayLamViec=N'Ngày thường' then COALESCE(OTBefore22H,0)
		     
		 -- end ) as  OTBefore22hCT,

		  sum( case 
			when  c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER between DATEADD(month, 1, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'	
			 then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0)
			when  c.POSITTION !='OP' and c.PARTCODE like '%shift%' and Shift=N'Ngày' and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'	
			 then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0)

			when c.POSITTION !='OP' and c.PARTCODE not like '%shift%' and Shift=N'Ngày' and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and  @pToDate
			and NgayLamViec=N'Ngày thường' then COALESCE(OTTruoc22H,0)
		     
		  end ) as  OTBefore22hCT,

		  --OT truoc 22H TV
		 -- 	 sum( case when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER between @pFromDate and DATEADD(month, 1, c.StartWork) and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and COALESCE(OTReal,0) > 0
			-- then COALESCE(a.OTBefore22H,0)
			-- when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER between @pFromDate and DATEADD(month, 1, c.StartWork) and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) and COALESCE(OTReal,0) = 0.0
			-- then 
			--	 COALESCE(a.OTBefore22H,0) -( cast(format(CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) - CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime),'HH') as int)+
			--				case when  cast(format(CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) -  CAST(CONVERT(VARCHAR(5), '20:00', 108) AS datetime) ,'mm') as int) >=30 
			--				then 0.5 else 0 end)
			-- when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER between @pFromDate and DATEADD(month, 1, c.StartWork) and NgayLamViec=N'Ngày thường'
			-- and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) < CAST(CONVERT(VARCHAR(5), '20:30', 108) AS datetime) 
			-- then COALESCE(a.OTBefore22H,0)
			--when c.POSITTION !='OP' and Shift=N'Ngày' and a.DATEREGISTER between @pFromDate and DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường' then COALESCE(OTBefore22H,0)
		     
		 -- end ) as  OTBefore22hTV

		  	 sum( case
			 when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec=N'Ngày thường'
			 then COALESCE(OTTruoc22H,0) + COALESCE(a.TOTALTIMEOVER,0)
			 when  c.POSITTION !='OP' and c.PARTCODE like '%shift%' and Shift=N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường'
			 then COALESCE(OTTruoc22H,0) + COALESCE(a.TOTALTIMEOVER,0)
			when c.POSITTION !='OP'  and c.PARTCODE not like '%shift%'   and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường' then COALESCE(OTTruoc22H,0)
		     
		  end ) as  OTBefore22hTV
		  --OT sau 22h CT
		   ,sum( case when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER between DATEADD(month, 1, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'
			     then COALESCE(b.OTSau22H,0)
					when c.POSITTION !='OP'    and Shift=N'Ngày' and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường' 
				then COALESCE(b.OTSau22H,0)
		  end ) as  OTAfter22hCT,
		  --OT sau 22h TV
		  	 sum( case when c.POSITTION='OP' and Shift=N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 1, c.StartWork) and NgayLamViec=N'Ngày thường'
			 --and CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '22:30', 108) AS datetime) 
			 then COALESCE(b.OTSau22H,0)
			when c.POSITTION !='OP' and Shift=N'Ngày' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường' then COALESCE(b.OTSau22H,0)
		     
		  end ) as  OTAfter22hTV
		  -- OT Dem thu viec
		  	 ,sum( case when c.POSITTION='OP'  and Shift=N'Đêm' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 1, c.StartWork)  and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)
					when c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and Shift=N'Đêm' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)
					when c.POSITTION !='OP' and c.PARTCODE not like '%shift%'  and Shift=N'Đêm' and a.DATEREGISTER >= @pFromDate and  a.DATEREGISTER < DATEADD(month, 2, c.StartWork) and NgayLamViec=N'Ngày thường'
			 then  COALESCE(b.OTTruoc22H,0)
				 end ) as  OTDemTV
		-- OT Dem Chinh thuc
		 ,sum( case 
			when c.POSITTION='OP' and Shift=N'Đêm' and a.DATEREGISTER between DATEADD(month, 1, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)

			 	when c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and Shift=N'Đêm' and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)
					when c.POSITTION !='OP' and c.PARTCODE not like '%shift%'  and Shift=N'Đêm' and a.DATEREGISTER between DATEADD(month, 2, c.StartWork) and  @pToDate and NgayLamViec=N'Ngày thường'
			 then  COALESCE(b.OTTruoc22H,0)
		  end ) as  OTDemCT



		 from tbl_ChamCong a left join tbl_OT b on a.EMPLOYEESID = b.EMP COLLATE DATABASE_DEFAULT and a.DATEREGISTER = b.DATEOT
		 left join Tbl_Employees c on a.EMPLOYEESID = c.EMPLOYEESID COLLATE DATABASE_DEFAULT
		 group by a.EMPLOYEESID)

		 , TinhThamNien as (
	select EMPLOYEESID,EMPLOYEESNAME, POSITTION
	,DATEDIFF(m,STARTWORK, @pfromdate) as ThangLamViec
	, case when POSITTION='OP' and DATEDIFF(m,STARTWORK, @pfromdate) >=12 and DATEDIFF(m,STARTWORK, @pfromdate) <36 then 100000
	      when POSITTION='OP' and  DATEDIFF(m,STARTWORK, @pfromdate) >=36 and DATEDIFF(m,STARTWORK, @pfromdate) <60 then 300000
		  when POSITTION='OP' and  DATEDIFF(m,STARTWORK, @pfromdate) >=60 and DATEDIFF(m,STARTWORK, @pfromdate) <84 then 500000
		  when POSITTION='OP' and  DATEDIFF(m,STARTWORK, @pfromdate) >=84 and DATEDIFF(m,STARTWORK, @pfromdate) <120 then 1000000
		  when POSITTION='OP' and  DATEDIFF(m,STARTWORK, @pfromdate) >=120 and DATEDIFF(m,STARTWORK, @pfromdate) <180 then 1500000
		  when POSITTION='OP' and DATEDIFF(m,STARTWORK, @pfromdate) >=180 and DATEDIFF(m,STARTWORK, @pfromdate) <240 then 2500000
		  when POSITTION='OP' and DATEDIFF(m,STARTWORK, @pfromdate) >=240 then 3500000 end as Seniority
	
	from Tbl_Employees where STATUSEMPLOYESS=1
)

--select * from tbl_ChamCong


select a.EMPLOYEESID,FULLNAME,c.POSITTION,DEPARTMENT,TypeEmployee,DATEREGISTER,DayinWeek,NgayLamViec, Shift,a.TIMEIN,a.TIMEOUT,starts,endtime,

		  (case
		       --Mr.Triêu(Mr.Dev) thêm trưởng hợp là 2 ngày này sẽ tính là 9 tiếng làm việc vi tháng này này làm bù
		       WHEN Shift = N'Ngày' AND NgayLamViec = N'Ngày thường' AND a.DATEREGISTER IN ('2026-04-11', '2026-04-25','2026-08-29') THEN 9 - COALESCE(e.TimeNghiPhep1, 0)
				when   Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' and (e.Status='N' or e.Status is null)  then COALESCE(worktimestand,0)
				when   Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' and ((e.TimeNghiPhep1  > COALESCE(worktimestand,0) and   e.Status='Y') or e.TimeNghiPhep1 is null) then COALESCE(worktimestand,0)
				when   Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' and e.Status='Y' and e.TimeNghiPhep1  < COALESCE(worktimestand,0) and DATEPART(dw,a.DATEREGISTER)  in (2,3,4,5) then  9-  COALESCE(e.TimeNghiPhep1,0)
				when   Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' and e.Status='Y' and e.TimeNghiPhep1  < COALESCE(worktimestand,0) and DATEPART(dw,a.DATEREGISTER)  in (6,7) then  8-  COALESCE(e.TimeNghiPhep1,0)
				when   Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' and e.Status='Y' and e.TimeNghiPhep1 =COALESCE(worktimestand,0) then  COALESCE(worktimestand,0)
		  end) as  CongCaNgay,
		 --cong ca dem
		
		    (case 
			 --Mr.Triêu(Mr.Dev) thêm trưởng hợp là 2 ngày này sẽ tính là 9 tiếng làm việc vi tháng này này làm bù
			WHEN Shift = N'Đêm' AND NgayLamViec = N'Ngày thường' AND a.DATEREGISTER IN ('2026-04-11', '2026-04-25','2026-08-29')   THEN 9 - COALESCE(e.TimeNghiPhep1, 0)
          
				when Shift=N'Đêm' and NgayLamViec=N'Ngày thường' and (e.Status='N' or e.Status is null)  then COALESCE(worktimestand,0)
				when Shift=N'Đêm' and NgayLamViec=N'Ngày thường' and e.Status='Y'  and ((e.TimeNghiPhep1  > COALESCE(worktimestand,0) and   e.Status='Y') or e.TimeNghiPhep1 is null)  then COALESCE(worktimestand,0)
				when  Shift=N'Đêm' and NgayLamViec=N'Ngày thường' and e.Status='Y' and e.TimeNghiPhep1  < COALESCE(worktimestand,0) and DATEPART(dw,a.DATEREGISTER)  in (2,3,4,5) then  9-  COALESCE(e.TimeNghiPhep1,0)
				when Shift=N'Đêm' and NgayLamViec=N'Ngày thường' and e.Status='Y' and e.TimeNghiPhep1  < COALESCE(worktimestand,0) and DATEPART(dw,a.DATEREGISTER)  in (6,7) then  8-  COALESCE(e.TimeNghiPhep1,0)
				when Shift=N'Đêm' and NgayLamViec=N'Ngày thường'and e.Status='Y'  and e.TimeNghiPhep1 = COALESCE(worktimestand,0) then COALESCE(worktimestand,0)
		 end) as  CongCaDem,


		 -- Triều cập nhật lại thời gian tăng ca cuối tuần với part leader
		 -- tang ca ngay chu nhat			-- 2026-06-22 Mr.Manh add POSITTION: Assistant Manager because dont count overtime hours
		  (case when c.POSITTION in ('Staff','Team Leader','Group Leader','Part Leader', 'Assistant Manager','Manager') and Shift in (N'NCN',N'Ngày')  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in (N'NCN',N'Ngày') and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		--   when c.POSITTION='Group Leader' and Shift in (N'NCN',N'Ngày') and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayChuNhat,

		 

		 -- tang ca dem chu nhat 
		   (case when c.POSITTION in ('Staff','Team Leader','Group Leader','Part Leader', 'Assistant Manager','Manager') and Shift in (N'DCN',N'Đêm') and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in (N'DCN',N'Đêm')  and NgayLamViec  =N'Ngày nghỉ'
			 then COALESCE(OTNgayNghi,0)
		--   when c.POSITTION='Group Leader' and Shift in (N'DCN',N'Đêm')  and NgayLamViec  =N'Ngày nghỉ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemChuNhat,

		 --tang ca ngay le
		  
		 (case when c.POSITTION in ('Staff','Team Leader','Group Leader','Part Leader', 'Assistant Manager','Manager') and Shift in( N'Ngày',N'NCN') and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in ( N'Ngày',N'NCN') and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		  -- when c.POSITTION='Group Leader' and Shift = N'Ngày' and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTNgayLe,
		 --tang ca dem le 
		   (case when c.POSITTION in ('Staff','Team Leader','Group Leader','Part Leader', 'Assistant Manager','Manager') and Shift in ( N'Đêm' ,N'DCN')  and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
			 when c.POSITTION in ('OP') and Shift in ( N'Đêm','DCN') and NgayLamViec  =N'Ngày lễ'
			 then COALESCE(OTNgayNghi,0)
		 --  when c.POSITTION='Group Leader' and Shift = N'Đêm'  and NgayLamViec  =N'Ngày lễ' then COALESCE(WorkTimeStand,0)
		 end) as OTDemLe,
		

		  ( case 
			when  c.POSITTION='OP' and Shift=N'Ngày' and NgayLamViec=N'Ngày thường'	
			 then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0)

			 when t6.DateJoin is not null and  CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
			and  ((t7.EmpID is not  null and  a.DATEREGISTER > t7.DateExpiry) or t7.EmpID is  null) 
			and  c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and NgayLamViec=N'Ngày thường'	and Shift=N'Ngày' 
			 then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0) -1

			 when t6.DateJoin is not null and  CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '18:00', 108) AS datetime) 
			and  (t7.EmpID is not  null and a.DATEREGISTER <= t7.DateExpiry) and c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and NgayLamViec=N'Ngày thường'	and Shift=N'Ngày'
			then  COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0) 

			when  c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and NgayLamViec=N'Ngày thường'	and Shift=N'Ngày'  
			and  t5.DateLearn is not null and  CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '19:00', 108) AS datetime)  
				and  (t7.EmpID is not  null and a.DATEREGISTER <= t7.DateExpiry)
				then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0) - 1.5
			when  c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and NgayLamViec=N'Ngày thường'	and Shift=N'Ngày'   
			and  t5.DateLearn is not null and  CAST(CONVERT(VARCHAR(5), a.TIMEOUT, 108) AS datetime) >= CAST(CONVERT(VARCHAR(5), '19:00', 108) AS datetime)  
				and  ((t7.EmpID is not  null and a.DATEREGISTER > t7.DateExpiry) or t7.EmpID is  null)
				then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0) -0.5

			when  c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and NgayLamViec=N'Ngày thường'	and Shift=N'Ngày' and  t6.DateJoin is null and   t5.DateLearn is  null
			 then COALESCE(OTTruoc22H,0) +  COALESCE(a.TOTALTIMEOVER,0) 


			when c.POSITTION !='OP' and c.PARTCODE not like '%shift%' and Shift=N'Ngày' and COALESCE(OTTruoc22H,0) <9
			and NgayLamViec=N'Ngày thường' then COALESCE(OTTruoc22H,0)
		     
		  end ) as  OTBefore22h,



		  --OT sau 22h CT
		   ( case when c.POSITTION='OP' and Shift=N'Ngày'  and NgayLamViec=N'Ngày thường'
			     then COALESCE(b.OTSau22H,0)
					when c.POSITTION !='OP'    and Shift=N'Ngày'  and NgayLamViec=N'Ngày thường' 
				then COALESCE(b.OTSau22H,0)
		  end ) as  OTAfter22h,
		  
		 
		-- OT Dem Chinh thuc
		 ( case 
			when c.POSITTION='OP' and Shift=N'Đêm'  and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)

			 	when c.POSITTION !='OP' and c.PARTCODE like '%shift%'  and Shift=N'Đêm' and NgayLamViec=N'Ngày thường'
			 then COALESCE(a.TOTALTIMEOVER,0) + COALESCE(b.OTTruoc22H,0)
					when c.POSITTION !='OP' and c.PARTCODE not like '%shift%'  and Shift=N'Đêm'  and NgayLamViec=N'Ngày thường'
			 then  COALESCE(b.OTTruoc22H,0)
		  end ) as  OTDem,a.Statuss,
		    aa.TimeNghiPhep, 
		  aa.TimeNghiBHXH,
		  aa.TimeNghiDacBiet,
		  aa.TimeNghiKhamThai,
		  aa.TimeNghiKhongLuong,
		  e.TimeIn as NghiTuGio,
		  e.TimeOut as NghiToiGio


from tbl_ChamCong a left join tbl_OT b on a.EMPLOYEESID = b.EMP COLLATE DATABASE_DEFAULT and a.DATEREGISTER = b.DATEOT
left join Tbl_Employees c on a.EMPLOYEESID = c.EMPLOYEESID COLLATE DATABASE_DEFAULT
	left join tbl_CheckPhep1 e on a.EMPLOYEESID = e.EmpID COLLATE DATABASE_DEFAULT and  a.DATEREGISTER = e.DateLeave
	left join tbl_CheckPhep aa on a.EMPLOYEESID = aa.EmpID  COLLATE DATABASE_DEFAULT and a.DATEREGISTER = aa.DateLeave
	 left join Tbl_VinaAcademy t6 on a.DATEREGISTER =t6.DateJoin and a.EMPLOYEESID = t6.EmpNo  COLLATE DATABASE_DEFAULT
		 left join Tbl_LearnLanguage t5 on a.DATEREGISTER =t5.DateLearn and a.EMPLOYEESID =t5.EmpNo  COLLATE DATABASE_DEFAULT
		 left join Tbl_ChildMode t7 on a.DATEREGISTER =t7.DateExpiry and a.EMPLOYEESID = t7.EmpID  COLLATE DATABASE_DEFAULT
 where 1=1
 AND (@EmpName ='' or c.EMPLOYEESNAME like '%'+@EmpName+'%')
			 AND (@Depart ='' or c.DEPARTMENTNAME=@Depart)
			  AND (@TypeEmployee='' or (@TypeEmployee=N'Thời vụ' and substring(c.EMPLOYEESID,1,1) = 8) or (@TypeEmployee=N'Chính thức' and substring(c.EMPLOYEESID,1,1) != 8) )
order by  a.EMPLOYEESID, a.DATEREGISTER desc



drop table #temp_leave
drop table #tempfinger

END




--42208001
