
-- =============================================
-- Author: Mr.Tung(nguyentung@vina.co.kr)
-- Create date: 2022-05-07
-- Browsable : true
-- ============================================= usp_Vietnam_MTBF_Andon_get '',''        
CREATE PROCEDURE [dbo].[usp_Vietnam_MTBF_Andon_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pYear Date = NULL,
		@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	return;

	set @pFromDate = case when isnull(@pFromDate,'')='' then dateadd(day,-180,getdate()) else @pFromDate end
	set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00'           		
	

	
;with linedat as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status, ls.statusApp, ls.statusEmail, ls.createdatetime, ls.createuserid     
      from stb_linesituation_vvt ls with(nolock) 
	  left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 
      where   (statusApp>2 )
     and (statusEmail is null or statusEmail<1000)
	and ls.createdatetime between @FromDate and @ToDate
	 
    )
  ,
  beginlineid as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status,  ls.statusEmail, ls.createdatetime, ls.createuserid--,'near' as val
      
       from stb_linesituation_vvt ls with(nolock) 
	   left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 	

      where   ls.createdatetime between @FromDate and @ToDate
	  and (statusEmail is null or statusEmail<1000)
	  and status=1
       
	  and (statusApp<2)
       
    )
  ,
 combinedat as (
    select 
	beginlineid.companycode as companycode,
	beginlineid.linecode as linecode,
	beginlineid.LineName as LineName,
	beginlineid.LineType as LineType,
	beginlineid.routecode as routecode,
	beginlineid.routename as routename,

    beginlineid.id  as _id,
	linedat.statusApp,
    beginlineid.errorcode as _errorcode,
    beginlineid.errorname as _errorname,
    beginlineid.status as _status,    
	convert(varchar(23),dateadd(hour,-2,beginlineid.createdatetime),120) as beginOccur,

	case when beginlineid.createuserid is null and  linedat.id is null then '~updat31f~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^updat31f^'
		else convert(varchar(23),dateadd(hour,-2,isnull(beginlineid.createuserid,beginlineid.createdatetime)),120) end as beginFix1,

	case when beginlineid.createuserid is null and  linedat.id is null then null
		else convert(varchar(23),dateadd(hour,-2,isnull(beginlineid.createuserid,beginlineid.createdatetime)),120) end as beginFix2,

		 '~deletf31~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^deletf31^' as delf,
	  case when linedat.id is null then 'NG' else 'OK' end as status,

	linedat.id,
	linedat.errorcode,
	linedat.errorname,

    (case when  linedat.id is null
		  then ( '~insert31~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^insert31^' ) 
		  else convert(varchar(23),dateadd(hour,-2,linedat.createdatetime),120) end)  as finishTime1,

      (case when  linedat.id is null		  then null
		  else convert(varchar(23),dateadd(hour,-2,linedat.createdatetime),120) end)  as finishTime2,
  
    (case when   linedat.id is null
		  then ( '~insert31f~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^insert31f^' ) 
		  else convert(varchar(23),dateadd(hour,-2,linedat.createuserid),120) end)  as finishFix1,

    (case when   linedat.id is null		  then null
		  else convert(varchar(23),dateadd(hour,-2,linedat.createuserid),120) end)  as finishFix2,
		  
		    '~delet31~'+convert(varchar(10),isnull(linedat.id,-1))+'^delet31^' as del,
	dateadd(hour,-2,getdate()) as getdate1

	    from beginlineid 
    left outer join linedat  on (beginlineid.id=linedat.statusApp or beginlineid.id is not null and linedat.id is null) 
  ) 
  , lastdata as ( select 
  --companycode, 
  LineCode, LineName, LineType, routecode, routename, 
  _id,-- statusApp, 
  _errorcode, _errorname, --_status, 
  beginOccur,  beginFix1 as beginFix, 
  delf, -- 
  id, errorcode as endcode,status,-- errorname, 
   
  finishTime1 as finishTime,
  finishFix1 as finishFix,    
   del,
   getdate1,
  case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end DuringOP
 
 ,case when isnull(DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1) ),0)=0 
		then ((case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)) 
		else DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1)  ) end DuringFix

  from combinedat
  where (case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)<=0 then 1 
		else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)<24*60*3
  )
  ,
  mttr as (
  select 
  --companycode,	
  LineCode,	LineName,	LineType,	--routecode,	routename,	_id	,_errorcode	,_errorname,	
  convert(varchar(19),dateadd(hour,-2,beginOccur),120) as beginOccur,	
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

-- case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime,getdate1)) end DuringOP
 --,case when isnull(DATEDIFF(MINUTE, beginFix, isnull(finishFix,getdate1) ),0)=0 then 1 else DATEDIFF(MINUTE, beginFix, isnull(finishFix,getdate1)  ) end DuringFix
  isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime,getdate1)  ),1)DuringOP
  , isnull(DATEDIFF(MINUTE, beginFix, isnull(finishFix,getdate1) ),1)DuringFix
  
  from lastdata
  --where 
  --order by isnull(_id,id) desc, CompanyCode, linetype,LineCode,routename 
  )
  ,
  mttrday as (
	select linecode,sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
				(case  when   (DATEPART(HOUR, beginOccur)>10)     or    
					(DATEPART(HOUR, beginOccur)=10 and DATEPART(MINUTE, beginOccur)>0)     
				then     convert(varchar(10),beginOccur,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  beginOccur),120)       
				end 
				)     as daily ,count(*) as counte
	  from mttr
	  group by linecode,(case  when   (DATEPART(HOUR, beginOccur)>10)     or    
					(DATEPART(HOUR, beginOccur)=10 and DATEPART(MINUTE, beginOccur)>0)     
				then     convert(varchar(10),beginOccur,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  beginOccur),120)       
				end 
				) 
  )
    ,
  mttrweek as (
  
	select linecode,sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
				datepart(week, beginOccur)    as weekly ,count(*) as counte
	  from mttr
	  group by linecode,datepart(week, beginOccur) 
  )
      ,
  mttrmonth as (
  
	select linecode,sum(DuringOP) DuringOP,sum(DuringFix) DuringFix, 
				datepart(MONTH, beginOccur)    as monthly ,count(*) as counte
	  from mttr
	  group by linecode,datepart(MONTH, beginOccur) 
  )
  ,
  mttrtotal as (
  select linecode,DAILY,NULL WEEKLY,NULL MONTHLY,DuringOP as DuringOP_minutes,DuringFix as DuringFix_minutes, counte,case when 24*60-DuringOP<0 then 0 else round((24*60-DuringOP)/counte/60.0,2) end as MTBF_hours
  from mttrday
  union 
    select linecode,NULL DAILY,WEEKLY,NULL MONTHLY,DuringOP as DuringOP_minutes,DuringFix as DuringFix_minutes, counte,case when 24*60*7-DuringOP<0 then 0 else round((24*60*7-DuringOP)/counte/60.0,2) end as MTBF_hours
  from mttrweek
    union 
    select linecode,NULL DAILY,NULL WEEKLY,MONTHLY,DuringOP as DuringOP_minutes,DuringFix as DuringFix_minutes, counte,case when 24*60*30-DuringOP<0 then 0 else round((24*60*30-DuringOP)/counte/60.0,2) end as MTBF_hours
  from mttrmonth
  )
  select li.LineName,li.LineDesc,li.LineType,mttrtotal.* from mttrtotal
  left outer join STB_LineInfo li with(nolock) on mttrtotal.linecode = li.LineCode
 order by monthly,weekly,daily,linecode
 END
