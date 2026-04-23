
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 사용자관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserInfo_iud]
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
  DECLARE @OldUserID VARCHAR(20)
  DECLARE @UserID VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UserInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = ISNULL(SourceTable.UserID,TargetTable.UserID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode
					);


			-- Process Update Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.OldUserID
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = ISNULL(SourceTable.UserID,TargetTable.UserID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode
					);


			-- Process Delete Table
            MERGE STB_UserInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldUserID IS NULL THEN UserID
							    ELSE OldUserID
							END AS OldUserID,
							UserID,
							CompanyCode,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										UserID VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID
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
									OldUserID,
									UserID,
									CompanyCode,
									WorkCenterCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									UserID,
									CompanyCode,
									WorkCenterCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldUserID IS NULL THEN UserID
										ELSE OldUserID
									END AS OldUserID,
									UserID,
									CompanyCode,
									WorkCenterCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 UserID VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldUserID,
								 @UserID,
								 @CompanyCode,
								 @WorkCenterCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UserInfo WHERE UserID = @UserID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @UserID)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_UserInfo',@UserID OUTPUT
                    END

                    INSERT INTO STB_UserInfo
						(
						    UserID,
						    CompanyCode,
						    WorkCenterCode
						)
						VALUES
						(
						    @UserID,
						    @CompanyCode,
						    @WorkCenterCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_UserInfo
						SET
						    UserID =   ISNULL(@UserID,UserID),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode)
						WHERE
						    UserID = @OldUserID
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_UserInfo
						WHERE
						    UserID = @OldUserID
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
