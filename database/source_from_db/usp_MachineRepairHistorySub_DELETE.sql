-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-23
-- Description:	설비수리작업자정보, 설비수리자재정보, 스페어파트입출고이력, 스페어파트교체이력정보 삭제 및 스페어파트재고정보 업데이트
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairHistorySub_DELETE]
	@pMachineRepairHistoryNo VARCHAR(20)
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @MachineRepairHistoryNo VARCHAR(20) = @pMachineRepairHistoryNo
	
	
	DELETE FROM STB_MachineRepairWorkerHist
	WHERE
			MachineRepairHistoryNo = @MachineRepairHistoryNo
			
	
	DECLARE @tbMachineRepairPartInfo TABLE
	(
		IDX INT IDENTITY,
		SparePartChangeHistoryNo VARCHAR(20)
	)
	DECLARE @rowCnt INT
	DECLARE @init_row INT
	
	DECLARE @SparePartchangeHistoryNo VARCHAR(20)
	DECLARE @SparePartIOHistoryNo VARCHAR(20)
	DECLARE @SPWarehouseCode VARCHAR(20)
	DECLARE @SPLocationCode VARCHAR(20)
	DECLARE @SparePartCode VARCHAR(20)
	DECLARE @ChangeQty NUMERIC(20,5)
	
	SET @init_row = 1
	
	
	INSERT @tbMachineRepairPartInfo
	SELECT
			SparePartChangeHistoryNo
	FROM
			STB_MachineRepairMaterialHist 
	WHERE
			MachineRepairHistoryNo = @MachineRepairHistoryNo 	
	ORDER BY
			MachineRepairMaterialSeq 	
	
	
	SET @rowCnt = (SELECT COUNT(*) FROM @tbMachineRepairPartInfo)
	
	WHILE (@init_row <= @rowCnt) BEGIN
		
		SELECT
				@SparePartchangeHistoryNo = TB.SparePartChangeHistoryNo,
				@SparePartIOHistoryNo = SPCH.SparePartIOHistoryNo,
				@SPWarehouseCode = SPIOH.SPWarehouseCode,
				@SPLocationCode = SPIOH.SPLocationCode,
				@SparePartCode = SPCH.SparePartCode,
				@ChangeQty = ISNULL(SPCH.ChangeQty,0)
		FROM
				@tbMachineRepairPartInfo TB
				LEFT OUTER JOIN STB_SparePartChangeHistory SPCH
					ON TB.SparePartChangeHistoryNo = SPCH.SparePartChangeHistoryNo
				LEFT OUTER JOIN STB_SparePartIOHistory SPIOH 
					ON SPCH.SparePartIOHistoryNo = SPIOH.SparePartIOHistoryNo
		WHERE
				IDX = @init_row
		
		
		DELETE FROM STB_SparePartChangeHistory 
		WHERE
				SparePartChangeHistoryNo = @SparePartchangeHistoryNo
				
		
		DELETE FROM STB_SparePartIOHistory 
		WHERE
				SparePartIOHistoryNo = @SparePartIOHistoryNo
				
		
		UPDATE STB_SparePartStockInfo 
		SET
				CurrentStockQty = CurrentStockQty + @ChangeQty
		WHERE
				SPWarehouseCode = @SPWarehouseCode
				AND SPLocationCode = @SPLocationCode
				AND SparePartCode = @SparePartCode
				
		
		SET @init_row = @init_row + 1
				
	END
	
	DELETE FROM STB_MachineRepairMaterialHist 
	WHERE
			MachineRepairHistoryNo = @MachineRepairHistoryNo
			
			
	

END

