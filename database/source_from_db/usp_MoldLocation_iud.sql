-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-01
-- Browsable : true
-- Group : 금형관리
-- Description:	금형 보관위치 정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldLocation_iud]
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
  DECLARE @OldMoldLocationCode VARCHAR(20)
  DECLARE @MoldLocationCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LocationName NVARCHAR(100)
  DECLARE @LocationDesc1 NVARCHAR(200)
  DECLARE @LocationDesc2 NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldLocation',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldLocationCode IS NULL THEN XMLData.MoldLocationCode
							    ELSE XMLData.OldMoldLocationCode
							END AS OldMoldLocationCode,
							XMLData.MoldLocationCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.LocationName,
							XMLData.LocationDesc1,
							XMLData.LocationDesc2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldLocationCode VARCHAR(20),
										MoldLocationCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LocationName NVARCHAR(100),
										LocationDesc1 NVARCHAR(200),
										LocationDesc2 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldLocationCode = SourceTable.MoldLocationCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldLocationCode = SourceTable.MoldLocationCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					LocationName = SourceTable.LocationName,
					LocationDesc1 = SourceTable.LocationDesc1,
					LocationDesc2 = SourceTable.LocationDesc2,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldLocationCode,
						CompanyCode,
						WorkCenterCode,
						LocationName,
						LocationDesc1,
						LocationDesc2,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldLocationCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LocationName,
							SourceTable.LocationDesc1,
							SourceTable.LocationDesc2,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldLocationCode IS NULL THEN XMLData.MoldLocationCode
							    ELSE XMLData.OldMoldLocationCode
							END AS OldMoldLocationCode,
							XMLData.MoldLocationCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.LocationName,
							XMLData.LocationDesc1,
							XMLData.LocationDesc2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldLocationCode VARCHAR(20),
										MoldLocationCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LocationName NVARCHAR(100),
										LocationDesc1 NVARCHAR(200),
										LocationDesc2 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldLocationCode = SourceTable.OldMoldLocationCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldLocationCode = SourceTable.MoldLocationCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					LocationName = SourceTable.LocationName,
					LocationDesc1 = SourceTable.LocationDesc1,
					LocationDesc2 = SourceTable.LocationDesc2,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldLocationCode,
						CompanyCode,
						WorkCenterCode,
						LocationName,
						LocationDesc1,
						LocationDesc2,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldLocationCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LocationName,
							SourceTable.LocationDesc1,
							SourceTable.LocationDesc2,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldLocationCode IS NULL THEN XMLData.MoldLocationCode
							    ELSE XMLData.OldMoldLocationCode
							END AS OldMoldLocationCode,
							XMLData.MoldLocationCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.LocationName,
							XMLData.LocationDesc1,
							XMLData.LocationDesc2,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldLocationCode VARCHAR(20),
										MoldLocationCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LocationName NVARCHAR(100),
										LocationDesc1 NVARCHAR(200),
										LocationDesc2 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldLocationCode = SourceTable.MoldLocationCode
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
									XMLData.OldMoldLocationCode,
									XMLData.MoldLocationCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.LocationName,
									XMLData.LocationDesc1,
									XMLData.LocationDesc2,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldLocationCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LocationName NVARCHAR(100),
											 LocationDesc1 NVARCHAR(200),
											 LocationDesc2 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldLocationCode IS NULL THEN XMLData.MoldLocationCode
										ELSE XMLData.OldMoldLocationCode
									END AS OldMoldLocationCode,
									XMLData.MoldLocationCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.LocationName,
									XMLData.LocationDesc1,
									XMLData.LocationDesc2,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldLocationCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LocationName NVARCHAR(100),
											 LocationDesc1 NVARCHAR(200),
											 LocationDesc2 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldLocationCode IS NULL THEN XMLData.MoldLocationCode
										ELSE XMLData.OldMoldLocationCode
									END AS OldMoldLocationCode,
									XMLData.MoldLocationCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.LocationName,
									XMLData.LocationDesc1,
									XMLData.LocationDesc2,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldLocationCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LocationName NVARCHAR(100),
											 LocationDesc1 NVARCHAR(200),
											 LocationDesc2 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldLocationCode,
								 @MoldLocationCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LocationName,
								 @LocationDesc1,
								 @LocationDesc2,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldLocation WHERE MoldLocationCode = @MoldLocationCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldLocationCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldLocation',
																	@MoldLocationCode OUTPUT
                    END

                    INSERT INTO STB_MoldLocation
						(
						    MoldLocationCode,
						    CompanyCode,
						    WorkCenterCode,
						    LocationName,
						    LocationDesc1,
						    LocationDesc2,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldLocationCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LocationName,
						    @LocationDesc1,
						    @LocationDesc2,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldLocation
						SET
						    MoldLocationCode =   CASE
						                WHEN @MoldLocationCode IS NOT NULL THEN @MoldLocationCode
						                ELSE MoldLocationCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    LocationName =   CASE
						                WHEN @LocationName IS NOT NULL THEN @LocationName
						                ELSE LocationName
						            END,
						    LocationDesc1 =   CASE
						                WHEN @LocationDesc1 IS NOT NULL THEN @LocationDesc1
						                ELSE LocationDesc1
						            END,
						    LocationDesc2 =   CASE
						                WHEN @LocationDesc2 IS NOT NULL THEN @LocationDesc2
						                ELSE LocationDesc2
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
						    MoldLocationCode = @OldMoldLocationCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldLocation
						WHERE
						    MoldLocationCode = @MoldLocationCode
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
