

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 자재관리
-- Description:	업체별 자재공급정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialVendorMapping_iud]
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
  DECLARE @OldCustomerCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @AQL VARCHAR(10)
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @InspectionType VARCHAR(20)
  DECLARE @UnitPriceQty NUMERIC(20,5)
  DECLARE @UnitPrice NUMERIC(20,5)
  DECLARE @BasicDeliveryDay INT
  DECLARE @MVMExtText01 VARCHAR(50)
  DECLARE @MVMExtText02 VARCHAR(50)
  DECLARE @MVMExtText03 VARCHAR(50)
  DECLARE @MVMExtText04 VARCHAR(50)
  DECLARE @MVMExtText05 VARCHAR(50)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialVendorMapping',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialVendorMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldCustomerCode IS NULL THEN ISNULL(XMLData.CustomerCode,'')
							    ELSE XMLData.OldCustomerCode
							END AS OldCustomerCode,
							XMLData.MaterialCode,
							ISNULL(XMLData.CustomerCode,'') AS CustomerCode,
							XMLData.InspectionType,
							XMLData.AQL,
							XMLData.InspectionLevel,
							XMLData.UnitPriceQty,
							XMLData.UnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.MVMExtText01,
							XMLData.MVMExtText02,
							XMLData.MVMExtText03,
							XMLData.MVMExtText04,
							XMLData.MVMExtText05,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldCustomerCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										CustomerCode VARCHAR(20),
										InspectionType VARCHAR(20),
										AQL VARCHAR(10),
										InspectionLevel VARCHAR(20),
										UnitPriceQty NUMERIC(20,5),
										UnitPrice NUMERIC(20,5),
										BasicDeliveryDay INT,
										MVMExtText01 VARCHAR(50),
										MVMExtText02 VARCHAR(50),
										MVMExtText03 VARCHAR(50),
										MVMExtText04 VARCHAR(50),
										MVMExtText05 VARCHAR(50),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CustomerCode = SourceTable.CustomerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					CustomerCode = SourceTable.CustomerCode,
					InspectionType = SourceTable.InspectionType,
					AQL = SourceTable.AQL,
					InspectionLevel = SourceTable.InspectionLevel,
					UnitPriceQty = SourceTable.UnitPriceQty,
					UnitPrice = SourceTable.UnitPrice,
					BasicDeliveryDay = SourceTable.BasicDeliveryDay,
					MVMExtText01 = SourceTable.MVMExtText01,
					MVMExtText02 = SourceTable.MVMExtText02,
					MVMExtText03 = SourceTable.MVMExtText03,
					MVMExtText04 = SourceTable.MVMExtText04,
					MVMExtText05 = SourceTable.MVMExtText05,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						CustomerCode,
						InspectionType,
						AQL,
						InspectionLevel,
						UnitPriceQty,
						UnitPrice,
						BasicDeliveryDay,
						MVMExtText01,
						MVMExtText02,
						MVMExtText03,
						MVMExtText04,
						MVMExtText05,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.CustomerCode,
							SourceTable.InspectionType,
							SourceTable.AQL,
							SourceTable.InspectionLevel,
							SourceTable.UnitPriceQty,
							SourceTable.UnitPrice,
							SourceTable.BasicDeliveryDay,
							SourceTable.MVMExtText01,
							SourceTable.MVMExtText02,
							SourceTable.MVMExtText03,
							SourceTable.MVMExtText04,
							SourceTable.MVMExtText05,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
			
			DECLARE @MaterialVendorMapping TABLE
			(
				MaterialCode VARCHAR(50),
				CustomerCode VARCHAR(20)
			)
			
			
			
            MERGE STB_MaterialVendorMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldCustomerCode IS NULL THEN ISNULL(XMLData.CustomerCode,'')
							    ELSE XMLData.OldCustomerCode
							END AS OldCustomerCode,
							XMLData.MaterialCode,
							ISNULL(XMLData.CustomerCode,'') AS CustomerCode,
							XMLData.InspectionType,
							XMLData.AQL,
							XMLData.InspectionLevel,
							XMLData.UnitPriceQty,
							XMLData.UnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.MVMExtText01,
							XMLData.MVMExtText02,
							XMLData.MVMExtText03,
							XMLData.MVMExtText04,
							XMLData.MVMExtText05,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldCustomerCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										CustomerCode VARCHAR(20),
										InspectionType VARCHAR(20),
										AQL VARCHAR(10),
										InspectionLevel VARCHAR(20),
										UnitPriceQty NUMERIC(20,5),
										UnitPrice NUMERIC(20,5),
										BasicDeliveryDay INT,
										MVMExtText01 VARCHAR(50),
										MVMExtText02 VARCHAR(50),
										MVMExtText03 VARCHAR(50),
										MVMExtText04 VARCHAR(50),
										MVMExtText05 VARCHAR(50),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.CustomerCode = SourceTable.OldCustomerCode
				)

			WHEN MATCHED THEN
			
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					CustomerCode = SourceTable.CustomerCode,
					InspectionType = SourceTable.InspectionType,
					AQL = SourceTable.AQL,
					InspectionLevel = SourceTable.InspectionLevel,
					UnitPriceQty = SourceTable.UnitPriceQty,
					UnitPrice = SourceTable.UnitPrice,
					BasicDeliveryDay = SourceTable.BasicDeliveryDay,
					MVMExtText01 = SourceTable.MVMExtText01,
					MVMExtText02 = SourceTable.MVMExtText02,
					MVMExtText03 = SourceTable.MVMExtText03,
					MVMExtText04 = SourceTable.MVMExtText04,
					MVMExtText05 = SourceTable.MVMExtText05,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
			
				
				
				
				INSERT
					(
						MaterialCode,
						CustomerCode,
						InspectionType,
						AQL,
						InspectionLevel,
						UnitPriceQty,
						UnitPrice,
						BasicDeliveryDay,
						MVMExtText01,
						MVMExtText02,
						MVMExtText03,
						MVMExtText04,
						MVMExtText05,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.CustomerCode,
							SourceTable.InspectionType,
							SourceTable.AQL,
							SourceTable.InspectionLevel,
							SourceTable.UnitPriceQty,
							SourceTable.UnitPrice,
							SourceTable.BasicDeliveryDay,
							SourceTable.MVMExtText01,
							SourceTable.MVMExtText02,
							SourceTable.MVMExtText03,
							SourceTable.MVMExtText04,
							SourceTable.MVMExtText05,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
					
			-- Process Delete Table
            MERGE STB_MaterialVendorMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldCustomerCode IS NULL THEN ISNULL(XMLData.CustomerCode,'')
							    ELSE XMLData.OldCustomerCode
							END AS OldCustomerCode,
							XMLData.MaterialCode,
							ISNULL(XMLData.CustomerCode,'') AS CustomerCode,
							XMLData.InspectionType,
							XMLData.AQL,
							XMLData.InspectionLevel,
							XMLData.UnitPriceQty,
							XMLData.UnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.MVMExtText01,
							XMLData.MVMExtText02,
							XMLData.MVMExtText03,
							XMLData.MVMExtText04,
							XMLData.MVMExtText05,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldCustomerCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										CustomerCode VARCHAR(20),
										InspectionType VARCHAR(20),
										AQL VARCHAR(10),
										InspectionLevel VARCHAR(20),
										UnitPriceQty NUMERIC(20,5),
										UnitPrice NUMERIC(20,5),
										BasicDeliveryDay INT,
										MVMExtText01 VARCHAR(50),
										MVMExtText02 VARCHAR(50),
										MVMExtText03 VARCHAR(50),
										MVMExtText04 VARCHAR(50),
										MVMExtText05 VARCHAR(50),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CustomerCode = SourceTable.CustomerCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMaterialCode,
									XMLData.OldCustomerCode,
									XMLData.MaterialCode,
									XMLData.CustomerCode,
									XMLData.InspectionType,
									XMLData.AQL,
									XMLData.InspectionLevel,
									XMLData.UnitPriceQty,
									XMLData.UnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.MVMExtText01,
									XMLData.MVMExtText02,
									XMLData.MVMExtText03,
									XMLData.MVMExtText04,
									XMLData.MVMExtText05,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldCustomerCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CustomerCode VARCHAR(20),
											 InspectionType VARCHAR(20),
											 AQL VARCHAR(10),
											 InspectionLevel VARCHAR(20),
											 UnitPriceQty NUMERIC(20,5),
											 UnitPrice NUMERIC(20,5),
											 BasicDeliveryDay INT,
											 MVMExtText01 VARCHAR(50),
											 MVMExtText02 VARCHAR(50),
											 MVMExtText03 VARCHAR(50),
											 MVMExtText04 VARCHAR(50),
											 MVMExtText05 VARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldCustomerCode IS NULL THEN XMLData.CustomerCode
										ELSE XMLData.OldCustomerCode
									END AS OldCustomerCode,
									XMLData.MaterialCode,
									XMLData.CustomerCode,
									XMLData.InspectionType,
									XMLData.AQL,
									XMLData.InspectionLevel,
									XMLData.UnitPriceQty,
									XMLData.UnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.MVMExtText01,
									XMLData.MVMExtText02,
									XMLData.MVMExtText03,
									XMLData.MVMExtText04,
									XMLData.MVMExtText05,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldCustomerCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CustomerCode VARCHAR(20),
											 InspectionType VARCHAR(20),
											 AQL VARCHAR(10),
											 InspectionLevel VARCHAR(20),
											 UnitPriceQty NUMERIC(20,5),
											 UnitPrice NUMERIC(20,5),
											 BasicDeliveryDay INT,
											 MVMExtText01 VARCHAR(50),
											 MVMExtText02 VARCHAR(50),
											 MVMExtText03 VARCHAR(50),
											 MVMExtText04 VARCHAR(50),
											 MVMExtText05 VARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldCustomerCode IS NULL THEN XMLData.CustomerCode
										ELSE XMLData.OldCustomerCode
									END AS OldCustomerCode,
									XMLData.MaterialCode,
									XMLData.CustomerCode,
									XMLData.InspectionType,
									XMLData.AQL,
									XMLData.InspectionLevel,
									XMLData.UnitPriceQty,
									XMLData.UnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.MVMExtText01,
									XMLData.MVMExtText02,
									XMLData.MVMExtText03,
									XMLData.MVMExtText04,
									XMLData.MVMExtText05,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldCustomerCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CustomerCode VARCHAR(20),
											 InspectionType VARCHAR(20),
											 AQL VARCHAR(10),
											 InspectionLevel VARCHAR(20),
											 UnitPriceQty NUMERIC(20,5),
											 UnitPrice NUMERIC(20,5),
											 BasicDeliveryDay INT,
											 MVMExtText01 VARCHAR(50),
											 MVMExtText02 VARCHAR(50),
											 MVMExtText03 VARCHAR(50),
											 MVMExtText04 VARCHAR(50),
											 MVMExtText05 VARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldCustomerCode,
								 @MaterialCode,
								 @CustomerCode,
								 @InspectionType,
								 @AQL,
								 @InspectionLevel,
								 @UnitPriceQty,
								 @UnitPrice,
								 @BasicDeliveryDay,
								 @MVMExtText01,
								 @MVMExtText02,
								 @MVMExtText03,
								 @MVMExtText04,
								 @MVMExtText05,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialVendorMapping WHERE MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialVendorMapping', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialVendorMapping
						(
						    MaterialCode,
						    CustomerCode,
						    InspectionType,
						    AQL,
						    InspectionLevel,
						    UnitPriceQty,
						    UnitPrice,
						    BasicDeliveryDay,
							MVMExtText01,
							MVMExtText02,
							MVMExtText03,
							MVMExtText04,
							MVMExtText05,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialCode,
						    @CustomerCode,
						    @InspectionType,
						    @AQL,
						    @InspectionLevel,
						    @UnitPriceQty,
						    @UnitPrice,
						    @BasicDeliveryDay,
							@MVMExtText01,
							@MVMExtText02,
							@MVMExtText03,
							@MVMExtText04,
							@MVMExtText05,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialVendorMapping
						SET
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    CustomerCode =   CASE
						                WHEN @CustomerCode IS NOT NULL THEN @CustomerCode
						                ELSE CustomerCode
						            END,
						    InspectionType =   CASE
						                WHEN @InspectionType IS NOT NULL THEN @InspectionType
						                ELSE InspectionType
						            END,
						    AQL =   CASE
						                WHEN @AQL IS NOT NULL THEN @AQL
						                ELSE AQL
						            END,
						    InspectionLevel =   CASE
						                WHEN @InspectionLevel IS NOT NULL THEN @InspectionLevel
						                ELSE InspectionLevel
						            END,
						    UnitPriceQty =   CASE
						                WHEN @UnitPriceQty IS NOT NULL THEN @UnitPriceQty
						                ELSE UnitPriceQty
						            END,
						    UnitPrice =   CASE
						                WHEN @UnitPrice IS NOT NULL THEN @UnitPrice
						                ELSE UnitPrice
						            END,
						    BasicDeliveryDay =   CASE
						                WHEN @BasicDeliveryDay IS NOT NULL THEN @BasicDeliveryDay
						                ELSE BasicDeliveryDay
						            END,
						    MVMExtText01 =   CASE
						                WHEN @MVMExtText01 IS NOT NULL THEN @MVMExtText01
						                ELSE MVMExtText01
						            END,
						    MVMExtText02 =   CASE
						                WHEN @MVMExtText02 IS NOT NULL THEN @MVMExtText02
						                ELSE MVMExtText02
						            END,
						    MVMExtText03 =   CASE
						                WHEN @MVMExtText03 IS NOT NULL THEN @MVMExtText03
						                ELSE MVMExtText03
						            END,
						    MVMExtText04 =   CASE
						                WHEN @MVMExtText04 IS NOT NULL THEN @MVMExtText04
						                ELSE MVMExtText04
						            END,
						    MVMExtText05 =   CASE
						                WHEN @MVMExtText05 IS NOT NULL THEN @MVMExtText05
						                ELSE MVMExtText05
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
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
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    CustomerCode = @OldCustomerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialVendorMapping
						WHERE
						    MaterialCode = @MaterialCode AND
						    CustomerCode = @CustomerCode
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
END


