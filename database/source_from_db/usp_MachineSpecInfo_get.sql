-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비제원정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSpecInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '' ELSE @pMachineCode END
	
	
    
	SELECT
	        MSI.MachineCode AS OldMachineCode,
	        MSI.MachineSpecSeq AS OldMachineSpecSeq,
	        MSI.MachineCode,
	        
	        MM.MachineName,
			MM.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MM.IsProdMachine,
			MM.MachineTypeCode,
			MT.MachineTypeName,
			
	        MSI.MachineSpecSeq,
	        MSI.SpecGroupName,
	        MSI.SpecName,
	        MSI.SpecText,
	        MSI.CreateDateTime,
	        MSI.CreateUserID,
	        MSI.ChangeDateTime,
	        MSI.ChangeUserID
	FROM
	        STB_MachineSpecInfo MSI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MSI.MachineCode = MBI.MachineCode
	        LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MSI.MachineCode = MM.MachineCode
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MM.WorkCentercode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MM.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) 
	        AND ((@MachineCode = '*') OR (MSI.MachineCode = @MachineCode)) 

END


