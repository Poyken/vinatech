-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 영업관리
-- Description:	고객불만요청사항등록
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CustomerComplaintsRequestInfo_iud
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
  DECLARE @OldCustomerComplaintsRequestNo VARCHAR(20)
  DECLARE @CustomerComplaintsRequestNo VARCHAR(20)
  DECLARE @ReceiptDate DATE
  DECLARE @SubmissionDate DATE
  DECLARE @AgencyCode VARCHAR(20)
  DECLARE @CustomerName NVARCHAR(100)
  DECLARE @SalesManagerID VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @DeliveryDate DATE
  DECLARE @DeliveryQty NUMERIC(20,2)
  DECLARE @ComplaintContent NVARCHAR(MAX)
  DECLARE @ComplaintImage VARBINARY(MAX)
  DECLARE @UseConditionContent NVARCHAR(MAX)
  DECLARE @MassSampleClassCode VARCHAR(20)
  DECLARE @LotNo VARCHAR(20)
  DECLARE @MarkingLetter VARCHAR(20)
  DECLARE @ApplicationName NVARCHAR(100)
  DECLARE @InputQty NUMERIC(20,2)
  DECLARE @DefectQty NUMERIC(20,2)
  DECLARE @IsCustomerComplaintsReport BIT
  DECLARE @ProcessingRequestDate DATE
  DECLARE @CustomerRequestContent NVARCHAR(MAX)
  DECLARE @CustomerRequestImage VARBINARY(MAX)
  DECLARE @SalesRequestContent NVARCHAR(MAX)
  DECLARE @SalesRequestImage VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CustomerComplaintsRequestInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCustomerComplaintsRequestNo,
									CustomerComplaintsRequestNo,
									ReceiptDate,
									SubmissionDate,
									AgencyCode,
									CustomerName,
									SalesManagerID,
									MaterialCode,
									DeliveryDate,
									DeliveryQty,
									ComplaintContent,
									dbo.fnBase64ToBinary(ComplaintImage) as ComplaintImage,
									UseConditionContent,
									MassSampleClassCode,
									LotNo,
									MarkingLetter,
									ApplicationName,
									InputQty,
									DefectQty,
									IsCustomerComplaintsReport,
									ProcessingRequestDate,
									CustomerRequestContent,
									dbo.fnBase64ToBinary(CustomerRequestImage) as CustomerRequestImage,
									SalesRequestContent,
									dbo.fnBase64ToBinary(SalesRequestImage) as SalesRequestImage,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCustomerComplaintsRequestNo VARCHAR(20),
											 CustomerComplaintsRequestNo VARCHAR(20),
											 ReceiptDate DATETIMEOFFSET,
											 SubmissionDate DATETIMEOFFSET,
											 AgencyCode VARCHAR(20),
											 CustomerName NVARCHAR(100),
											 SalesManagerID VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 DeliveryDate DATETIMEOFFSET,
											 DeliveryQty NUMERIC(20,2),
											 ComplaintContent NVARCHAR(MAX),
											 ComplaintImage NVARCHAR(MAX),
											 UseConditionContent NVARCHAR(MAX),
											 MassSampleClassCode VARCHAR(20),
											 LotNo VARCHAR(20),
											 MarkingLetter VARCHAR(20),
											 ApplicationName NVARCHAR(100),
											 InputQty NUMERIC(20,2),
											 DefectQty NUMERIC(20,2),
											 IsCustomerComplaintsReport BIT,
											 ProcessingRequestDate DATETIMEOFFSET,
											 CustomerRequestContent NVARCHAR(MAX),
											 CustomerRequestImage NVARCHAR(MAX),
											 SalesRequestContent NVARCHAR(MAX),
											 SalesRequestImage NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCustomerComplaintsRequestNo IS NULL THEN CustomerComplaintsRequestNo
										ELSE OldCustomerComplaintsRequestNo
									END AS OldCustomerComplaintsRequestNo,
									CustomerComplaintsRequestNo,
									ReceiptDate,
									SubmissionDate,
									AgencyCode,
									CustomerName,
									SalesManagerID,
									MaterialCode,
									DeliveryDate,
									DeliveryQty,
									ComplaintContent,
									dbo.fnBase64ToBinary(ComplaintImage) as ComplaintImage,
									UseConditionContent,
									MassSampleClassCode,
									LotNo,
									MarkingLetter,
									ApplicationName,
									InputQty,
									DefectQty,
									IsCustomerComplaintsReport,
									ProcessingRequestDate,
									CustomerRequestContent,
									dbo.fnBase64ToBinary(CustomerRequestImage) as CustomerRequestImage,
									SalesRequestContent,
									dbo.fnBase64ToBinary(SalesRequestImage) as SalesRequestImage,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCustomerComplaintsRequestNo VARCHAR(20),
											 CustomerComplaintsRequestNo VARCHAR(20),
											 ReceiptDate DATETIMEOFFSET,
											 SubmissionDate DATETIMEOFFSET,
											 AgencyCode VARCHAR(20),
											 CustomerName NVARCHAR(100),
											 SalesManagerID VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 DeliveryDate DATETIMEOFFSET,
											 DeliveryQty NUMERIC(20,2),
											 ComplaintContent NVARCHAR(MAX),
											 ComplaintImage NVARCHAR(MAX),
											 UseConditionContent NVARCHAR(MAX),
											 MassSampleClassCode VARCHAR(20),
											 LotNo VARCHAR(20),
											 MarkingLetter VARCHAR(20),
											 ApplicationName NVARCHAR(100),
											 InputQty NUMERIC(20,2),
											 DefectQty NUMERIC(20,2),
											 IsCustomerComplaintsReport BIT,
											 ProcessingRequestDate DATETIMEOFFSET,
											 CustomerRequestContent NVARCHAR(MAX),
											 CustomerRequestImage NVARCHAR(MAX),
											 SalesRequestContent NVARCHAR(MAX),
											 SalesRequestImage NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCustomerComplaintsRequestNo IS NULL THEN CustomerComplaintsRequestNo
										ELSE OldCustomerComplaintsRequestNo
									END AS OldCustomerComplaintsRequestNo,
									CustomerComplaintsRequestNo,
									ReceiptDate,
									SubmissionDate,
									AgencyCode,
									CustomerName,
									SalesManagerID,
									MaterialCode,
									DeliveryDate,
									DeliveryQty,
									ComplaintContent,
									dbo.fnBase64ToBinary(ComplaintImage) as ComplaintImage,
									UseConditionContent,
									MassSampleClassCode,
									LotNo,
									MarkingLetter,
									ApplicationName,
									InputQty,
									DefectQty,
									IsCustomerComplaintsReport,
									ProcessingRequestDate,
									CustomerRequestContent,
									dbo.fnBase64ToBinary(CustomerRequestImage) as CustomerRequestImage,
									SalesRequestContent,
									dbo.fnBase64ToBinary(SalesRequestImage) as SalesRequestImage,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCustomerComplaintsRequestNo VARCHAR(20),
											 CustomerComplaintsRequestNo VARCHAR(20),
											 ReceiptDate DATETIMEOFFSET,
											 SubmissionDate DATETIMEOFFSET,
											 AgencyCode VARCHAR(20),
											 CustomerName NVARCHAR(100),
											 SalesManagerID VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 DeliveryDate DATETIMEOFFSET,
											 DeliveryQty NUMERIC(20,2),
											 ComplaintContent NVARCHAR(MAX),
											 ComplaintImage NVARCHAR(MAX),
											 UseConditionContent NVARCHAR(MAX),
											 MassSampleClassCode VARCHAR(20),
											 LotNo VARCHAR(20),
											 MarkingLetter VARCHAR(20),
											 ApplicationName NVARCHAR(100),
											 InputQty NUMERIC(20,2),
											 DefectQty NUMERIC(20,2),
											 IsCustomerComplaintsReport BIT,
											 ProcessingRequestDate DATETIMEOFFSET,
											 CustomerRequestContent NVARCHAR(MAX),
											 CustomerRequestImage NVARCHAR(MAX),
											 SalesRequestContent NVARCHAR(MAX),
											 SalesRequestImage NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCustomerComplaintsRequestNo,
								 @CustomerComplaintsRequestNo,
								 @ReceiptDate,
								 @SubmissionDate,
								 @AgencyCode,
								 @CustomerName,
								 @SalesManagerID,
								 @MaterialCode,
								 @DeliveryDate,
								 @DeliveryQty,
								 @ComplaintContent,
								 @ComplaintImage,
								 @UseConditionContent,
								 @MassSampleClassCode,
								 @LotNo,
								 @MarkingLetter,
								 @ApplicationName,
								 @InputQty,
								 @DefectQty,
								 @IsCustomerComplaintsReport,
								 @ProcessingRequestDate,
								 @CustomerRequestContent,
								 @CustomerRequestImage,
								 @SalesRequestContent,
								 @SalesRequestImage,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CustomerComplaintsRequestInfo WHERE CustomerComplaintsRequestNo = @CustomerComplaintsRequestNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CustomerComplaintsRequestNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_CustomerComplaintsRequestInfo',@CustomerComplaintsRequestNo OUTPUT
                    END

                    INSERT INTO STB_CustomerComplaintsRequestInfo
						(
						    CustomerComplaintsRequestNo,
						    ReceiptDate,
						    SubmissionDate,
						    AgencyCode,
						    CustomerName,
						    SalesManagerID,
						    MaterialCode,
						    DeliveryDate,
						    DeliveryQty,
						    ComplaintContent,
						    ComplaintImage,
						    UseConditionContent,
						    MassSampleClassCode,
						    LotNo,
						    MarkingLetter,
						    ApplicationName,
						    InputQty,
						    DefectQty,
						    IsCustomerComplaintsReport,
						    ProcessingRequestDate,
						    CustomerRequestContent,
						    CustomerRequestImage,
						    SalesRequestContent,
						    SalesRequestImage,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CustomerComplaintsRequestNo,
						    @ReceiptDate,
						    @SubmissionDate,
						    @AgencyCode,
						    @CustomerName,
						    @SalesManagerID,
						    @MaterialCode,
						    @DeliveryDate,
						    @DeliveryQty,
						    @ComplaintContent,
						    @ComplaintImage,
						    @UseConditionContent,
						    @MassSampleClassCode,
						    @LotNo,
						    @MarkingLetter,
						    @ApplicationName,
						    @InputQty,
						    @DefectQty,
						    @IsCustomerComplaintsReport,
						    @ProcessingRequestDate,
						    @CustomerRequestContent,
						    @CustomerRequestImage,
						    @SalesRequestContent,
						    @SalesRequestImage,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CustomerComplaintsRequestInfo
						SET
						    ReceiptDate =   ISNULL(@ReceiptDate,ReceiptDate),
						    SubmissionDate =   ISNULL(@SubmissionDate,SubmissionDate),
						    AgencyCode =   ISNULL(@AgencyCode,AgencyCode),
						    CustomerName =   ISNULL(@CustomerName,CustomerName),
						    SalesManagerID =   ISNULL(@SalesManagerID,SalesManagerID),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    DeliveryDate =   ISNULL(@DeliveryDate,DeliveryDate),
						    DeliveryQty =   ISNULL(@DeliveryQty,DeliveryQty),
						    ComplaintContent =   ISNULL(@ComplaintContent,ComplaintContent),
						    ComplaintImage =   ISNULL(@ComplaintImage,ComplaintImage),
						    UseConditionContent =   ISNULL(@UseConditionContent,UseConditionContent),
						    MassSampleClassCode =   ISNULL(@MassSampleClassCode,MassSampleClassCode),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    MarkingLetter =   ISNULL(@MarkingLetter,MarkingLetter),
						    ApplicationName =   ISNULL(@ApplicationName,ApplicationName),
						    InputQty =   ISNULL(@InputQty,InputQty),
						    DefectQty =   ISNULL(@DefectQty,DefectQty),
						    IsCustomerComplaintsReport =   ISNULL(@IsCustomerComplaintsReport,IsCustomerComplaintsReport),
						    ProcessingRequestDate =   ISNULL(@ProcessingRequestDate,ProcessingRequestDate),
						    CustomerRequestContent =   ISNULL(@CustomerRequestContent,CustomerRequestContent),
						    CustomerRequestImage =   ISNULL(@CustomerRequestImage,CustomerRequestImage),
						    SalesRequestContent =   ISNULL(@SalesRequestContent,SalesRequestContent),
						    SalesRequestImage =   ISNULL(@SalesRequestImage,SalesRequestImage),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CustomerComplaintsRequestNo = @OldCustomerComplaintsRequestNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CustomerComplaintsRequestInfo
						WHERE
						    CustomerComplaintsRequestNo = @OldCustomerComplaintsRequestNo
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
