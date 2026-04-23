-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-09-05
-- Description : 생산출고요청 생성
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateProductionGIRequest]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50) = 'MaterialList',
	@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@iDoc INT,
			@TableName VARCHAR(100) = '/DataSet/' + @pProcessViewName,
			@PONo VARCHAR(20),
			@SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),
			@TargetCompanyCode VARCHAR(20),
			@TargetWorkCenterCode VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@TargetMaterialWarehouseCode VARCHAR(20),
			@DetailLotNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialDocType VARCHAR(20),
			@MaterialDocTypeCode VARCHAR(20),
			@MaterialDocNo VARCHAR(20),
			@MaterialDocDetailNo VARCHAR(20),
			@IsUseFlush BIT,
			@ErrorMessage NVARCHAR(MAX),
			@RequestQty NUMERIC(20,5)

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
		RequestQty NUMERIC(20,5)
	)
	DECLARE @RawData TABLE
	(
		PONo VARCHAR(20),
		SourceMaterialWarehouseCode VARCHAR(20),
		TargetMaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),
		RequestQty NUMERIC(20,5),
		IsUseFlush BIT
	)
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	INSERT INTO @RawData
	SELECT
			PONo,
			SourceMaterialWarehouseCode,
			TargetMaterialWarehouseCode,
			MaterialCode,
			RequestQty,
			IsUseFlush
	FROM
			OPENXML(@idoc , @TableName , 2)
			WITH  (
					PONo VARCHAR(20),
					SourceMaterialWarehouseCode VARCHAR(20),
					TargetMaterialWarehouseCode VARCHAR(20),
					MaterialCode VARCHAR(50),
					RequestQty NUMERIC(20,5),
					IsUseFlush BIT
					)
	-- 2018-09-10 JGH 수정
	WHERE
			RequestQty > 0

	IF (
			SELECT COUNT(*)
			FROM
					@RawData
		) <= 0 BEGIN
			EXEC usp_RaiseLocalizedError	@ProcessLanguage, '요청할 자재가 없습니다'
			RETURN
	END
	-- 2018-09-10 JGH 수정

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

		-- 2018-09-10 JGH 수정
		--EXEC usp_DoMakeMaterialDocNo	@ProcessLanguage,
		--								@ProcessUserID,
		--								@MaterialDocNo OUTPUT
		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocInfo', @MaterialDocNo OUTPUT

		INSERT INTO STB_MaterialDocInfo
		(
			MaterialDocNo,
			MaterialDocType,
			MaterialDocTypeCode,
			DocStatus,						-- 2018-09-10 JGH 수정
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
			'CREATE',						-- 2018-09-10 JGH 수정
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
				SUM(R.RequestQty)
		FROM
				@RawData R
		WHERE
				R.PONo = @PONo AND
				R.SourceMaterialWarehouseCode = @SourceMaterialWarehouseCode AND
				((@TargetMaterialWarehouseCode IS NULL) OR (R.TargetMaterialWarehouseCode = @TargetMaterialWarehouseCode)) AND
				R.IsUseFlush = @IsUseFlush
		GROUP BY
				R.MaterialCode
		ORDER BY
				R.MaterialCode

		SET @DROW = 1
		SET @DCOUNT = (SELECT COUNT(1) FROM @Detail)

		WHILE @DROW <= @DCOUNT BEGIN
			SELECT
					@MaterialCode = M.MaterialCode,
					@RequestQty = M.RequestQty
			FROM
					@Detail M
			WHERE
					M.ROW = @DROW

			-- 2018-09-10 JGH 수정
			--EXEC usp_DoMakeMaterialDocDetailNo	@ProcessLanguage,
			--									@ProcessUserID,
			--									@MaterialDocDetailNo OUTPUT

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT

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
				'NORMAL',
				'',
				'',
				'',
				@RequestQty,	-- RequestQty		
				@RequestQty,	-- AllowQty
				@RequestQty,	-- PickingAssignQty
				-- 2018-09-11 JGH 수정
				--@RequestQty,	-- PickingQty
				0,				-- PickingQty
				0,				-- ProcessFixQty
				0,				-- UnitPriceQty
				0,				-- UnitPrice
				GETDATE(),
				@ProcessUserID
			)

			SET @DROW = @DROW + 1
		END

		SET @HROW = @HROW + 1
	END

	EXEC sp_xml_removedocument @iDoc


END
