-- Procedure: usp_BoardType_iud



-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-07-06
-- Browsable : true
-- Group : 게시판
-- Description:	게시판유형을 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BoardType_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldBoardType VARCHAR(20)
  DECLARE @BoardType VARCHAR(20)
  DECLARE @Title NVARCHAR(100)
  DECLARE @TopImage VARBINARY(MAX)
  DECLARE @UseRange BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BoardType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BoardType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBoardType IS NULL THEN BoardType
							    ELSE OldBoardType
							END AS OldBoardType,
							BoardType,
							Title,
							dbo.fnBase64ToBinary(TopImage) as TopImage,
							UseRange,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBoardType VARCHAR(20),
										BoardType VARCHAR(20),
										Title NVARCHAR(100),
										TopImage NVARCHAR(MAX),
										UseRange BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BoardType = SourceTable.BoardType
				)

			WHEN MATCHED THEN
				UPDATE SET
					BoardType = ISNULL(SourceTable.BoardType,TargetTable.BoardType),
					Title = ISNULL(SourceTable.Title,TargetTable.Title),
					TopImage = ISNULL(SourceTable.TopImage,TargetTable.TopImage),
					UseRange = ISNULL(SourceTable.UseRange,TargetTable.UseRange),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BoardType,
						Title,
						TopImage,
						UseRange,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BoardType,
							SourceTable.Title,
							SourceTable.TopImage,
							SourceTable.UseRange,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_BoardType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBoardType IS NULL THEN BoardType
							    ELSE OldBoardType
							END AS OldBoardType,
							BoardType,
							Title,
							dbo.fnBase64ToBinary(TopImage) as TopImage,
							UseRange,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBoardType VARCHAR(20),
										BoardType VARCHAR(20),
										Title NVARCHAR(100),
										TopImage NVARCHAR(MAX),
										UseRange BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BoardType = SourceTable.OldBoardType
				)

			WHEN MATCHED THEN
				UPDATE SET
					BoardType = ISNULL(SourceTable.BoardType,TargetTable.BoardType),
					Title = ISNULL(SourceTable.Title,TargetTable.Title),
					TopImage = ISNULL(SourceTable.TopImage,TargetTable.TopImage),
					UseRange = ISNULL(SourceTable.UseRange,TargetTable.UseRange),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BoardType,
						Title,
						TopImage,
						UseRange,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BoardType,
							SourceTable.Title,
							SourceTable.TopImage,
							SourceTable.UseRange,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_BoardType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBoardType IS NULL THEN BoardType
							    ELSE OldBoardType
							END AS OldBoardType,
							BoardType,
							Title,
							dbo.fnBase64ToBinary(TopImage) as TopImage,
							UseRange,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBoardType VARCHAR(20),
										BoardType VARCHAR(20),
										Title NVARCHAR(100),
										TopImage NVARCHAR(MAX),
										UseRange BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BoardType = SourceTable.BoardType
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
									OldBoardType,
									BoardType,
									Title,
									dbo.fnBase64ToBinary(TopImage) as TopImage,
									UseRange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldBoardType VARCHAR(20),
											 BoardType VARCHAR(20),
											 Title NVARCHAR(100),
											 TopImage NVARCHAR(MAX),
											 UseRange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldBoardType IS NULL THEN BoardType
										ELSE OldBoardType
									END AS OldBoardType,
									BoardType,
									Title,
									dbo.fnBase64ToBinary(TopImage) as TopImage,
									UseRange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldBoardType VARCHAR(20),
											 BoardType VARCHAR(20),
											 Title NVARCHAR(100),
											 TopImage NVARCHAR(MAX),
											 UseRange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldBoardType IS NULL THEN BoardType
										ELSE OldBoardType
									END AS OldBoardType,
									BoardType,
									Title,
									dbo.fnBase64ToBinary(TopImage) as TopImage,
									UseRange,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldBoardType VARCHAR(20),
											 BoardType VARCHAR(20),
											 Title NVARCHAR(100),
											 TopImage NVARCHAR(MAX),
											 UseRange BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldBoardType,
								 @BoardType,
								 @Title,
								 @TopImage,
								 @UseRange,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BoardType WHERE BoardType = @BoardType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @BoardType)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(BoardType)
						FROM
								STB_BoardType 
						WHERE
								BoardType LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @BoardType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @BoardType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_BoardType
						(
						    BoardType,
						    Title,
						    TopImage,
						    UseRange,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @BoardType,
						    @Title,
						    @TopImage,
						    @UseRange,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BoardType
						SET
						    BoardType =   ISNULL(@BoardType,BoardType),
						    Title =   ISNULL(@Title,Title),
						    TopImage =   ISNULL(@TopImage,TopImage),
						    UseRange =   ISNULL(@UseRange,UseRange),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    BoardType = @OldBoardType
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BoardType
						WHERE
						    BoardType = @BoardType
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

