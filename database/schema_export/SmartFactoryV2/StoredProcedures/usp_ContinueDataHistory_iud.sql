-- Procedure: usp_ContinueDataHistory_iud


-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-09-21
-- Browsable : true
-- Group : 금형온도이력
-- Description:	금형온도이력마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ContinueDataHistory_iud]
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
  DECLARE @OldMeasureSeq BIGINT
  DECLARE @MeasureSeq BIGINT
  DECLARE @DataGroup VARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @OptionField VARCHAR(50)
  DECLARE @MeasureDateTime DATETIME
  DECLARE @IsAlarm BIT
  DECLARE @IsAlarmStart BIT
  DECLARE @AlarmRemark NVARCHAR(MAX)
  DECLARE @AlarmRemarkUserID VARCHAR(20)
  DECLARE @AlarmRemarkDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @AlarmEndDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ContinueDataHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ContinueDataHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMeasureSeq IS NULL THEN MeasureSeq
							    ELSE OldMeasureSeq
							END AS OldMeasureSeq,
							MeasureSeq,
							DataGroup,
							CompanyCode,
							WorkCenterCode,
							MachineCode,
							OptionField,
							MeasureDateTime,
							IsAlarm,
							IsAlarmStart,
							AlarmRemark,
							AlarmRemarkUserID,
							AlarmRemarkDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							AlarmEndDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMeasureSeq BIGINT,
										MeasureSeq BIGINT,
										DataGroup VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										OptionField VARCHAR(50),
										MeasureDateTime DATETIMEOFFSET,
										IsAlarm BIT,
										IsAlarmStart BIT,
										AlarmRemark NVARCHAR(MAX),
										AlarmRemarkUserID VARCHAR(20),
										AlarmRemarkDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										AlarmEndDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MeasureSeq = SourceTable.MeasureSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					AlarmRemark = ISNULL(SourceTable.AlarmRemark,TargetTable.AlarmRemark),
					AlarmRemarkUserID = ISNULL(SourceTable.AlarmRemarkUserID,TargetTable.AlarmRemarkUserID),
					AlarmRemarkDateTime = ISNULL(SourceTable.AlarmRemarkDateTime,TargetTable.AlarmRemarkDateTime),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DataGroup,
						CompanyCode,
						WorkCenterCode,
						MachineCode,
						OptionField,
						MeasureDateTime,
						IsAlarm,
						IsAlarmStart,
						AlarmRemark,
						AlarmRemarkUserID,
						AlarmRemarkDateTime,
						CreateDateTime,
						CreateUserID,
						AlarmEndDateTime
					)
				VALUES
					(
							SourceTable.DataGroup,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineCode,
							SourceTable.OptionField,
							SourceTable.MeasureDateTime,
							SourceTable.IsAlarm,
							SourceTable.IsAlarmStart,
							SourceTable.AlarmRemark,
							SourceTable.AlarmRemarkUserID,
							SourceTable.AlarmRemarkDateTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.AlarmEndDateTime
					);


			-- Process Update Table
            MERGE STB_ContinueDataHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMeasureSeq IS NULL THEN MeasureSeq
							    ELSE OldMeasureSeq
							END AS OldMeasureSeq,
							MeasureSeq,
							DataGroup,
							CompanyCode,
							WorkCenterCode,
							MachineCode,
							OptionField,
							MeasureDateTime,
							IsAlarm,
							IsAlarmStart,
							AlarmRemark,
							AlarmRemarkUserID,
							AlarmRemarkDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							AlarmEndDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMeasureSeq BIGINT,
										MeasureSeq BIGINT,
										DataGroup VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										OptionField VARCHAR(50),
										MeasureDateTime DATETIMEOFFSET,
										IsAlarm BIT,
										IsAlarmStart BIT,
										AlarmRemark NVARCHAR(MAX),
										AlarmRemarkUserID VARCHAR(20),
										AlarmRemarkDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										AlarmEndDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MeasureSeq = SourceTable.OldMeasureSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					AlarmRemark = ISNULL(SourceTable.AlarmRemark,TargetTable.AlarmRemark),
					AlarmRemarkUserID = @ProcessUserID,--ISNULL(SourceTable.AlarmRemarkUserID,TargetTable.AlarmRemarkUserID),
					AlarmRemarkDateTime = GETDATE(),--ISNULL(SourceTable.AlarmRemarkDateTime,TargetTable.AlarmRemarkDateTime),
					ChangeDateTime = GETDATE(),--ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = @ProcessUserID--ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DataGroup,
						CompanyCode,
						WorkCenterCode,
						MachineCode,
						OptionField,
						MeasureDateTime,
						IsAlarm,
						IsAlarmStart,
						AlarmRemark,
						AlarmRemarkUserID,
						AlarmRemarkDateTime,
						CreateDateTime,
						CreateUserID,
						AlarmEndDateTime
					)
				VALUES
					(
							SourceTable.DataGroup,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineCode,
							SourceTable.OptionField,
							SourceTable.MeasureDateTime,
							SourceTable.IsAlarm,
							SourceTable.IsAlarmStart,
							SourceTable.AlarmRemark,
							SourceTable.AlarmRemarkUserID,
							SourceTable.AlarmRemarkDateTime,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.AlarmEndDateTime
					);


			-- Process Delete Table
            MERGE STB_ContinueDataHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMeasureSeq IS NULL THEN MeasureSeq
							    ELSE OldMeasureSeq
							END AS OldMeasureSeq,
							MeasureSeq,
							DataGroup,
							CompanyCode,
							WorkCenterCode,
							MachineCode,
							OptionField,
							MeasureDateTime,
							IsAlarm,
							IsAlarmStart,
							AlarmRemark,
							AlarmRemarkUserID,
							AlarmRemarkDateTime,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							AlarmEndDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMeasureSeq BIGINT,
										MeasureSeq BIGINT,
										DataGroup VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										OptionField VARCHAR(50),
										MeasureDateTime DATETIMEOFFSET,
										IsAlarm BIT,
										IsAlarmStart BIT,
										AlarmRemark NVARCHAR(MAX),
										AlarmRemarkUserID VARCHAR(20),
										AlarmRemarkDateTime DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										AlarmEndDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MeasureSeq = SourceTable.MeasureSeq
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
									OldMeasureSeq,
									MeasureSeq,
									DataGroup,
									CompanyCode,
									WorkCenterCode,
									MachineCode,
									OptionField,
									MeasureDateTime,
									IsAlarm,
									IsAlarmStart,
									AlarmRemark,
									AlarmRemarkUserID,
									AlarmRemarkDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AlarmEndDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMeasureSeq BIGINT,
											 MeasureSeq BIGINT,
											 DataGroup VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 OptionField VARCHAR(50),
											 MeasureDateTime DATETIMEOFFSET,
											 IsAlarm BIT,
											 IsAlarmStart BIT,
											 AlarmRemark NVARCHAR(MAX),
											 AlarmRemarkUserID VARCHAR(20),
											 AlarmRemarkDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AlarmEndDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMeasureSeq IS NULL THEN MeasureSeq
										ELSE OldMeasureSeq
									END AS OldMeasureSeq,
									MeasureSeq,
									DataGroup,
									CompanyCode,
									WorkCenterCode,
									MachineCode,
									OptionField,
									MeasureDateTime,
									IsAlarm,
									IsAlarmStart,
									AlarmRemark,
									AlarmRemarkUserID,
									AlarmRemarkDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AlarmEndDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMeasureSeq BIGINT,
											 MeasureSeq BIGINT,
											 DataGroup VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 OptionField VARCHAR(50),
											 MeasureDateTime DATETIMEOFFSET,
											 IsAlarm BIT,
											 IsAlarmStart BIT,
											 AlarmRemark NVARCHAR(MAX),
											 AlarmRemarkUserID VARCHAR(20),
											 AlarmRemarkDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AlarmEndDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMeasureSeq IS NULL THEN MeasureSeq
										ELSE OldMeasureSeq
									END AS OldMeasureSeq,
									MeasureSeq,
									DataGroup,
									CompanyCode,
									WorkCenterCode,
									MachineCode,
									OptionField,
									MeasureDateTime,
									IsAlarm,
									IsAlarmStart,
									AlarmRemark,
									AlarmRemarkUserID,
									AlarmRemarkDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									AlarmEndDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMeasureSeq BIGINT,
											 MeasureSeq BIGINT,
											 DataGroup VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 OptionField VARCHAR(50),
											 MeasureDateTime DATETIMEOFFSET,
											 IsAlarm BIT,
											 IsAlarmStart BIT,
											 AlarmRemark NVARCHAR(MAX),
											 AlarmRemarkUserID VARCHAR(20),
											 AlarmRemarkDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 AlarmEndDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMeasureSeq,
								 @MeasureSeq,
								 @DataGroup,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MachineCode,
								 @OptionField,
								 @MeasureDateTime,
								 @IsAlarm,
								 @IsAlarmStart,
								 @AlarmRemark,
								 @AlarmRemarkUserID,
								 @AlarmRemarkDateTime,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @AlarmEndDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ContinueDataHistory WHERE MeasureSeq = @MeasureSeq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MeasureSeq)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_ContinueDataHistory',
																	@MeasureSeq OUTPUT
                    END

                    INSERT INTO STB_ContinueDataHistory
						(
						    DataGroup,
						    CompanyCode,
						    WorkCenterCode,
						    MachineCode,
						    OptionField,
						    MeasureDateTime,
						    IsAlarm,
						    IsAlarmStart,
						    AlarmRemark,
						    AlarmRemarkUserID,
						    AlarmRemarkDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    AlarmEndDateTime
						)
						VALUES
						(
						    @DataGroup,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MachineCode,
						    @OptionField,
						    @MeasureDateTime,
						    @IsAlarm,
						    @IsAlarmStart,
						    @AlarmRemark,
						    @AlarmRemarkUserID,
						    @AlarmRemarkDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @AlarmEndDateTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ContinueDataHistory
						SET
						    AlarmRemark =   ISNULL(@AlarmRemark,AlarmRemark),
						    AlarmRemarkUserID =   ISNULL(@ProcessUserID,AlarmRemarkUserID),
						    AlarmRemarkDateTime =   GETDATE(),
						    ChangeDateTime =   GETDATE(),
						    ChangeUserID =   ISNULL(@ProcessUserID,ChangeUserID)
						WHERE
						    MeasureSeq = @OldMeasureSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ContinueDataHistory
						WHERE
						    MeasureSeq = @OldMeasureSeq
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

