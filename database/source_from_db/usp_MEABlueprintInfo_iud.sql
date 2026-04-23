-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-12
-- Browsable : true
-- Group : 도면관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_MEABlueprintInfo_iud
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
  DECLARE @OldMEABlueprintNo VARCHAR(20)
  DECLARE @MEABlueprintNo VARCHAR(20)
  DECLARE @MEABlueprintModelNo VARCHAR(20)
  DECLARE @MEABlueprintSerNo INT
  DECLARE @MEAClassCode VARCHAR(20)
  DECLARE @CathodeCatalystCode VARCHAR(20)
  DECLARE @AnodeCatalystCode VARCHAR(20)
  DECLARE @ElectrolyteMembraneCode VARCHAR(20)
  DECLARE @AreaValue VARCHAR(10)
  DECLARE @GDLValue VARCHAR(10)
  DECLARE @BlueprintFileID BIGINT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @FileName NVARCHAR(255)
  DECLARE @FileSize BIGINT
  DECLARE @FileData VARBINARY(MAX)

  Declare @NextBlueprintSerNo BIGINT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MEABlueprintInfo',
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
									OldMEABlueprintNo,
									MEABlueprintNo,
									MEABlueprintModelNo,
									MEABlueprintSerNo,
									MEAClassCode,
									CathodeCatalystCode,
									AnodeCatalystCode,
									ElectrolyteMembraneCode,
									AreaValue,
									GDLValue,
									BlueprintFileID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMEABlueprintNo VARCHAR(20),
											 MEABlueprintNo VARCHAR(20),
											 MEABlueprintModelNo VARCHAR(20),
											 MEABlueprintSerNo INT,
											 MEAClassCode VARCHAR(20),
											 CathodeCatalystCode VARCHAR(20),
											 AnodeCatalystCode VARCHAR(20),
											 ElectrolyteMembraneCode VARCHAR(20),
											 AreaValue VARCHAR(10),
											 GDLValue VARCHAR(10),
											 BlueprintFileID BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMEABlueprintNo IS NULL THEN MEABlueprintNo
										ELSE OldMEABlueprintNo
									END AS OldMEABlueprintNo,
									MEABlueprintNo,
									MEABlueprintModelNo,
									MEABlueprintSerNo,
									MEAClassCode,
									CathodeCatalystCode,
									AnodeCatalystCode,
									ElectrolyteMembraneCode,
									AreaValue,
									GDLValue,
									BlueprintFileID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMEABlueprintNo VARCHAR(20),
											 MEABlueprintNo VARCHAR(20),
											 MEABlueprintModelNo VARCHAR(20),
											 MEABlueprintSerNo INT,
											 MEAClassCode VARCHAR(20),
											 CathodeCatalystCode VARCHAR(20),
											 AnodeCatalystCode VARCHAR(20),
											 ElectrolyteMembraneCode VARCHAR(20),
											 AreaValue VARCHAR(10),
											 GDLValue VARCHAR(10),
											 BlueprintFileID BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMEABlueprintNo IS NULL THEN MEABlueprintNo
										ELSE OldMEABlueprintNo
									END AS OldMEABlueprintNo,
									MEABlueprintNo,
									MEABlueprintModelNo,
									MEABlueprintSerNo,
									MEAClassCode,
									CathodeCatalystCode,
									AnodeCatalystCode,
									ElectrolyteMembraneCode,
									AreaValue,
									GDLValue,
									BlueprintFileID,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMEABlueprintNo VARCHAR(20),
											 MEABlueprintNo VARCHAR(20),
											 MEABlueprintModelNo VARCHAR(20),
											 MEABlueprintSerNo INT,
											 MEAClassCode VARCHAR(20),
											 CathodeCatalystCode VARCHAR(20),
											 AnodeCatalystCode VARCHAR(20),
											 ElectrolyteMembraneCode VARCHAR(20),
											 AreaValue VARCHAR(10),
											 GDLValue VARCHAR(10),
											 BlueprintFileID BIGINT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMEABlueprintNo,
								 @MEABlueprintNo,
								 @MEABlueprintModelNo,
								 @MEABlueprintSerNo,
								 @MEAClassCode,
								 @CathodeCatalystCode,
								 @AnodeCatalystCode,
								 @ElectrolyteMembraneCode,
								 @AreaValue,
								 @GDLValue,
								 @BlueprintFileID,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				-- 도면ID 초기화
				SET @BlueprintFileID = NULL

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MEABlueprintInfo WHERE MEABlueprintNo = @MEABlueprintNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MEABlueprintNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MEABlueprintInfo',@MEABlueprintNo OUTPUT
                    END

					-- 도면번호 조립
					SET @MEABlueprintModelNo = @MEAClassCode + '-' + @CathodeCatalystCode + @AnodeCatalystCode + @ElectrolyteMembraneCode + @AreaValue + '-G' + @GDLValue

					SELECT @NextBlueprintSerNo = ISNULL(MAX(MEABlueprintSerNo), 0) + 1
					  FROM STB_MEABlueprintInfo
					 WHERE MEABlueprintModelNo = @MEABlueprintModelNo

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MEABlueprintInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @BlueprintFileID OUTPUT

                    INSERT INTO STB_MEABlueprintInfo
						(
						    MEABlueprintNo,
						    MEABlueprintModelNo,
						    MEABlueprintSerNo,
						    MEAClassCode,
						    CathodeCatalystCode,
						    AnodeCatalystCode,
						    ElectrolyteMembraneCode,
						    AreaValue,
						    GDLValue,
						    BlueprintFileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MEABlueprintNo,
						    @MEABlueprintModelNo,
						    @NextBlueprintSerNo,
						    @MEAClassCode,
						    @CathodeCatalystCode,
						    @AnodeCatalystCode,
						    @ElectrolyteMembraneCode,
						    @AreaValue,
						    @GDLValue,
						    @BlueprintFileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    -- 업데이트를 해도 버전을 증가시킨다.
					--UPDATE STB_MEABlueprintInfo
					--	SET
					--	    MEABlueprintNo =   ISNULL(@MEABlueprintNo,MEABlueprintNo),
					--	    MEABlueprintModelNo =   ISNULL(@MEABlueprintModelNo,MEABlueprintModelNo),
					--	    MEABlueprintSerNo =   ISNULL(@MEABlueprintSerNo,MEABlueprintSerNo),
					--	    MEAClassCode =   ISNULL(@MEAClassCode,MEAClassCode),
					--	    CathodeCatalystCode =   ISNULL(@CathodeCatalystCode,CathodeCatalystCode),
					--	    AnodeCatalystCode =   ISNULL(@AnodeCatalystCode,AnodeCatalystCode),
					--	    ElectrolyteMembraneCode =   ISNULL(@ElectrolyteMembraneCode,ElectrolyteMembraneCode),
					--	    AreaValue =   ISNULL(@AreaValue,AreaValue),
					--	    GDLValue =   ISNULL(@GDLValue,GDLValue),
					--	    BlueprintFileID =   ISNULL(@BlueprintFileID,BlueprintFileID),
					--	    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
					--	    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
					--	    ChangeDateTime = GETDATE(),
					--	    ChangeUserID = @pProcessUserID
					--	WHERE
					--	    MEABlueprintNo = @OldMEABlueprintNo

					IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MEABlueprintInfo',@MEABlueprintNo OUTPUT
                    END

					-- 도면번호 조립
					SET @MEABlueprintModelNo = @MEAClassCode + '-' + @CathodeCatalystCode + @AnodeCatalystCode + @ElectrolyteMembraneCode + @AreaValue + '-G' + @GDLValue

					SELECT @NextBlueprintSerNo = ISNULL(MAX(MEABlueprintSerNo), 0) + 1
					  FROM STB_MEABlueprintInfo
					 WHERE MEABlueprintModelNo = @MEABlueprintModelNo

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MEABlueprintInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @BlueprintFileID OUTPUT

                    INSERT INTO STB_MEABlueprintInfo
						(
						    MEABlueprintNo,
						    MEABlueprintModelNo,
						    MEABlueprintSerNo,
						    MEAClassCode,
						    CathodeCatalystCode,
						    AnodeCatalystCode,
						    ElectrolyteMembraneCode,
						    AreaValue,
						    GDLValue,
						    BlueprintFileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MEABlueprintNo,
						    @MEABlueprintModelNo,
						    @NextBlueprintSerNo,
						    @MEAClassCode,
						    @CathodeCatalystCode,
						    @AnodeCatalystCode,
						    @ElectrolyteMembraneCode,
						    @AreaValue,
						    @GDLValue,
						    @BlueprintFileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MEABlueprintInfo
						WHERE
						    MEABlueprintNo = @OldMEABlueprintNo
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