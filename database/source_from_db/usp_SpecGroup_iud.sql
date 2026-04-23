
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 사양그룹정보
-- Description:	사양그룹정보IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecGroup_iud]
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
  DECLARE @OldSpecGroupCode VARCHAR(20)
  DECLARE @SpecGroupCode VARCHAR(20)
  DECLARE @SpecGroupName NVARCHAR(50)
  DECLARE @SpecGroupNameL NVARCHAR(50)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SpecGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SpecGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecGroupCode IS NULL THEN SpecGroupCode
							    ELSE OldSpecGroupCode
							END AS OldSpecGroupCode,
							SpecGroupCode,
							SpecGroupName,
							SpecGroupNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSpecGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecGroupName NVARCHAR(50),
										SpecGroupNameL NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecGroupCode = SourceTable.SpecGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecGroupCode = ISNULL(SourceTable.SpecGroupCode,TargetTable.SpecGroupCode),
					SpecGroupName = ISNULL(SourceTable.SpecGroupName,TargetTable.SpecGroupName),
					SpecGroupNameL = ISNULL(SourceTable.SpecGroupNameL,TargetTable.SpecGroupNameL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SpecGroupCode,
						SpecGroupName,
						SpecGroupNameL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SpecGroupCode,
							SourceTable.SpecGroupName,
							SourceTable.SpecGroupNameL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SpecGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecGroupCode IS NULL THEN SpecGroupCode
							    ELSE OldSpecGroupCode
							END AS OldSpecGroupCode,
							SpecGroupCode,
							SpecGroupName,
							SpecGroupNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSpecGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecGroupName NVARCHAR(50),
										SpecGroupNameL NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecGroupCode = SourceTable.OldSpecGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecGroupCode = ISNULL(SourceTable.SpecGroupCode,TargetTable.SpecGroupCode),
					SpecGroupName = ISNULL(SourceTable.SpecGroupName,TargetTable.SpecGroupName),
					SpecGroupNameL = ISNULL(SourceTable.SpecGroupNameL,TargetTable.SpecGroupNameL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SpecGroupCode,
						SpecGroupName,
						SpecGroupNameL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SpecGroupCode,
							SourceTable.SpecGroupName,
							SourceTable.SpecGroupNameL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SpecGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecGroupCode IS NULL THEN SpecGroupCode
							    ELSE OldSpecGroupCode
							END AS OldSpecGroupCode,
							SpecGroupCode,
							SpecGroupName,
							SpecGroupNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSpecGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecGroupName NVARCHAR(50),
										SpecGroupNameL NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecGroupCode = SourceTable.SpecGroupCode
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
									OldSpecGroupCode,
									SpecGroupCode,
									SpecGroupName,
									SpecGroupNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSpecGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecGroupName NVARCHAR(50),
											 SpecGroupNameL NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSpecGroupCode IS NULL THEN SpecGroupCode
										ELSE OldSpecGroupCode
									END AS OldSpecGroupCode,
									SpecGroupCode,
									SpecGroupName,
									SpecGroupNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSpecGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecGroupName NVARCHAR(50),
											 SpecGroupNameL NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSpecGroupCode IS NULL THEN SpecGroupCode
										ELSE OldSpecGroupCode
									END AS OldSpecGroupCode,
									SpecGroupCode,
									SpecGroupName,
									SpecGroupNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSpecGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecGroupName NVARCHAR(50),
											 SpecGroupNameL NVARCHAR(50),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSpecGroupCode,
								 @SpecGroupCode,
								 @SpecGroupName,
								 @SpecGroupNameL,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SpecGroup WHERE SpecGroupCode = @SpecGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SpecGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SpecGroup',@SpecGroupCode OUTPUT
                    END

                    INSERT INTO STB_SpecGroup
						(
						    SpecGroupCode,
						    SpecGroupName,
						    SpecGroupNameL,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @SpecGroupCode,
						    @SpecGroupName,
						    @SpecGroupNameL,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SpecGroup
						SET
						    SpecGroupCode =   ISNULL(@SpecGroupCode,SpecGroupCode),
						    SpecGroupName =   ISNULL(@SpecGroupName,SpecGroupName),
						    SpecGroupNameL =   ISNULL(@SpecGroupNameL,SpecGroupNameL),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    SpecGroupCode = @OldSpecGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SpecGroup
						WHERE
						    SpecGroupCode = @OldSpecGroupCode
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
