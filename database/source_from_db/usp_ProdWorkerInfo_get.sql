-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description:	생산 작업자를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdWorkerInfo_get] -- EXEC usp_ProdWorkerInfo_get '','','',''
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN

SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    
	SELECT
			PWI.CompanyCode,
			CI.CompanyName,
			PWI.WorkCenterCode,
			WCI.WorkCenterName,
			PWI.WorkerCode AS OldWorkerCode,
			PWI.WorkerCode,
			PWI.WorkerName,
			PWI.LanguageCode,
			PWI.OrgWorkerName,
			PWI.Nationality,
			PWI.EmpNo,
			PWI.WorkerImage,
			PWI.IsUsed,
			PWI.CreateDateTime,
			PWI.CreateUserID,
			PWI.ChangeDateTime,
			PWI.ChangeUserID,
			PWI.IsProdWorker,
			PWI.WorkerGroupCode,
			PWI.DATEJOIN,
			sli.LineCode,
			sli.LineName
	FROM
			STB_ProdWorkerInfo PWI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = PWI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = PWI.WorkCenterCode
		    LEFT OUTER JOIN  STB_LineInfo sli WITH(NOLOCK)
				ON sli.LineCode = PWI.LineCode
	WHERE
			PWI.CompanyCode LIKE @CompanyCode AND
			PWI.WorkCenterCode LIKE @WorkCenterCode
	

	
END


