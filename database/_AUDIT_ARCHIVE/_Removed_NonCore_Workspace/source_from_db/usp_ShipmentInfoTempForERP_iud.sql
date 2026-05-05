-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-12-02
-- Browsable : true
-- Group : 연습
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShipmentInfoTempForERP_iud]
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
  DECLARE @OldShipmentInfoNo BIGINT
  DECLARE @ShipmentInfoNo BIGINT
  DECLARE @MaterialWarehouseName NVARCHAR(100)
  DECLARE @ShipmentNo VARCHAR(30)
  DECLARE @ShipmentSerNo INT
  DECLARE @ShipmentDate DATE
  DECLARE @ShipmentClassName NVARCHAR(20)
  DECLARE @CustomerName NVARCHAR(100)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @MaterialName NVARCHAR(200)
  DECLARE @MaterialSpec NVARCHAR(200)
  DECLARE @MaterialSize NVARCHAR(100)
  DECLARE @MaterialQty NUMERIC(20,5)
  DECLARE @MaterialUnitCode VARCHAR(20)
  DECLARE @MaterialUnitPrice NUMERIC(20,5)
  DECLARE @MaterialTotPrice NUMERIC(20,5)
  DECLARE @CurrencyCode VARCHAR(10)
  DECLARE @CurrencyRate NUMERIC(20,5)
  DECLARE @ConvertPrice NUMERIC(20,5)
  DECLARE @StockUnitPrice NUMERIC(20,5)
  DECLARE @StockTotPrice NUMERIC(20,5)
  DECLARE @Margin NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_ShipmentInfoTempForERP',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ShipmentInfoTempForERP AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldShipmentInfoNo IS NULL THEN ShipmentInfoNo
							    ELSE OldShipmentInfoNo
							END AS OldShipmentInfoNo,
							ShipmentInfoNo,
							MaterialWarehouseName,
							ShipmentNo,
							ShipmentSerNo,
							ShipmentDate,
							ShipmentClassName,
							CustomerName,
							MaterialCode,
							MaterialName,
							MaterialSpec,
							MaterialSize,
							MaterialQty,
							MaterialUnitCode,
							MaterialUnitPrice,
							MaterialTotPrice,
							CurrencyCode,
							CurrencyRate,
							ConvertPrice,
							StockUnitPrice,
							StockTotPrice,
							Margin,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldShipmentInfoNo BIGINT,
										ShipmentInfoNo BIGINT,
										MaterialWarehouseName NVARCHAR(100),
										ShipmentNo VARCHAR(30),
										ShipmentSerNo INT,
										ShipmentDate DATETIMEOFFSET,
										ShipmentClassName NVARCHAR(20),
										CustomerName NVARCHAR(100),
										MaterialCode VARCHAR(20),
										MaterialName NVARCHAR(200),
										MaterialSpec NVARCHAR(200),
										MaterialSize NVARCHAR(100),
										MaterialQty NUMERIC(20,5),
										MaterialUnitCode VARCHAR(20),
										MaterialUnitPrice NUMERIC(20,5),
										MaterialTotPrice NUMERIC(20,5),
										CurrencyCode VARCHAR(10),
										CurrencyRate NUMERIC(20,5),
										ConvertPrice NUMERIC(20,5),
										StockUnitPrice NUMERIC(20,5),
										StockTotPrice NUMERIC(20,5),
										Margin NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ShipmentInfoNo = SourceTable.ShipmentInfoNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialWarehouseName = ISNULL(SourceTable.MaterialWarehouseName,TargetTable.MaterialWarehouseName),
					ShipmentNo = ISNULL(SourceTable.ShipmentNo,TargetTable.ShipmentNo),
					ShipmentSerNo = ISNULL(SourceTable.ShipmentSerNo,TargetTable.ShipmentSerNo),
					ShipmentDate = ISNULL(SourceTable.ShipmentDate,TargetTable.ShipmentDate),
					ShipmentClassName = ISNULL(SourceTable.ShipmentClassName,TargetTable.ShipmentClassName),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					MaterialSpec = ISNULL(SourceTable.MaterialSpec,TargetTable.MaterialSpec),
					MaterialSize = ISNULL(SourceTable.MaterialSize,TargetTable.MaterialSize),
					MaterialQty = ISNULL(SourceTable.MaterialQty,TargetTable.MaterialQty),
					MaterialUnitCode = ISNULL(SourceTable.MaterialUnitCode,TargetTable.MaterialUnitCode),
					MaterialUnitPrice = ISNULL(SourceTable.MaterialUnitPrice,TargetTable.MaterialUnitPrice),
					MaterialTotPrice = ISNULL(SourceTable.MaterialTotPrice,TargetTable.MaterialTotPrice),
					CurrencyCode = ISNULL(SourceTable.CurrencyCode,TargetTable.CurrencyCode),
					CurrencyRate = ISNULL(SourceTable.CurrencyRate,TargetTable.CurrencyRate),
					ConvertPrice = ISNULL(SourceTable.ConvertPrice,TargetTable.ConvertPrice),
					StockUnitPrice = ISNULL(SourceTable.StockUnitPrice,TargetTable.StockUnitPrice),
					StockTotPrice = ISNULL(SourceTable.StockTotPrice,TargetTable.StockTotPrice),
					Margin = ISNULL(SourceTable.Margin,TargetTable.Margin),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialWarehouseName,
						ShipmentNo,
						ShipmentSerNo,
						ShipmentDate,
						ShipmentClassName,
						CustomerName,
						MaterialCode,
						MaterialName,
						MaterialSpec,
						MaterialSize,
						MaterialQty,
						MaterialUnitCode,
						MaterialUnitPrice,
						MaterialTotPrice,
						CurrencyCode,
						CurrencyRate,
						ConvertPrice,
						StockUnitPrice,
						StockTotPrice,
						Margin,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialWarehouseName,
							SourceTable.ShipmentNo,
							SourceTable.ShipmentSerNo,
							SourceTable.ShipmentDate,
							SourceTable.ShipmentClassName,
							SourceTable.CustomerName,
							SourceTable.MaterialCode,
							SourceTable.MaterialName,
							SourceTable.MaterialSpec,
							SourceTable.MaterialSize,
							SourceTable.MaterialQty,
							SourceTable.MaterialUnitCode,
							SourceTable.MaterialUnitPrice,
							SourceTable.MaterialTotPrice,
							SourceTable.CurrencyCode,
							SourceTable.CurrencyRate,
							SourceTable.ConvertPrice,
							SourceTable.StockUnitPrice,
							SourceTable.StockTotPrice,
							SourceTable.Margin,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ShipmentInfoTempForERP AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldShipmentInfoNo IS NULL THEN ShipmentInfoNo
							    ELSE OldShipmentInfoNo
							END AS OldShipmentInfoNo,
							ShipmentInfoNo,
							MaterialWarehouseName,
							ShipmentNo,
							ShipmentSerNo,
							ShipmentDate,
							ShipmentClassName,
							CustomerName,
							MaterialCode,
							MaterialName,
							MaterialSpec,
							MaterialSize,
							MaterialQty,
							MaterialUnitCode,
							MaterialUnitPrice,
							MaterialTotPrice,
							CurrencyCode,
							CurrencyRate,
							ConvertPrice,
							StockUnitPrice,
							StockTotPrice,
							Margin,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldShipmentInfoNo BIGINT,
										ShipmentInfoNo BIGINT,
										MaterialWarehouseName NVARCHAR(100),
										ShipmentNo VARCHAR(30),
										ShipmentSerNo INT,
										ShipmentDate DATETIMEOFFSET,
										ShipmentClassName NVARCHAR(20),
										CustomerName NVARCHAR(100),
										MaterialCode VARCHAR(20),
										MaterialName NVARCHAR(200),
										MaterialSpec NVARCHAR(200),
										MaterialSize NVARCHAR(100),
										MaterialQty NUMERIC(20,5),
										MaterialUnitCode VARCHAR(20),
										MaterialUnitPrice NUMERIC(20,5),
										MaterialTotPrice NUMERIC(20,5),
										CurrencyCode VARCHAR(10),
										CurrencyRate NUMERIC(20,5),
										ConvertPrice NUMERIC(20,5),
										StockUnitPrice NUMERIC(20,5),
										StockTotPrice NUMERIC(20,5),
										Margin NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ShipmentInfoNo = SourceTable.OldShipmentInfoNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialWarehouseName = ISNULL(SourceTable.MaterialWarehouseName,TargetTable.MaterialWarehouseName),
					ShipmentNo = ISNULL(SourceTable.ShipmentNo,TargetTable.ShipmentNo),
					ShipmentSerNo = ISNULL(SourceTable.ShipmentSerNo,TargetTable.ShipmentSerNo),
					ShipmentDate = ISNULL(SourceTable.ShipmentDate,TargetTable.ShipmentDate),
					ShipmentClassName = ISNULL(SourceTable.ShipmentClassName,TargetTable.ShipmentClassName),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					MaterialSpec = ISNULL(SourceTable.MaterialSpec,TargetTable.MaterialSpec),
					MaterialSize = ISNULL(SourceTable.MaterialSize,TargetTable.MaterialSize),
					MaterialQty = ISNULL(SourceTable.MaterialQty,TargetTable.MaterialQty),
					MaterialUnitCode = ISNULL(SourceTable.MaterialUnitCode,TargetTable.MaterialUnitCode),
					MaterialUnitPrice = ISNULL(SourceTable.MaterialUnitPrice,TargetTable.MaterialUnitPrice),
					MaterialTotPrice = ISNULL(SourceTable.MaterialTotPrice,TargetTable.MaterialTotPrice),
					CurrencyCode = ISNULL(SourceTable.CurrencyCode,TargetTable.CurrencyCode),
					CurrencyRate = ISNULL(SourceTable.CurrencyRate,TargetTable.CurrencyRate),
					ConvertPrice = ISNULL(SourceTable.ConvertPrice,TargetTable.ConvertPrice),
					StockUnitPrice = ISNULL(SourceTable.StockUnitPrice,TargetTable.StockUnitPrice),
					StockTotPrice = ISNULL(SourceTable.StockTotPrice,TargetTable.StockTotPrice),
					Margin = ISNULL(SourceTable.Margin,TargetTable.Margin),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialWarehouseName,
						ShipmentNo,
						ShipmentSerNo,
						ShipmentDate,
						ShipmentClassName,
						CustomerName,
						MaterialCode,
						MaterialName,
						MaterialSpec,
						MaterialSize,
						MaterialQty,
						MaterialUnitCode,
						MaterialUnitPrice,
						MaterialTotPrice,
						CurrencyCode,
						CurrencyRate,
						ConvertPrice,
						StockUnitPrice,
						StockTotPrice,
						Margin,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialWarehouseName,
							SourceTable.ShipmentNo,
							SourceTable.ShipmentSerNo,
							SourceTable.ShipmentDate,
							SourceTable.ShipmentClassName,
							SourceTable.CustomerName,
							SourceTable.MaterialCode,
							SourceTable.MaterialName,
							SourceTable.MaterialSpec,
							SourceTable.MaterialSize,
							SourceTable.MaterialQty,
							SourceTable.MaterialUnitCode,
							SourceTable.MaterialUnitPrice,
							SourceTable.MaterialTotPrice,
							SourceTable.CurrencyCode,
							SourceTable.CurrencyRate,
							SourceTable.ConvertPrice,
							SourceTable.StockUnitPrice,
							SourceTable.StockTotPrice,
							SourceTable.Margin,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ShipmentInfoTempForERP AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldShipmentInfoNo IS NULL THEN ShipmentInfoNo
							    ELSE OldShipmentInfoNo
							END AS OldShipmentInfoNo,
							ShipmentInfoNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldShipmentInfoNo BIGINT,
										ShipmentInfoNo BIGINT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ShipmentInfoNo = SourceTable.ShipmentInfoNo
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
									OldShipmentInfoNo,
									ShipmentInfoNo,
									MaterialWarehouseName,
									ShipmentNo,
									ShipmentSerNo,
									ShipmentDate,
									ShipmentClassName,
									CustomerName,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									MaterialSize,
									MaterialQty,
									MaterialUnitCode,
									MaterialUnitPrice,
									MaterialTotPrice,
									CurrencyCode,
									CurrencyRate,
									ConvertPrice,
									StockUnitPrice,
									StockTotPrice,
									Margin,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldShipmentInfoNo BIGINT,
											 ShipmentInfoNo BIGINT,
											 MaterialWarehouseName NVARCHAR(100),
											 ShipmentNo VARCHAR(30),
											 ShipmentSerNo INT,
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentClassName NVARCHAR(20),
											 CustomerName NVARCHAR(100),
											 MaterialCode VARCHAR(20),
											 MaterialName NVARCHAR(200),
											 MaterialSpec NVARCHAR(200),
											 MaterialSize NVARCHAR(100),
											 MaterialQty NUMERIC(20,5),
											 MaterialUnitCode VARCHAR(20),
											 MaterialUnitPrice NUMERIC(20,5),
											 MaterialTotPrice NUMERIC(20,5),
											 CurrencyCode VARCHAR(10),
											 CurrencyRate NUMERIC(20,5),
											 ConvertPrice NUMERIC(20,5),
											 StockUnitPrice NUMERIC(20,5),
											 StockTotPrice NUMERIC(20,5),
											 Margin NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldShipmentInfoNo IS NULL THEN ShipmentInfoNo
										ELSE OldShipmentInfoNo
									END AS OldShipmentInfoNo,
									ShipmentInfoNo,
									MaterialWarehouseName,
									ShipmentNo,
									ShipmentSerNo,
									ShipmentDate,
									ShipmentClassName,
									CustomerName,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									MaterialSize,
									MaterialQty,
									MaterialUnitCode,
									MaterialUnitPrice,
									MaterialTotPrice,
									CurrencyCode,
									CurrencyRate,
									ConvertPrice,
									StockUnitPrice,
									StockTotPrice,
									Margin,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldShipmentInfoNo BIGINT,
											 ShipmentInfoNo BIGINT,
											 MaterialWarehouseName NVARCHAR(100),
											 ShipmentNo VARCHAR(30),
											 ShipmentSerNo INT,
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentClassName NVARCHAR(20),
											 CustomerName NVARCHAR(100),
											 MaterialCode VARCHAR(20),
											 MaterialName NVARCHAR(200),
											 MaterialSpec NVARCHAR(200),
											 MaterialSize NVARCHAR(100),
											 MaterialQty NUMERIC(20,5),
											 MaterialUnitCode VARCHAR(20),
											 MaterialUnitPrice NUMERIC(20,5),
											 MaterialTotPrice NUMERIC(20,5),
											 CurrencyCode VARCHAR(10),
											 CurrencyRate NUMERIC(20,5),
											 ConvertPrice NUMERIC(20,5),
											 StockUnitPrice NUMERIC(20,5),
											 StockTotPrice NUMERIC(20,5),
											 Margin NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldShipmentInfoNo IS NULL THEN ShipmentInfoNo
										ELSE OldShipmentInfoNo
									END AS OldShipmentInfoNo,
									ShipmentInfoNo,
									MaterialWarehouseName,
									ShipmentNo,
									ShipmentSerNo,
									ShipmentDate,
									ShipmentClassName,
									CustomerName,
									MaterialCode,
									MaterialName,
									MaterialSpec,
									MaterialSize,
									MaterialQty,
									MaterialUnitCode,
									MaterialUnitPrice,
									MaterialTotPrice,
									CurrencyCode,
									CurrencyRate,
									ConvertPrice,
									StockUnitPrice,
									StockTotPrice,
									Margin,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldShipmentInfoNo BIGINT,
											 ShipmentInfoNo BIGINT,
											 MaterialWarehouseName NVARCHAR(100),
											 ShipmentNo VARCHAR(30),
											 ShipmentSerNo INT,
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentClassName NVARCHAR(20),
											 CustomerName NVARCHAR(100),
											 MaterialCode VARCHAR(20),
											 MaterialName NVARCHAR(200),
											 MaterialSpec NVARCHAR(200),
											 MaterialSize NVARCHAR(100),
											 MaterialQty NUMERIC(20,5),
											 MaterialUnitCode VARCHAR(20),
											 MaterialUnitPrice NUMERIC(20,5),
											 MaterialTotPrice NUMERIC(20,5),
											 CurrencyCode VARCHAR(10),
											 CurrencyRate NUMERIC(20,5),
											 ConvertPrice NUMERIC(20,5),
											 StockUnitPrice NUMERIC(20,5),
											 StockTotPrice NUMERIC(20,5),
											 Margin NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldShipmentInfoNo,
								 @ShipmentInfoNo,
								 @MaterialWarehouseName,
								 @ShipmentNo,
								 @ShipmentSerNo,
								 @ShipmentDate,
								 @ShipmentClassName,
								 @CustomerName,
								 @MaterialCode,
								 @MaterialName,
								 @MaterialSpec,
								 @MaterialSize,
								 @MaterialQty,
								 @MaterialUnitCode,
								 @MaterialUnitPrice,
								 @MaterialTotPrice,
								 @CurrencyCode,
								 @CurrencyRate,
								 @ConvertPrice,
								 @StockUnitPrice,
								 @StockTotPrice,
								 @Margin,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ShipmentInfoTempForERP WHERE ShipmentInfoNo = @ShipmentInfoNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ShipmentInfoNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ShipmentInfoTempForERP',@ShipmentInfoNo OUTPUT
                    END

                    INSERT INTO STB_ShipmentInfoTempForERP
						(
						    MaterialWarehouseName,
						    ShipmentNo,
						    ShipmentSerNo,
						    ShipmentDate,
						    ShipmentClassName,
						    CustomerName,
						    MaterialCode,
						    MaterialName,
						    MaterialSpec,
						    MaterialSize,
						    MaterialQty,
						    MaterialUnitCode,
						    MaterialUnitPrice,
						    MaterialTotPrice,
						    CurrencyCode,
						    CurrencyRate,
						    ConvertPrice,
						    StockUnitPrice,
						    StockTotPrice,
						    Margin,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialWarehouseName,
						    @ShipmentNo,
						    @ShipmentSerNo,
						    @ShipmentDate,
						    @ShipmentClassName,
						    @CustomerName,
						    @MaterialCode,
						    @MaterialName,
						    @MaterialSpec,
						    @MaterialSize,
						    @MaterialQty,
						    @MaterialUnitCode,
						    @MaterialUnitPrice,
						    @MaterialTotPrice,
						    @CurrencyCode,
						    @CurrencyRate,
						    @ConvertPrice,
						    @StockUnitPrice,
						    @StockTotPrice,
						    @Margin,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ShipmentInfoTempForERP
						SET
						    MaterialWarehouseName =   ISNULL(@MaterialWarehouseName,MaterialWarehouseName),
						    ShipmentNo =   ISNULL(@ShipmentNo,ShipmentNo),
						    ShipmentSerNo =   ISNULL(@ShipmentSerNo,ShipmentSerNo),
						    ShipmentDate =   ISNULL(@ShipmentDate,ShipmentDate),
						    ShipmentClassName =   ISNULL(@ShipmentClassName,ShipmentClassName),
						    CustomerName =   ISNULL(@CustomerName,CustomerName),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    MaterialSpec =   ISNULL(@MaterialSpec,MaterialSpec),
						    MaterialSize =   ISNULL(@MaterialSize,MaterialSize),
						    MaterialQty =   ISNULL(@MaterialQty,MaterialQty),
						    MaterialUnitCode =   ISNULL(@MaterialUnitCode,MaterialUnitCode),
						    MaterialUnitPrice =   ISNULL(@MaterialUnitPrice,MaterialUnitPrice),
						    MaterialTotPrice =   ISNULL(@MaterialTotPrice,MaterialTotPrice),
						    CurrencyCode =   ISNULL(@CurrencyCode,CurrencyCode),
						    CurrencyRate =   ISNULL(@CurrencyRate,CurrencyRate),
						    ConvertPrice =   ISNULL(@ConvertPrice,ConvertPrice),
						    StockUnitPrice =   ISNULL(@StockUnitPrice,StockUnitPrice),
						    StockTotPrice =   ISNULL(@StockTotPrice,StockTotPrice),
						    Margin =   ISNULL(@Margin,Margin),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ShipmentInfoNo = @OldShipmentInfoNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ShipmentInfoTempForERP
						WHERE
						    ShipmentInfoNo = @OldShipmentInfoNo
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
