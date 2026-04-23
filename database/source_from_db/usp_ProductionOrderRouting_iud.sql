
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-20
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionOrderRouting_iud]
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

    -- Declare Columns Variable
  DECLARE @OldPoRoutingSeqNo BIGINT
  DECLARE @PoRoutingSeqNo BIGINT
  DECLARE @PONo VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @RouteIndex INT
  DECLARE @IsInputRoute BIT
  DECLARE @IsOutputRoute BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductionOrderRouting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
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
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
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
					TargetTable.PoRoutingSeqNo = SourceTable.PoRoutingSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PONo,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
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
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
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
					TargetTable.PoRoutingSeqNo = SourceTable.OldPoRoutingSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PONo,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
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
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
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
					TargetTable.PoRoutingSeqNo = SourceTable.PoRoutingSeqNo
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
									OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
										ELSE OldPoRoutingSeqNo
									END AS OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
										ELSE OldPoRoutingSeqNo
									END AS OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPoRoutingSeqNo,
								 @PoRoutingSeqNo,
								 @PONo,
								 @RouteCode,
								 @RouteIndex,
								 @IsInputRoute,
								 @IsOutputRoute,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ProductionOrderRouting WHERE PoRoutingSeqNo = @PoRoutingSeqNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PoRoutingSeqNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProductionOrderRouting',@PoRoutingSeqNo OUTPUT
                    END

                    INSERT INTO STB_ProductionOrderRouting
						(
						    PONo,
						    RouteCode,
						    RouteIndex,
						    IsInputRoute,
						    IsOutputRoute,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @PONo,
						    @RouteCode,
						    @RouteIndex,
						    @IsInputRoute,
						    @IsOutputRoute,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ProductionOrderRouting
						SET
						    PONo =   ISNULL(@PONo,PONo),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    RouteIndex =   ISNULL(@RouteIndex,RouteIndex),
						    IsInputRoute =   ISNULL(@IsInputRoute,IsInputRoute),
						    IsOutputRoute =   ISNULL(@IsOutputRoute,IsOutputRoute),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    PoRoutingSeqNo = @OldPoRoutingSeqNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ProductionOrderRouting
						WHERE
						    PoRoutingSeqNo = @OldPoRoutingSeqNo
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
