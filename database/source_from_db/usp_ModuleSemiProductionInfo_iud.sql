-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-10-26
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ModuleSemiProductionInfo_iud
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
  DECLARE @OldModuleSemiProductionNo VARCHAR(20)
  DECLARE @ModuleSemiProductionNo VARCHAR(20)
  DECLARE @ProdDate DATE
  DECLARE @Grade VARCHAR(10)
  DECLARE @PCBLotNo VARCHAR(20)
  DECLARE @SemiProdLotNo VARCHAR(20)
  DECLARE @SingleCellLotNo1 VARCHAR(20)
  DECLARE @SingleCellLotNo2 VARCHAR(20)
  DECLARE @SingleCellLotNo3 VARCHAR(20)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModuleSemiProductionInfo',
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
									OldModuleSemiProductionNo,
									ModuleSemiProductionNo,
									ProdDate,
									Grade,
									PCBLotNo,
									SemiProdLotNo,
									SingleCellLotNo1,
									SingleCellLotNo2,
									SingleCellLotNo3,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModuleSemiProductionNo VARCHAR(20),
											 ModuleSemiProductionNo VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 Grade VARCHAR(10),
											 PCBLotNo VARCHAR(20),
											 SemiProdLotNo VARCHAR(20),
											 SingleCellLotNo1 VARCHAR(20),
											 SingleCellLotNo2 VARCHAR(20),
											 SingleCellLotNo3 VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleSemiProductionNo IS NULL THEN ModuleSemiProductionNo
										ELSE OldModuleSemiProductionNo
									END AS OldModuleSemiProductionNo,
									ModuleSemiProductionNo,
									ProdDate,
									Grade,
									PCBLotNo,
									SemiProdLotNo,
									SingleCellLotNo1,
									SingleCellLotNo2,
									SingleCellLotNo3,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModuleSemiProductionNo VARCHAR(20),
											 ModuleSemiProductionNo VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 Grade VARCHAR(10),
											 PCBLotNo VARCHAR(20),
											 SemiProdLotNo VARCHAR(20),
											 SingleCellLotNo1 VARCHAR(20),
											 SingleCellLotNo2 VARCHAR(20),
											 SingleCellLotNo3 VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleSemiProductionNo IS NULL THEN ModuleSemiProductionNo
										ELSE OldModuleSemiProductionNo
									END AS OldModuleSemiProductionNo,
									ModuleSemiProductionNo,
									ProdDate,
									Grade,
									PCBLotNo,
									SemiProdLotNo,
									SingleCellLotNo1,
									SingleCellLotNo2,
									SingleCellLotNo3,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModuleSemiProductionNo VARCHAR(20),
											 ModuleSemiProductionNo VARCHAR(20),
											 ProdDate DATETIMEOFFSET,
											 Grade VARCHAR(10),
											 PCBLotNo VARCHAR(20),
											 SemiProdLotNo VARCHAR(20),
											 SingleCellLotNo1 VARCHAR(20),
											 SingleCellLotNo2 VARCHAR(20),
											 SingleCellLotNo3 VARCHAR(20),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldModuleSemiProductionNo,
								 @ModuleSemiProductionNo,
								 @ProdDate,
								 @Grade,
								 @PCBLotNo,
								 @SemiProdLotNo,
								 @SingleCellLotNo1,
								 @SingleCellLotNo2,
								 @SingleCellLotNo3,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ModuleSemiProductionInfo WHERE ModuleSemiProductionNo = @ModuleSemiProductionNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModuleSemiProductionNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ModuleSemiProductionInfo',@ModuleSemiProductionNo OUTPUT
                    END

                    INSERT INTO STB_ModuleSemiProductionInfo
						(
						    ModuleSemiProductionNo,
						    ProdDate,
						    Grade,
						    PCBLotNo,
						    SemiProdLotNo,
						    SingleCellLotNo1,
						    SingleCellLotNo2,
						    SingleCellLotNo3,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ModuleSemiProductionNo,
						    @ProdDate,
						    @Grade,
						    @PCBLotNo,
						    @SemiProdLotNo,
						    @SingleCellLotNo1,
						    @SingleCellLotNo2,
						    @SingleCellLotNo3,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ModuleSemiProductionInfo
						SET
						    ModuleSemiProductionNo =   ISNULL(@ModuleSemiProductionNo,ModuleSemiProductionNo),
						    ProdDate =   ISNULL(@ProdDate,ProdDate),
						    Grade =   ISNULL(@Grade,Grade),
						    PCBLotNo =   ISNULL(@PCBLotNo,PCBLotNo),
						    SemiProdLotNo =   ISNULL(@SemiProdLotNo,SemiProdLotNo),
						    SingleCellLotNo1 =   ISNULL(@SingleCellLotNo1,SingleCellLotNo1),
						    SingleCellLotNo2 =   ISNULL(@SingleCellLotNo2,SingleCellLotNo2),
						    SingleCellLotNo3 =   ISNULL(@SingleCellLotNo3,SingleCellLotNo3),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ModuleSemiProductionNo = @OldModuleSemiProductionNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModuleSemiProductionInfo
						WHERE
						    ModuleSemiProductionNo = @OldModuleSemiProductionNo
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
