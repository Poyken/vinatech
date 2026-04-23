
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리 > [C420] 공정검사이력조회 > GRID2 공용검사항목이력
-- Description:	공용검사항목조회
-- Modified: 정렬 기준을 검사항목명에서 표시순서로 변경 구형규님 요청 By Jackaroe #200916
-- 2021.01.04 공정정보 추가 
-- 프로시저 실행: [usp_GetCommInspectionItemHistory] '','','20220102000011'
-- =======================================================================
CREATE PROCEDURE [dbo].[usp_GetCommInspectionItemHistory]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20) = NULL,
						@pProcessSteps VARCHAR(20) = NULL    --공정정보 추가 (권취, 커링 2022. 01. 02 Kangs) 
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @CommInspDocNo VARCHAR(20) = CASE WHEN ISNULL(@pCommInspDocNo,'') = '' THEN '%' ELSE @pCommInspDocNo END
	DECLARE @ProcessSteps VARCHAR(20) = CASE WHEN ISNULL(@pProcessSteps, '') = '' THEN '*' ELSE @pProcessSteps END                                           -- 추가사항 (2021.10.20)
    
	--SELECT
	--        --CASE WHEN CII.RouteCode = 'E-22' THEN '권취' 
	--		      -- WHEN CII.RouteCode = 'E-24' THEN '조립'  ELSE CII.RouteCode END  AS 공정구분,

 --            CASE WHEN CII.RouteCode IN ('V-22', 'E-22') THEN '권취' 
	--		         WHEN CII.RouteCode IN ('V-24', 'E-24') THEN '조립'  ELSE CII.RouteCode END  AS 공정구분,

	--		CIDI.CommInspDocItemNo AS OldCommInspDocItemNo,
	--		CIDI.CommInspDocItemNo,
	--		CIDI.CommInspDocNo,
	--		CIDI.CommInspItemCode,
	--		CII.CommInspItemName,
	--		CIDI.CommInspUnit,
	--		CIDI.CommInspItemDesc,
	--		CIDI.CommInspInputType,
	--		CIIT.CommInspInputTypeName,
	--		CIDI.CommInspItemSpec,
	--		CIDI.CommInspUpper,
	--		CIDI.CommInspLower,
	--		CIDI.ItemTargetQty,
	--		CIDI.ItemQty,
	--		CIDI.ImageFileID,
	--		CIDI.CommInspRemark,
	--		CIDI.CreateDateTime,
	--		CIDI.CreateUserID,
	--		CIDI.ChangeDateTime,
	--		CIDI.ChangeUserID,			
	--		Case When CII.CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY' THEN  dbo.fnGetElectrodeDensity (CIDI.CommInspDocNo, CII.DisplayIndex) ELSE 0 END  AS ElectrodeDensityValue  -- 밀도값계산 (구형규 요청 (2020-09-04))
	--	   , CIDI.ProcessSteps
	--FROM
	--		STB_CommInspDocItem CIDI WITH(NOLOCK)
	--		LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)			ON	CIDI.CommInspItemCode = CII.CommInspItemCode
	--		LEFT OUTER JOIN VW_CommInspInputType CIIT  WITH(NOLOCK)	 ON	CIDI.CommInspInputType =  CIIT.CommInspInputType
	--WHERE  1=1
	--   AND (CIDI.CommInspDocNo = @CommInspDocNo) 
	--   AND CIDI.CommInspItemCode <> 'RQV_V'
	--    AND (@ProcessSteps = '*' OR CIDI.ProcessSteps = @ProcessSteps)   -- 추가 (2021-10-20)
	-- ORDER BY CII.DisplayIndex -- CII.CommInspItemName #200916


	SELECT
	        --CASE WHEN CII.RouteCode = 'E-22' THEN '권취' 
			      -- WHEN CII.RouteCode = 'E-24' THEN '조립'  ELSE CII.RouteCode END  AS 공정구분,

             CASE WHEN CII.RouteCode IN ('V-22', 'E-22') THEN '권취' 
			         WHEN CII.RouteCode IN ('V-24', 'E-24') THEN '조립'  ELSE CII.RouteCode END  AS 공정구분,

			CIDI.CommInspDocItemNo AS OldCommInspDocItemNo,
			CIDI.CommInspDocItemNo,
			CIDI.CommInspDocNo,
			CIDI.CommInspItemCode,
			CII.CommInspItemName,
			CIDI.CommInspUnit,
			CIDI.CommInspItemDesc,
			CIDI.CommInspInputType,
			CIIT.CommInspInputTypeName,
			CIDI.CommInspItemSpec,
			CIDI.CommInspUpper,
			CIDI.CommInspLower,
			CIDI.ItemTargetQty,
			CIDI.ItemQty,
			CIDI.ImageFileID,
			CIDI.CommInspRemark,
			CIDI.CreateDateTime,
			CIDI.CreateUserID,
			CIDI.ChangeDateTime,
			CIDI.ChangeUserID,			
			Case When CII.CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY' THEN  dbo.fnGetElectrodeDensity (CIDI.CommInspDocNo, CII.DisplayIndex) ELSE 0 END  AS ElectrodeDensityValue  -- 밀도값계산 (구형규 요청 (2020-09-04))
		   , CIDI.ProcessSteps
	FROM
			STB_CommInspDocItem CIDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)			ON	CIDI.CommInspItemCode = CII.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType CIIT  WITH(NOLOCK)	 ON	CIDI.CommInspInputType =  CIIT.CommInspInputType
	WHERE  1=1
	   AND (CIDI.CommInspDocNo = @CommInspDocNo) 
	   AND CIDI.CommInspItemCode <> 'RQV_V'
	    AND (@ProcessSteps = '*' OR CIDI.ProcessSteps = @ProcessSteps)   -- 추가 (2021-10-20)
	 ORDER BY CII.DisplayIndex -- CII.CommInspItemName #200916

END