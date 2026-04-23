-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-06-26
-- Browsable : true
-- Group : 비나에너솔
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_CustomerPartNoInfo_iud
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
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @OldCustomerPartNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @CustomerName NVARCHAR(50)
  DECLARE @CustomerPartNo VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CustomerPartNoInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CustomerPartNoInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCustomerPartNo IS NULL THEN CustomerPartNo
							    ELSE OldCustomerPartNo
							END AS OldCustomerPartNo,
							MaterialCode,
							CustomerName,
							CustomerPartNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(20),
										OldCustomerPartNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										CustomerName NVARCHAR(50),
										CustomerPartNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CustomerPartNo = SourceTable.CustomerPartNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					CustomerPartNo = ISNULL(SourceTable.CustomerPartNo,TargetTable.CustomerPartNo)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						CustomerName,
						CustomerPartNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.CustomerName,
							SourceTable.CustomerPartNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CustomerPartNoInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCustomerPartNo IS NULL THEN CustomerPartNo
							    ELSE OldCustomerPartNo
							END AS OldCustomerPartNo,
							MaterialCode,
							CustomerName,
							CustomerPartNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(20),
										OldCustomerPartNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										CustomerName NVARCHAR(50),
										CustomerPartNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.CustomerPartNo = SourceTable.OldCustomerPartNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					CustomerPartNo = ISNULL(SourceTable.CustomerPartNo,TargetTable.CustomerPartNo)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						CustomerName,
						CustomerPartNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.CustomerName,
							SourceTable.CustomerPartNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CustomerPartNoInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCustomerPartNo IS NULL THEN CustomerPartNo
							    ELSE OldCustomerPartNo
							END AS OldCustomerPartNo,
							MaterialCode,
							CustomerPartNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(20),
										OldCustomerPartNo VARCHAR(20),
										MaterialCode VARCHAR(20),
										CustomerPartNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CustomerPartNo = SourceTable.CustomerPartNo
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
        PRINT 'Loop was removed'
    END
END
