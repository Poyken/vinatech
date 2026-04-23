-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-02-24
-- Browsable : true
-- Group : 생산관리 > [B800] 전극생산현황 
-- Description:	
-- Modified:
--				2020.02.27 품목코드, 명 추가 (안제헌대리 요청사항)
--				2020.03.02 Mixing 추가(안제헌대리 요청사항)
--              2020.07.06 수율추가 및 전극공정2개만 (안제헌요청)
--              2020.07.07 합계추가 
--              2020.12.28 CompanyCode 전체조회

-- Exec [usp_Vietnam_ElectrodeProdRouteHist_get] 'klee', 'Korean', '2021-03-01 00:00:00', '2021-03-12 00:00:00', '', 'VVT'
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeSlittingQty_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATEtime,
						@pToDate DATEtime,					
						@pElectrodeRouteCode VARCHAR(20) = NULL,
						@pWHCode VARCHAR(20) = NULL,
						@pCompanyCode VARCHAR(20) = NULL                   -- 사업장 코드 추가 (2020.10.15),
AS

BEGIN

	Declare @FromDate               Datetime = convert(datetime, convert(varchar(10),@pFromDate,120)+' 10:00:00' ,120)
			 , @ToDate                   Datetime = convert(datetime, convert(varchar(10),Dateadd(Day,1,@pToDate),120)+' 10:00:00' ,120)
			 --, @ElectrodeRouteCode  VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteCode, '') = '' THEN '*' ELSE @pElectrodeRouteCode END
	  --    , @ElectrodeRouteGroup VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END
			 , @CompanyCode         VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
			  , @WHCode         VARCHAR(20) = CASE WHEN ISNULL(@pWHCode,'') = '' THEN '*' ELSE @pWHCode END

	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END
	
	--DECLARE @ElectrodeLotNumber VARCHAR(20)
	--SET @ElectrodeLotNumber = @pElectrodeLotNumber
	
	SELECT   ESR.ElectrodeLotNumber
			,ESR.Barcode	
			,MM.MaterialName
			,SI.Materialcode
			,ESR.Seq
			,ESR.ElectrodeThick
			,ESR.SlittingWidth
			,ESR.ProductionQty
			,ESR.GoodQtyLength
			,isnull(ss.CreateDateTime,ESR.CreateDateTime) CreateDateTime
			,isnull(ss.CreateUserID,ESR.CreateUserID) CreateUserID
			,ESR.ChangeDateTime
			,ESR.ChangeUserID
			--,'Report' AS CommandType			
			,ESR.LotUniqueNumber
			--,SVEOH.CreateUserId as EmpCreate
			--,SVEOH.VCMLine as VCMLine
			,RIGHT(ESR.Barcode, 3) AS CutNo
			,MM.MaterialSource
			,ss.PartNo, ss.Farad, ss.RollQty, ss.Location  
			--,ss.MaterialSource, ss. ElectrodeThick, ss.SlittingWidth ,ss.GoodQtyLength
			--, ss.CreateDateTime, ss.CreateUserID 
			,isnull(ss.WarehouseCode,'ELEC_VN_WH') as WarehouseCode
			,ss.ListUsed, ss.ListDate, ss.LotCount
	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	  left outer join stb_slittingStock_VVT ss WITH(NOLOCK)  on ESR.Barcode = ss.Barcode
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  --LEFT OUTER JOIN STB_Vietnam_ElectrodeOutHist SVEOH WITH(NOLOCK) on ESR.LotUniqueNumber = SVEOH.LotUniqueNumber
	where 
	ESR.CreateDateTime>=@FromDate  
	and ESR.CreateDateTime<=@ToDate
	and (@WHCode='*' or isnull(ss.WarehouseCode,'ELEC_VN_WH') = @WHCode)
	 --WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
	 ORDER BY ESR.CreateDateTime, ESR.ElectrodeLotNumber,ESR.Barcode	,ESR.Seq

END

/*
select top 100 * from
STB_ElectrodeRollPressingInfo a WITH(NOLOCK) 
left outer join STB_ElectrodeSlittingResult b  WITH(NOLOCK) on a.ElectrodeLotNumber=b.ElectrodeLotNumber
where b.Barcode is null

select top 100 * from
STB_ElectrodeCoatingInfo a WITH(NOLOCK) 
left outer join STB_ElectrodeSlittingResult b  WITH(NOLOCK) on a.ElectrodeLotNumber=b.ElectrodeLotNumber
where b.Barcode is null
*/