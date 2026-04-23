-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.12.14
-- Description:	Putaway, Picking 에서 처리한 이동처리 이력을 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddMaterialMoveHistory]
	@pMaterialLotNo VARCHAR(20),
	@pTargetMaterialLocationCode VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	DECLARE @MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@TargetMaterialLocationCode VARCHAR(20) = @pTargetMaterialLocationCode,
			@MoveUserID VARCHAR(20) = @pProcessUserID

	DECLARE @LotID VARCHAR(50),
			@MaterialCode VARCHAR(50),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@SourceMaterialLocationCode VARCHAR(20),
			@SourceZone NVARCHAR(100),
			@TargetMaterialWarehouseCode VARCHAR(20),
			@TargetZone NVARCHAR(100),
			@MoveStockQty NUMERIC(20,5)
			


	SELECT
			@TargetMaterialWarehouseCode = ML.MaterialWarehouseCode,
			@TargetZone = ML.MLExtText01
	FROM
			STB_MaterialLocation ML WITH (NOLOCK)
	WHERE 
			ML.MaterialLocationCode = @TargetMaterialLocationCode

	SELECT
			@MaterialCode = MLI.MaterialCode,
			@MoveStockQty = MLI.CurrentQty,
			@LotID = MLI.LotID,
			@SourceMaterialLocationCode = MLI.MaterialLocationCode
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	SELECT
			@SourceMaterialWarehouseCode = ML.MaterialWarehouseCode,
			@SourceZone = ML.MLExtText01
	FROM
			STB_MaterialLocation ML WITH (NOLOCK)
	WHERE 
			ML.MaterialLocationCode = @SourceMaterialLocationCode

	INSERT INTO STB_MaterialMoveHistory
			(
				MoveDate,
				MoveDateTime,
				MaterialLotNo,
				LotID,
				MaterialCode,
				SourceMaterialWarehouseCode,
				SourceMaterialLocationCode,
				SourceZone,
				TargetMaterialWarehouseCode,
				TargetMaterialLocationCode,
				TargetZone,
				MoveStockQty,
				MoveUserID
			)
	VALUES
			(
				GETDATE(),
				GETDATE(),
				@MaterialLotNo,
				@LotID,
				@MaterialCode,
				@SourceMaterialWarehouseCode,
				@SourceMaterialLocationCode,
				@SourceZone,
				@TargetMaterialWarehouseCode,
				@TargetMaterialLocationCode,
				@TargetZone,
				@MoveStockQty,
				@MoveUserID
			)
END
