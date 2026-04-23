-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-20
-- Browsable : true
-- Group : 설비관리
-- Description:	설비수리이력관리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pCompanyName NVARCHAR(50) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pWorkCenterName NVARCHAR(50) = NULL,
    @pMachineCode VARCHAR(20) = NULL,
    @pMachineName NVARCHAR(100) = NULL,
    @pFromDate DATE = NULL,
    @pToDate DATE = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
    DECLARE @FromDate DATE = CASE WHEN ISNULL(@pFromDate,'') = '' THEN GETDATE() ELSE @pFromDate END
    DECLARE @ToDate DATE = CASE WHEN ISNULL(@pToDate,'') = '' THEN GETDATE() ELSE @pToDate END

    
	SELECT
	        MRH.MachineRepairHistoryNo AS OldMachineRepairHistoryNo,
	        MRH.MachineRepairHistoryNo,
	        
	        MRH.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        MRH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MRH.MachineCode,
	        MM.MachineName,
	        MM.IsProdMachine,
	        MM.MachineTypeCode,
	        MT.MachineTypeName,
	        
	        MBI.MachineManagementNo,
	        MBI.OriginalMachineName,
	        MBI.MakerName,
	        MBI.ProductionDate,
	        MBI.MachineSerialNo,
	        MBI.BuyVendorName,
	        MBI.InstallDate,
	        MBI.BuyPrice,
	        MBI.ASVendorName,
	        MBI.ASVendorPhone,
	        MBI.ASPersonName,
	        MBI.ASPersonPhone,
	        MBI.MachineImage,
	        MBI.MachineExtText01,
	        MBI.MachineExtText02,
	        MBI.MachineExtText03,
	        MBI.MachineExtText04,
	        
	        MRH.JobDate,
	        MRH.JobStartDateTime,
	        MRH.JobEndDateTime,
	        MRH.MachineLossHistNo,
	        MRH.TroublePoint,
	        MRH.TroubleText,
	        MRH.RepairText,
	        MRH.IsMachineLoss,
	        MRH.TotalRepairCost,
	        MRH.CreateDateTime,
	        MRH.CreateUserID,
	        MRH.ChangeDateTime,
	        MRH.ChangeUserID
	FROM
	        STB_MachineRepairHistory MRH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MRH.MachineCode = MM.MachineCode 
			LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MRH.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MRH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MRH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
	WHERE
			((MRH.JobDate >= @FromDate) AND (@ToDate >= MRH.JobDate)) AND
	        ((@CompanyCode = '*') OR (MRH.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MRH.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MachineCode = '*') OR (MRH.MachineCode = @MachineCode))
	         

END


