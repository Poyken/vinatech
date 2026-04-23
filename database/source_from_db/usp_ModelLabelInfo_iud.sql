
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-31
-- Browsable : true
-- Group : 모델라벨정보
-- Description:	모델라벨정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelLabelInfo_iud]
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
    DECLARE @AlltTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
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
  DECLARE @OldModelCode VARCHAR(50)
  DECLARE @OldLabelType NVARCHAR(30)
  DECLARE @ModelCode VARCHAR(50)
  DECLARE @LabelType NVARCHAR(30)
  DECLARE @FormatName NVARCHAR(30)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModelLabelInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Update Table
			;WITH SourceTable_CTE AS (
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldLabelType IS NULL THEN LabelType
							    ELSE OldLabelType
							END AS OldLabelType,
							ModelCode,
							LabelType,
							FormatName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @AlltTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldLabelType NVARCHAR(30),
										ModelCode VARCHAR(50),
										LabelType NVARCHAR(30),
										FormatName NVARCHAR(30),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 		
				)
            MERGE STB_ModelLabelInfo AS TargetTable
			USING
				(
					SELECT
							*
					FROM
							SourceTable_CTE
					WHERE
							IsUsed = 1
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.OldModelCode AND
					TargetTable.LabelType = SourceTable.OldLabelType
				)
			WHEN MATCHED THEN
				UPDATE SET
					FormatName = SourceTable.FormatName,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModelCode,
						LabelType,
						FormatName,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ModelCode,
							SourceTable.LabelType,
							SourceTable.FormatName,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					)
			WHEN NOT MATCHED BY SOURCE AND ((TargetTable.LabelType IN (SELECT LabelType FROM SourceTable_CTE)) AND (TargetTable.FormatName IN (SELECT FormatName FROM SourceTable_CTE))) THEN
				DELETE;



        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

END

