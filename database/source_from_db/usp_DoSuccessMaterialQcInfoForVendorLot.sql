
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description: 수입검사 기존 합격한 업체Lot으로 입고된 Lot은 자동합격 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSuccessMaterialQcInfoForVendorLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    
	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @GRProcessQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @TotalCount INT
	DECLARE @LoopCount INT
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @PickingAssingQty NUMERIC(20,5)
	DECLARE @BefQcStatus VARCHAR(1)

	DECLARE @MaterialDocDetail TABLE
	(
		IDX INT,
		MaterialDocDetailNo VARCHAR(20),
		PickingAssignQty NUMERIC(20,5)
	)
    
	DECLARE @MaterialQcList TABLE
	(
		IDX INT,
		MaterialQcNo VARCHAR(20)
	)

	DECLARE MaterialQcList CURSOR FOR
		SELECT
				MDD.MaterialIqcNo
		FROM
				STB_MaterialDocDetail MDD
				INNER JOIN
				(
					SELECT
							DISTINCT
							MDD.VendorLotNo
					FROM
							STB_MaterialDocInfo MDI
							INNER JOIN STB_MaterialDocDetail MDD
								ON MDD.MaterialDocNo = MDI.MaterialDocNo
					WHERE
							MDI.IsCancel = 0 AND
							MDI.DocStatus = 'FIX' AND
							MDD.VendorLotNo IN (SELECT VendorLotNo FROM STB_MaterialDocDetail WHERE MaterialDocNo = @MaterialDocNo)
				) MDVH
					ON MDVH.VendorLotNo = MDD.VendorLotNo
		WHERE
				MDD.MaterialDocNo = @MaterialDocNo
		GROUP BY
				MDD.MaterialIqcNo

	OPEN MaterialQcList

	WHILE 1 = 1 BEGIN
			FETCH NEXT FROM MaterialQcList INTO @OldMaterialQcNo

			IF @@FETCH_STATUS <> 0 BEGIN
					BREAK;
			END

			UPDATE STB_MaterialQcInfo
			SET
				ProcessQty = QcQty,
				DecisionResult = 'Pass',
				DecisionDateTime = GETDATE(),
				DecisionUserID = 'system',
				ChangeDateTime = GETDATE(),
				ChangeUserID = 'system'
			WHERE
				MaterialQcNo = @OldMaterialQcNo

			UPDATE STB_MaterialQcDetail
			SET
					DecisionResult = 'Pass',
					ChangeDateTime = GETDATE(),
					ChangeUserID = 'system'
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					ISNULL(DecisionResult, '') = '' 

			DELETE FROM @MaterialDocDetail
			
			INSERT INTO @MaterialDocDetail
				(IDX, MaterialDocDetailNo, PickingAssignQty)
			SELECT
					ROW_NUMBER() OVER (ORDER BY MDD.MaterialDocDetailNo),
					MDD.MaterialDocDetailNo,
					MDD.PickingAssignQty
			FROM
					STB_MaterialDocDetail MDD
					LEFT OUTER JOIN STB_MaterialDocInfo MDI 
						ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
			WHERE 
					MDD.MaterialIqcNo = @OldMaterialQcNo AND
					ISNULL(MDI.IsCancel,0) = 0

			SELECT
					@TotalCount = COUNT(*)
			FROM
					@MaterialDocDetail

			SELECT
					@GRProcessQty = MQI.ProcessQty
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			SET @RemainQty = @GRProcessQty
			SET @LoopCount = 1

			WHILE @LoopCount <= @TotalCount BEGIN
					SELECT
							@MaterialDocDetailNo = MaterialDocDetailNo,
							@PickingAssingQty = PickingAssignQty
					FROM
							@MaterialDocDetail
					WHERE
							IDX = @LoopCount

					IF @PickingAssingQty >= @RemainQty 
					BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @RemainQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = 0
					END ELSE BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @PickingAssingQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = @RemainQty - @PickingAssingQty
					END

					SET @LoopCount = @LoopCount + 1
			END
	END
END

