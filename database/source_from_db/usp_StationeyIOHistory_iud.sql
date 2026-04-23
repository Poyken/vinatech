
CREATE PROCEDURE [dbo].[usp_StationeyIOHistory_iud]
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
  DECLARE @OldSIOHistoryNo NVARCHAR(50)
  DECLARE @SIOHistoryNo NVARCHAR(50)
  DECLARE @CompanyCode NVARCHAR(20)
  DECLARE @WorkCenterCode NVARCHAR(20)
  DECLARE @SIOTypeCode NVARCHAR(50)
  DECLARE @SWarehouse NVARCHAR(20)
  DECLARE @StationeyCode NVARCHAR(50)
  DECLARE @VendorCode NVARCHAR(50)
  DECLARE @UnitPrice NUMERIC(20,5)
  DECLARE @Quanlity NUMERIC(20,5)
  DECLARE @Dept NVARCHAR(50)
  DECLARE @Purpose NVARCHAR(500)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID NVARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID NVARCHAR(20)
  DECLARE @Description NVARCHAR(500)
  DECLARE @LineCode NVARCHAR(50)
 -- DECLARE @EmployeeDepartment NVARCHAR(50)
  DECLARE @EmpNo NVARCHAR(20)
  DECLARE @Attribute1 NVARCHAR(50)
  DECLARE @Attribute2  NVARCHAR(50)
  DECLARE @Attribute3 NVARCHAR(50)
  DECLARE @Attribute4 NVARCHAR(50)
  DECLARE @Attribute5 NVARCHAR(50)
  DECLARE @BasicDate Date 
  DECLARE @InvoiceNo NVARCHAR(50)
  DECLARE @ToSWarehouse NVARCHAR(50)
  DECLARE @IsConfirm BIT
  DECLARE @DateConfirm DATE

  DECLARE @IOType NVARCHAR(1)
  
  DECLARE @OldSparePartCode NVARCHAR(20)
  DECLARE @OldSPLocationCode NVARCHAR(20)
  DECLARE @OldProcessQty NUMERIC(20,5)
  

  DECLARE @MachineCode NVARCHAR(20)
  DECLARE @BasicUnitPrice NUMERIC(15,2)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'Stb_StationeryIOHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
   BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldSIOHistoryNo,
									XMLData.SIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SWarehouse,
									XMLData.SIOTypeCode,
									XMLData.StationeyCode,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.Quanlity,
									XMLData.Dept,
									XMLData.Purpose,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.LineCode,
									XMLData.EmpNo,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo,
									XMLData.ToSWarehouse,
									XMLData.IsConfirm,
									XMLData.DateConfirm
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSIOHistoryNo NVARCHAR(50),
											 SIOHistoryNo NVARCHAR(50),
											 CompanyCode NVARCHAR(20),
											 WorkCenterCode NVARCHAR(20),
											 SWarehouse NVARCHAR(20),
											 SIOTypeCode NVARCHAR(50),
											 StationeyCode NVARCHAR(50),
											 VendorCode NVARCHAR(50),
											 UnitPrice NUMERIC(20,5),
											 Quanlity NUMERIC(20,5),
											 Dept NVARCHAR(50),
											 Purpose NVARCHAR(500),
											 Description NVARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID NVARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID NVARCHAR(20),
											 LineCode NVARCHAR(50),
											 EmpNo NVARCHAR(20),
											 Attribute1 NVARCHAR(50),
											 Attribute2  NVARCHAR(50),
											 Attribute3 NVARCHAR(50),
											 Attribute4 NVARCHAR(50),
											 Attribute5 NVARCHAR(50),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(50),
											 ToSWarehouse NVARCHAR(50),
											 IsConfirm BIT,
											 DateConfirm DATE
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSIOHistoryNo IS NULL THEN XMLData.SIOHistoryNo
										ELSE XMLData.OldSIOHistoryNo
									END AS OldSIOHistoryNo,
									XMLData.SIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SWarehouse,
									XMLData.SIOTypeCode,
									XMLData.StationeyCode,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.Quanlity,
									XMLData.Dept,
									XMLData.Purpose,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.LineCode,
									XMLData.EmpNo,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo,
									XMLData.ToSWarehouse,
									XMLData.IsConfirm,
									XMLData.DateConfirm
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSIOHistoryNo NVARCHAR(50),
											 SIOHistoryNo NVARCHAR(50),
											 CompanyCode NVARCHAR(20),
											 WorkCenterCode NVARCHAR(20),
											 SWarehouse NVARCHAR(20),
											 SIOTypeCode NVARCHAR(50),
											 StationeyCode NVARCHAR(50),
											 VendorCode NVARCHAR(50),
											 UnitPrice NUMERIC(20,5),
											 Quanlity NUMERIC(20,5),
											 Dept NVARCHAR(50),
											 Purpose NVARCHAR(500),
											 Description NVARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID NVARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID NVARCHAR(20),
											 LineCode NVARCHAR(50),
											 EmpNo NVARCHAR(20),
											 Attribute1 NVARCHAR(50),
											 Attribute2  NVARCHAR(50),
											 Attribute3 NVARCHAR(50),
											 Attribute4 NVARCHAR(50),
											 Attribute5 NVARCHAR(50),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(50),
											 ToSWarehouse NVARCHAR(50),
											 IsConfirm BIT,
											 DateConfirm DATE
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSIOHistoryNo IS NULL THEN XMLData.SIOHistoryNo
										ELSE XMLData.OldSIOHistoryNo
									END AS OldSIOHistoryNo,
									XMLData.SIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SWarehouse,
									XMLData.SIOTypeCode,
									XMLData.StationeyCode,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.Quanlity,
									XMLData.Dept,
									XMLData.Purpose,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.LineCode,
									XMLData.EmpNo,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo,
									XMLData.ToSWarehouse,
									XMLData.IsConfirm,
									XMLData.DateConfirm
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSIOHistoryNo NVARCHAR(20),
											 SIOHistoryNo NVARCHAR(20),
											 CompanyCode NVARCHAR(20),
											 WorkCenterCode NVARCHAR(20),
											 SWarehouse NVARCHAR(20),
											 SIOTypeCode NVARCHAR(50),
											 StationeyCode NVARCHAR(50),
											 VendorCode NVARCHAR(50),
											 UnitPrice NUMERIC(20,5),
											 Quanlity NUMERIC(20,5),
											 Dept NVARCHAR(50),
											 Purpose NVARCHAR(500),
											 Description NVARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID NVARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID NVARCHAR(20),
											 LineCode NVARCHAR(50),
											 EmpNo NVARCHAR(20),
											 Attribute1 NVARCHAR(50),
											 Attribute2  NVARCHAR(50),
											 Attribute3 NVARCHAR(50),
											 Attribute4 NVARCHAR(50),
											 Attribute5 NVARCHAR(50),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(50),
											 ToSWarehouse NVARCHAR(50),
											 IsConfirm BIT,
											 DateConfirm DATE
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSIOHistoryNo,
								 @SIOHistoryNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @SWarehouse,
								 @SIOTypeCode,
								 @StationeyCode,
								 @VendorCode,
								 @UnitPrice,
								 @Quanlity,
								 @Dept,
								 @Purpose,
								 @Description,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @LineCode,
								 @EmpNo,
								 @Attribute1,
								 @Attribute2,
								 @Attribute3,
								 @Attribute4, 
								 @Attribute5, 
								 @BasicDate,
								 @InvoiceNo,
								 @ToSWarehouse,
								 @IsConfirm,
								 @DateConfirm


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

			    EXEC usp_StationeryInOutHistory_iud	    
														 @pOldSIOHistoryNo = @OldSIOHistoryNo,
														 @pSIOHistoryNo = @SIOHistoryNo,
														 @pCompanyCode = @CompanyCode,
														 @pWorkCenterCode = @WorkCenterCode,
														 @pSWarehouse = @SWarehouse,
														 @pSIOTypeCode = @SIOTypeCode,
														 @pStationeyCode = @StationeyCode,
														 @pVendorCode = @VendorCode,
														 @pUnitPrice= @UnitPrice,
														 @pQuanlity =@Quanlity,
														 @pDept = @Dept,
														 @pPurpose = @Purpose,
														 @pDescription = @Description,

														 @pIUD_FLAG = @IUD_FLAG,
														 @pProcessUserID = @ProcessUserID,
														 @pPrefixString = @PrefixString,
														 @pSerialLen = @SerialLen,

														 @pLineCode = @LineCode,
														 @pEmpNo = @EmpNo,
														 @pAttribute1 = @Attribute1,
														 @pAttribute2  = @Attribute2,
														 @pAttribute3 = @Attribute3,
														 @pAttribute4 = @Attribute4,
														 @pAttribute5 = @Attribute5,
														 @pBasicDate = @BasicDate,
														 @pInvoiceNo = @InvoiceNo,
														 @pToSWarehouse=@ToSWarehouse,
														 @pIsConfirm = @IsConfirm,
														 @pDateConfirm =@DateConfirm
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

