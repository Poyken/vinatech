
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-05-04
-- Browsable : true
-- Group : 제품관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ShipmentHist_iud
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

    -- Declare Columns Variable
  DECLARE @OldShipmentHistNo VARCHAR(20)
  DECLARE @ShipmentHistNo VARCHAR(20)
  DECLARE @ShippmentAreaCode VARCHAR(20)
  DECLARE @ShipmentDate DATE
  DECLARE @ShippingDate DATE
  DECLARE @NationCode VARCHAR(20)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @SalesTypeCode VARCHAR(20)
  DECLARE @ShipmentQty NUMERIC(20,5)
  DECLARE @GIUnitPrice NUMERIC(20,5)
  DECLARE @ExchangeRate NUMERIC(20,5)
  DECLARE @TransportTypeCode VARCHAR(20)
  DECLARE @ShippingCompanyName NVARCHAR(100)
  DECLARE @AirWayBillNo VARCHAR(100)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ShipmentHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldShipmentHistNo,
									ShipmentHistNo,
									ShippmentAreaCode,
									ShipmentDate,
									ShippingDate,
									NationCode,
									CustomerCode,
									SalesTypeCode,
									ShipmentQty,
									GIUnitPrice,
									ExchangeRate,
									TransportTypeCode,
									ShippingCompanyName,
									AirWayBillNo,
									MaterialCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldShipmentHistNo VARCHAR(20),
											 ShipmentHistNo VARCHAR(20),
											 ShippmentAreaCode VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShippingDate DATETIMEOFFSET,
											 NationCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 SalesTypeCode VARCHAR(20),
											 ShipmentQty NUMERIC(20,5),
											 GIUnitPrice NUMERIC(20,5),
											 ExchangeRate NUMERIC(20,5),
											 TransportTypeCode VARCHAR(20),
											 ShippingCompanyName NVARCHAR(100),
											 AirWayBillNo VARCHAR(100),
											 MaterialCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldShipmentHistNo IS NULL THEN ShipmentHistNo
										ELSE OldShipmentHistNo
									END AS OldShipmentHistNo,
									ShipmentHistNo,
									ShippmentAreaCode,
									ShipmentDate,
									ShippingDate,
									NationCode,
									CustomerCode,
									SalesTypeCode,
									ShipmentQty,
									GIUnitPrice,
									ExchangeRate,
									TransportTypeCode,
									ShippingCompanyName,
									AirWayBillNo,
									MaterialCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldShipmentHistNo VARCHAR(20),
											 ShipmentHistNo VARCHAR(20),
											 ShippmentAreaCode VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShippingDate DATETIMEOFFSET,
											 NationCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 SalesTypeCode VARCHAR(20),
											 ShipmentQty NUMERIC(20,5),
											 GIUnitPrice NUMERIC(20,5),
											 ExchangeRate NUMERIC(20,5),
											 TransportTypeCode VARCHAR(20),
											 ShippingCompanyName NVARCHAR(100),
											 AirWayBillNo VARCHAR(100),
											 MaterialCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldShipmentHistNo IS NULL THEN ShipmentHistNo
										ELSE OldShipmentHistNo
									END AS OldShipmentHistNo,
									ShipmentHistNo,
									ShippmentAreaCode,
									ShipmentDate,
									ShippingDate,
									NationCode,
									CustomerCode,
									SalesTypeCode,
									ShipmentQty,
									GIUnitPrice,
									ExchangeRate,
									TransportTypeCode,
									ShippingCompanyName,
									AirWayBillNo,
									MaterialCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldShipmentHistNo VARCHAR(20),
											 ShipmentHistNo VARCHAR(20),
											 ShippmentAreaCode VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShippingDate DATETIMEOFFSET,
											 NationCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 SalesTypeCode VARCHAR(20),
											 ShipmentQty NUMERIC(20,5),
											 GIUnitPrice NUMERIC(20,5),
											 ExchangeRate NUMERIC(20,5),
											 TransportTypeCode VARCHAR(20),
											 ShippingCompanyName NVARCHAR(100),
											 AirWayBillNo VARCHAR(100),
											 MaterialCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldShipmentHistNo,
								 @ShipmentHistNo,
								 @ShippmentAreaCode,
								 @ShipmentDate,
								 @ShippingDate,
								 @NationCode,
								 @CustomerCode,
								 @SalesTypeCode,
								 @ShipmentQty,
								 @GIUnitPrice,
								 @ExchangeRate,
								 @TransportTypeCode,
								 @ShippingCompanyName,
								 @AirWayBillNo,
								 @MaterialCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ShipmentHist WHERE ShipmentHistNo = @ShipmentHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ShipmentHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ShipmentHist',@ShipmentHistNo OUTPUT
                    END

                    INSERT INTO STB_ShipmentHist
						(
						    ShipmentHistNo,
						    ShippmentAreaCode,
						    ShipmentDate,
						    ShippingDate,
						    NationCode,
						    CustomerCode,
						    SalesTypeCode,
						    ShipmentQty,
						    GIUnitPrice,
						    ExchangeRate,
						    TransportTypeCode,
						    ShippingCompanyName,
						    AirWayBillNo,
						    MaterialCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ShipmentHistNo,
						    @ShippmentAreaCode,
						    @ShipmentDate,
						    @ShippingDate,
						    @NationCode,
						    @CustomerCode,
						    @SalesTypeCode,
						    @ShipmentQty,
						    @GIUnitPrice,
						    @ExchangeRate,
						    @TransportTypeCode,
						    @ShippingCompanyName,
						    @AirWayBillNo,
						    @MaterialCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ShipmentHist
						SET
						    ShipmentHistNo =   ISNULL(@ShipmentHistNo,ShipmentHistNo),
						    ShippmentAreaCode =   ISNULL(@ShippmentAreaCode,ShippmentAreaCode),
						    ShipmentDate =   ISNULL(@ShipmentDate,ShipmentDate),
						    ShippingDate =   ISNULL(@ShippingDate,ShippingDate),
						    NationCode =   ISNULL(@NationCode,NationCode),
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						    SalesTypeCode =   ISNULL(@SalesTypeCode,SalesTypeCode),
						    ShipmentQty =   ISNULL(@ShipmentQty,ShipmentQty),
						    GIUnitPrice =   ISNULL(@GIUnitPrice,GIUnitPrice),
						    ExchangeRate =   ISNULL(@ExchangeRate,ExchangeRate),
						    TransportTypeCode =   ISNULL(@TransportTypeCode,TransportTypeCode),
						    ShippingCompanyName =   ISNULL(@ShippingCompanyName,ShippingCompanyName),
						    AirWayBillNo =   ISNULL(@AirWayBillNo,AirWayBillNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ShipmentHistNo = @OldShipmentHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ShipmentHist
						WHERE
						    ShipmentHistNo = @OldShipmentHistNo
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
