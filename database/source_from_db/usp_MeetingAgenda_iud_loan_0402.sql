-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_MeetingAgenda_iud_loan_0402
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
  DECLARE @OldID INT
  DECLARE @ID INT
  DECLARE @Years INT
  DECLARE @Months INT
  DECLARE @Days INT
  DECLARE @No INT
  DECLARE @Meeting_Agenda nvarchar(200)
  DECLARE @Customer nvarchar(200)
  DECLARE @Size nvarchar(50)
  DECLARE @RespPlant Nvarchar(50)
  DECLARE @RestTeam nvarchar(50)
  DECLARE @CompleteDate date
  DECLARE @Status nvarchar(20)
  DECLARE @Date_Meeting date
  DECLARE @Attribute1 varchar(200)
  DECLARE @Attribute2 varchar(200)
  DECLARE @Attribute3 varchar(200)
  DECLARE @Attribute4 varchar(200)
  DECLARE @Attribute5 varchar(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

   -- EXEC SmartFramework.dbo.usp_GetSerialRule 
			--@pTableName = 'Stb_MeetingAgenda',
			--@pIsAutoKey = @IsAutoKey OUTPUT,
			--@pIsLoopIUD = @IsLoopIUD OUTPUT,
			--@pPrefixData = @PrefixString OUTPUT,
			--@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE Stb_MeetingAgenda AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldID IS NULL THEN XMLData.ID
							    ELSE XMLData.OldID
							END AS OldID,
							XMLData.ID,
							XMLData.Years,
							XMLData.Months,
							XMLData.Days,
							XMLData.No,
							XMLData.Meeting_Agenda,
							XMLData.Customer,
							XMLData.Size,
							XMLData.RespPlant,
							XMLData.RestTeam,
							XMLData.CompleteDate,
							XMLData.Status,
							XMLData.Date_Meeting,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldID INT,
										ID INT,
										Years int ,
										Months int,
										Days int,
										No int,
										Meeting_Agenda nvarchar(200),
										Customer nvarchar(50),
										Size nvarchar(50),
										RespPlant nvarchar(50),
										RestTeam nvarchar(50),
										CompleteDate date,
										Status nvarchar(20),
										Date_Meeting date,
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)

			WHEN MATCHED THEN
				UPDATE SET
					Years = SourceTable.Years,
					Months = SourceTable.Months,
					Days = SourceTable.Days,
					No = SourceTable.No,
					Meeting_Agenda = SourceTable.Meeting_Agenda,
					Customer = SourceTable.Customer,
					Size = SourceTable.Size,
					RespPlant = SourceTable.RespPlant,
					RestTeam = SourceTable.RestTeam,
					CompleteDate = SourceTable.CompleteDate,
					Status = SourceTable.Status,
					Date_Meeting = SourceTable.Date_Meeting,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						Years,
						Months,
						Days,
						No,
						Meeting_Agenda,
						Customer,
						Size,
						RespPlant,
						RestTeam,
						CompleteDate,
						Status,
						Date_Meeting,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Years,
							SourceTable.Months,
							SourceTable.Days,
							SourceTable.No,
							SourceTable.Meeting_Agenda,
							SourceTable.Customer,
							SourceTable.Size,
							SourceTable.RespPlant,
							SourceTable.RestTeam,
							SourceTable.CompleteDate,
							SourceTable.Status,
							SourceTable.Date_Meeting,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE Stb_MeetingAgenda AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldID IS NULL THEN XMLData.ID
							    ELSE XMLData.OldID
							END AS OldID,
							XMLData.Years,
							XMLData.Months,
							XMLData.Days,
							XMLData.No,
							XMLData.Meeting_Agenda,
							XMLData.Customer,
							XMLData.Size,
							XMLData.RespPlant,
							XMLData.RestTeam,
							XMLData.CompleteDate,
							XMLData.Status,
							XMLData.Date_Meeting,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldID int,
										ID int,
										Years int,
										Months int,
										Days int,
										No int,
										Meeting_Agenda nvarchar(200),
										Customer nvarchar(100),
										Size nvarchar(50),
										RespPlant nvarchar(50),
										RestTeam nvarchar(50),
										CompleteDate date,
										Status nvarchar(20),
										Date_Meeting date,
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.OldID
				)

			WHEN MATCHED THEN
				UPDATE SET
					Years = SourceTable.Years,
					Months = SourceTable.Months,
					Days = SourceTable.Days,
					No = SourceTable.No,
					Meeting_Agenda = SourceTable.Meeting_Agenda,
					Customer = SourceTable.Customer,
					Size = SourceTable.Size,
					RespPlant = SourceTable.RespPlant,
					RestTeam = SourceTable.RestTeam,
					CompleteDate = SourceTable.CompleteDate,
					Status = SourceTable.Status,
					Date_Meeting = SourceTable.Date_Meeting,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						Years,
						Months,
						Days,
						No,
						Meeting_Agenda,
						Customer,
						Size,
						RespPlant,
						RestTeam,
						CompleteDate,
						Status,
						Date_Meeting,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Years,
							SourceTable.Months,
							SourceTable.Days,
							SourceTable.No,
							SourceTable.Meeting_Agenda,
							SourceTable.Customer,
							SourceTable.Size,
							SourceTable.RespPlant,
							SourceTable.RestTeam,
							SourceTable.CompleteDate,
							SourceTable.Status,
							SourceTable.Date_Meeting,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE Stb_MeetingAgenda AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldID IS NULL THEN XMLData.ID
							    ELSE XMLData.OldID
							END AS OldID,
							XMLData.ID,
							XMLData.Years,
							XMLData.Months,
							XMLData.Days,
							XMLData.No,
							XMLData.Meeting_Agenda,
							XMLData.Customer,
							XMLData.Size,
							XMLData.RespPlant,
							XMLData.RestTeam,
							XMLData.CompleteDate,
							XMLData.Status,
							XMLData.Date_Meeting,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldID INT,
										ID int,
										Years int,
										Months Int,
										Days int,
										No int,
										Meeting_Agenda nvarchar(200),
										Customer nvarchar(100),
										Size nvarchar(50),
										RespPlant nvarchar(50),
										RestTeam nvarchar(50),
										CompleteDate date,
										Status nvarchar(20),
										Date_Meeting date,
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
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
									XMLData.OldID,
									XMLData.ID,
									XMLData.Years,
									XMLData.Months,
									XMLData.Days,
									XMLData.No,
									XMLData.Meeting_Agenda,
									XMLData.Customer,
									XMLData.Size,
									XMLData.RespPlant,
									XMLData.RestTeam,
									XMLData.CompleteDate,
									XMLData.Status,
									XMLData.Date_Meeting,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldID int,
											ID int,
											Years int,
											Months int,
											Days int,
											No int,
											Meeting_Agenda nvarchar(200),
											Customer nvarchar(100),
											Size nvarchar(50),
											RespPlant nvarchar(50),
											RestTeam nvarchar(50),
											CompleteDate date,
											Status nvarchar(20),
											Date_Meeting date,
											Attribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											Attribute4 nvarchar(200),
											Attribute5 nvarchar(200),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldID IS NULL THEN XMLData.ID
										ELSE XMLData.OldID
									END AS OldID,
									XMLData.ID,
									XMLData.Years,
									XMLData.Months,
									XMLData.Days,
									XMLData.No,
									XMLData.Meeting_Agenda,
									XMLData.Customer,
									XMLData.Size,
									XMLData.RespPlant,
									XMLData.RestTeam,
									XMLData.CompleteDate,
									XMLData.Status,
									XMLData.Date_Meeting,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
												OldID int,
												ID int,
												Years int,
												Months int,
												Days int,
												No int,
												Meeting_Agenda nvarchar(200),
												Customer nvarchar(100),
												Size nvarchar(50),
												RespPlant nvarchar(50),
												RestTeam nvarchar(50),
												CompleteDate date,
												Status nvarchar(20),
												Date_Meeting date,
												Attribute1 nvarchar(200),
												Attribute2 nvarchar(200),
												Attribute3 nvarchar(200),
												Attribute4 nvarchar(200),
												Attribute5 nvarchar(200),
												CreateDateTime DATETIME,
												CreateUserID VARCHAR(20),
												ChangeDateTime DATETIME,
												ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldID IS NULL THEN XMLData.ID
										ELSE XMLData.OldID
									END AS OldID,
									XMLData.ID,
									XMLData.Years,
									XMLData.Months,
									XMLData.Days,
									XMLData.No,
									XMLData.Meeting_Agenda,
									XMLData.Customer,
									XMLData.Size,
									XMLData.RespPlant,
									XMLData.RestTeam,
									XMLData.CompleteDate,
									XMLData.Status,
									XMLData.Date_Meeting,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldID int,
												ID int,
												Years int,
												Months int,
												Days int,
												No int,
												Meeting_Agenda nvarchar(200),
												Customer nvarchar(100),
												Size nvarchar(50),
												RespPlant nvarchar(50),
												RestTeam nvarchar(50),
												CompleteDate date,
												Status nvarchar(20),
												Date_Meeting date,
												Attribute1 nvarchar(200),
												Attribute2 nvarchar(200),
												Attribute3 nvarchar(200),
												Attribute4 nvarchar(200),
												Attribute5 nvarchar(200),
												CreateDateTime DATETIME,
												CreateUserID VARCHAR(20),
												ChangeDateTime DATETIME,
												ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldID,
								 @ID,
								 @Years,
								 @Months,
								 @Days,
								 @No,
								 @Meeting_Agenda,
								 @Customer,
								 @Size,
								 @RespPlant,
								 @RestTeam,
								 @CompleteDate,
								 @Status,
								 @Date_Meeting,
								 @Attribute1,
								 @Attribute2,
								 @Attribute3,
								 @Attribute4,
							     @Attribute5,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

     --               IF EXISTS (SELECT 1 FROM Stb_MeetingAgenda WHERE Date_Meeting = @Date_Meeting and no =@no) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @no)
					--END

     --               IF @IsAutoKey = 1 BEGIN
					--	EXEC SmartFramework.dbo.usp_DoCreateSerial 'Stb_MeetingAgenda', @No OUTPUT
     --               END

                    INSERT INTO Stb_MeetingAgenda
						(
						    Years,
						    Months,
						    Days,
						    No,
							Meeting_Agenda,
							Customer,
							Size,
							RespPlant,
							RestTeam,
							CompleteDate,
							Status,
							Date_Meeting,
							Attribute1,
							Attribute2,
							Attribute3,
							Attribute4,
							Attribute5,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @Years,
						    @Months,
						    @Days,
						    @No,
							@Meeting_Agenda,
							@Customer,
							@Size,
							@RespPlant,
							@RestTeam,
							@CompleteDate,
							@Status,
							@Date_Meeting,
							@Attribute1,
							@Attribute2,
							@Attribute3,
							@Attribute4,
							@Attribute5,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE Stb_MeetingAgenda
						SET
						    Years =   CASE
						                WHEN @Years IS NOT NULL THEN @Years
						                ELSE Years
						            END,
						    Months =   CASE
						                WHEN @Months IS NOT NULL THEN @Months
						                ELSE Months
						            END,
						    Days =   CASE
						                WHEN @Days IS NOT NULL THEN @Days
						                ELSE Days
						            END,
						    No =   CASE
						                WHEN @No IS NOT NULL THEN @No
						                ELSE No
						            END,
							Meeting_Agenda =   CASE
						                WHEN @Meeting_Agenda IS NOT NULL THEN @Meeting_Agenda
						                ELSE Meeting_Agenda
						            END,
					        Customer =   CASE
						                WHEN @Customer IS NOT NULL THEN @Customer
						                ELSE Customer
						            END,
							Size =   CASE
						                WHEN @Size IS NOT NULL THEN @Size
						                ELSE Size
						            END,
							RespPlant =   CASE
						                WHEN @RespPlant IS NOT NULL THEN @RespPlant
						                ELSE RespPlant
						            END,
							RestTeam =   CASE
						                WHEN @RestTeam IS NOT NULL THEN @RestTeam
						                ELSE RestTeam
						            END,
							CompleteDate =   CASE
						                WHEN @CompleteDate IS NOT NULL THEN @CompleteDate
						                ELSE CompleteDate
						            END,
							Status =   CASE
						                WHEN @Status IS NOT NULL THEN @Status
						                ELSE Status
						            END,
							Date_Meeting = CASE	
										   WHEN @Date_Meeting IS NOT NULL THEN @Date_Meeting
										   ELSE Date_Meeting
									END,
							Attribute1 =   CASE
						                WHEN @Attribute1 IS NOT NULL THEN @Attribute1
						                ELSE Attribute1
						            END,
							Attribute2 =   CASE
						                WHEN @Attribute2 IS NOT NULL THEN @Attribute2
						                ELSE Attribute2
						            END,
							Attribute3 =   CASE
						                WHEN @Attribute3 IS NOT NULL THEN @Attribute3
						                ELSE Attribute3
						            END,
						   Attribute4 =   CASE
						                WHEN @Attribute4 IS NOT NULL THEN @Attribute4
						                ELSE Attribute4
						            END,
						   Attribute5 =   CASE
						                WHEN @Attribute5 IS NOT NULL THEN @Attribute5
						                ELSE Attribute5
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
						    ID = @OldID
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM Stb_MeetingAgenda
						WHERE
						    ID = @ID
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

