
-- =============================================
-- Author: Mr.Tung(nguyentung@vina.co.kr)
-- Create date: 2022-05-07
-- Browsable : true
-- ============================================= usp_Vietnam_MTBF_Andon_get '','','2022-02-28'          usp_DoProcessDefectRepairInfoByBarcode_SmartApp
CREATE PROCEDURE [dbo].[usp_Vietnam_MTBF_Andon_get_OLD]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pYear Date = NULL,
			@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	return;

	declare @YEAH varchar(4)= '';
	if(@pYear is null or @pYear='') 
	 begin
	 select @YEAH=DATEPART(year,getdate())
	 select @pYear = convert(date,getdate(),120) ;
	 end
	else select @YEAH=DATEPART(year,@pYear)


			set @pFromDate = case when isnull(@pFromDate,'')='' then '2022-06-01 10:00:00' else @pFromDate end
	set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00'  

 ;with linedat as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status, ls.statusApp, ls.statusEmail, ls.createdatetime, ls.createuserid --,'lastest' as val
      from stb_lineinfo li with(nolock) 
      left outer join stb_linesituation_vvt ls with(nolock) on li.LineCode=ls.Linecode 
      where id  in ( 
          select  max(id) 
          from stb_linesituation_vvt  with(nolock) 
          --where errorname is null or errorname <>strEmpty and lower(errorname) not like 'normal%'
          group by linecode,routename,errorname
      )
	 -- and DATEPART(YEAR,ls.createdatetime) = @YEAH
	  and (statusApp>1 )
       	and ls.createdatetime > @FromDate --and @ToDate
	--and ls.createdatetime <= convert(varchar(10),dateadd(day,1,@pYear),120) + ' 08:00:00'
	  --and id=754
	  --and status=0
      --and  isused=1 
            and (substring(li.LineType,1,4) in ( 'Auto' , 'Manu') or substring(li.linename,1,3) in ('Dry' , '베트남' , 'Mod')  )
			--and errorname is not null
      /*or companycode='VNT' */
      --order by li.CompanyCode,li.LineType ,li.LineCode,CreateDateTime desc
    )
  ,
  beginlineid as (
    select li.companycode,ls.LineCode,ls.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status, ls.statusApp, ls.statusEmail, ls.createdatetime, ls.createuserid--,'near' as val
      
       from stb_linesituation_vvt ls with(nolock) 
	   left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 	

      where ls.id  in ( 
          select  max(lv.id) 
          from stb_linesituation_vvt lv with(nolock)
			left outer join linedat on linedat.LineCode=lv.linecode
		 and (linedat.id> lv.id or linedat.id is null) and (linedat.routename=lv.routename or linedat.routename is null) --and linedat.statusApp = lv.id
		 and (linedat.errorname=lv.errorname or linedat.errorname is null)
		 and (lv.status=1 )
          --where errorname is null or errorname <>strEmpty and lower(errorname) not like 'normal%'
          group by lv.linecode,lv.routename,lv.errorname
      )
	--  and DATEPART(YEAR,ls.createdatetime) = @YEAH
       	and ls.createdatetime > @FromDate --and @ToDate
	--and ls.createdatetime <= convert(varchar(10),dateadd(day,1,@pYear),120) + ' 08:00:00'
	  --and id=754
	  --and status=0
      --and  isused=1 
            and (substring(li.LineType,1,4) in ( 'Auto' , 'Manu') or substring(li.linename,1,3) in ('Dry' , '베트남' , 'Mod')  )
	  and (statusApp<2)
    
	  --and ls.errorname<>'Normal' and ls.errorname<>''
    --and errorname is not null
    )
  ,
  combinedat as (
    select --linedat.*,	
	isnull(linedat.companycode,beginlineid.companycode) as companycode,
	isnull(linedat.linecode,beginlineid.linecode) as linecode,
	isnull(linedat.LineName,beginlineid.LineName) as LineName,
	isnull(linedat.LineType,beginlineid.LineType) as LineType,
	isnull(linedat.routecode,beginlineid.routecode) as routecode,
	isnull(linedat.routename,beginlineid.routename) as routename,
	linedat.id,
	linedat.errorcode,
	linedat.errorname,
	linedat.createdatetime,
	linedat.createuserid,

    case when beginlineid.id is null then (case when linedat.statusApp>1 then linedat.statusApp else null end) else beginlineid.id end as _id,

    isnull(beginlineid.errorcode, (select errorcode from stb_linesituation_vvt  with(nolock) where id = isnull(beginlineid.id,linedat.statusApp) ) ) 
	 as _errorcode,

    isnull(beginlineid.errorname,(select errorname from stb_linesituation_vvt with(nolock)  where id = isnull(beginlineid.id,linedat.statusApp)) )
	 as _errorname,

    isnull(beginlineid.status,(select status from stb_linesituation_vvt  with(nolock) where id = isnull(beginlineid.id,linedat.statusApp) ) ) 
	 as _status,

    isnull(beginlineid.createdatetime, (select createdatetime from stb_linesituation_vvt  with(nolock) where id = isnull(beginlineid.id,linedat.statusApp) ) ) 
	 as beginOccur,

    isnull(beginlineid.createuserid, (select createuserid from stb_linesituation_vvt  with(nolock) where id = isnull(beginlineid.id,linedat.statusApp)) ) as beginFix
	,beginlineid.createuserid as beginFix1

    from linedat 
    full outer join beginlineid 
    on linedat.linecode = beginlineid.linecode 
    --and linedat.LineName = beginlineid.LineName
    and linedat.routename = beginlineid.routename
	and (beginlineid.id=linedat.statusApp /*or linedat.id is null or  beginlineid.id is null*/)
	and linedat.id>beginlineid.id
	and beginlineid.id is not null
      --and 
    /*or companycode='VNT' */
      --order by CompanyCode,LineType ,LineCode,CreateDateTime desc
    --order by linedat.status, linecode,routecode
  )
  ,
  lastdata as (
  select 
  companycode,LineCode,LineName,LineType,routecode,routename,  _id,_errorcode,_errorname,
  
  --isnull(convert(varchar(38),beginOccur,120),'~updat31~'+convert(varchar(10),isnull(_id,-1))+'^updat31^') as 
  beginOccur, 
  --case when _status=1 then isnull(convert(varchar(38),beginFix,120),'~updat31f~'+convert(varchar(10),isnull(_id,id))+'^updat31f^') else 
		--					isnull(convert(varchar(38),beginOccur,120),'~updat31f~'+convert(varchar(10),isnull(_id,-1))+'^updat31f^')
  -- end as beginFix,
   --isnull(convert(varchar(38),beginOccur,120),'~updat31~'+convert(varchar(10),isnull(_id,-1))+'^updat31^') as 
   convert(varchar(38),isnull(beginFix,beginOccur),120) as beginFix,
   beginFix1,
  --case when _status=1  then 'NG' else 'OK' end as _status,
  --status,
  --_status,
  --case when _id is null then null else id end as 
   id
  ,case when _id is null then null else errorcode end as endcode
  ,case when _id is null then null else errorname end  as enderrorname
  --,case when _id is null then null else (case when status=1  then 'NG' else 'OK' end ) end  as endstatus
  --,case when _id is null then null else statusApp end  as statusApp
  --,case when _id is null then null else statusEmail end  as statusEmail
  ,case when _id is not null then convert(varchar(38),isnull(createdatetime,createuserid),120)  else null end   as finishTime
  
  ,case when _id is not null then convert(varchar(38),isnull(createuserid,createdatetime),120) else null end as finishFix
  
 -- ,case when isnull(DATEDIFF(MINUTE, beginOccur, createdatetime),0)=0 then '' else DATEDIFF(MINUTE, beginOccur, createdatetime) end DuringOP
 -- ,case when isnull(DATEDIFF(MINUTE, beginFix, createuserid),0)=0 then '' else DATEDIFF(MINUTE, beginFix, createuserid) end DuringFix
  from combinedat 
  where (_errorname)<>'Normal' and len(_errorname)>0 -- _status=1   
  --and LineCode is not null
  )
  ,
  mttr as (
  select 
  --companycode,	
  LineCode,	--LineName,	LineType,	--routecode,	routename,	_id	,_errorcode	,_errorname,	
  --convert(varchar(19),dateadd(hour,-2,beginOccur),120)
  (case  when   (DATEPART(HOUR, beginOccur)>10)      
				then     convert(varchar(10),beginOccur,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  beginOccur),120)       
				end 
				)     
				as daily,	
datepart(week, beginOccur)    as weekly,
datepart(month, beginOccur)    as monthly,
  dateadd(hour,-2,beginOccur) as beginTimeErr     --,

  ----convert(varchar(19),dateadd(hour,-2,convert(datetime,beginFix)),120) as beginFix,	
  --case when  finishTime is null and finishFix is null  and beginFix1 is null then '~updat31~'+convert(varchar(10),isnull(_id,-1))+'^updat31^'
  --else convert(varchar(19),dateadd(hour,-2,beginFix),120) end
  --as beginFix,
 -- --status,	_status,	
 -- id,	endcode,	--enderrorname,	

 -- case when id is null then 'NG' else 'OK' end as status,
 -- --isnull(convert(varchar(38),beginOccur,120),'~updat31~'+convert(varchar(10),isnull(_id,-1))+'^updat31^') as beginOccur, 
 -- -- isnull(convert(varchar(38),beginFix,120),'~updat31~'+convert(varchar(10),isnull(_id,-1))+'^updat31^') as beginFix,
  

 --         (case when finishTime is null and finishFix is null 
 -- then ( '~insert31~'+convert(varchar(10),isnull(_id,-1))+'^insert31^' ) 
 -- else convert(varchar(38),dateadd(hour,-2,finishTime),120) end)  as finishTime
  
 -- ,(case when  finishTime is null and finishFix is null
 -- then ( '~insert31f~'+convert(varchar(10),isnull(_id,-1))+'^insert31f^' ) 
 -- else convert(varchar(38),dateadd(hour,-2,finishFix),120) end)  as finishFix,
 -- --case when id is null then '~insert31~'+convert(varchar(10),isnull(_id,-1))+'^insert31^' else finishTime end finishTime1,	
 -- --case when id is null then '~insert31f~'+convert(varchar(10),isnull(_id,-1))+'^insert31f^' else finishFix end finishFix1,	
 ---- DuringOP,
 ---- DuringFix,

 --case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime,getdate())  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime,getdate())) end DuringOP
 --,case when isnull(DATEDIFF(MINUTE, beginFix, isnull(finishFix,getdate()) ),0)=0 then 1 else DATEDIFF(MINUTE, beginFix, isnull(finishFix,getdate())  ) end DuringFix
  
  from lastdata

  --where 
  --order by isnull(_id,id) desc, CompanyCode, linetype,LineCode,routename 
  ) 
 -- , 
 -- mttrday as ( 
	--select linecode, beginTimeErr ,--sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
	--			(case  when   (DATEPART(HOUR, beginOccur)>10)      
	--			then     convert(varchar(10),beginOccur,120)    
	--			else    convert(varchar(10),DATEADD(DAY, -1,  beginOccur),120)       
	--			end 
	--			)     as daily --, count(*) as counte 
	--  from mttr 
	--  --group by linecode,(case  when   (DATEPART(HOUR, beginOccur)>10)     
	--		--	then     convert(varchar(10),beginOccur,120)    
	--		--	else    convert(varchar(10),DATEADD(DAY, -1,  beginOccur),120)       
	--		--	end 
	--		--	) 
 -- ) 

  ,
  mttrday as (
		select mttr.linecode,mttr.daily , --md2.beginTimeErr as secondtime , 
		DATEDIFF(MINUTE,mttr.beginTimeErr,md2.beginTimeErr) as begin1
		from mttr 
		cross apply ( 
			select top 1 * from mttr md1 where md1.linecode=mttr.linecode and md1.daily=mttr.daily and mttr.beginTimeErr<md1.beginTimeErr 
			order by md1.beginTimeErr 
		)md2 
  ) 
  ------,
  ------mttrweek as (
		------select mttr.linecode,mttr.weekly , --md2.beginTimeErr as secondtime , 
		------DATEDIFF(MINUTE,mttr.beginTimeErr,md2.beginTimeErr) as begin1
		------from mttr 
		------cross apply ( 
		------	select top 1 * from mttr md1 where md1.linecode=mttr.linecode and md1.weekly=mttr.weekly and mttr.beginTimeErr<md1.beginTimeErr 
		------	order by md1.beginTimeErr 
		------)md2 
  ------) 
  ------,
  ------mttrmonth as (
		------select mttr.linecode,mttr.monthly , --md2.beginTimeErr as secondtime , 
		------DATEDIFF(MINUTE,mttr.beginTimeErr,md2.beginTimeErr) as begin1
		------from mttr 
		------cross apply ( 
		------	select top 1 * from mttr md1 where md1.linecode=mttr.linecode and md1.monthly=mttr.monthly and mttr.beginTimeErr<md1.beginTimeErr 
		------	order by md1.beginTimeErr 
		------)md2 
  ------) 
 --   ,
 -- mttrweek as (
  
	--select linecode,sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
	--			datepart(week, beginOccur)    as weekly ,count(*) as counte
	--  from mttr
	--  group by linecode,datepart(week, beginOccur) 
 -- )
 --     ,
 -- mttrmonth as (
  
	--select linecode,sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
	--			datepart(MONTH, beginOccur)    as monthly ,count(*) as counte
	--  from mttr
	--  group by linecode,datepart(MONTH, beginOccur) 
 -- )

  ,
  mttrtotal as (

  select mtd.linecode,MTD.DAILY , NULL WEEKLY, NULL MONTHLY, 24*60-sum(begin1) as BetweenOccur_Minutes ,count(mtd.daily)  as counte
  from mttrday mtd
  --join  mttr on mttr.linecode = mtd.linecode and mttr.daily = mtd.daily
  group by mtd.linecode,mtd.daily 
  having count(mtd.daily)>1
  ------union
  ------  select mtd.linecode,NULL DAILY ,  MTD.WEEKLY, NULL MONTHLY, sum(begin1) as BetweenOccur_Minutes , count(mtd.weekly) as counte
  ------from mttrweek mtd
  --------join  mttr on mttr.linecode = mtd.linecode and mttr.weekly = mtd.weekly
  ------group by mtd.linecode,mtd.weekly 
  ------having count(mtd.weekly)>1
  ------union
  ------  select mtd.linecode,NULL DAILY , NULL WEEKLY,  MTD.MONTHLY, sum(begin1) as BetweenOccur_Minutes , count(mtd.monthly) as counte
  ------from mttrmonth mtd
  --------join  mttr on mttr.linecode = mtd.linecode and mttr.monthly = mtd.monthly
  ------group by mtd.linecode,mtd.monthly 
  ------having count(mtd.monthly)>1

  --union 
  --  select linecode,NULL DAILY,WEEKLY,NULL MONTHLY,DuringOP as DuringOP_minutes,DuringFix as DuringFix_minutes, counte,round(DuringOP/counte/60.0,2) as MTTR_hours
  --from mttrweek
  --  union 
  --  select linecode,NULL DAILY,NULL WEEKLY,MONTHLY,DuringOP as DuringOP_minutes,DuringFix as DuringFix_minutes, counte,round(DuringOP/counte/60.0,2) as MTTR_hours
  --from mttrmonth
  )
  select li.LineName,li.LineDesc,li.LineType,mttrtotal.*,round(BetweenOccur_Minutes/(counte*60.0),2) as MTBF_hours from mttrtotal
  left outer join STB_LineInfo li with(nolock) on mttrtotal.linecode = li.LineCode
 --order by daily,WEEKLY,MONTHLY,linecode
 
 END


 --select*from stb_electrodemixinfo
 --where ElectrodeLotNumber='VVMN3012001E21'

--  select*from STB_ElectrodeCoatingInfo
-- where ElectrodeLotNumber='VVMN3012001E21'


-- select * from STB_ElectrodeMixInfo where ElectrodeLotNumber='VVMN3012001E21' and ViscosityValue>0

-- MixingTemperature
--14.50000