-- Procedure: usp_StringResources_iud





-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-10-18
-- Browsable : true
-- Group : 시스템
-- Description:	String Resource정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_StringResources_iud]
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
  DECLARE @OldLanguage VARCHAR(20)
  DECLARE @OldType VARCHAR(20)
  DECLARE @OldName NVARCHAR(200)
  DECLARE @Language VARCHAR(20)
  DECLARE @Type VARCHAR(20)
  DECLARE @Name NVARCHAR(200)
  DECLARE @Value NVARCHAR(500)
  DECLARE @Description NVARCHAR(200)
  DECLARE @ChangeDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_StringResources',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_StringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLanguage IS NULL THEN Language
							    ELSE OldLanguage
							END AS OldLanguage,
							CASE
							    WHEN OldType IS NULL THEN Type
							    ELSE OldType
							END AS OldType,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Language,
							Type,
							Name,
							Value,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLanguage VARCHAR(20),
										OldType VARCHAR(20),
										OldName NVARCHAR(200),
										Language VARCHAR(20),
										Type VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(500),
										Description NVARCHAR(200),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Language = SourceTable.Language AND
					TargetTable.Type = SourceTable.Type AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					Language = ISNULL(SourceTable.Language,TargetTable.Language),
					Type = ISNULL(SourceTable.Type,TargetTable.Type),
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					Value = ISNULL(SourceTable.Value,TargetTable.Value),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Language,
						Type,
						Name,
						Value,
						Description
					)
				VALUES
					(
							SourceTable.Language,
							SourceTable.Type,
							SourceTable.Name,
							SourceTable.Value,
							SourceTable.Description
					);


			-- Process Update Table
            MERGE STB_StringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLanguage IS NULL THEN Language
							    ELSE OldLanguage
							END AS OldLanguage,
							CASE
							    WHEN OldType IS NULL THEN Type
							    ELSE OldType
							END AS OldType,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Language,
							Type,
							Name,
							Value,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLanguage VARCHAR(20),
										OldType VARCHAR(20),
										OldName NVARCHAR(200),
										Language VARCHAR(20),
										Type VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(500),
										Description NVARCHAR(200),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Language = SourceTable.OldLanguage AND
					TargetTable.Type = SourceTable.OldType AND
					TargetTable.Name = SourceTable.OldName
				)

			WHEN MATCHED THEN
				UPDATE SET
					Language = ISNULL(SourceTable.Language,TargetTable.Language),
					Type = ISNULL(SourceTable.Type,TargetTable.Type),
					Name = ISNULL(SourceTable.Name,TargetTable.Name),
					Value = ISNULL(SourceTable.Value,TargetTable.Value),
					Description = ISNULL(SourceTable.Description,TargetTable.Description),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Language,
						Type,
						Name,
						Value,
						Description
					)
				VALUES
					(
							SourceTable.Language,
							SourceTable.Type,
							SourceTable.Name,
							SourceTable.Value,
							SourceTable.Description
					);


			-- Process Delete Table
            MERGE STB_StringResources AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLanguage IS NULL THEN Language
							    ELSE OldLanguage
							END AS OldLanguage,
							CASE
							    WHEN OldType IS NULL THEN Type
							    ELSE OldType
							END AS OldType,
							CASE
							    WHEN OldName IS NULL THEN Name
							    ELSE OldName
							END AS OldName,
							Language,
							Type,
							Name,
							Value,
							Description,
							GETDATE() AS ChangeDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLanguage VARCHAR(20),
										OldType VARCHAR(20),
										OldName NVARCHAR(200),
										Language VARCHAR(20),
										Type VARCHAR(20),
										Name NVARCHAR(200),
										Value NVARCHAR(500),
										Description NVARCHAR(200),
										ChangeDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Language = SourceTable.Language AND
					TargetTable.Type = SourceTable.Type AND
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





GO

