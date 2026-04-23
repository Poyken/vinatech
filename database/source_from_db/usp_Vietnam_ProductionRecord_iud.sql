
--        exec usp_Vietnam_ProductionRecord_iud '','','VVT','','@pSize','@pCapa','@pYear'   

CREATE  PROCEDURE [dbo].[usp_Vietnam_ProductionRecord_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pId int = NULL,
	@pSize varchar(20) = NULL,
	@pCapa varchar(20) = NULL,
	@pYear varchar(20) = NULL,
	@pJan int  = NULL,
	@pFeb int  = NULL,
	@pMar int  = NULL,
	@pApr int  = NULL,
	@pMay int  = NULL,
	@pJun int  = NULL,
	@pJul int  = NULL,
	@pAug int  = NULL,
	@pSep int  = NULL,
	@pOct int  = NULL,
	@pNov int  = NULL,
	@pDec int  = NULL,
	@pTotal int = NULL,
	@pIsDeleted int = NULL,
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL
AS	

BEGIN

	SET NOCOUNT ON;

	DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pFromDate)), 120)  +'-26'   + ' 10:30:00'
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pToDate)), 120)  +'-26'   + ' 10:30:00'

	--declare  tung cursor for
	--select*from stb_vvt_productionrecord_vvt

	--open tung
	--fetch next from tung

	--close tung
	--DEALLOCATE  tung


	--	declare @tung varchar(20)=convert(varchar(20),@pIsDeleted)
	--raiserror (@tung,16,1)
	--return

  if(@pId is null or @pId=0 or @pId='') begin

	  SET IDENTITY_INSERT dbo.STB_VVT_ProductionRecord_VVT OFF;  
		INSERT INTO dbo.STB_VVT_ProductionRecord_VVT
           (Size
           ,Capa
           ,"Year"
           ,Jan
           ,Feb
           ,Mar
           ,Apr
           ,May
           ,Jun
           ,Jul
           ,Aug
           ,Sep
           ,Oct
           ,Nov
           ,"Dec"
           ,Total
           ,ChangeUserId
           ,ChangeDateTime
		   ,IsDeleted)
     VALUES
           (
		    @pSize
		    ,@pCapa
		    ,@pYear
		    ,@pJan 
		    ,@pFeb 
		    ,@pMar 
		    ,@pApr 
		    ,@pMay 
		    ,@pJun 
		    ,@pJul 
		    ,@pAug 
		    ,@pSep 
		    ,@pOct 
		    ,@pNov 
		    ,@pDec 
		    ,@pTotal
		    ,@pProcessUserID
		    ,getdate()
			,0
		   )
		 SET IDENTITY_INSERT dbo.STB_VVT_ProductionRecord_VVT ON;  
	end

  else

  	 select @FromDate   = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pFromDate)), 120) 

	  update STB_VVT_ProductionRecord_VVT
	  set
		 Size 		   =  case when @pSize is not null and  @pSize  <> '' then @pSize         else  Size             end
		,Capa		   =  case when @pCapa is not null and  @pCapa  <> '' then @pCapa         else  Capa		 	 end
		,"Year"		   =  case when @pYear is not null and  @pYear  <> '' then @pYear         else  "Year"		 	 end
		,Jan		   =  case when @pJan          > 0 and convert(varchar(4),"Year") + (case when Jan>=0 then '-01' end) between @FromDate and @ToDate  then @pJan          	 else  Jan		 	 end
		,Feb		   =  case when @pFeb          > 0 and convert(varchar(4),"Year") + (case when Feb>=0 then '-02' end) between @FromDate and @ToDate  then @pFeb          	 else  Feb		 	 end
		,Mar		   =  case when @pMar          > 0 and convert(varchar(4),"Year") + (case when Mar>=0 then '-03' end) between @FromDate and @ToDate  then @pMar          	 else  Mar		 	 end
		,Apr		   =  case when @pApr          > 0 and convert(varchar(4),"Year") + (case when Apr>=0 then '-04' end) between @FromDate and @ToDate  then @pApr          	 else  Apr		 	 end
		,May		   =  case when @pMay          > 0 and convert(varchar(4),"Year") + (case when May>=0 then '-05' end) between @FromDate and @ToDate  then @pMay          	 else  May		 	 end
		,Jun		   =  case when @pJun          > 0 and convert(varchar(4),"Year") + (case when Jun>=0 then '-06' end) between @FromDate and @ToDate  then @pJun          	 else  Jun		 	 end
		,Jul		   =  case when @pJul          > 0 and convert(varchar(4),"Year") + (case when Jul>=0 then '-07' end) between @FromDate and @ToDate  then @pJul          	 else  Jul		 	 end
		,Aug		   =  case when @pAug          > 0 and convert(varchar(4),"Year") + (case when Aug>=0 then '-08' end) between @FromDate and @ToDate  then @pAug          	 else  Aug		 	 end
		,Sep		   =  case when @pSep          > 0 and convert(varchar(4),"Year") + (case when Sep>=0 then '-09' end) between @FromDate and @ToDate  then @pSep          	 else  Sep		 	 end
		,Oct		   =  case when @pOct          > 0 and convert(varchar(4),"Year") + (case when Oct>=0 then '-10' end) between @FromDate and @ToDate  then @pOct          	 else  Oct		 	 end
		,Nov		   =  case when @pNov          > 0 and convert(varchar(4),"Year") + (case when Nov>=0 then '-11' end) between @FromDate and @ToDate  then @pNov          	 else  Nov		 	 end
		,"Dec"		   =  case when @pDec          > 0 and convert(varchar(4),"Year") + (case when "Dec">=0 then '-12' end) between @FromDate and @ToDate then @pDec          	 else  "Dec"		 end
		,Total		   =  case when @pTotal        > 0 then @pTotal        	 else  Total		 end
		,ChangeUserId  =  case when @pProcessUserID is not null and  @pProcessUserID  <> '' then @pProcessUserID	 else  ChangeUserId	 end
		,ChangeDateTime=   getdate()
		,IsDeleted     =   case when @pIsDeleted is null or @pIsDeleted='' or @pIsDeleted<=0 then 0 else 1 end
	  where Id=@pId
		and "Year" between DATEPART(year,@FromDate) and DATEPART(year,@ToDate)

END

--       exec usp_Vietnam_ProductionRecord_iud '','','VVT','2021-01-01','2021-06-01','','','','' 
--          update STB_VVT_ProductionRecord_VVT set isdeleted=0

	--select
	--	Size,
	--	Capa,
	--	"Year",		
	--	 ProdMonth,
	--	 ProdQty
	--from 
	--		(select * from STB_VVT_ProductionRecord_VVT where IsDeleted<>1) p
	--	UNPIVOT
	--	(
	--		ProdQty for ProdMonth in (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)
	--	) as unpvt
	--where [Year]<>'Total'
	--order by Size,capa,"Year"
