

-- =============================================
-- Author: Kim Yong Chan (yckim@awoo.co.kr)
-- Create date: 2018-04-12
-- Browsable : true
-- Group : 기준 정보
-- Description:	모델라벨정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeModelLabelInfo]
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
	DECLARE @UpdateTableName VARCHAR(200) = '/DataSet/' + @ProcessViewName + '_UPDATE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModelLabelInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			;
			WITH UpdateTable 
			AS 
			(
					SELECT
							MaterialCode,
							LabelType,
							FormatName
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  
									(
										MaterialCode VARCHAR(50),
										LabelType VARCHAR(20),
										FormatName VARCHAR(50)
									) 		
				)
          
		    MERGE STB_ModelLabelInfo AS TargetTable
			USING
				(
					SELECT
							MaterialCode,
							LabelType,
							FormatName
					FROM
							UpdateTable
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.MaterialCode AND
					TargetTable.LabelType = SourceTable.LabelType 
				)
			WHEN MATCHED THEN
				UPDATE SET
					ModelCode = SourceTable.MaterialCode,
					LabelType = SourceTable.LabelType,
					FormatName = SourceTable.FormatName,
					ChangeDateTime = GETDATE(),
					ChangeUserID = @ProcessUserID
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
							SourceTable.MaterialCode,
							SourceTable.LabelType,
							SourceTable.FormatName,
							GETDATE(),
							@ProcessUserID
					)
			WHEN NOT MATCHED BY SOURCE AND ((TargetTable.LabelType IN (SELECT LabelType FROM UpdateTable)) AND (TargetTable.FormatName IN (SELECT FormatName FROM UpdateTable))) THEN
				DELETE;


        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

END


