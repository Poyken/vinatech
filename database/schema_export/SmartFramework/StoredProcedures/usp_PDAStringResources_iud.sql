-- Procedure: usp_PDAStringResources_iud


-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 시스템
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PDAStringResources_iud]
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
  DECLARE @OldLang VARCHAR(20)
  DECLARE @OldName NVARCHAR(200)
  DECLARE @Lang VARCHAR(20)
  DECLARE @Name NVARCHAR(200)
  DECLARE @Value NVARCHAR(400)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PDAStringResources',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PDAStringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLang IS NULL THEN Lang
							    ELSE OldLang
							END AS OldLang,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Lang,
							Name,
							Value
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLang VARCHAR(20),
										OldName NVARCHAR(200),
										Lang VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(400)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Lang = SourceTable.Lang AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					Lang = ISNULL(SourceTable.Lang,TargetTable.Lang),
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					Value = ISNULL(SourceTable.Value,TargetTable.Value)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Lang,
						Name,
						Value
					)
				VALUES
					(
							SourceTable.Lang,
							SourceTable.Name,
							SourceTable.Value
					);


			-- Process Update Table
            MERGE STB_PDAStringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLang IS NULL THEN Lang
							    ELSE OldLang
							END AS OldLang,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Lang,
							Name,
							Value
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLang VARCHAR(20),
										OldName NVARCHAR(200),
										Lang VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(400)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Lang = SourceTable.OldLang AND
					TargetTable.Name = SourceTable.OldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Lang = ISNULL(SourceTable.Lang,TargetTable.Lang),
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					Value = ISNULL(SourceTable.Value,TargetTable.Value)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Lang,
						Name,
						Value
					)
				VALUES
					(
							SourceTable.Lang,
							SourceTable.Name,
							SourceTable.Value
					);


			-- Process Delete Table
            MERGE STB_PDAStringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLang IS NULL THEN Lang
							    ELSE OldLang
							END AS OldLang,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Lang,
							Name,
							Value
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLang VARCHAR(20),
										OldName NVARCHAR(200),
										Lang VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(400)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Lang = SourceTable.Lang AND
					TargetTable.Name = SourceTable.Name
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
									OldLang,
									OldName,
									Lang,
									Name,
									Value
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLang VARCHAR(20),
											 OldName NVARCHAR(200),
											 Lang VARCHAR(20),
											 Name NVARCHAR(200),
											 Value NVARCHAR(400)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLang IS NULL THEN Lang
										ELSE OldLang
									END AS OldLang,
									CASE 
										WHEN OldName IS NULL THEN Name
										ELSE OldName
									END AS OldName,
									Lang,
									Name,
									Value
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLang VARCHAR(20),
											 OldName NVARCHAR(200),
											 Lang VARCHAR(20),
											 Name NVARCHAR(200),
											 Value NVARCHAR(400)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLang IS NULL THEN Lang
										ELSE OldLang
									END AS OldLang,
									CASE 
										WHEN OldName IS NULL THEN Name
										ELSE OldName
									END AS OldName,
									Lang,
									Name,
									Value
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLang VARCHAR(20),
											 OldName NVARCHAR(200),
											 Lang VARCHAR(20),
											 Name NVARCHAR(200),
											 Value NVARCHAR(400)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLang,
								 @OldName,
								 @Lang,
								 @Name,
								 @Value


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PDAStringResources WHERE Lang = @Lang AND Name = @Name) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @Lang)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PDAStringResources',@Lang OUTPUT
                    END

                    INSERT INTO STB_PDAStringResources
						(
						    Lang,
						    Name,
						    Value
						)
						VALUES
						(
						    @Lang,
						    @Name,
						    @Value
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PDAStringResources
						SET
						    Lang =   ISNULL(@Lang,Lang),
						    Name =   ISNULL(@Name,Name),
						    Value =   ISNULL(@Value,Value)
						WHERE
						    Lang = @OldLang AND
						    Name = @OldName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PDAStringResources
						WHERE
						    Lang = @OldLang AND
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

