-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-30
-- Description : 수동 PO 생성 대화상자를 위한 Dummy 테이블 조회
-- Modified :
-- =============================================

--  exec [usp_GetDummyProductionOrderForCreateManual] '',''

CREATE PROCEDURE [dbo].[usp_GetDummyProductionOrderForCreateManual]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage VARCHAR(20) = @pProcessLanguage,			
				@PlanStartDate DATE,	
				@PlanEndDate DATE,
				@CompanyCode VARCHAR(20),
				@WorkCenterCode VARCHAR(20),
				@CompanyName NVARCHAR(50),
				@WorkCenterName NVARCHAR(50)
			--	@CompanyCode  VARCHAR(20)     --2020.10.06 추가

	SELECT @CompanyCode = CI.CompanyCode
	      ,@WorkCenterCode = WI.WorkCenterCode
		  ,@CompanyName = CI.CompanyName
		  ,@WorkCenterName = WI.WorkCenterName
	  FROM STB_UserInfo UI
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON UI.CompanyCode = CI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WI
	    ON UI.WorkCenterCode = WI.WorkCenterCode
	 WHERE UserID = @ProcessUserID

	SELECT
			GETDATE() AS PlanYearMonth,
			@PlanStartDate AS PlanStartDate,
			@PlanEndDate AS PlanEndDate,
			'' AS MaterialCode,
			'' AS MaterialName,
			'' AS BomVersion,
			@CompanyCode AS CompanyCode,
			@CompanyName AS CompanyName,
			@WorkCenterCode AS WorkCenterCode,
			@WorkCenterName AS WorkCenterName,
			CONVERT(NUMERIC(20,5),0) AS POQty
		--	@CompanyCode As CompanyCode       -- 2020.10.01 추가

END
