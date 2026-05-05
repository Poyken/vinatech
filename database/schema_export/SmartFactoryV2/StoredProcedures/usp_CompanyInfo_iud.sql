-- Procedure: usp_CompanyInfo_iud

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-27
-- Browsable : true
-- Group : 공통
-- Description:	사업장정보 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompanyInfo_iud]
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
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @CompanyName NVARCHAR(50)
  DECLARE @CompanyNameL NVARCHAR(50)
  DECLARE @CompanyDesc NVARCHAR(200)
  DECLARE @CompanyDescL NVARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CompanyInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CompanyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.CompanyCode
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.CompanyCode,
							XMLData.CompanyName,
							XMLData.CompanyNameL,
							XMLData.CompanyDesc,
							XMLData.CompanyDescL,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										CompanyName NVARCHAR(50),
										CompanyNameL NVARCHAR(50),
										CompanyDesc NVARCHAR(200),
										CompanyDescL NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = SourceTable.CompanyCode,
					CompanyName = SourceTable.CompanyName,
					CompanyNameL = SourceTable.CompanyNameL,
					CompanyDesc = SourceTable.CompanyDesc,
					CompanyDescL = SourceTable.CompanyDescL,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						CompanyName,
						CompanyNameL,
						CompanyDesc,
						CompanyDescL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.CompanyName,
							SourceTable.CompanyNameL,
							SourceTable.CompanyDesc,
							SourceTable.CompanyDescL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CompanyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.CompanyCode
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.CompanyCode,
							XMLData.CompanyName,
							XMLData.CompanyNameL,
							XMLData.CompanyDesc,
							XMLData.CompanyDescL,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										CompanyName NVARCHAR(50),
										CompanyNameL NVARCHAR(50),
										CompanyDesc NVARCHAR(200),
										CompanyDescL NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = SourceTable.CompanyCode,
					CompanyName = SourceTable.CompanyName,
					CompanyNameL = SourceTable.CompanyNameL,
					CompanyDesc = SourceTable.CompanyDesc,
					CompanyDescL = SourceTable.CompanyDescL,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						CompanyName,
						CompanyNameL,
						CompanyDesc,
						CompanyDescL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.CompanyName,
							SourceTable.CompanyNameL,
							SourceTable.CompanyDesc,
							SourceTable.CompanyDescL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CompanyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.CompanyCode
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.CompanyCode,
							XMLData.CompanyName,
							XMLData.CompanyNameL,
							XMLData.CompanyDesc,
							XMLData.CompanyDescL,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										CompanyName NVARCHAR(50),
										CompanyNameL NVARCHAR(50),
										CompanyDesc NVARCHAR(200),
										CompanyDescL NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode
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
									XMLData.OldCompanyCode,
									XMLData.CompanyCode,
									XMLData.CompanyName,
									XMLData.CompanyNameL,
									XMLData.CompanyDesc,
									XMLData.CompanyDescL,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 CompanyName NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 CompanyDesc NVARCHAR(200),
											 CompanyDescL NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.CompanyCode
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.CompanyCode,
									XMLData.CompanyName,
									XMLData.CompanyNameL,
									XMLData.CompanyDesc,
									XMLData.CompanyDescL,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 CompanyName NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 CompanyDesc NVARCHAR(200),
											 CompanyDescL NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.CompanyCode
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.CompanyCode,
									XMLData.CompanyName,
									XMLData.CompanyNameL,
									XMLData.CompanyDesc,
									XMLData.CompanyDescL,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 CompanyName NVARCHAR(50),
											 CompanyNameL NVARCHAR(50),
											 CompanyDesc NVARCHAR(200),
											 CompanyDescL NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @CompanyCode,
								 @CompanyName,
								 @CompanyNameL,
								 @CompanyDesc,
								 @CompanyDescL,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CompanyInfo WHERE CompanyCode = @CompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompanyCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CompanyInfo', @CompanyCode OUTPUT

                        INSERT INTO STB_CompanyInfo
						(
						    CompanyCode,
						    CompanyName,
						    CompanyNameL,
						    CompanyDesc,
						    CompanyDescL,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CompanyCode,
						    @CompanyName,
						    @CompanyNameL,
						    @CompanyDesc,
						    @CompanyDescL,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

					END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                        UPDATE STB_CompanyInfo
						SET
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    CompanyName =   CASE
						                WHEN @CompanyName IS NOT NULL THEN @CompanyName
						                ELSE CompanyName
						            END,
						    CompanyNameL =   CASE
						                WHEN @CompanyNameL IS NOT NULL THEN @CompanyNameL
						                ELSE CompanyNameL
						            END,
						    CompanyDesc =   CASE
						                WHEN @CompanyDesc IS NOT NULL THEN @CompanyDesc
						                ELSE CompanyDesc
						            END,
						    CompanyDescL =   CASE
						                WHEN @CompanyDescL IS NOT NULL THEN @CompanyDescL
						                ELSE CompanyDescL
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
						    CompanyCode = @OldCompanyCode
                    END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_CompanyInfo
						WHERE
						    CompanyCode = @CompanyCode
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

