
-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date: 2016-09-03
-- Description: 수불문서의 완료를 취소합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelFinishMaterialDoc]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pIsCancelDoc  BIT = 0	-- 문서취소여부
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@DocStatus VARCHAR(20),
			@ErrorMessage NVARCHAR(MAX)

	IF @pIsCancelDoc = 0 BEGIN
		EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
										@pProcessUserID = @ProcessUserID,
										@pMaterialDocNo = @MaterialDocNo,
										@pErrorWhenFinish = 0

		SELECT
				@MaterialDocType = MDI.MaterialDocType,
				@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
				@DocStatus = MDI.DocStatus
		FROM
				STB_MaterialDocInfo MDI
		WHERE
				MDI.MaterialDocNo = @MaterialDocNo

		IF @DocStatus <> 'FINISH' BEGIN
			EXEC usp_GetSystemStringResource	@ProcessLanguage,
												'^완료상태가 아닙니다.^',
												@ErrorMessage OUTPUT
			RAISERROR(@ErrorMessage,16,1)
			RETURN
		END
	
		UPDATE
				STB_MaterialDocInfo
		SET
				DocStatus = CASE @MaterialDocType
								WHEN 'GR' THEN 'ARRIVAL'
								WHEN 'GI' THEN 'WORKING'
								WHEN 'MOVE' THEN 'WORKING'
								ELSE 'CREATE'
							END,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @ProcessUserID
		WHERE
				MaterialDocNo = @MaterialDocNo
	END
			
	-- 입고완료(usp_DoFinishMaterialDoc)때 바코드 미사용자재는 미리 STB_MaterialDocLotInfo 에 INSERT 해준다.
	-- 입고는 바코드 STB_MaterialDocLotInfo 에서 미사용자재를 삭제한다.
	IF @MaterialDocType = 'GR' BEGIN
		UPDATE STB_MaterialDocDetail
		SET
				PickingQty = 0	-- 입고수량 초기화
		FROM
				STB_MaterialDocDetail MDD
				INNER JOIN STB_MaterialMaster MM 
					ON	MM.MaterialCode = MDD.MaterialCode
				LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI
					ON	MSAI.MaterialCode = MM.MaterialCode
		WHERE
				MDD.MaterialDocNo = @MaterialDocNo AND
				ISNULL(MSAI.IsUseBarcode,0) = 0

		DELETE	FROM STB_MaterialDocLotInfo
		WHERE
				MaterialDocDetailNo IN	(
											SELECT
													MDD.MaterialDocDetailNo
											FROM
													STB_MaterialDocDetail MDD
													INNER JOIN STB_MaterialMaster MM 
														ON	MM.MaterialCode = MDD.MaterialCode
													LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI
														ON	MSAI.MaterialCode = MM.MaterialCode
											WHERE
													MDD.MaterialDocNo = @MaterialDocNo AND
													ISNULL(MSAI.IsUseBarcode,0) = 0
										)
	END 
	
END
