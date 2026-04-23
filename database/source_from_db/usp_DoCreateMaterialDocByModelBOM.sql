

-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-29
-- Description:	BOM 정보를 이용하여 문서 생성
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialDocByModelBOM]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pMaterialDocTypeCode VARCHAR(20),
	@pNewMaterialDocNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@MaterialDocTypeCode VARCHAR(20) = @pMaterialDocTypeCode,
			@MaterialDocType VARCHAR(20)
			
	SELECT
			@MaterialDocType = MDT.MaterialDocType
	FROM
			STB_MaterialDocType MDT
	WHERE
			MDT.MaterialDocTypeCode = @MaterialDocTypeCode			

	DECLARE @SourceCompanyCode VARCHAR(20),
			@SourceWorkCenterCode VARCHAR(20),
			@SourceMaterialWarehouseCode VARCHAR(20),
			@TargetCompanyCode VARCHAR(20),
			@TargetWorkCenterCode VARCHAR(20),
			@TargetMaterialWarehouseCode VARCHAR(20)

	EXEC usp_DoMakeMaterialDocNo	@pProcessLanguage = @ProcessLanguage,
									@pProcessUserID = @ProcessUserID,
									@pMaterialDocNo = @pNewMaterialDocNo OUTPUT


	INSERT INTO STB_MaterialDocInfo
	(
		MaterialDocNo,
		BasicDate,
		MaterialDocType,
		MaterialDocTypeCode,
		DocStatus,
		SourceCompanyCode,
		SourceWorkCenterCode,
		SourceMaterialWarehouseCode,
		SourceRouteCode,
		TargetCompanyCode,
		TargetWorkCenterCode,
		TargetMaterialWarehouseCode,
		TargetRouteCode,
		RefMaterialDocNo,
		CreateDateTime,
		CreateUserID
	)
	SELECT
			@pNewMaterialDocNo,
			MDI.BasicDate,
			@MaterialDocType,
			@MaterialDocTypeCode,
			'CREATE',
			MDI.SourceCompanyCode,
			MDI.SourceWorkCenterCode,
			MDI.SourceMaterialWarehouseCode,
			MDI.SourceRouteCode,
			MDI.TargetCompanyCode,
			MDI.TargetWorkCenterCode,
			MDI.TargetMaterialWarehouseCode,
			MDI.TargetRouteCode,
			@MaterialDocNo,
			GETDATE(),
			@ProcessUserID
	FROM
			STB_MaterialDocInfo MDI
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo
	
	DECLARE @Detail TABLE
	(
		MaterialCode VARCHAR(50),
		UsedQty NUMERIC(20,5)
	)

	INSERT INTO @Detail
		(
			MaterialCode, 
			UsedQty
		)
	SELECT
			BD.ChildMaterialCode,			
			SUM(BD.UsedQty*MDD.AllowQty)
	FROM
			STB_MaterialDocInfo MDI
			INNER JOIN STB_MaterialDocDetail MDD
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			INNER JOIN STB_BomDetail BD
				ON	BD.MaterialCode = MDD.MaterialCode AND
					BD.BomVersion = MDD.BomVersion
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo
	GROUP BY
			BD.ChildMaterialCode

	DECLARE @MaterialDocDetailNo VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@UsedQty NUMERIC(20,5)

	DECLARE CUR_DETAIL CURSOR FOR
	SELECT
			D.MaterialCode,
			D.UsedQty
	FROM
			@Detail D

	OPEN CUR_DETAIL

	BEGIN TRY
		WHILE 1 = 1 BEGIN
			FETCH NEXT FROM CUR_DETAIL
			INTO	@MaterialCode,
					@UsedQty

			IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

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
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
					@MaterialDocDetailNo,
					@pNewMaterialDocNo,
					@MaterialCode,
					'NORMAL',	-- MaterialStockAttribute,
					'',			-- StockAttrib1
					'',			-- StockAttrib2
					'',			-- StockAttrib3
					@UsedQty,	-- RequestQty
					@UsedQty,	-- AllowQty
					0,	-- PickingAssignQty
					0,	-- PickingQty
					0,	-- ProcessFixQty
					GETDATE(),
					@ProcessUserID
			)

		END -- WHILE 1 = 1 BEGIN
		
--SELECT
--		*
--FROM
--		STB_MaterialDocDetail
--WHERE
--		MaterialDocNo = @pNewMaterialDocNo

		EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @pProcessLanguage,
										@pProcessUserID = @pProcessUserID,
										@pMaterialDocNo = @pNewMaterialDocNo,
										@pIsBackFlush = 1,
										@pIsTry = 0
		CLOSE CUR_DETAIL
		DEALLOCATE CUR_DETAIL
	END TRY
	BEGIN CATCH
		CLOSE CUR_DETAIL
		DEALLOCATE CUR_DETAIL;

		--THROW
		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@ErrorMessage,16,1)
	END CATCH	
END

