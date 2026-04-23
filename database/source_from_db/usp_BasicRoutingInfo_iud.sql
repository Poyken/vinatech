
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-07-30
-- Browsable : true
-- Group : 기준정보
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicRoutingInfo_iud]
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
  DECLARE @OldBasicRoutingCode VARCHAR(20)
  DECLARE @BasicRoutingCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @BasicRoutingName NVARCHAR(100)
  DECLARE @BasicRoutingDesc NVARCHAR(MAX)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BasicRoutingInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BasicRoutingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingCode IS NULL THEN BasicRoutingCode
							    ELSE OldBasicRoutingCode
							END AS OldBasicRoutingCode,
							BasicRoutingCode,
							CompanyCode,
							WorkCenterCode,
							BasicRoutingName,
							BasicRoutingDesc,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBasicRoutingCode VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicRoutingName NVARCHAR(100),
										BasicRoutingDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingCode = SourceTable.BasicRoutingCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					BasicRoutingCode = ISNULL(SourceTable.BasicRoutingCode,TargetTable.BasicRoutingCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					BasicRoutingName = ISNULL(SourceTable.BasicRoutingName,TargetTable.BasicRoutingName),
					BasicRoutingDesc = ISNULL(SourceTable.BasicRoutingDesc,TargetTable.BasicRoutingDesc),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BasicRoutingCode,
						CompanyCode,
						WorkCenterCode,
						BasicRoutingName,
						BasicRoutingDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BasicRoutingCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicRoutingName,
							SourceTable.BasicRoutingDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_BasicRoutingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingCode IS NULL THEN BasicRoutingCode
							    ELSE OldBasicRoutingCode
							END AS OldBasicRoutingCode,
							BasicRoutingCode,
							CompanyCode,
							WorkCenterCode,
							BasicRoutingName,
							BasicRoutingDesc,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBasicRoutingCode VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicRoutingName NVARCHAR(100),
										BasicRoutingDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingCode = SourceTable.OldBasicRoutingCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					BasicRoutingCode = ISNULL(SourceTable.BasicRoutingCode,TargetTable.BasicRoutingCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					BasicRoutingName = ISNULL(SourceTable.BasicRoutingName,TargetTable.BasicRoutingName),
					BasicRoutingDesc = ISNULL(SourceTable.BasicRoutingDesc,TargetTable.BasicRoutingDesc),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						BasicRoutingCode,
						CompanyCode,
						WorkCenterCode,
						BasicRoutingName,
						BasicRoutingDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.BasicRoutingCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicRoutingName,
							SourceTable.BasicRoutingDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_BasicRoutingInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBasicRoutingCode IS NULL THEN BasicRoutingCode
							    ELSE OldBasicRoutingCode
							END AS OldBasicRoutingCode,
							BasicRoutingCode,
							CompanyCode,
							WorkCenterCode,
							BasicRoutingName,
							BasicRoutingDesc,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBasicRoutingCode VARCHAR(20),
										BasicRoutingCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicRoutingName NVARCHAR(100),
										BasicRoutingDesc NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BasicRoutingCode = SourceTable.BasicRoutingCode
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
									OldBasicRoutingCode,
									BasicRoutingCode,
									CompanyCode,
									WorkCenterCode,
									BasicRoutingName,
									BasicRoutingDesc,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldBasicRoutingCode VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicRoutingName NVARCHAR(100),
											 BasicRoutingDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldBasicRoutingCode IS NULL THEN BasicRoutingCode
										ELSE OldBasicRoutingCode
									END AS OldBasicRoutingCode,
									BasicRoutingCode,
									CompanyCode,
									WorkCenterCode,
									BasicRoutingName,
									BasicRoutingDesc,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldBasicRoutingCode VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicRoutingName NVARCHAR(100),
											 BasicRoutingDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldBasicRoutingCode IS NULL THEN BasicRoutingCode
										ELSE OldBasicRoutingCode
									END AS OldBasicRoutingCode,
									BasicRoutingCode,
									CompanyCode,
									WorkCenterCode,
									BasicRoutingName,
									BasicRoutingDesc,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldBasicRoutingCode VARCHAR(20),
											 BasicRoutingCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicRoutingName NVARCHAR(100),
											 BasicRoutingDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldBasicRoutingCode,
								 @BasicRoutingCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @BasicRoutingName,
								 @BasicRoutingDesc,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BasicRoutingInfo WHERE BasicRoutingCode = @BasicRoutingCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @BasicRoutingCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BasicRoutingInfo',@BasicRoutingCode OUTPUT
                    END

                    INSERT INTO STB_BasicRoutingInfo
						(
						    BasicRoutingCode,
						    CompanyCode,
						    WorkCenterCode,
						    BasicRoutingName,
						    BasicRoutingDesc,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @BasicRoutingCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @BasicRoutingName,
						    @BasicRoutingDesc,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BasicRoutingInfo
						SET
						    BasicRoutingCode =   ISNULL(@BasicRoutingCode,BasicRoutingCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    BasicRoutingName =   ISNULL(@BasicRoutingName,BasicRoutingName),
						    BasicRoutingDesc =   ISNULL(@BasicRoutingDesc,BasicRoutingDesc),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    BasicRoutingCode = @OldBasicRoutingCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BasicRoutingInfo
						WHERE
						    BasicRoutingCode = @OldBasicRoutingCode
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
