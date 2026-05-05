-- Procedure: usp_LabelTypeInfo_iud


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨유형정보
-- Description:	라벨유형정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelTypeInfo_iud]
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
  DECLARE @LabelType NVARCHAR(30)
  DECLARE @LabelTypeName NVARCHAR(100)
  DECLARE @LabelTypeDesc NVARCHAR(MAX)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_LabelTypeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_LabelTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							XMLData.LabelType,
							XMLData.LabelTypeName,
							XMLData.LabelTypeDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										LabelType NVARCHAR(30),
										LabelTypeName NVARCHAR(100),
										LabelTypeDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.LabelType
				)

			WHEN MATCHED THEN
				UPDATE SET
					LabelType = SourceTable.LabelType,
					LabelTypeName = SourceTable.LabelTypeName,
					LabelTypeDesc = SourceTable.LabelTypeDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						LabelType,
						LabelTypeName,
						LabelTypeDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LabelType,
							SourceTable.LabelTypeName,
							SourceTable.LabelTypeDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_LabelTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							XMLData.LabelType,
							XMLData.LabelTypeName,
							XMLData.LabelTypeDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										LabelType NVARCHAR(30),
										LabelTypeName NVARCHAR(100),
										LabelTypeDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.OldLabelType
				)

			WHEN MATCHED THEN
				UPDATE SET
					LabelType = SourceTable.LabelType,
					LabelTypeName = SourceTable.LabelTypeName,
					LabelTypeDesc = SourceTable.LabelTypeDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						LabelType,
						LabelTypeName,
						LabelTypeDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LabelType,
							SourceTable.LabelTypeName,
							SourceTable.LabelTypeDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_LabelTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldLabelType IS NULL THEN XMLData.LabelType
							    ELSE XMLData.OldLabelType
							END AS OldLabelType,
							XMLData.LabelType,
							XMLData.LabelTypeName,
							XMLData.LabelTypeDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLabelType NVARCHAR(30),
										LabelType NVARCHAR(30),
										LabelTypeName NVARCHAR(100),
										LabelTypeDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.LabelType = SourceTable.LabelType
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
									XMLData.LabelType,
									XMLData.LabelTypeName,
									XMLData.LabelTypeDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelTypeName NVARCHAR(100),
											 LabelTypeDesc NVARCHAR(MAX),
											 IsUsed BIT,
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
									XMLData.LabelType,
									XMLData.LabelTypeName,
									XMLData.LabelTypeDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelTypeName NVARCHAR(100),
											 LabelTypeDesc NVARCHAR(MAX),
											 IsUsed BIT,
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
									XMLData.LabelType,
									XMLData.LabelTypeName,
									XMLData.LabelTypeDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLabelType NVARCHAR(30),
											 LabelType NVARCHAR(30),
											 LabelTypeName NVARCHAR(100),
											 LabelTypeDesc NVARCHAR(MAX),
											 IsUsed BIT,
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
								 @LabelType,
								 @LabelTypeName,
								 @LabelTypeDesc,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_LabelTypeInfo WHERE LabelType = @LabelType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LabelType)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(LabelType)
						FROM
								STB_LabelTypeInfo 
						WHERE
								LabelType LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @LabelType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_LabelTypeInfo
						(
						    LabelType,
						    LabelTypeName,
						    LabelTypeDesc,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LabelType,
						    @LabelTypeName,
						    @LabelTypeDesc,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_LabelTypeInfo
						SET
						    LabelType =   CASE
						                WHEN @LabelType IS NOT NULL THEN @LabelType
						                ELSE LabelType
						            END,
						    LabelTypeName =   CASE
						                WHEN @LabelTypeName IS NOT NULL THEN @LabelTypeName
						                ELSE LabelTypeName
						            END,
						    LabelTypeDesc =   CASE
						                WHEN @LabelTypeDesc IS NOT NULL THEN @LabelTypeDesc
						                ELSE LabelTypeDesc
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
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
						    LabelType = @OldLabelType
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_LabelTypeInfo
						WHERE
						    LabelType = @LabelType
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

