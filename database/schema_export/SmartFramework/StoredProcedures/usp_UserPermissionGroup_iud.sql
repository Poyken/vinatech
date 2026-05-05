-- Procedure: usp_UserPermissionGroup_iud






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 시스템관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserPermissionGroup_iud]
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
  DECLARE @OldUserID VARCHAR(20)
  DECLARE @OldUserType VARCHAR(20)
  DECLARE @UserID VARCHAR(20)
  DECLARE @UserType VARCHAR(20)
  DECLARE @HasPermission BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UserPermissionGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UserPermissionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserID IS NULL THEN XMLData.UserID
							    ELSE XMLData.OldUserID
							END AS OldUserID,
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserID,
							XMLData.UserType,
							XMLData.HasPermission,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldUserType VARCHAR(20),
										UserID VARCHAR(20),
										UserType VARCHAR(20),
										HasPermission BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID AND
					TargetTable.UserType = SourceTable.UserType
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = SourceTable.UserID,
					UserType = SourceTable.UserType,
					HasPermission = SourceTable.HasPermission,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						UserType,
						HasPermission,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.UserType,
							SourceTable.HasPermission,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_UserPermissionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserID IS NULL THEN XMLData.UserID
							    ELSE XMLData.OldUserID
							END AS OldUserID,
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserID,
							XMLData.UserType,
							XMLData.HasPermission,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldUserType VARCHAR(20),
										UserID VARCHAR(20),
										UserType VARCHAR(20),
										HasPermission BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.OldUserID AND
					TargetTable.UserType = SourceTable.OldUserType
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserID = SourceTable.UserID,
					UserType = SourceTable.UserType,
					HasPermission = SourceTable.HasPermission,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserID,
						UserType,
						HasPermission,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.UserID,
							SourceTable.UserType,
							SourceTable.HasPermission,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_UserPermissionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserID IS NULL THEN XMLData.UserID
							    ELSE XMLData.OldUserID
							END AS OldUserID,
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							XMLData.UserID,
							XMLData.UserType,
							XMLData.HasPermission,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldUserID VARCHAR(20),
										OldUserType VARCHAR(20),
										UserID VARCHAR(20),
										UserType VARCHAR(20),
										HasPermission BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserID = SourceTable.UserID AND
					TargetTable.UserType = SourceTable.UserType
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
									XMLData.OldUserID,
									XMLData.OldUserType,
									XMLData.UserID,
									XMLData.UserType,
									XMLData.HasPermission,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldUserType VARCHAR(20),
											 UserID VARCHAR(20),
											 UserType VARCHAR(20),
											 HasPermission BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldUserID IS NULL THEN XMLData.UserID
										ELSE XMLData.OldUserID
									END AS OldUserID,
									CASE 
										WHEN XMLData.OldUserID IS NULL THEN XMLData.UserType
										ELSE XMLData.OldUserID
									END AS OldUserType,
									XMLData.UserID,
									XMLData.UserType,
									XMLData.HasPermission,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldUserType VARCHAR(20),
											 UserID VARCHAR(20),
											 UserType VARCHAR(20),
											 HasPermission BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldUserID IS NULL THEN XMLData.UserID
										ELSE XMLData.OldUserID
									END AS OldUserID,
									CASE 
										WHEN XMLData.OldUserID IS NULL THEN XMLData.UserType
										ELSE XMLData.OldUserID
									END AS OldUserType,
									XMLData.UserID,
									XMLData.UserType,
									XMLData.HasPermission,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldUserID VARCHAR(20),
											 OldUserType VARCHAR(20),
											 UserID VARCHAR(20),
											 UserType VARCHAR(20),
											 HasPermission BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldUserID,
								 @OldUserType,
								 @UserID,
								 @UserType,
								 @HasPermission,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UserPermissionGroup WHERE UserID = @UserID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @UserID)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(UserID)
						FROM
								STB_UserPermissionGroup 
						WHERE
								UserID LIKE @PrefixString
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @UserID = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @UserID = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_UserPermissionGroup
						(
						    UserID,
						    UserType,
						    HasPermission,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @UserID,
						    @UserType,
						    @HasPermission,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_UserPermissionGroup
						SET
						    UserID =   CASE
						                WHEN @UserID IS NOT NULL THEN @UserID
						                ELSE UserID
						            END,
						    UserType =   CASE
						                WHEN @UserType IS NOT NULL THEN @UserType
						                ELSE UserType
						            END,
						    HasPermission =   CASE
						                WHEN @HasPermission IS NOT NULL THEN @HasPermission
						                ELSE HasPermission
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
						    UserID = @OldUserID AND
						    UserType = @OldUserType
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_UserPermissionGroup
						WHERE
						    UserID = @UserID AND
						    UserType = @UserType
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







GO

