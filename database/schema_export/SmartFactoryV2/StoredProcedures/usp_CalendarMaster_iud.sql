-- Procedure: usp_CalendarMaster_iud


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 근무카렌더 관리
-- Description:	근무 카렌더 마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarMaster_iud]
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
  DECLARE @OldCalendarCode VARCHAR(10)
  DECLARE @CalendarCode VARCHAR(10)
  DECLARE @CalendarName NVARCHAR(100)
  DECLARE @CalendarDesc NVARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CalendarMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CalendarMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							XMLData.CalendarCode,
							XMLData.CalendarName,
							XMLData.CalendarDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										CalendarCode VARCHAR(10),
										CalendarName NVARCHAR(100),
										CalendarDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.CalendarCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CalendarCode = SourceTable.CalendarCode,
					CalendarName = SourceTable.CalendarName,
					CalendarDesc = SourceTable.CalendarDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CalendarCode,
						CalendarName,
						CalendarDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CalendarCode,
							SourceTable.CalendarName,
							SourceTable.CalendarDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CalendarMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							XMLData.CalendarCode,
							XMLData.CalendarName,
							XMLData.CalendarDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										CalendarCode VARCHAR(10),
										CalendarName NVARCHAR(100),
										CalendarDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.OldCalendarCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CalendarCode = SourceTable.CalendarCode,
					CalendarName = SourceTable.CalendarName,
					CalendarDesc = SourceTable.CalendarDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CalendarCode,
						CalendarName,
						CalendarDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CalendarCode,
							SourceTable.CalendarName,
							SourceTable.CalendarDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
			
			
			
			
            MERGE STB_CalendarMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							XMLData.CalendarCode,
							XMLData.CalendarName,
							XMLData.CalendarDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										CalendarCode VARCHAR(10),
										CalendarName NVARCHAR(100),
										CalendarDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.CalendarCode
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
									XMLData.OldCalendarCode,
									XMLData.CalendarCode,
									XMLData.CalendarName,
									XMLData.CalendarDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 CalendarCode VARCHAR(10),
											 CalendarName NVARCHAR(100),
											 CalendarDesc NVARCHAR(200),
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
										WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
										ELSE XMLData.OldCalendarCode
									END AS OldCalendarCode,
									XMLData.CalendarCode,
									XMLData.CalendarName,
									XMLData.CalendarDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 CalendarCode VARCHAR(10),
											 CalendarName NVARCHAR(100),
											 CalendarDesc NVARCHAR(200),
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
										WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
										ELSE XMLData.OldCalendarCode
									END AS OldCalendarCode,
									XMLData.CalendarCode,
									XMLData.CalendarName,
									XMLData.CalendarDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 CalendarCode VARCHAR(10),
											 CalendarName NVARCHAR(100),
											 CalendarDesc NVARCHAR(200),
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
								 @OldCalendarCode,
								 @CalendarCode,
								 @CalendarName,
								 @CalendarDesc,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CalendarMaster WHERE CalendarCode = @CalendarCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CalendarCode)
					END
					
					

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CalendarMaster', @CalendarCode OUTPUT
                    END
                    
					-- 임시 SEQUENCE TABLE 사용 버젼
						INSERT INTO #SEQUENCE_TABLE
							(KeyValue, UID_KEY)
						VALUES
							(@CalendarCode, @OldCalendarCode)
					--                    

                    INSERT INTO STB_CalendarMaster
						(
						    CalendarCode,
						    CalendarName,
						    CalendarDesc,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CalendarCode,
						    @CalendarName,
						    @CalendarDesc,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CalendarMaster
						SET
						    CalendarCode =   CASE
						                WHEN @CalendarCode IS NOT NULL THEN @CalendarCode
						                ELSE CalendarCode
						            END,
						    CalendarName =   CASE
						                WHEN @CalendarName IS NOT NULL THEN @CalendarName
						                ELSE CalendarName
						            END,
						    CalendarDesc =   CASE
						                WHEN @CalendarDesc IS NOT NULL THEN @CalendarDesc
						                ELSE CalendarDesc
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
						    CalendarCode = @OldCalendarCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CalendarDetail
						WHERE
						    CalendarCode = @CalendarCode

                    DELETE FROM STB_CalendarMaster
						WHERE
						    CalendarCode = @CalendarCode
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

