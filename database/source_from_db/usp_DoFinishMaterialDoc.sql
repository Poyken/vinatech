
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-19
-- Description:	자재수불문서의 완료처리를 시도합니다.  [F330] 자재입고 및 라벨발행 화면에서 "입고완료"버튼 이벤트
-- Parameter
-- * @pIsTry : PDA 작업 시 FINISH 가 가능한 상태이면 바로 FINISH 처리한다.
--             @pIsTry 가 true 이면 에러는 발생시키지 않게 하도록 하여 PDA 작업에 영향을 주지 않도록 한다.
--			   PDA 작업을 완료한 후 PC에서 처리 할 경우 @pIsTry 가 false 이면 유효성 체크 실패 시 에러를 발생하도록 한다.
--			   예를 들어 입하 수량과 입고처리 수량이 불일치 하거나 바코드 사용 자재의 경우 입하수량과 바코드 스캔 수량이 불일치 하면 에러
--			   PC 처리 시 위 에러가 나지 않으려면 입하처리 수량(STB_MaterialDocDetail.PickingAssignQty)을 실제 바코드 스캔 수량(PickingQty)으로 수정한 후 처리.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishMaterialDoc]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pIsTry BIT = 0,
	@pIsBackFlush BIT = NULL,  -- BI Back Flush때 처리, 이떄는 MaterialDocLot과 수량과 일치하지 않아도 Finish 처리한다.
	@pIsAutoCreateDocLot BIT = 1,	-- 바코드 미사용자재를 자동으로 STB_MaterialDocLotInfo 에 입력할 지 여부
	@pIsFinished BIT = 0 OUTPUT	-- FINISH 되었는 지 여부	
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@DocType VARCHAR(20),
			@DocTypeCode VARCHAR(20),
			@DocStatus  VARCHAR(20),
			@DefaultLocationCode VARCHAR(20),
			@IsRequireQC BIT,
			@IsBackFlush BIT = ISNULL(@pIsBackFlush, CONVERT(BIT, 0)),
			@IsAutoCreateDocLot BIT = @pIsAutoCreateDocLot,
			@IsCancel BIT,
			@IsExistIQC BIT = 0,
			@GRMaxDate DATE,
			@GRMinDate DATE

	Declare @companycode VARCHAR(20)= '';
	select @companycode = TargetCompanyCode 
	from STB_MaterialDocInfo where MaterialDocNo= @pMaterialDocNo

	Declare @MaterialLotNos TABLE (
		MaterialLotNo VARCHAR(50)
	   ,MaterialCode VARCHAR(20)
	);

	Declare @MaterialCode VARCHAR(20)

	SELECT
			@DocType = MDI.MaterialDocType,
			@DocTypeCode = MDI.MaterialDocTypeCode,
			@DocStatus = MDI.DocStatus,
			@DefaultLocationCode = MW.DefaultLocationCode,
			@IsRequireQC = MDT.IsRequireQC,
			@IsCancel = MDI.IsCancel
	FROM
			STB_MaterialDocInfo MDI
			LEFT OUTER JOIN STB_MaterialDocType MDT				ON	MDT.MaterialDocType = MDI.MaterialDocType                                AND	MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW			ON	MW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo

			DECLARE @WarehouseCode VARCHAR(20)
		SELECT
				@WarehouseCode = MDI.TargetMaterialWarehouseCode
		fROM
				STB_MaterialDocInfo MDI WHERE MaterialDocNo = @MaterialDocNo
				
	IF ISNULL(@IsCancel,0) = 1 BEGIN
		IF @pIsTry = 0 BEGIN
			DECLARE @CancelDocMsg NVARCHAR(MAX)
			EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																											@pName = '^취소처리된 문서입니다..^',
																											@pValue = @CancelDocMsg OUTPUT	
			RAISERROR(@CancelDocMsg, 16, 1)
		END
		RETURN
	END


	IF @DocStatus IN ('FINISH', 'FIX') BEGIN
		IF @pIsTry = 0 BEGIN
			DECLARE @AlreadyFinish NVARCHAR(MAX)
			EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																											@pName = '^이미 완료처리된 문서입니다.^',
																											@pValue = @AlreadyFinish OUTPUT	
			RAISERROR(@AlreadyFinish, 16, 1)
		END
		RETURN
	END


	

	
	--IF @DocType IN ('GR','MOVE')
	--BEGIN
	--		IF ISNULL(@DefaultLocationCode,'') = ''  
			
	--		BEGIN

	--			IF @pIsTry = 0 
				
	--			BEGIN
	--				DECLARE @NotDefineDefaultLocation NVARCHAR(MAX)
	--				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage, @pName = '^해당 창고의 기본 로케이션이 지정되지 않았습니다. ^',  @pValue = @NotDefineDefaultLocation OUTPUT	
	--				RAISERROR(@NotDefineDefaultLocation, 16, 1)
	--			END

	--			RETURN
	--		END
	--END
	
															
	DECLARE @Detail TABLE
	(
		ROW INT IDENTITY(1,1),
		MaterialDocNo VARCHAR(20),
		MaterialDocDetailNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),

		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		VendorLotNo VARCHAR(100),		-- 2018-08-28 JGH VendorLotNo 추가
		IsUseBarcode BIT,
		IsQC BIT,
		ProcessQty NUMERIC(20,5)
	)

	INSERT INTO @Detail
	SELECT
			MDI.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDD.MaterialCode,
			MDD.MaterialStockAttribute,
			MDD.StockAttrib1,
			MDD.StockAttrib2,
			MDD.StockAttrib3,
			MDD.VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
			CONVERT(BIT,ISNULL(MSAI.IsUseBarcode,0)) AS IsUseBarcode,
			CASE 	WHEN ISNULL(MDD.InspectionType,'NONE') = 'NONE' THEN 0		ELSE 1			END  AS IsQC,
			CASE MDI.MaterialDocType		WHEN 'GR' THEN 			CASE 		WHEN ISNULL(MDD.MaterialIqcNo,'') = '' THEN  SUM(MDD.PickingAssignQty) 	ELSE SUM(MDD.PickingQty)		END	ELSE SUM(MDD.AllowQty)	END AS ProcessQty             -- 입하수량	-- 수입검사 완료수량 -- 출고나 이동의 경우 승인수량
	FROM
			STB_MaterialDocDetail MDD			
			LEFT OUTER JOIN STB_MaterialDocInfo MDI				   ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI	   ON	MSAI.MaterialCode = MDD.MaterialCode
	WHERE
			--MDD.MaterialDocNo = @MaterialDocNo
			MDD.MaterialDocNo IN ( '190610000001', '190610000002')
	GROUP BY
			MDI.MaterialDocType,
			MDI.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDD.MaterialCode,
			MDD.MaterialStockAttribute,
			MDD.StockAttrib1,
			MDD.StockAttrib2,
			MDD.StockAttrib3,
			MSAI.IsUseBarcode,
			MDD.InspectionType,
			MDD.MaterialIqcNo,
			MDD.VendorLotNo		-- 2018-08-28 JGH VendorLotNo 추가


	/****************************************************************************************/
	-- 피킹된 Lot의 GRDate 최대값보다 작은 데이터가 창고에 존재하면 에러 발생
	--IF @DocType IN ('GR') BEGIN
	--	INSERT INTO @MaterialLotNos
	--			SELECT MaterialLotNo, MaterialCode
	--			  FROM STB_MaterialLotInfo
	--			 WHERE LotID IN (
	--							SELECT LotID 
	--							  FROM STB_MaterialDocLotInfo
	--							 WHERE MaterialDocDetailNo IN (
	--															SELECT MaterialDocDetailNo
	--															  FROM @Detail
	--														  )
	--			)

	--	SELECT @MaterialCode = MaterialCode
	--	  FROM @MaterialLotNos

	--	SELECT @GRMaxDate = GRDate
	--	  FROM STB_MaterialLotInfo
	--	 WHERE MaterialLotNo IN (SELECT MaterialLotNo FROM @MaterialLotNos)

	--	SELECT @GRMinDate = GRDate
	--	  FROM STB_MaterialLotInfo
	--	 WHERE MaterialCode = @MaterialCode
	--	   AND MaterialLotNo NOT IN (SELECT MaterialLotNo FROM @MaterialLotNos)

	--	IF @GRMaxDate > @GRMinDate BEGIN -- 피킹된 제품의 최종입고일자와 피킹되지 않은 동일 제품 재고의 입고일자를 비교
	--		EXEC usp_RaiseLocalizedError @pProcessLanguage, '창고 재고 중 피킹된 품목보다 이전 재고가 존재합니다.'
	--		RETURN
	--	END
	--END

	/****************************************************************************************/
	-- 바코드 사용 자재중 모든 박스가 스캔되지 않은 자재가 있으면 FINISH 불가
	-- 바코드 관리 자재 총수량
	DECLARE @BarcodeCount NUMERIC(20,5)
	SELECT	
			@BarcodeCount = SUM(D.ProcessQty)
	FROM	
			@Detail D 
	WHERE	
			D.IsUseBarcode = 1

	SET @BarcodeCount = ISNULL(@BarcodeCount,0)

	-- 바코드 관리 자재중 스캔된 자재 수량
	DECLARE @ScanCount NUMERIC(20,5)

	SELECT
			@ScanCount = ISNULL(SUM(MDLI.StockQty),0)
	FROM
			@Detail D
			INNER JOIN STB_MaterialDocLotInfo MDLI				ON	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo
	WHERE 1=1
			AND D.IsUseBarcode = 1
			AND	MDLI.IsChecked = 1
	
	--DECLARE @b VARCHAR(20) = CONVERT(VARCHAR,@BarcodeCount)
	--DECLARE @c VARCHAR(20) = CONVERT(VARCHAR,@ScanCount)
	--RAISERROR('%s/%s',16,1,@b,@c)
	--RETURN
	-- 바코드 관리자재 총수량과 스캔된 수량이 일치하지 않으면 FINISH 불가
	
	IF @IsBackFlush = 0
	BEGIN
		--IF @BarcodeCount = 0 OR @BarcodeCount <> @ScanCount BEGIN	-- 2018-08-28 JGH 수정 바코드 미사용 자재는 스캔하지 않음 BarcodeCount = 0 OR ??
		IF @BarcodeCount <> @ScanCount 
		
		
		BEGIN
		
			IF @pIsTry = 0 BEGIN
				DECLARE @NotMatchScanCount NVARCHAR(MAX),
						@ScanCountString VARCHAR(50),
						@BarcodeCountString VARCHAR(50)

				SET @ScanCountString = CONVERT(VARCHAR, @ScanCount)
				SET @BarcodeCountString = CONVERT(VARCHAR, @BarcodeCount)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^모든 바코드가 스캔되지 않았습니다.^',
																	@pValue = @NotMatchScanCount OUTPUT	
				RAISERROR('%s : %s, %s', 16,1, @NotMatchScanCount, @ScanCountString, @BarcodeCountString)				
			END
			RETURN
		END
	END

	/****************************************************************************************/
	-- 입고는 동일한 프로세스로 FINISH 체크
	-- 입하 > 수입검사 > 라벨발행 > 라벨스캔 > 입고완료 > 입고확정
	-- 무검사자재, 바코드 미사용 자재만 있을 경우 FINISH
	/****************************************************************************************/

	IF @DocType = 'GR' BEGIN
		IF @IsRequireQC = 1 BEGIN	
			-- 검사의뢰는 usp_DoArriveMaterialDelivery 에서 이 프로시저를 호출하기 전에 만들어지므로
			-- 검사자재의 검사의뢰문서는 반드시 존재하고 있다
			-- 검사 자재 중 검사가 완료되지 않은 검사의뢰가 있으면 FINISH 불가
			IF 	(	SELECT 
							COUNT(*)
					FROM
							STB_MaterialDocDetail MDD
							INNER JOIN STB_MaterialQCInfo MII
								ON	MII.MaterialQcNo = MDD.MaterialIqcNo
							
					WHERE
							MDD.MaterialDocNo = @MaterialDocNo AND
							MII.DecisionResult In 
							(
							'None', 
							case when @companycode='VVT' then 'None' else 'Reject' end --Mr.Tung modify on 2022-Nov-22 IQC Mr.Kien & Warehouse Mr.Minh
							)
				) > 0
			BEGIN
					
				IF @pIsTry = 0 BEGIN
					DECLARE @NotFinishIQC NVARCHAR(MAX)			
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^검사가 완료되지 않았거나, 불합격 제품 입니다^',
																		@pValue = @NotFinishIQC OUTPUT
					RAISERROR(@NotFinishIQC,16,1)				
				END
				RETURN
			END ELSE BEGIN
				IF (
						SELECT
								COUNT(*)
						FROM 
								STB_MaterialDocDetail MDD
								INNER JOIN STB_MaterialQCInfo MII
									ON	MII.MaterialQcNo = MII.MaterialQcNo
						WHERE
								MDD.MaterialDocNo = @MaterialDocNo
					) > 0
				BEGIN
						SET @IsExistIQC = 1
				END ELSE BEGIN
						SET @IsExistIQC = 0
				END

			END
		END

		/****************************************************************************************/
		-- 입고상세내역에 입고완료 수량 업데이트
		-- 바코드 사용 자재는 스캔된(IsChecked = 1) 수량 만큼
		-- 바코드 미사용 자재는 입하수량 그대로 입고수량으로 처리
		-- 바코드 미사용 + 수입미검사 자재는 입하수량으로 입고확정수량까지 처리
		-- 바코드 사용 + 수입미검사 자재는 입고수량으로 입고확정수량까지 처리
		/****************************************************************************************/
		UPDATE
				STB_MaterialDocDetail
		SET
				PickingQty = CASE
								WHEN D.IsUseBarcode = 1 THEN 
									(
										SELECT	ISNULL(SUM(MDLI.StockQty),0)
										FROM	STB_MaterialDocLotInfo MDLI 
										WHERE	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo AND
												MDLI.IsChecked = 1
									)
								ELSE
									CASE 
											WHEN @IsExistIQC = 0 THEN MDD.PickingAssignQty
											ELSE PickingQty
									END
							 END,
				-- Modify By PJS : 2016.09.03 
				-- Fix 때 ProcessFixQty 처리하므로 처리하지 않는다.
				--ProcessFixQty = CASE
				--					WHEN D.IsUseBarcode = 0 AND D.IsQC = 0 THEN MDD.PickingAssingQty
				--					ELSE
				--						CASE
				--							WHEN D.IsUseBarcode = 1 AND D.IsQC = 0 THEN
				--								(
				--									SELECT	ISNULL(SUM(MDLI.StockQty),0)
				--									FROM	STB_MaterialDocLotInfo MDLI 
				--									WHERE	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo AND
				--											MDLI.IsChecked = 1
				--								)
				--							ELSE 
				--								CASE
				--										WHEN IsQC = 1 THEN
				--											CASE 
				--													WHEN @IsExistIQC = 0 THEN MDD.PickingAssingQty
				--													ELSE PickingQty
				--											END
											
				--										ELSE 0
				--								END
				--						END
				--				END,				
				ChangeDateTime = GETDATE(),
				ChangeUserID = @ProcessUserID
		FROM
				@Detail D
				INNER JOIN STB_MaterialDocDetail MDD
					ON	MDD.MaterialDocDetailNo = D.MaterialDocDetailNo		
		WHERE
				D.MaterialDocNo = @MaterialDocNo
		/****************************************************************************************/

		/****************************************************************************************/
		-- 라벨미사용 자재는 입고완료 시에 수불 LOT 정보를 생성한다.
		-- 라벨사용 자재의 경우 사내발행인 경우엔 발행 시점에 생성되고
		-- 업체라벨을 사용하는 경우엔 바코드를 스캔할 때 생성된다.
		/****************************************************************************************/
		IF @IsAutoCreateDocLot = 1 BEGIN
			INSERT INTO STB_MaterialDocLotInfo
			(
				MaterialDocDetailNo,
				MDLISeqNo,
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
				VendorLotNo,
				CreateDateTime,
				CreateUserID
			)
			SELECT
					D.MaterialDocDetailNo,
					D.ROW,						--MDLISeqNo,
					'',							-- LotID
					D.MaterialCode,
					D.MaterialStockAttribute,
					D.StockAttrib1,
					D.StockAttrib2,
					D.StockAttrib3,
					D.ProcessQty,				-- StockQty
					1,							-- IsChecked
					@DefaultLocationCode,		-- MaterialLocationCode
					@MaterialDocNo,				-- MaterialDocNo
					'',							-- PackingID
					D.VendorLotNo,				-- VendorLotNo	-- 2018-08-28 JGH VendorLotNo 추가
					GETDATE(),
					@ProcessUserID
			FROM
					@Detail D
			WHERE
					D.IsUseBarcode = 0


			IF @@ERROR <> 0 BEGIN
				RETURN
			END
		END
		/****************************************************************************************/
	END ELSE IF @DocType IN ('GI', 'MOVE') 
	
	BEGIN
		IF @IsBackFlush = 0 BEGIN
			DECLARE @NoBarcodeCount NUMERIC(20,5)
			SELECT	
					@NoBarcodeCount = SUM(D.ProcessQty)
			FROM	
					@Detail D 
			WHERE	
					D.IsUseBarcode = 0

			SET @NoBarcodeCount = ISNULL(@NoBarcodeCount,0)

			-- 바코드 미관리 자재중 처리 자재 수량
			DECLARE @LotCount NUMERIC(20,5)
			SELECT
					@LotCount = ISNULL(SUM(MDLI.StockQty),0)
			FROM
					@Detail D
					INNER JOIN STB_MaterialDocLotInfo MDLI
						ON	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo
			WHERE
					D.IsUseBarcode = 0 AND
					MDLI.IsChecked = 1

			-- 바코드 미관리자재 총수량과 스캔된 수량이 일치하지 않으면 FINISH 불가
			IF @NoBarcodeCount <> @LotCount BEGIN		
				IF @pIsTry = 0 BEGIN
					DECLARE @NotMatchLotCount NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^처리수량이 부족한 제품이 있습니다.^',
																		@pValue = @NotMatchLotCount OUTPUT	
					RAISERROR(@NotMatchLotCount,16,1)				
				END
				RETURN
			END
		END

		/****************************************************************************************/
		-- 출고상세내역의 수량과 출고제품내역의 수량이 일치하지 않으면 FINISH 불가
		/****************************************************************************************/
		DECLARE @AllowQty NUMERIC(20,5)
		SELECT 
				@AllowQty = ISNULL(SUM(MDD.AllowQty),0)
		FROM 
				STB_MaterialDocDetail MDD 
		WHERE 
				MaterialDocNo = @MaterialDocNo

		DECLARE @LotQty NUMERIC(20,5)
		SELECT 
				@LotQty = ISNULL(SUM(MDLI.StockQty),0)
		FROM 
				STB_MaterialDocLotInfo MDLI 
		WHERE 
				MaterialDocNo = @MaterialDocNo
		
		--DECLARE @x VARCHAR(20) = CONVERT(VARCHAR,@AllowQty)		
		--DECLARE @y VARCHAR(20) = CONVERT(VARCHAR,@LotQty)
		
		--RAISERROR('%s/%s', 16, 1,@x,@y)
		--RETURN
		IF @IsBackFlush = 0
		BEGIN
				IF ( @AllowQty <> @LotQty) BEGIN
					IF @pIsTry = 0 BEGIN
						DECLARE @NotEnoughGIQtyError NVARCHAR(MAX)			
						EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																			@pName = '^모든 제품이 피킹되지 않았습니다.^',
																			@pValue = @NotEnoughGIQtyError OUTPUT
						RAISERROR(@NotEnoughGIQtyError,16,1)		
					END
					RETURN
				END

				/****************************************************************************************/
				-- 출고상세내역에 피킹 수량 업데이트
				-- 바코드 사용 자재는 스캔된(IsChecked = 1) 수량 만큼
				-- 바코드 미사용 자재는 수불LOT수량 그대로 처리
				/****************************************************************************************/
				UPDATE
						STB_MaterialDocDetail
				SET
						PickingQty = CASE
										WHEN D.IsUseBarcode = 1 THEN 
											(
												SELECT	SUM(MDLI.StockQty)
												FROM	STB_MaterialDocLotInfo MDLI 
												WHERE	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo AND
														MDLI.IsChecked = 1
											)
										ELSE
											(
												SELECT	SUM(MDLI.StockQty)
												FROM	STB_MaterialDocLotInfo MDLI 
												WHERE	MDLI.MaterialDocDetailNo = D.MaterialDocDetailNo
											)
									 END
				FROM
						@Detail D
						INNER JOIN STB_MaterialDocDetail MDD
							ON	MDD.MaterialDocDetailNo = D.MaterialDocDetailNo		
				WHERE
						D.MaterialDocNo = @MaterialDocNo
		END
		--END ELSE BEGIN
		--		UPDATE
		--				STB_MaterialDocDetail
		--		SET
		--				PickingAssingQty =  AllowQty
		--		FROM
		--				@Detail D
		--				INNER JOIN STB_MaterialDocDetail MDD
		--					ON	MDD.MaterialDocDetailNo = D.MaterialDocDetailNo		
		--		WHERE
		--				D.MaterialDocNo = @MaterialDocNo AND
		--				D.IsUseBarcode = 0
		--END
		/****************************************************************************************/
	END
	/****************************************************************************************/


	UPDATE
			STB_MaterialDocInfo
	SET
			DocStatus = 'FINISH',
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			MaterialDocNo = @MaterialDocNo

	SET @pIsFinished = 1
	
END





