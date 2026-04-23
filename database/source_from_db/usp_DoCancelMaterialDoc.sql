

-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-11-18
-- Description:	문서를 취소합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelMaterialDoc]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo

	DECLARE @ErrorMessage NVARCHAR(MAX)

    EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo,
									@pErrorWhenFinish = 0,
									@pErrorWhenFix = 0

	IF @@ERROR <> 0 BEGIN
		RETURN
	END

	DECLARE @DocType VARCHAR(20),
			@DocStatus VARCHAR(20),
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@SourceDefaultLocationCode VARCHAR(20),
			@TargetCompanyCode VARCHAR(20),
			@TargetWorkCenterCode VARCHAR(20),
			@TargetMaterialWarehouseCode VARCHAR(20),
			@TargetDefaultLocationCode VARCHAR(20),
			@TotalStockQty NUMERIC(20,5),
			@IsUploadERP BIT
	SELECT
			@DocType = MDI.MaterialDocType,
			@DocStatus = MDI.DocStatus,
			@MaterialDocType = MDI.MaterialDocType,
			@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
			@SourceCompanyCode = MDI.SourceCompanyCode,
			@SourceWorkCenterCode = MDI.SourceWorkCenterCode,
			@SourceMaterialWarehouseCode = MDI.SourceMaterialWarehouseCode,
			@SourceDefaultLocationCode = SMW.DefaultLocationCode,
			@TargetCompanyCode = MDI.TargetCompanyCode,
			@TargetWorkCenterCode = MDI.TargetWorkCenterCode,
			@TargetMaterialWarehouseCode = MDI.TargetMaterialWarehouseCode,
			@TargetDefaultLocationCode = TMW.DefaultLocationCode,
			@IsUploadERP = MDI.IsUploadERP
	FROM
			STB_MaterialDocInfo MDI
			LEFT OUTER JOIN STB_MaterialWarehouse SMW
				ON	SMW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialWarehouse TMW
				ON	TMW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

	IF @IsUploadERP = 1 BEGIN
			EXEC usp_GetSystemStringResource	@ProcessLanguage,
												'^ERP 로 업로드되어 취소할 수 없습니다.^',
												@ErrorMessage OUTPUT

			RAISERROR(@ErrorMessage,16,1)
			RETURN
	END

	IF @DocStatus = 'FIX' AND @MaterialDocTypeCode = 'MOVE' BEGIN		
			EXEC usp_GetSystemStringResource	@ProcessLanguage,
												'^확정된 이동은 취소할 수 없습니다.^',
												@ErrorMessage OUTPUT

			RAISERROR(@ErrorMessage,16,1)
			RETURN
	END


	--Mr. Tung EA Team in Vietnam - prevent Warehouse Cancel Material Doc  200715000150
	--2021-01-22
	IF @TargetCompanyCode='VVT'  
	and @TargetMaterialWarehouseCode<>'PROD_STBY_VN_WH' 
	and @TargetMaterialWarehouseCode<>'PROD_VN_WH'
	and @TargetMaterialWarehouseCode<>'MODULE_VN_WH'
	BEGIN  
		
		declare @cCount1 numeric(10,0) = 0;
		EXEC usp_Vietnam_CancelDocLo '','',@MaterialDocNo,@cCount1 OUTPUT;

		if(@cCount1 = 0)
		 begin
			declare @err varchar(100)= '^Khong duoc phep huy bo don nhap lieu. Lien he EA team-^'+  @MaterialDocNo		
			EXEC usp_GetSystemStringResource	@ProcessLanguage,
												@err,
												@ErrorMessage OUTPUT

			RAISERROR(@ErrorMessage,16,1)
			RETURN
		 end
	END


	DECLARE @MaterialDocDetailNo VARCHAR(20),
			@OrderDetailNo VARCHAR(20),
			@MaterialIqcNo VARCHAR(20),
			@RequestQty NUMERIC(20,5),
			@AllowQty NUMERIC(20,5),
			@PickingAssignQty NUMERIC(20,5),	-- GR : 입하수량 / GI : 피킹할당수량
			@PickingQty NUMERIC(20,5),		-- GR : 입고수량 / GI : 피킹수량
			@ProcessFixQty NUMERIC(20,5)		-- GR : 입고확정수량 / GI : 출고확정수량

	DECLARE @Lot TABLE
	(
		ROW INT,
		MaterialLotNo VARCHAR(20),
		LotID VARCHAR(50),
		StockQty NUMERIC(20,5),
		ProcessQty NUMERIC(20,5)
	)

	DECLARE @LotRow INT,
			@LotCount INT,
			@MaterialLotNo VARCHAR(20),
			@StockQty NUMERIC(20,5),
			@ProcessQty NUMERIC(20,5)

	DECLARE @Detail TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocDetailNo VARCHAR(20),
		OrderDetailNo VARCHAR(20),
		MaterialIqcNo VARCHAR(20),
		RequestQty NUMERIC(20,5),
		AllowQty NUMERIC(20,5),
		PickingAssignQty NUMERIC(20,5),	-- GR : 입하수량 / GI : 피킹할당수량
		PickingQty NUMERIC(20,5),		-- GR : 입고수량 / GI : 피킹수량
		ProcessFixQty NUMERIC(20,5)		-- GR : 입고확정수량 / GI : 출고확정수량
	)
	INSERT INTO @Detail
	SELECT
			MDD.MaterialDocDetailNo,
			MDD.OrderDetailNo,
			MDD.MaterialIqcNo,
			MDD.RequestQty,
			MDD.AllowQty,
			MDD.PickingAssignQty,
			MDD.PickingQty,
			MDD.ProcessFixQty
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo

	DECLARE @ROW INT,
			@COUNT INT

	SELECT
			@ROW = 1,
			@COUNT = COUNT(*)
	FROM
			@Detail

	WHILE @ROW <= @COUNT BEGIN
		SELECT	@MaterialDocDetailNo = D.MaterialDocDetailNo,
				@OrderDetailNo = D.OrderDetailNo,
				@MaterialIqcNo = D.MaterialIqcNo,
				@RequestQty = D.RequestQty,
				@AllowQty = D.AllowQty,
				@PickingAssignQty = D.PickingAssignQty,	-- GR : 입하수량 / GI : 피킹할당수량
				@PickingQty = D.PickingQty,		-- GR : 입고수량 / GI : 피킹수량
				@ProcessFixQty = D.ProcessFixQty		-- GR : 입고확정수량 / GI : 출고확정수량
		FROM
				@Detail D
		WHERE
				D.ROW = @ROW

		IF @DocType = 'GR' BEGIN		
			-- 입고취소시에는 STB_MaterialLotInfo 가 삭제되어도 STB_MaterialLotSnapshot 에 INSERT 하지 않아야 한다.
			-- 이를 위해 트리거에서 알 수 있도록 CONTEXT_INFO 에 0x99999 을 설정한다.
			SET CONTEXT_INFO 0x999999
			BEGIN TRY
				DELETE FROM @Lot
				-- 바코드 미사용 입고 리스트
				INSERT INTO @Lot
				(
					ROW,
					MaterialLotNo,
					MS.LotID,
					StockQty,
					ProcessQty
				)
				SELECT
						ROW_NUMBER() OVER(ORDER BY MLI.GRDate),
						MLI.MaterialLotNo,
						MLI.LotID,
						MLI.CurrentQty - MLI.PickingQty,
						MDLI.StockQty
				FROM
						STB_MaterialDocLotInfo MDLI
						INNER JOIN STB_MaterialLotInfo MLI
							ON	MLI.CompanyCode = @TargetCompanyCode AND
								MLI.WorkCenterCode = @TargetWorkCenterCode AND
								MLI.MaterialWarehouseCode = @TargetMaterialWarehouseCode AND
								MLI.MaterialLocationCode =	CASE 
																WHEN ISNULL(MDLI.MaterialLocationCode,'') = '' THEN @TargetDefaultLocationCode 
																ELSE MDLI.MaterialLocationCode 
															END AND 
								MLI.MaterialCode = MDLI.MaterialCode AND
								MLI.MaterialStockAttribute = MDLI.MaterialStockAttribute AND
								MLI.StockAttrib1 = MDLI.StockAttrib1 AND
								MLI.StockAttrib2 = MDLI.StockAttrib2 AND
								MLI.StockAttrib3 = MDLI.StockAttrib3							
				WHERE
						MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND
						(MDLI.LotID IS NULL OR MDLI.LotID = '')
				ORDER BY
						MLI.GRDate

				-- 바코드 사용 입고 리스트
				INSERT INTO @Lot
				(
					ROW,
					MaterialLotNo,
					MS.LotID,
					StockQty,
					ProcessQty
				)
				SELECT
						ROW_NUMBER() OVER(ORDER BY MLI.GRDate),
						MLI.MaterialLotNo,
						MLI.LotID,
						MLI.CurrentQty - MLI.PickingQty,
						MDLI.StockQty
				FROM
						STB_MaterialDocLotInfo MDLI
						INNER JOIN STB_MaterialLotInfo MLI
							ON	MLI.LotID = MDLI.LotID		
				WHERE
						MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND					
							MDLI.LotID IS NOT NULL AND MDLI.LotID <> ''
				ORDER BY
						MLI.GRDate
					
				SELECT
						@TotalStockQty = SUM(L.StockQty)
				FROM
						@Lot L

				-- 재고수량이 입고처리 수량만큼 있는 지 체크
				IF @ProcessFixQty > @TotalStockQty BEGIN
					DECLARE @NotEnoughStockError NVARCHAR(MAX)
					EXEC usp_GetSystemStringResource	@ProcessLanguage,
														'^취소할 재고가 부족합니다.^',
														@NotEnoughStockError OUTPUT

					RAISERROR(@NotEnoughStockError,16,1)
					RETURN													
				END
				
				IF @DocStatus = 'FIX' BEGIN
					SELECT
							@LotRow = 1,
							@LotCount = COUNT(*)
					FROM
							@Lot L

					WHILE @LotRow <= @LotCount BEGIN
						IF @ProcessFixQty <= 0 BEGIN
							BREAK
						END

						SELECT
								@MaterialLotNo = L.MaterialLotNo,
								@ProcessQty = L.ProcessQty,
								@StockQty = L.StockQty
						FROM
								@Lot L
						WHERE
								L.ROW = @LotRow
						
						IF @StockQty <= @ProcessFixQty BEGIN
							DELETE FROM STB_MaterialLotInfo
							WHERE
									MaterialLotNo = @MaterialLotNo
							SET @ProcessFixQty = @ProcessFixQty - @StockQty
						END ELSE BEGIN
							UPDATE	STB_MaterialLotInfo
							SET		CurrentQty = CurrentQty - @ProcessQty,
									ChangeDateTime = GETDATE(),
									ChangeUserID = @ProcessUserID
							WHERE	MaterialLotNo = @MaterialLotNo
							SET @ProcessFixQty = 0
						END

						SET @LotRow = @LotRow + 1
					END
				END
				IF @ProcessFixQty > 0 BEGIN
					DECLARE @NotEnoughStockError2 NVARCHAR(MAX)
					EXEC usp_GetSystemStringResource	@pLanguage = @ProcessLanguage,
														@pName = '^재고수량이 부족합니다.^',
														@pValue = @NotEnoughStockError2 OUTPUT
					RAISERROR(@NotEnoughStockError2,16,1)
					RETURN
				END
				-- 발주잔량 복원
				UPDATE
						STB_MaterialOrderItem
				SET
						MaterialOrderRemainQty = MaterialOrderRemainQty + 
													CASE 
															WHEN @DocStatus = 'FIX' THEN @ProcessFixQty
															ELSE @RequestQty
													END,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @ProcessUserID
				WHERE
						MaterialOrderItemNo = @OrderDetailNo

				DELETE FROM STB_MaterialQCDetail
				WHERE
						MaterialQCNo IN 
										(
											SELECT
													MaterialIqcNo
											FROM
													STB_MaterialDocDetail MDD
											WHERE
													MDD.MaterialDocNo = @MaterialDocNo 
										)

				DELETE FROM STB_MaterialQcInfo
				WHERE 
						MaterialQcNo IN 
										(
											SELECT
													MaterialIqcNo
											FROM
													STB_MaterialDocDetail MDD
											WHERE
													MDD.MaterialDocNo = @MaterialDocNo 
										)


				SET CONTEXT_INFO 0
			END TRY
			BEGIN CATCH
				SET CONTEXT_INFO 0
				DECLARE @ERROR_NUMBER BIGINT = ERROR_NUMBER()
				DECLARE @ERROR_MESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
				--THROW @ERROR_NUMBER,@ERROR_MESSAGE,1
				RAISERROR(@ERROR_MESSAGE,16,1)
			END CATCH
		END ELSE IF @DocType IN ('GI','MOVE') BEGIN
			
			IF @DocStatus = 'FIX' BEGIN
				-- 기존 재고가 남아있으면 재고수량 업데이트
				UPDATE	STB_MaterialLotInfo
				SET		CurrentQty = CurrentQty + MDLI.StockQty
				FROM	STB_MaterialDocLotInfo MDLI
						INNER JOIN STB_MaterialLotInfo MLI
							ON	MLI.MaterialLotNo = MDLI.MaterialLotNo
				WHERE
						MaterialDocDetailNo = @MaterialDocDetailNo
			
				-- 모두 출고되어서 재고정보가 없는 경우 Snapshot 에서 복원
				INSERT INTO STB_MaterialLotInfo
				(
					MaterialLotNo,
					LotID,
					CompanyCode,
					WorkCenterCode,
					MaterialWarehouseCode,
					MaterialLocationCode,
					MaterialCode,
					MaterialStockAttribute,
					StockAttrib1,
					StockAttrib2,
					StockAttrib3,
					PackingID,
					GRDate,
					InitialQty,
					CurrentQty,
					PickingQty,
					VendorLotNo,
					LifeBasicDate,
					ProductionDate,
					EndOfLifeDate,
					LotNo,
					IsSplitLot,
					BefMaterialLotNo,
					CreateDateTime,
					CreateUserID,
					ChangeDateTime,
					ChangeUserID
				)
				SELECT
						MLS.MaterialLotNo,
						MLS.LotID,
						MLS.CompanyCode,
						MLS.WorkCenterCode,
						MLS.MaterialWarehouseCode,
						MLS.MaterialLocationCode,
						MLS.MaterialCode,
						MLS.MaterialStockAttribute,
						MLS.StockAttrib1,
						MLS.StockAttrib2,
						MLS.StockAttrib3,
						MLS.PackingID,
						MLS.GRDate,
						MLS.InitialQty,
						MDLI.StockQty,
						0,
						MLS.VendorLotNo,
						MLS.LifeBasicDate,
						MLS.ProductionDate,
						MLS.EndOfLifeDate,
						MLS.LotNo,
						MLS.IsSplitLot,
						MLS.BefMaterialLotNo,
						MLS.CreateDateTime,
						MLS.CreateUserID,
						MLS.ChangeDateTime,
						MLS.ChangeUserID
				FROM
						STB_MaterialDocLotInfo MDLI
						INNER JOIN STB_MaterialLotSnapshot MLS
							ON	MLS.MaterialLotNo = MDLI.MaterialLotNo
				WHERE
						MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
			END
			
			-- 영업오더 처리수량 복원

			IF @DocStatus = 'FIX'
			BEGIN
					UPDATE
							STB_SalesOrderItem
					SET
							GIFixQty = GIFixQty - @ProcessFixQty,
							ChangeDateTime = GETDATE(),
							ChangeUserID = @ProcessUserID
					WHERE
							SOISequence = @OrderDetailNo
			END ELSE BEGIN
					UPDATE
							STB_SalesOrderItem
					SET
							GIPlanQty = GIPlanQty - @RequestQty,
							ChangeDateTime = GETDATE(),
							ChangeUserID = @ProcessUserID
					WHERE
							SOISequence = @OrderDetailNo

			END


		END -- IF @DocType = 'GR' BEGIN

		SET @ROW = @ROW + 1
	END -- WHILE @ROW <= @COUNT BEGIN

	-- 출고취소시 STB_MaterialDocLotInfo 가 삭제될 때 trigger 에서 STB_MaterialLotInfo 의 Picking 수량을 차감하는데
	-- 확정이 되었으면 이미 Picking 수량은 차감이 되었기 때문에 취소시에는 차감되면 안된다.
	IF @DocStatus = 'FIX' BEGIN
		SET CONTEXT_INFO 0x999997
	END
	DELETE FROM STB_MaterialDocLotInfo
	WHERE
			MaterialDocNo = @MaterialDocNo
	IF @DocStatus = 'FIX' BEGIN
		SET CONTEXT_INFO 0
	END
	
	IF @DocType IN ('GI','MOVE') BEGIN
		DELETE FROM STB_MaterialDocPickingPlan
		WHERE
				MaterialDocNo = @MaterialDocNo				
	END

	UPDATE STB_MaterialDocInfo
	SET
			IsCancel = 1,
			CancelDateTime = GETDATE(),
			CancelUserID = @ProcessUserID
	WHERE
			MaterialDocNo = @MaterialDocNo

END


