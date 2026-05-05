-- Procedure: usp_BaseCodeTest_iud


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2018-06-11
-- Browsable : true
-- Group : 기준정보
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BaseCodeTest_iud]
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
  DECLARE @OldCodeGroup VARCHAR(50)
  DECLARE @OldItemCode VARCHAR(20)
  DECLARE @CodeGroup VARCHAR(50)
  DECLARE @ItemCode VARCHAR(20)
  DECLARE @Description NVARCHAR(MAX)
  DECLARE @ChangeDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BaseCode',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BaseCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCodeGroup IS NULL THEN CodeGroup
							    ELSE OldCodeGroup
							END AS OldCodeGroup,
							CASE
							    WHEN OldItemCode IS NULL THEN ItemCode
							    ELSE OldItemCode
							END AS OldItemCode,
							CodeGroup,
							ItemCode,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCodeGroup VARCHAR(50),
										OldItemCode VARCHAR(20),
										CodeGroup VARCHAR(50),
										ItemCode VARCHAR(20),
										Description NVARCHAR(MAX),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CodeGroup = SourceTable.CodeGroup AND
					TargetTable.ItemCode = SourceTable.ItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CodeGroup = ISNULL(SourceTable.CodeGroup,TargetTable.CodeGroup),
					ItemCode = ISNULL(SourceTable.ItemCode,TargetTable.ItemCode),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CodeGroup,
						ItemCode,
						Description
					)
				VALUES
					(
							SourceTable.CodeGroup,
							SourceTable.ItemCode,
							SourceTable.Description
					);


			-- Process Update Table
            MERGE STB_BaseCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCodeGroup IS NULL THEN CodeGroup
							    ELSE OldCodeGroup
							END AS OldCodeGroup,
							CASE
							    WHEN OldItemCode IS NULL THEN ItemCode
							    ELSE OldItemCode
							END AS OldItemCode,
							CodeGroup,
							ItemCode,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCodeGroup VARCHAR(50),
										OldItemCode VARCHAR(20),
										CodeGroup VARCHAR(50),
										ItemCode VARCHAR(20),
										Description NVARCHAR(MAX),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CodeGroup = SourceTable.OldCodeGroup AND
					TargetTable.ItemCode = SourceTable.OldItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CodeGroup = ISNULL(SourceTable.CodeGroup,TargetTable.CodeGroup),
					ItemCode = ISNULL(SourceTable.ItemCode,TargetTable.ItemCode),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CodeGroup,
						ItemCode,
						Description
					)
				VALUES
					(
							SourceTable.CodeGroup,
							SourceTable.ItemCode,
							SourceTable.Description
					);


			-- Process Delete Table
            MERGE STB_BaseCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCodeGroup IS NULL THEN CodeGroup
							    ELSE OldCodeGroup
							END AS OldCodeGroup,
							CASE
							    WHEN OldItemCode IS NULL THEN ItemCode
							    ELSE OldItemCode
							END AS OldItemCode,
							CodeGroup,
							ItemCode,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCodeGroup VARCHAR(50),
										OldItemCode VARCHAR(20),
										CodeGroup VARCHAR(50),
										ItemCode VARCHAR(20),
										Description NVARCHAR(MAX),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CodeGroup = SourceTable.CodeGroup AND
					TargetTable.ItemCode = SourceTable.ItemCode
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
									OldCodeGroup,
									OldItemCode,
									CodeGroup,
									ItemCode,
									Description,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCodeGroup VARCHAR(50),
											 OldItemCode VARCHAR(20),
											 CodeGroup VARCHAR(50),
											 ItemCode VARCHAR(20),
											 Description NVARCHAR(MAX),
											 ChangeDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCodeGroup IS NULL THEN CodeGroup
										ELSE OldCodeGroup
									END AS OldCodeGroup,
									CASE 
										WHEN OldItemCode IS NULL THEN ItemCode
										ELSE OldItemCode
									END AS OldItemCode,
									CodeGroup,
									ItemCode,
									Description,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCodeGroup VARCHAR(50),
											 OldItemCode VARCHAR(20),
											 CodeGroup VARCHAR(50),
											 ItemCode VARCHAR(20),
											 Description NVARCHAR(MAX),
											 ChangeDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCodeGroup IS NULL THEN CodeGroup
										ELSE OldCodeGroup
									END AS OldCodeGroup,
									CASE 
										WHEN OldItemCode IS NULL THEN ItemCode
										ELSE OldItemCode
									END AS OldItemCode,
									CodeGroup,
									ItemCode,
									Description,
									ChangeDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCodeGroup VARCHAR(50),
											 OldItemCode VARCHAR(20),
											 CodeGroup VARCHAR(50),
											 ItemCode VARCHAR(20),
											 Description NVARCHAR(MAX),
											 ChangeDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCodeGroup,
								 @OldItemCode,
								 @CodeGroup,
								 @ItemCode,
								 @Description,
								 @ChangeDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BaseCode WHERE CodeGroup = @CodeGroup AND ItemCode = @ItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CodeGroup)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BaseCode',@CodeGroup OUTPUT
                    END

                    INSERT INTO STB_BaseCode
						(
						    CodeGroup,
						    ItemCode,
						    Description,
						    ChangeDateTime
						)
						VALUES
						(
						    @CodeGroup,
						    @ItemCode,
						    @Description,
						    @ChangeDateTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BaseCode
						SET
						    CodeGroup =   ISNULL(@CodeGroup,CodeGroup),
						    ItemCode =   ISNULL(@ItemCode,ItemCode),
						    Description =   ISNULL(@Description,Description),
						    ChangeDateTime = GETDATE()
						WHERE
						    CodeGroup = @OldCodeGroup AND
						    ItemCode = @OldItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BaseCode
						WHERE
						    CodeGroup = @OldCodeGroup AND
						    ItemCode = @OldItemCode
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

