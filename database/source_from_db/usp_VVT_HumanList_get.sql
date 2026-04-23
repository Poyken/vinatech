
-- =============================================
-- Author:	   kilee
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 생산관리 > 실적등록 > [B590] 베트남생산실적입력
-- Description:	
-- Modified: 
-- ============================================
-- 실행문 :  EXEC usp_VVT_HumanList_get '','','','',''

CREATE PROCEDURE [dbo].[usp_VVT_HumanList_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pCostGroupString VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')
    
	IF @CostGroupString = '' 
	
	BEGIN
	--	SELECT
	--			PWI.WorkerCode,
	--			PWI.WorkerName,
	--			PWI.OrgWorkerName,
	--			PWI.Nationality,
	--			PWI.EmpNo
	--	FROM
	--			STB_ProdWorkerInfo PWI WITH(NOLOCK)
	--			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = PWI.CompanyCode
	--			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
	--	WHERE 1=1
	--	   AND PWI.CompanyCode    LIKE @CompanyCode 
	--	   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
	--	   AND PWI.IsUsed = 1
	--	   AND PWI.IsProdWorker = 1
		 
	--END ELSE BEGIN
	--	SELECT
	--			PWI.WorkerCode,
	--			PWI.WorkerName,
	--			PWI.OrgWorkerName,
	--			PWI.Nationality,
	--			PWI.EmpNo
	--	FROM
	--			STB_ProdWorkerInfo PWI WITH(NOLOCK)
	--			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = PWI.CompanyCode
	--			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
	--	WHERE 1=1
	--	   AND PWI.CompanyCode    LIKE @CompanyCode 
	--	   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
	--	   AND PWI.IsUsed = 1
	--	   AND PWI.IsProdWorker = 1
	--		AND PWI.WorkerCode  IN (
	--		                                       SELECT WorkerCode
	--												FROM STB_CostGroupWorkerMapping 
	--											   WHERE IsAssigned = 1 
	--												AND CostGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
	--								)
	
	SELECT USERID, USERNAME FROM SmartFramework.DBO.STB_UserInfo
	WHERE 1=1
	AND USERNAME IN ('이강일','이현숙','이상훈','황명구','유영종','유재민','최은화','박건우','성준기','vananh','노승한','nguyentung','배철호','강의겸','방준혁')

	END

	


END