
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	설비조건 항목정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineConditionName_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END

    
	SELECT
			WCI.CompanyCode,
			CI.CompanyName,			
			MPM.WorkCenterCode,
			WCI.WorkCenterName,
			
	        MCN.MachineCode AS OldMachineCode,
	        MCN.MachineCode,
	        MPM.MachineName, 
	        
	        MCN.ConditionColumnIndex AS OldConditionColumnIndex,
	        MCN.ConditionColumnIndex,
	        MCN.ConditionName,
	        MCN.IsAlarm,
	        
	        MCN.CreateDateTime,
	        MCN.CreateUserID,
	        MCN.ChangeDateTime,
	        MCN.ChangeUserID
	FROM
	        STB_MachineConditionName MCN WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
				ON MCN.MachineCode = MPM.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
	        
	WHERE
			WCI.CompanyCode LIKE @CompanyCode AND
			MPM.WorkCenterCode LIKE @WorkCenterCode AND
	        MCN.MachineCode LIKE @MachineCode
END


