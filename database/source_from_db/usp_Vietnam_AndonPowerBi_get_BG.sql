-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Vietnam_AndonPowerBi_get_BG
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL	
AS
BEGIN

SET NOCOUNT ON;

	set @pFromDate = case when isnull(@pFromDate,'')='' then  dateadd(day,-180,getdate())  else @pFromDate end
	set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00'           		
	



;with linedat as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status, ls.statusApp, ls.statusEmail, ls.createdatetime, ls.createuserid     
      from stb_linesituation_vvt ls with(nolock) 
	  left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 
      where   (statusApp>2  and (statusEmail is null or statusEmail<1000))
     
	and ls.createdatetime between @FromDate and @ToDate
	and ls.linename like '%BG%'
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
      and ls.linename like '%BG%'
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

	case when beginlineid.createuserid is null and  linedat.id is null then null
		else convert(varchar(23),dateadd(hour,-2,isnull(beginlineid.createuserid,beginlineid.createdatetime)),120) end as beginFix1,

	case when beginlineid.createuserid is null and  linedat.id is null then null
		else convert(varchar(23),dateadd(hour,-2,isnull(beginlineid.createuserid,beginlineid.createdatetime)),120) end as beginFix2,

		-- '~deletf31~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^deletf31^' as delf,
	  case when linedat.id is null then 'NG' else 'OK' end as status,

	linedat.id,
	linedat.errorcode,
	linedat.errorname,

    (case when  linedat.id is null
		  then null 
		  else convert(varchar(23),dateadd(hour,-2,linedat.createdatetime),120) end)  as finishTime1,

      (case when  linedat.id is null		  then null
		  else convert(varchar(23),dateadd(hour,-2,linedat.createdatetime),120) end)  as finishTime2,
  
    (case when   linedat.id is null
		  then null 
		  else convert(varchar(23),dateadd(hour,-2,linedat.createuserid),120) end)  as finishFix1,

    (case when   linedat.id is null		  then null
		  else convert(varchar(23),dateadd(hour,-2,linedat.createuserid),120) end)  as finishFix2,
		  
		    --'~delet31~'+convert(varchar(10),isnull(linedat.id,-1))+'^delet31^' as del,
	dateadd(hour,-2,getdate()) as getdate1

	    from beginlineid 
    left outer join linedat  on (beginlineid.id=linedat.statusApp or beginlineid.id is not null and linedat.id is null) 
  ) 
  select 
  --companycode, 
  LineCode, LineName, LineType, routecode, routename, 
 -- _id,-- statusApp, 
  _errorcode, _errorname, --_status, 
  beginOccur,  beginFix1 as beginFix, 
 -- delf, -- 
  --id, 
  errorcode as endcode,status,-- errorname, 
   
  finishTime1 as finishTime,
  finishFix1 as finishFix,    
  -- del,

  case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end DuringOP
 
 ,case when isnull(DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1) ),0)=0 
		then ((case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)) 
		else DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1)  ) end DuringFix

  from combinedat
  where (case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)<=0 then 1 
		else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)<24*60
  order by _id desc , CompanyCode, linetype,LineCode,routename 
  

END
