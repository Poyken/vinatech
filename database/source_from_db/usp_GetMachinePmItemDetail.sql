-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리 > [H210]설비정기점검관리 > Grid2 설비정기점검항목상세
-- Description:	설비정기점검항목 상세조회 (get)
-- Modified:   
-- 2021.10.27 등록오류 해결지원 (Kangs)
--
-- [프로시저 실행]  :     usp_GetMachinePmItemDetail  'kilee2', 'Korean', 'VNT', 'VNT_F1', 'VNEP01105'
-- ===========================================================================
CREATE PROCEDURE [dbo].[usp_GetMachinePmItemDetail]
							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pCompanyCode VARCHAR(20) = NULL,
							@pWorkCenterCode VARCHAR(20) = NULL,
							@pMachineCode VARCHAR(20) = NULL
WITH RECOMPILE
AS

BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '' ELSE @pMachineCode END
    
    DECLARE @CurrentDate DATE
    SET @CurrentDate = GETDATE()
    
    
    
    SELECT
			
					
			CASE WHEN MPI.NextPmPlanDate < @CurrentDate THEN 1
				 WHEN MPI.NextPmPlanDate = @CurrentDate THEN 2 
				 WHEN MPI.NextPmPlanDate = DATEADD(DD,1,@CurrentDate) THEN 3
				 ELSE 4
			END AS SeqNo,
					
			MachinePmHistory.MachinePmHistoryNo,
			MPI.MachinePmItemCode,
			MPI.PmItemName,
			
			MPI.InspectionMethod,
			
			MPI.CompanyCode,
			MPI.WorkCenterCode,
			MPI.MachineCode,
			CASE
				WHEN MachinePmHistory.MachineRepairWorkerCode IS NULL THEN @pProcessUserID
				ELSE MachinePmHistory.MachineRepairWorkerCode
			END AS MachineRepairWorkerCode,
			MRW.MachineRepairWorkerName,
--			CASE
--				WHEN MRW.MachineRepairWorkerName IS NULL THEN @pProcessUserID
--				ELSE MRW.MachineRepairWorkerName
--			END AS MachineRepairWorkerName,
			MPI.PmItemGroup,
			MPI.PmItemSpec,
			MPI.PmTermType,
			MPI.FinalPmDate,
			MPI.NextPmPlanDate,
			MachinePmHistory.PmText,
			ISNULL(MachinePmHistory.IsFinishPm,0) AS IsFinishPm,
			MachinePmHistory.MachinePmResultReportFileID,
			ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX), NULL)) AS FileData,
			AFM.FileName,
			AFM.FileSize
		   
	FROM
			STB_MachinePmItem MPI WITH(NOLOCK)
			LEFT OUTER JOIN 
											(
												SELECT
														MAX(MPH.MachinePmHistoryNo) AS MachinePmHistoryNo,
														MPH.MachinePmItemCode,
														MPH.MachineRepairWorkerCode,
														MPH.PmText,
														MPH.IsFinishPm,
														MPH.MachinePmResultReportFileID
												FROM
														STB_MachinePmHistory MPH WITH(NOLOCK)
												WHERE
														--MPH.JobDate = @CurrentDate
														MPH.IsFinishPm = 1
												GROUP BY
														MPH.MachinePmItemCode,
														MPH.MachineRepairWorkerCode,
														MPH.PmText,
														MPH.IsFinishPm,
														MPH.MachinePmResultReportFileID
											)  MachinePmHistory				                                
											ON MPI.MachinePmItemCode = MachinePmHistory.MachinePmItemCode
			LEFT OUTER JOIN STB_MachineRepairWorker MRW WITH(NOLOCK)				
			  ON MachinePmHistory.MachineRepairWorkerCode = MRW.MachineRepairWorkerCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
			  ON AFM.FileID = MachinePmHistory.MachinePmResultReportFileID
	WHERE
			((@CompanyCode = '*') OR (MPI.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MPI.WorkCenterCode = @WorkCenterCode))
			AND ((@MachineCode = '*') OR (MPI.MachineCode = @MachineCode))
			AND (MPI.IsUsed = 1)
	ORDER BY
			MPI.MachinePmItemCode,
			SeqNo
    
	
    
END