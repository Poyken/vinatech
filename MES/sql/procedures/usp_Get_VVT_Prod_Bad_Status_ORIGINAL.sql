-- =============================================
-- Author:	   nguyentung
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 조립불량현황

-- =============================================
-- [프로시저 실행문]      EXEC usp_GetProdBadStatus  '','','VVT','','','','','2019-12-15','2019-12-15',''
-- [프로시저 실행문]      EXEC usp_Get_VVT_Prod_Bad_Status  '','','','VVT','VVT_F1','','','','2025-05-26','2025-05-26',''


CREATE PROCEDURE [dbo].[usp_Get_VVT_Prod_Bad_Status]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;
 --DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END   -- 원본 백업
 --DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END  -- 원본 백업
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN '*'      ELSE @pCompanyCode    END      --2019.12.16 수정
	DECLARE @WorkCenterCode   VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*'      ELSE @pWorkCenterCode END      --2019.12.16 수정	
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATETIME                   = @pFromDate
	DECLARE @ToDate DATETIME                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       


	select @FromDate   = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	select @ToDate     = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'

	
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,b.CreateDateTime)>@FromDate 
		 and isnull(b.ProdDateTime,b.CreateDateTime)<@ToDate and  SUBSTRING (c.Barcode, 1, 1) !='M'
	 ),
RawView as (
 	select  c.Barcode,isnull(b.RouteCode,a.FindRouteCode) RouteCode,isnull(b.RouteCode,a.FindRouteCode) as FindRouteCode,c.ControlNo,c.MaterialCode,
		InputLineCode,isnull(b.MachineCode,'')MachineCode,isnull(b.WorkerCode,'')WorkerCode,SIExtText07,SIExtInt01,DefectCode,
		isnull(max(b.ProdQty),0) as ProdQty, sum(isnull(a.DefectQty,0)) as DefectQty,  sum(isnull(a.RepairQty,0)) as RepairQty ,
		isnull(max(b.ProdDateTime),max(a.CreateDateTime)) as ProdDateTime, dateadd(second,-6,max(a.CreateDateTime)) as CreateDateTime,POI.DefectSummaryNoBeforeDroping--,a.DefectCauseID
		from  STB_SetInfo c with(nolock) 
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo  
		 left outer join   STB_ProdRouteHist     b	 with(nolock)   on  c.ControlNo=b.ControlNo	 and  a.FindRouteCode = b.RouteCode
		 left outer join STB_ProductionOrderInfo POI with(nolock) on a.PoNo = POI.PoNo
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) 
		 and	a.DefectQty >=1
		 and    (isnull(b.ProdDateTime,a.CreateDateTime)>@FromDate and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,a.CreateDateTime)<@ToDate)
		 group by c.Barcode,b.RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,DefectCode,POI.DefectSummaryNoBeforeDroping--,a.DefectCauseID
)
,
--AlloyView as (
--select RawView.* --, 
	--(row_number() over (partition by RawView.Barcode order by RawView.RouteCode ASC) )     as Routerank 
		--, (row_number() over (partition by RawView.Barcode order by RawView.ProdDateTime ASC) )  as Timerank 	
		--, prh.ProdDateTime as maxProdDateTime
		--, ( count(prh.RouteCode))  as total
		--  from RawView
		  --join STB_ProdRouteHist  prh with(nolock) on RawView.ControlNo = prh.ControlNo --and RawView.RouteCode = prh.RouteCode
		  --group by Barcode,RawView.RouteCode, FindRouteCode,RawView.ControlNo,RawView.MaterialCode,InputLineCode,
		  --RawView.MachineCode,RawView.WorkerCode,SIExtText07,SIExtInt01,RawView.ProdQty,RawView.DefectQty,RawView.ProdDateTime--, prh.ProdDateTime
--)
X as(
		select  
		 RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode as LineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,DefectCode,
		 ri.RouteName, 
		 MM2.MaterialName,
		-- case when RV.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else  MM2.MaterialName end as MaterialName, --Ms Phuong request update audit 2025-11-26
		 li.LineName, pwi.WorkerName,mm.MachineName,
		  RV.ProdDateTime	
		 --, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
			--	then     convert(varchar(10),ProdDateTime,120)    
			--	else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
			--	end )    as  JobDate ,
			, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>0)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  JobDate ,
		  max(RV.ProdQty) as ProdQty,
		  sum(RV.DefectQty - RV.RepairQty) as DefectQty, 
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		  DATEPART(DAY, ProdDateTime)  as ProdDay,
		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode,
		  RV.DefectSummaryNoBeforeDroping
		  --RV.DefectCauseID
		 
		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster     MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
			  --outer APPLY
					--	 (SELECT distinct t1.Lotno
					--	  FROM STB_MaterialLotInfo t1  with(nolock) 
					--	  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
					--	 ) mli	
		--where 
		--( 
		--	(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
		--	(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
		--	--(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
		--) 
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime,DefectCode,RV.DefectSummaryNoBeforeDroping--,RV.DefectCauseID
)
	,
	  Z as (
		select sum(DefectQty) as TotalErrQty
		from X WITH(NOLOCK)
	  ),
	 STB_Defect_VVT as (
	    SELECT --ROW_NUMBER() OVER(ORDER BY X.DefectQty DESC) AS ROWNUM
			  X.JobDate    AS 작업일자
			,  X.LineCode   AS  라인코드		  
			,  X.RouteCode AS 공정코드
			,  X.RouteName AS 공정명
			,  X.MaterialCode  AS 품목코드
			
			,  X.MaterialName  AS 품목명
			,  X.DefectCode AS  불량코드
			,  case when di.BasicDefectName = di.DefectDesc then di.DefectDesc else di.BasicDefectName  +'_'+ di.DefectDesc end AS 불량명 
			,  X.DefectQty AS 불량수량		
			, (X.DefectQty / (select TotalErrQty from Z) ) * 100 AS 불량률
			,  X.ControlNo                       AS ControlNo
			, X.Barcode
			, Y.TypeErrorNameVI	as DirectlyUnder
			--H.Id,
			--di.DefectCause as DefectName
		   
			--di.DefectCause
			--, dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice
			--, dbo.fnGetWastePriceByMaterial(@CompanyCode
			--                              , @WorkCenterCode
			--							  , X.LineCode
			--							  , X.MaterialCode
			--							  , 'PC'
			--							  , X.RouteCode
			--							  , X.DefectQty) AS DefectWastePrice
			,X.DefectSummaryNoBeforeDroping
			,X.MachineCode,
			X.MachineName
		from X WITH(NOLOCK)
				 --left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=x.ControlNo and a.FindRouteCode = x.RouteCode and CreateDateTime between @FromDate and @ToDate
				 left  outer join  STB_DefectInfo        di   with(nolock)  on  X.DefectCode = di.DefectCode
				 left outer join STB_TypeErrorGroupOfFactory Y with(nolock)  on  Y.TypeErrorCode = di.DirectlyUnder
				 --left outer join STB_DefectCauseNG H on X.DefectCauseID=H.Id
		    --,Z WITH(NOLOCK)
	)

	 SELECT  /* dbo.fnGetLocalTime(*/A.작업일자--,@pUtcOffset) AS 작업일자
				,A.라인코드
				,A.공정코드
				,A.공정명
				,A.품목코드,  -- mã  hàng
				CASE
				   WHEN A.품목코드='ECVT27-344' THEN 'HY-CAP WEC2R7106QG (1030 Low)'
				   ELSE A.품목명
				 END AS 품목명
				--,A.품목명 -- tên hang mục hang

				,A.불량코드
				,A.불량명
				--,A.불량내용
				,A.불량수량
				,A.불량률
				,A.MachineCode,
				A.MachineName
				--,SUM(B.불량률) AS 누적불량률
				,A.ControlNo
				,A.Barcode as LotNo ,
				A.DirectlyUnder
				--A.DefectCause,
				--A.Id,
				--A.DefectName
				, ISNULL(A.불량수량, 0) *  
				case when A.작업일자<'2023-10-01' then ISNULL(vwupd.ProcessUnitPriceEA,0) 
					when A.작업일자>='2023-10-01' and A.DefectSummaryNoBeforeDroping  is not null  and   (불량코드 like 'V-29_XX1' or 불량코드 like 'V-29_XX2' or 불량코드 like 'V-29_XX3' or 공정코드 like 'V-34_BG')   
					then
						case  
							when A.공정코드 like '%'+vwup.RouteV22+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV22)
							when A.공정코드 like '%'+vwup.RouteV23+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV23)
							when A.공정코드 like '%'+vwup.RouteV24+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV24)
							when A.공정코드 like '%'+vwup.RouteV25+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV25)
							when A.공정코드 like '%'+vwup.RouteV26+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV26)
							when A.공정코드 like '%'+vwup.RouteV27+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV27)
							when A.공정코드 like '%'+vwup.RouteV28+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV28)
							when A.공정코드 like '%'+vwup.RouteV29+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV29)
							when A.공정코드 like '%'+vwup.RouteV30+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV30)
							when A.공정코드 like '%'+vwup.RouteV31+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV31)
							when A.공정코드 like '%'+vwup.RouteV32+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV32)
							when A.공정코드 like '%'+vwup.RouteV33+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV33)

							when A.공정코드 like '%'+vwup.RouteVE01+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE01)
							when A.공정코드 like '%'+vwup.RouteVE02+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE02)
							when A.공정코드 like '%'+vwup.RouteVE03+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE03)
							when A.공정코드 like '%'+vwup.RouteVE04+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE04)
							when A.공정코드 like '%'+vwup.RouteVE05+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE05)
							when A.공정코드 like '%'+vwup.RouteVE06+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE06)
							when A.공정코드 like '%'+vwup.RouteVE07+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE07)
							when A.공정코드 like '%'+vwup.RouteVE08+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE08)
							when A.공정코드 like '%'+vwup.RouteVE09+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE09)
							when A.공정코드 like '%'+vwup.RouteVE10+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE10)
							else
								ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA) 
							end
					
					when A.작업일자>='2023-10-01' and (불량코드 not like 'V-29_XX1' and 불량코드 not like 'V-29_XX2' and 불량코드 not like 'V-29_XX3' and 공정코드 not like 'V-34_BG' and A.DefectSummaryNoBeforeDroping is null) 
					then 
						case 
							when A.공정코드 like '%'+vwup.RouteV22+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV22)
							when A.공정코드 like '%'+vwup.RouteV23+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV23)
							when A.공정코드 like '%'+vwup.RouteV24+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV24)
							when A.공정코드 like '%'+vwup.RouteV25+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV25)
							when A.공정코드 like '%'+vwup.RouteV26+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV26)
							when A.공정코드 like '%'+vwup.RouteV27+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV27)
							when A.공정코드 like '%'+vwup.RouteV28+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV28)
							when A.공정코드 like '%'+vwup.RouteV29+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV29)
							when A.공정코드 like '%'+vwup.RouteV30+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV30)
							when A.공정코드 like '%'+vwup.RouteV31+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV31)
							when A.공정코드 like '%'+vwup.RouteV32+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV32)
							when A.공정코드 like '%'+vwup.RouteV33+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceV33)

							when A.공정코드 like '%'+vwup.RouteVE01+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE01)
							when A.공정코드 like '%'+vwup.RouteVE02+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE02)
							when A.공정코드 like '%'+vwup.RouteVE03+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE03)
							when A.공정코드 like '%'+vwup.RouteVE04+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE04)
							when A.공정코드 like '%'+vwup.RouteVE05+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE05)
							when A.공정코드 like '%'+vwup.RouteVE06+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE06)
							when A.공정코드 like '%'+vwup.RouteVE07+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE07)
							when A.공정코드 like '%'+vwup.RouteVE08+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE08)
							when A.공정코드 like '%'+vwup.RouteVE09+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE09)
							when A.공정코드 like '%'+vwup.RouteVE10+'%' then COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA,vwup.PriceVE10)
							else
								COALESCE(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA) 
							end
					else  0  end   
					as     DefectWastePrice 

				,case	when A.품목코드 = 'ECVT30-367' then weightLastD.valweight  -- 1030 low esr / dòng này cập nhật cho những model có cùng size, cùng farad nhưng khác cân
						when A.불량코드 in ('V-24_2DD','V-24_00','V-24_2CW','V-24_2RI','V-24_2RY','V-24_QQ','V-24_X03','V-24_X12') then isnull(case when weightLastA.valweight=0 then weightLast.valweight else weightLastA.valweight end,weightLast.valweight)
						when A.불량코드 in ('','','','','') then isnull(weightLastB.valweight,weightLast.valweight) 
						when A.불량코드 in ('V-24_2DR','','','','') then isnull(weightLastC.valweight,weightLast.valweight) 
						--else weightLast.valweight 
						
						else ISNULL(weightLast.valweight, weightLastD.valweight)
				 end as WeightUnit  

		  , ISNULL(A.불량수량, 0) * (case when A.품목코드 = 'ECVT30-367' then weightLastD.valweight  -- 1030 low esr / dòng này cập nhật cho những model có cùng size, cùng farad nhưng khác cân
						when A.불량코드 in ('V-24_2DD','V-24_00','V-24_2CW','V-24_2RI','V-24_2RY','V-24_QQ','V-24_X03','V-24_X12') then isnull(case when weightLastA.valweight=0 then weightLast.valweight else weightLastA.valweight end,weightLast.valweight)
						when A.불량코드 in ('','','','','') then isnull(weightLastB.valweight,weightLast.valweight) 
						when A.불량코드 in ('V-24_2DR','','','','') then isnull(weightLastC.valweight,weightLast.valweight) 
						--else weightLast.valweight 
						else ISNULL(weightLast.valweight , weightLastD.valweight)
				 end)/1000 as WasteWeight 
				 ,A.DefectSummaryNoBeforeDroping
	    FROM STB_Defect_VVT A WITH(NOLOCK) 
		left outer join [dbo].[fn_VVT_StagePrices]() vwupd  on vwupd.model = A.품목코드 and vwupd.routecode=A.공정코드 
		left outer join STB_VVT_StagePrices vwup on vwup.model = A.품목코드 and 
		(  A.공정코드 like '%'+vwup.RouteV22+'%'
		or A.공정코드 like '%'+vwup.RouteV23+'%'
		or A.공정코드 like '%'+vwup.RouteV24+'%'
		or A.공정코드 like '%'+vwup.RouteV25+'%'
		or A.공정코드 like '%'+vwup.RouteV26+'%'
		or A.공정코드 like '%'+vwup.RouteV27+'%'
		or A.공정코드 like '%'+vwup.RouteV28+'%'
		or A.공정코드 like '%'+vwup.RouteV29+'%'
		or A.공정코드 like '%'+vwup.RouteV30+'%'
		or A.공정코드 like '%'+vwup.RouteV31+'%'
		or A.공정코드 like '%'+vwup.RouteV32+'%'
		or A.공정코드 like '%'+vwup.RouteV33+'%'
		or A.공정코드 like '%'+vwup.RouteV34+'%'
		or A.공정코드 like '%'+vwup.RouteVE01+'%'
		or A.공정코드 like '%'+vwup.RouteVE02+'%'
		or A.공정코드 like '%'+vwup.RouteVE03+'%'
		or A.공정코드 like '%'+vwup.RouteVE04+'%'
		or A.공정코드 like '%'+vwup.RouteVE05+'%'
		or A.공정코드 like '%'+vwup.RouteVE06+'%'
		or A.공정코드 like '%'+vwup.RouteVE07+'%'
		or A.공정코드 like '%'+vwup.RouteVE08+'%'
		or A.공정코드 like '%'+vwup.RouteVE09+'%'
		or A.공정코드 like '%'+vwup.RouteVE10+'%'
		)

		left outer join [dbo].[fn_VVT_StagePricesNEW]() vwupNEW on vwupNEW.model = A.품목코드 and vwupNEW.routecode=A.공정코드 
		outer apply  
				(select top 1 * from [dbo].[fn_VVT_StagePricesNEW]()  vwupNEW1 
				where A.품목명 like '%'+vwupNEW1.partno+'%' and vwupNEW1.routecode=A.공정코드 
				)vwupNEW1 
--outer apply (
--select model, convert(numeric(38,15),isnull(max(val),0) ) as ProcessUnitPriceEA
--from Prices
--where A.품목명 like model and 공정코드=routecode and routecode<>'V-28'
--group by model
--)  vwup

			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 5) like '%'+weight3.model+'%'  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 5) like '%'+weight3.model+'%'  and  weight3.routecode=A.공정코드    and Modelcode=A.품목코드
			   ) weightLast 
			   			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 5) like '%'+weight3.model+'%'  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 5) like '%'+weight3.model+'%'  and  weight3.routecode=A.공정코드+'A'
			   ) weightLastA
			   			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 5) like '%'+weight3.model+'%'  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 5) like '%'+weight3.model+'%'  and  weight3.routecode=A.공정코드+'B'
			   ) weightLastB
			   			  OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 5) like '%'+weight3.model+'%'  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 5) like '%'+weight3.model+'%'  and  weight3.routecode=A.공정코드 and weight3.routecode='V-23'
			   ) weightLastC

			   -- DinhManh update 2025-10-08 for MaterialName don't have '('
				   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
								join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
									on modelInfo.ModelName =  weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
								where A.품목명 =  weight3.model  and  weight3.routecode=A.공정코드    and Modelcode=A.품목코드
				   ) weightLastD
				-- END

	   --          INNER JOIN STB_Defect_VVT B WITH(NOLOCK)  ON B.ROWNUM <= A.ROWNUM
	   --    GROUP BY A.작업일자
	   --            , A.라인코드 
				--   , A.공정코드
				--   , A.공정명 
				--   , A.품목코드
			 --      , A.품목명
				--   , A.불량코드
				--   , A.불량명
				--   , A.불량수량
				--   , A.불량률
				--   , A.ControlNo
				--   , A.DefectWastePrice
				--   ,a.Barcode
	   --ORDER BY SUM(B.불량률)
	   ORDER BY ISNULL(A.불량수량, 0) *   convert(numeric(38,15), ISNULL(vwupd.ProcessUnitPriceEA,0) )  desc
	   --       EXEC usp_Get_VVT_Prod_Bad_Status  '','',420,'VVT','','','','','2020-09-12','2020-09-18',''

   

----select*from   STB_DefectRepairInfo 
----where controlno =(select controlno from STB_SetInfo where Barcode='VVLM303R036703')

----select
----sum(DefectQty)
----from
----STB_ProdRouteHist a 
----left outer join STB_DefectRepairInfo b on a.ControlNo = b.ControlNo
----where a.CreateDateTime > '2021-04-30 10:30:00' and a.CreateDateTime < '2021-05-01 10:30:00' and a.RouteCode like 'V%'



END

-- [프로시저 실행문]      EXEC usp_Get_VVT_Prod_Bad_Status  '','','','VVT','','','','','2020-07-12','2020-07-13',''

--select*from STB_DefectInfo