-- Procedure: usp_PDAMenu_iud


-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 시스템
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAMenu_iud]
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
  DECLARE @OldName VARCHAR(50)
  DECLARE @Name VARCHAR(50)
  DECLARE @ParentName VARCHAR(50)
  DECLARE @DefaultCaption NVARCHAR(20)
  DECLARE @TypeName VARCHAR(50)
  DECLARE @IsUse BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PDAMenu',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PDAMenu AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Name,
							ParentName,
							DefaultCaption,
							TypeName,
							IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										ParentName VARCHAR(50),
										DefaultCaption NVARCHAR(20),
										TypeName VARCHAR(50),
										IsUse BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					WHERE
							Name NOT IN ('MENU')
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					ParentName = ISNULL(SourceTable.ParentName,TargetTable.ParentName),
					DefaultCaption = ISNULL(SourceTable.DefaultCaption,TargetTable.DefaultCaption),
					TypeName = ISNULL(SourceTable.TypeName,TargetTable.TypeName),
					IsUse = ISNULL(SourceTable.IsUse,TargetTable.IsUse),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Name,
						ParentName,
						DefaultCaption,
						TypeName,
						IsUse,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Name,
							SourceTable.ParentName,
							SourceTable.DefaultCaption,
							SourceTable.TypeName,
							SourceTable.IsUse,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_PDAMenu AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Name,
							ParentName,
							DefaultCaption,
							TypeName,
							IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										ParentName VARCHAR(50),
										DefaultCaption NVARCHAR(20),
										TypeName VARCHAR(50),
										IsUse BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					WHERE
							Name NOT IN ('MENU')
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.OldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					ParentName = ISNULL(SourceTable.ParentName,TargetTable.ParentName),
					DefaultCaption = ISNULL(SourceTable.DefaultCaption,TargetTable.DefaultCaption),
					TypeName = ISNULL(SourceTable.TypeName,TargetTable.TypeName),
					IsUse = ISNULL(SourceTable.IsUse,TargetTable.IsUse),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Name,
						ParentName,
						DefaultCaption,
						TypeName,
						IsUse,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Name,
							SourceTable.ParentName,
							SourceTable.DefaultCaption,
							SourceTable.TypeName,
							SourceTable.IsUse,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_PDAMenu AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Name,
							ParentName,
							DefaultCaption,
							TypeName,
							IsUse,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										ParentName VARCHAR(50),
										DefaultCaption NVARCHAR(20),
										TypeName VARCHAR(50),
										IsUse BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				DELETE;

			INSERT INTO STB_PDAStringResources
			SELECT
					'Default',
					PDAM.Name,
					PDAM.DefaultCaption
			FROM
					STB_PDAMenu PDAM
					LEFT OUTER JOIN STB_PDAStringResources PDASR
						ON PDASR.Name = PDAM.Name AND
						PDASR.Lang = 'Default'
			WHERE
					PDASR.Name IS NULL
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
									OldName,
									Name,
									ParentName,
									DefaultCaption,
									TypeName,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 ParentName VARCHAR(50),
											 DefaultCaption NVARCHAR(20),
											 TypeName VARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldName IS NULL THEN Name
										ELSE OldName
									END AS OldName,
									Name,
									ParentName,
									DefaultCaption,
									TypeName,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 ParentName VARCHAR(50),
											 DefaultCaption NVARCHAR(20),
											 TypeName VARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldName IS NULL THEN Name
										ELSE OldName
									END AS OldName,
									Name,
									ParentName,
									DefaultCaption,
									TypeName,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 ParentName VARCHAR(50),
											 DefaultCaption NVARCHAR(20),
											 TypeName VARCHAR(50),
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldName,
								 @Name,
								 @ParentName,
								 @DefaultCaption,
								 @TypeName,
								 @IsUse,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PDAMenu WHERE Name = @Name) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @Name)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PDAMenu',@Name OUTPUT
                    END

                    INSERT INTO STB_PDAMenu
						(
						    Name,
						    ParentName,
						    DefaultCaption,
						    TypeName,
						    IsUse,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @Name,
						    @ParentName,
						    @DefaultCaption,
						    @TypeName,
						    @IsUse,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PDAMenu
						SET
						    Name =   ISNULL(@Name,Name),
						    ParentName =   ISNULL(@ParentName,ParentName),
						    DefaultCaption =   ISNULL(@DefaultCaption,DefaultCaption),
						    TypeName =   ISNULL(@TypeName,TypeName),
						    IsUse =   ISNULL(@IsUse,IsUse),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    Name = @OldName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PDAMenu
						WHERE
						    Name = @OldName
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

