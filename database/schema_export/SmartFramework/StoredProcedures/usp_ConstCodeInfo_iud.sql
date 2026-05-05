-- Procedure: usp_ConstCodeInfo_iud





-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-11-28
-- Browsable : true
-- Group : System
-- Description:	상수코드를 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ConstCodeInfo_iud]
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
  DECLARE @OldConstName NVARCHAR(100)
  DECLARE @ConstName NVARCHAR(100)
  DECLARE @ConstValue NVARCHAR(MAX)
  DECLARE @Description NVARCHAR(MAX)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ConstCodeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
  
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
		
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ConstCodeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldConstName IS NULL THEN ConstName
							    ELSE OldConstName
							END AS OldConstName,
							ConstName,
							ConstValue,
							Description
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldConstName NVARCHAR(100),
										ConstName NVARCHAR(100),
										ConstValue NVARCHAR(MAX),
										Description NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ConstName = SourceTable.ConstName
				)

			WHEN MATCHED THEN
				UPDATE SET
					ConstName = ISNULL(SourceTable.ConstName,TargetTable.ConstName),
					ConstValue = ISNULL(SourceTable.ConstValue,TargetTable.ConstValue),
					Description = ISNULL(SourceTable.Description,TargetTable.Description)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ConstName,
						ConstValue,
						Description
					)
				VALUES
					(
							SourceTable.ConstName,
							SourceTable.ConstValue,
							SourceTable.Description
					);


			-- Process Update Table
            MERGE STB_ConstCodeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldConstName IS NULL THEN ConstName
							    ELSE OldConstName
							END AS OldConstName,
							ConstName,
							ConstValue,
							Description
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldConstName NVARCHAR(100),
										ConstName NVARCHAR(100),
										ConstValue NVARCHAR(MAX),
										Description NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ConstName = SourceTable.OldConstName
				)

			WHEN MATCHED THEN
				UPDATE SET
					ConstName = ISNULL(SourceTable.ConstName,TargetTable.ConstName),
					ConstValue = ISNULL(SourceTable.ConstValue,TargetTable.ConstValue),
					Description = ISNULL(SourceTable.Description,TargetTable.Description)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ConstName,
						ConstValue,
						Description
					)
				VALUES
					(
							SourceTable.ConstName,
							SourceTable.ConstValue,
							SourceTable.Description
					);


			-- Process Delete Table
            MERGE STB_ConstCodeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldConstName IS NULL THEN ConstName
							    ELSE OldConstName
							END AS OldConstName,
							ConstName,
							ConstValue,
							Description
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldConstName NVARCHAR(100),
										ConstName NVARCHAR(100),
										ConstValue NVARCHAR(MAX),
										Description NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ConstName = SourceTable.ConstName
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
									OldConstName,
									ConstName,
									ConstValue,
									Description
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldConstName NVARCHAR(100),
											 ConstName NVARCHAR(100),
											 ConstValue NVARCHAR(MAX),
											 Description NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldConstName IS NULL THEN ConstName
										ELSE OldConstName
									END AS OldConstName,
									ConstName,
									ConstValue,
									Description
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldConstName NVARCHAR(100),
											 ConstName NVARCHAR(100),
											 ConstValue NVARCHAR(MAX),
											 Description NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldConstName IS NULL THEN ConstName
										ELSE OldConstName
									END AS OldConstName,
									ConstName,
									ConstValue,
									Description
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldConstName NVARCHAR(100),
											 ConstName NVARCHAR(100),
											 ConstValue NVARCHAR(MAX),
											 Description NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldConstName,
								 @ConstName,
								 @ConstValue,
								 @Description


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ConstCodeInfo WHERE ConstName = @ConstName) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ConstName)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(ConstName)
						FROM
								STB_ConstCodeInfo 
						WHERE
								ConstName LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @ConstName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @ConstName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_ConstCodeInfo
						(
						    ConstName,
						    ConstValue,
						    Description
						)
						VALUES
						(
						    @ConstName,
						    @ConstValue,
						    @Description
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ConstCodeInfo
						SET
						    ConstName =   ISNULL(@ConstName,ConstName),
						    ConstValue =   ISNULL(@ConstValue,ConstValue),
						    Description =   ISNULL(@Description,Description)
						WHERE
						    ConstName = @OldConstName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ConstCodeInfo
						WHERE
						    ConstName = @ConstName
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

