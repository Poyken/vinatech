-- Procedure: usp_CommInspSelectItem_iud

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-27
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspSelectItem_iud]
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
  DECLARE @OldCommInspSelectItemCode VARCHAR(20)
  DECLARE @CommInspSelectItemCode VARCHAR(20)
  DECLARE @CommInspSelectGroupCode VARCHAR(20)
  DECLARE @CommInspSelectItemValue VARCHAR(50)
  DECLARE @CommInspSelectITemDesc NVARCHAR(100)
  DECLARE @CommInspSelectResult VARCHAR(4)
  DECLARE @DisplayIndex INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CommInspSelectItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CommInspSelectItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspSelectItemCode IS NULL THEN CommInspSelectItemCode
							    ELSE OldCommInspSelectItemCode
							END AS OldCommInspSelectItemCode,
							CommInspSelectItemCode,
							CommInspSelectGroupCode,
							CommInspSelectItemValue,
							CommInspSelectITemDesc,
							CommInspSelectResult,
							DisplayIndex,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCommInspSelectItemCode VARCHAR(20),
										CommInspSelectItemCode VARCHAR(20),
										CommInspSelectGroupCode VARCHAR(20),
										CommInspSelectItemValue VARCHAR(50),
										CommInspSelectITemDesc NVARCHAR(100),
										CommInspSelectResult VARCHAR(4),
										DisplayIndex INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspSelectItemCode = SourceTable.CommInspSelectItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspSelectItemCode = ISNULL(SourceTable.CommInspSelectItemCode,TargetTable.CommInspSelectItemCode),
					CommInspSelectGroupCode = ISNULL(SourceTable.CommInspSelectGroupCode,TargetTable.CommInspSelectGroupCode),
					CommInspSelectItemValue = ISNULL(SourceTable.CommInspSelectItemValue,TargetTable.CommInspSelectItemValue),
					CommInspSelectITemDesc = ISNULL(SourceTable.CommInspSelectITemDesc,TargetTable.CommInspSelectITemDesc),
					CommInspSelectResult = ISNULL(SourceTable.CommInspSelectResult,TargetTable.CommInspSelectResult),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspSelectItemCode,
						CommInspSelectGroupCode,
						CommInspSelectItemValue,
						CommInspSelectITemDesc,
						CommInspSelectResult,
						DisplayIndex,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspSelectItemCode,
							SourceTable.CommInspSelectGroupCode,
							SourceTable.CommInspSelectItemValue,
							SourceTable.CommInspSelectITemDesc,
							SourceTable.CommInspSelectResult,
							SourceTable.DisplayIndex,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CommInspSelectItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspSelectItemCode IS NULL THEN CommInspSelectItemCode
							    ELSE OldCommInspSelectItemCode
							END AS OldCommInspSelectItemCode,
							CommInspSelectItemCode,
							CommInspSelectGroupCode,
							CommInspSelectItemValue,
							CommInspSelectITemDesc,
							CommInspSelectResult,
							DisplayIndex,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCommInspSelectItemCode VARCHAR(20),
										CommInspSelectItemCode VARCHAR(20),
										CommInspSelectGroupCode VARCHAR(20),
										CommInspSelectItemValue VARCHAR(50),
										CommInspSelectITemDesc NVARCHAR(100),
										CommInspSelectResult VARCHAR(4),
										DisplayIndex INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspSelectItemCode = SourceTable.OldCommInspSelectItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspSelectItemCode = ISNULL(SourceTable.CommInspSelectItemCode,TargetTable.CommInspSelectItemCode),
					CommInspSelectGroupCode = ISNULL(SourceTable.CommInspSelectGroupCode,TargetTable.CommInspSelectGroupCode),
					CommInspSelectItemValue = ISNULL(SourceTable.CommInspSelectItemValue,TargetTable.CommInspSelectItemValue),
					CommInspSelectITemDesc = ISNULL(SourceTable.CommInspSelectITemDesc,TargetTable.CommInspSelectITemDesc),
					CommInspSelectResult = ISNULL(SourceTable.CommInspSelectResult,TargetTable.CommInspSelectResult),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspSelectItemCode,
						CommInspSelectGroupCode,
						CommInspSelectItemValue,
						CommInspSelectITemDesc,
						CommInspSelectResult,
						DisplayIndex,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspSelectItemCode,
							SourceTable.CommInspSelectGroupCode,
							SourceTable.CommInspSelectItemValue,
							SourceTable.CommInspSelectITemDesc,
							SourceTable.CommInspSelectResult,
							SourceTable.DisplayIndex,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CommInspSelectItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspSelectItemCode IS NULL THEN CommInspSelectItemCode
							    ELSE OldCommInspSelectItemCode
							END AS OldCommInspSelectItemCode,
							CommInspSelectItemCode,
							CommInspSelectGroupCode,
							CommInspSelectItemValue,
							CommInspSelectITemDesc,
							CommInspSelectResult,
							DisplayIndex,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCommInspSelectItemCode VARCHAR(20),
										CommInspSelectItemCode VARCHAR(20),
										CommInspSelectGroupCode VARCHAR(20),
										CommInspSelectItemValue VARCHAR(50),
										CommInspSelectITemDesc NVARCHAR(100),
										CommInspSelectResult VARCHAR(4),
										DisplayIndex INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspSelectItemCode = SourceTable.CommInspSelectItemCode
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
									OldCommInspSelectItemCode,
									CommInspSelectItemCode,
									CommInspSelectGroupCode,
									CommInspSelectItemValue,
									CommInspSelectITemDesc,
									CommInspSelectResult,
									DisplayIndex,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCommInspSelectItemCode VARCHAR(20),
											 CommInspSelectItemCode VARCHAR(20),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspSelectItemValue VARCHAR(50),
											 CommInspSelectITemDesc NVARCHAR(100),
											 CommInspSelectResult VARCHAR(4),
											 DisplayIndex INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspSelectItemCode IS NULL THEN CommInspSelectItemCode
										ELSE OldCommInspSelectItemCode
									END AS OldCommInspSelectItemCode,
									CommInspSelectItemCode,
									CommInspSelectGroupCode,
									CommInspSelectItemValue,
									CommInspSelectITemDesc,
									CommInspSelectResult,
									DisplayIndex,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCommInspSelectItemCode VARCHAR(20),
											 CommInspSelectItemCode VARCHAR(20),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspSelectItemValue VARCHAR(50),
											 CommInspSelectITemDesc NVARCHAR(100),
											 CommInspSelectResult VARCHAR(4),
											 DisplayIndex INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspSelectItemCode IS NULL THEN CommInspSelectItemCode
										ELSE OldCommInspSelectItemCode
									END AS OldCommInspSelectItemCode,
									CommInspSelectItemCode,
									CommInspSelectGroupCode,
									CommInspSelectItemValue,
									CommInspSelectITemDesc,
									CommInspSelectResult,
									DisplayIndex,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCommInspSelectItemCode VARCHAR(20),
											 CommInspSelectItemCode VARCHAR(20),
											 CommInspSelectGroupCode VARCHAR(20),
											 CommInspSelectItemValue VARCHAR(50),
											 CommInspSelectITemDesc NVARCHAR(100),
											 CommInspSelectResult VARCHAR(4),
											 DisplayIndex INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCommInspSelectItemCode,
								 @CommInspSelectItemCode,
								 @CommInspSelectGroupCode,
								 @CommInspSelectItemValue,
								 @CommInspSelectITemDesc,
								 @CommInspSelectResult,
								 @DisplayIndex,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CommInspSelectItem WHERE CommInspSelectItemCode = @CommInspSelectItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CommInspSelectItemCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspSelectItem',@CommInspSelectItemCode OUTPUT
                    END

                    INSERT INTO STB_CommInspSelectItem
						(
						    CommInspSelectItemCode,
						    CommInspSelectGroupCode,
						    CommInspSelectItemValue,
						    CommInspSelectITemDesc,
						    CommInspSelectResult,
						    DisplayIndex,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CommInspSelectItemCode,
						    @CommInspSelectGroupCode,
						    @CommInspSelectItemValue,
						    @CommInspSelectITemDesc,
						    @CommInspSelectResult,
						    @DisplayIndex,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CommInspSelectItem
						SET
						    CommInspSelectItemCode =   ISNULL(@CommInspSelectItemCode,CommInspSelectItemCode),
						    CommInspSelectGroupCode =   ISNULL(@CommInspSelectGroupCode,CommInspSelectGroupCode),
						    CommInspSelectItemValue =   ISNULL(@CommInspSelectItemValue,CommInspSelectItemValue),
						    CommInspSelectITemDesc =   ISNULL(@CommInspSelectITemDesc,CommInspSelectITemDesc),
						    CommInspSelectResult =   ISNULL(@CommInspSelectResult,CommInspSelectResult),
						    DisplayIndex =   ISNULL(@DisplayIndex,DisplayIndex),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CommInspSelectItemCode = @OldCommInspSelectItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CommInspSelectItem
						WHERE
						    CommInspSelectItemCode = @OldCommInspSelectItemCode
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

