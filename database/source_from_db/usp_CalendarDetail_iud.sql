

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 근무카렌더 관리
-- Description:	근무 카렌더 디테일 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CalendarDetail_iud]
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
  DECLARE @OldSeqNo VARCHAR(4)
  DECLARE @CalendarCode VARCHAR(10)
  DECLARE @SeqNo VARCHAR(4)
  DECLARE @StartTime DATETIME
  DECLARE @EndTime DATETIME
  DECLARE @IsWork BIT
  DECLARE @RestType BIT
  DECLARE @ShiftCode VARCHAR(1)
  DECLARE @TimeCode VARCHAR(2)
  
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


  DECLARE @UID_KEY VARCHAR(50)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CalendarDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			

    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CalendarDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							CASE
							    WHEN XMLData.OldSeqNo IS NULL THEN XMLData.SeqNo
							    ELSE XMLData.OldSeqNo
							END AS OldSeqNo,
							XMLData.CalendarCode,
							XMLData.SeqNo,
							XMLData.StartTime,
							XMLData.EndTime,
							XMLData.IsWork,
							XMLData.RestType,
							XMLData.ShiftCode,
							XMLData.TimeCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										OldSeqNo VARCHAR(4),
										CalendarCode VARCHAR(10),
										SeqNo VARCHAR(4),
										StartTime DATETIMEOFFSET,
										EndTime DATETIMEOFFSET,
										IsWork BIT,
										RestType BIT,
										ShiftCode VARCHAR(1),
										TimeCode VARCHAR(2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.CalendarCode AND
					TargetTable.SeqNo = SourceTable.SeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CalendarCode = SourceTable.CalendarCode,
					SeqNo = SourceTable.SeqNo,
					StartTime = SourceTable.StartTime,
					EndTime = SourceTable.EndTime,
					IsWork = SourceTable.IsWork,
					RestType = SourceTable.RestType,
					ShiftCode = SourceTable.ShiftCode,
					TimeCode = SourceTable.TimeCode,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CalendarCode,
						SeqNo,
						StartTime,
						EndTime,
						IsWork,
						RestType,
						ShiftCode,
						TimeCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CalendarCode,
							--SourceTable.SeqNo,
							SmartFramework.dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL((SELECT MAX(SeqNo) FROM STB_CalendarDetail WHERE CalendarCode = SourceTable.CalendarCode),0)) + 1,4),
							SourceTable.StartTime,
							SourceTable.EndTime,
							SourceTable.IsWork,
							SourceTable.RestType,
							SourceTable.ShiftCode,
							SourceTable.TimeCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CalendarDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							CASE
							    WHEN XMLData.OldSeqNo IS NULL THEN XMLData.SeqNo
							    ELSE XMLData.OldSeqNo
							END AS OldSeqNo,
							XMLData.CalendarCode,
							XMLData.SeqNo,
							XMLData.StartTime,
							XMLData.EndTime,
							XMLData.IsWork,
							XMLData.RestType,
							XMLData.ShiftCode,
							XMLData.TimeCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										OldSeqNo VARCHAR(4),
										CalendarCode VARCHAR(10),
										SeqNo VARCHAR(4),
										StartTime DATETIMEOFFSET,
										EndTime DATETIMEOFFSET,
										IsWork BIT,
										RestType BIT,
										ShiftCode VARCHAR(1),
										TimeCode VARCHAR(2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.OldCalendarCode AND
					TargetTable.SeqNo = SourceTable.OldSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CalendarCode = SourceTable.CalendarCode,
					SeqNo = SourceTable.SeqNo,
					StartTime = SourceTable.StartTime,
					EndTime = SourceTable.EndTime,
					IsWork = SourceTable.IsWork,
					RestType = SourceTable.RestType,
					ShiftCode = SourceTable.ShiftCode,
					TimeCode = SourceTable.TimeCode,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CalendarCode,
						SeqNo,
						StartTime,
						EndTime,
						IsWork,
						RestType,
						ShiftCode,
						TimeCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CalendarCode,
							--SourceTable.SeqNo,
							SmartFramework.dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL((SELECT MAX(SeqNo) FROM STB_CalendarDetail WHERE CalendarCode = SourceTable.CalendarCode),0)) + 1,4),
							SourceTable.StartTime,
							SourceTable.EndTime,
							SourceTable.IsWork,
							SourceTable.RestType,
							SourceTable.ShiftCode,
							SourceTable.TimeCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CalendarDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.CalendarCode
							    ELSE XMLData.OldCalendarCode
							END AS OldCalendarCode,
							CASE
							    WHEN XMLData.OldSeqNo IS NULL THEN XMLData.SeqNo
							    ELSE XMLData.OldSeqNo
							END AS OldSeqNo,
							XMLData.CalendarCode,
							XMLData.SeqNo,
							XMLData.StartTime,
							XMLData.EndTime,
							XMLData.IsWork,
							XMLData.RestType,
							XMLData.ShiftCode,
							XMLData.TimeCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCalendarCode VARCHAR(10),
										OldSeqNo VARCHAR(4),
										CalendarCode VARCHAR(10),
										SeqNo VARCHAR(4),
										StartTime DATETIMEOFFSET,
										EndTime DATETIMEOFFSET,
										IsWork BIT,
										RestType BIT,
										ShiftCode VARCHAR(1),
										TimeCode VARCHAR(2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.CalendarCode = SourceTable.CalendarCode AND
					TargetTable.SeqNo = SourceTable.SeqNo
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
									XMLData.OldSeqNo,
									XMLData.CalendarCode,
									XMLData.SeqNo,
									XMLData.StartTime,
									XMLData.EndTime,
									XMLData.IsWork,
									XMLData.RestType,
									XMLData.ShiftCode,
									XMLData.TimeCode,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 OldSeqNo VARCHAR(4),
											 CalendarCode VARCHAR(10),
											 SeqNo VARCHAR(4),
											 StartTime DATETIMEOFFSET,
											 EndTime DATETIMEOFFSET,
											 IsWork BIT,
											 RestType BIT,
											 ShiftCode VARCHAR(1),
											 TimeCode VARCHAR(2),
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
									CASE 
										WHEN XMLData.OldSeqNo IS NULL THEN XMLData.SeqNo
										ELSE XMLData.OldSeqNo
									END AS OldSeqNo,
									XMLData.CalendarCode,
									XMLData.SeqNo,
									XMLData.StartTime,
									XMLData.EndTime,
									XMLData.IsWork,
									XMLData.RestType,
									XMLData.ShiftCode,
									XMLData.TimeCode,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 OldSeqNo VARCHAR(4),
											 CalendarCode VARCHAR(10),
											 SeqNo VARCHAR(4),
											 StartTime DATETIMEOFFSET,
											 EndTime DATETIMEOFFSET,
											 IsWork BIT,
											 RestType BIT,
											 ShiftCode VARCHAR(1),
											 TimeCode VARCHAR(2),
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
									CASE 
										WHEN XMLData.OldCalendarCode IS NULL THEN XMLData.SeqNo
										ELSE XMLData.OldCalendarCode
									END AS OldSeqNo,
									XMLData.CalendarCode,
									XMLData.SeqNo,
									XMLData.StartTime,
									XMLData.EndTime,
									XMLData.IsWork,
									XMLData.RestType,
									XMLData.ShiftCode,
									XMLData.TimeCode,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCalendarCode VARCHAR(10),
											 OldSeqNo VARCHAR(4),
											 CalendarCode VARCHAR(10),
											 SeqNo VARCHAR(4),
											 StartTime DATETIMEOFFSET,
											 EndTime DATETIMEOFFSET,
											 IsWork BIT,
											 RestType BIT,
											 ShiftCode VARCHAR(1),
											 TimeCode VARCHAR(2),
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
								 @OldSeqNo,
								 @CalendarCode,
								 @SeqNo,
								 @StartTime,
								 @EndTime,
								 @IsWork,
								 @RestType,
								 @ShiftCode,
								 @TimeCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

     --               IF EXISTS (SELECT 1 FROM STB_CalendarDetail WHERE CalendarCode = @CalendarCode) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CalendarCode)
					--END
					
					-- 임시 SEQUENCE TABLE 사용 버젼
					SET @UID_KEY = @OldCalendarCode
					SET @OldCalendarCode = @CalendarCode
					
					SET @CalendarCode = NULL
					
					SELECT 
							@CalendarCode = KeyValue
					FROM 
							#SEQUENCE_TABLE
					WHERE
							UID_KEY = @UID_KEY
					
					IF @CalendarCode IS NULL
					BEGIN
						SET @CalendarCode = @OldCalendarCode
					END
					--

                    IF @IsAutoKey = 1 BEGIN
						--SELECT
						--		@MaxKeyField = MAX(CalendarCode)
						--FROM
						--		STB_CalendarDetail 
						--WHERE
						--		CalendarCode LIKE @PrefixString + '%'
													
						--IF @MaxKeyField IS NULL BEGIN
						--    SET @CalendarCode = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						--END ELSE BEGIN
						--    SET @CalendarCode = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						--END
						
						SET @SeqNo = SmartFramework.dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL((SELECT MAX(SeqNo) FROM STB_CalendarDetail WHERE CalendarCode = @CalendarCode),0)) + 1,4)
                    END

                    INSERT INTO STB_CalendarDetail
						(
						    CalendarCode,
						    SeqNo,
						    StartTime,
						    EndTime,
						    IsWork,
						    RestType,
						    ShiftCode,
						    TimeCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CalendarCode,
						    @SeqNo,
						    @StartTime,
						    @EndTime,
						    @IsWork,
						    @RestType,
						    @ShiftCode,
						    @TimeCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CalendarDetail
						SET
						    CalendarCode =   CASE
						                WHEN @CalendarCode IS NOT NULL THEN @CalendarCode
						                ELSE CalendarCode
						            END,
						    SeqNo =   CASE
						                WHEN @SeqNo IS NOT NULL THEN @SeqNo
						                ELSE SeqNo
						            END,
						    StartTime =   CASE
						                WHEN @StartTime IS NOT NULL THEN @StartTime
						                ELSE StartTime
						            END,
						    EndTime =   CASE
						                WHEN @EndTime IS NOT NULL THEN @EndTime
						                ELSE EndTime
						            END,
						    IsWork =   CASE
						                WHEN @IsWork IS NOT NULL THEN @IsWork
						                ELSE IsWork
						            END,
						    RestType =   CASE
						                WHEN @RestType IS NOT NULL THEN @RestType
						                ELSE RestType
						            END,
						    ShiftCode =   CASE
						                WHEN @ShiftCode IS NOT NULL THEN @ShiftCode
						                ELSE ShiftCode
						            END,
						    TimeCode = CASE 
									WHEN @TimeCode IS NOT NULL THEN @TimeCode
									ELSE TimeCode
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
						    CalendarCode = @OldCalendarCode AND
						    SeqNo = @OldSeqNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CalendarDetail
						WHERE
						    CalendarCode = @CalendarCode AND
						    SeqNo = @SeqNo
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


