-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 현장용
-- Create date: 2018-08-03
-- Description:	공정별 실적 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdGRMaterialByOne]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pLotID VARCHAR(50) = NULL,
	@pLotNo VARCHAR(50) = NULL,
	@pPackingID VARCHAR(50) = NULL,
	@pMarkingCode varchar(20)=NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pStockAttrib1 VARCHAR(20) = NULL,
	@pStockAttrib2 VARCHAR(20) = NULL,
	@pStockAttrib3 VARCHAR(20) = NULL,
	@pMaterialDocNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LotID VARCHAR(50) = ISNULL(@pLotID,'')
	DECLARE @LotNo VARCHAR(50) = ISNULL(@pLotNo,'')
	DECLARE @PackingID VARCHAR(50) = ISNULL(@pPackingID,'')
	DECLARE @MarkingCode VARCHAR(50) = ISNULL(@pMarkingCode,'')
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @ProdQty NUMERIC(20,5) = ISNULL(@pProdQty,1)

	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @GRWarehouseCode VARCHAR(20)
	DECLARE @GRLocationCode VARCHAR(20)
	DECLARE @MaterialDocNo VARCHAR(20) = ISNULL(@pMaterialDocNo,'')
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @MaterialDocTypeCode VARCHAR(20) = 'GR_INT_PROD'
	DECLARE @MaterialStockAttribute VARCHAR(20) = 'NORMAL'
	DECLARE @IsUseBarcode BIT
	DECLARE @IsLotUse BIT
	DECLARE @MaterialLotNo VARCHAR(20)
	DECLARE @StockAttrib1 VARCHAR(20) = ISNULL(@pStockAttrib1,'')
	DECLARE @StockAttrib2 VARCHAR(20) = ISNULL(@pStockAttrib2,'')
	DECLARE @StockAttrib3 VARCHAR(20) = ISNULL(@pStockAttrib3,'')

	--Line의 CompanyCode 
	DECLARE @LineCompanyCode VARCHAR(20)
			--RAISERROR(@PONo,16,1)
	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@MaterialCode = POI.MaterialCode,
			@IsUseBarcode = MSA.IsUseBarcode,
			@IsLotUse = MSA.IsLotUse
	FROM
			STB_ProductionOrderInfo POI
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSA
				ON MSA.MaterialCode = POI.MaterialCode
	WHERE
			POI.PONo = @PONo

	-- 베트남 권취 후 본사 진행의 경우 라인은 베트남 라인이나 후공정이 본사 공정이므로
	-- 최초 라인의 소속에 따라 공정코드를 변경한다. 2020.10.28 By Jackaroe
	-- 베트남 로케이션 입고의 경우 입고예정 목록에 자동 추가되지 않으므로 수기 작업을 해주어야 한다.

		

	SELECT @LineCompanyCode = CompanyCode
	  FROM STB_LineInfo
	 WHERE LineCode = @LineCode

	 INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@LineCode', @LineCode)

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@LineCompanyCode', @LineCompanyCode)

	SELECT
			@GRWarehouseCode = LRM.GRWarehouseCode,
			@GRLocationCode = ISNULL(LRM.GRLocationCode, MW.DefaultLocationCode) -- GRLocation이 지정되어있으면 가져다 쓰고 그렇지 않으면 기본 로케이션을 참조한다. 2022.08.28 by Jackaroe
	FROM
			STB_LineRouteMapping LRM
			LEFT OUTER JOIN STB_MaterialWarehouse MW
				ON MW.MaterialWarehouseCode = LRM.GRWarehouseCode	-- 2019-06-10 JGH 수정
	WHERE
			LRM.LineCode = @LineCode AND
			LRM.RouteCode = CASE WHEN @LineCompanyCode = 'VNT' THEN REPLACE(@RouteCode, 'V-', 'E-')
			                     ELSE REPLACE(@RouteCode, 'E-', 'V-') END
								 

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@PackingID', @PackingID)

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@GRWarehouseCode', @GRWarehouseCode)

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@GRLocationCode', @GRLocationCode)
		
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
		'GR',					--MaterialDocType,
		@MaterialDocTypeCode,	--MaterialDocTypeCode,
		'CREATE',				--DocStatus,
		'',						--SourceCustomerCode,
		@CompanyCode,			--SourceCompanyCode,
		@WorkCenterCode,		--SourceWorkCenterCode,
		@RouteCode,				--SourceRouteCode,
		'',						--SourceMaterialWarehouseCode,
		'',						--TargetCustomerCode,
		@CompanyCode,			--TargetCompanyCode,
		@WorkCenterCode,		--TargetWorkCenterCode,
		'',						--TargetRouteCode,
		@GRWarehouseCode,		--TargetMaterialWarehouseCode,
		@PONo,					--PONo,
		'',						--FPItemWorkNo,
		'',						--RefMaterialDocNo,
		GETDATE(),				--RequestDateTime,
		'system',				--RequestUserID,
		GETDATE(),				--RequestPlanDate,
		'',						--RequestDesc,
		GETDATE(),				--RequestFixDateTime,,
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

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@MaterialDocNo', @MaterialDocNo)
		
	SELECT
			@MaterialDocDetailNo = MDD.MaterialDocDetailNo
	FROM
			STB_MaterialDocDetail MDD
	WHERE
			MDD.MaterialDocNo = @MaterialDocNo AND
			MDD.MaterialCode = @MaterialCode AND
			MaterialStockAttribute = @MaterialStockAttribute AND
			StockAttrib1 = @StockAttrib1 AND
			StockAttrib2 = @StockAttrib2 AND
			StockAttrib3 = @StockAttrib3

	IF ISNULL(@MaterialDocDetailNo,'') = '' BEGIN
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
				@ProdQty,		--RequestQty,
				@ProdQty,		--AllowQty,
				@ProdQty,		--PickingAssignQty,
				@ProdQty,		--PickingQty,
				'NONE',
				GETDATE(),
				@ProcessUserID
			)
	END ELSE BEGIN
			UPDATE	STB_MaterialDocDetail
			SET
					RequestQty = RequestQty + @ProdQty,
					AllowQty = AllowQty + @ProdQty,
					PickingAssignQty = PickingAssignQty + @ProdQty,
					PickingQty = PickingQty + @ProdQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo
	END

	INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@MaterialDocDetailNo', @MaterialDocDetailNo)

	IF @IsUseBarcode = 1 OR @IsLotUse = 1 BEGIN

			

			IF @IsUseBarcode = 1 AND @LotID = '' BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage,'바코드 사용자재는 LotID가 필수입니다'
			END

			IF @IsLotUse = 1 AND @LotNo = '' BEGIN
					EXEC usp_RaiseLocalizedError @ProcessLanguage, 'Lot을 사용하는 자재는 LotNo가 필수입니다'
			END

			SELECT
					@MaterialLotNo = MLI.MaterialLotNo
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.CompanyCode = @CompanyCode AND
					MLI.WorkCenterCode = @WorkCenterCode AND
					MLI.MaterialCode = @MaterialCode AND
					MLI.LotID = @LotID AND
					MLI.LotNo = @LotNo AND
					MLI.StockAttrib1 = @StockAttrib1 AND
					MLI.StockAttrib2 = @StockAttrib2 AND
					MLI.StockAttrib3 = @StockAttrib3

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
				MarkingCode,
				LotNo,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialDocDetailNo,
				(
					SELECT
							ISNULL(MAX(MDLI.MDLISeqNo),0) + 1
					FROM
							STB_MaterialDocLotInfo MDLI
					WHERE
							MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
				),
				ISNULL(@MaterialLotNo,''),
				@LotID,
				@MaterialCode,
				@MaterialStockAttribute,
				@StockAttrib1,
				@StockAttrib2,
				@StockAttrib3,
				@ProdQty,
				1,
				@GRLocationCode,
				@MaterialDocNo,
				CASE WHEN ISNULL(@PackingID,'') = '' THEN @LotID ELSE @PackingID END,
				CASE WHEN ISNULL(@MarkingCode,'') = '' THEN '' ELSE @MarkingCode END,
				@LotNo,
				GETDATE(),
				@ProcessUserID
			)

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@PackingID', @PackingID)

			INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) 
				VALUES ('usp_DoProcessProdGRMaterialByOne', '@LotID', @LotID)
	END
								
	SET @pMaterialDocNo = @MaterialDocNo
END


--select * from STB_MaterialLotInfo where packingid='PKPL2600235'