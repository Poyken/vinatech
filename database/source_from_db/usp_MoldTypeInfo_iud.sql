-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-01
-- Browsable : true
-- Group : 금형관리
-- Description:	금형타입정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldTypeInfo_iud]
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
  DECLARE @OldMoldTypeCode VARCHAR(20)
  DECLARE @MoldTypeCode VARCHAR(20)
  DECLARE @MoldTypeName NVARCHAR(50)
  DECLARE @MoldTypeDesc NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldTypeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldTypeCode IS NULL THEN XMLData.MoldTypeCode
							    ELSE XMLData.OldMoldTypeCode
							END AS OldMoldTypeCode,
							XMLData.MoldTypeCode,
							XMLData.MoldTypeName,
							XMLData.MoldTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldTypeCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										MoldTypeName NVARCHAR(50),
										MoldTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldTypeCode = SourceTable.MoldTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldTypeCode = SourceTable.MoldTypeCode,
					MoldTypeName = SourceTable.MoldTypeName,
					MoldTypeDesc = SourceTable.MoldTypeDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldTypeCode,
						MoldTypeName,
						MoldTypeDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldTypeCode,
							SourceTable.MoldTypeName,
							SourceTable.MoldTypeDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldTypeCode IS NULL THEN XMLData.MoldTypeCode
							    ELSE XMLData.OldMoldTypeCode
							END AS OldMoldTypeCode,
							XMLData.MoldTypeCode,
							XMLData.MoldTypeName,
							XMLData.MoldTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldTypeCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										MoldTypeName NVARCHAR(50),
										MoldTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldTypeCode = SourceTable.OldMoldTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldTypeCode = SourceTable.MoldTypeCode,
					MoldTypeName = SourceTable.MoldTypeName,
					MoldTypeDesc = SourceTable.MoldTypeDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldTypeCode,
						MoldTypeName,
						MoldTypeDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldTypeCode,
							SourceTable.MoldTypeName,
							SourceTable.MoldTypeDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldTypeCode IS NULL THEN XMLData.MoldTypeCode
							    ELSE XMLData.OldMoldTypeCode
							END AS OldMoldTypeCode,
							XMLData.MoldTypeCode,
							XMLData.MoldTypeName,
							XMLData.MoldTypeDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldTypeCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										MoldTypeName NVARCHAR(50),
										MoldTypeDesc NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldTypeCode = SourceTable.MoldTypeCode
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
									XMLData.OldMoldTypeCode,
									XMLData.MoldTypeCode,
									XMLData.MoldTypeName,
									XMLData.MoldTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldTypeCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldTypeName NVARCHAR(50),
											 MoldTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldTypeCode IS NULL THEN XMLData.MoldTypeCode
										ELSE XMLData.OldMoldTypeCode
									END AS OldMoldTypeCode,
									XMLData.MoldTypeCode,
									XMLData.MoldTypeName,
									XMLData.MoldTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldTypeCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldTypeName NVARCHAR(50),
											 MoldTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldTypeCode IS NULL THEN XMLData.MoldTypeCode
										ELSE XMLData.OldMoldTypeCode
									END AS OldMoldTypeCode,
									XMLData.MoldTypeCode,
									XMLData.MoldTypeName,
									XMLData.MoldTypeDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldTypeCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldTypeName NVARCHAR(50),
											 MoldTypeDesc NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldTypeCode,
								 @MoldTypeCode,
								 @MoldTypeName,
								 @MoldTypeDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldTypeInfo WHERE MoldTypeCode = @MoldTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldTypeInfo',
																	@MoldTypeCode OUTPUT
                    END

                    INSERT INTO STB_MoldTypeInfo
						(
						    MoldTypeCode,
						    MoldTypeName,
						    MoldTypeDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldTypeCode,
						    @MoldTypeName,
						    @MoldTypeDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldTypeInfo
						SET
						    MoldTypeCode =   CASE
						                WHEN @MoldTypeCode IS NOT NULL THEN @MoldTypeCode
						                ELSE MoldTypeCode
						            END,
						    MoldTypeName =   CASE
						                WHEN @MoldTypeName IS NOT NULL THEN @MoldTypeName
						                ELSE MoldTypeName
						            END,
						    MoldTypeDesc =   CASE
						                WHEN @MoldTypeDesc IS NOT NULL THEN @MoldTypeDesc
						                ELSE MoldTypeDesc
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
						    MoldTypeCode = @OldMoldTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldTypeInfo
						WHERE
						    MoldTypeCode = @MoldTypeCode
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



