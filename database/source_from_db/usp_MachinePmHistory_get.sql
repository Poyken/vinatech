-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 설비관리
-- Description:	설비정기점검이력정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachinePmHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineCode VARCHAR(20) = NULL,
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
	        --MPH.MachinePmHistoryNo AS OldMachinePmHistoryNo,
	        --MPH.MachinePmHistoryNo,
			MAX(MPH.MachinePmHistoryNo) AS MachinePmHistoryNo,
	        
	        MPH.MachinePmItemCode,
	        MPI.PmItemName,
	        MPI.PmItemGroup,
	        MPI.PmItemSpec,
	        MPI.PmTermType,
	        MPI.FinalPmDate,
	        MPI.NextPmPlanDate,
	        
	        MPH.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        MPH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MPH.MachineCode,
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
				        
	        --MPH.JobDate,
	        MPH.MachineRepairWorkerCode,
	        MRW.MachineRepairWorkerName,
	        MRW.BasicCost,
	        
	        
	        --MPH.PmDateTime,
	        MPH.PmText,
	        MPH.IsFinishPm,
	        --MPH.CreateDateTime,
	        MPH.CreateUserID,
	        MPH.ChangeDateTime,
	        MPH.ChangeUserID,
			MPH.MachinePmResultReportFileID,
			MAX(ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX), NULL))) AS FileData,
			MAX(AFM.FileName) AS FileName,
			MAX(AFM.FileSize) AS FileSize
	FROM
	        STB_MachinePmHistory MPH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachinePmItem MPI WITH(NOLOCK)
				ON MPH.MachinePmItemCode = MPI.MachinePmItemCode
			LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MPH.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MPH.MachineCode = MM.MachineCode
			LEFT OUTER JOIN STB_MachineRepairWorker MRW WITH(NOLOCK)
				ON MPH.MachineRepairWorkerCode = MRW.MachineRepairWorkerCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MPH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
			    ON AFM.FileID = MPH.MachinePmResultReportFileID
	WHERE
			((MPH.JobDate >= @FromDate) AND (MPH.JobDate <= @ToDate)) AND
	        ((@CompanyCode = '*') OR (MPH.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MPH.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MachineCode = '*') OR (MPH.MachineCode = @MachineCode)) AND
			MPH.IsFinishPm = 1
	GROUP BY
			MPH.MachinePmItemCode,
	        MPI.PmItemName,
	        MPI.PmItemGroup,
	        MPI.PmItemSpec,
	        MPI.PmTermType,
	        MPI.FinalPmDate,
	        MPI.NextPmPlanDate,
	        
	        MPH.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        MPH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MPH.MachineCode,
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
				        
	        --MPH.JobDate,
	        MPH.MachineRepairWorkerCode,
	        MRW.MachineRepairWorkerName,
	        MRW.BasicCost,
	        
	        
	        --MPH.PmDateTime,
	        MPH.PmText,
	        MPH.IsFinishPm,
	        --MPH.CreateDateTime,
	        MPH.CreateUserID,
	        MPH.ChangeDateTime,
	        MPH.ChangeUserID,
			MPH.MachinePmResultReportFileID
END


