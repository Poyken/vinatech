
-- =============================================
-- Author: Mr.Duy
-- Create date: 2024-02-26
-- Browsable : true
-- =============================================exec [usp_Vietnam_AndonDetail_get_BG] '2024-04-01','2024-04-08','adon'    
CREATE PROCEDURE [dbo].[usp_Vietnam_AndonDetail_get_BG]
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL,
						@pFromGUI varchar(10)=null
				
as
BEGIN 
 
SET NOCOUNT ON;

	set @pFromDate = case when isnull(@pFromDate,'')='' then dateadd(day,-60,getdate()) else @pFromDate end
	set @pToDate = case when isnull(@pToDate,'')='' then getdate() else @pToDate end

	DECLARE @FromDate   VARCHAR(19)  = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                            
	DECLARE @ToDate     VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate )), 120) + ' 10:00:00'           		
	

	BEGIN TRY  
	   	
		


			;with remain as (
				select min(id) as id1,linecode,errorcode, convert(varchar(15),createdatetime,120) as dat, count(*) as coun
				from stb_linesituation_vvt
				where  createdatetime> dateadd(month,-2,getdate()) and statusApp in (0,1)
				group by linecode,errorcode, convert(varchar(15),createdatetime,120)
				having count(*)>1
			)
			, removed as (	select ls.id from  stb_linesituation_vvt ls
				join remain on ls.linecode=remain.linecode and ls.errorcode=remain.errorcode and ls.id>remain.id1
			)
			update stb_linesituation_vvt 
			set status=null,statusApp=2
			where id in (select id from removed) and   statusApp in (0,1)


			update stb_linesituation_vvt
			set [status]=null,statusApp=case when statusApp is null then null else  (-1*statusApp)  end
			where statusApp >2 and (lower(errorname) like N'%test%' or lower(errorcode) like N'%test%' 
			or lower(errorname) like N'%bao nham%' or lower(errorcode) like N'%báo nhầm%' )
									   

			update stb_linesituation_vvt
			set statusApp=case when statusApp is null then null else (-1*statusApp) end
			where [status] is null and statusApp>2
				

			update stb_linesituation_vvt
			set routecode = case when        routename='WINDING-권취'				then  'V-22_BG'
								 when		 routename='BEADING-비딩'				then  'V-23_BG'
								 when		 routename='CURLING-커링'				then  'V-24_BG'
								 when		 routename='SLEEVE-슬리브'				then  'V-25_BG'
								 when		 routename='AGING-에이징'				then  'V-26_BG'
								 when		 routename='VISUAL-외관'					then  'V-27_BG'
								 when		 routename='PACKING-포장'				then  'V-28_BG'
								 when		 routename='BENDING-벤딩'				then  'V-33_BG'
								 else		 '.'						end
			where routecode is null or routecode=''


			;with duplica as (
				select statusApp from stb_linesituation_vvt
				where  createdatetime>'2022-06-20'  and statusApp>2
				group by statusApp
			)
			,goodfromdup as (
				select statusApp,min(id) as goodid
				from stb_linesituation_vvt
				where statusApp in (
									select statusApp from duplica
									)
				and len(errorcode)>5
				group by statusApp
			)
			,alldup as (
				select id from stb_linesituation_vvt where statusApp in (select statusApp from duplica)
			)
			update stb_linesituation_vvt 
			set statusApp = (case when statusApp is null then null else   (-1*statusApp)  end) , [status]=null
			where id in (select id from alldup except select goodid from goodfromdup) and statusApp>2
			



			update stb_linesituation_vvt
			set createuserid=convert(varchar(19),convert(datetime,createuserid),120)
			where createuserid is not null and (createuserid not like '%-%' or createuserid like '%AM%' or createuserid like '%PM%')

	END TRY  
	BEGIN CATCH  

		 	update stb_linesituation_vvt
			set createuserid=convert(varchar(19),createdatetime,120)
			where createuserid is not null and (createuserid not like '%-%' or createuserid like '%AM%' or createuserid like '%PM%')

	END CATCH  




	if(@pFromGUI is not null and @pFromGUI<>'') begin
	   select 
            
				ls.LineCode , isnull(li.LineName,ls.LineName) LineName, 
				li.LineType, 
				ls.routecode, 
				ls.routename , 

				replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=2),'-Comment:','') 'Detector',
				replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=3),'-Comment:','') 'Operator',
				ls.errorname , 
				replace((select Item from dbo.fnSplitToTable('~~',ls.errorcode) where RowNo=1),'-Comment:','') 'Descibe', 

							convert(varchar(19),ls.createdatetime,120) as 'beginOccur', 
				isnull(ls.createuserid,convert(varchar(19),ls.createdatetime,120)) as 'beginFix',

				(select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=1) 'Reason',
				(select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=2) 'Countermeasure',
				(select Item from dbo.fnSplitToTable('~~',tbend.errorcode) where RowNo=3) 'Fixer',
				 convert(varchar(19),tbend.createdatetime,120) as 'FinishTime', 
				 isnull(tbend.createuserid,convert(varchar(19),tbend.createdatetime,120)) as 'FixTime',
				 convert(varchar(10),DATEDIFF(MINUTE, ls.createdatetime, tbend.createdatetime)) as 'During', 
				case when ls.id is not null and tbend.id is not null then 'FIXED' else 'None' end as 'Trạng thái'
				from stb_linesituation_vvt ls with(nolock)      
				left outer join stb_linesituation_vvt tbend with(nolock)     on ls.id = (tbend.statusApp) 
				left outer join STB_LineInfo li  with(nolock)  on ls.linecode=li.LineCode
				where  (ls.statusEmail<1000) 
				and (  ls.createdatetime >= @FromDate  and  ls.createdatetime <= @ToDate) 
				and ls.statusApp>=0 and ls.statusApp<5 
				and ls.status is not null 
				and ls.linename like '%BG%'
				order by ls.id desc 
	    return;
	end
	
	
;with linedat as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status, ls.statusApp, ls.statusEmail, ls.createdatetime, ls.createuserid     
      from stb_linesituation_vvt ls with(nolock) 
	  left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 
      where   (statusApp>2 )
     
	and ls.createdatetime between @FromDate and @ToDate
	and ls.linename like'%BG%'
	 
    )
  ,
  beginlineid as (
    select li.companycode,li.LineCode,li.LineName,li.LineType,ls.id, ls.errorcode, ls.errorname, ls.routecode, ls.routename, 
      ls.status,  ls.statusEmail, ls.createdatetime, ls.createuserid--,'near' as val
      
       from stb_linesituation_vvt ls with(nolock) 
	   left outer join stb_lineinfo li with(nolock) on li.LineCode=ls.Linecode 	

      where   ls.createdatetime between @FromDate and @ToDate
	  and ls.linename like '%BG%'
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

	case when beginlineid.createuserid is null and linedat.id is null then '~updat31f~'+convert(varchar(10),isnull(beginlineid.id,-1))+'^updat31f^'
		else convert(varchar(23),dateadd(hour,-2,isnull(beginlineid.createuserid,beginlineid.createdatetime)),120) end as beginFix1,

	case when beginlineid.createuserid is null and linedat.id is null then null
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
	, isnull(beginlineid.statusEmail,linedat.statusEmail)statusEmail

	    from beginlineid 
    left outer join linedat  on (beginlineid.id=linedat.statusApp or beginlineid.id is not null and linedat.id is null) 
  ) 
  select 
  --companycode, 
  top 200
  LineCode, LineName, LineType, routecode, routename, 
  _id,-- statusApp, 
  _errorcode, _errorname, --_status, 
  beginOccur,  beginFix1 as beginFix, 
  delf, -- 
  id, errorcode as endcode,status,-- errorname, 
   
  finishTime1 as finishTime,
  finishFix1 as finishFix,    
   del,

  case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end DuringOP
 
 ,case when isnull(DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1) ),0)=0 
		then ((case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)) 
		else DATEDIFF(MINUTE, beginFix2, isnull(finishFix2,getdate1)  ) end DuringFix,
		statusEmail as audi

  from combinedat
  where statusEmail>=1000 or (case when isnull(DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)  ),0)=0 then 1 
		else DATEDIFF(MINUTE, beginOccur, isnull(finishTime2,getdate1)) end)<24*60*3
  order by _id desc ,  linetype,LineCode,routename 


END
