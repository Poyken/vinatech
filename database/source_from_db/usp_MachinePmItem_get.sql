-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비정기점검항목정보 조회
-- Modified:
--  usp_MachinePmItem_get '','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachinePmItem_get]
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
	        MPI.MachinePmItemCode AS OldMachinePmItemCode,
	        MPI.MachinePmItemCode,
	        MPI.PmItemName,
	        
	        MPI.InspectionMethod,
	        
	        MPI.CompanyCode,
	        CI.CompanyName,
	        
	        MPI.WorkCenterCode,
	        WCI.WorkCenterName,
	        
	        MPI.MachineCode,
	        MM.MachineName,
	        MM.MachineTypeCode,
	        MT.MachineTypeName,
	        
	        MPI.PmItemGroup,
	        
	        MPI.PmItemSpec,
	        
	        MPI.PmTermType,
	        MPI.FinalPmDate,
	        MPI.NextPmPlanDate,
	        MPI.IsUsed,
	        MPI.CreateDateTime,
	        MPI.CreateUserID,
	        MPI.ChangeDateTime,
	        MPI.ChangeUserID,
			MPI.Remark
	FROM
	        STB_MachinePmItem MPI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MPI.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MPI.MachineCode = MM.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MPI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCk)
				ON MM.MachineTypeCode = MT.MachineTypeCode
	WHERE
	        ((@CompanyCode = '*') OR (MPI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MPI.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MachineCode = '*') OR (MPI.MachineCode = @MachineCode)) 

END


