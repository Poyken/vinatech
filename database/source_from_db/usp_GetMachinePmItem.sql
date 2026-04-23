-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비정기점검항목 조회
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMachinePmItem]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    
    DECLARE @CurrentDate DATE
    SET @CurrentDate = GETDATE()
    
    SELECT
			MM.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MM.MachineCode,
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
						
			
			ISNULL(NotInspection.NotInspect,0) AS NotInspect,
			ISNULL(CurrentInspection.CurrentInspect,0) AS CurrentInspect,
			ISNULL(TomorrowInspection.TomorrowInspect,0) AS TomorrowInspect
			
	FROM
			STB_MachineMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN 
			(
				SELECT
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode,
						COUNT(*) AS NotInspect
				FROM
						STB_MachinePmItem MP WITH(NOLOCK)
				WHERE
						((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode)) 
						AND ((@WorkCenterCode = '*') OR (MP.WorkCenterCode = @WorkCenterCode))
						AND MP.NextPmPlanDate < @CurrentDate
				GROUP BY
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode
			)NotInspection
				ON MM.CompanyCode = NotInspection.CompanyCode
				AND MM.WorkCenterCode = NotInspection.WorkCenterCode
				AND MM.MachineCode = NotInspection.MachineCode	
			LEFT OUTER JOIN 
			(
				SELECT
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode,
						COUNT(*) AS CurrentInspect
				FROM
						STB_MachinePmItem MP WITH(NOLOCK)
				WHERE
						((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode)) 
						AND ((@WorkCenterCode = '*') OR (MP.WorkCenterCode = @WorkCenterCode))
						AND MP.NextPmPlanDate = @CurrentDate
				GROUP BY
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode
			)CurrentInspection
				ON MM.CompanyCode = CurrentInspection.CompanyCode
				AND MM.WorkCenterCode = CurrentInspection.WorkCenterCode
				AND MM.MachineCode = CurrentInspection.MachineCode	
			LEFT OUTER JOIN 
			(
				SELECT
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode,
						COUNT(*) AS TomorrowInspect
				FROM
						STB_MachinePmItem MP WITH(NOLOCK)
				WHERE
						((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode)) 
						AND ((@WorkCenterCode = '*') OR (MP.WorkCenterCode = @WorkCenterCode))
						AND MP.NextPmPlanDate = DATEADD(DD,1,@CurrentDate)
				GROUP BY
						MP.CompanyCode,
						MP.WorkCenterCode,
						MP.MachineCode
			)TomorrowInspection
				ON MM.CompanyCode = TomorrowInspection.CompanyCode
				AND MM.WorkCenterCode = TomorrowInspection.WorkCenterCode
				AND MM.MachineCode = TomorrowInspection.MachineCode
			LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MM.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MM.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode	
			
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode))
			--AND MM.MachineTypeCode = 'INJECTION'
	ORDER BY
			NotInspection.NotInspect DESC,
			CurrentInspection.CurrentInspect DESC,
			TomorrowInspection.TomorrowInspect DESC
END

