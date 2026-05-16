-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 현장용
-- Create date: 2018-08-16
-- Description:	ProductionOrderBom의 공정에 해당하는 자재를 출고처리합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdGIMaterialByBOM]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pMaterialCode VARCHAR(50),
	@pLotID VARCHAR(50) = NULL,
	@pLotNo VARCHAR(50) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pFPItemWorkNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	DECLARE @PONo VARCHAR(20) = @pPONO
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @LotNo VARCHAR(50) = ISNULL(@pLotNo,'')
	DECLARE @ProdQty NUMERIC(20,5) = @pProdQty
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')
	DECLARE @FPItemWorkNo VARCHAR(20) = ISNULL(@pFPItemWorkNo,'')

	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MaterialStockAttribute VARCHAR(20) = 'NORMAL'
	DECLARE @MaterialDocType VARCHAR(20) = 'GI_PRODUCTION'
	DECLARE @GIWarehouseCode VARCHAR(20)
	DECLARE @GILocationCode VARCHAR(20)
	DECLARE @Count INT
	DECLARE @Row INT = 1
	DECLARE @UsedQty NUMERIC(20,5)
	DECLARE @Items TABLE
	(
		IDX INT,
		MaterialCode VARCHAR(50),
		UseQty NUMERIC(20,5)
	)

	INSERT INTO @Items
	SELECT
			ROW_NUMBER() OVER (ORDER BY POB.ChildMaterialCode) AS IDX,
			POB.ChildMaterialCode,
			SmartFramework.dbo.fnConvertUnit(POB.BomUnit,MM.MaterialUnit,POB.UsedQty * @ProdQty)
			--POB.MaterialUnitUsedQty * @ProdQty
	FROM
			STB_ProductionOrderBom POB
			INNER JOIN STB_MaterialMaster MM
				ON MM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI
				ON MSAI.MaterialCode = POB.ChildMaterialCode
	WHERE
			POB.PONo = @PONo AND
			POB.MaterialCode = @MaterialCode AND
			POB.RouteCode = @RouteCode AND
			POB.IsUseProduction = 1 AND
			MM.IsUseFlush = 1 AND
			MM.IsUseBackFlush = 0

	PRINT 'usp_DoProcessProdGIMaterialByBOM' + ' @PONo ' + @PONo
	PRINT 'usp_DoProcessProdGIMaterialByBOM' + ' @MaterialCode ' + @MaterialCode
	PRINT 'usp_DoProcessProdGIMaterialByBOM' + ' @RouteCode ' + @RouteCode

			
	-- 2019-05-10 JGH 수정 차감할 자재가 있는지 확인
	DECLARE @NotEnoughMaterial VARCHAR(50) = NULL

	SELECT
			@NotEnoughMaterial = IT.MaterialCode
	FROM
			@Items IT
			LEFT OUTER JOIN STB_MaterialStock MS
				ON MS.MaterialCode = IT.MaterialCode AND
				MS.CompanyCode = @CompanyCode AND
				MS.WorkCenterCode = @WorkCenterCode AND
				MS.MaterialWarehouseCode = @GIWarehouseCode
	WHERE
 			IT.UseQty > ISNULL(MS.StockQty,0)



	IF @NotEnoughMaterial IS NOT NULL BEGIN
			DECLARE @Message NVARCHAR(200) = '부족한 자재가 있습니다 [' + @NotEnoughMaterial + '].'
			EXEC usp_RaiseLocalizedError @ProcessLanguage, @Message
	END

	SET @Count = (SELECT COUNT(*) FROM @Items)

	IF @Count > 0 BEGIN
			SELECT
					@GIWarehouseCode = LRM.MaterialWarehouseCode,
					@GILocationCode = LRM.GILocationCode
			FROM
					STB_LineRouteMapping LRM
			WHERE
					LRM.LineCode = @LineCode AND
					LRM.RouteCode = @RouteCode

			WHILE @Count >= @Row BEGIN
					IF @Row = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocInfo',@MaterialDocNo OUTPUT
			
							INSERT INTO STB_MaterialDocInfo
							(
								MaterialDocNo,
								BasicDate,
								MaterialDocType,
								MaterialDocTypeCode,
								DocStatus,
								SourceCustomerCode,
								SourceCompanyCode,
								SourceWorkCenterCode,
								SourceRouteCode,
								SourceMaterialWarehouseCode,
								TargetCustomerCode,
								TargetCompanyCode,
								TargetWorkCenterCode,
								TargetRouteCode,
								TargetMaterialWarehouseCode,
								PONo,
								FPItemWorkNo,
								RefMaterialDocNo,
								RequestDateTime,
								RequestUserID,
								RequestPlanDate,
								RequestDesc,
								RequestFixDateTime,
								RequestFixUserID,
								IsAssignPicking,
								IsCancel,
								IsPickingFix,
								IsRequestApproval,
								IsRequestFix,
								IsSourceFinish,
								IsTargetFinish,
								IsUploadERP,
								CreateDateTime,
								CreateUserID
							)
							VALUES
							(
								@MaterialDocNo,			--MaterialDocNo,
								GETDATE(),				--BasicDate,
								'GI',					--MaterialDocType,
								@MaterialDocType,		--MaterialDocTypeCode,
								'CREATE',				--DocStatus,
								'',						--SourceCustomerCode,
								@CompanyCode,			--SourceCompanyCode,
								@WorkCenterCode,		--SourceWorkCenterCode,
								@RouteCode,				--SourceRouteCode,
								@GIWarehouseCode,		--SourceMaterialWarehouseCode,
								'',						--TargetCustomerCode,
								@CompanyCode,			--TargetCompanyCode,
								@WorkCenterCode,		--TargetWorkCenterCode,
								@RouteCode,				--TargetRouteCode,
								'',						--TargetMaterialWarehouseCode,
								@PONo,					--PONo,
								@FPItemWorkNo,			--FPItemWorkNo,
								'',						--RefMaterialDocNo,
								GETDATE(),				--RequestDateTime,
								'system',				--RequestUserID,
								GETDATE(),				--RequestPlanDate,
								'',						--RequestDesc,
								GETDATE(),				--RequestFixDateTime,
								'system',				--RequestFixUserID,
								0,						--IsAssignPicking,
								0,						--IsCancel,
								0,						--IsPickingFix,
								1,						--IsRequestApproval,
								1,						--IsRequestFix,
								0,						--IsSourceFinish,
								0,						--IsTargetFinish,
								0,						--IsUploadERP,
								GETDATE(),				--CreateDateTime,
								@ProcessUserID			--CreateUserID
							)
					END

					SELECT
							@MaterialCode = IT.MaterialCode,
							@UsedQty = IT.UseQty
					FROM
							@Items IT
					WHERE
							IT.IDX = @Row

					EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail',@MaterialDocDetailNo OUTPUT

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
						InspectionType,
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
						@UsedQty,		--RequestQty,
						@UsedQty,		--AllowQty,
						@UsedQty,		--PickingAssignQty,
						@UsedQty,		--PickingQty,
						'NONE',
						GETDATE(),
						@ProcessUserID
					)

					EXEC usp_DoCreateMaterialDocLotInfoNotUsedBarcode	@pProcessUserID = @ProcessUserID,
																		@pProcessLanguage = @ProcessLanguage,
																		@pMaterialDocNo = @MaterialDocNo,
																		@pMaterialDocDetailNo = @MaterialDocDetailNo,
																		@pMaterialCode = @MaterialCode,
																		@pMaterialStockAttribute = @MaterialStockAttribute,
																		@pMaterialWarehouseCode = @GIWarehouseCode,
																		@pMaterialLocationCode = @GILocationCode,
																		@pUsedQty = @UsedQty,
																		@pStockAttrib1 = @StockAttrib1,
																		@pStockAttrib2 = @StockAttrib2,
																		@pStockAttrib3 = @StockAttrib3

					SET @Row = @Row + 1
			END	--WHILE @Count >= @Row BEGIN

			EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
											@pProcessUserID = @ProcessUserID,
											@pMaterialDocNo = @MaterialDocNo

			EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
										@pProcessLanguage = @ProcessLanguage,
										@pMaterialDocNo = @MaterialDocNo
	END
END
