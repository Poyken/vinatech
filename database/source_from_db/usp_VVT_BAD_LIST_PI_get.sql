-- ==================================================================
-- Author      : kilee
-- Create date : 2019-12-13
-- Browsable   : true
-- Group       :  Power-BI 모니터링 화면 > 베트남 대시보드  > 전일Big5
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    :  Power-BI 베트남 대시보드에서 수량부분 - 일간불량 BIG5
-- ==================================================================

-- [프로시저 실행문]      usp_VVT_BAD_LIST_PI_get   '','','VVT','','','','','','2020-03-30','2020-03-30'    -- 이전것

--                      EXEC usp_VVT_BAD_LIST_PI_get  '','','VVT','','','','',''   -- 최근거




CREATE PROCEDURE [dbo].[usp_VVT_BAD_LIST_PI_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(200) = NULL,	
	@pFindRouteCode VARCHAR(10) = NULL,                            
	@pDefectCode VARCHAR(20) = NULL,                                
	@pMaterialCode VARCHAR(50) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	DECLARE @LineCode          VARCHAR(200) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END	
	DECLARE @FindRouteCode VARCHAR(10) = CASE WHEN ISNULL(@pFindRouteCode,'') = '' THEN '*' ELSE @pFindRouteCode END
	DECLARE @DefectCode      VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END

	DECLARE @MaterialCode     VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '*' ELSE @pMaterialCode   END
	--DECLARE @FromDate DATE = @pFromDate
	--DECLARE @ToDate    DATE = @pToDate


	-- 원본수정 (2020.03.31)
	 SELECT TOP(5) AA.DefectDesc AS 불량종류
		          ,  AA.DefectQty      AS 불량수량
			FROM (
						SELECT						
								ROW_NUMBER() OVER( ORDER BY SUM(DRI.DefectQty - DRI.RepairQty) DESC) 순위										
						      , DG.BasicDefectGroupName              AS DefectDesc    -- 어쩔수없이 이걸로  
							  --, DRI.DefectCode
							  --, DI.BasicDefectName                    AS DefectName
							  --, DI.DefectDesc                            AS DefectDesc
							  , SUM(DRI.DefectQty - DRI.RepairQty) AS DefectQty
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

								LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				             ON DI.DefectGroupCode = DG.DefectGroupCode                                                        --2020.03.31 공정그룹으로 변경하면서 추가

						WHERE 1=1
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								--AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								
								AND	DRI.FindJobdate = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)           -- 전일자로 하드코딩                   ex)  SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11) 
								AND	DRI.RepairType NOT IN ('MISSING')
								AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                    
						GROUP BY
						        --DRI.DefectCode
							  --, DI.BasicDefectName         
							     DG.BasicDefectGroupName
							  --, DI.DefectDesc                
						  --ORDER BY 순위
						  	)  AA						
			ORDER BY  AA.순위


-- 원본백업 [2020.03.30까지 사용]
--ALTER PROC [dbo].[usp_VVT_BAD_LIST_PI_get]
--				@pProcessUserID VARCHAR(20),
--				@pProcessLanguage VARCHAR(20),
--				@pMonth DateTime,
--				@pSizeCode VARCHAR(20) = null,
--				@pCompanyCode VARCHAR(20) = NULL                                           

--AS

--BEGIN
--	SET NOCOUNT ON;

--	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
--    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
--	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
--	DECLARE @Month               VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)	
--	DECLARE @SizeCode            VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
--	DECLARE @ToDay               VARCHAR(08) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                    -- 전일자 두자리    SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')   	
	
	-- 원본백업
		 --  SELECT TOP(5) AA.BAD_Kind AS 불량종류
		 --         ,  AA.Qty                 AS 불량수량
			--FROM (
			--			SELECT ROW_NUMBER() OVER( ORDER BY QTY DESC) 순위
			--				   ,  *     
			--			FROM STB_BAD_LIST2
			--			WHERE 1=1
			--			 --AND StandardDate = '20200226'					
			--			   AND StandardDate LIKE   @ToDay + '%'
			--		)  AA						
			--ORDER BY  AA.순위
			 
 END

 