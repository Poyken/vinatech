
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	유형별 불량현황을 조회합니다
-- Modified: 2019.09.16 자재그룹삭제 및 공정코드추가 
-- =============================================
-- EXEC [usp_GetDefectRepairInfoByDefect_TEST] '','','','','ASSYLINE-07','E-22','','','2019-09-01','2019-09-05'         --45건


CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoByDefect_TEST]
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
	DECLARE @LineCode          VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	--DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @FindRouteCode VARCHAR(10) = CASE WHEN ISNULL(@pFindRouteCode,'') = '' THEN '%' ELSE @pFindRouteCode END
	DECLARE @DefectCode      VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '%' ELSE @pDefectCode END

	DECLARE @MaterialCode     VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '%' ELSE @pMaterialCode   END
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
			RI.RouteName AS FindRouteName,
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
			DI.BasicDefectName AS DefectName,
			--DRI.DefectExtDesc,
			SUM(DRI.DefectQty) AS DefectQty,
			DRI.RepairType,		                                                                                                                                   -- 수리여부
			RT.RepairTypeName,
			--DRI.RepairQty
			DRI.CreateUserID,                                                                                                                                      -- 추가사항
			MAX(DRI.CreateDateTime) AS CreateDateTime																									   -- 추가사항
			, MAX(SI.Barcode)           AS LotNo           
			, PRH.ControlNo
			, PRH.WorkerCode 
			, (SELECT WorkerName FROM STB_ProdWorkerInfo  SPM WHERE SPM.WorkerCode = MAX(PRH.WorkerCode) ) AS WorkerName
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                               -- SELECT * FROM STB_DefectRepairInfo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode
			--LEFT OUTER JOIN STB_SubRouteInfo SRI WITH(NOLOCK)						ON SRI.SubRouteCode = DRI.FindSubRouteCode
			LEFT OUTER JOIN STB_LineInfo CLI WITH(NOLOCK)								ON CLI.LineCode = DRI.CauseLineCode
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
			INNER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)						    ON PRH.ControlNo = SI.ControlNo        AND  PRH.ControlNo = DRI.ControlNo AND	PRH.RouteCode = RI.RouteCode
			

	WHERE 1=1
			AND (DRI.CompanyCode LIKE @CompanyCode) 
			AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 
			--AND	MM.ProductGroupCode LIKE @ProductGroupCode 
			AND	DRI.MaterialCode LIKE @MaterialCode 
			AND	(DRI.FindLineCode LIKE @LineCode) 
			AND	(DRI.FindJobdate >= @FromDate AND DRI.FindJobdate <= @ToDate) 
			AND	DRI.RepairType NOT IN ('MISSING', 'FINISH')
			AND DRI.FindRouteCode LIKE @FindRouteCode                                             -- 추가
			AND DRI.DefectCode LIKE @DefectCode                                                      -- 추가
			--AND SI.Barcode = 'VJJR023R015603'
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
			PRH.ControlNo,
			PRH.WorkerCode
      ORDER BY DRI.FindRouteCode 

END


-- SELECT * FROM STB_SetInfo
-- SELECT * FROM STB_ProdRouteHist WHERE  ControlNo ='20190902000079'