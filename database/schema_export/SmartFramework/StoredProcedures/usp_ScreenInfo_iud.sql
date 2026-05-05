-- Procedure: usp_ScreenInfo_iud






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-02-11
-- Browsable : true
-- Group : System
-- Description:	화면정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ScreenInfo_iud]
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
  DECLARE @OldName VARCHAR(50)
  DECLARE @Name VARCHAR(50)
  DECLARE @TCode VARCHAR(10)
  DECLARE @IsFolder BIT
  DECLARE @IsDialog BIT
  DECLARE @IsNeverClose BIT
  DECLARE @ParentName VARCHAR(50)
  DECLARE @Caption NVARCHAR(100)
  DECLARE @ShowAfterStart BIT
  DECLARE @ShowInMenu BIT
  DECLARE @CurrentVersion INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsDelete BIT
  DECLARE @DeleteDateTime DATETIME
  DECLARE @DeleteUserID VARCHAR(20)
  DECLARE @AccessType VARCHAR(50)
  DECLARE @Icon VARBINARY(MAX)
  DECLARE @SystemCode VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ScreenInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
							XMLData.IsDialog,
							XMLData.IsNeverClose,
							XMLData.ParentName,
							XMLData.Caption,
							XMLData.ShowAfterStart,
							XMLData.ShowInMenu,
							XMLData.CurrentVersion,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.IsDelete,
							XMLData.DeleteDateTime,
							XMLData.DeleteUserID,
							XMLData.AccessType,
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon,
							XMLData.SystemCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
										IsDialog BIT,
										IsNeverClose BIT,
										ParentName VARCHAR(50),
										Caption NVARCHAR(100),
										ShowAfterStart BIT,
										ShowInMenu BIT,
										CurrentVersion INT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20),
										IsDelete BIT,
										DeleteDateTime DATETIME,
										DeleteUserID VARCHAR(20),
										AccessType VARCHAR(50),
										Icon NVARCHAR(MAX),
										SystemCode VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					Name = SourceTable.Name,
					TCode = SourceTable.TCode,
					IsFolder = SourceTable.IsFolder,
					IsDialog = SourceTable.IsDialog,
					IsNeverClose = SourceTable.IsNeverClose,
					ParentName = SourceTable.ParentName,
					Caption = SourceTable.Caption,
					ShowAfterStart = SourceTable.ShowAfterStart,
					ShowInMenu = SourceTable.ShowInMenu,
					CurrentVersion = SourceTable.CurrentVersion,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					IsDelete = SourceTable.IsDelete,
					DeleteDateTime = SourceTable.DeleteDateTime,
					DeleteUserID = SourceTable.DeleteUserID,
					AccessType = SourceTable.AccessType,
					Icon = dbo.fnBase64ToBinary(SourceTable.Icon),
					SystemCode = SourceTable.SystemCode
			WHEN NOT MATCHED THEN
				INSERT
					(
						Name,
						TCode,
						IsFolder,
						IsDialog,
						IsNeverClose,
						ParentName,
						Caption,
						ShowAfterStart,
						ShowInMenu,
						CurrentVersion,
						CreateDateTime,
						CreateUserID,
						IsDelete,
						DeleteDateTime,
						DeleteUserID,
						AccessType,
						Icon,
						SystemCode
					)
				VALUES
					(
							SourceTable.Name,
							SourceTable.TCode,
							SourceTable.IsFolder,
							SourceTable.IsDialog,
							SourceTable.IsNeverClose,
							SourceTable.ParentName,
							SourceTable.Caption,
							SourceTable.ShowAfterStart,
							SourceTable.ShowInMenu,
							SourceTable.CurrentVersion,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsDelete,
							SourceTable.DeleteDateTime,
							SourceTable.DeleteUserID,
							SourceTable.AccessType,
							SourceTable.Icon,
							SourceTable.SystemCode
					);


			-- Process Update Table
            MERGE STB_ScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
							XMLData.IsDialog,
							XMLData.IsNeverClose,
							XMLData.ParentName,
							XMLData.Caption,
							XMLData.ShowAfterStart,
							XMLData.ShowInMenu,
							XMLData.CurrentVersion,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.IsDelete,
							XMLData.DeleteDateTime,
							XMLData.DeleteUserID,
							XMLData.AccessType,
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon,
							XMLData.SystemCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
										IsDialog BIT,
										IsNeverClose BIT,
										ParentName VARCHAR(50),
										Caption NVARCHAR(100),
										ShowAfterStart BIT,
										ShowInMenu BIT,
										CurrentVersion INT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20),
										IsDelete BIT,
										DeleteDateTime DATETIME,
										DeleteUserID VARCHAR(20),
										AccessType VARCHAR(50),
										Icon NVARCHAR(MAX),
										SystemCode VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.OldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Name = SourceTable.Name,
					TCode = SourceTable.TCode,
					IsFolder = SourceTable.IsFolder,
					IsDialog = SourceTable.IsDialog,
					IsNeverClose = SourceTable.IsNeverClose,
					ParentName = SourceTable.ParentName,
					Caption = SourceTable.Caption,
					ShowAfterStart = SourceTable.ShowAfterStart,
					ShowInMenu = SourceTable.ShowInMenu,
					CurrentVersion = SourceTable.CurrentVersion,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					IsDelete = SourceTable.IsDelete,
					DeleteDateTime = SourceTable.DeleteDateTime,
					DeleteUserID = SourceTable.DeleteUserID,
					AccessType = SourceTable.AccessType,
					Icon = SourceTable.Icon,
					SystemCode = SourceTable.SystemCode
			WHEN NOT MATCHED THEN
				INSERT
					(
						Name,
						TCode,
						IsFolder,
						IsDialog,
						IsNeverClose,
						ParentName,
						Caption,
						ShowAfterStart,
						ShowInMenu,
						CurrentVersion,
						CreateDateTime,
						CreateUserID,
						IsDelete,
						DeleteDateTime,
						DeleteUserID,
						AccessType,
						Icon,
						SystemCode
					)
				VALUES
					(
							SourceTable.Name,
							SourceTable.TCode,
							SourceTable.IsFolder,
							SourceTable.IsDialog,
							SourceTable.IsNeverClose,
							SourceTable.ParentName,
							SourceTable.Caption,
							SourceTable.ShowAfterStart,
							SourceTable.ShowInMenu,
							SourceTable.CurrentVersion,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsDelete,
							SourceTable.DeleteDateTime,
							SourceTable.DeleteUserID,
							SourceTable.AccessType,
							SourceTable.Icon,
							SourceTable.SystemCode
					);

			-- GUI의 메뉴관리에서 메뉴 삭제시 관련 데이터 삭제
			DECLARE @Delete TABLE
			(
				Name VARCHAR(50)
			)
			INSERT INTO @Delete
			SELECT
					Name
			FROM
					OPENXML(@idoc , @DeleteTableName , 2)
					WITH  (
								Name VARCHAR(50)
							) XMLData

			DELETE FROM STB_ScreenLayoutInfo
			WHERE	Name = @Name

			DELETE FROM STB_UserTypeBasicPermission
			WHERE	Name = @Name

			DELETE FROM STB_UserTypeViewPermission
			WHERE	Name = @Name

			DELETE FROM STB_UserTypeFunctionPermission
			WHERE	Name = @Name

			DELETE FROM STB_FavoriteMenu
			WHERE	Name = @Name

			DELETE FROM STB_ScreenDiagrams
			WHERE	Name = @Name

			DELETE FROM STB_ScreenObjects
			WHERE	ScreenName = @Name

			-- Process Delete Table
            MERGE STB_ScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
							XMLData.IsDialog,
							XMLData.IsNeverClose,
							XMLData.ParentName,
							XMLData.Caption,
							XMLData.ShowAfterStart,
							XMLData.ShowInMenu,
							XMLData.CurrentVersion,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.IsDelete,
							XMLData.DeleteDateTime,
							XMLData.DeleteUserID,
							XMLData.AccessType,
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon,
							XMLData.SystemCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
										IsDialog BIT,
										IsNeverClose BIT,
										ParentName VARCHAR(50),
										Caption NVARCHAR(100),
										ShowAfterStart BIT,
										ShowInMenu BIT,
										CurrentVersion INT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20),
										IsDelete BIT,
										DeleteDateTime DATETIME,
										DeleteUserID VARCHAR(20),
										AccessType VARCHAR(50),
										Icon NVARCHAR(MAX),
										SystemCode VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.Name = SourceTable.Name
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
									XMLData.OldName,
									XMLData.Name,
									XMLData.TCode,
									XMLData.IsFolder,
									XMLData.IsDialog,
									XMLData.IsNeverClose,
									XMLData.ParentName,
									XMLData.Caption,
									XMLData.ShowAfterStart,
									XMLData.ShowInMenu,
									XMLData.CurrentVersion,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsDelete,
									XMLData.DeleteDateTime,
									XMLData.DeleteUserID,
									XMLData.AccessType,
									dbo.fnBase64ToBinary(XMLData.Icon),
									XMLData.SystemCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 TCode VARCHAR(10),
											 IsFolder BIT,
											 IsDialog BIT,
											 IsNeverClose BIT,
											 ParentName VARCHAR(50),
											 Caption NVARCHAR(100),
											 ShowAfterStart BIT,
											 ShowInMenu BIT,
											 CurrentVersion INT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20),
											 IsDelete BIT,
											 DeleteDateTime DATETIME,
											 DeleteUserID VARCHAR(20),
											 AccessType VARCHAR(50),
											 Icon NVARCHAR(MAX),
											 SystemCode VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldName IS NULL THEN XMLData.Name
										ELSE XMLData.OldName
									END AS OldName,
									XMLData.Name,
									XMLData.TCode,
									XMLData.IsFolder,
									XMLData.IsDialog,
									XMLData.IsNeverClose,
									XMLData.ParentName,
									XMLData.Caption,
									XMLData.ShowAfterStart,
									XMLData.ShowInMenu,
									XMLData.CurrentVersion,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsDelete,
									XMLData.DeleteDateTime,
									XMLData.DeleteUserID,
									XMLData.AccessType,
									dbo.fnBase64ToBinary(XMLData.Icon),
									XMLData.SystemCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 TCode VARCHAR(10),
											 IsFolder BIT,
											 IsDialog BIT,
											 IsNeverClose BIT,
											 ParentName VARCHAR(50),
											 Caption NVARCHAR(100),
											 ShowAfterStart BIT,
											 ShowInMenu BIT,
											 CurrentVersion INT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20),
											 IsDelete BIT,
											 DeleteDateTime DATETIME,
											 DeleteUserID VARCHAR(20),
											 AccessType VARCHAR(50),
											 Icon NVARCHAR(MAX),
											 SystemCode VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldName IS NULL THEN XMLData.Name
										ELSE XMLData.OldName
									END AS OldName,
									XMLData.Name,
									XMLData.TCode,
									XMLData.IsFolder,
									XMLData.IsDialog,
									XMLData.IsNeverClose,
									XMLData.ParentName,
									XMLData.Caption,
									XMLData.ShowAfterStart,
									XMLData.ShowInMenu,
									XMLData.CurrentVersion,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.IsDelete,
									XMLData.DeleteDateTime,
									XMLData.DeleteUserID,
									XMLData.AccessType,
									dbo.fnBase64ToBinary(XMLData.Icon),
									XMLData.SystemCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldName VARCHAR(50),
											 Name VARCHAR(50),
											 TCode VARCHAR(10),
											 IsFolder BIT,
											 IsDialog BIT,
											 IsNeverClose BIT,
											 ParentName VARCHAR(50),
											 Caption NVARCHAR(100),
											 ShowAfterStart BIT,
											 ShowInMenu BIT,
											 CurrentVersion INT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20),
											 IsDelete BIT,
											 DeleteDateTime DATETIME,
											 DeleteUserID VARCHAR(20),
											 AccessType VARCHAR(50),
											 Icon NVARCHAR(MAX),
											 SystemCode VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldName,
								 @Name,
								 @TCode,
								 @IsFolder,
								 @IsDialog,
								 @IsNeverClose,
								 @ParentName,
								 @Caption,
								 @ShowAfterStart,
								 @ShowInMenu,
								 @CurrentVersion,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsDelete,
								 @DeleteDateTime,
								 @DeleteUserID,
								 @AccessType,
								 @Icon,
								 @SystemCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ScreenInfo WHERE Name = @Name) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @Name)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(Name)
						FROM
								STB_ScreenInfo 
						WHERE
								Name LIKE @PrefixString + '%'
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @Name = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @Name = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END
                    END

                    INSERT INTO STB_ScreenInfo
						(
						    Name,
						    TCode,
						    IsFolder,
							IsDialog,
						    IsNeverClose,
						    ParentName,
						    Caption,
						    ShowAfterStart,
						    ShowInMenu,
						    CurrentVersion,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    IsDelete,
						    DeleteDateTime,
						    DeleteUserID,
							AccessType,
							Icon,
							SystemCode
						)
						VALUES
						(
						    @Name,
						    @TCode,
						    @IsFolder,
							@IsDialog,
						    @IsNeverClose,
						    @ParentName,
						    @Caption,
						    @ShowAfterStart,
						    @ShowInMenu,
						    @CurrentVersion,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @IsDelete,
						    @DeleteDateTime,
						    @DeleteUserID,
							@AccessType,
							@Icon,
							@SystemCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ScreenInfo
						SET
						    Name =   CASE
						                WHEN @Name IS NOT NULL THEN @Name
						                ELSE Name
						            END,
						    TCode =   CASE
						                WHEN @TCode IS NOT NULL THEN @TCode
						                ELSE TCode
						            END,
						    IsFolder =   CASE
						                WHEN @IsFolder IS NOT NULL THEN @IsFolder
						                ELSE IsFolder
						            END,
							IsDialog =   CASE
						                WHEN @IsDialog IS NOT NULL THEN @IsDialog
						                ELSE IsDialog
						            END,
						    IsNeverClose =   CASE
						                WHEN @IsNeverClose IS NOT NULL THEN @IsNeverClose
						                ELSE IsNeverClose
						            END,
						    ParentName =   CASE
						                WHEN @ParentName IS NOT NULL THEN @ParentName
						                ELSE ParentName
						            END,
						    Caption =   CASE
						                WHEN @Caption IS NOT NULL THEN @Caption
						                ELSE Caption
						            END,
						    ShowAfterStart =   CASE
						                WHEN @ShowAfterStart IS NOT NULL THEN @ShowAfterStart
						                ELSE ShowAfterStart
						            END,
						    ShowInMenu =   CASE
						                WHEN @ShowInMenu IS NOT NULL THEN @ShowInMenu
						                ELSE ShowInMenu
						            END,
						    CurrentVersion =   CASE
						                WHEN @CurrentVersion IS NOT NULL THEN @CurrentVersion
						                ELSE CurrentVersion
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
						    IsDelete =   CASE
						                WHEN @IsDelete IS NOT NULL THEN @IsDelete
						                ELSE IsDelete
						            END,
						    DeleteDateTime =   CASE
						                WHEN @DeleteDateTime IS NOT NULL THEN @DeleteDateTime
						                ELSE DeleteDateTime
						            END,
						    DeleteUserID =   CASE
						                WHEN @DeleteUserID IS NOT NULL THEN @DeleteUserID
						                ELSE DeleteUserID
						            END,
							AccessType =   CASE
						                WHEN @AccessType IS NOT NULL THEN @AccessType
						                ELSE AccessType
						            END,
							Icon =   CASE
						                WHEN @Icon IS NOT NULL THEN dbo.fnBase64ToBinary(@Icon)
						                ELSE Icon
						            END,
							SystemCode = CASE
										WHEN @SystemCode IS NOT NULL THEN @SystemCode
										ELSE SystemCode
									END
						WHERE
						    Name = @OldName
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					-- GUI의 메뉴관리에서 메뉴 삭제시 실제 삭제 및 하위메뉴 삭제	
                    DELETE FROM STB_ScreenInfo
					WHERE   Name = @Name

					DELETE FROM STB_ScreenInfo
					WHERE
							Name IN (SELECT Name FROM DBO.fnGetChildScreens(@Name))
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

