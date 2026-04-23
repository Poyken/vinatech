
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-07-03
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecialRecruitmentHistory_iud]
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
  DECLARE @OldBarcode VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)
  DECLARE @SpecialRecruitmentRemark NVARCHAR(MAX)
  DECLARE @IsDelete BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SpecialRecruitmentHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SpecialRecruitmentHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							Barcode,
							SpecialRecruitmentRemark,
							IsDelete,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20),
										SpecialRecruitmentRemark NVARCHAR(MAX),
										IsDelete BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.Barcode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecialRecruitmentRemark = ISNULL(SourceTable.SpecialRecruitmentRemark,TargetTable.SpecialRecruitmentRemark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						SpecialRecruitmentRemark,
						IsDelete,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.SpecialRecruitmentRemark,
							CONVERT(BIT, 0),
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SpecialRecruitmentHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							Barcode,
							SpecialRecruitmentRemark,
							IsDelete,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20),
										SpecialRecruitmentRemark NVARCHAR(MAX),
										IsDelete BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.OldBarcode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecialRecruitmentRemark = ISNULL(SourceTable.SpecialRecruitmentRemark,TargetTable.SpecialRecruitmentRemark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Barcode,
						SpecialRecruitmentRemark,
						IsDelete,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.Barcode,
							SourceTable.SpecialRecruitmentRemark,
							CONVERT(BIT, 0),
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SpecialRecruitmentHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBarcode IS NULL THEN Barcode
							    ELSE OldBarcode
							END AS OldBarcode,
							Barcode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBarcode VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.Barcode = SourceTable.Barcode
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
