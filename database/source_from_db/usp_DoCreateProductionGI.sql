-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 자재 생산출고 생성
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateProductionGI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE',
			@iDoc INT,
			@SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),
			@TargetCompanyCode VARCHAR(20),
			@TargetWorkCenterCode VARCHAR(20),
			@PONo VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@TargetMaterialWarehouseCode VARCHAR(20),
			@DetailLotNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialLotNo VARCHAR(20),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@RequestQty NUMERIC(20,5),
			@LotQty NUMERIC(20,5),
			@CurrentQty NUMERIC(20,5),
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@MaterialDocNo VARCHAR(20),
			@MaterialDocDetailNo VARCHAR(20),
			@IsUseFlush BIT,
			@ErrorMessage NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	DECLARE @RawData TABLE
	(
		PONo VARCHAR(20),
		SourceMaterialWarehouseCode VARCHAR(20),
		TargetMaterialWarehouseCode VARCHAR(20),
		MaterialLotNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		Lotid VARCHAR(50),
		LotNo VARCHAR(100),
		MaterialLocationCode VARCHAR(20),
		PackingID VARCHAR(50),
		LotAttr01 NVARCHAR(100),
		LotAttr02 NVARCHAR(100),
		LotAttr03 NVARCHAR(100),
		LotAttr04 NVARCHAR(100),
		LotAttr05 NVARCHAR(100),
		LotAttr06 NVARCHAR(100),
		LotAttr07 NVARCHAR(100),
		LotAttr08 NVARCHAR(100),
		LotAttr09 NVARCHAR(100),
		LotAttr10 NVARCHAR(100),
		CurrentQty NUMERIC(20,5),
		RequestQty NUMERIC(20,5),
		IsUseFlush BIT
	)
	INSERT INTO @RawData
	SELECT
			X.PONo,
			X.SourceMaterialWarehouseCode,
			X.TargetMaterialWarehouseCode,
			X.MaterialLotNo,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.LotID,
			MLI.LotNo,
			MLI.MaterialLocationCode,
			MLI.PackingID,
			MLI.LotAttr01,
			MLI.LotAttr02,
			MLI.LotAttr03,
			MLI.LotAttr04,
			MLI.LotAttr05,
			MLI.LotAttr06,
			MLI.LotAttr07,
			MLI.LotAttr08,
			MLI.LotAttr09,
			MLI.LotAttr10,
			MLI.CurrentQty,
			X.RequestQty,
			ISNULL(MM.IsUseFlush,0)
	FROM
			OPENXML(@iDoc , @UpdateTableName , 2)
			WITH  (
						PONo VARCHAR(20),
						SourceMaterialWarehouseCode VARCHAR(20),
						TargetMaterialWarehouseCode VARCHAR(20),
						MaterialLotNo VARCHAR(20),
						MaterialCode VARCHAR(50),
						RequestQty NUMERIC(20,5)
					) X
			INNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.MaterialLotNo = X.MaterialLotNo
			INNER JOIN STB_MaterialMaster MM
				ON	MM.MaterialCode = MLI.MaterialCode
	EXEC sp_xml_removedocument @iDoc

	DECLARE @Header TABLE
	(
		ROW INT IDENTITY(1,1),
		PONo VARCHAR(20),
		MaterialDocType VARCHAR(20),
		MaterialDocTypeCode VARCHAR(20),
		SourceMaterialWarehouseCode VARCHAR(20),
		TargetMaterialWarehouseCode VARCHAR(20),
		IsUseFlush BIT
	)

	DECLARE @Detail TABLE
	(
		ROW INT,
		MaterialCode VARCHAR(50),
		MaterialStockAttribute VARCHAR(20),
		StockAttrib1 VARCHAR(20),
		StockAttrib2 VARCHAR(20),
		StockAttrib3 VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)

	DECLARE @LOT TABLE
	(
		ROW INT,
		MaterialLotNo VARCHAR(20),
		RequestQty NUMERIC(20,5)
	)
	
	INSERT INTO @Header
	SELECT
			DISTINCT
			R.PONo,
			'GI',
			'GI_WH_ROUTE',
			R.SourceMaterialWarehouseCode,
			R.TargetMaterialWarehouseCode,
			R.IsUseFlush
	FROM
			@RawData R
	WHERE
			R.IsUseFlush = 0

	INSERT INTO @Header
	SELECT
			DISTINCT
			R.PONo,
			'MOVE',
			'MV_WH_ROUTE',
			R.SourceMaterialWarehouseCode,
			R.TargetMaterialWarehouseCode,
			R.IsUseFlush
	FROM
			@RawData R
	WHERE
			R.IsUseFlush = 1

	DECLARE @HROW INT = 1,
			@HCOUNT INT = (SELECT COUNT(1) FROM @Header),
			@DROW INT,
			@DCOUNT INT,
			@LROW INT,
			@LCOUNT INT

	WHILE @HROW <= @HCOUNT BEGIN
		SELECT
				@PONo = H.PONo,
				@SourceCompanyCode = POI.CompanyCode,
				@SourceWorkCenterCode = POI.WorkCenterCode,
				@MaterialDocType = H.MaterialDocType,
				@MaterialDocTypeCode = H.MaterialDocTypeCode,
				@TargetCompanyCode = CASE WHEN ISNULL(H.TargetMaterialWarehouseCode,'') = '' THEN NULL ELSE POI.CompanyCode END,
				@TargetWorkCenterCode = CASE WHEN ISNULL(H.TargetMaterialWarehouseCode,'') = '' THEN NULL ELSE POI.WorkCenterCode END,
				@SourceMaterialWarehouseCode = H.SourceMaterialWarehouseCode,
				@TargetMaterialWarehouseCode = H.TargetMaterialWarehouseCode,
				@IsUseFlush = H.IsUseFlush
		FROM
				@Header H
				INNER JOIN STB_ProductionOrderInfo POI
					ON	POI.PONo = H.PONo
		WHERE
				H.ROW = @HROW

		EXEC usp_DoMakeMaterialDocNo	@ProcessLanguage,
										@ProcessUserID,
										@MaterialDocNo OUTPUT
		INSERT INTO STB_MaterialDocInfo
		(
			MaterialDocNo,
			MaterialDocType,
			MaterialDocTypeCode,
			SourceCompanyCode,
			SourceWorkCenterCode,
			SourceMaterialWarehouseCode,
			TargetCompanyCode,
			TargetWorkCenterCode,
			TargetMaterialWarehouseCode,
			BasicDate,
			PONo,
			IsCancel,
			IsRequestApproval,
			IsRequestFix,
			IsAssignPicking,
			IsPickingFix,			
			IsSourceFinish,
			IsTargetFinish,
			IsUploadERP,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@MaterialDocNo,
			@MaterialDocType,
			@MaterialDocTypeCode,
			@SourceCompanyCode,
			@SourceWorkCenterCode,
			@SourceMaterialWarehouseCode,
			@TargetCompanyCode,
			@TargetWorkCenterCode,
			@TargetMaterialWarehouseCode,
			GETDATE(),		--BasicDate,
			@PONo,			--PONo
			0,				--IsCancel,
			0,				--IsRequestApproval,
			1,				--IsRequestFix,
			0,				--IsAssignPicking,
			0,				--IsPickingFix,			
			0,				--IsSourceFinish,
			0,				--IsTargetFinish,
			0,				--IsUploadERP,
			GETDATE(),		--CreateDateTime,
			@ProcessUserID	--CreateUserID
		)
		
		DELETE FROM @Detail
		INSERT INTO @Detail
		SELECT
				ROW_NUMBER() OVER(ORDER BY R.MaterialCode),
				R.MaterialCode,
				R.MaterialStockAttribute,
				R.StockAttrib1,
				R.StockAttrib2,
				R.StockAttrib3,
				SUM(R.RequestQty)
		FROM
				@RawData R
		WHERE
				R.PONo = @PONo AND
				R.SourceMaterialWarehouseCode = @SourceMaterialWarehouseCode AND
				((@TargetMaterialWarehouseCode IS NULL) OR (R.TargetMaterialWarehouseCode = @TargetMaterialWarehouseCode)) AND
				R.IsUseFlush = @IsUseFlush
		GROUP BY
				R.MaterialCode,
				R.MaterialStockAttribute,
				R.StockAttrib1,
				R.StockAttrib2,
				R.StockAttrib3
		ORDER BY
				R.MaterialCode

		SET @DROW = 1
		SET @DCOUNT = (SELECT COUNT(1) FROM @Detail)

		WHILE @DROW <= @DCOUNT BEGIN
			SELECT
					@MaterialCode = M.MaterialCode,
					@MaterialStockAttribute = M.MaterialStockAttribute,
					@StockAttrib1 = M.StockAttrib1,
					@StockAttrib2 = M.StockAttrib2,
					@StockAttrib3 = M.StockAttrib3,
					@RequestQty = M.RequestQty
			FROM
					@Detail M
			WHERE
					M.ROW = @DROW

			EXEC usp_DoMakeMaterialDocDetailNo	@ProcessLanguage,
												@ProcessUserID,
												@MaterialDocDetailNo OUTPUT

			INSERT INTO STB_MaterialDocDetail
			(
				MaterialDocDetailNo,
				MaterialDocNo,
				MaterialCode,
				MaterialStockAttribute,
				StockAttrib1,
				StockAttrib2,
				StockAttrib3,
				RequestQty,
				AllowQty,
				PickingAssignQty,
				PickingQty,
				ProcessFixQty,
				UnitPriceQty,
				UnitPrice,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				@MaterialDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@RequestQty,	-- RequestQty		
				@RequestQty,	-- AllowQty
				@RequestQty,	-- PickingAssignQty
				@RequestQty,	-- PickingQty
				0,				-- ProcessFixQty
				0,				-- UnitPriceQty
				0,				-- UnitPrice
				GETDATE(),
				@ProcessUserID
			)

			DELETE @LOT
			INSERT INTO @LOT
			SELECT
					ROW_NUMBER() OVER(ORDER BY R.MaterialLotNo),
					R.MaterialLotNo,
					R.RequestQty
			FROM
					@RawData R
			WHERE
					R.PONo = @PONo AND
					R.SourceMaterialWarehouseCode = @SourceMaterialWarehouseCode AND
					((@TargetMaterialWarehouseCode IS NULL) OR (R.TargetMaterialWarehouseCode = @TargetMaterialWarehouseCode)) AND
					R.MaterialCode = @MaterialCode AND
					R.MaterialStockAttribute = @MaterialStockAttribute AND
					R.StockAttrib1 = @StockAttrib1 AND
					R.StockAttrib2 = @StockAttrib2 AND
					R.StockAttrib3 = @StockAttrib3 AND
					R.IsUseFlush = @IsUseFlush
			ORDER BY
					R.MaterialLotNo

			SET @LROW = 1
			SET @LCOUNT = (SELECT COUNT(1) FROM @LOT)

			WHILE @LROW <= @LCOUNT BEGIN
				SELECT
						@MaterialLotNo = L.MaterialLotNo,
						@CurrentQty = R.CurrentQty,
						@LotQty = L.RequestQty
				FROM
						@LOT L
						INNER JOIN @RawData R
							ON	R.MaterialLotNo = L.MaterialLotNo
				WHERE
						L.ROW = @LROW

				IF @CurrentQty IS NULL OR @CurrentQty < @LotQty BEGIN
					EXEC usp_GetAddonStringResource	@ProcessLanguage,
													'^재고가 부족합니다 : %s of %s^',
													@ErrorMessage OUTPUT
					RAISERROR(@ErrorMessage,16,1, @MaterialLotNo,@MaterialCode)
					RETURN
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
					LotNo,
					LotAttr01,
					LotAttr02,
					LotAttr03,
					LotAttr04,
					LotAttr05,
					LotAttr06,
					LotAttr07,
					LotAttr08,
					LotAttr09,
					LotAttr10,
					CreateDateTime,
					CreateUserID
				)
				SELECT
						@MaterialDocDetailNo,
						(
							SELECT 
									ISNULL(COUNT(1),1)
							FROM
									STB_MaterialDocDetail MDD
							WHERE
									MDD.MaterialDocDetailNo = @MaterialDocDetailNo
						),
						MLI.MaterialLotNo,
						MLI.LotID,
						MLI.MaterialCode,
						MLI.MaterialStockAttribute,
						MLI.StockAttrib1,
						MLI.StockAttrib2,
						MLI.StockAttrib3,
						@LotQty,
						1,	-- IsChecked,
						MLI.MaterialLocationCode,
						@MaterialDocNo,
						NULL,	-- PackingID
						MLI.LotNo,
						MLI.LotAttr01,
						MLI.LotAttr02,
						MLI.LotAttr03,
						MLI.LotAttr04,
						MLI.LotAttr05,
						MLI.LotAttr06,
						MLI.LotAttr07,
						MLI.LotAttr08,
						MLI.LotAttr09,
						MLI.LotAttr10,
						GETDATE(),
						@ProcessUserID
				FROM
						@RawData MLI
				WHERE
						MLI.MaterialLotNo = @MaterialLotNo

				SET @LROW = @LROW + 1
			END

			SET @DROW = @DROW + 1
		END

		SET @HROW = @HROW + 1
	END

	EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @MaterialDocNo

	EXEC usp_DoFixMaterialDoc	@pProcessLanguage = @ProcessLanguage,
								@pProcessUserID = @ProcessUserID,
								@pMaterialDocNo = @MaterialDocNo
									
END
