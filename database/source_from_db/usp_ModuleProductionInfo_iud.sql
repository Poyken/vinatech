-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-10-21
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ModuleProductionInfo_iud
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
  DECLARE @OldModuleProductionNo VARCHAR(20)
  DECLARE @ModuleProductionNo VARCHAR(20)
  DECLARE @JobStartDate DATE
  DECLARE @SemiProdLotNo1 VARCHAR(20)
  DECLARE @SemiProdLotNo2 VARCHAR(20)
  DECLARE @PinHoleQty NUMERIC(20,5)
  DECLARE @ChangeCellQty NUMERIC(20,5)
  DECLARE @DefectRepairRemark NVARCHAR(MAX)
  DECLARE @Farad NUMERIC(20,5)
  DECLARE @ESR NUMERIC(20,5)
  DECLARE @FinishedProdLotNo VARCHAR(20)
  DECLARE @ShipmentDate DATE
  DECLARE @ShipmentQty NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModuleProductionInfo',
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
									OldModuleProductionNo,
									ModuleProductionNo,
									JobStartDate,
									SemiProdLotNo1,
									SemiProdLotNo2,
									PinHoleQty,
									ChangeCellQty,
									DefectRepairRemark,
									Farad,
									ESR,
									FinishedProdLotNo,
									ShipmentDate,
									ShipmentQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModuleProductionNo VARCHAR(20),
											 ModuleProductionNo VARCHAR(20),
											 JobStartDate DATETIMEOFFSET,
											 SemiProdLotNo1 VARCHAR(20),
											 SemiProdLotNo2 VARCHAR(20),
											 PinHoleQty NUMERIC(20,5),
											 ChangeCellQty NUMERIC(20,5),
											 DefectRepairRemark NVARCHAR(MAX),
											 Farad NUMERIC(20,5),
											 ESR NUMERIC(20,5),
											 FinishedProdLotNo VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentQty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleProductionNo IS NULL THEN ModuleProductionNo
										ELSE OldModuleProductionNo
									END AS OldModuleProductionNo,
									ModuleProductionNo,
									JobStartDate,
									SemiProdLotNo1,
									SemiProdLotNo2,
									PinHoleQty,
									ChangeCellQty,
									DefectRepairRemark,
									Farad,
									ESR,
									FinishedProdLotNo,
									ShipmentDate,
									ShipmentQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModuleProductionNo VARCHAR(20),
											 ModuleProductionNo VARCHAR(20),
											 JobStartDate DATETIMEOFFSET,
											 SemiProdLotNo1 VARCHAR(20),
											 SemiProdLotNo2 VARCHAR(20),
											 PinHoleQty NUMERIC(20,5),
											 ChangeCellQty NUMERIC(20,5),
											 DefectRepairRemark NVARCHAR(MAX),
											 Farad NUMERIC(20,5),
											 ESR NUMERIC(20,5),
											 FinishedProdLotNo VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentQty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleProductionNo IS NULL THEN ModuleProductionNo
										ELSE OldModuleProductionNo
									END AS OldModuleProductionNo,
									ModuleProductionNo,
									JobStartDate,
									SemiProdLotNo1,
									SemiProdLotNo2,
									PinHoleQty,
									ChangeCellQty,
									DefectRepairRemark,
									Farad,
									ESR,
									FinishedProdLotNo,
									ShipmentDate,
									ShipmentQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModuleProductionNo VARCHAR(20),
											 ModuleProductionNo VARCHAR(20),
											 JobStartDate DATETIMEOFFSET,
											 SemiProdLotNo1 VARCHAR(20),
											 SemiProdLotNo2 VARCHAR(20),
											 PinHoleQty NUMERIC(20,5),
											 ChangeCellQty NUMERIC(20,5),
											 DefectRepairRemark NVARCHAR(MAX),
											 Farad NUMERIC(20,5),
											 ESR NUMERIC(20,5),
											 FinishedProdLotNo VARCHAR(20),
											 ShipmentDate DATETIMEOFFSET,
											 ShipmentQty NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldModuleProductionNo,
								 @ModuleProductionNo,
								 @JobStartDate,
								 @SemiProdLotNo1,
								 @SemiProdLotNo2,
								 @PinHoleQty,
								 @ChangeCellQty,
								 @DefectRepairRemark,
								 @Farad,
								 @ESR,
								 @FinishedProdLotNo,
								 @ShipmentDate,
								 @ShipmentQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ModuleProductionInfo WHERE ModuleProductionNo = @ModuleProductionNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModuleProductionNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ModuleProductionInfo',@ModuleProductionNo OUTPUT
                    END

                    INSERT INTO STB_ModuleProductionInfo
						(
						    ModuleProductionNo,
						    JobStartDate,
						    SemiProdLotNo1,
						    SemiProdLotNo2,
						    PinHoleQty,
						    ChangeCellQty,
						    DefectRepairRemark,
						    Farad,
						    ESR,
						    FinishedProdLotNo,
						    ShipmentDate,
						    ShipmentQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ModuleProductionNo,
						    @JobStartDate,
						    @SemiProdLotNo1,
						    @SemiProdLotNo2,
						    @PinHoleQty,
						    @ChangeCellQty,
						    @DefectRepairRemark,
						    @Farad,
						    @ESR,
						    @FinishedProdLotNo,
						    @ShipmentDate,
						    @ShipmentQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ModuleProductionInfo
						SET
						    ModuleProductionNo =   ISNULL(@ModuleProductionNo,ModuleProductionNo),
						    JobStartDate =   ISNULL(@JobStartDate,JobStartDate),
						    SemiProdLotNo1 =   ISNULL(@SemiProdLotNo1,SemiProdLotNo1),
						    SemiProdLotNo2 =   ISNULL(@SemiProdLotNo2,SemiProdLotNo2),
						    PinHoleQty =   ISNULL(@PinHoleQty,PinHoleQty),
						    ChangeCellQty =   ISNULL(@ChangeCellQty,ChangeCellQty),
						    DefectRepairRemark =   ISNULL(@DefectRepairRemark,DefectRepairRemark),
						    Farad =   ISNULL(@Farad,Farad),
						    ESR =   ISNULL(@ESR,ESR),
						    FinishedProdLotNo =   ISNULL(@FinishedProdLotNo,FinishedProdLotNo),
						    ShipmentDate =   ISNULL(@ShipmentDate,ShipmentDate),
						    ShipmentQty =   ISNULL(@ShipmentQty,ShipmentQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ModuleProductionNo = @OldModuleProductionNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModuleProductionInfo
						WHERE
						    ModuleProductionNo = @OldModuleProductionNo
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
