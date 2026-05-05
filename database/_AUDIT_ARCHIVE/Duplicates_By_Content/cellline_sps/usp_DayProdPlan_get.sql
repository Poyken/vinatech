-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리 > 일계획관리 > 일일생산계획관리
-- Description: 코팅롤 일일생산계획 ? 일일 생산계획 (1TAB)
-- Modified:  2019.10.07  CreateUserID 조건 추가
--            2020.08.04 DateTimeOffset 처리 / 사업장코드로 구분하면 문제가 되어 데이터의 사업장 코드로 @pUtcOffset를 조정
--            VNT : 540 / VVT : 660
-- 실행문 :  usp_DayProdPlan_get ' ' , '', NULL, 'VVT', 'VVT_F1' , '', '2025-05-11', '2025-05-16', 'HALB' , 'HALB', 'COATING-ROLL' ,'true' , '123456'
--             usp_DayProdPlan_get 'kilee3' , '', NULL, 'VNT', 'VNT_F1' , '', '2022-04-06', '2022-04-07', '' , '', '' ,'' , ''
-- ================================================================================================
CREATE PROCEDURE [dbo].[usp_DayProdPlan_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pBasicMaterialType VARCHAR(20) = NULL,
						@pMaterialTypeCode VARCHAR(20) = NULL,
						@pProductGroupCode VARCHAR(20) = NULL,
						@pCancelShow BIT = NULL,
						@pCreateUserID VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(30) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '%' ELSE @pBasicMaterialType END
	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @CancelShow BIT = ISNULL(@pCancelShow,0)
	DECLARE @CreateUserID VARCHAR(20) = CASE WHEN ISNULL(@pCreateUserID,'') = '' THEN '%' ELSE @pCreateUserID + '%' END

	/*declare @fd varchar(25) =@ToDate
	raiserror(@fd,16,1)*/
	;WITH DayProdPlan AS

	(

	-- 최종 SELECT 부분
		SELECT
				DPP.*
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE 1=1
			AND DPP.PlanDate BETWEEN @FromDate AND @ToDate
			AND DPP.CompanyCode LIKE @CompanyCode 
			AND DPP.WorkCenterCode LIKE @WorkCenterCode 
			AND DPP.LineCode LIKE @LineCode 
			AND DPP.IsCancel IN (CONVERT(BIT,0),@CancelShow)
			--AND DPP.CreateUserID LIKE @CreateUserID 

		--SELECT
		--		DPP.*
		--FROM
		--		STB_DayProdPlan DPP WITH(NOLOCK)
		--WHERE 1=1
		--	AND (DPP.PlanDate BETWEEN @FromDate AND @ToDate) 
		--	AND DPP.CompanyCode LIKE @CompanyCode 
		--	AND DPP.WorkCenterCode LIKE @WorkCenterCode 
		--	AND DPP.LineCode LIKE  'SLITTING%'
		--	AND DPP.IsCancel IN (CONVERT(BIT,0),@CancelShow)

	)


	SELECT
			DPP.DayPlanNo AS OldDayPlanNo,
			DPP.DayPlanNo,
			DPP.CompanyCode,
			CI.CompanyName,
			DPP.WorkCenterCode,
			WCI.WorkCenterName,
			DPP.PONo,
			DPP.MaterialCode,
			MM.MaterialName,
			--Case When DPP.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else MM.MaterialName end as MaterialName, --Ms Phuong update audit 2025-11-26
			Case When MM.MaterialName like '%2Batch%' Then ISNULL(SI.LotCount,0) * 2  Else ISNULL(SI.LotCount,0) End AS BatchQty ,   --2021.04.06 추가
				

			DPP.BomVersion,
			DPP.LineCode,
			LI.LineName,
			DPP.RouteCode,
			RI.RouteName,
			DPP.MachineCode,
			MCM.MachineName,
			DPP.MoldNumber,
			MDBI.MoldCategory1,
			DPP.MoldChangePlanTime,
			DPP.PlanWorkTime,
			dbo.fnGetLocalTime(DPP.PlanDate, @pUtcOffset) AS PlanDate,
			DPP.PlanShiftCode,
			SC.Shift AS PlanShift,
			DPP.ProdPrior,
			DPP.PlanQty,
			DPP.IsFixed,
			DPP.IsCancel,
			CONVERT(BIT,CASE WHEN DPP.DPPExtText01 = '1' THEN 1 ELSE 0 END) AS DPPExtText01,
			DPP.DPPExtText02,
			DPP.DPPExtText03,
			DPP.DPPExtText04,
			DPP.DPPExtText05,
			DPP.PlanCT,
			DPP.BarcodeModel,
			DPP.MonthlyLotSeq,
			DPP.MonthlyLotSeqText,
			DPP.ProdSnHeader,
			DPP.StartSerial,
			DPP.EndSerial,
			DPP.StartProdSn,
			DPP.EndProdSn,
			DPP.CurrentTarget,
			DPP.CreateDateTime,
			DPP.CreateUserID,
			DPP.ChangeDateTime,
			DPP.ChangeUserID,
			0 AS ProdQty,
			CONVERT(BIT,0) AS IsAddLot,
			CONVERT(NUMERIC(20,5), ISNULL(SI.LotCount,0)) AS LotCount,
			'' AS LotID
		
		  , case when SI.SIExtReal03 is not null then SI.SIExtReal03 else     -- Modified by Mr.Tung on 2022-04-07 for Thickness auto fill in the B440
			convert(  
					 numeric(20,5), 
					 (case when MM.MaterialThickness is null or rtrim(ltrim(MM.MaterialThickness))='' then '0.0' else MM.MaterialThickness end) 
				   ) 
			end  AS SIExtReal03,                                               -- Modified by Mr.Tung on 2022-04-07 for Thickness auto fill in the B440
			MM.MaterialUnit,
			POI.LotBeforeReDroping as LotBeforeReDroping
	FROM
			                      DayProdPlan DPP WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = DPP.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = DPP.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON MM.MaterialCode = DPP.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)						ON LI.LineCode = DPP.LineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				    ON RI.RouteCode = DPP.RouteCode
			LEFT OUTER JOIN VW_ShiftCode SC										ON SC.ShiftCode = DPP.PlanShiftCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)		ON MCM.MachineCode = DPP.MachineCode
			LEFT OUTER JOIN STB_MoldBasicInfo MDBI WITH(NOLOCK)			ON MDBI.MoldNumber = DPP.MoldNumber
			LEFT OUTER JOIN
			(
				SELECT
						SI.DayPlanNo,
						SI.SIExtReal03,
						COUNT(*) AS LotCount
				FROM
						STB_SetInfo SI
				WHERE
						SI.DayPlanNo IN (SELECT DayPlanNo FROM DayProdPlan)
				GROUP BY
						SI.DayPlanNo
					,   SI.SIExtReal03
			) SI
				ON SI.DayPlanNo = DPP.DayPlanNo

				LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)			ON DPP.PoNo = POI.PoNo
	WHERE 1=1
			AND MM.MaterialTypeCode LIKE @MaterialTypeCode
			AND (@MaterialTypeCode = '%' OR MT.BasicMaterialType IN (SELECT item FROM dbo.fnSplitToTable(',', @BasicMaterialType)))
			AND MM.ProductGroupCode LIKE '%' + @ProductGroupCode + '%'
			--and DPP.MaterialCode = 'ECVT30-333'
END