-- Procedure: usp_LabelSpecInfo_iud


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨스팩정보
-- Description:	라벨스팩정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelSpecInfo_iud]
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
  DECLARE @OldLabelType NVARCHAR(30)
  DECLARE @OldLabelSpecCode VARCHAR(30)
  DECLARE @LabelType NVARCHAR(30)
  DECLARE @LabelSpecCode VARCHAR(30)
  DECLARE @LabelSpecName NVARCHAR(100)
  DECLARE @LabelSpecDesc NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_LabelSpecInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_LabelSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN XMLData.OldLabelSpecCode IS NULL THEN XMLData.LabelSpecCode
							    ELSE XMLData.OldLabelSpecCode
							END AS OldLabelSpecCode,
							XMLData.LabelType,
							XMLData.LabelSpecCode,
							XMLData.LabelSpecName,
							XMLData.LabelSpecDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecName NVARCHAR(100),
										LabelSpecDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.LabelType AND
					TargetTable.LabelSpecCode = SourceTable.LabelSpecCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					LabelType = SourceTable.LabelType,
					LabelSpecCode = SourceTable.LabelSpecCode,
					LabelSpecName = SourceTable.LabelSpecName,
					LabelSpecDesc = SourceTable.LabelSpecDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						LabelType,
						LabelSpecCode,
						LabelSpecName,
						LabelSpecDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LabelType,
							SourceTable.LabelSpecCode,
							SourceTable.LabelSpecName,
							SourceTable.LabelSpecDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_LabelSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN XMLData.OldLabelSpecCode IS NULL THEN XMLData.LabelSpecCode
							    ELSE XMLData.OldLabelSpecCode
							END AS OldLabelSpecCode,
							XMLData.LabelType,
							XMLData.LabelSpecCode,
							XMLData.LabelSpecName,
							XMLData.LabelSpecDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecName NVARCHAR(100),
										LabelSpecDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.OldLabelType AND
					TargetTable.LabelSpecCode = SourceTable.OldLabelSpecCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					LabelType = SourceTable.LabelType,
					LabelSpecCode = SourceTable.LabelSpecCode,
					LabelSpecName = SourceTable.LabelSpecName,
					LabelSpecDesc = SourceTable.LabelSpecDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						LabelType,
						LabelSpecCode,
						LabelSpecName,
						LabelSpecDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LabelType,
							SourceTable.LabelSpecCode,
							SourceTable.LabelSpecName,
							SourceTable.LabelSpecDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_LabelSpecInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN XMLData.OldLabelSpecCode IS NULL THEN XMLData.LabelSpecCode
							    ELSE XMLData.OldLabelSpecCode
							END AS OldLabelSpecCode,
							XMLData.LabelType,
							XMLData.LabelSpecCode,
							XMLData.LabelSpecName,
							XMLData.LabelSpecDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecName NVARCHAR(100),
										LabelSpecDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.LabelType AND
					TargetTable.LabelSpecCode = SourceTable.LabelSpecCode
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
									XMLData.OldLabelType,
									XMLData.OldLabelSpecCode,
									XMLData.LabelType,
									XMLData.LabelSpecCode,
									XMLData.LabelSpecName,
									XMLData.LabelSpecDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecName NVARCHAR(100),
											 LabelSpecDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
										ELSE XMLData.OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN XMLData.OldLabelSpecCode IS NULL THEN XMLData.LabelSpecCode
										ELSE XMLData.OldLabelSpecCode
									END AS OldLabelSpecCode,
									XMLData.LabelType,
									XMLData.LabelSpecCode,
									XMLData.LabelSpecName,
									XMLData.LabelSpecDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecName NVARCHAR(100),
											 LabelSpecDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
										ELSE XMLData.OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN XMLData.OldLabelSpecCode IS NULL THEN XMLData.LabelSpecCode
										ELSE XMLData.OldLabelSpecCode
									END AS OldLabelSpecCode,
									XMLData.LabelType,
									XMLData.LabelSpecCode,
									XMLData.LabelSpecName,
									XMLData.LabelSpecDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecName NVARCHAR(100),
											 LabelSpecDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLabelType,
								 @OldLabelSpecCode,
								 @LabelType,
								 @LabelSpecCode,
								 @LabelSpecName,
								 @LabelSpecDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LabelSpecInfo WHERE LabelType = @LabelType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LabelType)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(LabelType)
						FROM
								STB_LabelSpecInfo 
						WHERE
								LabelType LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_LabelSpecInfo
						(
						    LabelType,
						    LabelSpecCode,
						    LabelSpecName,
						    LabelSpecDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LabelType,
						    @LabelSpecCode,
						    @LabelSpecName,
						    @LabelSpecDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LabelSpecInfo
						SET
						    LabelType =   CASE
						                WHEN @LabelType IS NOT NULL THEN @LabelType
						                ELSE LabelType
						            END,
						    LabelSpecCode =   CASE
						                WHEN @LabelSpecCode IS NOT NULL THEN @LabelSpecCode
						                ELSE LabelSpecCode
						            END,
						    LabelSpecName =   CASE
						                WHEN @LabelSpecName IS NOT NULL THEN @LabelSpecName
						                ELSE LabelSpecName
						            END,
						    LabelSpecDesc =   CASE
						                WHEN @LabelSpecDesc IS NOT NULL THEN @LabelSpecDesc
						                ELSE LabelSpecDesc
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LabelType = @OldLabelType AND
						    LabelSpecCode = @OldLabelSpecCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LabelSpecInfo
						WHERE
						    LabelType = @LabelType AND
						    LabelSpecCode = @LabelSpecCode
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

