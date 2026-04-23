-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비보수작업자정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairWorker_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMachineRepairWorkerCode VARCHAR(20) = NULL,
    @pMachineRepairWorkerName NVARCHAR(50) = NULL,
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MachineRepairWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineRepairWorkerCode,'') = '' THEN '*' ELSE @pMachineRepairWorkerCode END
      DECLARE @MachineRepairWorkerName NVARCHAR(50) = CASE WHEN ISNULL(@pMachineRepairWorkerName,'') = '' THEN '*' ELSE @pMachineRepairWorkerName END
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

    
	SELECT
	        MRW.MachineRepairWorkerCode AS OldMachineRepairWorkerCode,
	        MRW.MachineRepairWorkerCode,
	        MRW.MachineRepairWorkerName,
	        MRW.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        MRW.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MRW.BasicCost,
	        MRW.IsUsed,
	        MRW.CreateDateTime,
	        MRW.CreateUserID,
	        MRW.ChangeDateTime,
	        MRW.ChangeUserID
	FROM
	        STB_MachineRepairWorker MRW WITH(NOLOCK)
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MRW.WorkCenterCode = WCI.WorkCenterCode 
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MRW.CompanyCode = CI.CompanyCode
	WHERE
	        ((@MachineRepairWorkerCode = '*') OR (MRW.MachineRepairWorkerCode = @MachineRepairWorkerCode)) AND
	        ((@MachineRepairWorkerName = '*') OR (MRW.MachineRepairWorkerName = @MachineRepairWorkerName)) AND
	        ((@CompanyCode = '*') OR (MRW.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MRW.WorkCenterCode = @WorkCenterCode)) 

END


