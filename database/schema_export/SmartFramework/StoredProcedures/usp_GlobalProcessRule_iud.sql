-- Procedure: usp_GlobalProcessRule_iud

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-06
-- Browsable : true
-- Group : 시스템
-- Description:	시스템 처리 룰을 설정합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GlobalProcessRule_iud]
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
  DECLARE @OldRuleCode VARCHAR(50)
  DECLARE @RuleCode VARCHAR(50)
  DECLARE @GroupName NVARCHAR(50)
  DECLARE @RuleName NVARCHAR(100)
  DECLARE @OptionDesc NVARCHAR(MAX)
  DECLARE @SettingValue VARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_GlobalProcessRule',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_GlobalProcessRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRuleCode IS NULL THEN RuleCode
							    ELSE OldRuleCode
							END AS OldRuleCode,
							RuleCode,
							GroupName,
							RuleName,
							OptionDesc,
							SettingValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRuleCode VARCHAR(50),
										RuleCode VARCHAR(50),
										GroupName NVARCHAR(50),
										RuleName NVARCHAR(100),
										OptionDesc NVARCHAR(MAX),
										SettingValue VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RuleCode = SourceTable.RuleCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RuleCode = SourceTable.RuleCode,
					GroupName = SourceTable.GroupName,
					RuleName = SourceTable.RuleName,
					OptionDesc = SourceTable.OptionDesc,
					SettingValue = SourceTable.SettingValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						RuleCode,
						GroupName,
						RuleName,
						OptionDesc,
						SettingValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RuleCode,
							SourceTable.GroupName,
							SourceTable.RuleName,
							SourceTable.OptionDesc,
							SourceTable.SettingValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_GlobalProcessRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRuleCode IS NULL THEN RuleCode
							    ELSE OldRuleCode
							END AS OldRuleCode,
							RuleCode,
							GroupName,
							RuleName,
							OptionDesc,
							SettingValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRuleCode VARCHAR(50),
										RuleCode VARCHAR(50),
										GroupName NVARCHAR(50),
										RuleName NVARCHAR(100),
										OptionDesc NVARCHAR(MAX),
										SettingValue VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RuleCode = SourceTable.OldRuleCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RuleCode = SourceTable.RuleCode,
					GroupName = SourceTable.GroupName,
					RuleName = SourceTable.RuleName,
					OptionDesc = SourceTable.OptionDesc,
					SettingValue = SourceTable.SettingValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						RuleCode,
						GroupName,
						RuleName,
						OptionDesc,
						SettingValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.RuleCode,
							SourceTable.GroupName,
							SourceTable.RuleName,
							SourceTable.OptionDesc,
							SourceTable.SettingValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_GlobalProcessRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRuleCode IS NULL THEN RuleCode
							    ELSE OldRuleCode
							END AS OldRuleCode,
							RuleCode,
							GroupName,
							RuleName,
							OptionDesc,
							SettingValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRuleCode VARCHAR(50),
										RuleCode VARCHAR(50),
										GroupName NVARCHAR(50),
										RuleName NVARCHAR(100),
										OptionDesc NVARCHAR(MAX),
										SettingValue VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RuleCode = SourceTable.RuleCode
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
									OldRuleCode,
									RuleCode,
									GroupName,
									RuleName,
									OptionDesc,
									SettingValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRuleCode VARCHAR(50),
											 RuleCode VARCHAR(50),
											 GroupName NVARCHAR(50),
											 RuleName NVARCHAR(100),
											 OptionDesc NVARCHAR(MAX),
											 SettingValue VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRuleCode IS NULL THEN RuleCode
										ELSE OldRuleCode
									END AS OldRuleCode,
									RuleCode,
									GroupName,
									RuleName,
									OptionDesc,
									SettingValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRuleCode VARCHAR(50),
											 RuleCode VARCHAR(50),
											 GroupName NVARCHAR(50),
											 RuleName NVARCHAR(100),
											 OptionDesc NVARCHAR(MAX),
											 SettingValue VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRuleCode IS NULL THEN RuleCode
										ELSE OldRuleCode
									END AS OldRuleCode,
									RuleCode,
									GroupName,
									RuleName,
									OptionDesc,
									SettingValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRuleCode VARCHAR(50),
											 RuleCode VARCHAR(50),
											 GroupName NVARCHAR(50),
											 RuleName NVARCHAR(100),
											 OptionDesc NVARCHAR(MAX),
											 SettingValue VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRuleCode,
								 @RuleCode,
								 @GroupName,
								 @RuleName,
								 @OptionDesc,
								 @SettingValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_GlobalProcessRule WHERE RuleCode = @RuleCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RuleCode)
					END

                    IF @IsAutoKey = 'Y' BEGIN
						SELECT
								@MaxKeyField = MAX(RuleCode)
						FROM
								STB_GlobalProcessRule 
						WHERE
								RuleCode LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @RuleCode = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @RuleCode = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_GlobalProcessRule
						(
						    RuleCode,
						    GroupName,
						    RuleName,
						    OptionDesc,
						    SettingValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RuleCode,
						    @GroupName,
						    @RuleName,
						    @OptionDesc,
						    @SettingValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_GlobalProcessRule
						SET
						    RuleCode =   CASE
						                WHEN @RuleCode IS NOT NULL THEN @RuleCode
						                ELSE RuleCode
						            END,
						    GroupName =   CASE
						                WHEN @GroupName IS NOT NULL THEN @GroupName
						                ELSE GroupName
						            END,
						    RuleName =   CASE
						                WHEN @RuleName IS NOT NULL THEN @RuleName
						                ELSE RuleName
						            END,
						    OptionDesc =   CASE
						                WHEN @OptionDesc IS NOT NULL THEN @OptionDesc
						                ELSE OptionDesc
						            END,
						    SettingValue =   CASE
						                WHEN @SettingValue IS NOT NULL THEN @SettingValue
						                ELSE SettingValue
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
						    RuleCode = @OldRuleCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_GlobalProcessRule
						WHERE
						    RuleCode = @RuleCode
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

