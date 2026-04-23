-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductsReceiptHist_iud]
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
  
  DECLARE @OldBarcode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @InvoiceNo VARCHAR(40)
  DECLARE @BLNo VARCHAR(20)
  DECLARE @PackingDate DATETIME
  DECLARE @ShipmentDate DATETIME
  DECLARE @TransportationMethodCode VARCHAR(2)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @ProdQty NUMERIC(20,5)
  DECLARE @VNNameProduct NVARCHAR(200)
  DECLARE @IsHeadOfficeConfirm BIT
  DECLARE @HeadOfficeConfirmDate DATETIME
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @Nation VARCHAR(100)
  DECLARE @Customer VARCHAR(100)
  DECLARE @Size VARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  -- 본사품질확인 여부 및 확인일자 추가 2021.01.11 이미정 차장님 요청 by Jackaroe
  DECLARE @IsHeadOfficeQcConfirm BIT
  DECLARE @HeadOfficeQcConfirmDate DATETIME

  -- 본사품질(상태) 추가 
  DECLARE @HeadOfficeQcStatusCode VARCHAR(10)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductsReceiptHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProductsReceiptHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							ID,
							Barcode,
							InvoiceNo,
							BLNo,
							PackingDate,
							ShipmentDate,
							TransportationMethodCode,
							MaterialCode,
							ProdQty,
							VNNameProduct,
							IsHeadOfficeConfirm,
							HeadOfficeConfirmDate,
							IsHeadOfficeQcConfirm,
							HeadOfficeQcConfirmDate,
							HeadOfficeQcStatusCode,
							Remark,
							Nation,
							Customer,
							Size,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20),
										ID INT,
										InvoiceNo VARCHAR(40),
										BLNo VARCHAR(20),
										PackingDate DATETIMEOFFSET,
										ShipmentDate DATETIMEOFFSET,
										TransportationMethodCode VARCHAR(2),
										MaterialCode VARCHAR(20),
										ProdQty NUMERIC(20,5),
										VNNameProduct NVARCHAR(200),
										IsHeadOfficeConfirm BIT,
										HeadOfficeConfirmDate DATETIMEOFFSET,
										IsHeadOfficeQcConfirm BIT,
										HeadOfficeQcConfirmDate DATETIMEOFFSET,
										HeadOfficeQcStatusCode VARCHAR(10),
										Remark NVARCHAR(MAX),
										Nation VARCHAR(100),
										Customer VARCHAR(100),
										Size VARCHAR(50),			
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					  TargetTable.Barcode = SourceTable.Barcode
					  and TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					InvoiceNo = ISNULL(SourceTable.InvoiceNo,TargetTable.InvoiceNo),
					BLNo = ISNULL(SourceTable.BLNo,TargetTable.BLNo),
					PackingDate = ISNULL(SourceTable.PackingDate,TargetTable.PackingDate),
					ShipmentDate = ISNULL(SourceTable.ShipmentDate,TargetTable.ShipmentDate),
					TransportationMethodCode = ISNULL(SourceTable.TransportationMethodCode,TargetTable.TransportationMethodCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ProdQty = ISNULL(SourceTable.ProdQty,TargetTable.ProdQty),
					VNNameProduct = ISNULL(SourceTable.VNNameProduct, SourceTable.VNNameProduct),
					IsHeadOfficeConfirm = ISNULL(SourceTable.IsHeadOfficeConfirm,TargetTable.IsHeadOfficeConfirm),
					HeadOfficeConfirmDate = ISNULL(SourceTable.HeadOfficeConfirmDate,TargetTable.HeadOfficeConfirmDate),
					IsHeadOfficeQcConfirm = ISNULL(SourceTable.IsHeadOfficeQcConfirm,TargetTable.IsHeadOfficeQcConfirm),
					HeadOfficeQcConfirmDate = ISNULL(SourceTable.HeadOfficeQcConfirmDate,TargetTable.HeadOfficeQcConfirmDate),
					HeadOfficeQcStatusCode = ISNULL(SourceTable.HeadOfficeQcStatusCode,TargetTable.HeadOfficeQcStatusCode),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					Nation = ISNULL(SourceTable.Nation,TargetTable.Nation),
					Customer = ISNULL(SourceTable.Customer,TargetTable.Customer),
					Size = ISNULL(SourceTable.Size,TargetTable.Size),
					ChangeDateTime = ISNULL(SourceTable.Nation,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						InvoiceNo,
						BLNo,
						PackingDate,
						ShipmentDate,
						TransportationMethodCode,
						MaterialCode,
						ProdQty,
						VNNameProduct,
						Remark,
						Nation,
						Customer,
						Size,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.InvoiceNo,
							SourceTable.BLNo,
							SourceTable.PackingDate,
							SourceTable.ShipmentDate,
							SourceTable.TransportationMethodCode,
							SourceTable.MaterialCode,
							SourceTable.ProdQty,
							SourceTable.VNNameProduct,
							SourceTable.Remark,
							SourceTable.Nation,
							SourceTable.Customer,
							SourceTable.Size,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ProductsReceiptHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							Barcode,
							ID,
							InvoiceNo,
							BLNo,
							PackingDate,
							ShipmentDate,
							TransportationMethodCode,
							MaterialCode,
							ProdQty,
							VNNameProduct,
							IsHeadOfficeConfirm,
							HeadOfficeConfirmDate,
							IsHeadOfficeQcConfirm,
							HeadOfficeQcConfirmDate,
							HeadOfficeQcStatusCode,
							Remark,
							Nation,
							Customer,
							Size,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20),
										ID INT,
										InvoiceNo VARCHAR(40),
										BLNo VARCHAR(20),
										PackingDate DATETIMEOFFSET,
										ShipmentDate DATETIMEOFFSET,
										TransportationMethodCode VARCHAR(2),
										MaterialCode VARCHAR(20),
										ProdQty NUMERIC(20,5),
										VNNameProduct NVARCHAR(200),
										IsHeadOfficeConfirm BIT,
										HeadOfficeConfirmDate DATETIMEOFFSET,
										IsHeadOfficeQcConfirm BIT,
										HeadOfficeQcConfirmDate DATETIMEOFFSET,
										HeadOfficeQcStatusCode VARCHAR(10),
										Remark NVARCHAR(MAX),
										Nation VARCHAR(100),
										Customer VARCHAR(100),
										Size VARCHAR(50),		
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.OldBarcode
					and TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					InvoiceNo = ISNULL(SourceTable.InvoiceNo,TargetTable.InvoiceNo),
					BLNo = ISNULL(SourceTable.BLNo,TargetTable.BLNo),
					PackingDate = ISNULL(SourceTable.PackingDate,TargetTable.PackingDate),
					ShipmentDate = ISNULL(SourceTable.ShipmentDate,TargetTable.ShipmentDate),
					TransportationMethodCode = ISNULL(SourceTable.TransportationMethodCode,TargetTable.TransportationMethodCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ProdQty = ISNULL(SourceTable.ProdQty,TargetTable.ProdQty),
					VNNameProduct = ISNULL(SourceTable.VNNameProduct, TargetTable.VNNameProduct),
					IsHeadOfficeConfirm = ISNULL(SourceTable.IsHeadOfficeConfirm,TargetTable.IsHeadOfficeConfirm),
					HeadOfficeConfirmDate = CASE WHEN ISNULL(SourceTable.IsHeadOfficeConfirm,TargetTable.IsHeadOfficeConfirm) = CONVERT(BIT, 1) AND SourceTable.HeadOfficeConfirmDate IS NULL THEN GETDATE() ELSE SourceTable.HeadOfficeConfirmDate END,
					IsHeadOfficeQcConfirm = ISNULL(SourceTable.IsHeadOfficeQcConfirm,TargetTable.IsHeadOfficeQcConfirm),
					HeadOfficeQcConfirmDate = CASE WHEN ISNULL(SourceTable.IsHeadOfficeQcConfirm,TargetTable.IsHeadOfficeQcConfirm) = CONVERT(BIT, 1) AND SourceTable.HeadOfficeQcConfirmDate IS NULL  THEN GETDATE() ELSE SourceTable.HeadOfficeQcConfirmDate END,
					HeadOfficeQcStatusCode = ISNULL(SourceTable.HeadOfficeQcStatusCode,TargetTable.HeadOfficeQcStatusCode),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					Nation = ISNULL(SourceTable.Nation,TargetTable.Nation),
					Customer = ISNULL(SourceTable.Customer,TargetTable.Customer),
					Size = ISNULL(SourceTable.Size,TargetTable.Size),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						InvoiceNo,
						BLNo,
						PackingDate,
						ShipmentDate,
						TransportationMethodCode,
						MaterialCode,
						ProdQty,
						VNNameProduct,
						Remark,
						Nation,
						Customer,
						Size,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.InvoiceNo,
							SourceTable.BLNo,
							SourceTable.PackingDate,
							SourceTable.ShipmentDate,
							SourceTable.TransportationMethodCode,
							SourceTable.MaterialCode,
							SourceTable.ProdQty,
							SourceTable.VNNameProduct,
							SourceTable.Remark,
							SourceTable.Nation,
							SourceTable.Customer,
							SourceTable.Size,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ProductsReceiptHist AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							Barcode,
							ID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20),
										ID int
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.Barcode
					and TargetTable.ID = SourceTable.ID
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
        PRINT 'Loop was removed'
    END
END
