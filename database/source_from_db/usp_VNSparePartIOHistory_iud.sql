-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 입출고 이력 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNSparePartIOHistory_iud]
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
  DECLARE @OldSparePartIOHistoryNo VARCHAR(20)
  DECLARE @SparePartIOHistoryNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @SPWarehouseCode VARCHAR(20)
  DECLARE @SPLocationCode VARCHAR(20)
  DECLARE @SparePartIOTypeCode VARCHAR(20)
  DECLARE @SparePartCode VARCHAR(20)
  DECLARE @PONo VARCHAR(20)
  DECLARE @VendorCode VARCHAR(20)
  DECLARE @UnitPrice NUMERIC(20,5)
  DECLARE @ProcessQty NUMERIC(20,5)
  DECLARE @HistoryText NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @CurlingGomaUniqueNo VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
 -- DECLARE @EmployeeDepartment NVARCHAR(50)
  DECLARE @CodeEmp NVARCHAR(50)
  DECLARE @Attribute1 NVARCHAR(200)
  DECLARE @Attribute2  NVARCHAR(200)
  DECLARE @Attribute3 NVARCHAR(200)
  DECLARE @Attribute4 NVARCHAR(200)
  DECLARE @Attribute5 NVARCHAR(200)
  DECLARE @BasicDate Date 
  DECLARE @InvoiceNo NVARCHAR(200)
  

  DECLARE @IOType VARCHAR(1)
  
  DECLARE @OldSparePartCode VARCHAR(20)
  DECLARE @OldSPLocationCode VARCHAR(20)
  DECLARE @OldProcessQty NUMERIC(20,5)
  

  DECLARE @MachineCode VARCHAR(20)
  DECLARE @BasicUnitPrice NUMERIC(15,2)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VNSparePartIOHistory',
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
									XMLData.OldSparePartIOHistoryNo,
									XMLData.SparePartIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartCode,
									XMLData.PONo,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.ProcessQty,
									XMLData.HistoryText,
									XMLData.MachineCode,
									XMLData.BasicUnitPrice,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CurlingGomaUniqueNo,
									XMLData.LineCode,
									XMLData.CodeEmp,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSparePartIOHistoryNo VARCHAR(20),
											 SparePartIOHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartCode VARCHAR(20),
											 PONo VARCHAR(20),
											 VendorCode VARCHAR(20),
											 UnitPrice NUMERIC(20,5),
											 ProcessQty NUMERIC(20,5),
											 HistoryText NVARCHAR(100),
											 MachineCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(15,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CurlingGomaUniqueNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 CodeEmp NVARCHAR(50),
											 Attribute1 NVARCHAR(200),
											 Attribute2  NVARCHAR(200),
											 Attribute3 NVARCHAR(200),
											 Attribute4 NVARCHAR(200),
											 Attribute5 NVARCHAR(200),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(200)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSparePartIOHistoryNo IS NULL THEN XMLData.SparePartIOHistoryNo
										ELSE XMLData.OldSparePartIOHistoryNo
									END AS OldSparePartIOHistoryNo,
									XMLData.SparePartIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartCode,
									XMLData.PONo,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.ProcessQty,
									XMLData.HistoryText,
									XMLData.MachineCode,
									XMLData.BasicUnitPrice,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CurlingGomaUniqueNo,
									XMLData.LineCode,
									XMLData.CodeEmp,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSparePartIOHistoryNo VARCHAR(20),
											 SparePartIOHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartCode VARCHAR(20),
											 PONo VARCHAR(20),
											 VendorCode VARCHAR(20),
											 UnitPrice NUMERIC(20,5),
											 ProcessQty NUMERIC(20,5),
											 HistoryText NVARCHAR(100),
											 MachineCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(15,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CurlingGomaUniqueNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 CodeEmp NVARCHAR(50),
											 Attribute1 NVARCHAR(200),
											 Attribute2  NVARCHAR(200),
											 Attribute3 NVARCHAR(200),
											 Attribute4 NVARCHAR(200),
											 Attribute5 NVARCHAR(200),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(200)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSparePartIOHistoryNo IS NULL THEN XMLData.SparePartIOHistoryNo
										ELSE XMLData.OldSparePartIOHistoryNo
									END AS OldSparePartIOHistoryNo,
									XMLData.SparePartIOHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartCode,
									XMLData.PONo,
									XMLData.VendorCode,
									XMLData.UnitPrice,
									XMLData.ProcessQty,
									XMLData.HistoryText,
									XMLData.MachineCode,
									XMLData.BasicUnitPrice,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CurlingGomaUniqueNo,
									XMLData.LineCode,
									XMLData.CodeEmp,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4, 
									XMLData.Attribute5, 
									XMLData.BasicDate,
									XMLData.InvoiceNo
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSparePartIOHistoryNo VARCHAR(20),
											 SparePartIOHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartCode VARCHAR(20),
											 PONo VARCHAR(20),
											 VendorCode VARCHAR(20),
											 UnitPrice NUMERIC(20,5),
											 ProcessQty NUMERIC(20,5),
											 HistoryText NVARCHAR(100),
											 MachineCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(15,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CurlingGomaUniqueNo VARCHAR(20),
											 LineCode VARCHAR(20),
											 CodeEmp NVARCHAR(50),
											 Attribute1 NVARCHAR(200),
											 Attribute2  NVARCHAR(200),
											 Attribute3 NVARCHAR(200),
											 Attribute4 NVARCHAR(200),
											 Attribute5 NVARCHAR(200),
											 BasicDate Date,
											 InvoiceNo NVARCHAR(200)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSparePartIOHistoryNo,
								 @SparePartIOHistoryNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @SPWarehouseCode,
								 @SPLocationCode,
								 @SparePartIOTypeCode,
								 @IOType,
								 @SparePartCode,
								 @PONo,
								 @VendorCode,
								 @UnitPrice,
								 @ProcessQty,
								 @HistoryText,
								 @MachineCode,
								 @BasicUnitPrice,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CurlingGomaUniqueNo,
								 @LineCode,
								 @CodeEmp,
								 @Attribute1,
								 @Attribute2,
								 @Attribute3,
								 @Attribute4,
								 @Attribute5,
								 @BasicDate,
								 @InvoiceNo


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				if(@SparePartCode='' or @SparePartCode is null) set @SparePartCode = @PONo  --Modified by Mr.Tung for Vietnam Account in 2022-Sep-18
							
				IF @IOType = 'I' BEGIN
					--스페어파트 입고이력관리
					EXEC usp_VNDoSparePartInHistory_iud	@pCompanyCode = @CompanyCode,
														@pWorkCenterCode = @WorkCenterCode,
														@pOldSparePartIOHistoryNo = @OldSparePartIOHistoryNo,
														@pSparePartIOHistoryNo = @SparePartIOHistoryNo,
														@pSPWarehouseCode = @SPWarehouseCode,
														@pSparePartCode = @SparePartCode,
														@pSPLocationCode = @SPLocationCode,
														@pSparePartIOTypeCode = @SparePartIOTypeCode,
														@pVendorCode = @VendorCode,
														@pUnitPrice = @BasicUnitPrice,
														@pProcessQty = @ProcessQty,
														@pHistoryText = @HistoryText,
														@pIUD_FLAG = @IUD_FLAG,
														@pProcessUserID = @ProcessUserID,
														@pPrefixString = @PrefixString,
														@pSerialLen = @SerialLen,
														@pCurlingGomaUniqueNo = @CurlingGomaUniqueNo,
														@pCodeEmp = @CodeEmp,
														@pAttribute1 = @Attribute1,
														@pAttribute2 = @Attribute2,
														@pAttribute3 = @Attribute3,
														@pAttribute4 = @Attribute4,
														@pAttribute5 = @Attribute5,
														@pBasicDate = @BasicDate,
														@pInvoiceNo = @InvoiceNo
				END										
	
				IF @IOType in ('O','U','M') BEGIN   --Modified by Mr.Tung for Vietnam , add  U  M  in 2022-Sep-18
					
					IF @MachineCode IS NULL BEGIN
						
						--스페어파트 출고이력관리
						EXEC usp_VNDoSparePartOutHistory_iud  @pCompanyCode = @CompanyCode,
															@pWorkCenterCode = @WorkCenterCode,
															@pOldSparePartIOHistoryNo = @OldSparePartIOHistoryNo,
															@pSparePartIOHistoryNo = @SparePartIOHistoryNo,
															@pSPWarehouseCode = @SPWarehouseCode,
															@pSparePartCode = @SparePartCode,
															@pSPLocationCode = @SPLocationCode,
															@pSparePartIOTypeCode = @SparePartIOTypeCode,
															@pProcessQty = @ProcessQty,
															@pHistoryText = @HistoryText,
															@pBasicUnitPrice = @BasicUnitPrice,
															@pIUD_FLAG = @IUD_FLAG,
															@pProcessUserID = @ProcessUserID,
															@pPrefixString = @PrefixString,
															@pSerialLen = @SerialLen,
															@pCurlingGomaUniqueNo = @CurlingGomaUniqueNo,
															@pLineCode = @LineCode,
															@pCodeEmp = @CodeEmp,
															@pAttribute1 = @Attribute1,
															@pAttribute2 = @Attribute2,
															@pAttribute3 = @Attribute3,
															@pAttribute4 = @Attribute4,
															@pAttribute5 = @Attribute5,
															@pBasicDate = @BasicDate

					END ELSE BEGIN
						
						--스페어파트 출고이력관리(화면에서 설비를 선택하는 경우 스페어파트교체이력정보 IUD 포함)
						
						EXEC usp_VNDoSparePartOutHistoryByMachine_iud @pCompanyCode = @CompanyCode,
																	@pWorkCenterCode = @WorkCenterCode,
																	@pOldSparePartIOHistoryNo = @OldSparePartIOHistoryNo,
																	@pSparePartIOHistoryNo = @SparePartIOHistoryNo,
																	@pSPWarehouseCode = @SPWarehouseCode,
																	@pSparePartCode = @SparePartCode,
																	@pSPLocationCode = @SPLocationCode,
																	@pSparePartIOTypeCode = @SparePartIOTypeCode,
																	@pVendorCode = @VendorCode,
																	@pUnitPrice = @BasicUnitPrice,
																	@pProcessQty = @ProcessQty,
																	@pHistoryText = @HistoryText,
																	@pMachineCode = @MachineCode,
																	@pBasicUnitPrice = @BasicUnitPrice,
																	@pIUD_FLAG = @IUD_FLAG,
																	
																	@pProcessUserID = @ProcessUserID,
																	@pPrefixString = @PrefixString,
																	@pSerialLen = @SerialLen,
																	@pCurlingGomaUniqueNo = @CurlingGomaUniqueNo,
																	@pCodeEmp = @CodeEmp,
																	@pAttribute1 = @Attribute1,
																	@pAttribute2 = @Attribute2,
																	@pAttribute3 = @Attribute3,
																	@pAttribute4 = @Attribute4,
																	@pAttribute5 = @Attribute5,
																	@pBasicDate = @BasicDate
																													
					END
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

