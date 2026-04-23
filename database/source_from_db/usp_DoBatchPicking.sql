
-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date: 2017-03-09
-- Description:	자재출고 화면에서 일괄피킹 버튼 클릭 시 호출
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoBatchPicking]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo

	DECLARE @Picking TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		PickingQty NUMERIC(20,5)
	)
	INSERT INTO @Picking
	SELECT
			P.MaterialDocNo,
			P.MaterialDocDetailNo,
			P.MaterialLotNo,
			P.PickingQty
	FROM
			dbo.fnGetPickingAvailTable(@MaterialDocNo) P

	DECLARE @Row INT = 1,
			@Count INT,
			@MaterialDocDetailNo VARCHAR(20),
			@MaterialLotNo VARCHAR(20),
			@PickingQty NUMERIC(20,5)

	SELECT
			@Count = COUNT(1)
	FROM
			@Picking

	WHILE @Row <= @Count BEGIN
		SELECT
				@MaterialDocDetailNo = P.MaterialDocDetailNo,
				@MaterialLotNo = P.MaterialLotNo,
				@PickingQty = P.PickingQty
		FROM
				@Picking P
		WHERE
				P.ROW = @Row

		EXEC usp_PDADoPicking	@pProcessLanguage = @ProcessLanguage,
								@pProcessUserID = @ProcessUserID,
								@pMaterialDocNo = @MaterialDocNo,
								@pMaterialDocDetailNo = @MaterialDocDetailNo,
								@pMaterialLotNo = @MaterialLotNo,
								@pStockQty = @PickingQty

		SET @Row = @Row + 1
	END
END

