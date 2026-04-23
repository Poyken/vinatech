
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	유형별 불량현황을 조회합니다
-- Modified: 2019.09.16 자재그룹삭제 및 공정코드추가 
--             2020.02.24 불량단가, 불량금액, 제품검사합격여부 추가  By Jackaroe #200224
--             2020.02.25 베트남공정코드 추가
-- =============================================
--                                     EXEC [usp_GetDefectRepairInfoByDefect] '','','','','ASSYLINE-07','','','','2019-09-01','2019-09-05'         
--                                     EXEC [usp_GetDefectRepairInfoByDefect] '','','','','ASSYLINE-07','E-22','','','2019-09-01','2019-09-05'         
-- 유형별 불량현황 전체조회 -> EXEC usp_GetDefectRepairInfoByDefect '','','','','','','','','2024-09-01','2024-10-30' 
--  EXEC usp_GetDefectRepairInfoByDefect '','','','VVT_F1','','','','','2024-09-03','2024-09-03' 
--EXEC usp_GetDefectRepairInfoByDefect '','','','VVT_F1','','','','','2024-09-04','2024-09-04' 

CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoByDefect]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(200) = NULL,
	--@pProductGroupCode VARCHAR(20) = NULL,
	@pFindRouteCode VARCHAR(10) = NULL,                            -- 2019.09.16 추가 (주영진차장 요청)
	@pDefectCode VARCHAR(20) = NULL,                                -- 2019.09.16 추가 (주영진차장 요청)
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	--DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	--DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END



	DECLARE @LineCode          VARCHAR(200) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	--DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @FindRouteCode VARCHAR(10) = CASE WHEN ISNULL(@pFindRouteCode,'') = '' THEN '*' ELSE @pFindRouteCode END
	DECLARE @DefectCode      VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END

	DECLARE @MaterialCode     VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '*' ELSE @pMaterialCode   END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	
		--DECLARE @test         VARCHAR(200) =@FromDate

		--raiserror(@test,16,1)

    SELECT
			DRI.PONo,
			DRI.DayPlanNo,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName AS FindLineName,
			DRI.FindRouteCode,
			RI.RouteName AS FindRouteName,
			--DRI.FindJobdate,
			CONVERT(DATETIMEOFFSET, DRI.FindJobdate) AS FindJobdate,           --2020.02.25
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
			SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) AS DefectQty,
			DRI.RepairType,		                                                                                                                                   -- 수리여부
			RT.RepairTypeName,
			--DRI.RepairQty
			DRI.CreateUserID,                                                                                                                                      -- 추가사항
			MAX(DRI.CreateDateTime) AS CreateDateTime																									   -- 추가사항
			, MAX(SI.Barcode)           AS LotNo                                                                                                               -- 추가사항
			, SI.ControlNo
			, PRH.WorkerCode
			, PWI.WorkerName
			--, CASE WHEN SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) = 0 THEN 0
			--       ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) / SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) END AS WasteUnitPrice -- #200224
			, CASE WHEN  
								(CASE WHEN SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) = 0 THEN 0
								ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) / SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) END)  <= 0 THEN 0.00
					
				ELSE 
					CONVERT(NUMERIC(10,4), 	(CASE WHEN SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) = 0 THEN 0
								ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) / SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0)) END))
			
			END  AS WasteUnitPrice -- #200224
			, dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) AS WastePrice -- #200224
			, CASE WHEN DRI.FindRouteCode IN ('E-27', 'V-27') THEN MQI.DecisionResult ELSE NULL END AS LotDecisionResult
			,dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, 1) AS MaterialDcUnitPrice
			,dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) AS MaterialDcPrice
			,dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, 1) AS MaterialPcUnitPrice
			,dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, SUM(ISNULL(DRI.DefectQty, 0) - ISNULL(DRI.RepairQty, 0))) AS MaterialPcPrice
			,   (	 SELECT  BaseMonth
			     FROM STB_AggregationPeriod
				 WHERE 1=1										   
				  AND  FromDate  <= FindJobdate
				  AND  ToDate     >=FindJobdate
										)  AS YearMonth
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                               -- SELECT * FROM STB_DefectRepairInfo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode
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
			LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)                    ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode    -- 2019.09.17 추가 조인
						
						
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PRH.WorkerCode = PWI.WorkerCode

			LEFT OUTER JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = SI.LotNumber


	WHERE 1=1
			AND (@CompanyCode = '*' OR DRI.CompanyCode = @CompanyCode) 
			AND	(@WorkCenterCode = '*' OR DRI.WorkCenterCode = @WorkCenterCode) 
			--AND	MM.ProductGroupCode LIKE @ProductGroupCode 
			AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
			AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
			AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
			AND	DRI.RepairType NOT IN ('MISSING')
			AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                             -- 추가
			AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                      -- 추가
			AND DRI.FindLineCode IS NOT NULL
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
			CASE WHEN DRI.FindRouteCode IN ('E-27', 'V-27') THEN MQI.DecisionResult ELSE NULL END

END