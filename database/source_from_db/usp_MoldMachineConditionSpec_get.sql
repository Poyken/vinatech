
-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	설비조건 스펙정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMachineConditionSpec_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineCode VARCHAR(20) = NULL,
    @pConditionColumnIndex INT = NULL,
    @pMoldNumber VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END
    DECLARE @ConditionColumnIndex INT = CASE WHEN ISNULL(@pConditionColumnIndex,'') = '' THEN -1 ELSE @pConditionColumnIndex END
    DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '%' ELSE @pMoldNumber END

    
	SELECT
			WCI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			MPM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
	        MMCS.MachineCode AS OldMachineCode,
	        MMCS.MachineCode,
	        MPM.MachineName,
	        
	        MMCS.ConditionColumnIndex AS OldConditionColumnIndex,
	        MMCS.ConditionColumnIndex,
	        MCN.ConditionName,
	        
	        MMCS.MoldNumber AS OldMoldNumber,
	        MMCS.MoldNumber,
	        MBI.MoldCategory1,
	        MBI.MoldCategory2,
	        MBI.MoldCategory3,
	        
	        ISNULL(MMCS.SpecValue,0) AS SpecValue,
	        ISNULL(MMCS.UpperLimit,0) AS UpperLimit,
	        ISNULL(MMCS.LowerLimit,0) AS LowerLimit,
	        
	        MMCS.CreateDateTime,
	        MMCS.CreateUserID,
	        MMCS.ChangeDateTime,
	        MMCS.ChangeUserID
	FROM
	        STB_MoldMachineConditionSpec MMCS WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachineConditionName MCN WITH(NOLOCK)
				ON MMCS.MachineCode = MCN.MachineCode
				AND MMCS.ConditionColumnIndex = MCN.ConditionColumnIndex
			LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
				ON MMCS.MachineCode = MPM.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MMCS.MoldNumber = MBI.MoldNumber
	WHERE
			WCI.CompanyCode LIKE @CompanyCode AND
	        MPM.WorkCenterCode LIKE @WorkCenterCode AND
	        MMCS.MachineCode LIKE @MachineCode AND
	        MMCS.MoldNumber LIKE @MoldNumber
			--((@ConditionColumnIndex = -1) OR (MMCS.ConditionColumnIndex = @ConditionColumnIndex)) AND
END
