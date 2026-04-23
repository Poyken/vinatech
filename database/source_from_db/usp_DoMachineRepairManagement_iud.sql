-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-22
-- Browsable : true
-- Group : 설비관리
-- Description: 설비수리이력, 수리작업자, 수리자재, 스페어파트교체이력, 스페어파트입출고 이력 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMachineRepairManagement_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
WITH RECOMPILE
AS
BEGIN
	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(20),
		UID_KEY VARCHAR(50)
	)
	
	SET NOCOUNT ON;
	
	DECLARE @MachineRepairHistoryNo VARCHAR(20)
	
	--EXEC usp_MachineRepairHistory_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairHistory', @pXml, @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo OUTPUT
	
	--EXEC usp_MachineRepairWorkerHist_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairWorkerHist', @pXml, @MachineRepairHistoryNo, @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo OUTPUT
	
	--EXEC usp_MachineRepairMaterialHist_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairMaterialHist', @pXml, @MachineRepairHistoryNo, @pOutMachineRepairHistoryNo = @MachineRepairHistoryNo OUTPUT
	
	--EXEC usp_DoUpdateMachineRepairHistory @MachineRepairHistoryNo
	
	EXEC usp_MachineRepairHistory_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairHistory', @pXml
	
	EXEC usp_MachineRepairWorkerHist_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairWorkerHist', @pXml
	
	EXEC usp_MachineRepairMaterialHist_iud @pProcessUserID, @pProcessLanguage, 'MachineRepairMaterialHist', @pXml
	
	--EXEC usp_DoUpdateMachineRepairHistory @MachineRepairHistoryNo
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END

