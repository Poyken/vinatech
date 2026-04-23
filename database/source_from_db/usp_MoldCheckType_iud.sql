

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형점검유형정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckType_iud]
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
  DECLARE @OldMoldCheckTypeCode VARCHAR(20)
  DECLARE @MoldCheckTypeCode VARCHAR(20)
  DECLARE @MoldCheckTypeName NVARCHAR(50)
  DECLARE @MoldCheckTypeDesc NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldCheckType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldCheckType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckTypeCode IS NULL THEN XMLData.MoldCheckTypeCode
							    ELSE XMLData.OldMoldCheckTypeCode
							END AS OldMoldCheckTypeCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckTypeName,
							XMLData.MoldCheckTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeName NVARCHAR(50),
										MoldCheckTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckTypeCode = SourceTable.MoldCheckTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckTypeCode = SourceTable.MoldCheckTypeCode,
					MoldCheckTypeName = SourceTable.MoldCheckTypeName,
					MoldCheckTypeDesc = SourceTable.MoldCheckTypeDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckTypeCode,
						MoldCheckTypeName,
						MoldCheckTypeDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckTypeCode,
							SourceTable.MoldCheckTypeName,
							SourceTable.MoldCheckTypeDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldCheckType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckTypeCode IS NULL THEN XMLData.MoldCheckTypeCode
							    ELSE XMLData.OldMoldCheckTypeCode
							END AS OldMoldCheckTypeCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckTypeName,
							XMLData.MoldCheckTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeName NVARCHAR(50),
										MoldCheckTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckTypeCode = SourceTable.OldMoldCheckTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckTypeCode = SourceTable.MoldCheckTypeCode,
					MoldCheckTypeName = SourceTable.MoldCheckTypeName,
					MoldCheckTypeDesc = SourceTable.MoldCheckTypeDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckTypeCode,
						MoldCheckTypeName,
						MoldCheckTypeDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckTypeCode,
							SourceTable.MoldCheckTypeName,
							SourceTable.MoldCheckTypeDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldCheckType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckTypeCode IS NULL THEN XMLData.MoldCheckTypeCode
							    ELSE XMLData.OldMoldCheckTypeCode
							END AS OldMoldCheckTypeCode,
							XMLData.MoldCheckTypeCode,
							XMLData.MoldCheckTypeName,
							XMLData.MoldCheckTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeCode VARCHAR(20),
										MoldCheckTypeName NVARCHAR(50),
										MoldCheckTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckTypeCode = SourceTable.MoldCheckTypeCode
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
									XMLData.OldMoldCheckTypeCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckTypeName,
									XMLData.MoldCheckTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeName NVARCHAR(50),
											 MoldCheckTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckTypeCode IS NULL THEN XMLData.MoldCheckTypeCode
										ELSE XMLData.OldMoldCheckTypeCode
									END AS OldMoldCheckTypeCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckTypeName,
									XMLData.MoldCheckTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeName NVARCHAR(50),
											 MoldCheckTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckTypeCode IS NULL THEN XMLData.MoldCheckTypeCode
										ELSE XMLData.OldMoldCheckTypeCode
									END AS OldMoldCheckTypeCode,
									XMLData.MoldCheckTypeCode,
									XMLData.MoldCheckTypeName,
									XMLData.MoldCheckTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeCode VARCHAR(20),
											 MoldCheckTypeName NVARCHAR(50),
											 MoldCheckTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldCheckTypeCode,
								 @MoldCheckTypeCode,
								 @MoldCheckTypeName,
								 @MoldCheckTypeDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldCheckType WHERE MoldCheckTypeCode = @MoldCheckTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldCheckTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldCheckType',
																	@MoldCheckTypeCode OUTPUT
                    END

                    INSERT INTO STB_MoldCheckType
						(
						    MoldCheckTypeCode,
						    MoldCheckTypeName,
						    MoldCheckTypeDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldCheckTypeCode,
						    @MoldCheckTypeName,
						    @MoldCheckTypeDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldCheckType
						SET
						    MoldCheckTypeCode =   CASE
						                WHEN @MoldCheckTypeCode IS NOT NULL THEN @MoldCheckTypeCode
						                ELSE MoldCheckTypeCode
						            END,
						    MoldCheckTypeName =   CASE
						                WHEN @MoldCheckTypeName IS NOT NULL THEN @MoldCheckTypeName
						                ELSE MoldCheckTypeName
						            END,
						    MoldCheckTypeDesc =   CASE
						                WHEN @MoldCheckTypeDesc IS NOT NULL THEN @MoldCheckTypeDesc
						                ELSE MoldCheckTypeDesc
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
						    MoldCheckTypeCode = @OldMoldCheckTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldCheckType
						WHERE
						    MoldCheckTypeCode = @MoldCheckTypeCode
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



