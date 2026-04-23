-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-16
-- Group : 생산관리
-- Description:	생산시 사용원자재 Lot 이력을 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateMainAssemblePart]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pParentMaterialCode VARCHAR(50) = NULL,
	@pControlNo VARCHAR(20) = NULL,
	@pAsmLotNo VARCHAR(50) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ParentMaterialCode VARCHAR(50) = @pParentMaterialCode
	DECLARE @ControlNo VARCHAR(20) = @pControlNo
	DECLARE @AsmLotNo VARCHAR(50) = @pAsmLotNo
	DECLARE @PartCode VARCHAR(50)
	DECLARE @PONo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @Barcode VARCHAR(50)

	-- Developer에서 화면 만들때는 무시
	IF ISNULL(@AsmLotNo,'') <> '' BEGIN
			SELECT
					@PartCode = MLI.MaterialCode
			FROM
					STB_MaterialLotInfo MLI
					LEFT OUTER JOIN STB_MaterialMaster MM
						ON MM.MaterialCode = MLI.MaterialCode
			WHERE
					MLI.LotID = @AsmLotNo

			IF ISNULL(@PartCode,'') = '' BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage,'재고에 없는 Lot입니다'
					RETURN
			END

			SELECT
					@ControlNo = SI.ControlNo,
					@MaterialCode = SI.MaterialCode,
					@PONo = SI.PONo,
					@Barcode = SI.Barcode
			FROM
					STB_SetInfo SI
					LEFT OUTER JOIN STB_ProductionOrderInfo POI
						ON POI.PONo = SI.PONo
			WHERE
					SI.ControlNo = @ControlNo

			IF NOT EXISTS (
							SELECT	1
							FROM
									STB_ProductionOrderBom POB
							WHERE
									POB.PONo = @PONo AND
									POB.MaterialCode = @MaterialCode AND
									POB.ChildMaterialCode = @PartCode
						) BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage,'BOM에 해당하지 않는 자재입니다'
					RETURN
			END

			IF EXISTS (
						SELECT	1
						FROM
								STB_MainAssemblePartInfo MAPI
						WHERE
								MAPI.ControlNo = @ControlNo AND
								MAPI.AsmLotNo = @AsmLotNo
					) BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage,'이미 등록된 Lot입니다'
					RETURN
			END
	END

	SELECT
			@ControlNo AS ControlNo,
			@Barcode AS Barcode,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MLI.MaterialCode AsmPartCode,
			MM.MaterialName AS AsmPartName,
			MLI.LotID,
			MLI.CurrentQty
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MLI.LotID = @AsmLotNo
END
