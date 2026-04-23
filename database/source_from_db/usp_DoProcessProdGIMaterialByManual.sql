-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Browsable : ture
-- Group : 생산관리
-- Create date: 2022-09-01
-- Description:	MEA 원자재 투입 시 입력 받은 수량을 기준으로 출고처리 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdGIMaterialByManual]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pLotID VARCHAR(50) = NULL,
	@pInputQty NUMERIC(20,5) = NULL,
	@pGIWarehouseCode VARCHAR(20) = NULL,
	@pGILocationCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @InputQty NUMERIC(20,5) = @pInputQty

	Declare @MaterialCode VARCHAR(20) 

	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MaterialStockAttribute VARCHAR(20) = 'NORMAL'
	DECLARE @MaterialDocType VARCHAR(20) = 'GI_PRODUCTION'
	DECLARE @GIWarehouseCode VARCHAR(20) = @pGIWarehouseCode
	DECLARE @GILocationCode VARCHAR(20) = @pGILocationCode
	DECLARE @Count INT
	DECLARE @Row INT = 1
	DECLARE @UsedQty NUMERIC(20,5)
	DECLARE @Items TABLE
	(
		IDX INT,
		MaterialCode VARCHAR(50),
		UseQty NUMERIC(20,5)
	)

	SELECT @MaterialCode = MaterialCode
	  FROM STB_MaterialDocLotInfo
	 WHERE LotID = @LotID OR LotNo = @LotID

	INSERT INTO @Items
	SELECT
			1 AS IDX,
			@MaterialCode,
			@InputQty
			
	-- 2019-05-10 JGH 수정 차감할 자재가 있는지 확인
	DECLARE @NotEnoughMaterial VARCHAR(50) = NULL

	--SELECT
	--		@NotEnoughMaterial = IT.MaterialCode
	--FROM
	--		@Items IT
	--		LEFT OUTER JOIN STB_MaterialStock MS
	--			ON MS.MaterialCode = IT.MaterialCode AND
	--			MS.CompanyCode = @CompanyCode AND
	--			MS.WorkCenterCode = @WorkCenterCode AND
	--			MS.MaterialWarehouseCode IN (SELECT MaterialWarehouseCode 
	--			                               FROM STB_MaterialWarehouse 
	--										  WHERE IsRouteWarehouse = CONVERT(BIT, 1))
	--WHERE
 --			IT.UseQty > ISNULL(MS.StockQty,0)

	SELECT
			@NotEnoughMaterial = IT.MaterialCode
	FROM
			@Items IT
			LEFT OUTER JOIN STB_MaterialLotInfo MLI
				ON MLI.MaterialCode = IT.MaterialCode AND
				MLI.CompanyCode = @CompanyCode AND
				MLI.WorkCenterCode = @WorkCenterCode AND
				(MLI.LotID = @LotID OR MLI.LotNo = @LotID) 
				--AND
				--MLI.MaterialWarehouseCode IN (SELECT MaterialWarehouseCode 
				--                               FROM STB_MaterialWarehouse 
				--							  WHERE IsRouteWarehouse = CONVERT(BIT, 1))  --->>공정창고, 원자재창고 에서 샘플자재 투입이 가능하도록 조치 2022.11.23 SJC
	WHERE
 			IT.UseQty > ISNULL(MLI.CurrentQty,0)



	IF @NotEnoughMaterial IS NOT NULL BEGIN
			DECLARE @Message NVARCHAR(200) = '부족한 자재가 있습니다 [' + @NotEnoughMaterial + '].'
			EXEC usp_RaiseLocalizedError @ProcessLanguage, @Message
	END

	SET @Count = (SELECT COUNT(*) FROM @Items)

	IF @Count > 0 BEGIN
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
								'',				--SourceRouteCode,
								@GIWarehouseCode,		--SourceMaterialWarehouseCode,
								'',						--TargetCustomerCode,
								@CompanyCode,			--TargetCompanyCode,
								@WorkCenterCode,		--TargetWorkCenterCode,
								'',				--TargetRouteCode,
								'',						--TargetMaterialWarehouseCode,
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
																		@pUsedQty = @UsedQty

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