-- =============================================
-- Author : Ha Nguyen
-- Group : 
-- Browsable : true
-- Create date : 2014-07-04
-- Description :
-- Modified :
--               
-- 프로시저실행 : 
-- ======================================================================================
-- usp_ProductReDroping_get'2024-07-04','2024-07-04'

--EXEC usp_ProductReDroping_get  '','','','','','','','','2024-07-01','2024-07-31',''
 
CREATE PROCEDURE [dbo].[usp_ProductReDroping_get]
	@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = Null,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pIsOutputRoute BIT = NULL
AS

BEGIN
	set @pWorkCenterCode ='VVT_F2'
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

	EXEC usp_syncSTB_DefectRepairInfo
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,b.CreateDateTime)>@FromDate 
		 and isnull(b.ProdDateTime,b.CreateDateTime)<@ToDate and  SUBSTRING (c.Barcode, 1, 1) !='M'
	 ),
Table1  as (
		select
		PO.DefectSummaryNoBeforeDroping as OldDefectSummaryNo,
		PO.LotBeforeReDroping as OldLotNo,
		SI.PONo as OldPoNo,
		PO.PONo as NewPoNo
		 from STB_ProductionOrderInfo PO 
		left outer  join  STB_SetInfo SI  on  Po.LotBeforeReDroping =SI.Barcode
		where  PO.DefectSummaryNoBeforeDroping is not null and  PO.LotBeforeReDroping is not null
), table2 as (
		select 
		tb1.OldPoNo,
		tb1.OldDefectSummaryNo, 
		tb1.OldLotNo,
		tb1.NewPoNo,
		SI.Barcode as Newbarcode
	
		from table1 tb1
				left outer join  STB_SetInfo SI  on  tb1.NewPoNo =SI.PONo 
) ,
RawView as (
 	select  c.Barcode,isnull(b.RouteCode,a.FindRouteCode) RouteCode,isnull(b.RouteCode,a.FindRouteCode) as FindRouteCode,c.ControlNo,c.MaterialCode,
		InputLineCode,isnull(b.MachineCode,'')MachineCode,isnull(b.WorkerCode,'')WorkerCode,SIExtText07,SIExtInt01,DefectCode,
		isnull(max(b.ProdQty),0) as ProdQty, sum(isnull(a.DefectQty,0)) as DefectQty,  sum(isnull(a.RepairQty,0)) as RepairQty ,
		isnull(max(b.ProdDateTime),max(a.CreateDateTime)) as ProdDateTime, dateadd(second,-6,max(a.CreateDateTime)) as CreateDateTime, a.DefectSummaryNo
		from  STB_SetInfo c with(nolock) 
		 left  outer join  STB_ReDropping  a    with(nolock)  on  a.ControlNo=c.ControlNo 
		 left outer join   STB_ProdRouteHist     b	 with(nolock)   on  c.ControlNo=b.ControlNo	 and  a.FindRouteCode = b.RouteCode
		
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) 
		 and c.Barcode not in ( select tb2.Newbarcode as Barcode  from table2 tb2  where  tb2.Newbarcode is not null)
		 and    (isnull(b.ProdDateTime,a.CreateDateTime)>@FromDate and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,a.CreateDateTime)<@ToDate) and a.isStatus = 1
		 group by c.Barcode,b.RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,DefectCode,a.DefectSummaryNo
) 
,

X as(
		select  
		 RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode as LineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,DefectCode,RV.DefectSummaryNo,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		  RV.ProdDateTime	
		 , (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
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
		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode

		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster     MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
		
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime,DefectCode,RV.DefectSummaryNo
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
			, X.Barcode,
			X.DefectSummaryNo
			--, dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice
			--, dbo.fnGetWastePriceByMaterial(@CompanyCode
			--                              , @WorkCenterCode
			--							  , X.LineCode
			--							  , X.MaterialCode
			--							  , 'PC'
			--							  , X.RouteCode
			--							  , X.DefectQty) AS DefectWastePrice			
		from X WITH(NOLOCK)
				 --left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=x.ControlNo and a.FindRouteCode = x.RouteCode and CreateDateTime between @FromDate and @ToDate
				 left  outer join  STB_DefectInfo        di   with(nolock)  on  X.DefectCode = di.DefectCode
		    --,Z WITH(NOLOCK)
	)

	 SELECT  /* dbo.fnGetLocalTime(*/A.작업일자--,@pUtcOffset) AS 작업일자
				,A.라인코드
				,A.공정코드
				,A.공정명
				,A.품목코드
				,A.품목명
				,A.불량코드
				,A.불량명
				--,A.불량내용
				,A.불량수량
				,A.불량률
				--,SUM(B.불량률) AS 누적불량률
				,A.ControlNo
				,A.Barcode as LotNo 

				--, ISNULL(A.불량수량, 0) *  
				--case when A.작업일자<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0) 
				--	when A.작업일자>='2023-10-01' and 불량코드 not like 'V-29_XX1' and 불량코드 not like 'V-29_XX2' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA) 
				--	else  0  end   
				--	as     DefectWastePrice 

				--,case when A.불량코드 in ('V-24_2DD','V-24_00','V-24_2CW','V-24_2RI','V-24_2RY','V-24_QQ','V-24_X03','V-24_X12') then isnull(case when weightLastA.valweight=0 then weightLast.valweight else weightLastA.valweight end,weightLast.valweight)
				--		when A.불량코드 in ('','','','','') then isnull(weightLastB.valweight,weightLast.valweight) 
				--		when A.불량코드 in ('V-24_2DR','','','','') then isnull(weightLastC.valweight,weightLast.valweight) 
				--		else weightLast.valweight 
				-- end as WeightUnit  

		  --, ISNULL(A.불량수량, 0) * (case when A.불량코드 in ('V-24_2DD','V-24_00','V-24_2CW','V-24_2RI','V-24_2RY','V-24_QQ','V-24_X03','V-24_X12') then isnull(case when weightLastA.valweight=0 then weightLast.valweight else weightLastA.valweight end,weightLast.valweight)
				--		when A.불량코드 in ('','','','','') then isnull(weightLastB.valweight,weightLast.valweight) 
				--		when A.불량코드 in ('V-24_2DR','','','','') then isnull(weightLastC.valweight,weightLast.valweight) 
				--		else weightLast.valweight 
				-- end)/1000 as WasteWeight 
				,c.PoNo,
				A.DefectSummaryNo
	    FROM STB_Defect_VVT A WITH(NOLOCK) 
		left outer join [dbo].[fn_VVT_StagePrices]() vwup  on vwup.model = A.품목코드 and vwup.routecode=A.공정코드 
		left outer join [dbo].[fn_VVT_StagePricesNEW]() vwupNEW on vwupNEW.model = A.품목코드 and vwupNEW.routecode=A.공정코드 
		left outer join STB_SetInfo c  with(nolock) on A.ControlNo=c.ControlNo
		outer apply  
				(select top 1 * from [dbo].[fn_VVT_StagePricesNEW]()  vwupNEW1 
				where A.품목명 like '%'+vwupNEW1.partno+'%' and vwupNEW1.routecode=A.공정코드 
				)vwupNEW1 

			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 4) = weight3.model  and  weight3.routecode=A.공정코드  
			   ) weightLast 
			   			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 4) = weight3.model  and  weight3.routecode=A.공정코드+'A'
			   ) weightLastA
			   			   OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 4) = weight3.model  and  weight3.routecode=A.공정코드+'B'
			   ) weightLastB
			   			  OUTER APPLY (select top 1 * from     [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(A.품목명, CHARINDEX('(', A.품목명, 0) + 1, 4) = weight3.model  and  weight3.routecode=A.공정코드 and weight3.routecode='V-23'
			   ) weightLastC
	   where (작업일자 between @FromDate  and @pToDate ) and   불량코드 ='V-29_XX1' or 불량코드 ='V-29_XX2'  or 불량코드 ='V-29_XX3'
	   ORDER BY ISNULL(A.불량수량, 0) *   convert(numeric(38,15), ISNULL(vwup.ProcessUnitPriceEA,0) )  desc
	  
END



