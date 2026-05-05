-- Procedure: usp_VendorScreenInfo_iud






-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10.20
-- Browsable : true
-- Group : System
-- Description:	업체별화면정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VendorScreenInfo_iud]
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
  DECLARE @OldSystemCode VARCHAR(20)
  DECLARE @SystemCode VARCHAR(20)
  DECLARE @OldName VARCHAR(50)
  DECLARE @Name VARCHAR(50)
  DECLARE @TCode VARCHAR(10)
  DECLARE @IsFolder BIT
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

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VendorScreenInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_VendorScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSystemCode IS NULL THEN XMLData.SystemCode
							    ELSE XMLData.OldSystemCode
							END AS OldSystemCode,
							XMLData.SystemCode,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
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
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSystemCode VARCHAR(20),
										SystemCode VARCHAR(20),
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
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
										Icon NVARCHAR(MAX)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SystemCode = SourceTable.SystemCode AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					SystemCode = SourceTable.SystemCode,
					Name = SourceTable.Name,
					TCode = SourceTable.TCode,
					IsFolder = SourceTable.IsFolder,
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
					Icon = dbo.fnBase64ToBinary(SourceTable.Icon)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SystemCode,
						Name,
						TCode,
						IsFolder,
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
						Icon
					)
				VALUES
					(
							SourceTable.SystemCode,
							SourceTable.Name,
							SourceTable.TCode,
							SourceTable.IsFolder,
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
							SourceTable.Icon
					);


			-- Process Update Table
            MERGE STB_VendorScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSystemCode IS NULL THEN XMLData.SystemCode
							    ELSE XMLData.OldSystemCode
							END AS OldSystemCode,
							XMLData.SystemCode,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
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
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSystemCode VARCHAR(20),
										SystemCode VARCHAR(20),
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
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
										Icon NVARCHAR(MAX)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SystemCode = SourceTable.OldSystemCode AND
					TargetTable.Name = SourceTable.OldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					SystemCode = SourceTable.SystemCode,
					Name = SourceTable.Name,
					TCode = SourceTable.TCode,
					IsFolder = SourceTable.IsFolder,
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
					Icon = SourceTable.Icon
			WHEN NOT MATCHED THEN
				INSERT
					(
						SystemCode,
						Name,
						TCode,
						IsFolder,
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
						Icon
					)
				VALUES
					(
							SourceTable.SystemCode,
							SourceTable.Name,
							SourceTable.TCode,
							SourceTable.IsFolder,
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
							SourceTable.Icon
					);

			-- Process Delete Table
            MERGE STB_VendorScreenInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSystemCode IS NULL THEN XMLData.SystemCode
							    ELSE XMLData.OldSystemCode
							END AS OldSystemCode,
							XMLData.SystemCode,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.Name,
							XMLData.TCode,
							XMLData.IsFolder,
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
							dbo.fnBase64ToBinary(XMLData.Icon) AS Icon
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSystemCode VARCHAR(20),
										SystemCode VARCHAR(20),
										OldName VARCHAR(50),
										Name VARCHAR(50),
										TCode VARCHAR(10),
										IsFolder BIT,
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
										Icon NVARCHAR(MAX)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SystemCode = SourceTable.SystemCode AND
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

    END
END







GO

