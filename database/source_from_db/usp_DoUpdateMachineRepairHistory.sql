-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-23
-- Description: 설비수리이력 마스터(작업일자, 작업시작시간, 작업완료시간, 총발생비용) 업데이트	
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMachineRepairHistory]
	@pMachineRepairHistoryNo VARCHAR(20) 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @MachineRepairHistoryNo VARCHAR(20)
	DECLARE @JobStartDateTime DATETIME
	DECLARE @JobEndDateTime DATETIME
	DECLARE @TotalRepairWorkerCost NUMERIC(20,5)
	DECLARE @TotalRepairMaterialCost NUMERIC(20,5)
	
	SET @MachineRepairHistoryNo = @pMachineRepairHistoryNo
	
	SELECT
			@JobStartDateTime = MIN(MRWH.JobStartDateTime),
			@JobEndDateTime = MAX(MRWH.JobEndDateTime),
			@TotalRepairWorkerCost = SUM((ISNULL(MRWH.JobTime,0) / 60.0) * MRWH.BasicCost)
	FROM
			STB_MachineRepairWorkerHist MRWH
	WHERE
			MRWH.MachineRepairHistoryNo = @MachineRepairHistoryNo
			
			
	SELECT
			@TotalRepairMaterialCost = SUM(ISNULL(SPCH.ChangeQty,0) * ISNULL(SPCH.BasicUnitPrice,0))
	FROM
			STB_SparePartChangeHistory SPCH
	WHERE
			SPCH.SparePartChangeHistoryNo IN (SELECT SparePartChangeHistoryNo FROM STB_MachineRepairMaterialHist WHERE MachineRepairHistoryNo = @MachineRepairHistoryNo)
	
	
	
	UPDATE STB_MachineRepairHistory 
	SET
			JobDate = CONVERT(DATE,@JobStartDateTime),
			JobStartDateTime = @JobStartDateTime,
			JobEndDateTime = @JobEndDateTime,
			TotalRepairCost = @TotalRepairWorkerCost + @TotalRepairMaterialCost
	WHERE
			MachineRepairHistoryNo = @MachineRepairHistoryNo
	
END

