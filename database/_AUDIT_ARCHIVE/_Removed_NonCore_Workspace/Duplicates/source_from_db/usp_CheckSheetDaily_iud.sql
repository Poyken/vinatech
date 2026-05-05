
CREATE PROCEDURE [dbo].[usp_CheckSheetDaily_iud]
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
	  DECLARE @OldNo VARCHAR(50)
	  DECLARE @ID VARCHAR(20)
	  DECLARE @No nvarchar(50)
	  DECLARE @PeopleTest nvarchar(50)
	  DECLARE @DateTest date
	  DECLARE @Shifts nvarchar(50)
	  DECLARE @Cellline nvarchar(50)
	  DECLARE @Model nvarchar(100)
	  DECLARE @Part nvarchar(100)
	  DECLARE @TypeCheck nvarchar(100)
	  DECLARE @CreateDateTime DATETIME
	  DECLARE @CreateUserID VARCHAR(20)
	  DECLARE @ChangeDateTime DATETIME
	  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'stb_CheckSheetDaily',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE stb_CheckSheetDaily AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldNo IS NULL THEN XMLData.No
							    ELSE XMLData.OldNo
							END AS OldNo,
							--XMLData.ID,
							XMLData.No,
							XMLData.PeopleTest,
							XMLData.DateTest,
							XMLData.Shifts,
							XMLData.Cellline,
							XMLData.Model,
							XMLData.Part,
							XMLData.TypeCheck,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID as ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldNo  nvarchar(50),
										--ID int,
										No nvarchar(50),
										PeopleTest nvarchar(50),
										DateTest date,
										Shifts nvarchar(50),
										Cellline nvarchar(50),
										Model nvarchar(100),
										Part nvarchar(100),
										TypeCheck nvarchar(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.No = SourceTable.No
				)

			WHEN MATCHED THEN
				UPDATE SET
				--	ID = SourceTable.ID,
					No = SourceTable.No,
					PeopleTest = SourceTable.PeopleTest,
					DateTest = SourceTable.DateTest,
					Shifts = SourceTable.Shifts,
					Cellline = SourceTable.Cellline,
					Model = SourceTable.Model,
					Part = SourceTable.Part,
					TypeCheck = SourceTable.TypeCheck,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN
				INSERT
					(
						No,
						PeopleTest,
						DateTest,
						Shifts,
						Cellline,
						Model,
						Part,
						TypeCheck,
						CreateDateTime,
						CreateUserID,
						ChangeUserID
						
					)
				VALUES
					(
							SourceTable.No,
							SourceTable.PeopleTest,
							SourceTable.DateTest,
							SourceTable.Shifts,
							SourceTable.Cellline,
							SourceTable.Model,
							SourceTable.Part,
							SourceTable.TypeCheck,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID
							
					);


			-- Process Update Table
            MERGE stb_CheckSheetDaily AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldNo IS NULL THEN XMLData.No
							    ELSE XMLData.OldNo
							END AS OldNo,
							--XMLData.ID,
							XMLData.No,
							XMLData.PeopleTest,
							XMLData.DateTest,
							XMLData.Shifts,
							XMLData.Cellline,
							XMLData.Model,
							XMLData.Part,
							XMLData.TypeCheck,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID as ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldNo nvarchar(50),
										--ID int,
										No nvarchar(50),
										PeopleTest nvarchar(50),
										DateTest date,
										Shifts nvarchar(50),
										Cellline nvarchar(50),
										Model nvarchar(100),
										Part nvarchar(100),
										TypeCheck nvarchar(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.No = SourceTable.OldNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					No = SourceTable.No,
					PeopleTest = SourceTable.PeopleTest,
					DateTest = SourceTable.DateTest,
					Shifts = SourceTable.Shifts,
					Cellline = SourceTable.Cellline,
					Model = SourceTable.Model,
					Part = SourceTable.Part,
					TypeCheck = SourceTable.TypeCheck,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN
				INSERT
					(
						No,
						PeopleTest,
						DateTest,
						Shifts,
						Cellline,
						Model,
						Part,
						TypeCheck,
						CreateDateTime,
						CreateUserID,
						ChangeUserID
						
					)
				VALUES
					(
							SourceTable.No,
							SourceTable.PeopleTest,
							SourceTable.DateTest,
							SourceTable.Shifts,
							SourceTable.Cellline,
							SourceTable.Model,
							SourceTable.Part,
							SourceTable.TypeCheck,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID
							
					);


			-- Process Delete Table
            MERGE stb_CheckSheetDaily AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldNo IS NULL THEN XMLData.No
							    ELSE XMLData.OldNo
							END AS OldNo,
						--	XMLData.ID,
							XMLData.No,
							XMLData.PeopleTest,
							XMLData.DateTest,
							XMLData.Shifts,
							XMLData.Cellline,
							XMLData.Model,
							XMLData.Part,
							XMLData.TypeCheck,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID as ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldNo nvarchar(50),
										--ID int,
										No nvarchar(50),
										PeopleTest nvarchar(50),
										DateTest date,
										Shifts nvarchar(50),
										Cellline nvarchar(50),
										Model nvarchar(100),
										Part nvarchar(100),
										TypeCheck nvarchar(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.No = SourceTable.No
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
									XMLData.OldNo,
								--	XMLData.ID,
									XMLData.No,
									XMLData.PeopleTest,
									XMLData.DateTest,
									XMLData.Shifts,
									XMLData.Cellline,
									XMLData.Model,
									XMLData.Part,
									XMLData.TypeCheck,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											OldNo nvarchar(50),
										--	ID int,
											No nvarchar(50),
											PeopleTest nvarchar(50),
											DateTest date,
											Shifts nvarchar(50),
											Cellline nvarchar(50),
											Model nvarchar(100),
											Part nvarchar(100),
											TypeCheck nvarchar(100),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldNo IS NULL THEN XMLData.No
										ELSE XMLData.OldNo
									END AS OldNo,
									--XMLData.ID,
									XMLData.No,
									XMLData.PeopleTest,
									XMLData.DateTest,
									XMLData.Shifts,
									XMLData.Cellline,
									XMLData.Model,
									XMLData.Part,
									XMLData.TypeCheck,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldNo nvarchar(50),
										--	ID int,
											No nvarchar(50),
											PeopleTest nvarchar(50),
											DateTest date,
											Shifts nvarchar(50),
											Cellline nvarchar(50),
											Model nvarchar(100),
											Part nvarchar(100),
											TypeCheck nvarchar(100),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldNo IS NULL THEN XMLData.No
										ELSE XMLData.OldNo
									END AS OldNo,
								--	XMLData.ID,
										XMLData.No,
									XMLData.PeopleTest,
									XMLData.DateTest,
									XMLData.Shifts,
									XMLData.Cellline,
									XMLData.Model,
									XMLData.Part,
									XMLData.TypeCheck,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldNo nvarchar(50),
										--	ID int,
											No nvarchar(50),
											PeopleTest nvarchar(50),
											DateTest date,
											Shifts nvarchar(50),
											Cellline nvarchar(50),
											Model nvarchar(100),
											Part nvarchar(100),
											TypeCheck nvarchar(100),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldNo,
								-- @ID,
								 @No,
								 @PeopleTest,
								 @DateTest,
								 @Shifts,
								 @Cellline,
								 @Model,
								 @Part,
								 @TypeCheck,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM stb_CheckSheetDaily WHERE No = @No) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @No)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'stb_CheckSheetDaily', @No OUTPUT
                    END


                    INSERT INTO stb_CheckSheetDaily
						(
						    No,
						    PeopleTest,
						    DateTest,
						    Shifts,
						    Cellline,
							Model,
						    Part,
						    TypeCheck,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @No,
						    @PeopleTest,
						    --@DateTest,
							Dateadd(day,1,@DateTest) ,
						    @Shifts,
						    @Cellline,
							@Model,
						    @Part,
						    @TypeCheck,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
							
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
							
                    UPDATE stb_CheckSheetDaily
						SET
						    PeopleTest =   CASE
						                WHEN @PeopleTest IS NOT NULL THEN @PeopleTest
						                ELSE PeopleTest
						            END,
						    --DateTest =   CASE
						    --            WHEN @DateTest IS NOT NULL THEN @DateTest
						    --            ELSE DateTest
						    --        END,
						    DateTest =   CASE
						                WHEN @DateTest IS NOT NULL THEN Dateadd(day,1,@DateTest) 
						                ELSE DateTest
						            END,
							Shifts =   CASE
						                WHEN @Shifts IS NOT NULL THEN @Shifts
						                ELSE Shifts
						            END,
						    Cellline =   CASE
						                WHEN @Cellline IS NOT NULL THEN @Cellline
						                ELSE Cellline
						            END,
						    Model =   CASE
						                WHEN @Model IS NOT NULL THEN @Model
						                ELSE Model
						            END,
						    Part =   CASE
						                WHEN @Part IS NOT NULL THEN @Part
						                ELSE Part
						            END,
						    TypeCheck =   CASE
						                WHEN @TypeCheck IS NOT NULL THEN @TypeCheck
						                ELSE TypeCheck
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID =   CASE
						                WHEN @pProcessUserID IS NOT NULL THEN @pProcessUserID
						                ELSE ChangeUserID
						            END
						WHERE
						    No = @OldNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
							
                    DELETE FROM stb_CheckSheetDaily
					WHERE
						   No = @No
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


