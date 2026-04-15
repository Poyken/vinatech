

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date: 2016-09-16
-- Description: 라벨을 생성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateLabel]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20),
	@pLabelQty INT,
	@pPackingQty NUMERIC(20,5)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,
			@LabelQty INT = @pLabelQty,
			@PackingQty NUMERIC(20,5) = @pPackingQty

	DECLARE	@MaterialDocNo VARCHAR(20),
			@MaterialDocType VARCHAR(20),
			@DocStatus VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MakeQty NUMERIC(20,5) = @LabelQty * @PackingQty,
			@WorkCenterCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@BasicMaterialType VARCHAR(20),
			@AllowQty NUMERIC(20,5),
			@CurrentQty NUMERIC(20,5),
			@LotID VARCHAR(50),
			@PrefixData VARCHAR(20),
			@SerialLen INT,
			@NewSerial INT,
			@CustomerName NVARCHAR(50)

	SELECT
			@MaterialDocNo = MDD.MaterialDocNo,
			@MaterialDocType = MDI.MaterialDocType,
			@DocStatus = MDI.DocStatus,
			@WorkCenterCode = MDI.TargetWorkCenterCode,
			@MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode,
			@AllowQty = MDD.AllowQty,
			@MaterialCode = MDD.MaterialCode,
			@BasicMaterialType = MT.BasicMaterialType,
			@CustomerName = CI.CustomerName
	FROM
			STB_MaterialDocDetail MDD
			INNER JOIN STB_MaterialDocInfo MDI				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster MM 		ON	MM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_CustomerInfo CI				ON CI.CustomerCode = MDI.SourceCustomerCode
	WHERE
			MDD.MaterialDocDetailNo = @MaterialDocDetailNo


	IF @MaterialDocNo  IS NULL 
	
	BEGIN
		RAISERROR('수불문서를 찾을 수 없습니다.',16,1)
		RETURN
	END

	IF @MaterialDocType <> 'GR' 
	
	BEGIN
		RAISERROR('입고문서가 아닙니다.',16,1)
		RETURN
	END

	IF @DocStatus <> 'ARRIVAL' BEGIN
		RAISERROR('입하처리가 되지 않았습니다.',16,1)
		RETURN
	END

	DECLARE @SerialType VARCHAR(20)
	IF @BasicMaterialType IN ('ROH', 'HIBE') BEGIN
		SET @SerialType = @BasicMaterialType
	END

	SELECT
		 	@CurrentQty = SUM(MDLI.StockQty)			
	FROM
			STB_MaterialDocLotInfo MDLI
	WHERE
			MDLI.MaterialDocDetailNo = @MaterialDocDetailNo

	SET @CurrentQty = ISNULL(@CurrentQty, 0)
	--DECLARE @A VARCHAR(20) = @AllowQty,
	--		@B VARCHAR(20) = @CurrentQty,
	--		@C VARCHAR(20) = @MakeQty
	--RAISERROR('%s / %s / %s',16,1,@A,@B,@C)
	--RETURN
	IF @AllowQty < @CurrentQty + @MakeQty
	
	 BEGIN
		RAISERROR('수량을 초과하여 인쇄할 수 없습니다.',16,1)
		RETURN
	  END

	DECLARE @MaterialLocationCode VARCHAR(20)

	SELECT
			@MaterialLocationCode = MW.DefaultLocationCode
	FROM
			STB_MaterialWarehouse MW
	WHERE
			MW.MaterialWarehouseCode = @MaterialWarehouseCode

	IF ISNULL(@MaterialLocationCode,'') = '' BEGIN
		RAISERROR('입고창고의 기본 로케이션이 지정되지 않았습니다.',16,1)
		RETURN
	END

	DECLARE @IsAutoCheck VARCHAR(1)

	SELECT
			@IsAutoCheck = GPR.SettingValue
	FROM
			SmartFramework.dbo.STB_GlobalProcessRule GPR
	WHERE
			GPR.RuleCode = 'AUTO_SCAN_CHECK_MATERIAL_GR'
	
	IF ISNULL(@IsAutoCheck,'') = ''
		SET @IsAutoCheck = 'N'

	DECLARE @Index INT = 1

	DECLARE @JobDateShiftTime VARCHAR(10),
			@JobDate DATE,
			@ShiftCode CHAR(1),
			@RollNo VARCHAR(10),
			@LotNo VARCHAR(100)

	WHILE @Index <= @LabelQty BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo',
													@LotID OUTPUT													
	

	--raiserror ('check12312',16,1)
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
			PackingID,
			LotNo,
			MaterialDocNo,
			CreateDateTime,
			CreateUserID,
			LotAttr01,				-- MODEL
			LotAttr02,				-- Production Order
			LotAttr03				-- VendorName
		)
		SELECT
				MDD.MaterialDocDetailNo,
				(
					SELECT
							COUNT(1)
					FROM
							STB_MaterialDocLotInfo MDLI
					WHERE
							MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo
				) + 1,
				@LotID,
				MDD.MaterialCode,
				MDD.MaterialStockAttribute,
				MDD.StockAttrib1,
				MDD.StockAttrib2,
				MDD.StockAttrib3,
				@PackingQty,
				CASE @IsAutoCheck
					WHEN 'Y' THEN 1
					ELSE 0
				END,		-- IsCheck
				@MaterialLocationCode,
				@LotID,
				--@LotNo,		-- LotNo
				MDD.StockAttrib2, --업체LotID 일괄세팅
				MDD.MaterialDocNo,
				GETDATE(),
				@ProcessUserID,
				'',
				'',
				@CustomerName
		FROM
				STB_MaterialDocDetail MDD
		WHERE
				MDD.MaterialDocDetailNo = @MaterialDocDetailNo

		SET @Index = @Index + 1
	END
END


