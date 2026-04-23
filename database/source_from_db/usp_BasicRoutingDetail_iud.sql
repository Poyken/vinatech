
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-30
-- Browsable : true
-- Group : 기준정보
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicRoutingDetail_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
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
	-- 사업장코드, 작업장코드 추가 2019.09.27 By Jackaroe
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode

    -- Declare Columns Variable
  DECLARE @OldBasicRoutingDetailNo VARCHAR(20)
  DECLARE @BasicRoutingDetailNo VARCHAR(20)
  DECLARE @BasicRoutingCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @RouteIndex INT
  DECLARE @IsInputRoute BIT
  DECLARE @IsOutputRoute BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsUse BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BasicRoutingDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BasicRoutingDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingDetailNo IS NULL THEN BasicRoutingDetailNo
							    ELSE OldBasicRoutingDetailNo
							END AS OldBasicRoutingDetailNo,
							BasicRoutingDetailNo,
							BasicRoutingCode,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBasicRoutingDetailNo VARCHAR(20),
										BasicRoutingDetailNo VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingDetailNo = SourceTable.BasicRoutingDetailNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					BasicRoutingDetailNo = ISNULL(SourceTable.BasicRoutingDetailNo,TargetTable.BasicRoutingDetailNo),
					BasicRoutingCode = ISNULL(SourceTable.BasicRoutingCode,TargetTable.BasicRoutingCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BasicRoutingDetailNo,
						BasicRoutingCode,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BasicRoutingDetailNo,
							SourceTable.BasicRoutingCode,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_BasicRoutingDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingDetailNo IS NULL THEN BasicRoutingDetailNo
							    ELSE OldBasicRoutingDetailNo
							END AS OldBasicRoutingDetailNo,
							BasicRoutingDetailNo,
							BasicRoutingCode,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBasicRoutingDetailNo VARCHAR(20),
										BasicRoutingDetailNo VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingDetailNo = SourceTable.OldBasicRoutingDetailNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					BasicRoutingDetailNo = ISNULL(SourceTable.BasicRoutingDetailNo,TargetTable.BasicRoutingDetailNo),
					BasicRoutingCode = ISNULL(SourceTable.BasicRoutingCode,TargetTable.BasicRoutingCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BasicRoutingDetailNo,
						BasicRoutingCode,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BasicRoutingDetailNo,
							SourceTable.BasicRoutingCode,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_BasicRoutingDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingDetailNo IS NULL THEN BasicRoutingDetailNo
							    ELSE OldBasicRoutingDetailNo
							END AS OldBasicRoutingDetailNo,
							BasicRoutingDetailNo,
							BasicRoutingCode,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBasicRoutingDetailNo VARCHAR(20),
										BasicRoutingDetailNo VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingDetailNo = SourceTable.BasicRoutingDetailNo
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
									OldBasicRoutingDetailNo,
									BasicRoutingDetailNo,
									BasicRoutingCode,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldBasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldBasicRoutingDetailNo IS NULL THEN BasicRoutingDetailNo
										ELSE OldBasicRoutingDetailNo
									END AS OldBasicRoutingDetailNo,
									BasicRoutingDetailNo,
									BasicRoutingCode,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldBasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldBasicRoutingDetailNo IS NULL THEN BasicRoutingDetailNo
										ELSE OldBasicRoutingDetailNo
									END AS OldBasicRoutingDetailNo,
									BasicRoutingDetailNo,
									BasicRoutingCode,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									IsUse,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldBasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingDetailNo VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 IsUse BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldBasicRoutingDetailNo,
								 @BasicRoutingDetailNo,
								 @BasicRoutingCode,
								 @RouteCode,
								 @RouteIndex,
								 @IsInputRoute,
								 @IsOutputRoute,
								 @IsUse,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				IF (@IsUse = 1) AND ISNULL(@BasicRoutingDetailNo,'') = '' BEGIN
                --IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BasicRoutingDetail WHERE BasicRoutingDetailNo = @BasicRoutingDetailNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @BasicRoutingDetailNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BasicRoutingDetail',@BasicRoutingDetailNo OUTPUT
                    END

                    INSERT INTO STB_BasicRoutingDetail
						(
						    BasicRoutingDetailNo,
						    BasicRoutingCode,
						    RouteCode,
						    RouteIndex,
						    IsInputRoute,
						    IsOutputRoute,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							CompanyCode,
							WorkCenterCode
						)
						VALUES
						(
						    @BasicRoutingDetailNo,
						    @BasicRoutingCode,
						    @RouteCode,
						    @RouteIndex,
						    @IsInputRoute,
						    @IsOutputRoute,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CompanyCode,
							@WorkCenterCode
						)

				END ELSE IF (@IsUse = 1) BEGIN

                    UPDATE STB_BasicRoutingDetail
						SET
						    BasicRoutingDetailNo =   ISNULL(@BasicRoutingDetailNo,BasicRoutingDetailNo),
						    BasicRoutingCode =   ISNULL(@BasicRoutingCode,BasicRoutingCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    RouteIndex =   ISNULL(@RouteIndex,RouteIndex),
						    IsInputRoute =   ISNULL(@IsInputRoute,IsInputRoute),
						    IsOutputRoute =   ISNULL(@IsOutputRoute,IsOutputRoute),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							CompanyCode = @CompanyCode,
							WorkCenterCode = @WorkCenterCode
						WHERE
						    BasicRoutingDetailNo = @OldBasicRoutingDetailNo
                END ELSE BEGIN
                    DELETE FROM STB_BasicRoutingDetail
						WHERE
						    BasicRoutingDetailNo = @OldBasicRoutingDetailNo
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
