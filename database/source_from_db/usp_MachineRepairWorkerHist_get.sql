-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-20
-- Browsable : true
-- Group : 설비관리
-- Description:	설비수리작업자정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairWorkerHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMachineRepairHistoryNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MachineRepairHistoryNo VARCHAR(20) = CASE WHEN ISNULL(@pMachineRepairHistoryNo,'') = '' THEN '' ELSE @pMachineRepairHistoryNo END

    
	SELECT
			MRWH.MachineRepairHistoryNo AS OldMachineRepairHistoryNo,
			MRWH.MachineRepairHistoryNo,
			MRWH.MachineRepairWorkerSeq AS OldMachineRepairWorkerSeq,
			MRWH.MachineRepairWorkerSeq,
			
			MRWH.MachineRepairWorkerCode,
			MRW.MachineRepairWorkerName,
			
			MRW.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			MRW.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			
			MRWH.JobStartDateTime,
			MRWH.JobEndDateTime,
			MRWH.JobTime,
			MRWH.BasicCost,
			MRWH.RepairText,
			MRWH.CreateDateTime,
			MRWH.CreateUserID,
			MRWH.ChangeDateTime,
			MRWH.ChangeUserID
	FROM
			STB_MachineRepairWorkerHist MRWH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineRepairWorker MRW WITH(NOLOCK)
				ON MRWH.MachineRepairWorkerCode = MRW.MachineRepairWorkerCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MRW.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MRW.CompanyCode = CI.CompanyCode 
	WHERE
			((@MachineRepairHistoryNo = '*') OR (MRWH.MachineRepairHistoryNo = @MachineRepairHistoryNo)) 

END


