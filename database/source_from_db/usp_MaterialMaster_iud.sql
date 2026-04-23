-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-07-22
-- Browsable : true
-- Group : 품목마스터
-- Description:	품목마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMaster_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @MaterialName NVARCHAR(100)
  DECLARE @MaterialNameL NVARCHAR(100)
  DECLARE @MaterialTypeCode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @MaterialUnit VARCHAR(10)
  DECLARE @BasicGrQty NUMERIC(20,5)
  DECLARE @MaterialSpec NVARCHAR(MAX)
  DECLARE @MaterialSpecL NVARCHAR(MAX)
  DECLARE @MaterialSource NVARCHAR(50)
  DECLARE @MaterialThickness NVARCHAR(20)
  DECLARE @AvgGrDay INT
  DECLARE @IsDelegate BIT
  DECLARE @IsInternalProd BIT
  DECLARE @IsProdPlan BIT
  DECLARE @IsPurchase BIT
  DECLARE @IsOrder BIT
  DECLARE @IsUseFlush BIT
  DECLARE @IsUseBackFlush BIT
  DECLARE @IsClosed BIT
  DECLARE @IsRequireOqc BIT
  DECLARE @BeforeMaterialCode VARCHAR(50)
  DECLARE @RequestGrDay INT
  DECLARE @BasicCostPrice NUMERIC(20,5)
  DECLARE @MMExtText01 NVARCHAR(200)
  DECLARE @MMExtText02 NVARCHAR(200)
  DECLARE @MMExtText03 NVARCHAR(200)
  DECLARE @MMExtText04 NVARCHAR(200)
  DECLARE @MMExtText05 NVARCHAR(200)
  DECLARE @MMExtText06 NVARCHAR(200)
  DECLARE @MMExtText07 NVARCHAR(200)
  DECLARE @MMExtText08 NVARCHAR(200)
  DECLARE @MMExtText09 NVARCHAR(200)
  DECLARE @MMExtText10 NVARCHAR(200)
  DECLARE @MMExtInt01 BIGINT
  DECLARE @MMExtInt02 BIGINT
  DECLARE @MMExtInt03 BIGINT
  DECLARE @MMExtInt04 BIGINT
  DECLARE @MMExtInt05 BIGINT
  DECLARE @MMExtReal01 NUMERIC(20,5)
  DECLARE @MMExtReal02 NUMERIC(20,5)
  DECLARE @MMExtReal03 NUMERIC(20,5)
  DECLARE @MMExtReal04 NUMERIC(20,5)
  DECLARE @MMExtReal05 NUMERIC(20,5)
  DECLARE @MMExtReal06 NUMERIC(20,5)
  DECLARE @MMExtReal07 NUMERIC(20,5)
  DECLARE @MMExtReal08 NUMERIC(20,5)
  DECLARE @MMExtReal09 NUMERIC(20,5)
  DECLARE @MMExtReal10 NUMERIC(20,5)
  DECLARE @MMExtLongText01 NVARCHAR(MAX)
  DECLARE @MMExtLongText02 NVARCHAR(MAX)
  DECLARE @MMExtLongText03 NVARCHAR(MAX)
  DECLARE @MMExtLongText04 NVARCHAR(MAX)
  DECLARE @MMExtLongText05 NVARCHAR(MAX)
  DECLARE @MMExtImage01 VARBINARY(MAX)
  DECLARE @MMExtImage02 VARBINARY(MAX)
  DECLARE @MMExtImage03 VARBINARY(MAX)
  DECLARE @MMExtImage04 VARBINARY(MAX)
  DECLARE @MMExtImage05 VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @AltMaterialCode VARCHAR(50)
  DECLARE @BasicPackingQty NUMERIC(20,5)
  DECLARE @DelegateMaterialCode VARCHAR(50)
  DECLARE @MaterialPurchaseType NVARCHAR(50)
  DECLARE @MaxProdPlanQty NUMERIC(20,5)
  DECLARE @AgingGreen int
  DECLARE @AgingYellow int
  DECLARE @AgingRed int
  DECLARE @BasicRoutingCode VARCHAR(20)
  DECLARE @BasicCostPriceVVT NUMERIC(20,5) -- 베트남 표준원가 추가 2021.01.28 김은초롱님 요청 by Jackaroe
  DECLARE @BefModelCode NVARCHAR(200) -- 모품목 정보 추가 2026.01.05 BY 소병운

  DECLARE @IsUseBarcode VARCHAR(1),
		  @IsLotUse VARCHAR(1),
		  @IsUseVendorLot VARCHAR(1),
		  @IsUseVendorBarcode VARCHAR(1),
		  @IsLifetimeUse VARCHAR(1),
		  @IsFIFO VARCHAR(1)

	SET @IsUseBarcode = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_USE_BARCODE','Y')
	SET @IsLotUse = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_LOT_USE','Y')
	SET @IsUseVendorLot = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_USE_VENDOR_LOT','N')
	SET @IsUseVendorBarcode = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_USE_VENDOR_BARCODE','N')
	SET @IsLifetimeUse = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_LIFE_TIME_USE','N')
	SET @IsFIFO = SmartFramework.dbo.fnGetProcessRule('MATERIAL_STOCK_FIFO','Y')


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldMaterialCode,
									MaterialCode,
									MaterialName,
									MaterialNameL,
									MaterialTypeCode,
									ProductGroupCode,
									MaterialUnit,
									BasicGrQty,
									MaterialSpec,
									MaterialSpecL,
									MaterialSource,
									MaterialThickness,
									AvgGrDay,
									IsDelegate,
									IsInternalProd,
									IsProdPlan,
									IsPurchase,
									IsOrder,
									IsUseFlush,
									IsUseBackFlush,
									IsClosed,
									IsRequireOqc,
									BeforeMaterialCode,
									RequestGrDay,
									BasicCostPrice,
									BasicCostPriceVVT,
									MMExtText01,
									MMExtText02,
									MMExtText03,
									MMExtText04,
									MMExtText05,
									MMExtText06,
									MMExtText07,
									MMExtText08,
									MMExtText09,
									MMExtText10,
									MMExtInt01,
									MMExtInt02,
									MMExtInt03,
									MMExtInt04,
									MMExtInt05,
									MMExtReal01,
									MMExtReal02,
									MMExtReal03,
									MMExtReal04,
									MMExtReal05,
									MMExtLongText01,
									MMExtLongText02,
									MMExtLongText03,
									MMExtLongText04,
									MMExtLongText05,
									dbo.fnBase64ToBinary(MMExtImage01) as MMExtImage01,
									dbo.fnBase64ToBinary(MMExtImage02) as MMExtImage02,
									dbo.fnBase64ToBinary(MMExtImage03) as MMExtImage03,
									dbo.fnBase64ToBinary(MMExtImage04) as MMExtImage04,
									dbo.fnBase64ToBinary(MMExtImage05) as MMExtImage05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AltMaterialCode,
									BasicPackingQty,
									MaterialPurchaseType,
									MaxProdPlanQty,
									DelegateMaterialCode,
									BasicRoutingCode,
									BefModelCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialName NVARCHAR(100),
											 MaterialNameL NVARCHAR(100),
											 MaterialTypeCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 MaterialUnit VARCHAR(10),
											 BasicGrQty NUMERIC(20,5),
											 MaterialSpec NVARCHAR(MAX),
											 MaterialSpecL NVARCHAR(MAX),
											 MaterialSource NVARCHAR(50),
											 MaterialThickness NVARCHAR(20),
											 AvgGrDay INT,
											 IsDelegate BIT,
											 IsInternalProd BIT,
											 IsProdPlan BIT,
											 IsPurchase BIT,
											 IsOrder BIT,
											 IsUseFlush BIT,
											 IsUseBackFlush BIT,
											 IsClosed BIT,
											 IsRequireOqc BIT,
											 BeforeMaterialCode VARCHAR(50),
											 RequestGrDay INT,
											 BasicCostPrice NUMERIC(20,5),
											 BasicCostPriceVVT NUMERIC(20,5),
											 MMExtText01 NVARCHAR(200),
											 MMExtText02 NVARCHAR(200),
											 MMExtText03 NVARCHAR(200),
											 MMExtText04 NVARCHAR(200),
											 MMExtText05 NVARCHAR(200),
											 MMExtText06 NVARCHAR(200),
											 MMExtText07 NVARCHAR(200),
											 MMExtText08 NVARCHAR(200),
											 MMExtText09 NVARCHAR(200),
											 MMExtText10 NVARCHAR(200),
											 MMExtInt01 BIGINT,
											 MMExtInt02 BIGINT,
											 MMExtInt03 BIGINT,
											 MMExtInt04 BIGINT,
											 MMExtInt05 BIGINT,
											 MMExtReal01 NUMERIC(20,5),
											 MMExtReal02 NUMERIC(20,5),
											 MMExtReal03 NUMERIC(20,5),
											 MMExtReal04 NUMERIC(20,5),
											 MMExtReal05 NUMERIC(20,5),
											 MMExtLongText01 NVARCHAR(MAX),
											 MMExtLongText02 NVARCHAR(MAX),
											 MMExtLongText03 NVARCHAR(MAX),
											 MMExtLongText04 NVARCHAR(MAX),
											 MMExtLongText05 NVARCHAR(MAX),
											 MMExtImage01 NVARCHAR(MAX),
											 MMExtImage02 NVARCHAR(MAX),
											 MMExtImage03 NVARCHAR(MAX),
											 MMExtImage04 NVARCHAR(MAX),
											 MMExtImage05 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AltMaterialCode VARCHAR(50),
											 BasicPackingQty NUMERIC(20,5),
											 MaterialPurchaseType NVARCHAR(50),
											 MaxProdPlanQty NUMERIC(20,5),
											 DelegateMaterialCode VARCHAR(50),
											 BasicRoutingCode VARCHAR(20),
											 BefModelCode NVARCHAR(200)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									MaterialCode,
									MaterialName,
									MaterialNameL,
									MaterialTypeCode,
									ProductGroupCode,
									MaterialUnit,
									BasicGrQty,
									MaterialSpec,
									MaterialSpecL,
									MaterialSource,
									MaterialThickness,
									AvgGrDay,
									IsDelegate,
									IsInternalProd,
									IsProdPlan,
									IsPurchase,
									IsOrder,
									IsUseFlush,
									IsUseBackFlush,
									IsClosed,
									IsRequireOqc,
									BeforeMaterialCode,
									RequestGrDay,
									BasicCostPrice,
									BasicCostPriceVVT,
									MMExtText01,
									MMExtText02,
									MMExtText03,
									MMExtText04,
									MMExtText05,
									MMExtText06,
									MMExtText07,
									MMExtText08,
									MMExtText09,
									MMExtText10,
									MMExtInt01,
									MMExtInt02,
									MMExtInt03,
									MMExtInt04,
									MMExtInt05,
									MMExtReal01,
									MMExtReal02,
									MMExtReal03,
									MMExtReal04,
									MMExtReal05,
									MMExtLongText01,
									MMExtLongText02,
									MMExtLongText03,
									MMExtLongText04,
									MMExtLongText05,
									dbo.fnBase64ToBinary(MMExtImage01) as MMExtImage01,
									dbo.fnBase64ToBinary(MMExtImage02) as MMExtImage02,
									dbo.fnBase64ToBinary(MMExtImage03) as MMExtImage03,
									dbo.fnBase64ToBinary(MMExtImage04) as MMExtImage04,
									dbo.fnBase64ToBinary(MMExtImage05) as MMExtImage05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AltMaterialCode,
									BasicPackingQty,
									MaterialPurchaseType,
									MaxProdPlanQty,
									DelegateMaterialCode,
									BasicRoutingCode,
									BefModelCode

							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialName NVARCHAR(100),
											 MaterialNameL NVARCHAR(100),
											 MaterialTypeCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 MaterialUnit VARCHAR(10),
											 BasicGrQty NUMERIC(20,5),
											 MaterialSpec NVARCHAR(MAX),
											 MaterialSpecL NVARCHAR(MAX),
											 MaterialSource NVARCHAR(50),
											 MaterialThickness NVARCHAR(20),
											 AvgGrDay INT,
											 IsDelegate BIT,
											 IsInternalProd BIT,
											 IsProdPlan BIT,
											 IsPurchase BIT,
											 IsOrder BIT,
											 IsUseFlush BIT,
											 IsUseBackFlush BIT,
											 IsClosed BIT,
											 IsRequireOqc BIT,
											 BeforeMaterialCode VARCHAR(50),
											 RequestGrDay INT,
											 BasicCostPrice NUMERIC(20,5),
											 BasicCostPriceVVT NUMERIC(20,5),
											 MMExtText01 NVARCHAR(200),
											 MMExtText02 NVARCHAR(200),
											 MMExtText03 NVARCHAR(200),
											 MMExtText04 NVARCHAR(200),
											 MMExtText05 NVARCHAR(200),
											 MMExtText06 NVARCHAR(200),
											 MMExtText07 NVARCHAR(200),
											 MMExtText08 NVARCHAR(200),
											 MMExtText09 NVARCHAR(200),
											 MMExtText10 NVARCHAR(200),
											 MMExtInt01 BIGINT,
											 MMExtInt02 BIGINT,
											 MMExtInt03 BIGINT,
											 MMExtInt04 BIGINT,
											 MMExtInt05 BIGINT,
											 MMExtReal01 NUMERIC(20,5),
											 MMExtReal02 NUMERIC(20,5),
											 MMExtReal03 NUMERIC(20,5),
											 MMExtReal04 NUMERIC(20,5),
											 MMExtReal05 NUMERIC(20,5),
											 MMExtLongText01 NVARCHAR(MAX),
											 MMExtLongText02 NVARCHAR(MAX),
											 MMExtLongText03 NVARCHAR(MAX),
											 MMExtLongText04 NVARCHAR(MAX),
											 MMExtLongText05 NVARCHAR(MAX),
											 MMExtImage01 NVARCHAR(MAX),
											 MMExtImage02 NVARCHAR(MAX),
											 MMExtImage03 NVARCHAR(MAX),
											 MMExtImage04 NVARCHAR(MAX),
											 MMExtImage05 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AltMaterialCode VARCHAR(50),
											 BasicPackingQty NUMERIC(20,5),
											 MaterialPurchaseType NVARCHAR(50),
											 MaxProdPlanQty NUMERIC(20,5),
											 DelegateMaterialCode VARCHAR(50),
											 BasicRoutingCode VARCHAR(20),
											 BefModelCode NVARCHAR(200)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									MaterialCode,
									MaterialName,
									MaterialNameL,
									MaterialTypeCode,
									ProductGroupCode,
									MaterialUnit,
									BasicGrQty,
									MaterialSpec,
									MaterialSpecL,
									MaterialSource,
									MaterialThickness,
									AvgGrDay,
									IsDelegate,
									IsInternalProd,
									IsProdPlan,
									IsPurchase,
									IsOrder,
									IsUseFlush,
									IsUseBackFlush,
									IsClosed,
									IsRequireOqc,
									BeforeMaterialCode,
									RequestGrDay,
									BasicCostPrice,
									BasicCostPriceVVT,
									MMExtText01,
									MMExtText02,
									MMExtText03,
									MMExtText04,
									MMExtText05,
									MMExtText06,
									MMExtText07,
									MMExtText08,
									MMExtText09,
									MMExtText10,
									MMExtInt01,
									MMExtInt02,
									MMExtInt03,
									MMExtInt04,
									MMExtInt05,
									MMExtReal01,
									MMExtReal02,
									MMExtReal03,
									MMExtReal04,
									MMExtReal05,
									MMExtLongText01,
									MMExtLongText02,
									MMExtLongText03,
									MMExtLongText04,
									MMExtLongText05,
									dbo.fnBase64ToBinary(MMExtImage01) as MMExtImage01,
									dbo.fnBase64ToBinary(MMExtImage02) as MMExtImage02,
									dbo.fnBase64ToBinary(MMExtImage03) as MMExtImage03,
									dbo.fnBase64ToBinary(MMExtImage04) as MMExtImage04,
									dbo.fnBase64ToBinary(MMExtImage05) as MMExtImage05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AltMaterialCode,
									BasicPackingQty,
									MaterialPurchaseType,
									MaxProdPlanQty,
									DelegateMaterialCode,
									BasicRoutingCode,
									BefModelCode

							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialName NVARCHAR(100),
											 MaterialNameL NVARCHAR(100),
											 MaterialTypeCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 MaterialUnit VARCHAR(10),
											 BasicGrQty NUMERIC(20,5),
											 MaterialSpec NVARCHAR(MAX),
											 MaterialSpecL NVARCHAR(MAX),
											 MaterialSource NVARCHAR(50),
											 MaterialThickness NVARCHAR(20),
											 AvgGrDay INT,
											 IsDelegate BIT,
											 IsInternalProd BIT,
											 IsProdPlan BIT,
											 IsPurchase BIT,
											 IsOrder BIT,
											 IsUseFlush BIT,
											 IsUseBackFlush BIT,
											 IsClosed BIT,
											 IsRequireOqc BIT,
											 BeforeMaterialCode VARCHAR(50),
											 RequestGrDay INT,
											 BasicCostPrice NUMERIC(20,5),
											 BasicCostPriceVVT NUMERIC(20,5),
											 MMExtText01 NVARCHAR(200),
											 MMExtText02 NVARCHAR(200),
											 MMExtText03 NVARCHAR(200),
											 MMExtText04 NVARCHAR(200),
											 MMExtText05 NVARCHAR(200),
											 MMExtText06 NVARCHAR(200),
											 MMExtText07 NVARCHAR(200),
											 MMExtText08 NVARCHAR(200),
											 MMExtText09 NVARCHAR(200),
											 MMExtText10 NVARCHAR(200),
											 MMExtInt01 BIGINT,
											 MMExtInt02 BIGINT,
											 MMExtInt03 BIGINT,
											 MMExtInt04 BIGINT,
											 MMExtInt05 BIGINT,
											 MMExtReal01 NUMERIC(20,5),
											 MMExtReal02 NUMERIC(20,5),
											 MMExtReal03 NUMERIC(20,5),
											 MMExtReal04 NUMERIC(20,5),
											 MMExtReal05 NUMERIC(20,5),
											 MMExtLongText01 NVARCHAR(MAX),
											 MMExtLongText02 NVARCHAR(MAX),
											 MMExtLongText03 NVARCHAR(MAX),
											 MMExtLongText04 NVARCHAR(MAX),
											 MMExtLongText05 NVARCHAR(MAX),
											 MMExtImage01 NVARCHAR(MAX),
											 MMExtImage02 NVARCHAR(MAX),
											 MMExtImage03 NVARCHAR(MAX),
											 MMExtImage04 NVARCHAR(MAX),
											 MMExtImage05 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AltMaterialCode VARCHAR(50),
											 BasicPackingQty NUMERIC(20,5),
											 MaterialPurchaseType NVARCHAR(50),
											 MaxProdPlanQty NUMERIC(20,5),
											 DelegateMaterialCode VARCHAR(50),
											 BasicRoutingCode VARCHAR(20),
											 BefModelCode NVARCHAR(200)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @MaterialCode,
								 @MaterialName,
								 @MaterialNameL,
								 @MaterialTypeCode,
								 @ProductGroupCode,
								 @MaterialUnit,
								 @BasicGrQty,
								 @MaterialSpec,
								 @MaterialSpecL,
								 @MaterialSource,
								 @MaterialThickness,
								 @AvgGrDay,
								 @IsDelegate,
								 @IsInternalProd,
								 @IsProdPlan,
								 @IsPurchase,
								 @IsOrder,
								 @IsUseFlush,
								 @IsUseBackFlush,
								 @IsClosed,
								 @IsRequireOqc,
								 @BeforeMaterialCode,
								 @RequestGrDay,
								 @BasicCostPrice,
								 @BasicCostPriceVVT,
								 @MMExtText01,
								 @MMExtText02,
								 @MMExtText03,
								 @MMExtText04,
								 @MMExtText05,
								 @MMExtText06,
								 @MMExtText07,
								 @MMExtText08,
								 @MMExtText09,
								 @MMExtText10,
								 @MMExtInt01,
								 @MMExtInt02,
								 @MMExtInt03,
								 @MMExtInt04,
								 @MMExtInt05,
								 @MMExtReal01,
								 @MMExtReal02,
								 @MMExtReal03,
								 @MMExtReal04,
								 @MMExtReal05,
								 @MMExtLongText01,
								 @MMExtLongText02,
								 @MMExtLongText03,
								 @MMExtLongText04,
								 @MMExtLongText05,
								 @MMExtImage01,
								 @MMExtImage02,
								 @MMExtImage03,
								 @MMExtImage04,
								 @MMExtImage05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @AltMaterialCode,
								 @BasicPackingQty,
								 @MaterialPurchaseType,
								 @MaxProdPlanQty,
								 @DelegateMaterialCode,
								 @BasicRoutingCode,
								 @BefModelCode



                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialMaster WHERE MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialMaster', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialMaster
						(
						    MaterialCode,
						    MaterialName,
						    MaterialNameL,
						    MaterialTypeCode,
						    ProductGroupCode,
						    MaterialUnit,
						    BasicGrQty,
						    MaterialSpec,
						    MaterialSpecL,
						    MaterialSource,
						    MaterialThickness,
						    AvgGrDay,
						    IsDelegate,
						    IsInternalProd,
							IsProdPlan,
						    IsPurchase,
						    IsOrder,
							IsUseFlush,
							IsUseBackFlush,
						    IsClosed,
							IsRequireOqc,
						    BeforeMaterialCode,
							RequestGrDay,
							BasicCostPrice,
							BasicCostPriceVVT,
						    MMExtText01,
						    MMExtText02,
						    MMExtText03,
						    MMExtText04,
						    MMExtText05,
						    MMExtText06,
						    MMExtText07,
						    MMExtText08,
						    MMExtText09,
						    MMExtText10,
						    MMExtInt01,
						    MMExtInt02,
						    MMExtInt03,
						    MMExtInt04,
						    MMExtInt05,
						    MMExtReal01,
						    MMExtReal02,
						    MMExtReal03,
						    MMExtReal04,
						    MMExtReal05,
						    MMExtLongText01,
						    MMExtLongText02,
						    MMExtLongText03,
						    MMExtLongText04,
						    MMExtLongText05,
						    MMExtImage01,
						    MMExtImage02,
						    MMExtImage03,
						    MMExtImage04,
						    MMExtImage05,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							AltMaterialCode,
							BasicPackingQty,
							MaterialPurchaseType,
							MaxProdPlanQty,
							DelegateMaterialCode,
							BasicRoutingCode,
							BefModelCode
						)
						VALUES
						(
						    @MaterialCode,
						    @MaterialName,
						    @MaterialNameL,
						    @MaterialTypeCode,
						    ISNULL(@ProductGroupCode,''),
						    @MaterialUnit,
						    @BasicGrQty,
						    @MaterialSpec,
						    @MaterialSpecL,
						    @MaterialSource,
						    @MaterialThickness,
						    @AvgGrDay,
						    @IsDelegate,
						    @IsInternalProd,
							@IsProdPlan,
						    @IsPurchase,
						    @IsOrder,
							@IsUseFlush,
							@IsUseBackFlush,
						    @IsClosed,
							@IsRequireOqc,
						    @BeforeMaterialCode,
							@RequestGrDay,
							@BasicCostPrice,
							@BasicCostPriceVVT,
						    @MMExtText01,
						    @MMExtText02,
						    @MMExtText03,
						    @MMExtText04,
						    @MMExtText05,
						    @MMExtText06,
						    @MMExtText07,
						    @MMExtText08,
						    @MMExtText09,
						    @MMExtText10,
						    @MMExtInt01,
						    @MMExtInt02,
						    @MMExtInt03,
						    @MMExtInt04,
						    @MMExtInt05,
						    @MMExtReal01,
						    @MMExtReal02,
						    @MMExtReal03,
						    @MMExtReal04,
						    @MMExtReal05,
						    @MMExtLongText01,
						    @MMExtLongText02,
						    @MMExtLongText03,
						    @MMExtLongText04,
						    @MMExtLongText05,
						    @MMExtImage01,
						    @MMExtImage02,
						    @MMExtImage03,
						    @MMExtImage04,
						    @MMExtImage05,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@AltMaterialCode,
							@BasicPackingQty,
							@MaterialPurchaseType,
							@MaxProdPlanQty,
							@DelegateMaterialCode,
							@BasicRoutingCode,
							@BefModelCode
						)


						MERGE STB_MaterialStockAttributeInfo MSAI
						USING
								(
									SELECT 
											@MaterialCode AS MaterialCode
								) AS SourceTable
						ON (SourceTable.MaterialCode = MSAI.MaterialCode)
						WHEN NOT MATCHED THEN
							INSERT
								(
									MaterialCode,
									IsUseBarcode,
									IsLotUse,
									IsVendorLotUse,
									IsUseVendorBarcode,
									IsLifetimeUse,
									IsFIFO,
									SaftyStock,
									CreateDateTime,
									CreateUserID
								)
							VALUES
								(
										SourceTable.MaterialCode,
										CASE WHEN @IsUseBarcode = 'Y' THEN 1 ELSE 0 END,
										CASE WHEN @IsLotUse = 'Y' THEN 1 ELSE 0 END,
										CASE WHEN @IsUseVendorLot = 'Y' THEN 1 ELSE 0 END,
										CASE WHEN @IsUseVendorBarcode = 'Y' THEN 1 ELSE 0 END,
										CASE WHEN @IsLifetimeUse = 'Y' THEN 1 ELSE 0 END,
										CASE WHEN @IsFIFO = 'Y' THEN 1 ELSE 0 END,
										0,
										GETDATE(),
										@pProcessUserID
								);



						--INSERT INTO STB_AltMaterialMaster
						--		(AltMaterialCode, MaterialCode)
						--SELECT
						--		ALT.Item AS AltMaterialCode,
						--		@MaterialCode AS MaterialCode
						--FROM	
						--		dbo.fnSplitToTable(',', @AltMaterialCode) ALT

						-- ERP 인터페이스
						--EXEC usp_MaterialMaster_interface @MaterialCode, @IUD_FLAG
				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialMaster
						SET
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,
						    MaterialNameL =   CASE
						                WHEN @MaterialNameL IS NOT NULL THEN @MaterialNameL
						                ELSE MaterialNameL
						            END,
						    MaterialTypeCode =   CASE
						                WHEN @MaterialTypeCode IS NOT NULL THEN @MaterialTypeCode
						                ELSE MaterialTypeCode
						            END,
						    ProductGroupCode =   CASE
						                WHEN @ProductGroupCode IS NOT NULL THEN @ProductGroupCode
						                ELSE ProductGroupCode
						            END,
						    MaterialUnit =   CASE
						                WHEN @MaterialUnit IS NOT NULL THEN @MaterialUnit
						                ELSE MaterialUnit
						            END,
						    BasicGrQty =   CASE
						                WHEN @BasicGrQty IS NOT NULL THEN @BasicGrQty
						                ELSE BasicGrQty
						            END,
						    MaterialSpec =   CASE
						                WHEN @MaterialSpec IS NOT NULL THEN @MaterialSpec
						                ELSE MaterialSpec
						            END,
						    MaterialSpecL =   CASE
						                WHEN @MaterialSpecL IS NOT NULL THEN @MaterialSpecL
						                ELSE MaterialSpecL
						            END,
						    MaterialSource =   CASE
						                WHEN @MaterialSource IS NOT NULL THEN @MaterialSource
						                ELSE MaterialSource
						            END,
						    MaterialThickness =   CASE
						                WHEN @MaterialThickness IS NOT NULL THEN @MaterialThickness
						                ELSE MaterialThickness
						            END,
						    AvgGrDay =   CASE
						                WHEN @AvgGrDay IS NOT NULL THEN @AvgGrDay
						                ELSE AvgGrDay
						            END,
						    IsDelegate =   CASE
						                WHEN @IsDelegate IS NOT NULL THEN @IsDelegate
						                ELSE IsDelegate
						            END,
						    IsInternalProd =   CASE
						                WHEN @IsInternalProd IS NOT NULL THEN @IsInternalProd
						                ELSE IsInternalProd
						            END,
							IsProdPlan =    CASE
						                WHEN @IsProdPlan IS NOT NULL THEN @IsProdPlan
						                ELSE IsProdPlan
						            END,
						    IsPurchase =   CASE
						                WHEN @IsPurchase IS NOT NULL THEN @IsPurchase
						                ELSE IsPurchase
						            END,
						    IsOrder =   CASE
						                WHEN @IsOrder IS NOT NULL THEN @IsOrder
						                ELSE IsOrder
						            END,
							IsUseFlush = CASE
										WHEN @IsUseFlush IS NOT NULL THEN @IsUseFlush
										ELSE IsUseFlush 
									END,
							IsUseBackFlush = CASE
										WHEN @IsUseBackFlush IS NOT NULL THEN @IsUseBackFlush
										ELSE IsUseBackFlush
									END,
						    IsClosed =   CASE
						                WHEN @IsClosed IS NOT NULL THEN @IsClosed
						                ELSE IsClosed
						            END,
							IsRequireOqc = CASE
											WHEN @IsRequireOqc IS NOT NULL THEN @IsRequireOqc
											ELSE IsRequireOqc
									END,
						    BeforeMaterialCode =   CASE
						                WHEN @BeforeMaterialCode IS NOT NULL THEN @BeforeMaterialCode
						                ELSE BeforeMaterialCode
						            END,
						    RequestGrDay =   CASE
						                WHEN @RequestGrDay IS NOT NULL THEN @RequestGrDay
						                ELSE RequestGrDay
									END,
							BasicCostPrice =	CASE
										WHEN  @BasicCostPrice IS NOT NULL THEN @BasicCostPrice
										ELSE BasicCostPrice
						            END,
							BasicCostPriceVVT =	CASE
										WHEN  @BasicCostPriceVVT IS NOT NULL THEN @BasicCostPriceVVT
										ELSE BasicCostPriceVVT
						            END,
						    MMExtText01 =   CASE
						                WHEN @MMExtText01 IS NOT NULL THEN @MMExtText01
						                ELSE MMExtText01
						            END,
						    MMExtText02 =   CASE
						                WHEN @MMExtText02 IS NOT NULL THEN @MMExtText02
						                ELSE MMExtText02
						            END,
						    MMExtText03 =   CASE
						                WHEN @MMExtText03 IS NOT NULL THEN @MMExtText03
						                ELSE MMExtText03
						            END,
						    MMExtText04 =   CASE
						                WHEN @MMExtText04 IS NOT NULL THEN @MMExtText04
						                ELSE MMExtText04
						            END,
						    MMExtText05 =   CASE
						                WHEN @MMExtText05 IS NOT NULL THEN @MMExtText05
						                ELSE MMExtText05
						            END,
						    MMExtText06 =   CASE
						                WHEN @MMExtText06 IS NOT NULL THEN @MMExtText06
						                ELSE MMExtText06
						            END,
						    MMExtText07 =   CASE
						                WHEN @MMExtText07 IS NOT NULL THEN @MMExtText07
						                ELSE MMExtText07
						            END,
						    MMExtText08 =   CASE
						                WHEN @MMExtText08 IS NOT NULL THEN @MMExtText08
						                ELSE MMExtText08
						            END,
						    MMExtText09 =   CASE
						                WHEN @MMExtText09 IS NOT NULL THEN @MMExtText09
						                ELSE MMExtText09
						            END,
						    MMExtText10 =   CASE
						                WHEN @MMExtText10 IS NOT NULL THEN @MMExtText10
						                ELSE MMExtText10
						            END,
						    MMExtInt01 =   CASE
						                WHEN @MMExtInt01 IS NOT NULL THEN @MMExtInt01
						                ELSE MMExtInt01
						            END,
						    MMExtInt02 =   CASE
						                WHEN @MMExtInt02 IS NOT NULL THEN @MMExtInt02
						                ELSE MMExtInt02
						            END,
						    MMExtInt03 =   CASE
						                WHEN @MMExtInt03 IS NOT NULL THEN @MMExtInt03
						                ELSE MMExtInt03
						            END,
						    MMExtInt04 =   CASE
						                WHEN @MMExtInt04 IS NOT NULL THEN @MMExtInt04
						                ELSE MMExtInt04
						            END,
						    MMExtInt05 =   CASE
						                WHEN @MMExtInt05 IS NOT NULL THEN @MMExtInt05
						                ELSE MMExtInt05
						            END,
						    MMExtReal01 =   CASE
						                WHEN @MMExtReal01 IS NOT NULL THEN @MMExtReal01
						                ELSE MMExtReal01
						            END,
						    MMExtReal02 =   CASE
						                WHEN @MMExtReal02 IS NOT NULL THEN @MMExtReal02
						                ELSE MMExtReal02
						            END,
						    MMExtReal03 =   CASE
						                WHEN @MMExtReal03 IS NOT NULL THEN @MMExtReal03
						                ELSE MMExtReal03
						            END,
						    MMExtReal04 =   CASE
						                WHEN @MMExtReal04 IS NOT NULL THEN @MMExtReal04
						                ELSE MMExtReal04
						            END,
						    MMExtReal05 =   CASE
						                WHEN @MMExtReal05 IS NOT NULL THEN @MMExtReal05
						                ELSE MMExtReal05
						            END,
						    MMExtLongText01 =   CASE
						                WHEN @MMExtLongText01 IS NOT NULL THEN @MMExtLongText01
						                ELSE MMExtLongText01
						            END,
						    MMExtLongText02 =   CASE
						                WHEN @MMExtLongText02 IS NOT NULL THEN @MMExtLongText02
						                ELSE MMExtLongText02
						            END,
						    MMExtLongText03 =   CASE
						                WHEN @MMExtLongText03 IS NOT NULL THEN @MMExtLongText03
						                ELSE MMExtLongText03
						            END,
						    MMExtLongText04 =   CASE
						                WHEN @MMExtLongText04 IS NOT NULL THEN @MMExtLongText04
						                ELSE MMExtLongText04
						            END,
						    MMExtLongText05 =   CASE
						                WHEN @MMExtLongText05 IS NOT NULL THEN @MMExtLongText05
						                ELSE MMExtLongText05
						            END,
						    MMExtImage01 =   CASE
						                WHEN @MMExtImage01 IS NOT NULL THEN @MMExtImage01
						                ELSE MMExtImage01
						            END,
						    MMExtImage02 =   CASE
						                WHEN @MMExtImage02 IS NOT NULL THEN @MMExtImage02
						                ELSE MMExtImage02
						            END,
						    MMExtImage03 =   CASE
						                WHEN @MMExtImage03 IS NOT NULL THEN @MMExtImage03
						                ELSE MMExtImage03
						            END,
						    MMExtImage04 =   CASE
						                WHEN @MMExtImage04 IS NOT NULL THEN @MMExtImage04
						                ELSE MMExtImage04
						            END,
						    MMExtImage05 =   CASE
						                WHEN @MMExtImage05 IS NOT NULL THEN @MMExtImage05
						                ELSE MMExtImage05
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							AltMaterialCode = CASE
										WHEN @AltMaterialCode IS NOT NULL THEN @AltMaterialCode
										ELSE AltMaterialCode
									END,
							BasicPackingQty = CASE
										WHEN @BasicPackingQty IS NOT NULL THEN @BasicPackingQty
										ELSE BasicPackingQty
									END,
							MaterialPurchaseType = CASE
										WHEN @MaterialPurchaseType IS NOT NULL THEN @MaterialPurchaseType
										ELSE MaterialPurchaseType
									END,
							MaxProdPlanQty = CASE
										WHEN @MaxProdPlanQty IS NOT NULL THEN @MaxProdPlanQty
										ELSE MaxProdPlanQty
									END,
							DelegateMaterialCode = CASE	
										WHEN @DelegateMaterialCode IS NOT NULL THEN @DelegateMaterialCode
										ELSE DelegateMaterialCode
									END,
							BasicRoutingCode = CASE
										WHEN @BasicRoutingCode IS NOT NULL THEN @BasicRoutingCode
										ELSE BasicRoutingCode
									END,
							BefModelCode = CASE
									WHEN @BefModelCode IS NOT NULL THEN @BefModelCode
									ELSE BefModelCode
								END
						WHERE
						    MaterialCode = @OldMaterialCode


						--DELETE FROM STB_AltMaterialMaster
						--WHERE
						--		MaterialCode = @MaterialCode

						--INSERT INTO STB_AltMaterialMaster
						--		(AltMaterialCode, MaterialCode)
						--SELECT
						--		ALT.Item AS AltMaterialCode,
						--		@MaterialCode AS MaterialCode
						--FROM	
						--		dbo.fnSplitToTable(',', @AltMaterialCode) ALT
						-- ERP 인터페이스
						--EXEC usp_MaterialMaster_interface @MaterialCode, @IUD_FLAG
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialMaster
						WHERE
						    MaterialCode = @MaterialCode

					--DELETE FROM STB_AltMaterialMaster
					--WHERE
					--		MaterialCode = @MaterialCode
					-- ERP 인터페이스
					--EXEC usp_MaterialMaster_interface @MaterialCode, @IUD_FLAG
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	

END
