
-- =============================================
-- Author:		<Jeon Gyeong Ho>
-- Browsable : false
-- Group : 시스템
-- Create date: <2016-06-17>
-- Description:	MaterilaDocLot에 실제 출고된 MaterialLot을 추가한다. BackFlush 때 사용
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocLot_ForGIBackFlush]
	@pMaterialDocNo VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20),
	@pMaterialLotNo VARCHAR(20),
	@pProcessQty NUMERIC(20,5),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	DECLARE @MDLISeqNo INT

	SET @MDLISeqNo = NULL

	SELECT
			@MDLISeqNo = MAX(MDLI.MDLISeqNo)
	FROM
			STB_MaterialDocLotInfo MDLI
	WHERE
			MDLI.MaterialDocDetailNo = @pMaterialDocDetailNo

	IF @MDLISeqNo IS NULL
	BEGIN
			SET @MDLISeqNo = 1
	END ELSE BEGIN
			SET @MDLISeqNo = @MDLISeqNo + 1
	END

	INSERT INTO STB_MaterialDocLotInfo 
		(
			MaterialDocDetailNo,
			MDLISeqNo,
			MaterialLotNo,
			LotID,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			StockQty,
			IsChecked,
			MaterialLocationCode,
			MaterialDocNo,
			PackingID,
			CreateDateTime,
			CreateUserID
		)
	SELECT
			@pMaterialDocDetailNo,
			@MDLISeqNo,
			@pMaterialLotNo,
			MLI.LotID,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			@pProcessQty,
			CONVERT(BIT, 1),
			MLI.MaterialLocationCode,
			@pMaterialDocNo,
			MLI.PackingID,
			GETDATE(),
			@pProcessUserID
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @pMaterialLotNo
END
