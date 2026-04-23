-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비기초정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineBasicInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pMachineCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END

    
    SELECT
			MM.MachineCode AS OldMachineCode,
			MM.MachineCode,
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
	        AFM.[FileName],
			AFM.FileSize,
			ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData,
	        MBI.MachineExtText01,
	        MBI.MachineExtText02,
	        MBI.MachineExtText03,
	        MBI.MachineExtText04,
	        MBI.CreateDateTime,
	        MBI.CreateUserID,
	        MBI.ChangeDateTime,
	        MBI.ChangeUserID,
			MBI.IsIdle,
            MBI.IdleDate,
            MBI.IsDisposal,
            MBI.DisposalDate,
            MBI.IsVietnamShipment,
            MBI.VietnamShipmentDate,
			MBI.MachineStatusCode,
			MBI.MachineStatusChangeDate,
            MBI.ModelSpec,
            MBI.MachinetSize,
            MBI.MachineWeight,
            MBI.MachinePower,
            MBI.VendorContact,
            MBI.Remark
			
	FROM
			STB_MachineMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)				ON MM.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MM.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCk)				ON MM.MachineTypeCode = MT.MachineTypeCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)				ON AFM.FileID = MBI.MachineImage
			
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) 			
	        AND ((@MachineCode = '*') OR (MM.MachineCode = @MachineCode)) 		
    


END