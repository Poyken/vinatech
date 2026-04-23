-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 팝업
-- Description:	설비정보-팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairWorker_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
	SELECT
			MRW.MachineRepairWorkerCode,
			MRW.MachineRepairWorkerName,
			MRW.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MRW.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MRW.BasicCost
			
	FROM
			STB_MachineRepairWorker MRW WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MRW.WorkCentercode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MRW.CompanyCode = CI.CompanyCode
			
	WHERE
			((@CompanyCode = '*') OR (MRW.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MRW.WorkCenterCode = @WorkCenterCode)) 
			AND (MRW.IsUsed = 1)
END

