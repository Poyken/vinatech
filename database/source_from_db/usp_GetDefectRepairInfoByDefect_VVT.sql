
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	유형별 불량현황을 조회합니다
-- Modified: 2019.09.16 자재그룹삭제 및 공정코드추가 
-- =============================================
-- EXEC [usp_GetDefectRepairInfoByDefect_Dashboard] '','','VVT','VVT_F1','','V-22','','','2019-01-26','2020-02-25'         --45건
-- EXEC [usp_GetDefectRepairInfoByDefect_VVT] '','','VVT','','','','','','2019-01-26','2020-02-25'         --45건


-- 유형별 불량현황 전체조회 -> EXEC usp_GetDefectRepairInfoByDefect '','','','','','','','','2019-09-01','2019-09-30' 
-- 불량단가, 불량금액, 제품검사합격여부 추가 2020.02.24 By Jackaroe #200224

CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoByDefect_VVT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	--@pProductGroupCode VARCHAR(20) = NULL,
	@pFindRouteCode VARCHAR(10) = NULL,                            -- 2019.09.16 추가 (주영진차장 요청)
	@pDefectCode VARCHAR(20) = NULL,                                -- 2019.09.16 추가 (주영진차장 요청)
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	--DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	--DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END


	DECLARE @LineCode          VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	--DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @FindRouteCode VARCHAR(10) = CASE WHEN ISNULL(@pFindRouteCode,'') = '' THEN '*' ELSE @pFindRouteCode END
	DECLARE @DefectCode      VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END

	DECLARE @MaterialCode     VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '*' ELSE @pMaterialCode   END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	
    SELECT
			DRI.PONo,
			DRI.DayPlanNo,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName AS FindLineName,
			DRI.FindRouteCode,
			--Replace(DRI.FindRouteCode, 'V', 'E') as FindRouteCode,
			RI.RouteName AS FindRouteName,

				--CASE WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-22' THEN '권취'
				--      WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-23' THEN '고무전'
			 --      WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-24' THEN '커링'
				--   WHEN Replace(DRI.FindRouteCode,  'V', 'E') = 'E-25' THEN '슬리빙'
				--   WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-26' THEN '에이징'
				--   WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-27' THEN '외관'
				--   WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-28' THEN '포장'    ELSE '기타' END FindRouteName,
				--   --WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-33' THEN '절곡'
				--   --WHEN Replace(DRI.FindRouteCode, 'V', 'E') = 'E-40' THEN '내전압'  

			DRI.FindJobdate,
			DRI.FindShiftCode,
			VFSC.[Shift] AS FindShiftName,
			DRI.FindTimeCode,
			--DRI.DefectCauseCode,
			--DCI.BasicDefectCauseName AS DefectCauseName,
			--DRI.DefectCauseDetailCode,
			--DRI.DefectCauseType,
			--DCT.DefectCauseName AS DefectCauseTypeName,
			--CASE WHEN DRI.DefectCauseType = 'S' THEN DRI.DutyCostCenterCode	ELSE DRI.DutyVendorCode END AS CostCenterCode,
			--CASE WHEN DRI.DefectCauseType = 'S' THEN CUI.CustomerName    	ELSE CUI.CustomerName   END AS CostCeneterName,
			DRI.DefectCode,
			--REPLACE(DRI.DefectCode, 'V_', 'E_') as DefectCode,
			DI.BasicDefectName AS DefectName,
			--DRI.DefectExtDesc,
			SUM(DRI.DefectQty - DRI.RepairQty) AS DefectQty,
			DRI.RepairType,		                                                                                                                                   -- 수리여부
			RT.RepairTypeName,
			--DRI.RepairQty
			DRI.CreateUserID,                                                                                                                                      -- 추가사항
			MAX(DRI.CreateDateTime) AS CreateDateTime																									   -- 추가사항
			, MAX(SI.Barcode)           AS LotNo                                                                                                               -- 추가사항
			, SI.ControlNo
			, PRH.WorkerCode
			, PWI.WorkerName
			, CASE WHEN SUM(DRI.DefectQty - DRI.RepairQty) = 0 THEN 0 ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(DRI.DefectQty - DRI.RepairQty)) / SUM(DRI.DefectQty - DRI.RepairQty) END AS WasteUnitPrice -- #200224
			, dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(DRI.DefectQty - DRI.RepairQty)) AS WastePrice -- #200224
			, CASE WHEN DRI.FindRouteCode IN ( 'E-27', 'V-37') THEN SI.LotDecisionResult ELSE NULL END AS LotDecisionResult
			, DRI.CompanyCode  AS CompanyCode
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                               -- SELECT * FROM STB_DefectRepairInfo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode
			--LEFT OUTER JOIN (SELECT Replace(RouteCode, 'V', 'E') AS RouteCode FROM STB_RouteInfo )         RI  ON RI.RouteCode = DRI.FindRouteCode

			--LEFT OUTER JOIN STB_SubRouteInfo SRI WITH(NOLOCK)						ON SRI.SubRouteCode = DRI.FindSubRouteCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode
			--LEFT OUTER JOIN STB_DefectLanguageInfo DLI WITH(NOLOCK)				ON DLI.DefectCode = DRI.DefectCode			--	AND DLI.LanguageCode = @pProcessLanguage
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode
			--LEFT OUTER JOIN STB_DefectCauseLanguage DCGL WITH(NOLOCK)	 		ON DCGL.DefectCauseCode = DCI.DefectCauseCode			--	AND DCGL.LanguageCode = @pProcessLanguage
			LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)						ON CUI.CustomerCode = DRI.DutyVendorCode
			LEFT OUTER JOIN VW_RepairType RT												ON RT.RepairType = DRI.RepairType
			LEFT OUTER JOIN VW_DefectCauseType DCT										ON DCT.DefectCauseType = DRI.DefectCauseType
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)		ON UI.UserID = DRI.RepairUserID
			LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)							ON VFSC.ShiftCode = DRI.FindShiftCode
			LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)							ON VCSC.ShiftCode = DRI.CauseShiftCode			
			LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK) 
			             ON PRH.ControlNo = DRI.ControlNo      -- 2019.09.17 추가 조인
						AND PRH.RouteCode = DRI.FindRouteCode
						
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PRH.WorkerCode = PWI.WorkerCode


	WHERE 1=1
			AND (DRI.CompanyCode LIKE @CompanyCode) 
			AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 
			--AND	MM.ProductGroupCode LIKE @ProductGroupCode 
			AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
			AND	(@LineCode = '*' OR DRI.FindLineCode = @LineCode) 
			AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
			AND	DRI.RepairType NOT IN ('MISSING')
			AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                             -- 추가
			AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                      -- 추가
	GROUP BY
			DRI.PONo,
			DRI.DayPlanNo,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName,
			DRI.FindRouteCode,
			RI.RouteName,
			DRI.FindJobdate,
			DRI.FindShiftCode,
			VFSC.[Shift],
			DRI.FindTimeCode,
			DRI.DefectCode,
			DI.BasicDefectName,
			DRI.RepairType,
			RT.RepairTypeName,
			DRI.CreateUserID,
			SI.Barcode,
			SI.ControlNo,
			PRH.WorkerCode,
			PWI.WorkerName,
			CASE WHEN DRI.FindRouteCode IN ( 'E-27', 'V-37') THEN SI.LotDecisionResult ELSE NULL END,
			 DRI.CompanyCode

END