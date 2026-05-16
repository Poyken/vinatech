
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-09
-- Browsable : true
-- Group : 공통
-- Description:	공정정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_RouteInfo_iud]
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
  DECLARE @OldRouteCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @RouteType VARCHAR(20)
  DECLARE @RouteName NVARCHAR(50)
  DECLARE @IsExternalRoute BIT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsInterfaceRoute BIT
  Declare @IsRequireMachine BIT

  -- 공정표준 Takt Time 컬럼 추가
  Declare @StandardTaktTime NUMERIC(20,5)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_RouteInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_RouteInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							RouteCode,
							CompanyCode,
							WorkCenterCode,
							ISNULL(RouteType,'') AS RouteType,
							RouteName,
							IsExternalRoute,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsInterfaceRoute,
							IsRequireMachine, 
							StandardTaktTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										RouteCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										RouteType VARCHAR(20),
										RouteName NVARCHAR(50),
										IsExternalRoute BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsInterfaceRoute BIT,
										IsRequireMachine BIT,
										StandardTaktTime NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.RouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RouteCode = SourceTable.RouteCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					RouteType = SourceTable.RouteType,
					RouteName = SourceTable.RouteName,
					--IsExternalRoute = SourceTable.IsExternalRoute,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
				    IsInterfaceRoute = SourceTable.IsInterfaceRoute, 
					IsRequireMachine = SourceTable.IsRequireMachine,
					StandardTaktTime = SourceTable.StandardTaktTime
			WHEN NOT MATCHED THEN
				INSERT
					(
						RouteCode,
						CompanyCode,
						WorkCenterCode,
						RouteType,
						RouteName,
						--IsExternalRoute,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsInterfaceRoute,
						IsRequireMachine,
						StandardTaktTime
					)
				VALUES
					(
							SourceTable.RouteCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.RouteType,
							SourceTable.RouteName,
							--SourceTable.IsExternalRoute,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsInterfaceRoute,
							SourceTable.IsRequireMachine,
							SourceTable.StandardTaktTime
					);


			-- Process Update Table
            MERGE STB_RouteInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							RouteCode,
							CompanyCode,
							WorkCenterCode,
							ISNULL(RouteType,'') AS RouteType,
							RouteName,
							IsExternalRoute,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsInterfaceRoute,
							IsRequireMachine,
							StandardTaktTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										RouteCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										RouteType VARCHAR(20),
										RouteName NVARCHAR(50),
										IsExternalRoute BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsInterfaceRoute BIT,
										IsRequireMachine BIT,
										StandardTaktTime NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.OldRouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RouteCode = SourceTable.RouteCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					RouteType = SourceTable.RouteType,
					RouteName = SourceTable.RouteName,
					--IsExternalRoute = SourceTable.IsExternalRoute,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					IsInterfaceRoute = SourceTable.IsInterfaceRoute,
					IsRequireMachine = SourceTable.IsRequireMachine,
					StandardTaktTime = SourceTable.StandardTaktTime
			WHEN NOT MATCHED THEN
				INSERT
					(
						RouteCode,
						CompanyCode,
						WorkCenterCode,
						RouteType,
						RouteName,
						--IsExternalRoute,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsInterfaceRoute,
						IsRequireMachine,
						StandardTaktTime
					)
				VALUES
					(
							SourceTable.RouteCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.RouteType,
							SourceTable.RouteName,
							--SourceTable.IsExternalRoute,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsInterfaceRoute,
							SourceTable.IsRequireMachine,
							SourceTable.StandardTaktTime
					);


			-- Process Delete Table
            MERGE STB_RouteInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							RouteCode,
							CompanyCode,
							WorkCenterCode,
							RouteType,
							RouteName,
							IsExternalRoute,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsInterfaceRoute,
							IsRequireMachine,
							StandardTaktTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										RouteCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										RouteType VARCHAR(20),
										RouteName NVARCHAR(50),
										IsExternalRoute BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsInterfaceRoute BIT,
										IsRequireMachine BIT,
										StandardTaktTime NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.RouteCode
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
									OldRouteCode,
									RouteCode,
									CompanyCode,
									WorkCenterCode,
									RouteType,
									RouteName,
									IsExternalRoute,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsInterfaceRoute,
									IsRequireMachine,
									StandardTaktTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRouteCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 RouteType VARCHAR(20),
											 RouteName NVARCHAR(50),
											 IsExternalRoute BIT,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsInterfaceRoute BIT,
											 IsRequireMachine BIT,
											 StandardTaktTime NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									RouteCode,
									CompanyCode,
									WorkCenterCode,
									RouteType,
									RouteName,
									IsExternalRoute,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsInterfaceRoute,
									IsRequireMachine,
									StandardTaktTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRouteCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 RouteType VARCHAR(20),
											 RouteName NVARCHAR(50),
											 IsExternalRoute BIT,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsInterfaceRoute BIT,
											 IsRequireMachine BIT,
											 StandardTaktTime NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									RouteCode,
									CompanyCode,
									WorkCenterCode,
									RouteType,
									RouteName,
									IsExternalRoute,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsInterfaceRoute,
									IsRequireMachine,
									StandardTaktTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRouteCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 RouteType VARCHAR(20),
											 RouteName NVARCHAR(50),
											 IsExternalRoute BIT,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsInterfaceRoute BIT,
											 IsRequireMachine BIT,
											 StandardTaktTime NUMERIC(20,5)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRouteCode,
								 @RouteCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @RouteType,
								 @RouteName,
								 @IsExternalRoute,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsInterfaceRoute,
								 @IsRequireMachine,
								 @StandardTaktTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_RouteInfo WHERE RouteCode = @RouteCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RouteCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RouteInfo', @RouteCode OUTPUT
                    END

                    INSERT INTO STB_RouteInfo
						(
						    RouteCode,
						    CompanyCode,
						    WorkCenterCode,
						    RouteType,
						    RouteName,
						    --IsExternalRoute,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsInterfaceRoute,
							IsRequireMachine,
							StandardTaktTime
						)
						VALUES
						(
						    @RouteCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @RouteType,
						    @RouteName,
						    --@IsExternalRoute,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsInterfaceRoute,
							@IsRequireMachine,
							@StandardTaktTime
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_RouteInfo
						SET
						    RouteCode =   CASE
						                WHEN @RouteCode IS NOT NULL THEN @RouteCode
						                ELSE RouteCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    RouteType =   CASE
						                WHEN @RouteType IS NOT NULL THEN @RouteType
						                ELSE RouteType
						            END,
						    RouteName =   CASE
						                WHEN @RouteName IS NOT NULL THEN @RouteName
						                ELSE RouteName
						            END,
						    --IsExternalRoute =   CASE
						    --            WHEN @IsExternalRoute IS NOT NULL THEN @IsExternalRoute
						    --            ELSE IsExternalRoute
						    --        END,
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
						    ChangeUserID = @pProcessUserID,
							IsInterfaceRoute = @IsInterfaceRoute,
							IsRequireMachine = @IsRequireMachine,
							StandardTaktTime = CASE
						                WHEN @StandardTaktTime IS NOT NULL THEN @StandardTaktTime
						                ELSE StandardTaktTime
						            END
						WHERE
						    RouteCode = @OldRouteCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_RouteInfo
						WHERE
						    RouteCode = @RouteCode
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

