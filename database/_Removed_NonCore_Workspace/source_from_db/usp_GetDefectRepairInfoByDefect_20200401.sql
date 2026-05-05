
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	유형별 불량현황을 조회합니다
-- Modified: 2019.09.16 자재그룹삭제 및 공정코드추가 
--             2020.02.25 베트남공정코드 추가
-- =============================================
-- 유형별 불량현황 전체조회 ->  usp_GetDefectRepairInfoByDefect_20200401   '','','VVT','','','','','','2020-03-26','2020-04-25' 


CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoByDefect_20200401]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pCompanyCode VARCHAR(20) = NULL,
					@pWorkCenterCode VARCHAR(20) = NULL,
					@pLineCode VARCHAR(200) = NULL,	
					@pFindRouteCode VARCHAR(10) = NULL,                            
					@pDefectCode VARCHAR(20) = NULL,                                
					@pMaterialCode VARCHAR(50) = NULL,
					@pFromDate DATE = NULL,
					@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	DECLARE @LineCode          VARCHAR(200) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END	
	DECLARE @FindRouteCode VARCHAR(10) = CASE WHEN ISNULL(@pFindRouteCode,'') = '' THEN '*' ELSE @pFindRouteCode END
	DECLARE @DefectCode      VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END

	DECLARE @MaterialCode     VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '*' ELSE @pMaterialCode   END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	DECLARE @ToDay               VARCHAR(08) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)                -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)


	-- 원본수정 (2020.03.31)
	                    

            SELECT SUM(AA.DAILY_SUM)     AS DAILY_SUM
	               ,  SUM(AA.MONTH_SUM)  AS MONTH_SUM

             FROM (
						-- 전일
						SELECT						
							      SUM(DRI.DefectQty - DRI.RepairQty) AS DAILY_SUM
								  ,                                        0 AS MONTH_SUM
						FROM
													  STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
								LEFT OUTER JOIN STB_MaterialMaster  MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
								LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
								LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
								LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
								LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
								LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
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
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								--AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								AND	DRI.RepairType NOT IN ('MISSING')
								AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                    
								 AND DRI.FindJobdate  = '2020-03-30'

				                -- AND DRI.FindJobdate  LIKE @ToDay + '%'
								-- AND Convert(VARCHAR(10), DRI.FindJobdate, 121)  = @ToDay 
								-- AND Convert(VARCHAR(10), DRI.FindJobdate, 121)  LIKE @ToDay + '%'
					          
						UNION 


						SELECT				
						                                                  0  AS DAILY_SUM		
							    , SUM(DRI.DefectQty - DRI.RepairQty) AS MONTH_SUM
						FROM
													  STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
								LEFT OUTER JOIN STB_MaterialMaster  MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
								LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
								LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
								LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
								LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
								LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
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
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								AND	DRI.RepairType NOT IN ('MISSING')
								AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)         

								 ) AA

	-- [원본백업]

 --   SELECT
			
	--		--DRI.MaterialCode,
	--		--MM.MaterialName,
	--		--DRI.FindLineCode,
	--		--FLI.LineName AS FindLineName,
	--		--DRI.FindRouteCode,
	--		--RI.RouteName AS FindRouteName,												
	--		DRI.DefectCode,
	--		DI.BasicDefectName AS DefectName,			
	--		DI.DefectDesc AS DefectDesc,			
	--		SUM(DRI.DefectQty - DRI.RepairQty) AS DefectQty
	--		--DRI.RepairType,		                                                                                                                                   -- 수리여부
	--		--RT.RepairTypeName,			
	--		--DRI.CreateUserID,                                                                                                                                      -- 추가사항
	--		--, MAX(DRI.CreateDateTime) AS CreateDateTime																									   -- 추가사항
	--		--, MAX(SI.Barcode)           AS LotNo                                                                                                               -- 추가사항
	--		--, SI.ControlNo			
	--		--, CASE WHEN SUM(DRI.DefectQty - DRI.RepairQty) = 0 THEN 0
	--		--       ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(DRI.DefectQty - DRI.RepairQty)) / SUM(DRI.DefectQty - DRI.RepairQty) END AS WasteUnitPrice -- #200224
	--		--, dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, SUM(DRI.DefectQty - DRI.RepairQty)) AS WastePrice -- #200224
			
	--FROM
	--		STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
	--		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
	--		LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
	--		LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
	--		LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
	--		LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
	--		LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
	--		LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)						ON CUI.CustomerCode = DRI.DutyVendorCode
	--		LEFT OUTER JOIN VW_RepairType RT												ON RT.RepairType = DRI.RepairType
	--		LEFT OUTER JOIN VW_DefectCauseType DCT										ON DCT.DefectCauseType = DRI.DefectCauseType
	--		LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)		ON UI.UserID = DRI.RepairUserID
	--		LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)							ON VFSC.ShiftCode = DRI.FindShiftCode
	--		LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)							ON VCSC.ShiftCode = DRI.CauseShiftCode			
	--		LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)                    ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode    -- 2019.09.17 추가 조인
						
						
	--		LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PRH.WorkerCode = PWI.WorkerCode

	--		LEFT OUTER JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = SI.LotNumber


	--WHERE 1=1
	--		AND (DRI.CompanyCode LIKE @CompanyCode) 
	--		AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
	--		AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
	--		AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
	--		AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
	--		AND	DRI.RepairType NOT IN ('MISSING')
	--		AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                             -- 추가
	--		AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                      -- 추가
	--GROUP BY
	--		DRI.PONo,
	--		DRI.DayPlanNo,
	--		DRI.MaterialCode,
	--		MM.MaterialName,
	--		DRI.FindLineCode,
	--		FLI.LineName,
	--		DRI.FindRouteCode,
	--		RI.RouteName,
	--		DRI.FindJobdate,
	--		DRI.FindShiftCode,
	--		VFSC.[Shift],
	--		DRI.FindTimeCode,
	--		DRI.DefectCode,
	--		DI.BasicDefectName,
	--		DRI.RepairType,
	--		RT.RepairTypeName,
	--		DRI.CreateUserID,
	--		SI.Barcode,
	--		SI.ControlNo,
	--		PRH.WorkerCode,
	--		PWI.WorkerName,
	--		CASE WHEN DRI.FindRouteCode IN ('E-27', 'V-27') THEN MQI.DecisionResult ELSE NULL END,
	--		DI.DefectDesc 

END