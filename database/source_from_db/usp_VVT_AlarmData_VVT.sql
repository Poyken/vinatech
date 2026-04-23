
--   exec  usp_VVT_AlarmData_VVT '','','',null,null,4

-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_AlarmData_VVT]
	
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pYesterday INT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = 'VVT'
	DECLARE @WorkCenterCode VARCHAR(20) = 'VVT_F1'

	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATETIME                   = @pFromDate
	DECLARE @ToDate DATETIME                      = @pToDate


	select @pyesterday  = -7
	select @pfromdate  = null
	select @ptodate  = null
   	select @fromdate                    = ''
	select @todate                       = ''
	declare @checki int =0

   if(@pyesterday>0 and @pyesterday<3) begin 
		select @pfromdate = getdate()-@pyesterday
		select @ptodate = getdate() --@pyesterday
   end
   else
	 begin
		--theo tuan
		select @pfromdate = dateadd(day, @pyesterday+1-datepart(dw, getdate()), getdate())
		select @ptodate   = dateadd(day, @pyesterday+7-datepart(dw, getdate()), getdate())		
	 end

	if(@pyesterday<1)select @checki=1
	
	select @fromdate   = convert(varchar(10), @pfromdate, 120) + ' 10:30:00'                      
	select @todate     = convert(varchar(10), dateadd(day, 1, convert(smalldatetime, @ptodate)), 120) + ' 10:30:00'
	

	--print @fromdate
	--print @todate


;with tmpdata as (
select 	
	case when si.materialcode is null then (case when lcmh.befmaterialcode is null then lcmh1.newbarcode else lcmh.oldbarcode end)
	else si.barcode
	end as lotno
	 ,[sd] 
      ,sum(case when [sd] > mqii.usl or [sd] < mqii.lsl then 1 else 0 end) ngqty
	  ,sum(case when [sd] <= mqii.usl and [sd] >= mqii.lsl then 1 else 0 end) okqty
	  ,	 (case  when   (datepart(hour, createdate)>10)     or    (datepart(hour, createdate)=10 and datepart(minute, createdate)>30)     
				then     convert(varchar(10),createdate,120)    
				else    convert(varchar(10),dateadd(day, -1,  createdate),120)       
				end )    as  jobdate 
	  --,	
			--mqii.inspectiontype,
			-----it.inspectiontypename,
			--mqii.qcspecdesc,
	  --      mqii.inspectionlevel,
	  --      mqii.aql,
	  --      mqii.specvalue,
	  --      mqii.usl,
	  --      mqii.lsl,
	  --      mqii.ucl,
	  --      mqii.lcl,
	  --      mqii.textspecvalue,
	  --      mqii.createdatetime,
	  --      mqii.createuserid,
	  --      mqii.changedatetime,
	  --      mqii.changeuserid
      --,[createdate]
      --,[attribute1]
      --,[attribute2]
      --,[attribute3]
      --,[pattern]
      --,[capacity]
	  ,isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) as materialcode	  

  from [smartfactoryv2].[dbo].[stb_sdinforbylot] sibl with(nolock)	
  left outer join stb_setinfo si with(nolock)	 on sibl.lotno=si.barcode and si.materialcode is not null
  left outer join stb_lotchangematerialhistory lcmh with(nolock)	 on lcmh.oldbarcode=sibl.lotno and lcmh.befmaterialcode is not null
  left outer join stb_lotchangematerialhistory lcmh1 with(nolock)	 on lcmh1.newbarcode=sibl.lotno and lcmh1.aftmaterialcode is not null

  left outer join	stb_materialqcinspectionitem mqii with(nolock)	on 		mqii.materialcode = isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode))
    where createdate>=@fromdate --convert(varchar(10),getdate()-2,120)+' 10:30:00'
	and (pattern like '%SD%' and pattern not like '%용량%')
	and qcinspectionitemcode='IQC_GPD_18'
	--and sibl.sd='0.0000' 
	group by isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) 
	,(case  when   (datepart(hour, createdate)>10)     or    (datepart(hour, createdate)=10 and datepart(minute, createdate)>30)     
				then     convert(varchar(10),createdate,120)    
				else    convert(varchar(10),dateadd(day, -1,  createdate),120)       
				end )
	 ,[sd]
	,case when si.materialcode is null then (case when lcmh.befmaterialcode is null then lcmh1.newbarcode else lcmh.oldbarcode end)
	else si.barcode
	end
	 --,(case when [sd] > mqii.usl or [sd] < mqii.lsl then 1 else 0 end) 
	 -- ,(case when [sd] <= mqii.usl and [sd] >= mqii.lsl then 1 else 0 end) 
	--order by isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) 
	)
	,
	tmpdata1 as	(
	select count([lotno]) as countlotno,sum(ngqty) as ngqty,sum(okqty) as okqty,/*tmpdata.materialcode as materialcode1,
	mm.materialname,*/substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4) as materialcode
	 ,inputlinecode, jobdate, [sd]

	--,case when jobdate>=@fromdate and jobdate<=@todate then ''
	--else '' end as lastweek

	--,case when jobdate>=@todate then ''
	--else '' end as thisweek
	--,((ngqty)/(countlotno))*100 as ngrate
	from tmpdata	
   left outer join stb_setinfo si  with(nolock)	on si.barcode = [lotno]
	left outer join stb_materialmaster mm with(nolock) on tmpdata.materialcode = mm.materialcode 
	group by /*tmpdata.materialcode,*/substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4),jobdate,	inputlinecode, [sd]
	)	
	,
	tmpdata2 as	(
	select sum(countlotno) as countlotno,convert(numeric(10,2),sum(ngqty)) as ngqty,convert(numeric(10,2),sum(okqty)) as okqty,materialcode,inputlinecode, jobdate, avg( convert(numeric(10,2),[sd])) as  [sd]--,((ngqty)/(countlotno))*100 as ngrate
	from tmpdata1
	where isnumeric([sd]) = 1
	group by materialcode,inputlinecode,jobdate
	)	
	,
	tmpdata3 as (
	select materialcode,inputlinecode, sum(okqty) as okqty, sum(ngqty) as ngqty,sum(countlotno) as countlotno, avg( [sd]) as  [sd]--,((ngqty)/(okqty))*100 as ngrate
	--,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-4, 120)  then ((ngqty)/(okqty)) 
	--	 else 0 
	--	 end)) as befyesterday2

	--,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-3, 120)  then ((ngqty)/(okqty)) 
	--	 else 0 
	--	 end)) as befyesterday1
	,avg(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then (([sd])) 
		 end) as [sdlastweek]

	,avg(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then (([sd])) 
		 end) as [sdthisweek]

	
	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((countlotno)) 
		 else 0 
		 end) as countlotnolast

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((countlotno)) 
		 else 0 
		 end) as countlotnothis



	,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((ngqty)/(okqty+ngqty)) *100
		 else 0 
		 end)) as befyesterday

	,convert(numeric(10,2),sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as yesterday

	,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as today

	,convert(numeric(10,2),sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as lastweek

	,convert(numeric(10,2),sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as thisweek


		 
	,sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((ngqty)) 
		 else 0 
		 end) as befyesterdayng

	,sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((ngqty)) 
		 else 0 
		 end) as yesterdayng

	,sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((ngqty)) 
		 else 0 
		 end) as todayng

	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((ngqty)) 
		 else 0 
		 end) as lastweekng

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((ngqty)) 
		 else 0 
		 end) as thisweekng
		 



	,sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((okqty)) 
		 else 0 
		 end) as befyesterdayok

	,sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((okqty)) 
		 else 0 
		 end) as yesterdayok

	,sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((okqty)) 
		 else 0 
		 end) as todayok

	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((okqty)) 
		 else 0 
		 end) as lastweekok

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((okqty)) 
		 else 0 
		 end) as thisweekok

		 

	--,case when @checki=1 then 'week' else 'day' end as isweek

	from tmpdata2

	where inputlinecode is not null

	group by materialcode,inputlinecode
	)
	,
	sdnow as(
	select 'SD' as cata,
	materialcode, inputlinecode, 
	'_' as separate1, 
	  sdlastweek as valuelastweek,sdthisweek as valuethisweek,
		lastweekok, lastweekng,
	thisweekok, thisweekng,  
	 countlotnolast as lastweeklot, countlotnothis as thisweeklot, 
	 '_' as separate2,
	 lastweek as lastweekrate, thisweek as thisweekrate, 
	'_' as separate3, 
	befyesterday as befyesterdayrate, yesterday as yesterdayrate, today as todayrate, 
	 '_' as separate4, 
	befyesterdayok, befyesterdayng,
	yesterdayok, yesterdayng,
	todayok, todayng, 
	'_' as separate5, 

	sd as sdtotal, okqty , ngqty 

	from tmpdata3
	--	where thisweek> lastweek
	--or today>yesterday
	--or yesterday>befyesterday
	)	
	,
	esrdata as (
select 	
	case when si.materialcode is null then (case when lcmh.befmaterialcode is null then lcmh1.newbarcode else lcmh.oldbarcode end)
	else si.barcode
	end as lotno
	 ,[value] as [sd] 
      ,sum(case when [value] > mqii.usl or [value] < mqii.lsl then 1 else 0 end) ngqty
	  ,sum(case when [value] <= mqii.usl and [value] >= mqii.lsl then 1 else 0 end) okqty
	  ,	 (case  when   (datepart(hour, createdate)>10)     or    (datepart(hour, createdate)=10 and datepart(minute, createdate)>30)     
				then     convert(varchar(10),createdate,120)    
				else    convert(varchar(10),dateadd(day, -1,  createdate),120)       
				end )    as  jobdate 
	  --,	
			--mqii.inspectiontype,
			-----it.inspectiontypename,
			--mqii.qcspecdesc,
	  --      mqii.inspectionlevel,
	  --      mqii.aql,
	  --      mqii.specvalue,
	  --      mqii.usl,
	  --      mqii.lsl,
	  --      mqii.ucl,
	  --      mqii.lcl,
	  --      mqii.textspecvalue,
	  --      mqii.createdatetime,
	  --      mqii.createuserid,
	  --      mqii.changedatetime,
	  --      mqii.changeuserid
      --,[createdate]
      --,[attribute1]
      --,[attribute2]
      --,[attribute3]
      --,[pattern]
      --,[capacity]
	  ,isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) as materialcode	  

  from [smartfactoryv2].[dbo].[Stb_ESRValueMonitor] sibl with(nolock)	
  left outer join stb_setinfo si with(nolock)	 on sibl.lotno=si.barcode and si.materialcode is not null
  left outer join stb_lotchangematerialhistory lcmh  with(nolock)	on lcmh.oldbarcode=sibl.lotno and lcmh.befmaterialcode is not null
  left outer join stb_lotchangematerialhistory lcmh1 with(nolock)	 on lcmh1.newbarcode=sibl.lotno and lcmh1.aftmaterialcode is not null

  left outer join	stb_materialqcinspectionitem mqii with(nolock)	on 		mqii.materialcode = isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode))
    where createdate>=@fromdate --convert(varchar(10),getdate()-2,120)+' 10:30:00'
	--and (pattern like '%SD%' and pattern not like '%용량%')
	and qcinspectionitemcode='IQC_GPD_19'
	--and sibl.sd='0.0000' 
	group by isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) 
	,(case  when   (datepart(hour, createdate)>10)     or    (datepart(hour, createdate)=10 and datepart(minute, createdate)>30)     
				then     convert(varchar(10),createdate,120)    
				else    convert(varchar(10),dateadd(day, -1,  createdate),120)       
				end )
	 ,[value] 
	,case when si.materialcode is null then (case when lcmh.befmaterialcode is null then lcmh1.newbarcode else lcmh.oldbarcode end)
	else si.barcode
	end
	 --,(case when [sd] > mqii.usl or [sd] < mqii.lsl then 1 else 0 end) 
	 -- ,(case when [sd] <= mqii.usl and [sd] >= mqii.lsl then 1 else 0 end) 
	--order by isnull(si.materialcode,isnull(lcmh.befmaterialcode,lcmh1.aftmaterialcode)) 
	)
	,
	esrdata1 as	(
	--------------------select count([lotno]) as countlotno,sum(ngqty) as ngqty,sum(okqty) as okqty,esrdata.materialcode,
	-------------------- inputlinecode, jobdate, [sd]

	----------------------,case when jobdate>=@fromdate and jobdate<=@todate then ''
	----------------------else '' end as lastweek

	----------------------,case when jobdate>=@todate then ''
	----------------------else '' end as thisweek
	----------------------,((ngqty)/(countlotno))*100 as ngrate
	--------------------from esrdata	
 --------------------  left outer join stb_setinfo si  with(nolock)	on si.barcode = [lotno]
	--------------------group by esrdata.materialcode,jobdate,	inputlinecode, [sd]
		select count([lotno]) as countlotno,sum(ngqty) as ngqty,sum(okqty) as okqty,/*tmpdata.materialcode as materialcode1,
	mm.materialname,*/substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4) as materialcode
	 ,inputlinecode, jobdate, [sd]

	--,case when jobdate>=@fromdate and jobdate<=@todate then ''
	--else '' end as lastweek

	--,case when jobdate>=@todate then ''
	--else '' end as thisweek
	--,((ngqty)/(countlotno))*100 as ngrate
	from esrdata	
   left outer join stb_setinfo si  with(nolock)	on si.barcode = [lotno]
	left outer join stb_materialmaster mm with(nolock) on esrdata.materialcode = mm.materialcode 
	group by /*esrdata.materialcode*/substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4),jobdate,	inputlinecode, [sd]
	)	
	,
	esrdata2 as	(
	select sum(countlotno) as countlotno,convert(numeric(10,2),sum(ngqty)) as ngqty,convert(numeric(10,2),sum(okqty)) as okqty,materialcode,inputlinecode, jobdate, avg( convert(numeric(10,2),[sd])) as  [sd]--,((ngqty)/(countlotno))*100 as ngrate
	from esrdata1
	where isnumeric([sd]) = 1
	group by materialcode,inputlinecode,jobdate
	)	
	,
	esrdata3 as (
	select materialcode,inputlinecode, sum(okqty) as okqty, sum(ngqty) as ngqty,sum(countlotno) as countlotno, avg( [sd]) as  [sd]--,((ngqty)/(okqty))*100 as ngrate
	--,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-4, 120)  then ((ngqty)/(okqty)) 
	--	 else 0 
	--	 end)) as befyesterday2

	--,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-3, 120)  then ((ngqty)/(okqty)) 
	--	 else 0 
	--	 end)) as befyesterday1
	,avg(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then (([sd])) 
		 end) as [sdlastweek]

	,avg(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then (([sd])) 
		 end) as [sdthisweek]

	
	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((countlotno)) 
		 else 0 
		 end) as countlotnolast

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((countlotno)) 
		 else 0 
		 end) as countlotnothis



	,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((ngqty)/(okqty+ngqty)) *100
		 else 0 
		 end)) as befyesterday

	,convert(numeric(10,2),sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as yesterday

	,convert(numeric(10,2),sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as today

	,convert(numeric(10,2),sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as lastweek

	,convert(numeric(10,2),sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((ngqty)/(okqty+ngqty))  *100
		 else 0 
		 end)) as thisweek


		 
	,sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((ngqty)) 
		 else 0 
		 end) as befyesterdayng

	,sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((ngqty)) 
		 else 0 
		 end) as yesterdayng

	,sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((ngqty)) 
		 else 0 
		 end) as todayng

	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((ngqty)) 
		 else 0 
		 end) as lastweekng

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((ngqty)) 
		 else 0 
		 end) as thisweekng
		 



	,sum(case when  jobdate=convert(varchar(10), getdate()-2, 120)  then ((okqty)) 
		 else 0 
		 end) as befyesterdayok

	,sum(case when   jobdate=convert(varchar(10), getdate()-1, 120)  then ((okqty)) 
		 else 0 
		 end) as yesterdayok

	,sum(case when  jobdate=convert(varchar(10), getdate(), 120)   then ((okqty)) 
		 else 0 
		 end) as todayok

	,sum(case when @todate<getdate() and jobdate>=@fromdate and jobdate<@todate and @checki=1 then ((okqty)) 
		 else 0 
		 end) as lastweekok

	,sum(case when (@todate> getdate() or jobdate>=@todate)  and @checki=1 then ((okqty)) 
		 else 0 
		 end) as thisweekok

		 

	--,case when @checki=1 then 'week' else 'day' end as isweek

	from esrdata2

	where inputlinecode is not null

	group by materialcode,inputlinecode
	)
	,
	esrnow as (select 'ESR' as cata,
	materialcode, inputlinecode, 
	'_' as separate1, 
	   sdlastweek as valuelastweek,sdthisweek as valuethisweek,
		lastweekok, lastweekng,
	thisweekok, thisweekng,  
	 countlotnolast as lastweeklot, countlotnothis as thisweeklot, 
	 '_' as separate2,
	 lastweek as lastweekrate, thisweek as thisweekrate, 
	'_' as separate3, 
	befyesterday as befyesterdayrate, yesterday as yesterdayrate, today as todayrate, 
	 '_' as separate4, 
	befyesterdayok, befyesterdayng,
	yesterdayok, yesterdayng,
	todayok, todayng, 
	'_' as separate5, 

	sd as sdtotal, okqty , ngqty 

	from esrdata3
	
	--where thisweek> lastweek  
	--or today>yesterday        
	--or yesterday>befyesterday 
	)
	,
	sdESRdata as (
select   --mm.materialname,
--substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4) as sizecode,
sdnow.*,getdate() as createdate    from sdnow 
	--left outer join stb_materialmaster mm with(nolock) on sdnow.materialcode  = mm.materialcode

union all

select  --mm.materialname,
--substring(mm.materialname,CHARINDEX('(',mm.materialname)+1,4) as sizecode,
esrnow.*,getdate() as createdate   from esrnow 
	--left outer join stb_materialmaster mm on with(nolock)  esrnow.materialcode = mm.materialcode 
	)
	select * 
	into #tmpSDESR
	from sdESRdata
	--

	if ( OBJECT_ID('TempDB..##tmpGlobalESRrate','U') is not null) begin
		declare @checkdate DATETIME = NULL
		
		select @checkdate= max(createdate) from ##tmpGlobalESRrate

		if(@checkdate is null or @checkdate<=getdate()-(convert(numeric,1)/24/2)) begin
			insert into ##tmpGlobalESRrate
			select * from #tmpSDESR
		end
		else begin
			select * from ##tmpGlobalESRrate
			union all
			select * from #tmpSDESR
			order by createdate desc,cata,inputlinecode,materialcode;
			delete #tmpSDESR
			return;
		end
	end
	else begin
		select * 
		into ##tmpGlobalESRrate
		from #tmpSDESR
	end

	
	delete ##tmpGlobalESRrate
	where createdate<convert(varchar(10),getdate(),120)


	select * from ##tmpGlobalESRrate
	order by createdate desc,cata,inputlinecode,materialcode;

	delete #tmpSDESR


-- usp_VVT_AlarmData_VVT '','','',null,null,1
   
----   if(@pYesterday=1) begin 
----		select @pFromDate = GETDATE()-1
----		select @pToDate = GETDATE()-1
----   end

----   if(@pYesterday=0) begin
----   		select @pFromDate = GETDATE()
----		select @pToDate = GETDATE()
----   end


----	if(@pYesterday=2) begin
----		--tuan nay
----		select @pFromDate = dateadd(day, 1-datepart(dw, getdate()), getdate())
----		select @pToDate = dateadd(day, 7-datepart(dw, getdate()), getdate())
----	end


----	if(@pYesterday=4) begin
----		--tan trươc
----		select @pFromDate = dateadd(day, -6-datepart(dw, getdate()), getdate())
----		select @pToDate = dateadd(day, 0-datepart(dw, getdate()), getdate())
----	end


----	select @FromDate   = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:30:00'                      
----	select @ToDate     = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:00'


	
----;with ViewBarcode as (
----		 select  c.Barcode
----		 from 
----		 STB_SetInfo c with(nolock) 
----		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
----		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
----	 ),
----RawView as (
----	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.WorkerCode,SIExtText07,SIExtInt01,shiftcode,c.PONo,
----		max(b.ProdQty) as ProdQty, sum(a.DefectQty) as DefectQty,  sum(a.RepairQty) as RepairQty ,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
----		from  STB_SetInfo c with(nolock) 
----		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
----		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
----		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
----		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime,shiftcode,c.PONo
----)
----,


----X as(
----		select  
----		 RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode as LineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,shiftcode,PONo,
----		 ri.RouteName, 
----		 MM2.MaterialName,
----		 li.LineName, pwi.WorkerName,
----		  RV.ProdDateTime	
----		 , (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
----				then     convert(varchar(10),ProdDateTime,120)    
----				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
----				end )    as  JobDate ,
----		  max(RV.ProdQty) as OutputQty,
----		  sum(RV.DefectQty) as DefectQty, 
----		  sum(RV.RepairQty) as RepairQty, 
----		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
----		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
----		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
----		  DATEPART(DAY, ProdDateTime)  as ProdDay,
----		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
----		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
----		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
----		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode
----		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
----		from RawView RV 
----		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
----			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
----			LEFT OUTER JOIN STB_MaterialMaster     MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
----			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
----			  --LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
----			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
----			  outer APPLY
----						 (SELECT distinct t1.Lotno
----						  FROM STB_MaterialLotInfo t1  with(nolock) 
----						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
----						 ) mli	
----		where 
----		( 
----			(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
----			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
----			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
----		) 
----		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,shiftcode,PONo,
----		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,		  RV.ProdDateTime
----)
----	SELECT
----           --dbo.fnGetLocalTime(PRS.JobDate, 420) ,
----			--PRS.CompanyCode,
----			--PRS.WorkCenterCode,
----			PRS.MaterialCode ,
----			MM.MaterialName ,
----			--PRS.LineCode ,
----			--LI.LineName ,
----			PRS.RouteCode ,
----			RI.RouteName ,
----			--POR.RouteIndex,
----			--PRS.MoldNumber,
----			--PRS.MachineCode,
----			--MCM.MachineName,
----			--PRS.PONo,
----			--POI.PlanQty AS POPlanQty,


----			--PRS.ShiftCode,
----			--SC.Shift,
----			--(SELECT SC.Shift FROM VW_ShiftCode SC),
----			--PRS.TimeCode,
----			--isnull(SUM(DPP.PlanQty),0) as PlanQty ,
----			--MAX(DPP.PlanQty) AS PlanQty,
----			--SUM(PRS.InputQty) AS InputQty,
----			isnull(SUM(PRS.OutputQty),0) as OutputQty,
----			isnull(SUM(isnull(PRS.DefectQty,0) - ISNULL(RepairQty, 0) ),0) as NGQTY, 
----			(SUM(isnull(PRS.OutputQty,0)) - SUM(isnull(PRS.DefectQty,0) -- ISNULL(RepairInfo.RepairQty, 0) 
----			)) as TotalQTY--, 
----			--SUM(PRS.RepairQty) AS RepairQty,
----			--SUM(PRS.LossQty) AS LossQty
----			--CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
----			--CASE WHEN ISNULL(SUM(PRS.DefectQty - ISNULL(RepairQty, 0)
----			--),0) = 0 THEN 0.0 
----			--        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE SUM(PRS.DefectQty - ISNULL(RepairQty, 0)
----			--		) / SUM(PRS.OutputQty) * 100.0 END as rate 
----	FROM
----			X   PRS WITH(NOLOCK)
----			 OUTER APPLY (select top 1 * from  STB_LineInfo              LI WITH(NOLOCK)   where  LI.LineCode = PRS.LineCode
----			) LI
----			OUTER APPLY (select top 1 * from   STB_RouteInfo            RI WITH(NOLOCK)    where RI.RouteCode = PRS.RouteCode
----			)	RI
----			--OUTER APPLY (select top 1 * from   STB_MachineMaster MCM WITH(NOLOCK)          where  MCM.MachineCode = PRS.MachineCode
----			--)MCM

----			 OUTER APPLY (select top 1 * from   STB_MaterialMaster   MM WITH(NOLOCK)        where MM.MaterialCode = PRS.MaterialCode
----			)MM

----			 OUTER APPLY (select top 1 * from   VW_ShiftCode           SC     WITH(NOLOCK)  where SC.ShiftCode = PRS.ShiftCode
----			)SC

----			 OUTER APPLY (select top 1 * from   STB_ProductionOrderRouting POR WITH(NOLOCK) where POR.PONo = PRS.PONo 
----																		AND POR.RouteCode = PRS.RouteCode
----			)POR

----			 OUTER APPLY (select top 1 * from   STB_ProductionOrderInfo POI WITH(NOLOCK)    where POI.PONo = PRS.PONo
----			)POI 
----			OUTER APPLY (select top 1 * from   STB_DayProdPlan            DPP WITH(NOLOCK) where DPP.PONo = PRS.PONo 
----																		AND DPP.LineCode = PRS.LineCode 
----																		AND DPP.PlanDate = PRS.JobDate 
----																		AND DPP.PlanShiftCode = PRS.ShiftCode
----			)DPP

----	GROUP BY
----			--PRS.CompanyCode,
----			--PRS.WorkCenterCode,
----			--PRS.PONo,
----			--POI.PlanQty,
----			PRS.MaterialCode,
----			MM.MaterialName,
----			--PRS.LineCode,
----			--LI.LineName,
----			PRS.RouteCode,
----			RI.RouteName--,
----			--POR.RouteIndex,
----			--PRS.MoldNumber,
----			--PRS.MachineCode,
----			--MCM.MachineName,
----			--PRS.JobDate,
----			--PRS.ShiftCode,
----			--SC.Shift--,
----			--PRS.TimeCode
----  --order by PRS.RouteCode


END 

-- usp_VVT_AlarmData_VVT '','','',null,null,1
