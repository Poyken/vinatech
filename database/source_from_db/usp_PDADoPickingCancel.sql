

-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-20
-- Description:	자재를 피킹 취소처리 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDADoPickingCancel]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pMaterialLotNo VARCHAR(20)
	--@pLotID VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NotFoundStock NVARCHAR(500)

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,			
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			--@LotID VARCHAR(50) = @pLotID,
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20)

	EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo,
									@pErrorWhenFinish = 0	-- 완료된 문서도 피킹취소 가능
									
	IF @@ERROR <> 0 BEGIN
		RETURN
	END

	SELECT
			@CompanyCode = UI.CompanyCode,
			@WorkCenterCode = UI.WorkCenterCode
	FROM
			STB_UserInfo UI
	WHERE
			UI.UserID = @ProcessUserID


	DECLARE @MaterialDocDetailNo VARCHAR(20),
			@MDLISeqNo INT,
			@PickingQty NUMERIC(20,5),
			@PackingID VARCHAR(20)

	SELECT
			@MaterialDocDetailNo = MLI.MaterialDocDetailNo,
			@PackingID = MLI.PackingID
	FROM
			STB_MaterialDocLotInfo MLI
	WHERE
			MLI.MaterialDocNo = @MaterialDocNo AND
			MLI.MaterialLotNo = @MaterialLotNo
			--MDI.SourceCompanyCode = @CompanyCode AND
			--MDI.SourceWorkCenterCode = @WorkCenterCode AND
			--MLI.LotID = @LotID 
	IF @MaterialDocDetailNo IS NULL BEGIN
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^피킹정보를 찾을 수 없습니다.^',
										@pValue = @NotFoundStock OUTPUT
		RAISERROR(@NotFoundStock,16,1)
		RETURN
	END

	DECLARE @Picking TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocDetailNo VARCHAR(20),
		MDLISeqNo INT,
		PickingQty NUMERIC(20,5)
	)

	IF ISNULL(@PackingID,'') <> ''
	BEGIN
			INSERT INTO @Picking
			SELECT
					MLI.MaterialDocDetailNo,
					MLI.MDLISeqNo,
					MLI.StockQty
			FROM
					STB_MaterialDocLotInfo MLI
			WHERE
					MLI.MaterialDocNo = @MaterialDocNo AND
					MLI.PackingID = @PackingID
	END ELSE BEGIN
			INSERT INTO @Picking
			SELECT
					MLI.MaterialDocDetailNo,
					MLI.MDLISeqNo,
					MLI.StockQty
			FROM
					STB_MaterialDocLotInfo MLI
			WHERE
					MLI.MaterialDocNo = @MaterialDocNo AND
					MLI.MaterialLotNo = @MaterialLotNo
	END

	DECLARE @ROW INT,
			@COUNT INT

	SELECT
			@ROW = 1,
			@COUNT = COUNT(*)
	FROM
			@Picking P

	IF @COUNT = 0 BEGIN
		RETURN
	END

	WHILE @ROW <= @COUNT BEGIN
		SELECT
				@MaterialDocDetailNo = P.MaterialDocDetailNo,
				@MDLISeqNo = P.MDLISeqNo,
				@PickingQty = P.PickingQty
		FROM
				@Picking P
		WHERE
				P.ROW = @ROW
		-- STB_MaterialDocLotInfi 의 트리거에서 자동처리
		-- 수물상세 내역 피킹수량 차감
		--UPDATE
		--		STB_MaterialDocDetail
		--SET
		--		PickingQty = PickingQty - @PickingQty
		--WHERE
		--		MaterialDocNo = @MaterialDocNo AND
		--		MaterialDocDetailNo = @MaterialDocDetailNo

		-- 수불 LOT 정보를 삭제한다.
		DELETE FROM STB_MaterialDocLotInfo
		WHERE
				MaterialDocDetailNo = @MaterialDocDetailNo AND
				MDLISeqNo = @MDLISeqNo
				--LotID = @LotID

		SET @ROW = @ROW + 1
	END


	IF (SELECT COUNT(*) FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = @MaterialDocNo) > 0 BEGIN	
		UPDATE STB_MaterialDocInfo
		SET
				DocStatus = 'WORKING'
		WHERE
				MaterialDocNo = @MaterialDocNo
	END ELSE BEGIN
		UPDATE STB_MaterialDocInfo
		SET
				--DocStatus = 'CREATE'		-- 2018-09-10 JGH 수정
				DocStatus = 'APPROVED'		-- 2018-09-10 JGH 수정
		WHERE
				MaterialDocNo = @MaterialDocNo
	END
	
END
