-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-28
-- Description:	기종변경을 처리합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoTransformMaterialCode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialLotNo VARCHAR(20),
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MaterialCode VARCHAR(50),			
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@CurrentQty INT,
			@TargetMaterialCode VARCHAR(50),
			@iDoc INT

	DECLARE @GIMaterial TABLE
	(
		Row INT IDENTITY(1,1),
		MaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),
		PickingQty NUMERIC(20,5)
	)

	DECLARE @GRMaterial TABLE
	(
		Row INT IDENTITY(1,1),
		MaterialWarehouseCode VARCHAR(20),
		MaterialCode VARCHAR(50),
		PickingQty NUMERIC(20,5)
	)

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	SELECT
			@MaterialLotNo = XMLData.MaterialLotNo,
			@CompanyCode = MLI.CompanyCode,
			@WorkCenterCode = MLI.WorkCenterCode,
			@MaterialWarehouseCode = MLI.MaterialWarehouseCode,			
			@MaterialCode = MLI.MaterialCode,
			@MaterialStockAttribute = MLI.MaterialStockAttribute,
			@StockAttrib1 = MLI.StockAttrib1,
			@StockAttrib2 = MLI.StockAttrib2,
			@StockAttrib3 = MLI.StockAttrib3,
			@CurrentQty = MLI.CurrentQty,
			@TargetMaterialCode = XMLData.TargetMaterialCode
	FROM
			OPENXML(@idoc , '/DataSet/MaterialLotInfo' , 2)
			WITH	(
						MaterialLotNo VARCHAR(20),
						TargetMaterialCode VARCHAR(20)
					) XMLData
			INNER JOIN STB_MaterialLotInfo MLI
				ON	MLI.MaterialLotNo = XMLData.MaterialLotNo

	INSERT INTO @GIMaterial
	(
		MaterialWarehouseCode,
		MaterialCode,
		PickingQty
	)
	SELECT
			XMLData.MaterialWarehouseCode,
			XMLData.MaterialCode,
			SUM(XMLData.PickingQty)
	FROM
			OPENXML(@idoc , '/DataSet/GIMaterial' , 2)
			WITH	(
						MaterialWarehouseCode VARCHAR(20),
						MaterialCode VARCHAR(50),
						PickingQty NUMERIC(20,5)
					) XMLData
	GROUP BY
			XMLData.MaterialWarehouseCode,
			XMLData.MaterialCode

	INSERT INTO @GRMaterial
	(
		MaterialWarehouseCode,
		MaterialCode,
		PickingQty
	)
	SELECT
			XMLData.MaterialWarehouseCode,
			XMLData.MaterialCode,
			SUM(XMLData.PickingQty)
	FROM
			OPENXML(@idoc , '/DataSet/GRMaterial' , 2)
			WITH	(
						MaterialWarehouseCode VARCHAR(20),
						MaterialCode VARCHAR(50),
						PickingQty NUMERIC(20,5)
					) XMLData
	GROUP BY
			XMLData.MaterialWarehouseCode,
			XMLData.MaterialCode

	EXEC sp_xml_removedocument @iDoc

	-- 기종변경 문서(MV_TRANSFORM) 생성
	DECLARE @MoveDocNo VARCHAR(20),
			@MoveDocDetailNo VARCHAR(20)

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo',@MoveDocNo OUTPUT
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MoveDocDetailNo OUTPUT

	EXEC usp_DoMakeMaterialDocDetailNo	@ProcessLanguage,
										@ProcessUserID,
										@MoveDocDetailNo OUTPUT

	INSERT INTO STB_MaterialDocInfo
	(
		MaterialDocNo,
		MaterialDocType,
		MaterialDocTypeCode,
		DocStatus,
		SourceCompanyCode,
		SourceWorkCenterCode,
		SourceMaterialWarehouseCode,
		TargetCompanyCode,
		TargetWorkCenterCode,
		TargetMaterialWarehouseCode,
		IsCancel,
		BasicDate,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@MoveDocNo,
		'MOVE',
		'MV_TRANSFORM',
		'CREATE',
		@CompanyCode,
		@WorkCenterCode,
		@MaterialWarehouseCode,
		@CompanyCode,
		@WorkCenterCode,
		@MaterialWarehouseCode,
		0,	-- IsCancel
		GETDATE(),
		GETDATE(),
		@ProcessUserID
	)

	-- 기종변경 디테일 생성
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
		MRMDExtText01,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@MoveDocDetailNo,
		@MoveDocNo,
		@MaterialCode,
		@MaterialStockAttribute,
		@StockAttrib1,
		@StockAttrib2,
		@StockAttrib3,
		@CurrentQty,		-- RequestQty
		@CurrentQty,		-- AllowQty
		@CurrentQty,		-- PickingAssignQty
		0,		-- PickingQty
		0,		-- ProcessFixQty
		@TargetMaterialCode,	-- MRMDExtText01
		GETDATE(),
		@ProcessUserID
	)

	-- 기종변경 LOT 입력
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
		CreateDateTime,
		CreateUserID
	)
	SELECT
			@MoveDocDetailNo,
			1,	-- MDLISeqNo
			MLI.MaterialLotNo,
			MLI.LotID,
			MLI.MaterialCode,
			MLI.MaterialStockAttribute,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.CurrentQty,
			1,		-- IsChecked
			MLI.MaterialLocationCode,
			@MoveDocNo,
			MLI.PackingID,
			MLI.LotNo,
			MLI.CreateDateTime,
			MLI.CreateUserID
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo
			
	-- 기종변경 완료
	EXEC usp_DoFinishMaterialDoc	@ProcessLanguage,
									@ProcessUserID,
									@MoveDocNo

	-- 기종변경 확정
	EXEC usp_DoFixMaterialDoc	@ProcessLanguage,
								@ProcessUserID,
								@MoveDocNo

	-- 자재입고 문서(GR_ETC) 생성
	DECLARE @GRDocNo VARCHAR(20),
			@GRDocDetailNo VARCHAR(20)

	DECLARE @GRRow INT,
			@GRCount INT

	SELECT
			@GRRow = 1,
			@GRCount = COUNT(*)
	FROM
			@GRMaterial

	IF @GRCount > 0 BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo', @GRDocNo OUTPUT
	
		-- 2016-09-27 JGH 수정 창고지정추가
		SELECT @MaterialWarehouseCode = MaterialWarehouseCode FROM @GRMaterial

		INSERT INTO STB_MaterialDocInfo
		(
			MaterialDocNo,
			MaterialDocType,
			MaterialDocTypeCode,
			DocStatus,
			BasicDate,
			TargetCompanyCode,
			TargetWorkCenterCode,
			TargetMaterialWarehouseCode,
			RefMaterialDocNo,
			MRMIExtText01,	-- 비고
			MRMIExtText02,	-- 변경 MaterialLotNo
			MRMIExtText03,	-- 변경전 MaterialCode
			MRMIExtText04,	-- 변경후 MaterialCode
			IsCancel,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@GRDocNo,
			'GR',
			'GR_ETC',
			'CREATE',
			GETDATE(),
			@CompanyCode,
			@WorkCenterCode,
			@MaterialWarehouseCode,
			@MoveDocNo,
			'기종변경',				-- MRMIExtText01
			@MaterialLotNo,			-- MRMIExtText02
			@MaterialCode,			-- MRMIExtText03
			@TargetMaterialCode,	-- MRMIExtText04
			0,						-- IsCancel
			GETDATE(),
			@ProcessUserID
		)

		-- 자재입고 디테일 생성
		WHILE @GRRow <= @GRCount BEGIN
			SELECT
					@MaterialCode = GR.MaterialCode,
					@MaterialStockAttribute = 'NORMAL',
					@StockAttrib1 = '',
					@StockAttrib2 = '',
					@StockAttrib3 = '',
					@CurrentQty = GR.PickingQty
			FROM
					@GRMaterial GR
			WHERE
					GR.Row = @GRRow

			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @GRDocDetailNo OUTPUT
		
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
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@GRDocDetailNo,
				@GRDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@CurrentQty,		-- RequestQty
				@CurrentQty,		-- AllowQty
				@CurrentQty,		-- PickingAssignQty
				0,		-- PickingQty
				0,		-- ProcessFixQty
				GETDATE(),
				@ProcessUserID
			)
			SET @GRRow = @GRRow + 1
		END

		-- 자재입고 완료
		EXEC usp_DoFinishMaterialDoc	@ProcessLanguage,
										@ProcessUserID,
										@GRDocNo
		-- 자재입고 확정
		EXEC usp_DoFixMaterialDoc	@ProcessLanguage,
									@ProcessUserID,
									@GRDocNo
	END
	

	-- 자재출고 문서(GI_ETC) 생성
	DECLARE @GIDocNo VARCHAR(20),
			@GIDocDetailNo VARCHAR(20)

	DECLARE @GIRow INT,
			@GICount INT

	SELECT
			@GIRow = 1,
			@GICount = COUNT(*)
	FROM
			@GIMaterial

	IF @GICount > 0 BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo', @GIDocNo OUTPUT
	
		-- 2016-09-27 JGH 수정 창고지정추가
		SELECT @MaterialWarehouseCode = MaterialWarehouseCode FROM @GIMaterial

		INSERT INTO STB_MaterialDocInfo
		(
			MaterialDocNo,
			MaterialDocType,
			MaterialDocTypeCode,
			DocStatus,
			BasicDate,
			SourceCompanyCode,
			SourceWorkCenterCode,
			SourceMaterialWarehouseCode,
			RefMaterialDocNo,
			MRMIExtText01,	-- 비고
			MRMIExtText02,	-- 변경 MaterialLotNo
			MRMIExtText03,	-- 변경전 MaterialCode
			MRMIExtText04,	-- 변경후 MaterialCode
			IsCancel,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@GIDocNo,
			'GI',
			'GI_ETC',
			'CREATE',
			GETDATE(),
			@CompanyCode,
			@WorkCenterCode,
			@MaterialWarehouseCode,
			@MoveDocNo,
			'기종변경',				-- MRMIExtText01
			@MaterialLotNo,			-- MRMIExtText02
			@MaterialCode,			-- MRMIExtText03
			@TargetMaterialCode,	-- MRMIExtText04
			0,						-- IsCancel
			GETDATE(),
			@ProcessUserID
		)

		-- 자재출고 디테일 생성
		WHILE @GIRow <= @GICount BEGIN
			SELECT
					@MaterialCode = GI.MaterialCode,
					@MaterialStockAttribute = 'NORMAL',
					@StockAttrib1 = '',
					@StockAttrib2 = '',
					@StockAttrib3 = '',
					@CurrentQty = GI.PickingQty
			FROM
					@GIMaterial GI
			WHERE
					GI.Row = @GIRow

			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @GIDocDetailNo OUTPUT
		
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
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@GIDocDetailNo,
				@GIDocNo,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@CurrentQty,		-- RequestQty
				@CurrentQty,		-- AllowQty
				@CurrentQty,		-- PickingAssignQty
				0,		-- PickingQty
				0,		-- ProcessFixQty
				GETDATE(),
				@ProcessUserID
			)
			SET @GIRow = @GIRow + 1
		END
	
		-- 자재출고 완료
		EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
										@pProcessUserID = @ProcessUserID,
										@pMaterialDocNo = @GIDocNo,
										@pIsBackFlush = 1
		-- 자재출고 확정
		EXEC usp_DoFixMaterialDoc	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @GIDocNo,
									@pIsBackFlush = 1
	END


	UPDATE STB_MaterialLotInfo
	SET
		MaterialCode = @TargetMaterialCode,
		PickingQty = 0
	WHERE
		MaterialLotNo = @MaterialLotNo

	
END