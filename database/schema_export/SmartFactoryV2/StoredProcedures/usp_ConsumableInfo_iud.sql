-- Procedure: usp_ConsumableInfo_iud
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2023-09-16
-- Browsable : true
-- Group : 자재관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ConsumableInfo_iud
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
  DECLARE @OldConsumableNo VARCHAR(20)
  DECLARE @ConsumableNo VARCHAR(20)
  DECLARE @Cateogry1 NVARCHAR(100)
  DECLARE @Category2 NVARCHAR(100)
  DECLARE @Category3 NVARCHAR(100)
  DECLARE @MaterialCode NVARCHAR(100)
  DECLARE @MaterialName NVARCHAR(100)
  DECLARE @Qty NUMERIC(20,5)
  DECLARE @Unit NVARCHAR(10)
  DECLARE @UnitPrice NUMERIC(20,5)
  DECLARE @ProdDate DATE
  DECLARE @VendorLotRemark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ConsumableInfo',
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
									OldConsumableNo,
									ConsumableNo,
									Cateogry1,
									Category2,
									Category3,
									MaterialCode,
									MaterialName,
									Qty,
									Unit,
									UnitPrice,
									ProdDate,
									VendorLotRemark,
									CreateDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldConsumableNo VARCHAR(20),
											 ConsumableNo VARCHAR(20),
											 Cateogry1 NVARCHAR(100),
											 Category2 NVARCHAR(100),
											 Category3 NVARCHAR(100),
											 MaterialCode NVARCHAR(100),
											 MaterialName NVARCHAR(100),
											 Qty NUMERIC(20,5),
											 Unit NVARCHAR(10),
											 UnitPrice NUMERIC(20,5),
											 ProdDate DATETIMEOFFSET,
											 VendorLotRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldConsumableNo IS NULL THEN ConsumableNo
										ELSE OldConsumableNo
									END AS OldConsumableNo,
									ConsumableNo,
									Cateogry1,
									Category2,
									Category3,
									MaterialCode,
									MaterialName,
									Qty,
									Unit,
									UnitPrice,
									ProdDate,
									VendorLotRemark,
									CreateDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldConsumableNo VARCHAR(20),
											 ConsumableNo VARCHAR(20),
											 Cateogry1 NVARCHAR(100),
											 Category2 NVARCHAR(100),
											 Category3 NVARCHAR(100),
											 MaterialCode NVARCHAR(100),
											 MaterialName NVARCHAR(100),
											 Qty NUMERIC(20,5),
											 Unit NVARCHAR(10),
											 UnitPrice NUMERIC(20,5),
											 ProdDate DATETIMEOFFSET,
											 VendorLotRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldConsumableNo IS NULL THEN ConsumableNo
										ELSE OldConsumableNo
									END AS OldConsumableNo,
									ConsumableNo,
									Cateogry1,
									Category2,
									Category3,
									MaterialCode,
									MaterialName,
									Qty,
									Unit,
									UnitPrice,
									ProdDate,
									VendorLotRemark,
									CreateDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldConsumableNo VARCHAR(20),
											 ConsumableNo VARCHAR(20),
											 Cateogry1 NVARCHAR(100),
											 Category2 NVARCHAR(100),
											 Category3 NVARCHAR(100),
											 MaterialCode NVARCHAR(100),
											 MaterialName NVARCHAR(100),
											 Qty NUMERIC(20,5),
											 Unit NVARCHAR(10),
											 UnitPrice NUMERIC(20,5),
											 ProdDate DATETIMEOFFSET,
											 VendorLotRemark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldConsumableNo,
								 @ConsumableNo,
								 @Cateogry1,
								 @Category2,
								 @Category3,
								 @MaterialCode,
								 @MaterialName,
								 @Qty,
								 @Unit,
								 @UnitPrice,
								 @ProdDate,
								 @VendorLotRemark,
								 @CreateDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ConsumableInfo WHERE ConsumableNo = @ConsumableNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ConsumableNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ConsumableInfo',@ConsumableNo OUTPUT
                    END

                    INSERT INTO STB_ConsumableInfo
						(
						    ConsumableNo,
						    Cateogry1,
						    Category2,
						    Category3,
						    MaterialCode,
						    MaterialName,
						    Qty,
						    Unit,
						    UnitPrice,
						    ProdDate,
						    VendorLotRemark,
						    CreateDateTime
						)
						VALUES
						(
						    @ConsumableNo,
						    @Cateogry1,
						    @Category2,
						    @Category3,
						    @MaterialCode,
						    @MaterialName,
						    @Qty,
						    @Unit,
						    @UnitPrice,
						    @ProdDate,
						    @VendorLotRemark,
						    GETDATE()
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ConsumableInfo
						SET
						    ConsumableNo =   ISNULL(@ConsumableNo,ConsumableNo),
						    Cateogry1 =   ISNULL(@Cateogry1,Cateogry1),
						    Category2 =   ISNULL(@Category2,Category2),
						    Category3 =   ISNULL(@Category3,Category3),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    Qty =   ISNULL(@Qty,Qty),
						    Unit =   ISNULL(@Unit,Unit),
						    UnitPrice =   ISNULL(@UnitPrice,UnitPrice),
						    ProdDate =   ISNULL(@ProdDate,ProdDate),
						    VendorLotRemark =   ISNULL(@VendorLotRemark,VendorLotRemark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime)
						WHERE
						    ConsumableNo = @OldConsumableNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ConsumableInfo
						WHERE
						    ConsumableNo = @OldConsumableNo
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

GO

