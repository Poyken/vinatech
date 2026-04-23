
CREATE PROCEDURE [dbo].[usp_Stationey_iud]
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
	DECLARE @OldStationeryCode VARCHAR(20)
	DECLARE @StationeryCode VARCHAR(50)
	DECLARE @StationeryName NVARCHAR(200)
	DECLARE @BasicUnit nvarchar(20)
	DECLARE @TypeStationery nvarchar(50)
	DECLARE @Description NVARCHAR(500)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(50)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_StationeryInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_StationeryInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldStationeryCode IS NULL THEN XMLData.StationeryCode
							    ELSE XMLData.OldStationeryCode
							END AS OldStationeryCode,
							XMLData.StationeryCode,
							XMLData.StationeryName,
							XMLData.BasicUnit,
							XMLData.TypeStationery,
							XMLData.Description,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.WorkCenterCode
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldStationeryCode VARCHAR(50),
										StationeryCode VARCHAR(50),
										StationeryName NVARCHAR(200),
										BasicUnit NVARCHAR(20),
										TypeStationery NVARCHAR(50),
										Description NVARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										WorkCenterCode VARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.StationeryCode = SourceTable.StationeryCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					StationeryCode = SourceTable.StationeryCode,
					StationeryName = SourceTable.StationeryName,
					BasicUnit = SourceTable.BasicUnit ,
					TypeStationery = SourceTable.TypeStationery,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					WorkCenterCode =SourceTable.WorkCenterCode
					
			WHEN NOT MATCHED THEN
				INSERT
					(
						StationeryCode,
						StationeryName,
						BasicUnit,
						TypeStationery,
						Description,
						CreateDateTime,
						CreateUserID,
						ChangeUserID,
						WorkCenterCode
						
					)
				VALUES
					(
							SourceTable.StationeryCode,
							SourceTable.StationeryName,
							SourceTable.BasicUnit,
							SourceTable.TypeStationery,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID,
							SourceTable.WorkCenterCode
							
					);

				
			-- Process Update Table
            MERGE STB_StationeryInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldStationeryCode IS NULL THEN XMLData.StationeryCode
							    ELSE XMLData.OldStationeryCode
							END AS OldStationeryCode,
							XMLData.StationeryCode,
							XMLData.StationeryName,
							XMLData.BasicUnit,
							XMLData.TypeStationery,
							XMLData.Description,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.WorkCenterCode
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldStationeryCode VARCHAR(50),
										StationeryCode VARCHAR(50),
										StationeryName NVARCHAR(200),
										BasicUnit NVARCHAR(20),
										TypeStationery NVARCHAR(50),
										Description NVARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										WorkCenterCode VARCHAR(50)
										
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.StationeryCode = SourceTable.OldStationeryCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					StationeryCode = SourceTable.StationeryCode,
					StationeryName = SourceTable.StationeryName,
					BasicUnit = SourceTable.BasicUnit ,
					TypeStationery = SourceTable.TypeStationery,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					WorkCenterCode =SourceTable.WorkCenterCode
					
			WHEN NOT MATCHED THEN
				INSERT
					(
						StationeryCode,
						StationeryName,
						BasicUnit,
						TypeStationery,
						Description,
						CreateDateTime,
						CreateUserID,
						ChangeUserID,
						WorkCenterCode
						
					)
				VALUES
					(
							SourceTable.StationeryCode,
							SourceTable.StationeryName,
							SourceTable.BasicUnit,
							SourceTable.TypeStationery,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID,
							SourceTable.WorkCenterCode
							
					);
			

			-- Process Delete Table
            MERGE STB_StationeryInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldStationeryCode IS NULL THEN XMLData.StationeryCode
							    ELSE XMLData.OldStationeryCode
							END AS OldStationeryCode,
							XMLData.StationeryCode,
							XMLData.StationeryName,
							XMLData.BasicUnit,
							XMLData.TypeStationery,
							XMLData.Description,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.WorkCenterCode
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldStationeryCode VARCHAR(50),
										StationeryCode VARCHAR(50),
										StationeryName NVARCHAR(200),
										BasicUnit NVARCHAR(20),
										TypeStationery NVARCHAR(50),
										Description NVARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										WorkCenterCode VARCHAR(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.StationeryCode = SourceTable.StationeryCode
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
									XMLData.OldStationeryCode,
									XMLData.StationeryCode,
									XMLData.StationeryName,
									XMLData.BasicUnit,
									XMLData.TypeStationery,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.WorkCenterCode
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldStationeryCode VARCHAR(50),
											 StationeryCode VARCHAR(50),
											 StationeryName NVARCHAR(200),
											 BasicUnit NVARCHAR(20),
											 TypeStationery NVARCHAR(50),
											 Description NVARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WorkCenterCode VARCHAR(50)
											
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldStationeryCode IS NULL THEN XMLData.StationeryCode
										ELSE XMLData.OldStationeryCode
									END AS OldStationeryCode,
									XMLData.StationeryCode,
									XMLData.StationeryName,
									XMLData.BasicUnit,
									XMLData.TypeStationery ,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.WorkCenterCode

									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldStationeryCode VARCHAR(50),
											 StationeryCode VARCHAR(50),
											 StationeryName NVARCHAR(200),
											 BasicUnit NVARCHAR(20),
											 TypeStationery NVARCHAR(50),
											 Description NVARCHAR(500), 
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WorkCenterCode VARCHAR(50)
											 
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldStationeryCode IS NULL THEN XMLData.StationeryCode
										ELSE XMLData.OldStationeryCode
									END AS OldStationeryCode,
									XMLData.StationeryCode,
									XMLData.StationeryName,
									XMLData.BasicUnit,
									XMLData.TypeStationery,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.WorkCenterCode
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldStationeryCode VARCHAR(50),
											 StationeryCode VARCHAR(50),
											 StationeryName NVARCHAR(200),
											 BasicUnit NVARCHAR(20),
											 TypeStationery NVARCHAR(50),
											 Description NVARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 WorkCenterCode VARCHAR(50)
											
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldStationeryCode,
								 @StationeryCode,
								 @StationeryName,
								 @BasicUnit,
								 @TypeStationery,
								 @Description,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @WorkCenterCode

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_StationeryInfo WHERE StationeryCode = @StationeryCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @StationeryCode)
					END

                      IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StationeryInfo', @StationeryCode OUTPUT
                    END


                    INSERT INTO STB_StationeryInfo
						(
						    StationeryCode,
						    StationeryName,
							BasicUnit,
							TypeStationery,
						    Description,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							WorkCenterCode
							
						)
						VALUES
						(
						    @StationeryCode,
						    @StationeryName,
							@BasicUnit,
							@TypeStationery,
						    @Description,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@WorkCenterCode
						)

				END
				ELSE 
				IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
							
                    UPDATE STB_StationeryInfo
						SET
						    StationeryCode =   CASE
						                WHEN @StationeryCode IS NOT NULL THEN @StationeryCode
						                ELSE StationeryCode
						            END,
						    StationeryName =   CASE
						                WHEN @StationeryName IS NOT NULL THEN @StationeryName
						                ELSE StationeryName
						            END,
							BasicUnit = CASE
						                WHEN @BasicUnit IS NOT NULL THEN @BasicUnit
						                ELSE BasicUnit
						            END,    
							TypeStationery = CASE
						                WHEN @TypeStationery IS NOT NULL THEN @TypeStationery
						                ELSE TypeStationery
						            END,
						    Description =   CASE
						                WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
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
						    --ChangeUserID =   @pProcessUserID
							WorkCenterCode=CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END
						WHERE
						    StationeryCode = @OldStationeryCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
                    DELETE FROM STB_StationeryInfo
					WHERE
						   StationeryCode = @StationeryCode
                END
					set @UpdateTableName=@UpdateTableName;
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

