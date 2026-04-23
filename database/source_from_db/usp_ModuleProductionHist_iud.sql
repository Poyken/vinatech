-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-02
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ModuleProductionHist_iud
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
  DECLARE @OldModuleProductionHistNo VARCHAR(20)
  DECLARE @ModuleProductionHistNo VARCHAR(20)
  DECLARE @MPHExtText01 VARCHAR(MAX)
  DECLARE @MPHExtText02 VARCHAR(MAX)
  DECLARE @MPHExtText03 VARCHAR(MAX)
  DECLARE @MPHExtText04 VARCHAR(MAX)
  DECLARE @MPHExtText05 VARCHAR(MAX)
  DECLARE @MPHExtText06 VARCHAR(MAX)
  DECLARE @MPHExtText07 VARCHAR(MAX)
  DECLARE @MPHExtText08 VARCHAR(MAX)
  DECLARE @MPHExtText09 VARCHAR(MAX)
  DECLARE @MPHExtText10 VARCHAR(MAX)
  DECLARE @MPHExtInt01 BIGINT
  DECLARE @MPHExtInt02 BIGINT
  DECLARE @MPHExtInt03 BIGINT
  DECLARE @MPHExtInt04 BIGINT
  DECLARE @MPHExtInt05 BIGINT
  DECLARE @MPHExtInt06 BIGINT
  DECLARE @MPHExtInt07 BIGINT
  DECLARE @MPHExtInt08 BIGINT
  DECLARE @MPHExtInt09 BIGINT
  DECLARE @MPHExtInt10 BIGINT
  DECLARE @MPHExtReal01 NUMERIC(20,5)
  DECLARE @MPHExtReal02 NUMERIC(20,5)
  DECLARE @MPHExtReal03 NUMERIC(20,5)
  DECLARE @MPHExtReal04 NUMERIC(20,5)
  DECLARE @MPHExtReal05 NUMERIC(20,5)
  DECLARE @MPHExtReal06 NUMERIC(20,5)
  DECLARE @MPHExtReal07 NUMERIC(20,5)
  DECLARE @MPHExtReal08 NUMERIC(20,5)
  DECLARE @MPHExtReal09 NUMERIC(20,5)
  DECLARE @MPHExtReal10 NUMERIC(20,5)
  DECLARE @MPHExtDate01 DATETIME
  DECLARE @MPHExtDate02 DATETIME
  DECLARE @MPHExtDate03 DATETIME
  DECLARE @MPHExtDate04 DATETIME
  DECLARE @MPHExtDate05 DATETIME
  DECLARE @MPHExtDate06 DATETIME
  DECLARE @MPHExtDate07 DATETIME
  DECLARE @MPHExtDate08 DATETIME
  DECLARE @MPHExtDate09 DATETIME
  DECLARE @MPHExtDate10 DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModuleProductionHist',
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
									OldModuleProductionHistNo,
									ModuleProductionHistNo,
									MPHExtText01,
									MPHExtText02,
									MPHExtText03,
									MPHExtText04,
									MPHExtText05,
									MPHExtText06,
									MPHExtText07,
									MPHExtText08,
									MPHExtText09,
									MPHExtText10,
									MPHExtInt01,
									MPHExtInt02,
									MPHExtInt03,
									MPHExtInt04,
									MPHExtInt05,
									MPHExtInt06,
									MPHExtInt07,
									MPHExtInt08,
									MPHExtInt09,
									MPHExtInt10,
									MPHExtReal01,
									MPHExtReal02,
									MPHExtReal03,
									MPHExtReal04,
									MPHExtReal05,
									MPHExtReal06,
									MPHExtReal07,
									MPHExtReal08,
									MPHExtReal09,
									MPHExtReal10,
									MPHExtDate01,
									MPHExtDate02,
									MPHExtDate03,
									MPHExtDate04,
									MPHExtDate05,
									MPHExtDate06,
									MPHExtDate07,
									MPHExtDate08,
									MPHExtDate09,
									MPHExtDate10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModuleProductionHistNo VARCHAR(20),
											 ModuleProductionHistNo VARCHAR(20),
											 MPHExtText01 VARCHAR(MAX),
											 MPHExtText02 VARCHAR(MAX),
											 MPHExtText03 VARCHAR(MAX),
											 MPHExtText04 VARCHAR(MAX),
											 MPHExtText05 VARCHAR(MAX),
											 MPHExtText06 VARCHAR(MAX),
											 MPHExtText07 VARCHAR(MAX),
											 MPHExtText08 VARCHAR(MAX),
											 MPHExtText09 VARCHAR(MAX),
											 MPHExtText10 VARCHAR(MAX),
											 MPHExtInt01 BIGINT,
											 MPHExtInt02 BIGINT,
											 MPHExtInt03 BIGINT,
											 MPHExtInt04 BIGINT,
											 MPHExtInt05 BIGINT,
											 MPHExtInt06 BIGINT,
											 MPHExtInt07 BIGINT,
											 MPHExtInt08 BIGINT,
											 MPHExtInt09 BIGINT,
											 MPHExtInt10 BIGINT,
											 MPHExtReal01 NUMERIC(20,5),
											 MPHExtReal02 NUMERIC(20,5),
											 MPHExtReal03 NUMERIC(20,5),
											 MPHExtReal04 NUMERIC(20,5),
											 MPHExtReal05 NUMERIC(20,5),
											 MPHExtReal06 NUMERIC(20,5),
											 MPHExtReal07 NUMERIC(20,5),
											 MPHExtReal08 NUMERIC(20,5),
											 MPHExtReal09 NUMERIC(20,5),
											 MPHExtReal10 NUMERIC(20,5),
											 MPHExtDate01 DATETIMEOFFSET,
											 MPHExtDate02 DATETIMEOFFSET,
											 MPHExtDate03 DATETIMEOFFSET,
											 MPHExtDate04 DATETIMEOFFSET,
											 MPHExtDate05 DATETIMEOFFSET,
											 MPHExtDate06 DATETIMEOFFSET,
											 MPHExtDate07 DATETIMEOFFSET,
											 MPHExtDate08 DATETIMEOFFSET,
											 MPHExtDate09 DATETIMEOFFSET,
											 MPHExtDate10 DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleProductionHistNo IS NULL THEN ModuleProductionHistNo
										ELSE OldModuleProductionHistNo
									END AS OldModuleProductionHistNo,
									ModuleProductionHistNo,
									MPHExtText01,
									MPHExtText02,
									MPHExtText03,
									MPHExtText04,
									MPHExtText05,
									MPHExtText06,
									MPHExtText07,
									MPHExtText08,
									MPHExtText09,
									MPHExtText10,
									MPHExtInt01,
									MPHExtInt02,
									MPHExtInt03,
									MPHExtInt04,
									MPHExtInt05,
									MPHExtInt06,
									MPHExtInt07,
									MPHExtInt08,
									MPHExtInt09,
									MPHExtInt10,
									MPHExtReal01,
									MPHExtReal02,
									MPHExtReal03,
									MPHExtReal04,
									MPHExtReal05,
									MPHExtReal06,
									MPHExtReal07,
									MPHExtReal08,
									MPHExtReal09,
									MPHExtReal10,
									MPHExtDate01,
									MPHExtDate02,
									MPHExtDate03,
									MPHExtDate04,
									MPHExtDate05,
									MPHExtDate06,
									MPHExtDate07,
									MPHExtDate08,
									MPHExtDate09,
									MPHExtDate10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModuleProductionHistNo VARCHAR(20),
											 ModuleProductionHistNo VARCHAR(20),
											 MPHExtText01 VARCHAR(MAX),
											 MPHExtText02 VARCHAR(MAX),
											 MPHExtText03 VARCHAR(MAX),
											 MPHExtText04 VARCHAR(MAX),
											 MPHExtText05 VARCHAR(MAX),
											 MPHExtText06 VARCHAR(MAX),
											 MPHExtText07 VARCHAR(MAX),
											 MPHExtText08 VARCHAR(MAX),
											 MPHExtText09 VARCHAR(MAX),
											 MPHExtText10 VARCHAR(MAX),
											 MPHExtInt01 BIGINT,
											 MPHExtInt02 BIGINT,
											 MPHExtInt03 BIGINT,
											 MPHExtInt04 BIGINT,
											 MPHExtInt05 BIGINT,
											 MPHExtInt06 BIGINT,
											 MPHExtInt07 BIGINT,
											 MPHExtInt08 BIGINT,
											 MPHExtInt09 BIGINT,
											 MPHExtInt10 BIGINT,
											 MPHExtReal01 NUMERIC(20,5),
											 MPHExtReal02 NUMERIC(20,5),
											 MPHExtReal03 NUMERIC(20,5),
											 MPHExtReal04 NUMERIC(20,5),
											 MPHExtReal05 NUMERIC(20,5),
											 MPHExtReal06 NUMERIC(20,5),
											 MPHExtReal07 NUMERIC(20,5),
											 MPHExtReal08 NUMERIC(20,5),
											 MPHExtReal09 NUMERIC(20,5),
											 MPHExtReal10 NUMERIC(20,5),
											 MPHExtDate01 DATETIMEOFFSET,
											 MPHExtDate02 DATETIMEOFFSET,
											 MPHExtDate03 DATETIMEOFFSET,
											 MPHExtDate04 DATETIMEOFFSET,
											 MPHExtDate05 DATETIMEOFFSET,
											 MPHExtDate06 DATETIMEOFFSET,
											 MPHExtDate07 DATETIMEOFFSET,
											 MPHExtDate08 DATETIMEOFFSET,
											 MPHExtDate09 DATETIMEOFFSET,
											 MPHExtDate10 DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldModuleProductionHistNo IS NULL THEN ModuleProductionHistNo
										ELSE OldModuleProductionHistNo
									END AS OldModuleProductionHistNo,
									ModuleProductionHistNo,
									MPHExtText01,
									MPHExtText02,
									MPHExtText03,
									MPHExtText04,
									MPHExtText05,
									MPHExtText06,
									MPHExtText07,
									MPHExtText08,
									MPHExtText09,
									MPHExtText10,
									MPHExtInt01,
									MPHExtInt02,
									MPHExtInt03,
									MPHExtInt04,
									MPHExtInt05,
									MPHExtInt06,
									MPHExtInt07,
									MPHExtInt08,
									MPHExtInt09,
									MPHExtInt10,
									MPHExtReal01,
									MPHExtReal02,
									MPHExtReal03,
									MPHExtReal04,
									MPHExtReal05,
									MPHExtReal06,
									MPHExtReal07,
									MPHExtReal08,
									MPHExtReal09,
									MPHExtReal10,
									MPHExtDate01,
									MPHExtDate02,
									MPHExtDate03,
									MPHExtDate04,
									MPHExtDate05,
									MPHExtDate06,
									MPHExtDate07,
									MPHExtDate08,
									MPHExtDate09,
									MPHExtDate10,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModuleProductionHistNo VARCHAR(20),
											 ModuleProductionHistNo VARCHAR(20),
											 MPHExtText01 VARCHAR(MAX),
											 MPHExtText02 VARCHAR(MAX),
											 MPHExtText03 VARCHAR(MAX),
											 MPHExtText04 VARCHAR(MAX),
											 MPHExtText05 VARCHAR(MAX),
											 MPHExtText06 VARCHAR(MAX),
											 MPHExtText07 VARCHAR(MAX),
											 MPHExtText08 VARCHAR(MAX),
											 MPHExtText09 VARCHAR(MAX),
											 MPHExtText10 VARCHAR(MAX),
											 MPHExtInt01 BIGINT,
											 MPHExtInt02 BIGINT,
											 MPHExtInt03 BIGINT,
											 MPHExtInt04 BIGINT,
											 MPHExtInt05 BIGINT,
											 MPHExtInt06 BIGINT,
											 MPHExtInt07 BIGINT,
											 MPHExtInt08 BIGINT,
											 MPHExtInt09 BIGINT,
											 MPHExtInt10 BIGINT,
											 MPHExtReal01 NUMERIC(20,5),
											 MPHExtReal02 NUMERIC(20,5),
											 MPHExtReal03 NUMERIC(20,5),
											 MPHExtReal04 NUMERIC(20,5),
											 MPHExtReal05 NUMERIC(20,5),
											 MPHExtReal06 NUMERIC(20,5),
											 MPHExtReal07 NUMERIC(20,5),
											 MPHExtReal08 NUMERIC(20,5),
											 MPHExtReal09 NUMERIC(20,5),
											 MPHExtReal10 NUMERIC(20,5),
											 MPHExtDate01 DATETIMEOFFSET,
											 MPHExtDate02 DATETIMEOFFSET,
											 MPHExtDate03 DATETIMEOFFSET,
											 MPHExtDate04 DATETIMEOFFSET,
											 MPHExtDate05 DATETIMEOFFSET,
											 MPHExtDate06 DATETIMEOFFSET,
											 MPHExtDate07 DATETIMEOFFSET,
											 MPHExtDate08 DATETIMEOFFSET,
											 MPHExtDate09 DATETIMEOFFSET,
											 MPHExtDate10 DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldModuleProductionHistNo,
								 @ModuleProductionHistNo,
								 @MPHExtText01,
								 @MPHExtText02,
								 @MPHExtText03,
								 @MPHExtText04,
								 @MPHExtText05,
								 @MPHExtText06,
								 @MPHExtText07,
								 @MPHExtText08,
								 @MPHExtText09,
								 @MPHExtText10,
								 @MPHExtInt01,
								 @MPHExtInt02,
								 @MPHExtInt03,
								 @MPHExtInt04,
								 @MPHExtInt05,
								 @MPHExtInt06,
								 @MPHExtInt07,
								 @MPHExtInt08,
								 @MPHExtInt09,
								 @MPHExtInt10,
								 @MPHExtReal01,
								 @MPHExtReal02,
								 @MPHExtReal03,
								 @MPHExtReal04,
								 @MPHExtReal05,
								 @MPHExtReal06,
								 @MPHExtReal07,
								 @MPHExtReal08,
								 @MPHExtReal09,
								 @MPHExtReal10,
								 @MPHExtDate01,
								 @MPHExtDate02,
								 @MPHExtDate03,
								 @MPHExtDate04,
								 @MPHExtDate05,
								 @MPHExtDate06,
								 @MPHExtDate07,
								 @MPHExtDate08,
								 @MPHExtDate09,
								 @MPHExtDate10,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
					-- Pliops건이면 모듈번호가 존재하는지 체크한다.
					IF @MPHExtText01 = '13913' BEGIN
						IF NOT EXISTS (SELECT 1 FROM STB_ModuleLabelInfo WHERE ModuleSerialNo = @MPHExtText02) BEGIN
							RAISERROR('모듈 일련번호가 존재하지 않습니다. 모듈 라벨 정보를 확인하세요.', 16, 1)
						END
					END

                    IF EXISTS (SELECT 1 FROM STB_ModuleProductionHist WHERE ModuleProductionHistNo = @ModuleProductionHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModuleProductionHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_ModuleProductionHist',@ModuleProductionHistNo OUTPUT
                    END

                    INSERT INTO STB_ModuleProductionHist
						(
						    ModuleProductionHistNo,
						    MPHExtText01,
						    MPHExtText02,
						    MPHExtText03,
						    MPHExtText04,
						    MPHExtText05,
						    MPHExtText06,
						    MPHExtText07,
						    MPHExtText08,
						    MPHExtText09,
						    MPHExtText10,
						    MPHExtInt01,
						    MPHExtInt02,
						    MPHExtInt03,
						    MPHExtInt04,
						    MPHExtInt05,
						    MPHExtInt06,
						    MPHExtInt07,
						    MPHExtInt08,
						    MPHExtInt09,
						    MPHExtInt10,
						    MPHExtReal01,
						    MPHExtReal02,
						    MPHExtReal03,
						    MPHExtReal04,
						    MPHExtReal05,
						    MPHExtReal06,
						    MPHExtReal07,
						    MPHExtReal08,
						    MPHExtReal09,
						    MPHExtReal10,
						    MPHExtDate01,
						    MPHExtDate02,
						    MPHExtDate03,
						    MPHExtDate04,
						    MPHExtDate05,
						    MPHExtDate06,
						    MPHExtDate07,
						    MPHExtDate08,
						    MPHExtDate09,
						    MPHExtDate10,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ModuleProductionHistNo,
						    @MPHExtText01,
						    @MPHExtText02,
						    @MPHExtText03,
						    @MPHExtText04,
						    @MPHExtText05,
						    @MPHExtText06,
						    @MPHExtText07,
						    @MPHExtText08,
						    @MPHExtText09,
						    @MPHExtText10,
						    @MPHExtInt01,
						    @MPHExtInt02,
						    @MPHExtInt03,
						    @MPHExtInt04,
						    @MPHExtInt05,
						    @MPHExtInt06,
						    @MPHExtInt07,
						    @MPHExtInt08,
						    @MPHExtInt09,
						    @MPHExtInt10,
						    @MPHExtReal01,
						    @MPHExtReal02,
						    @MPHExtReal03,
						    @MPHExtReal04,
						    @MPHExtReal05,
						    @MPHExtReal06,
						    @MPHExtReal07,
						    @MPHExtReal08,
						    @MPHExtReal09,
						    @MPHExtReal10,
						    @MPHExtDate01,
						    @MPHExtDate02,
						    @MPHExtDate03,
						    @MPHExtDate04,
						    @MPHExtDate05,
						    @MPHExtDate06,
						    @MPHExtDate07,
						    @MPHExtDate08,
						    @MPHExtDate09,
						    @MPHExtDate10,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					-- Pliops건이면 모듈번호가 존재하는지 체크한다.
					IF @MPHExtText01 = '13913' BEGIN
						IF NOT EXISTS (SELECT 1 FROM STB_ModuleLabelInfo WHERE ModuleSerialNo = @MPHExtText02) BEGIN
							RAISERROR('모듈 일련번호가 존재하지 않습니다. 모듈 라벨 정보를 확인하세요.', 16, 1)
						END
					END

                    UPDATE STB_ModuleProductionHist
						SET
						    ModuleProductionHistNo =   ISNULL(@ModuleProductionHistNo,ModuleProductionHistNo),
						    MPHExtText01 =   ISNULL(@MPHExtText01,MPHExtText01),
						    MPHExtText02 =   ISNULL(@MPHExtText02,MPHExtText02),
						    MPHExtText03 =   ISNULL(@MPHExtText03,MPHExtText03),
						    MPHExtText04 =   ISNULL(@MPHExtText04,MPHExtText04),
						    MPHExtText05 =   ISNULL(@MPHExtText05,MPHExtText05),
						    MPHExtText06 =   ISNULL(@MPHExtText06,MPHExtText06),
						    MPHExtText07 =   ISNULL(@MPHExtText07,MPHExtText07),
						    MPHExtText08 =   ISNULL(@MPHExtText08,MPHExtText08),
						    MPHExtText09 =   ISNULL(@MPHExtText09,MPHExtText09),
						    MPHExtText10 =   ISNULL(@MPHExtText10,MPHExtText10),
						    MPHExtInt01 =   ISNULL(@MPHExtInt01,MPHExtInt01),
						    MPHExtInt02 =   ISNULL(@MPHExtInt02,MPHExtInt02),
						    MPHExtInt03 =   ISNULL(@MPHExtInt03,MPHExtInt03),
						    MPHExtInt04 =   ISNULL(@MPHExtInt04,MPHExtInt04),
						    MPHExtInt05 =   ISNULL(@MPHExtInt05,MPHExtInt05),
						    MPHExtInt06 =   ISNULL(@MPHExtInt06,MPHExtInt06),
						    MPHExtInt07 =   ISNULL(@MPHExtInt07,MPHExtInt07),
						    MPHExtInt08 =   ISNULL(@MPHExtInt08,MPHExtInt08),
						    MPHExtInt09 =   ISNULL(@MPHExtInt09,MPHExtInt09),
						    MPHExtInt10 =   ISNULL(@MPHExtInt10,MPHExtInt10),
						    MPHExtReal01 =   ISNULL(@MPHExtReal01,MPHExtReal01),
						    MPHExtReal02 =   ISNULL(@MPHExtReal02,MPHExtReal02),
						    MPHExtReal03 =   ISNULL(@MPHExtReal03,MPHExtReal03),
						    MPHExtReal04 =   ISNULL(@MPHExtReal04,MPHExtReal04),
						    MPHExtReal05 =   ISNULL(@MPHExtReal05,MPHExtReal05),
						    MPHExtReal06 =   ISNULL(@MPHExtReal06,MPHExtReal06),
						    MPHExtReal07 =   ISNULL(@MPHExtReal07,MPHExtReal07),
						    MPHExtReal08 =   ISNULL(@MPHExtReal08,MPHExtReal08),
						    MPHExtReal09 =   ISNULL(@MPHExtReal09,MPHExtReal09),
						    MPHExtReal10 =   ISNULL(@MPHExtReal10,MPHExtReal10),
						    MPHExtDate01 =   ISNULL(@MPHExtDate01,MPHExtDate01),
						    MPHExtDate02 =   ISNULL(@MPHExtDate02,MPHExtDate02),
						    MPHExtDate03 =   ISNULL(@MPHExtDate03,MPHExtDate03),
						    MPHExtDate04 =   ISNULL(@MPHExtDate04,MPHExtDate04),
						    MPHExtDate05 =   ISNULL(@MPHExtDate05,MPHExtDate05),
						    MPHExtDate06 =   ISNULL(@MPHExtDate06,MPHExtDate06),
						    MPHExtDate07 =   ISNULL(@MPHExtDate07,MPHExtDate07),
						    MPHExtDate08 =   ISNULL(@MPHExtDate08,MPHExtDate08),
						    MPHExtDate09 =   ISNULL(@MPHExtDate09,MPHExtDate09),
						    MPHExtDate10 =   ISNULL(@MPHExtDate10,MPHExtDate10),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ModuleProductionHistNo = @OldModuleProductionHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModuleProductionHist
						WHERE
						    ModuleProductionHistNo = @OldModuleProductionHistNo
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