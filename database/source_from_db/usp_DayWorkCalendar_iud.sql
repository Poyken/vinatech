

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-03
-- Browsable : true
-- Group : 일일근무카렌더
-- Description:	일일근무카렌더 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayWorkCalendar_iud]
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
  DECLARE @OldDayWorkCalendarNo VARCHAR(20)
  DECLARE @DayWorkCalendarNo VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @FacilityRouteCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @CalendarCode VARCHAR(10)
  DECLARE @StartDateTime DATETIME
  DECLARE @EndDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
	
  
  DECLARE @DayWorkCalendar_Validation VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DayWorkCalendar',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
			
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldDayWorkCalendarNo,
									DayWorkCalendarNo,
									JobDate,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									CalendarCode,
									StartDateTime,
									EndDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDayWorkCalendarNo VARCHAR(20),
											 DayWorkCalendarNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CalendarCode VARCHAR(10),
											 StartDateTime DATETIMEOFFSET,
											 EndDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDayWorkCalendarNo IS NULL THEN DayWorkCalendarNo
										ELSE OldDayWorkCalendarNo
									END AS OldDayWorkCalendarNo,
									DayWorkCalendarNo,
									JobDate,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									CalendarCode,
									StartDateTime,
									EndDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDayWorkCalendarNo VARCHAR(20),
											 DayWorkCalendarNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CalendarCode VARCHAR(10),
											 StartDateTime DATETIMEOFFSET,
											 EndDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDayWorkCalendarNo IS NULL THEN DayWorkCalendarNo
										ELSE OldDayWorkCalendarNo
									END AS OldDayWorkCalendarNo,
									DayWorkCalendarNo,
									JobDate,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									FacilityRouteCode,
									MachineCode,
									CalendarCode,
									StartDateTime,
									EndDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDayWorkCalendarNo VARCHAR(20),
											 DayWorkCalendarNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 FacilityRouteCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 CalendarCode VARCHAR(10),
											 StartDateTime DATETIMEOFFSET,
											 EndDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDayWorkCalendarNo,
								 @DayWorkCalendarNo,
								 @JobDate,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @RouteCode,
								 @FacilityRouteCode,
								 @MachineCode,
								 @CalendarCode,
								 @StartDateTime,
								 @EndDateTime,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID



                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

     --               IF EXISTS (SELECT 1 FROM STB_DayWorkCalendar WHERE DayWorkCalendarNo = @DayWorkCalendarNo) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DayWorkCalendarNo)
					--END
					
					
						
							
					SELECT
							@DayWorkCalendar_Validation = DayWorkCalendarNo
					FROM
							STB_DayWorkCalendar
					WHERE
							((JobDate = @JobDate)) AND
							((CompanyCode = ISNULL(@CompanyCode,''))) AND
							((WorkCenterCode = ISNULL(@WorkCenterCode,''))) AND
							((LineCode = ISNULL(@LineCode,''))) AND
							((RouteCode = ISNULL(@RouteCode,''))) AND
							((FacilityRouteCode = ISNULL(@FacilityRouteCode,''))) AND
							((MachineCode = ISNULL(@MachineCode,''))) 
							
					
					IF ISNULL(@DayWorkCalendar_Validation,'') <> '' BEGIN
					
						UPDATE STB_DayWorkCalendar
						SET
								JobDate = @JobDate,
								CompanyCode = ISNULL(@CompanyCode,''),
								WorkCenterCode = ISNULL(@WorkCenterCode,''),
								LineCode = ISNULL(@LineCode,''),
								RouteCode = ISNULL(@RouteCode,''),
								FacilityRouteCode = ISNULL(@FacilityRouteCode,''),
								MachineCode = ISNULL(@MachineCode,''),
								CalendarCode = ISNULL(@CalendarCode,''),
								ChangeDateTime = GETDATE(),
								ChangeUserID = @ProcessUserID
						WHERE
								
								((JobDate = @JobDate)) AND
								((CompanyCode = ISNULL(@CompanyCode,''))) AND
								((WorkCenterCode = ISNULL(@WorkCenterCode,''))) AND
								((LineCode = ISNULL(@LineCode,''))) AND
								((RouteCode = ISNULL(@RouteCode,''))) AND
								((FacilityRouteCode = ISNULL(@FacilityRouteCode,''))) AND
								((MachineCode = ISNULL(@MachineCode,''))) 
								
						EXEC usp_DoWorkCalendar_IUD @pProcessLanguage = @ProcessLanguage,
														@pProcessUserID = @ProcessUserID,
														@pDayWorkCalendarNo = @DayWorkCalendar_Validation,
														@pCalendarCode = @CalendarCode,
														@pJobDate = @JobDate 
						
					END ELSE BEGIN
					
						
						 IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayWorkCalendar', @DayWorkCalendarNo OUTPUT
						END
						
						INSERT INTO STB_DayWorkCalendar
						(
						    DayWorkCalendarNo,
						    JobDate,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    RouteCode,
						    FacilityRouteCode,
						    MachineCode,
						    CalendarCode,
						    StartDateTime,
						    EndDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DayWorkCalendarNo,
						    @JobDate,
						    ISNULL(@CompanyCode,''),
						    ISNULL(@WorkCenterCode,''),
						    ISNULL(@LineCode,''),
						    ISNULL(@RouteCode,''),
						    ISNULL(@FacilityRouteCode,''),
						    ISNULL(@MachineCode,''),
						    ISNULL(@CalendarCode,''),
						    @StartDateTime,
						    @EndDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
						
						
						EXEC usp_DoWorkCalendar_IUD @pProcessLanguage = @ProcessLanguage,
													@pProcessUserID = @ProcessUserID,
													@pDayWorkCalendarNo = @DayWorkCalendarNo,
													@pCalendarCode = @CalendarCode,
													@pJobDate = @JobDate 
						
					END			
							

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				                   
                    
                    SELECT
							@DayWorkCalendar_Validation = DayWorkCalendarNo
					FROM
							STB_DayWorkCalendar
					WHERE
							((JobDate = @JobDate)) AND
							((CompanyCode = ISNULL(@CompanyCode,''))) AND
							((WorkCenterCode = ISNULL(@WorkCenterCode,''))) AND
							((LineCode = ISNULL(@LineCode,''))) AND
							((RouteCode = ISNULL(@RouteCode,''))) AND
							((FacilityRouteCode = ISNULL(@FacilityRouteCode,''))) AND
							((MachineCode = ISNULL(@MachineCode,''))) 
					
					IF ISNULL(@DayWorkCalendar_Validation,'') <> '' BEGIN
						
						
						UPDATE STB_DayWorkCalendar
						SET
								JobDate = @JobDate,
								CompanyCode = ISNULL(@CompanyCode,''),
								WorkCenterCode = ISNULL(@WorkCenterCode,''),
								LineCode = ISNULL(@LineCode,''),
								RouteCode = ISNULL(@RouteCode,''),
								FacilityRouteCode = ISNULL(@FacilityRouteCode,''),
								MachineCode = ISNULL(@MachineCode,''),
								CalendarCode = ISNULL(@CalendarCode,''),
								ChangeDateTime = GETDATE(),
								ChangeUserID = @ProcessUserID
						WHERE
								
								((JobDate = @JobDate)) AND
								((CompanyCode = ISNULL(@CompanyCode,''))) AND
								((WorkCenterCode = ISNULL(@WorkCenterCode,''))) AND
								((LineCode = ISNULL(@LineCode,''))) AND
								((RouteCode = ISNULL(@RouteCode,''))) AND
								((FacilityRouteCode = ISNULL(@FacilityRouteCode,''))) AND
								((MachineCode = ISNULL(@MachineCode,''))) 
								
						EXEC usp_DoWorkCalendar_IUD	@pProcessLanguage = @ProcessLanguage,
													@pProcessUserID = @ProcessUserID,
													@pDayWorkCalendarNo = @DayWorkCalendar_Validation,
													@pCalendarCode = @CalendarCode,
													@pJobDate = @JobDate 
						
					END ELSE BEGIN
					
						
						
						IF @IsAutoKey = 1 BEGIN
							SELECT
									@MaxKeyField = MAX(DayWorkCalendarNo)
							FROM
									STB_DayWorkCalendar 
							WHERE
									DayWorkCalendarNo LIKE @PrefixString + '%'
														
							IF @MaxKeyField IS NULL BEGIN
								SET @DayWorkCalendar_Validation = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
							END ELSE BEGIN
								SET @DayWorkCalendar_Validation = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
							END
						END
						
						
						INSERT INTO STB_DayWorkCalendar
						(
						    DayWorkCalendarNo,
						    JobDate,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    RouteCode,
						    FacilityRouteCode,
						    MachineCode,
						    CalendarCode,
						    StartDateTime,
						    EndDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @DayWorkCalendar_Validation,
						    @JobDate,
						    ISNULL(@CompanyCode,''),
						    ISNULL(@WorkCenterCode,''),
						    ISNULL(@LineCode,''),
						    ISNULL(@RouteCode,''),
						    ISNULL(@FacilityRouteCode,''),
						    ISNULL(@MachineCode,''),
						    ISNULL(@CalendarCode,''),
						    @StartDateTime,
						    @EndDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
						
						
						EXEC usp_DoWorkCalendar_IUD @pProcessLanguage = @ProcessLanguage,
													@pProcessUserID = @ProcessUserID,
													@pDayWorkCalendarNo = @DayWorkCalendar_Validation,
													@pCalendarCode = @CalendarCode,
													@pJobDate = @JobDate 
						
					END			
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                
					DELETE FROM STB_DayWorkCalendarDetail
					WHERE
							DayWorkCalendarNo = @DayWorkCalendarNo
							
                    DELETE FROM STB_DayWorkCalendar
						WHERE
						    DayWorkCalendarNo = @DayWorkCalendarNo
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

