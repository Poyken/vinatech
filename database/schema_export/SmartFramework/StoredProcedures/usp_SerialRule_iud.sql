-- Procedure: usp_SerialRule_iud






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-26
-- Browsable : true
-- Description:	테이블의 키 생성룰을 관리합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_SerialRule_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldTableName VARCHAR(50)
  DECLARE @TableName VARCHAR(50)
  DECLARE @TableDescription NVARCHAR(100)
  DECLARE @IsAutoKeyCursor BIT
  DECLARE @IsLoopIUDCursor BIT
  DECLARE @PrefixDataCursor VARCHAR(12)
  DECLARE @SerialLenCursor INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SerialRule',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SerialRule AS TargetTable
			USING
				(
					SELECT
							XMLData.TableName,
							XMLData.TableDescription,
							XMLData.IsAutoKey,
							XMLData.IsLoopIUD,
							XMLData.PrefixData,
							XMLData.SerialLen
					FROM
							OPENXML(@idoc , '/DataSet/SerialRule_INSERT' , 2)
							WITH  (
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TableName = SourceTable.TableName
				)

			WHEN MATCHED THEN
				UPDATE SET
					TableDescription = SourceTable.TableDescription,
					IsAutoKey = SourceTable.IsAutoKey,
					IsLoopIUD = SourceTable.IsLoopIUD,
					PrefixData = SourceTable.PrefixData,
					SerialLen = SourceTable.SerialLen
			WHEN NOT MATCHED THEN
				INSERT
					(
						TableName,
						TableDescription,
						IsAutoKey,
						IsLoopIUD,
						PrefixData,
						SerialLen
					)
				VALUES
					(
							SourceTable.TableName,
							SourceTable.TableDescription,
							SourceTable.IsAutoKey,
							SourceTable.IsLoopIUD,
							SourceTable.PrefixData,
							SourceTable.SerialLen
					);


			-- Process Update Table
            MERGE STB_SerialRule AS TargetTable
			USING
				(
					SELECT
							XMLData.TableName,
							XMLData.TableDescription,
							XMLData.IsAutoKey,
							XMLData.IsLoopIUD,
							XMLData.PrefixData,
							XMLData.SerialLen
					FROM
							OPENXML(@idoc , '/DataSet/SerialRule_UPDATE' , 2)
							WITH  (
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TableName = SourceTable.TableName
				)

			WHEN MATCHED THEN
				UPDATE SET
					TableDescription = SourceTable.TableDescription,
					IsAutoKey = SourceTable.IsAutoKey,
					IsLoopIUD = SourceTable.IsLoopIUD,
					PrefixData = SourceTable.PrefixData,
					SerialLen = SourceTable.SerialLen
			WHEN NOT MATCHED THEN
				INSERT
					(
						TableName,
						TableDescription,
						IsAutoKey,
						IsLoopIUD,
						PrefixData,
						SerialLen
					)
				VALUES
					(
							SourceTable.TableName,
							SourceTable.TableDescription,
							SourceTable.IsAutoKey,
							SourceTable.IsLoopIUD,
							SourceTable.PrefixData,
							SourceTable.SerialLen
					);


			-- Process Delete Table
            MERGE STB_SerialRule AS TargetTable
			USING
				(
					SELECT
							XMLData.TableName,
							XMLData.TableDescription,
							XMLData.IsAutoKey,
							XMLData.IsLoopIUD,
							XMLData.PrefixData,
							XMLData.SerialLen
					FROM
							OPENXML(@idoc , '/DataSet/SerialRule_DELETE' , 2)
							WITH  (
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.TableName = SourceTable.TableName
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
                        XMLData.OldTableName,
									XMLData.TableName,
									XMLData.TableDescription,
									XMLData.IsAutoKey,
									XMLData.IsLoopIUD,
									XMLData.PrefixData,
									XMLData.SerialLen
							FROM
									OPENXML(@idoc , '/DataSet/SerialRule_INSERT' , 2)
							        WITH  (
											 OldTableName VARCHAR(50),
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldTableName IS NULL THEN XMLData.TableName
										ELSE XMLData.OldTableName
									END AS OldTableName,
									XMLData.TableName,
									XMLData.TableDescription,
									XMLData.IsAutoKey,
									XMLData.IsLoopIUD,
									XMLData.PrefixData,
									XMLData.SerialLen
							FROM
									OPENXML(@idoc , '/DataSet/SerialRule_UPDATE' , 2)
							        WITH  (
											 OldTableName VARCHAR(50),
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldTableName IS NULL THEN XMLData.TableName
										ELSE XMLData.OldTableName
									END AS OldTableName,
									XMLData.TableName,
									XMLData.TableDescription,
									XMLData.IsAutoKey,
									XMLData.IsLoopIUD,
									XMLData.PrefixData,
									XMLData.SerialLen
							FROM
									OPENXML(@idoc , '/DataSet/SerialRule_DELETE' , 2)
							        WITH  (
											 OldTableName VARCHAR(50),
											 TableName VARCHAR(50),
											 TableDescription NVARCHAR(100),
											 IsAutoKey BIT,
											 IsLoopIUD BIT,
											 PrefixData VARCHAR(12),
											 SerialLen INT
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldTableName,
								 @TableName,
								 @TableDescription,
								 @IsAutoKeyCursor,
								 @IsLoopIUDCursor,
								 @PrefixDataCursor,
								 @SerialLenCursor


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SerialRule WHERE TableName = @TableName) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @TableName)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(TableName)
						FROM
								STB_SerialRule 
						WHERE
								TableName LIKE @PrefixString
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @TableName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @TableName = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END

                        INSERT INTO STB_SerialRule
						(
						    TableName,
						    TableDescription,
						    IsAutoKey,
						    IsLoopIUD,
						    PrefixData,
						    SerialLen
						)
						VALUES
						(
						    @TableName,
						    @TableDescription,
						    @IsAutoKey,
						    @IsLoopIUD,
						    @PrefixDataCursor,
						    @SerialLen
						)

					END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                        UPDATE STB_SerialRule
						SET
						    TableName =   CASE
						                WHEN @TableName IS NOT NULL THEN @TableName
						                ELSE TableName
						            END,
						    TableDescription =   CASE
						                WHEN @TableDescription IS NOT NULL THEN @TableDescription
						                ELSE TableDescription
						            END,
						    IsAutoKey =   CASE
						                WHEN @IsAutoKey IS NOT NULL THEN @IsAutoKey
						                ELSE IsAutoKey
						            END,
						    IsLoopIUD =   CASE
						                WHEN @IsLoopIUD IS NOT NULL THEN @IsLoopIUD
						                ELSE IsLoopIUD
						            END,
						    PrefixData =   CASE
						                WHEN @PrefixDataCursor IS NOT NULL THEN @PrefixDataCursor
						                ELSE PrefixData
						            END,
						    SerialLen =   CASE
						                WHEN @SerialLen IS NOT NULL THEN @SerialLen
						                ELSE SerialLen
						            END
						WHERE
						    TableName = @TableName
                    END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_SerialRule
						WHERE
						    TableName = @TableName
                    END
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

