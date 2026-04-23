-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-18
-- Browsable : true
-- Group : 금형관리
-- Description:	금형수정수리이력 IUD
-- Modified:의신정밀->2018스마트공장
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldRepairHistory_iud]
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
    DECLARE @AllTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldRepairHistNo VARCHAR(20)
	DECLARE @RepairHistNo VARCHAR(20)
	DECLARE @MoldNumber VARCHAR(50)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @RepairType VARCHAR(1)
	DECLARE @ApprovalDate1 DATETIME
	DECLARE @ApprovalUser1 VARCHAR(20)
	DECLARE @ApprovalDate2 DATETIME
	DECLARE @ApprovalUser2 VARCHAR(20)
	DECLARE @ApprovalDate3 DATETIME
	DECLARE @ApprovalUser3 VARCHAR(20)
	DECLARE @ApprovalDate4 DATETIME
	DECLARE @ApprovalUser4 VARCHAR(20)
	DECLARE @MaterialType VARCHAR(50)
	DECLARE @ProductionWorkCenter VARCHAR(20)
	DECLARE @RequestWorkCenter VARCHAR(20)
	DECLARE @RequestUser VARCHAR(50)
	DECLARE @RequestDate DATE
	DECLARE @DemandDate DATE
	DECLARE @TotalProdQty INT
	DECLARE @DeliveryQty INT
	DECLARE @CauseImageID BIGINT
	DECLARE @CauseText VARCHAR(MAX)
	DECLARE @MeasureText VARCHAR(MAX)
	DECLARE @DevUser VARCHAR(50)
	DECLARE @GIDate DATE
	DECLARE @RepairTerm NUMERIC(5,2)
	DECLARE @GRDate DATE
	DECLARE @TestDate DATE
	DECLARE @RepairVendor VARCHAR(20)
	DECLARE @CompleteDate DATE
	DECLARE @CompleteCheckUser VARCHAR(20)
	DECLARE @StockProdQtyPerDay INT
	DECLARE @StockProdWorkCenter VARCHAR(20)
	DECLARE @StockWipQty INT
	DECLARE @StockTotalQty INT
	DECLARE @StockCompleteDate DATE
	DECLARE @ProblemText VARCHAR(MAX)
	DECLARE @EONO VARCHAR(50)
	DECLARE @EONOFileID BIGINT
	DECLARE @RepairText VARCHAR(MAX)
	DECLARE @Relations VARCHAR(MAX)
	DECLARE @IsComplete BIT
	DECLARE @EtcText VARCHAR(MAX)
	
	DECLARE @DocFileID BIGINT
	DECLARE @FileData VARBINARY(MAX)
	DECLARE @DocFileName NVARCHAR(MAX)
	
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	
	
	

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldRepairHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
	
    
	BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
                        'ALL' AS IUD_FLAG,
									OldRepairHistNo,
									RepairHistNo,
									MoldNumber,
									WorkCenterCode,
									RepairType,
									ApprovalDate1,
									ApprovalUser1,
									ApprovalDate2,
									ApprovalUser2,
									ApprovalDate3,
									ApprovalUser3,
									ApprovalDate4,
									ApprovalUser4,
									MaterialType,
									ProductionWorkCenter,
									RequestWorkCenter,
									RequestUser,
									RequestDate,
									DemandDate,
									TotalProdQty,
									DeliveryQty,
									CauseImageID,
									CauseText,
									MeasureText,
									DevUser,
									GIDate,
									RepairTerm,
									GRDate,
									TestDate,
									RepairVendor,
									CompleteDate,
									CompleteCheckUser,
									StockProdQtyPerDay,
									StockProdWorkCenter,
									StockWipQty,
									StockTotalQty,
									StockCompleteDate,
									ProblemText,
									EONO,
									EONOFileID,
									RepairText,
									Relations,
									IsComplete,
									EtcText,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @AllTableName , 2)
							        WITH  (
											 OldRepairHistNo VARCHAR(20),
											 RepairHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 WorkCenterCode VARCHAR(20),
											 RepairType VARCHAR(1),
											 ApprovalDate1 DATETIMEOFFSET,
											 ApprovalUser1 VARCHAR(20),
											 ApprovalDate2 DATETIMEOFFSET,
											 ApprovalUser2 VARCHAR(20),
											 ApprovalDate3 DATETIMEOFFSET,
											 ApprovalUser3 VARCHAR(20),
											 ApprovalDate4 DATETIMEOFFSET,
											 ApprovalUser4 VARCHAR(20),
											 MaterialType VARCHAR(50),
											 ProductionWorkCenter VARCHAR(20),
											 RequestWorkCenter VARCHAR(20),
											 RequestUser VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 DemandDate DATETIMEOFFSET,
											 TotalProdQty INT,
											 DeliveryQty INT,
											 CauseImageID BIGINT,
											 CauseText VARCHAR(MAX),
											 MeasureText VARCHAR(MAX),
											 DevUser VARCHAR(50),
											 GIDate DATETIMEOFFSET,
											 RepairTerm NUMERIC(5,2),
											 GRDate DATETIMEOFFSET,
											 TestDate DATETIMEOFFSET,
											 RepairVendor VARCHAR(20),
											 CompleteDate DATETIMEOFFSET,
											 CompleteCheckUser VARCHAR(20),
											 StockProdQtyPerDay INT,
											 StockProdWorkCenter VARCHAR(20),
											 StockWipQty INT,
											 StockTotalQty INT,
											 StockCompleteDate DATETIMEOFFSET,
											 ProblemText VARCHAR(MAX),
											 EONO VARCHAR(50),
											 EONOFileID BIGINT,
											 RepairText VARCHAR(MAX),
											 Relations VARCHAR(MAX),
											 IsComplete BIT,
											 EtcText VARCHAR(MAX),
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
				UNION ALL
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldRepairHistNo,
									RepairHistNo,
									MoldNumber,
									WorkCenterCode,
									RepairType,
									ApprovalDate1,
									ApprovalUser1,
									ApprovalDate2,
									ApprovalUser2,
									ApprovalDate3,
									ApprovalUser3,
									ApprovalDate4,
									ApprovalUser4,
									MaterialType,
									ProductionWorkCenter,
									RequestWorkCenter,
									RequestUser,
									RequestDate,
									DemandDate,
									TotalProdQty,
									DeliveryQty,
									CauseImageID,
									CauseText,
									MeasureText,
									DevUser,
									GIDate,
									RepairTerm,
									GRDate,
									TestDate,
									RepairVendor,
									CompleteDate,
									CompleteCheckUser,
									StockProdQtyPerDay,
									StockProdWorkCenter,
									StockWipQty,
									StockTotalQty,
									StockCompleteDate,
									ProblemText,
									EONO,
									EONOFileID,
									RepairText,
									Relations,
									IsComplete,
									EtcText,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRepairHistNo VARCHAR(20),
											 RepairHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 WorkCenterCode VARCHAR(20),
											 RepairType VARCHAR(1),
											 ApprovalDate1 DATETIMEOFFSET,
											 ApprovalUser1 VARCHAR(20),
											 ApprovalDate2 DATETIMEOFFSET,
											 ApprovalUser2 VARCHAR(20),
											 ApprovalDate3 DATETIMEOFFSET,
											 ApprovalUser3 VARCHAR(20),
											 ApprovalDate4 DATETIMEOFFSET,
											 ApprovalUser4 VARCHAR(20),
											 MaterialType VARCHAR(50),
											 ProductionWorkCenter VARCHAR(20),
											 RequestWorkCenter VARCHAR(20),
											 RequestUser VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 DemandDate DATETIMEOFFSET,
											 TotalProdQty INT,
											 DeliveryQty INT,
											 CauseImageID BIGINT,
											 CauseText VARCHAR(MAX),
											 MeasureText VARCHAR(MAX),
											 DevUser VARCHAR(50),
											 GIDate DATETIMEOFFSET,
											 RepairTerm NUMERIC(5,2),
											 GRDate DATETIMEOFFSET,
											 TestDate DATETIMEOFFSET,
											 RepairVendor VARCHAR(20),
											 CompleteDate DATETIMEOFFSET,
											 CompleteCheckUser VARCHAR(20),
											 StockProdQtyPerDay INT,
											 StockProdWorkCenter VARCHAR(20),
											 StockWipQty INT,
											 StockTotalQty INT,
											 StockCompleteDate DATETIMEOFFSET,
											 ProblemText VARCHAR(MAX),
											 EONO VARCHAR(50),
											 EONOFileID BIGINT,
											 RepairText VARCHAR(MAX),
											 Relations VARCHAR(MAX),
											 IsComplete BIT,
											 EtcText VARCHAR(MAX),
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRepairHistNo IS NULL THEN RepairHistNo
										ELSE OldRepairHistNo
									END AS OldRepairHistNo,
									RepairHistNo,
									MoldNumber,
									WorkCenterCode,
									RepairType,
									ApprovalDate1,
									ApprovalUser1,
									ApprovalDate2,
									ApprovalUser2,
									ApprovalDate3,
									ApprovalUser3,
									ApprovalDate4,
									ApprovalUser4,
									MaterialType,
									ProductionWorkCenter,
									RequestWorkCenter,
									RequestUser,
									RequestDate,
									DemandDate,
									TotalProdQty,
									DeliveryQty,
									CauseImageID,
									CauseText,
									MeasureText,
									DevUser,
									GIDate,
									RepairTerm,
									GRDate,
									TestDate,
									RepairVendor,
									CompleteDate,
									CompleteCheckUser,
									StockProdQtyPerDay,
									StockProdWorkCenter,
									StockWipQty,
									StockTotalQty,
									StockCompleteDate,
									ProblemText,
									EONO,
									EONOFileID,
									RepairText,
									Relations,
									IsComplete,
									EtcText,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRepairHistNo VARCHAR(20),
											 RepairHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 WorkCenterCode VARCHAR(20),
											 RepairType VARCHAR(1),
											 ApprovalDate1 DATETIMEOFFSET,
											 ApprovalUser1 VARCHAR(20),
											 ApprovalDate2 DATETIMEOFFSET,
											 ApprovalUser2 VARCHAR(20),
											 ApprovalDate3 DATETIMEOFFSET,
											 ApprovalUser3 VARCHAR(20),
											 ApprovalDate4 DATETIMEOFFSET,
											 ApprovalUser4 VARCHAR(20),
											 MaterialType VARCHAR(50),
											 ProductionWorkCenter VARCHAR(20),
											 RequestWorkCenter VARCHAR(20),
											 RequestUser VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 DemandDate DATETIMEOFFSET,
											 TotalProdQty INT,
											 DeliveryQty INT,
											 CauseImageID BIGINT,
											 CauseText VARCHAR(MAX),
											 MeasureText VARCHAR(MAX),
											 DevUser VARCHAR(50),
											 GIDate DATETIMEOFFSET,
											 RepairTerm NUMERIC(5,2),
											 GRDate DATETIMEOFFSET,
											 TestDate DATETIMEOFFSET,
											 RepairVendor VARCHAR(20),
											 CompleteDate DATETIMEOFFSET,
											 CompleteCheckUser VARCHAR(20),
											 StockProdQtyPerDay INT,
											 StockProdWorkCenter VARCHAR(20),
											 StockWipQty INT,
											 StockTotalQty INT,
											 StockCompleteDate DATETIMEOFFSET,
											 ProblemText VARCHAR(MAX),
											 EONO VARCHAR(50),
											 EONOFileID BIGINT,
											 RepairText VARCHAR(MAX),
											 Relations VARCHAR(MAX),
											 IsComplete BIT,
											 EtcText VARCHAR(MAX),
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRepairHistNo IS NULL THEN RepairHistNo
										ELSE OldRepairHistNo
									END AS OldRepairHistNo,
									RepairHistNo,
									MoldNumber,
									WorkCenterCode,
									RepairType,
									ApprovalDate1,
									ApprovalUser1,
									ApprovalDate2,
									ApprovalUser2,
									ApprovalDate3,
									ApprovalUser3,
									ApprovalDate4,
									ApprovalUser4,
									MaterialType,
									ProductionWorkCenter,
									RequestWorkCenter,
									RequestUser,
									RequestDate,
									DemandDate,
									TotalProdQty,
									DeliveryQty,
									CauseImageID,
									CauseText,
									MeasureText,
									DevUser,
									GIDate,
									RepairTerm,
									GRDate,
									TestDate,
									RepairVendor,
									CompleteDate,
									CompleteCheckUser,
									StockProdQtyPerDay,
									StockProdWorkCenter,
									StockWipQty,
									StockTotalQty,
									StockCompleteDate,
									ProblemText,
									EONO,
									EONOFileID,
									RepairText,
									Relations,
									IsComplete,
									EtcText,
									dbo.fnBase64ToBinary(FileData) as FileData,
									DocFileID,
									DocFileName,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRepairHistNo VARCHAR(20),
											 RepairHistNo VARCHAR(20),
											 MoldNumber VARCHAR(50),
											 WorkCenterCode VARCHAR(20),
											 RepairType VARCHAR(1),
											 ApprovalDate1 DATETIMEOFFSET,
											 ApprovalUser1 VARCHAR(20),
											 ApprovalDate2 DATETIMEOFFSET,
											 ApprovalUser2 VARCHAR(20),
											 ApprovalDate3 DATETIMEOFFSET,
											 ApprovalUser3 VARCHAR(20),
											 ApprovalDate4 DATETIMEOFFSET,
											 ApprovalUser4 VARCHAR(20),
											 MaterialType VARCHAR(50),
											 ProductionWorkCenter VARCHAR(20),
											 RequestWorkCenter VARCHAR(20),
											 RequestUser VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 DemandDate DATETIMEOFFSET,
											 TotalProdQty INT,
											 DeliveryQty INT,
											 CauseImageID BIGINT,
											 CauseText VARCHAR(MAX),
											 MeasureText VARCHAR(MAX),
											 DevUser VARCHAR(50),
											 GIDate DATETIMEOFFSET,
											 RepairTerm NUMERIC(5,2),
											 GRDate DATETIMEOFFSET,
											 TestDate DATETIMEOFFSET,
											 RepairVendor VARCHAR(20),
											 CompleteDate DATETIMEOFFSET,
											 CompleteCheckUser VARCHAR(20),
											 StockProdQtyPerDay INT,
											 StockProdWorkCenter VARCHAR(20),
											 StockWipQty INT,
											 StockTotalQty INT,
											 StockCompleteDate DATETIMEOFFSET,
											 ProblemText VARCHAR(MAX),
											 EONO VARCHAR(50),
											 EONOFileID BIGINT,
											 RepairText VARCHAR(MAX),
											 Relations VARCHAR(MAX),
											 IsComplete BIT,
											 EtcText VARCHAR(MAX),
											 FileData VARCHAR(MAX),
											 DocFileID BIGINT,
											 DocFileName NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRepairHistNo,
								 @RepairHistNo,
								 @MoldNumber,
								 @WorkCenterCode,
								 @RepairType,
								 @ApprovalDate1,
								 @ApprovalUser1,
								 @ApprovalDate2,
								 @ApprovalUser2,
								 @ApprovalDate3,
								 @ApprovalUser3,
								 @ApprovalDate4,
								 @ApprovalUser4,
								 @MaterialType,
								 @ProductionWorkCenter,
								 @RequestWorkCenter,
								 @RequestUser,
								 @RequestDate,
								 @DemandDate,
								 @TotalProdQty,
								 @DeliveryQty,
								 @CauseImageID,
								 @CauseText,
								 @MeasureText,
								 @DevUser,
								 @GIDate,
								 @RepairTerm,
								 @GRDate,
								 @TestDate,
								 @RepairVendor,
								 @CompleteDate,
								 @CompleteCheckUser,
								 @StockProdQtyPerDay,
								 @StockProdWorkCenter,
								 @StockWipQty,
								 @StockTotalQty,
								 @StockCompleteDate,
								 @ProblemText,
								 @EONO,
								 @EONOFileID,
								 @RepairText,
								 @Relations,
								 @IsComplete,
								 @EtcText,
								 @FileData,
								 @DocFileID,
								 @DocFileName,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

				
				
				
                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'ALL' BEGIN
					
					
					 EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldRepairHistory',
							@pFileContents = @FileData,
							@pFileName = @DocFileName,
							@pFileSize = NULL,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileID OUTPUT
					
                    UPDATE STB_MoldRepairHistory
						SET
						    RepairHistNo =   CASE
						                WHEN @RepairHistNo IS NOT NULL THEN @RepairHistNo
						                ELSE RepairHistNo
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    RepairType =   CASE
						                WHEN @RepairType IS NOT NULL THEN @RepairType
						                ELSE RepairType
						            END,
						    ApprovalDate1 =   CASE
						                WHEN @ApprovalDate1 IS NOT NULL THEN @ApprovalDate1
						                ELSE ApprovalDate1
						            END,
						    ApprovalUser1 =   CASE
						                WHEN @ApprovalUser1 IS NOT NULL THEN @ApprovalUser1
						                ELSE ApprovalUser1
						            END,
						    ApprovalDate2 =   CASE
						                WHEN @ApprovalDate2 IS NOT NULL THEN @ApprovalDate2
						                ELSE ApprovalDate2
						            END,
						    ApprovalUser2 =   CASE
						                WHEN @ApprovalUser2 IS NOT NULL THEN @ApprovalUser2
						                ELSE ApprovalUser2
						            END,
						    ApprovalDate3 =   CASE
						                WHEN @ApprovalDate3 IS NOT NULL THEN @ApprovalDate3
						                ELSE ApprovalDate3
						            END,
						    ApprovalUser3 =   CASE
						                WHEN @ApprovalUser3 IS NOT NULL THEN @ApprovalUser3
						                ELSE ApprovalUser3
						            END,
						    ApprovalDate4 =   CASE
						                WHEN @ApprovalDate4 IS NOT NULL THEN @ApprovalDate4
						                ELSE ApprovalDate4
						            END,
						    ApprovalUser4 =   CASE
						                WHEN @ApprovalUser4 IS NOT NULL THEN @ApprovalUser4
						                ELSE ApprovalUser4
						            END,
						    MaterialType =   CASE
						                WHEN @MaterialType IS NOT NULL THEN @MaterialType
						                ELSE MaterialType
						            END,
						    ProductionWorkCenter =   CASE
						                WHEN @ProductionWorkCenter IS NOT NULL THEN @ProductionWorkCenter
						                ELSE ProductionWorkCenter
						            END,
						    RequestWorkCenter =   CASE
						                WHEN @RequestWorkCenter IS NOT NULL THEN @RequestWorkCenter
						                ELSE RequestWorkCenter
						            END,
						    RequestUser =   CASE
						                WHEN @RequestUser IS NOT NULL THEN @RequestUser
						                ELSE RequestUser
						            END,
						    RequestDate =   CASE
						                WHEN @RequestDate IS NOT NULL THEN @RequestDate
						                ELSE RequestDate
						            END,
						    DemandDate =   CASE
						                WHEN @DemandDate IS NOT NULL THEN @DemandDate
						                ELSE DemandDate
						            END,
						    TotalProdQty =   CASE
						                WHEN @TotalProdQty IS NOT NULL THEN @TotalProdQty
						                ELSE TotalProdQty
						            END,
						    DeliveryQty =   CASE
						                WHEN @DeliveryQty IS NOT NULL THEN @DeliveryQty
						                ELSE DeliveryQty
						            END,
						    CauseImageID =   CASE
						                WHEN @CauseImageID IS NOT NULL THEN @CauseImageID
						                ELSE CauseImageID
						            END,
						    CauseText =   CASE
						                WHEN @CauseText IS NOT NULL THEN @CauseText
						                ELSE CauseText
						            END,
						    MeasureText =   CASE
						                WHEN @MeasureText IS NOT NULL THEN @MeasureText
						                ELSE MeasureText
						            END,
						    DevUser =   CASE
						                WHEN @DevUser IS NOT NULL THEN @DevUser
						                ELSE DevUser
						            END,
						    GIDate =   CASE
						                WHEN @GIDate IS NOT NULL THEN @GIDate
						                ELSE GIDate
						            END,
						    RepairTerm =   CASE
						                WHEN @RepairTerm IS NOT NULL THEN @RepairTerm
						                ELSE RepairTerm
						            END,
						    GRDate =   CASE
						                WHEN @GRDate IS NOT NULL THEN @GRDate
						                ELSE GRDate
						            END,
						    TestDate =   CASE
						                WHEN @TestDate IS NOT NULL THEN @TestDate
						                ELSE TestDate
						            END,
						    RepairVendor =   CASE
						                WHEN @RepairVendor IS NOT NULL THEN @RepairVendor
						                ELSE RepairVendor
						            END,
						    CompleteDate =   CASE
						                WHEN @CompleteDate IS NOT NULL THEN @CompleteDate
						                ELSE CompleteDate
						            END,
						    CompleteCheckUser =   CASE
						                WHEN @CompleteCheckUser IS NOT NULL THEN @CompleteCheckUser
						                ELSE CompleteCheckUser
						            END,
						    StockProdQtyPerDay =   CASE
						                WHEN @StockProdQtyPerDay IS NOT NULL THEN @StockProdQtyPerDay
						                ELSE StockProdQtyPerDay
						            END,
						    StockProdWorkCenter =   CASE
						                WHEN @StockProdWorkCenter IS NOT NULL THEN @StockProdWorkCenter
						                ELSE StockProdWorkCenter
						            END,
						    StockWipQty =   CASE
						                WHEN @StockWipQty IS NOT NULL THEN @StockWipQty
						                ELSE StockWipQty
						            END,
						    StockTotalQty =   CASE
						                WHEN @StockTotalQty IS NOT NULL THEN @StockTotalQty
						                ELSE StockTotalQty
						            END,
						    StockCompleteDate =   CASE
						                WHEN @StockCompleteDate IS NOT NULL THEN @StockCompleteDate
						                ELSE StockCompleteDate
						            END,
						    ProblemText =   CASE
						                WHEN @ProblemText IS NOT NULL THEN @ProblemText
						                ELSE ProblemText
						            END,
						    EONO =   CASE
						                WHEN @EONO IS NOT NULL THEN @EONO
						                ELSE EONO
						            END,
						    EONOFileID =   CASE
						                WHEN @EONOFileID IS NOT NULL THEN @EONOFileID
						                ELSE EONOFileID
						            END,
						    RepairText =   CASE
						                WHEN @RepairText IS NOT NULL THEN @RepairText
						                ELSE RepairText
						            END,
						    Relations =   CASE
						                WHEN @Relations IS NOT NULL THEN @Relations
						                ELSE Relations
						            END,
						    IsComplete =   CASE
						                WHEN @IsComplete IS NOT NULL THEN @IsComplete
						                ELSE IsComplete
						            END,
						    EtcText =   CASE
						                WHEN @EtcText IS NOT NULL THEN @EtcText
						                ELSE EtcText
						            END,
						    DocFileID =   CASE
						                WHEN @DocFileID IS NOT NULL THEN @DocFileID
						                ELSE DocFileID
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
						    RepairHistNo = @OldRepairHistNo
				END
                ELSE IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldRepairHistory WHERE RepairHistNo = @RepairHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RepairHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldRepairHistory',
																	@RepairHistNo OUTPUT
                    END
                    
                    EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldRepairHistory',
							@pFileContents = @FileData,
							@pFileName = @DocFileName,
							@pFileSize = NULL,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileID OUTPUT

                    INSERT INTO STB_MoldRepairHistory
						(
						    RepairHistNo,
						    MoldNumber,
						    WorkCenterCode,
						    RepairType,
						    ApprovalDate1,
						    ApprovalUser1,
						    ApprovalDate2,
						    ApprovalUser2,
						    ApprovalDate3,
						    ApprovalUser3,
						    ApprovalDate4,
						    ApprovalUser4,
						    MaterialType,
						    ProductionWorkCenter,
						    RequestWorkCenter,
						    RequestUser,
						    RequestDate,
						    DemandDate,
						    TotalProdQty,
						    DeliveryQty,
						    CauseImageID,
						    CauseText,
						    MeasureText,
						    DevUser,
						    GIDate,
						    RepairTerm,
						    GRDate,
						    TestDate,
						    RepairVendor,
						    CompleteDate,
						    CompleteCheckUser,
						    StockProdQtyPerDay,
						    StockProdWorkCenter,
						    StockWipQty,
						    StockTotalQty,
						    StockCompleteDate,
						    ProblemText,
						    EONO,
						    EONOFileID,
						    RepairText,
						    Relations,
						    IsComplete,
						    EtcText,
						    DocFileID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @RepairHistNo,
						    @MoldNumber,
						    @WorkCenterCode,
						    @RepairType,
						    @ApprovalDate1,
						    @ApprovalUser1,
						    @ApprovalDate2,
						    @ApprovalUser2,
						    @ApprovalDate3,
						    @ApprovalUser3,
						    @ApprovalDate4,
						    @ApprovalUser4,
						    @MaterialType,
						    @ProductionWorkCenter,
						    @RequestWorkCenter,
						    @RequestUser,
						    @RequestDate,
						    @DemandDate,
						    @TotalProdQty,
						    @DeliveryQty,
						    @CauseImageID,
						    @CauseText,
						    @MeasureText,
						    @DevUser,
						    @GIDate,
						    @RepairTerm,
						    @GRDate,
						    @TestDate,
						    @RepairVendor,
						    @CompleteDate,
						    @CompleteCheckUser,
						    @StockProdQtyPerDay,
						    @StockProdWorkCenter,
						    @StockWipQty,
						    @StockTotalQty,
						    @StockCompleteDate,
						    @ProblemText,
						    @EONO,
						    @EONOFileID,
						    @RepairText,
						    @Relations,
						    @IsComplete,
						    @EtcText,
						    @DocFileID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
					 EXEC usp_DoSaveFile 
							@pSystemName = 'STB_MoldRepairHistory',
							@pFileContents = @FileData,
							@pFileName = @DocFileName,
							@pFileSize = NULL,
							@pUserID = @ProcessUserID,
							@pFileID = @DocFileID OUTPUT
					
                    UPDATE STB_MoldRepairHistory
						SET
						    RepairHistNo =   CASE
						                WHEN @RepairHistNo IS NOT NULL THEN @RepairHistNo
						                ELSE RepairHistNo
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    RepairType =   CASE
						                WHEN @RepairType IS NOT NULL THEN @RepairType
						                ELSE RepairType
						            END,
						    ApprovalDate1 =   CASE
						                WHEN @ApprovalDate1 IS NOT NULL THEN @ApprovalDate1
						                ELSE ApprovalDate1
						            END,
						    ApprovalUser1 =   CASE
						                WHEN @ApprovalUser1 IS NOT NULL THEN @ApprovalUser1
						                ELSE ApprovalUser1
						            END,
						    ApprovalDate2 =   CASE
						                WHEN @ApprovalDate2 IS NOT NULL THEN @ApprovalDate2
						                ELSE ApprovalDate2
						            END,
						    ApprovalUser2 =   CASE
						                WHEN @ApprovalUser2 IS NOT NULL THEN @ApprovalUser2
						                ELSE ApprovalUser2
						            END,
						    ApprovalDate3 =   CASE
						                WHEN @ApprovalDate3 IS NOT NULL THEN @ApprovalDate3
						                ELSE ApprovalDate3
						            END,
						    ApprovalUser3 =   CASE
						                WHEN @ApprovalUser3 IS NOT NULL THEN @ApprovalUser3
						                ELSE ApprovalUser3
						            END,
						    ApprovalDate4 =   CASE
						                WHEN @ApprovalDate4 IS NOT NULL THEN @ApprovalDate4
						                ELSE ApprovalDate4
						            END,
						    ApprovalUser4 =   CASE
						                WHEN @ApprovalUser4 IS NOT NULL THEN @ApprovalUser4
						                ELSE ApprovalUser4
						            END,
						    MaterialType =   CASE
						                WHEN @MaterialType IS NOT NULL THEN @MaterialType
						                ELSE MaterialType
						            END,
						    ProductionWorkCenter =   CASE
						                WHEN @ProductionWorkCenter IS NOT NULL THEN @ProductionWorkCenter
						                ELSE ProductionWorkCenter
						            END,
						    RequestWorkCenter =   CASE
						                WHEN @RequestWorkCenter IS NOT NULL THEN @RequestWorkCenter
						                ELSE RequestWorkCenter
						            END,
						    RequestUser =   CASE
						                WHEN @RequestUser IS NOT NULL THEN @RequestUser
						                ELSE RequestUser
						            END,
						    RequestDate =   CASE
						                WHEN @RequestDate IS NOT NULL THEN @RequestDate
						                ELSE RequestDate
						            END,
						    DemandDate =   CASE
						                WHEN @DemandDate IS NOT NULL THEN @DemandDate
						                ELSE DemandDate
						            END,
						    TotalProdQty =   CASE
						                WHEN @TotalProdQty IS NOT NULL THEN @TotalProdQty
						                ELSE TotalProdQty
						            END,
						    DeliveryQty =   CASE
						                WHEN @DeliveryQty IS NOT NULL THEN @DeliveryQty
						                ELSE DeliveryQty
						            END,
						    CauseImageID =   CASE
						                WHEN @CauseImageID IS NOT NULL THEN @CauseImageID
						                ELSE CauseImageID
						            END,
						    CauseText =   CASE
						                WHEN @CauseText IS NOT NULL THEN @CauseText
						                ELSE CauseText
						            END,
						    MeasureText =   CASE
						                WHEN @MeasureText IS NOT NULL THEN @MeasureText
						                ELSE MeasureText
						            END,
						    DevUser =   CASE
						                WHEN @DevUser IS NOT NULL THEN @DevUser
						                ELSE DevUser
						            END,
						    GIDate =   CASE
						                WHEN @GIDate IS NOT NULL THEN @GIDate
						                ELSE GIDate
						            END,
						    RepairTerm =   CASE
						                WHEN @RepairTerm IS NOT NULL THEN @RepairTerm
						                ELSE RepairTerm
						            END,
						    GRDate =   CASE
						                WHEN @GRDate IS NOT NULL THEN @GRDate
						                ELSE GRDate
						            END,
						    TestDate =   CASE
						                WHEN @TestDate IS NOT NULL THEN @TestDate
						                ELSE TestDate
						            END,
						    RepairVendor =   CASE
						                WHEN @RepairVendor IS NOT NULL THEN @RepairVendor
						                ELSE RepairVendor
						            END,
						    CompleteDate =   CASE
						                WHEN @CompleteDate IS NOT NULL THEN @CompleteDate
						                ELSE CompleteDate
						            END,
						    CompleteCheckUser =   CASE
						                WHEN @CompleteCheckUser IS NOT NULL THEN @CompleteCheckUser
						                ELSE CompleteCheckUser
						            END,
						    StockProdQtyPerDay =   CASE
						                WHEN @StockProdQtyPerDay IS NOT NULL THEN @StockProdQtyPerDay
						                ELSE StockProdQtyPerDay
						            END,
						    StockProdWorkCenter =   CASE
						                WHEN @StockProdWorkCenter IS NOT NULL THEN @StockProdWorkCenter
						                ELSE StockProdWorkCenter
						            END,
						    StockWipQty =   CASE
						                WHEN @StockWipQty IS NOT NULL THEN @StockWipQty
						                ELSE StockWipQty
						            END,
						    StockTotalQty =   CASE
						                WHEN @StockTotalQty IS NOT NULL THEN @StockTotalQty
						                ELSE StockTotalQty
						            END,
						    StockCompleteDate =   CASE
						                WHEN @StockCompleteDate IS NOT NULL THEN @StockCompleteDate
						                ELSE StockCompleteDate
						            END,
						    ProblemText =   CASE
						                WHEN @ProblemText IS NOT NULL THEN @ProblemText
						                ELSE ProblemText
						            END,
						    EONO =   CASE
						                WHEN @EONO IS NOT NULL THEN @EONO
						                ELSE EONO
						            END,
						    EONOFileID =   CASE
						                WHEN @EONOFileID IS NOT NULL THEN @EONOFileID
						                ELSE EONOFileID
						            END,
						    RepairText =   CASE
						                WHEN @RepairText IS NOT NULL THEN @RepairText
						                ELSE RepairText
						            END,
						    Relations =   CASE
						                WHEN @Relations IS NOT NULL THEN @Relations
						                ELSE Relations
						            END,
						    IsComplete =   CASE
						                WHEN @IsComplete IS NOT NULL THEN @IsComplete
						                ELSE IsComplete
						            END,
						    EtcText =   CASE
						                WHEN @EtcText IS NOT NULL THEN @EtcText
						                ELSE EtcText
						            END,
						    DocFileID =   CASE
						                WHEN @DocFileID IS NOT NULL THEN @DocFileID
						                ELSE DocFileID
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
						    RepairHistNo = @OldRepairHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldRepairHistory
						WHERE
						    RepairHistNo = @RepairHistNo
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

