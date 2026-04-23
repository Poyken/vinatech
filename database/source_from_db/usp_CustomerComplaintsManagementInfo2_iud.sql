
-- =============================================
-- Author:	    Kangs()
-- Create date: 2021-03-16
-- Browsable : true
-- Group : 품질관리 ------------------
-- Description:	고객불만 현상이미지
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_CustomerComplaintsManagementInfo2_iud
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
  DECLARE @OldCustomerComplaintsManagementNo VARCHAR(20)
  DECLARE @CustomerComplaintsManagementNo VARCHAR(20)
  DECLARE @ReceiptDate DATE
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @ProductSize VARCHAR(20)
  DECLARE @CustomerComplaintsDefectTypeCode VARCHAR(20)
  DECLARE @ProductionCompanyCode VARCHAR(20)
  DECLARE @CustomerComplaintsContents NVARCHAR(MAX)
  DECLARE @Barcode NVARCHAR(1000)
  DECLARE @MarkingLetter NVARCHAR(1000)
  DECLARE @DefectQty NUMERIC(10,2)
  DECLARE @ResponsibilityCompanyCode VARCHAR(20)
  DECLARE @CustomerComplaintsDefectCode VARCHAR(20)
  DECLARE @CauseContents NVARCHAR(MAX)
  DECLARE @ActionContents NVARCHAR(MAX)
  DECLARE @ActionDocSubmissionDate DATETIME
  DECLARE @ActionDocFileID BIGINT
  DECLARE @CreateDateTime DATE
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsPerformance BIT
  DECLARE @DefectImage VARBINARY(1)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_CustomerComplaintsManagementInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CustomerComplaintsManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsManagementNo IS NULL THEN CustomerComplaintsManagementNo
							    ELSE OldCustomerComplaintsManagementNo
							END AS OldCustomerComplaintsManagementNo,
							CustomerComplaintsManagementNo,
							ReceiptDate,
							CustomerCode,
							MaterialCode,
							ProductSize,
							CustomerComplaintsDefectTypeCode,
							ProductionCompanyCode,
							CustomerComplaintsContents,
							Barcode,
							MarkingLetter,
							DefectQty,
							ResponsibilityCompanyCode,
							CustomerComplaintsDefectCode,
							CauseContents,
							ActionContents,
							ActionDocSubmissionDate,
							ActionDocFileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsPerformance,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCustomerComplaintsManagementNo VARCHAR(20),
										CustomerComplaintsManagementNo VARCHAR(20),
										ReceiptDate DATETIMEOFFSET,
										CustomerCode VARCHAR(20),
										MaterialCode VARCHAR(20),
										ProductSize VARCHAR(20),
										CustomerComplaintsDefectTypeCode VARCHAR(20),
										ProductionCompanyCode VARCHAR(20),
										CustomerComplaintsContents NVARCHAR(MAX),
										Barcode NVARCHAR(1000),
										MarkingLetter NVARCHAR(1000),
										DefectQty NUMERIC(10,2),
										ResponsibilityCompanyCode VARCHAR(20),
										CustomerComplaintsDefectCode VARCHAR(20),
										CauseContents NVARCHAR(MAX),
										ActionContents NVARCHAR(MAX),
										ActionDocSubmissionDate DATETIMEOFFSET,
										ActionDocFileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsPerformance BIT,
										DefectImage NVARCHAR(1)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsManagementNo = SourceTable.CustomerComplaintsManagementNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerComplaintsManagementNo = ISNULL(SourceTable.CustomerComplaintsManagementNo,TargetTable.CustomerComplaintsManagementNo),
					ReceiptDate = ISNULL(SourceTable.ReceiptDate,TargetTable.ReceiptDate),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ProductSize = ISNULL(SourceTable.ProductSize,TargetTable.ProductSize),
					CustomerComplaintsDefectTypeCode = ISNULL(SourceTable.CustomerComplaintsDefectTypeCode,TargetTable.CustomerComplaintsDefectTypeCode),
					ProductionCompanyCode = ISNULL(SourceTable.ProductionCompanyCode,TargetTable.ProductionCompanyCode),
					CustomerComplaintsContents = ISNULL(SourceTable.CustomerComplaintsContents,TargetTable.CustomerComplaintsContents),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MarkingLetter = ISNULL(SourceTable.MarkingLetter,TargetTable.MarkingLetter),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					ResponsibilityCompanyCode = ISNULL(SourceTable.ResponsibilityCompanyCode,TargetTable.ResponsibilityCompanyCode),
					CustomerComplaintsDefectCode = ISNULL(SourceTable.CustomerComplaintsDefectCode,TargetTable.CustomerComplaintsDefectCode),
					CauseContents = ISNULL(SourceTable.CauseContents,TargetTable.CauseContents),
					ActionContents = ISNULL(SourceTable.ActionContents,TargetTable.ActionContents),
					ActionDocSubmissionDate = ISNULL(SourceTable.ActionDocSubmissionDate,TargetTable.ActionDocSubmissionDate),
					ActionDocFileID = ISNULL(SourceTable.ActionDocFileID,TargetTable.ActionDocFileID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsPerformance = ISNULL(SourceTable.IsPerformance,TargetTable.IsPerformance),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerComplaintsManagementNo,
						ReceiptDate,
						CustomerCode,
						MaterialCode,
						ProductSize,
						CustomerComplaintsDefectTypeCode,
						ProductionCompanyCode,
						CustomerComplaintsContents,
						Barcode,
						MarkingLetter,
						DefectQty,
						ResponsibilityCompanyCode,
						CustomerComplaintsDefectCode,
						CauseContents,
						ActionContents,
						ActionDocSubmissionDate,
						ActionDocFileID,
						CreateDateTime,
						CreateUserID,
						IsPerformance,
						DefectImage
					)
				VALUES
					(
							SourceTable.CustomerComplaintsManagementNo,
							SourceTable.ReceiptDate,
							SourceTable.CustomerCode,
							SourceTable.MaterialCode,
							SourceTable.ProductSize,
							SourceTable.CustomerComplaintsDefectTypeCode,
							SourceTable.ProductionCompanyCode,
							SourceTable.CustomerComplaintsContents,
							SourceTable.Barcode,
							SourceTable.MarkingLetter,
							SourceTable.DefectQty,
							SourceTable.ResponsibilityCompanyCode,
							SourceTable.CustomerComplaintsDefectCode,
							SourceTable.CauseContents,
							SourceTable.ActionContents,
							SourceTable.ActionDocSubmissionDate,
							SourceTable.ActionDocFileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsPerformance,
							SourceTable.DefectImage
					);


			-- Process Update Table
            MERGE STB_CustomerComplaintsManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsManagementNo IS NULL THEN CustomerComplaintsManagementNo
							    ELSE OldCustomerComplaintsManagementNo
							END AS OldCustomerComplaintsManagementNo,
							CustomerComplaintsManagementNo,
							ReceiptDate,
							CustomerCode,
							MaterialCode,
							ProductSize,
							CustomerComplaintsDefectTypeCode,
							ProductionCompanyCode,
							CustomerComplaintsContents,
							Barcode,
							MarkingLetter,
							DefectQty,
							ResponsibilityCompanyCode,
							CustomerComplaintsDefectCode,
							CauseContents,
							ActionContents,
							ActionDocSubmissionDate,
							ActionDocFileID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsPerformance,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCustomerComplaintsManagementNo VARCHAR(20),
										CustomerComplaintsManagementNo VARCHAR(20),
										ReceiptDate DATETIMEOFFSET,
										CustomerCode VARCHAR(20),
										MaterialCode VARCHAR(20),
										ProductSize VARCHAR(20),
										CustomerComplaintsDefectTypeCode VARCHAR(20),
										ProductionCompanyCode VARCHAR(20),
										CustomerComplaintsContents NVARCHAR(MAX),
										Barcode NVARCHAR(1000),
										MarkingLetter NVARCHAR(1000),
										DefectQty NUMERIC(10,2),
										ResponsibilityCompanyCode VARCHAR(20),
										CustomerComplaintsDefectCode VARCHAR(20),
										CauseContents NVARCHAR(MAX),
										ActionContents NVARCHAR(MAX),
										ActionDocSubmissionDate DATETIMEOFFSET,
										ActionDocFileID BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsPerformance BIT,
										DefectImage NVARCHAR(1)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsManagementNo = SourceTable.OldCustomerComplaintsManagementNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerComplaintsManagementNo = ISNULL(SourceTable.CustomerComplaintsManagementNo,TargetTable.CustomerComplaintsManagementNo),
					ReceiptDate = ISNULL(SourceTable.ReceiptDate,TargetTable.ReceiptDate),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ProductSize = ISNULL(SourceTable.ProductSize,TargetTable.ProductSize),
					CustomerComplaintsDefectTypeCode = ISNULL(SourceTable.CustomerComplaintsDefectTypeCode,TargetTable.CustomerComplaintsDefectTypeCode),
					ProductionCompanyCode = ISNULL(SourceTable.ProductionCompanyCode,TargetTable.ProductionCompanyCode),
					CustomerComplaintsContents = ISNULL(SourceTable.CustomerComplaintsContents,TargetTable.CustomerComplaintsContents),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode),
					MarkingLetter = ISNULL(SourceTable.MarkingLetter,TargetTable.MarkingLetter),
					DefectQty = ISNULL(SourceTable.DefectQty,TargetTable.DefectQty),
					ResponsibilityCompanyCode = ISNULL(SourceTable.ResponsibilityCompanyCode,TargetTable.ResponsibilityCompanyCode),
					CustomerComplaintsDefectCode = ISNULL(SourceTable.CustomerComplaintsDefectCode,TargetTable.CustomerComplaintsDefectCode),
					CauseContents = ISNULL(SourceTable.CauseContents,TargetTable.CauseContents),
					ActionContents = ISNULL(SourceTable.ActionContents,TargetTable.ActionContents),
					ActionDocSubmissionDate = ISNULL(SourceTable.ActionDocSubmissionDate,TargetTable.ActionDocSubmissionDate),
					ActionDocFileID = ISNULL(SourceTable.ActionDocFileID,TargetTable.ActionDocFileID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsPerformance = ISNULL(SourceTable.IsPerformance,TargetTable.IsPerformance),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerComplaintsManagementNo,
						ReceiptDate,
						CustomerCode,
						MaterialCode,
						ProductSize,
						CustomerComplaintsDefectTypeCode,
						ProductionCompanyCode,
						CustomerComplaintsContents,
						Barcode,
						MarkingLetter,
						DefectQty,
						ResponsibilityCompanyCode,
						CustomerComplaintsDefectCode,
						CauseContents,
						ActionContents,
						ActionDocSubmissionDate,
						ActionDocFileID,
						CreateDateTime,
						CreateUserID,
						IsPerformance,
						DefectImage
					)
				VALUES
					(
							SourceTable.CustomerComplaintsManagementNo,
							SourceTable.ReceiptDate,
							SourceTable.CustomerCode,
							SourceTable.MaterialCode,
							SourceTable.ProductSize,
							SourceTable.CustomerComplaintsDefectTypeCode,
							SourceTable.ProductionCompanyCode,
							SourceTable.CustomerComplaintsContents,
							SourceTable.Barcode,
							SourceTable.MarkingLetter,
							SourceTable.DefectQty,
							SourceTable.ResponsibilityCompanyCode,
							SourceTable.CustomerComplaintsDefectCode,
							SourceTable.CauseContents,
							SourceTable.ActionContents,
							SourceTable.ActionDocSubmissionDate,
							SourceTable.ActionDocFileID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsPerformance,
							SourceTable.DefectImage
					);


			-- Process Delete Table
            MERGE STB_CustomerComplaintsManagementInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerComplaintsManagementNo IS NULL THEN CustomerComplaintsManagementNo
							    ELSE OldCustomerComplaintsManagementNo
							END AS OldCustomerComplaintsManagementNo,
							CustomerComplaintsManagementNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCustomerComplaintsManagementNo VARCHAR(20),
										CustomerComplaintsManagementNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerComplaintsManagementNo = SourceTable.CustomerComplaintsManagementNo
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
