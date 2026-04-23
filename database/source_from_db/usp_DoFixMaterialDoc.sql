

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-20
-- Browsable : true
-- Group : 공통
-- Description:	자재수불확정처리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFixMaterialDoc]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pIsBackFlush BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @DocStatus VARCHAR(20)
	DECLARE @MaterialDocTypeCode VARCHAR(20)
	DECLARE @SourceCustomerCode VARCHAR(20)
	DECLARE @SourceCompanyCode VARCHAR(20)
	DECLARE @SourceWorkCenterCode VARCHAR(20)
	DECLARE @SourceRouteCode VARCHAR(20)
	DECLARE @SourceMaterialWarehouseCode VARCHAR(20)
	DECLARE @TargetCustomerCode VARCHAR(20)
	DECLARE @TargetCompanyCode VARCHAR(20)
	DECLARE @TargetWorkCenterCode VARCHAR(20)
	DECLARE @TargetRouteCode VARCHAR(20)
	DECLARE @TargetMaterialWarehouseCode VARCHAR(20)
	DECLARE @TargetMaterialLocationCode VARCHAR(20)

	DECLARE @DefaultMaterialLocationCode VARCHAR(20)
	
	DECLARE @MaterialLotNo VARCHAR(20)
	DECLARE @LotID VARCHAR(50)
	DECLARE @StockQty NUMERIC(20,5)
	DECLARE @MaterialLocationCode VARCHAR(20)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @LotNo VARCHAR(100)
	DECLARE @VendorLotNo VARCHAR(100)		-- 2018-08-28 JGH VendorLotNo 추가
	DECLARE @LotAttr01 NVARCHAR(100)
	DECLARE @LotAttr02 NVARCHAR(100)
	DECLARE @LotAttr03 NVARCHAR(100)
	DECLARE @LotAttr04 NVARCHAR(100)
	DECLARE @LotAttr05 NVARCHAR(100)
	DECLARE @LotAttr06 NVARCHAR(100)
	DECLARE @LotAttr07 NVARCHAR(100)
	DECLARE @LotAttr08 NVARCHAR(100)
	DECLARE @LotAttr09 NVARCHAR(100)
	DECLARE @LotAttr10 NVARCHAR(100)
	
	DECLARE @IsProcessOrderBom BIT
	DECLARE @IsProcessModelBom BIT
	DECLARE @IsAutoCreate BIT
	DECLARE @IsDecSource BIT
	DECLARE @IsIncTarget BIT
	DECLARE @IsChangeStockAttribute BIT
	DECLARE @IsRefDocAutoFix BIT
	DECLARE @AutoCreateMoveType VARCHAR(20)
	DECLARE @NewRefDocNo VARCHAR(20)
	DECLARE @IsBackFlush BIT = ISNULL(@pIsBackFlush, CONVERT(BIT,0))
	
	DECLARE @GRDate DATE
	DECLARE @IsCancel BIT
	
	DECLARE @DocDetailTable TABLE
		(
			IDX INT IDENTITY(1,1),
			MaterialDocDetailNo VARCHAR(20)
		)
	DECLARE @DocDetailIdx INT
	DECLARE @DocDetailCount INT
		
	DECLARE @DocLotInfo TABLE
		(
			IDX INT ,
			MaterialLotNo VARCHAR(20),
			LotID VARCHAR(50),
			StockQty NUMERIC(20,5),
			MaterialLocationCode VARCHAR(20),
			PackingID VARCHAR(50),
			LotNo VARCHAR(100),
			VendorLotNo VARCHAR(100),		-- 2018-08-28 JGH VendorLotNo 추가
			LotAttr01 NVARCHAR(100),
			LotAttr02 NVARCHAR(100),
			LotAttr03 NVARCHAR(100),
			LotAttr04 NVARCHAR(100),
			LotAttr05 NVARCHAR(100),
			LotAttr06 NVARCHAR(100),
			LotAttr07 NVARCHAR(100),
			LotAttr08 NVARCHAR(100),
			LotAttr09 NVARCHAR(100),
			LotAttr10 NVARCHAR(100)
		)
	DECLARE @DocLotInfoIdx INT
	DECLARE @DocLotInfoCount INT	
	
	IF @MaterialDocNo IS NULL BEGIN
		DECLARE @NoMaterialDocNumber NVARCHAR(500)	
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^문서번호가 입력되지 않았습니다.^',
										@pValue = @NoMaterialDocNumber OUTPUT	
		RAISERROR(@NoMaterialDocNumber, 16, 1)
		RETURN
	END
	
	SELECT
			@DocStatus = MDI.DocStatus,
			@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
			@SourceCustomerCode = MDI.SourceCustomerCode,
			@SourceCompanyCode = MDI.SourceCompanyCode,
			@SourceWorkCenterCode = MDI.SourceWorkCenterCode,
			@SourceRouteCode = MDI.SourceRouteCode,
			@SourceMaterialWarehouseCode = MDI.SourceMaterialWarehouseCode,
			@TargetCustomerCode = MDI.TargetCustomerCode,
			@TargetCompanyCode = MDI.TargetCompanyCode,
			@TargetWorkCenterCode = MDI.TargetWorkCenterCode,
			@TargetRouteCode = MDI.TargetRouteCode,
			@TargetMaterialWarehouseCode = MDI.TargetMaterialWarehouseCode,
			@GRDate = MDI.BasicDate,
			@IsCancel = MDI.IsCancel
	FROM
			STB_MaterialDocInfo MDI
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo
	

	
	IF @IsBackFlush = 1
	BEGIN
			SELECT
					TOP 1
					@DefaultMaterialLocationCode = LRM.GILocationCode
			FROM
					STB_LineRouteMapping LRM WITH (NOLOCK)
			WHERE
					LRM.MaterialWarehouseCode = @SourceMaterialWarehouseCode AND
					LRM.RouteCode = @SourceRouteCode AND
					LRM.GILocationCode IS NOT NULL OR LRM.GILocationCode <> ''
	END ELSE BEGIN
			SELECT
					@DefaultMaterialLocationCode = MW.DefaultLocationCode
			FROM
					STB_MaterialWarehouse MW
			WHERE
					MW.MaterialWarehouseCode = @SourceMaterialWarehouseCode
	END

	IF @DocStatus IS NULL BEGIN
		DECLARE @NotFoundDocError NVARCHAR(500)	
		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
										@pName = '^문서를 찾을 수 없습니다.^',
										@pValue = @NotFoundDocError OUTPUT	
		RAISERROR(@NotFoundDocError, 16, 1)
		RETURN
	END

	IF @IsCancel = 1 BEGIN
			DECLARE @AlreadyCancelError NVARCHAR(500)	
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^취소된 문서입니다.^',
											@pValue = @AlreadyCancelError OUTPUT	
			RAISERROR(@AlreadyCancelError, 16, 1)
			RETURN
	END

	IF @DocStatus IN ('FIX') BEGIN
			DECLARE @AlradyFixDocMsg NVARCHAR(500)	
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^이미 확정된 문서입니다.^',
											@pValue = @AlradyFixDocMsg OUTPUT	
			RAISERROR(@AlradyFixDocMsg, 16, 1)
			RETURN
	END

	IF @DocStatus NOT IN ('FINISH') BEGIN
			DECLARE @NotFinishedDocNumber NVARCHAR(500)	
			EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
											@pName = '^완료되지 않은 문서입니다.^',
											@pValue = @NotFinishedDocNumber OUTPUT	
			RAISERROR(@NotFinishedDocNumber, 16, 1)
			RETURN
	END
	
	DECLARE @MaterialDocType VARCHAR(20)
	SELECT
			@MaterialDocType = MDT.MaterialDocType,
			@IsProcessOrderBom = ISNULL(MDT.IsProcessBom,CONVERT(BIT, 0)),
			@IsProcessModelBom = ISNULL(MDT.IsProcessModelBom,CONVERT(BIT, 0)),
			@IsAutoCreate = ISNULL(MDT.IsAutoCreate,CONVERT(BIT, 0)),
			@IsDecSource = ISNULL(MDT.IsDecSource,CONVERT(BIT, 0)),
			@IsIncTarget = ISNULL(MDT.IsIncTarget,CONVERT(BIT, 0)),
			@IsChangeStockAttribute = ISNULL(MDT.IsChangeStockAttribute,CONVERT(BIT, 0)),
			@IsRefDocAutoFix = ISNULL(MDT.IsProcessRefDoc,CONVERT(BIT, 0)),
			@AutoCreateMoveType = MDT.AutoCreateMoveType
	FROM
			STB_MaterialDocType MDT
	WHERE
			MDT.MaterialDocTypeCode = @MaterialDocTypeCode


	INSERT INTO @DocDetailTable
			(MaterialDocDetailNo)
	SELECT
			MDD.MaterialDocDetailNo
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo

	
	SELECT
			@DocDetailCount = COUNT(*)
	FROM
			@DocDetailTable

	
	DECLARE @MaterialDocDetailNo VARCHAR(20),
			@OrderDetailNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialStockAttribute VARCHAR(20),
			@BefMaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@AllowQty NUMERIC(20,5),
			@ProcessFixQty NUMERIC(20,5),

			-- 원자재와 제품을 구분하기 위해 추가 2020.07.28 By Jackaroe
			@MaterialTypeCode VARCHAR(20)
			
	

	SET @DocDetailIdx = 1
	
	
	WHILE @DocDetailIdx <= @DocDetailCount
	BEGIN
			SELECT
					@MaterialDocDetailNo = DDT.MaterialDocDetailNo
			FROM
					@DocDetailTable DDT
			WHERE
					DDT.IDX = @DocDetailIdx
	
	
			SELECT
					@OrderDetailNo = MDD.OrderDetailNo,
					@MaterialCode = MDD.MaterialCode,
					@MaterialStockAttribute = MDD.MaterialStockAttribute,
					@StockAttrib1 = MDD.StockAttrib1,
					@StockAttrib2 = MDD.StockAttrib2,
					@StockAttrib3 = MDD.StockAttrib3,
					@AllowQty = CASE
									WHEN @MaterialDocType IN ('GI','MOVE') AND @IsBackFlush = 1 THEN MDD.AllowQty
									ELSE MDD.AllowQty
								END,
					--= MDD.PickingQty,
					--@ProcessFixQty = MDD.ProcessFixQty,
					-- GI BackFlush 일때는 PIckingQty에 데이터가 없으므로 이렇게 처리한다.
					@ProcessFixQty= CASE
										WHEN  @MaterialDocType IN ('GI','MOVE') AND @IsBackFlush = 1 THEN MDD.AllowQty
										ELSE MDD.PickingQty
									END,
					@BefMaterialStockAttribute = MDD.BefMaterialStockAttribute
			FROM
					STB_MaterialDocDetail MDD
			WHERE
					MDD.MaterialDocDetailNo = @MaterialDocDetailNo
			
			DELETE FROM @DocLotInfo
			

			IF @IsBackFlush = 0
			BEGIN
					INSERT INTO @DocLotInfo
						(
							IDX,
							MaterialLotNo,
							LotID,
							StockQty,
							MaterialLocationCode,
							PackingID,
							LotNo,
							VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
							LotAttr01,
							LotAttr02,
							LotAttr03,
							LotAttr04,
							LotAttr05,
							LotAttr06,
							LotAttr07,
							LotAttr08,
							LotAttr09,
							LotAttr10
						)
					SELECT
							ROW_NUMBER() OVER (ORDER BY MDLI.MDLISeqNo) ,
							MDLI.MaterialLotNo,
							MDLI.LotID,
							MDLI.StockQty,
							MDLI.MaterialLocationCode,
							MDLI.PackingID,
							ISNULL(MDLI.LotNo,''),
							MDLI.VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
							MDLI.LotAttr01,
							MDLI.LotAttr02,
							MDLI.LotAttr03,
							MDLI.LotAttr04,
							MDLI.LotAttr05,
							MDLI.LotAttr06,
							MDLI.LotAttr07,
							MDLI.LotAttr08,
							MDLI.LotAttr09,
							MDLI.LotAttr10
					FROM
							STB_MaterialDocLotInfo MDLI
					WHERE
							MDLI.MaterialDocDetailNo = @MaterialDocDetailNo AND
							MDLI.IsChecked = 1
			END ELSE BEGIN
					INSERT INTO @DocLotInfo
						(
							IDX,
							MaterialLotNo,
							LotID,
							StockQty,
							MaterialLocationCode,
							PackingID,
							LotNo
						)
					VALUES
						(
							1,
							'',
							'',
							@ProcessFixQty,
							@DefaultMaterialLocationCode,
							'',
							''
						)

			END
			
			SELECT
					@DocLotInfoCount = COUNT(*)
			FROM	
					@DocLotInfo DLI
					
			SET @DocLotInfoIdx = 1
			
			WHILE @DocLotInfoIdx <= @DocLotInfoCount
			BEGIN
					SELECT
							@MaterialLotNo = DLI.MaterialLotNo,
							@LotID = DLI.LotID,
							@StockQty = DLI.StockQty,
							@MaterialLocationCode = DLI.MaterialLocationCode,
							@PackingID = DLI.PackingID,
							@LotNo = DLI.LotNo,
							@VendorLotNo = DLI.VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
							@LotAttr01 = DLI.LotAttr01,
							@LotAttr02 = DLI.LotAttr02,
							@LotAttr03 = DLI.LotAttr03,
							@LotAttr04 = DLI.LotAttr04,
							@LotAttr05 = DLI.LotAttr05,
							@LotAttr06 = DLI.LotAttr06,
							@LotAttr07 = DLI.LotAttr07,
							@LotAttr08 = DLI.LotAttr08,
							@LotAttr09 = DLI.LotAttr09,
							@LotAttr10 = DLI.LotAttr10
					FROM
							@DocLotInfo DLI 
					WHERE
							DLI.IDX = @DocLotInfoIdx
							
					
					
					IF @IsAutoCreate = 1 -- 자동수불생성(선처리)
					BEGIN
							--임시코드
							SET @IsAutoCreate = 1
					
					END



					IF ((@IsDecSource = 1) AND (@IsIncTarget = 0)) OR ((@IsDecSource = 1) AND (ISNULL(@LotID,'') = '')) -- 원본 재고만 감소의 경우(GI)거나 바코드 미사용의 경우
					BEGIN
							--raiserror('check123',16,1)
							IF @IsChangeStockAttribute = 0
							BEGIN
									EXEC usp_DoProcessMaterialLotInfoOutput
											@pCompanyCode = @SourceCompanyCode,
											@pWorkCenterCode = @SourceWorkCenterCode,
											@pMaterialLotNo = @MaterialLotNo,
											@pLotID = @LotID,
											@pMaterialWarehouseCode = @SourceMaterialWarehouseCode,
											@pMaterialLocationCode = @MaterialLocationCode,
											@pMaterialStockAttribute = @MaterialStockAttribute,
											@pStockAttrib1 = @StockAttrib1,
											@pStockAttrib2 = @StockAttrib2,
											@pStockAttrib3 = @StockAttrib3,
											@pMaterialCode = @MaterialCode,
											@pUsedQty = @StockQty,
											@pProcessUserID = @pProcessUserID,
											@pMaterialDocNo = @MaterialDocNo,
											@pMaterialDocDetailNo = @MaterialDocDetailNo
							END ELSE BEGIN
									EXEC usp_DoProcessMaterialLotInfoOutput
											@pCompanyCode = @SourceCompanyCode,
											@pWorkCenterCode = @SourceWorkCenterCode,
											@pMaterialLotNo = @MaterialLotNo,
											@pLotID = @LotID,
											@pMaterialWarehouseCode = @SourceMaterialWarehouseCode,
											@pMaterialLocationCode = @MaterialLocationCode,
											@pMaterialStockAttribute = @BefMaterialStockAttribute,
											@pStockAttrib1 = @StockAttrib1,
											@pStockAttrib2 = @StockAttrib2,
											@pStockAttrib3 = @StockAttrib3,
											@pMaterialCode = @MaterialCode,
											@pUsedQty = @StockQty,
											@pProcessUserID = @pProcessUserID,
											@pMaterialDocNo = @MaterialDocNo,
											@pMaterialDocDetailNo = @MaterialDocDetailNo
							END
					END
					
					
					IF  ((@IsDecSource = 0) AND (@IsIncTarget = 1)) OR ((@IsIncTarget = 1) AND (ISNULL(@LotID,'') = '')) -- 대상 재고만 증가거나 바코드 미사용의 경우
					BEGIN
							
							-- 입고 시 Location 이 지정되어 MaterialDocLotInfo 에 Location 이 지정된 경우
							IF ISNULL(@MaterialLocationCode, '') <> ''
							BEGIN 
									SET @TargetMaterialLocationCode = @MaterialLocationCode
							END ELSE BEGIN
									SELECT
											@TargetMaterialLocationCode = MW.DefaultLocationCode
									FROM	
											STB_MaterialWarehouse MW WITH (NOLOCK)
									WHERE
											MW.MaterialWarehouseCode = @TargetMaterialWarehouseCode
							END


							EXEC usp_DoProcessMaterialLotInfoInput
									@pCompanyCode = @TargetCompanyCode,
									@pWorkCenterCode = @TargetWorkCenterCode,
									@pLotID = @LotID,
									@pMaterialWarehouseCode = @TargetMaterialWarehouseCode,
									@pMaterialLocationCode = @TargetMaterialLocationCode,
									@pMaterialStockAttribute = @MaterialStockAttribute,
									@pStockAttrib1 = @StockAttrib1,
									@pStockAttrib2 = @StockAttrib2,
									@pStockAttrib3 = @StockAttrib3,
									@pMaterialCode = @MaterialCode,
									@pLotNo = @LotNo,
									@pVendorLotNo = @VendorLotNo,		-- 2018-08-28 JGH VendorLotNo 추가
									@pUsedQty = @StockQty,
									@pPackingID = @PackingID,
									@pGRDate = @GRDate,
									@pProcessUserID = @pProcessUserID,
									@pLotAttr01 = @LotAttr01,
									@pLotAttr02 = @LotAttr02,
									@pLotAttr03 = @LotAttr03,
									@pLotAttr04 = @LotAttr04,
									@pLotAttr05 = @LotAttr05,
									@pLotAttr06 = @LotAttr06,
									@pLotAttr07 = @LotAttr07,
									@pLotAttr08 = @LotAttr08,
									@pLotAttr09 = @LotAttr09,
									@pLotAttr10 = @LotAttr10
					END
					
					IF  ((@IsDecSource = 1) AND (@IsIncTarget = 1)) AND (ISNULL(@LotID,'') <> '' ) -- 바코드 사용자재의 이동처리의 경우
					BEGIN
							EXEC usp_DoProcessMaterialLotInfoMove
									/*
									@pSourceCompanyCode = @SourceCompanyCode,
									@pSourceWorkCenterCode = @SourceWorkCenterCode,
									@pSourceRouteCode = @SourceRouteCode,
									@pSourceMaterialWarehouseCode = @SourceMaterialWarehouseCode,
									@pSourceMaterialLocationCode = @MaterialLocationCode,
									@pSourceMaterialStockAttribute = @BefMaterialStockAttribute,
									*/
									@pTargetCompanyCode = @TargetCompanyCode,
									@pTargetWorkCenterCode = @TargetWorkCenterCode,
									@pTargetRouteCode = @TargetRouteCode,
									@pTargetMaterialWarehouseCode = @TargetMaterialWarehouseCode,
									--@pTargetMaterialLocationCode = @TargetLocationCode,
									@pTargetMaterialStockAttribute = @MaterialStockAttribute,
									
									@pMaterialLotNo = @MaterialLotNo,
									@pPackingID = @PackingID,
									/*
									@pLotID = @LotID,
									@pStockAttrib1 = @StockAttrib1,
									@pStockAttrib2 = @StockAttrib2,
									@pStockAttrib3 = @StockAttrib3,
									@pMaterialCode = @MaterialCode,
									*/
									@pUsedQty = @StockQty,
									@pProcessUserID = @pProcessUserID
					END
					
					SET @DocLotInfoIdx = @DocLotInfoIdx + 1
			END -- WHILE @DocLotInfoIdx <= @DocLotInfoCount


			/***************************************************************/
			-- Modify : 2016-08-20  Park Jong Seob(jspark@awoo.co.kr)
			-- MaterialDocDetail 의 ProcessFixQty 처리한다.
			/***************************************************************/

			UPDATE STB_MaterialDocDetail
			SET 
					ProcessFixQty = @ProcessFixQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo


			/***************************************************************/
			-- Modified : 2016-06-21 Kim Han Young(hykim@awoo.co.kr)
			-- 입고의 경우 확정 시 발주잔량 재계산 및 업데이트
			/***************************************************************/
			-- 발주문서 항번이 있을 경우 발주정보 업데이트
			IF @MaterialDocType = 'GR' BEGIN
				
				IF @OrderDetailNo IS NOT NULL BEGIN
					DECLARE @A VARCHAR(20) = @AllowQty,
							@B VARCHAR(20) = @ProcessFixQty

					UPDATE
							STB_MaterialOrderItem
					SET
							-- 입하 시 @AllowQty 만큼 발주잔량을 차감했기 때문에
							-- 발주잔량을 실제확정수량으로 재계산
							MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) + @AllowQty - @ProcessFixQty
					WHERE
							MaterialOrderItemNo = @OrderDetailNo
				END
			-- 출고의 경우 발주문서 항번이 있으면 
			-- 영업오더상세에 출고계획수량 업데이트
			END ELSE IF @MaterialDocType = 'GI' BEGIN
				IF ISNULL(@OrderDetailNo, '') <> ''
				BEGIN
						UPDATE
								STB_SalesOrderItem
						SET
								--GIPlanQty = GIPlanQty + @AllowQty - @ProcessFixQty,
								GIPlanQty = GIPlanQty - @AllowQty,
								GIFixQty = GIFixQty + @ProcessFixQty -- @AllowQty--@ProcessFixQty , 출고시에는 AllowQty와 PickingQty가 같지 않으면 처리되지 않기 때문에 AllowQty로 처리한다.
						WHERE
								SOISequence = @OrderDetailNo
				END

				UPDATE STB_MaterialStock
				SET 
						PickingAssignQty = PickingAssignQty - MDPP.PickingAssingQty
				FROM
						(
								SELECT
										MaterialStockNo,
										PickingAssingQty
								FROM
										STB_MaterialDocPickingPlan
								WHERE
										MaterialDocDetailNo = @MaterialDocDetailNo 
						) MDPP
				WHERE
						MDPP.MaterialStockNo = STB_MaterialStock.MaterialStockNo
			END
			/***************************************************************/
			
			SET @DocDetailIdx = @DocDetailIdx + 1
	END -- WHILE @DocDetailIdx <= @DocDetailCount
	

	IF @IsAutoCreate = 1 -- 자동수불생성(선처리)
	BEGIN
			--임시코드
			--SET @IsAutoCreate = 1
			IF @IsProcessModelBom = 1
			BEGIN
					EXEC usp_DoCreateMaterialDocByModelBOM 
							@pProcessLanguage = @pProcessLanguage,
							@pProcessUserID = @pProcessUserID,
							@pMaterialDocNo = @MaterialDocNo,
							@pMaterialDocTypeCode = @AutoCreateMoveType,
							@pNewMaterialDocNo = @NewRefDocNo OUTPUT
			END
			IF @IsProcessOrderBom = 1 BEGIN
					EXEC usp_DoCreateMaterialDocByDoc 
							@pProcessLanguage = @pProcessLanguage,
							@pProcessUserID = @pProcessUserID,
							@pMaterialDocNo = @MaterialDocNo,
							@pMaterialDocTypeCode = @AutoCreateMoveType,
							@pNewMaterialDocNo = @NewRefDocNo OUTPUT
			END

			IF (@IsRefDocAutoFix = 1) AND (ISNULL(@NewRefDocNo,'') <> '')
			BEGIN
					EXEC usp_DoFixMaterialDoc
							@pProcessUserID = @pProcessUserID,
							@pProcessLanguage = @pProcessLanguage,
							@pIsBackFlush = 1,
							@pMaterialDocNo = @NewRefDocNo
			END
	END

	-- ERP 인터페이스 처리
	--IF @MaterialDocType = 'GI' BEGIN
		--exec usp_DoProcessSalesInOut_itf @pProcessUserID, @pProcessLanguage, 'TEST', @MaterialDocNo
	--END

	--안전재고 체크 TEST
	exec usp_DoCheckSafeStockQty @pProcessUserID
	                            ,@pProcessLanguage
								,@SourceCompanyCode
								,@SourceWorkCenterCode
								,@SourceMaterialWarehouseCode
								,@MaterialCode

	-- 2016-07-02 JGH 문서 진행상태 FIX 로 변경

	IF @IsAutoCreate = 1
	BEGIN
			IF @MaterialDocType = 'GR' BEGIN -- GR 인경우 Taret 처리
					UPDATE STB_MaterialDocInfo
					SET
							DocStatus = 'FIX',
							RefMaterialDocNo = @NewRefDocNo,
							TargetProcessDateTime = GETDATE(),
							TargetProcessUserID = @pProcessUserID
					WHERE
							MaterialDocNo = @MaterialDocNo
			END ELSE BEGIN -- GI, MOVE 인경우 Source 처리
					UPDATE STB_MaterialDocInfo
					SET
							DocStatus = 'FIX',
							RefMaterialDocNo = @NewRefDocNo,
							SourceProcessDateTime = GETDATE(),
							SourceProcessUserID = @pProcessUserID
					WHERE
							MaterialDocNo = @MaterialDocNo
			END 
	END ELSE BEGIN
			IF @MaterialDocType = 'GR' BEGIN -- GR 인경우 Taret 처리
					UPDATE STB_MaterialDocInfo
					SET
							DocStatus = 'FIX',
							TargetProcessDateTime = GETDATE(),
							TargetProcessUserID = @pProcessUserID
					WHERE
							MaterialDocNo = @MaterialDocNo
			END ELSE BEGIN
					UPDATE STB_MaterialDocInfo
					SET
							DocStatus = 'FIX',
							SourceProcessDateTime = GETDATE(),
							SourceProcessUserID = @pProcessUserID
					WHERE
							MaterialDocNo = @MaterialDocNo
			END
	END

	-- WareNavi 인터페이스 테이블 Insert (GR/GI를 구분하여 패킹ID별로 커서로 처리함.)
	-- 입고의 경우는 단건 처리지만, 출고의 경우 다건의 패킹ID가 넘어올 수 있음.
	-- 2020.07.28 By Jackaroe
	SELECT @MaterialTypeCode = MaterialTypeCode 
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = @MaterialCode

	DECLARE WareNaviCur CURSOR FOR

		SELECT PackingID
		  FROM @DocLotInfo
		 GROUP BY PackingID

		OPEN WareNaviCur

		FETCH NEXT FROM WareNaviCur INTO @PackingID

		INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoFixMaterialDoc', '@MaterialTypeCode', @MaterialTypeCode)
		INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoFixMaterialDoc', '@MaterialDocType', @MaterialDocType)

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @MaterialTypeCode IN ('FERT', 'MDL') AND @MaterialDocType = 'GR' BEGIN
				exec usp_RCV_ASN_iud @pProcessUserID, @pProcessLanguage, @PackingID
			END

			IF @MaterialTypeCode IN ('FERT', 'MDL') AND @MaterialDocType = 'GI' BEGIN
				exec usp_OUT_ASN_iud @pProcessUserID, @pProcessLanguage, @PackingID
			END
	
			FETCH NEXT FROM WareNaviCur INTO @PackingID
		END

	CLOSE WareNaviCur
	DEALLOCATE WareNaviCur

END

