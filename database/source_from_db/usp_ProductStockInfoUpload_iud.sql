-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-05
-- Browsable : true
-- Group : 제품관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfoUpload_iud]
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
  DECLARE @OldProductStockNo VARCHAR(20)
  DECLARE @ProductStockNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @PackingID VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @MaterialLocationCode VARCHAR(20)
  DECLARE @PaletteNo NVARCHAR(20)
  DECLARE @StockQty NUMERIC(20,2)
  DECLARE @ManufacturingUnitPrice NUMERIC(20,5)
  DECLARE @StockPrice NUMERIC(38,6)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  -- 기존재 PackingID
  DECLARE @FindPackingID VARCHAR(20)

  -- 비고 추가
  DECLARE @Remark NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductStockInfoUpload',
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
									OldProductStockNo,
									ProductStockNo,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									Barcode,
									PackingID,
									MaterialWarehouseCode,
									MaterialLocationCode,
									PaletteNo,
									StockQty,
									ManufacturingUnitPrice,
									StockPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProductStockNo VARCHAR(20),
											 ProductStockNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 PaletteNo NVARCHAR(20),
											 StockQty NUMERIC(20,2),
											 ManufacturingUnitPrice NUMERIC(20,5),
											 StockPrice NUMERIC(38,6),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProductStockNo IS NULL THEN ProductStockNo
										ELSE OldProductStockNo
									END AS OldProductStockNo,
									ProductStockNo,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									Barcode,
									PackingID,
									MaterialWarehouseCode,
									MaterialLocationCode,
									PaletteNo,
									StockQty,
									ManufacturingUnitPrice,
									StockPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProductStockNo VARCHAR(20),
											 ProductStockNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 PaletteNo NVARCHAR(20),
											 StockQty NUMERIC(20,2),
											 ManufacturingUnitPrice NUMERIC(20,5),
											 StockPrice NUMERIC(38,6),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProductStockNo IS NULL THEN ProductStockNo
										ELSE OldProductStockNo
									END AS OldProductStockNo,
									ProductStockNo,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									Barcode,
									PackingID,
									MaterialWarehouseCode,
									MaterialLocationCode,
									PaletteNo,
									StockQty,
									ManufacturingUnitPrice,
									StockPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProductStockNo VARCHAR(20),
											 ProductStockNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Barcode VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 PaletteNo NVARCHAR(20),
											 StockQty NUMERIC(20,2),
											 ManufacturingUnitPrice NUMERIC(20,5),
											 StockPrice NUMERIC(38,6),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProductStockNo,
								 @ProductStockNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialCode,
								 @Barcode,
								 @PackingID,
								 @MaterialWarehouseCode,
								 @MaterialLocationCode,
								 @PaletteNo,
								 @StockQty,
								 @ManufacturingUnitPrice,
								 @StockPrice,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 화면에서 넘어온 PackingID가 없으면,
				IF ISNULL(RTRIM(@PackingID), '') = '' BEGIN
					SELECT TOP 1 @FindPackingID = PackingID
					  FROM STB_MaterialLotInfo
					 WHERE LotID = @Barcode OR LotNo = @Barcode
				END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ProductStockInfoUpload WHERE ProductStockNo = @ProductStockNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProductStockNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ProductStockInfoUpload',@ProductStockNo OUTPUT
                    END

                    INSERT INTO STB_ProductStockInfoUpload
						(
						    ProductStockNo,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialCode,
						    Barcode,
						    PackingID,
						    MaterialWarehouseCode,
						    MaterialLocationCode,
						    PaletteNo,
						    StockQty,
						    ManufacturingUnitPrice,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Remark
						)
						VALUES
						(
						    @ProductStockNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialCode,
						    @Barcode,
						    ISNULL(@PackingID, @FindPackingID),
						    @MaterialWarehouseCode,
						    @MaterialLocationCode,
						    @PaletteNo,
						    @StockQty,
						    @ManufacturingUnitPrice,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@Remark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ProductStockInfoUpload
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    PackingID =   ISNULL(ISNULL(@PackingID,PackingID), @FindPackingID),
						    MaterialWarehouseCode =   ISNULL(@MaterialWarehouseCode,MaterialWarehouseCode),
						    MaterialLocationCode =   ISNULL(@MaterialLocationCode,MaterialLocationCode),
						    PaletteNo =   ISNULL(@PaletteNo,PaletteNo),
						    StockQty =   ISNULL(@StockQty,StockQty),
						    ManufacturingUnitPrice =   ISNULL(@ManufacturingUnitPrice,ManufacturingUnitPrice),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							Remark = ISNULL(@Remark, Remark)
						WHERE
						    ProductStockNo = @OldProductStockNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ProductStockInfoUpload
						WHERE
						    ProductStockNo = @OldProductStockNo
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
