
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-27
-- Browsable : true
-- Group : 자재관리
-- Description: MRP 정보를 이용하여 자재발주를 생성합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMaterialOrder_ByMRP]
	@pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pProcessViewName VARCHAR(50) = NULL,
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--raiserror  ('XML Data: %s', 16, 1, @pXml) WITH NOWAIT;
	DECLARE @iDoc INT

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
	DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

	DECLARE @MaterialWarehouseCode VARCHAR(20)

	SET @MaterialWarehouseCode = dbo.fnGetConstValue('MaterialOrder','MaterialWarehouseCode','ROH_WH')
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	DECLARE @OrderItem TABLE
	(
		Row INT IDENTITY(1,1),
		MRPTargetNo VARCHAR(20),
		CustomerCode VARCHAR(20),
		IsInternalProd BIT,
		MaterialCode VARCHAR(20),
		PlanGrDate DATE,
		OrderQty NUMERIC(20,5)
	)
    ;
	WITH MRP AS
	(
		SELECT
				MrpTargetNo = MrpTargetNo,
				OrderQty = OrderQty
		FROM
				OPENXML(@idoc , @TableName , 2)
				WITH	(
							MrpTargetNo VARCHAR(20),
							OrderQty NUMERIC(20,5)
						) XMLData
	)
	INSERT INTO @OrderItem
	(
		MRPTargetNo,
		CustomerCode,
		IsInternalProd,
		MaterialCode,
		PlanGrDate,
		OrderQty
	)
	SELECT
			M.MrpTargetNo,
			MTM.CustomerCode,
			ISNULL(MM.IsInternalProd,0),		--	MRP 대상자재중 가공품여부가 true 이면 외주가공
			MTM.MaterialCode,
			MTM.PlanGrDate,
			--MTM.FixedQty,
			M.OrderQty
	FROM
			MRP M
			INNER JOIN STB_MrpTargetMaterial MTM
				ON	MTM.MrpTargetNo = M.MrpTargetNo
			INNER JOIN STB_MaterialMaster MM
				ON	MM.MaterialCode = MTM.MaterialCode
	ORDER BY
			MTM.CustomerCode,
			MM.IsInternalProd

	EXEC sp_xml_removedocument @idoc	

	DECLARE @MaterialOrderNo VARCHAR(20),
			@MaterialOrderItemNo VARCHAR(20),
			@MrpTargetNo VARCHAR(20),
			@CustomerCode VARCHAR(20),
			@IsInternalProd BIT,
			@OrderToName NVARCHAR(50),
			@MaterialCode VARCHAR(20),
			@PlanGrDate DATE,			
			@OrderQty NUMERIC(20,5),
			@MaterialUnitPriceQty NUMERIC(20,5),
			@MaterialUnitPrice NUMERIC(20,5)

	DECLARE @Row INT = 1,
			@Count INT

	SELECT
			@Count = COUNT(*)
	FROM
			@OrderItem

	DECLARE @CurrCustomerCode VARCHAR(20) = '',
			@CurrIsInternalProd BIT = NULL

	WHILE @Row <= @Count BEGIN
		SELECT
				@MrpTargetNo = OI.MRPTargetNo,
				@CustomerCode = OI.CustomerCode,
				@IsInternalProd = OI.IsInternalProd,
				@OrderToName = CI.OrderToName,
				@MaterialCode = OI.MaterialCode,
				@PlanGrDate = OI.PlanGrDate,
				@OrderQty = OI.OrderQty
		FROM
				@OrderItem OI
				LEFT OUTER JOIN STB_CustomerInfo CI
					ON	CI.CustomerCode = OI.CustomerCode
		WHERE
				OI.Row = @Row

		-- 거래처가 달라지거나 가공품여부가 달라지면 발주서 생성
		-- 가공품여부가 FALSE(0) 이면 구매발주서 생성
		-- 가공품여부가 TRUE(1) 이면 외주생산 발주서 생성
		IF (@CurrCustomerCode <> @CustomerCode) OR (@CurrIsInternalProd <> @IsInternalProd) BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialOrder',
														@MaterialOrderNo OUTPUT

			
			INSERT INTO STB_MaterialOrder
			(
				MaterialOrderNo,
				CompanyCode,
				WorkCenterCode,
				MOCreateType,
				MaterialOrderType,
				CustomerCode,
				OrderFromUserID,
				OrderToName,
				MaterialWarehouseCode,
				OrderDate,
				DeliveryPlanDate,
				TotalItemQty,
				TotalOrderPrice,
				OrderStatus,
				IsAllCancel,
				IsFinished,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@MaterialOrderNo,
				@CompanyCode,
				@WorkCenterCode,
				'MRP',			-- MOCreateType
				CASE @IsInternalProd 
					WHEN 1 THEN 'PRODUCTION'	-- 외주생산
					ELSE 'PURCHASE'				-- 구매
				END,		-- MaterialOrderType
				@CustomerCode,
				@ProcessUserID,
				@OrderToName,
				@MaterialWarehouseCode,
				GETDATE(),		-- OrderDate
				@PlanGrDate,	-- DeliveryPlanDate
				0,				-- TotalItemQty
				0,				-- TotalOrderPrice
				'REQUEST',		-- OrderStatus
				0,				-- IsAllCancel
				0,				-- IsFinished
				GETDATE(),
				@ProcessUserID
			)

			SET @CurrCustomerCode = @CustomerCode
			SET @CurrIsInternalProd = @IsInternalProd
		END

		-- 구매항목 생성
		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialOrderItem',
													@MaterialOrderItemNo OUTPUT

		SELECT
				@MaterialUnitPriceQty = ISNULL(MVM.UnitPriceQty,1),
				@MaterialUnitPrice = ISNULL(MVM.UnitPrice,0)
		FROM
				STB_MaterialVendorMapping MVM
		WHERE
				MVM.MaterialCode = @MaterialCode AND
				MVM.CustomerCode = @CustomerCode

		INSERT INTO STB_MaterialOrderItem
		(
			MaterialOrderItemNo,
			MaterialOrderNo,
			MaterialCode,
			MaterialStockAttribute,
			StockAttrib1,
			StockAttrib2,
			StockAttrib3,
			MaterialOrderQty,
			MaterialOrderUnitPriceQty,
			MaterialOrderUnitPrice,
			MaterialOrderTotalPrice,
			IsCancel,
			MaterialOrderRemainQty,
			PlanGrDate,
			MrpTargetNo,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@MaterialOrderItemNo,
			@MaterialOrderNo,
			@MaterialCode,
			'NORMAL',	-- MaterialStockAttribute
			'',			-- StockAttrib1
			'',			-- StockAttrib2
			'',			-- StockAttrib3
			@OrderQty,	-- MaterialOrderQty
			@MaterialUnitPriceQty,	-- MaterialOrderUnitPriceQty
			@MaterialUnitPrice,		--MaterialOrderUnitPrice
			(@OrderQty / @MaterialUnitPriceQty) * @MaterialUnitPrice, -- MaterialOrderTotalPrice
			0, -- IsCancel,
			@OrderQty, -- MaterialOrderRemainQty,
			@PlanGrDate,
			@MrpTargetNo, -- MrpTargetNo,
			GETDATE(), -- CreateDateTime,
			@ProcessUserID -- CreateUserID
		)

		UPDATE
				STB_MaterialOrder
		SET
				TotalItemQty = TotalItemQty + 1,
				TotalOrderPrice = TotalOrderPrice + ((@OrderQty / @MaterialUnitPriceQty) * @MaterialUnitPrice)
		WHERE
				MaterialOrderNo = @MaterialOrderNo

		UPDATE
				STB_MrpTargetMaterial
		SET
				MaterialOrderNo = @MaterialOrderNo,
				MaterialOrderItemNo = @MaterialOrderItemNo
		WHERE
				MrpTargetNo = @MrpTargetNo

		SET @Row = @Row + 1
	END



END

