
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-20
-- Browsable : true
-- Group : 자재수불관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocDetail_iud]
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
  DECLARE @OldMaterialDocDetailNo VARCHAR(20)
  DECLARE @MaterialDocDetailNo VARCHAR(20)
  DECLARE @MaterialDocNo VARCHAR(20)
  DECLARE @OrderDetailNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @MaterialStockAttribute VARCHAR(20)

  DECLARE @ManufacturerCode VARCHAR(20)		-- update 2026-04-15 for Bac Giang 2 factory
  DECLARE @WeekCode VARCHAR(10)
  DECLARE @RevisionsVer	NVARCHAR(30)

  DECLARE @StockAttrib1 VARCHAR(20)
  DECLARE @StockAttrib2 VARCHAR(20)
  DECLARE @StockAttrib3 VARCHAR(20)
  DECLARE @RequestQty NUMERIC(20,5)
  DECLARE @AllowQty NUMERIC(20,5)
  DECLARE @PickingAssignQty NUMERIC(20,5)
  DECLARE @PickingQty NUMERIC(20,5)
  DECLARE @ProcessFixQty NUMERIC(20,5)
  DECLARE @UnitPriceQty NUMERIC(20,5)
  DECLARE @UnitPrice NUMERIC(20,5)
  DEClARE @InspectionType VARCHAR(10)
  DECLARE @MaterialIqcNo VARCHAR(20)
  DECLARE @BefMaterialStockAttribute VARCHAR(20)
  DECLARE @VendorLotNo VARCHAR(100)
  DECLARE @MRMDExtText01 NVARCHAR(MAX)
  DECLARE @MRMDExtText02 NVARCHAR(MAX)
  DECLARE @MRMDExtText03 NVARCHAR(MAX)
  DECLARE @MRMDExtText04 NVARCHAR(MAX)
  DECLARE @MRMDExtText05 NVARCHAR(MAX)
  DECLARE @MDDErpRefText01 NVARCHAR(50)
  DECLARE @MDDErpRefText02 NVARCHAR(50)
  DECLARE @MDDErpRefText03 NVARCHAR(50)
  DECLARE @MDDErpRefText04 NVARCHAR(50)
  DECLARE @MDDErpRefText05 NVARCHAR(50)
  DECLARE @MDDErpRefText06 NVARCHAR(50)
  DECLARE @MDDErpRefText07 NVARCHAR(50)
  DECLARE @MDDErpRefText08 NVARCHAR(50)
  DECLARE @MDDErpRefText09 NVARCHAR(50)
  DECLARE @MDDErpRefText10 NVARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @LineCode NVARCHAR(50)
  DECLARE @ImportLine NVARCHAR(50)
  DECLARE @MRMDExtText06 NVARCHAR(50)
  
  DECLARE @DocStatus VARCHAR(20)
  DECLARE @IsCancel BIT
  DECLARE @WorkCenterCode VARCHAR(20)

  -- Add Column ManufacturerPartNumber NVARCHAR(500)
  Declare @ManufacturerPartNumber NVARCHAR(500)

	DECLARE @UID_KEY VARCHAR(50)
	DECLARE @MaterialDocTypeCode VARCHAR(20)
	DECLARE @MaterialDocType VARCHAR(10)
	DECLARE @IsRequireQC BIT
	DECLARE @CustomerCode VARCHAR(20)
	DECLARE @BefRequestQty NUMERIC(20,5)
	DECLARE @BefAllowQty NUMERIC(20,5)
	DECLARE @BefPickingAssignQty NUMERIC(20,5)
	-- 2016-08-28 Kim Han Young(hykim@awoo.co.kr)
	-- 생산자재불출(MV_WH_ROUTE)의 경우 STB_ProdPlanBom 에 요청수량(RequestQty) 를 업데이트 하기 위한 생산계획번호
	DECLARE @FPMainPlanNo VARCHAR(20)

	DECLARE @AUTOFIXQTY_GI VARCHAR(1)
	DECLARE @AUTOFIXQTY_GR VARCHAR(1)
	-- 2016-08-28 Kim Han Young(hykim@awoo.co.kr)
	-- 입하수량을 요청수량으로 자동입력할 지 여부
	DECLARE @AUTOARRIVALQTY_GR VARCHAR(1)

	Declare @MDDExtBit01 BIT -- 개발품여부
	Declare @MDDExtBit02 BIT -- 국책여부

	Declare @Grade VARCHAR(10)

	Declare @IsBOM INT

	-- CoC 체크여부
	Declare @IsCheckCoc BIT

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialDocDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
	-- 기본 설정에 관계없이 아래와 같이 처리. 단 Key관련 정보는 받아온거 사용 -- PJS
	SET @IsAutoKey = 1
	SET @IsLoopIUD = 1

	SET @AUTOFIXQTY_GI = dbo.fnGetProcessRule('SALES_GI_ITEM_FIXQTY', 'Y')
	SET @AUTOFIXQTY_GR = dbo.fnGetProcessRule('SALES_GR_ITEM_FIXQTY', 'Y')	
	SET @AUTOARRIVALQTY_GR = dbo.fnGetProcessRule('SALES_GR_ITEM_ARRIVALQTY', 'Y')
	
 
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldMaterialDocDetailNo,
								MaterialDocDetailNo,
								MaterialDocNo,
								OrderDetailNo,
								MaterialCode,
								MaterialStockAttribute,
								ManufacturerCode,
								WeekCode,
								RevisionsVer,
								ISNULL(StockAttrib1,'') AS StockAttrib1,
								ISNULL(StockAttrib2,'') AS StockAttrib2,
								ISNULL(StockAttrib3,'') AS StockAttrib3,
								RequestQty,
								AllowQty,
								PickingAssignQty,
								PickingQty,
								ProcessFixQty,
								UnitPriceQty,
								UnitPrice,
								InspectionType,
								MaterialIqcNo,
								BefMaterialStockAttribute,
								VendorLotNo,
								MRMDExtText01,
								MRMDExtText02,
								MRMDExtText03,
								MRMDExtText04,
								MRMDExtText05,
								MDDErpRefText01,
								MDDErpRefText02,
								MDDErpRefText03,
								MDDErpRefText04,
								MDDErpRefText05,
								MDDErpRefText06,
								MDDErpRefText07,
								MDDErpRefText08,
								MDDErpRefText09,
								MDDErpRefText10,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								LineCode,
								ImportLine,
								MRMDExtText06,
								MDDExtBit01,
								MDDExtBit02,
								ManufacturerPartNumber,
								Grade,
								IsCheckCoc
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
						        WITH  (
										 OldMaterialDocDetailNo VARCHAR(20),
										 MaterialDocDetailNo VARCHAR(20),
										 MaterialDocNo VARCHAR(20),
										 OrderDetailNo VARCHAR(20),
										 MaterialCode VARCHAR(50),
										 MaterialStockAttribute VARCHAR(20),
										 ManufacturerCode VARCHAR(20),
										 WeekCode VARCHAR(10),
										 RevisionsVer	NVARCHAR(30),
										 StockAttrib1 VARCHAR(20),
										 StockAttrib2 VARCHAR(20),
										 StockAttrib3 VARCHAR(20),
										 RequestQty NUMERIC(20,5),
										 AllowQty NUMERIC(20,5),
										 PickingAssignQty NUMERIC(20,5),
										 PickingQty NUMERIC(20,5),
										 ProcessFixQty NUMERIC(20,5),
										 UnitPriceQty NUMERIC(20,5),
										 UnitPrice NUMERIC(20,5),
										 InspectionType VARCHAR(10),
										 MaterialIqcNo VARCHAR(20),
										 BefMaterialStockAttribute VARCHAR(20),
										 VendorLotNo VARCHAR(100),
										 MRMDExtText01 NVARCHAR(MAX),
										 MRMDExtText02 NVARCHAR(MAX),
										 MRMDExtText03 NVARCHAR(MAX),
										 MRMDExtText04 NVARCHAR(MAX),
										 MRMDExtText05 NVARCHAR(MAX),
										 MDDErpRefText01 NVARCHAR(50),
										 MDDErpRefText02 NVARCHAR(50),
										 MDDErpRefText03 NVARCHAR(50),
										 MDDErpRefText04 NVARCHAR(50),
										 MDDErpRefText05 NVARCHAR(50),
										 MDDErpRefText06 NVARCHAR(50),
										 MDDErpRefText07 NVARCHAR(50),
										 MDDErpRefText08 NVARCHAR(50),
										 MDDErpRefText09 NVARCHAR(50),
										 MDDErpRefText10 NVARCHAR(50),
										 CreateDateTime DATETIMEOFFSET,
										 CreateUserID VARCHAR(20),
										 ChangeDateTime DATETIMEOFFSET,
										 ChangeUserID VARCHAR(20),
										 LineCode NVARCHAR(50),
										 ImportLine NVARCHAR(50),
										 MRMDExtText06 NVARCHAR(50),
										 MDDExtBit01 BIT,
										 MDDExtBit02 BIT,
										 ManufacturerPartNumber NVARCHAR(500),
										 Grade VARCHAR(10),
										 IsCheckCoc BIT
										)
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldMaterialDocDetailNo IS NULL THEN MaterialDocDetailNo
									ELSE OldMaterialDocDetailNo
								END AS OldMaterialDocDetailNo,
								MaterialDocDetailNo,
								MaterialDocNo,
								OrderDetailNo,
								MaterialCode,
								MaterialStockAttribute,
								ManufacturerCode,
								WeekCode,
								RevisionsVer,
								ISNULL(StockAttrib1,'') AS StockAttrib1,
								ISNULL(StockAttrib2,'') AS StockAttrib2,
								ISNULL(StockAttrib3,'') AS StockAttrib3,
								RequestQty,
								AllowQty,
								PickingAssignQty,
								PickingQty,
								ProcessFixQty,
								UnitPriceQty,
								UnitPrice,
								InspectionType,
								MaterialIqcNo,
								BefMaterialStockAttribute,
								VendorLotNo,
								MRMDExtText01,
								MRMDExtText02,
								MRMDExtText03,
								MRMDExtText04,
								MRMDExtText05,
								MDDErpRefText01,
								MDDErpRefText02,
								MDDErpRefText03,
								MDDErpRefText04,
								MDDErpRefText05,
								MDDErpRefText06,
								MDDErpRefText07,
								MDDErpRefText08,
								MDDErpRefText09,
								MDDErpRefText10,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								LineCode,
								ImportLine,
								MRMDExtText06,
								MDDExtBit01,
								MDDExtBit02,
								ManufacturerPartNumber,
								Grade,
								IsCheckCoc
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
						        WITH  (
										 OldMaterialDocDetailNo VARCHAR(20),
										 MaterialDocDetailNo VARCHAR(20),
										 MaterialDocNo VARCHAR(20),
										 OrderDetailNo VARCHAR(20),
										 MaterialCode VARCHAR(50),
										 MaterialStockAttribute VARCHAR(20),
										 ManufacturerCode VARCHAR(20),
										 WeekCode VARCHAR(10),
										 RevisionsVer	NVARCHAR(30),
										 StockAttrib1 VARCHAR(20),
										 StockAttrib2 VARCHAR(20),
										 StockAttrib3 VARCHAR(20),
										 RequestQty NUMERIC(20,5),
										 AllowQty NUMERIC(20,5),
										 PickingAssignQty NUMERIC(20,5),
										 PickingQty NUMERIC(20,5),
										 ProcessFixQty NUMERIC(20,5),
										 UnitPriceQty NUMERIC(20,5),
										 UnitPrice NUMERIC(20,5),
										 InspectionType VARCHAR(10),
										 MaterialIqcNo VARCHAR(20),
										 BefMaterialStockAttribute VARCHAR(20),
										 VendorLotNo VARCHAR(100),
										 MRMDExtText01 NVARCHAR(MAX),
										 MRMDExtText02 NVARCHAR(MAX),
										 MRMDExtText03 NVARCHAR(MAX),
										 MRMDExtText04 NVARCHAR(MAX),
										 MRMDExtText05 NVARCHAR(MAX),
										 MDDErpRefText01 NVARCHAR(50),
										 MDDErpRefText02 NVARCHAR(50),
										 MDDErpRefText03 NVARCHAR(50),
										 MDDErpRefText04 NVARCHAR(50),
										 MDDErpRefText05 NVARCHAR(50),
										 MDDErpRefText06 NVARCHAR(50),
										 MDDErpRefText07 NVARCHAR(50),
										 MDDErpRefText08 NVARCHAR(50),
										 MDDErpRefText09 NVARCHAR(50),
										 MDDErpRefText10 NVARCHAR(50),
										 CreateDateTime DATETIMEOFFSET,
										 CreateUserID VARCHAR(20),
										 ChangeDateTime DATETIMEOFFSET,
										 ChangeUserID VARCHAR(20),
										 LineCode NVARCHAR(50),
										 ImportLine NVARCHAR(50),
										 MRMDExtText06 NVARCHAR(50),
										 MDDExtBit01 BIT,
										 MDDExtBit02 BIT,
										 ManufacturerPartNumber NVARCHAR(500),
										 Grade VARCHAR(10),
										 IsCheckCoc BIT
										)
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN OldMaterialDocDetailNo IS NULL THEN MaterialDocDetailNo
									ELSE OldMaterialDocDetailNo
								END AS OldMaterialDocDetailNo,
								MaterialDocDetailNo,
								MaterialDocNo,
								OrderDetailNo,
								MaterialCode,
								MaterialStockAttribute,
								ManufacturerCode,
								WeekCode,
								RevisionsVer,
								ISNULL(StockAttrib1,'') AS StockAttrib1,
								ISNULL(StockAttrib2,'') AS StockAttrib2,
								ISNULL(StockAttrib3,'') AS StockAttrib3,
								RequestQty,
								AllowQty,
								PickingAssignQty,
								PickingQty,
								ProcessFixQty,
								UnitPriceQty,
								UnitPrice,
								InspectionType,
								MaterialIqcNo,
								BefMaterialStockAttribute,
								VendorLotNo,
								MRMDExtText01,
								MRMDExtText02,
								MRMDExtText03,
								MRMDExtText04,
								MRMDExtText05,
								MDDErpRefText01,
								MDDErpRefText02,
								MDDErpRefText03,
								MDDErpRefText04,
								MDDErpRefText05,
								MDDErpRefText06,
								MDDErpRefText07,
								MDDErpRefText08,
								MDDErpRefText09,
								MDDErpRefText10,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								LineCode,
								ImportLine,
								MRMDExtText06,
								MDDExtBit01,
								MDDExtBit02,
								ManufacturerPartNumber,
								Grade,
								IsCheckCoc
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
						        WITH  (
										 OldMaterialDocDetailNo VARCHAR(20),
										 MaterialDocDetailNo VARCHAR(20),
										 MaterialDocNo VARCHAR(20),
										 OrderDetailNo VARCHAR(20),
										 MaterialCode VARCHAR(50),
										 MaterialStockAttribute VARCHAR(20),
										 ManufacturerCode VARCHAR(20),
										 WeekCode VARCHAR(10),
										 RevisionsVer	NVARCHAR(30),
										 StockAttrib1 VARCHAR(20),
										 StockAttrib2 VARCHAR(20),
										 StockAttrib3 VARCHAR(20),
										 RequestQty NUMERIC(20,5),
										 AllowQty NUMERIC(20,5),
										 PickingAssignQty NUMERIC(20,5),
										 PickingQty NUMERIC(20,5),
										 ProcessFixQty NUMERIC(20,5),
										 UnitPriceQty NUMERIC(20,5),
										 UnitPrice NUMERIC(20,5),
										 InspectionType VARCHAR(10),
										 MaterialIqcNo VARCHAR(20),
										 BefMaterialStockAttribute VARCHAR(20),
										 VendorLotNo VARCHAR(100),
										 MRMDExtText01 NVARCHAR(MAX),
										 MRMDExtText02 NVARCHAR(MAX),
										 MRMDExtText03 NVARCHAR(MAX),
										 MRMDExtText04 NVARCHAR(MAX),
										 MRMDExtText05 NVARCHAR(MAX),
										 MDDErpRefText01 NVARCHAR(50),
										 MDDErpRefText02 NVARCHAR(50),
										 MDDErpRefText03 NVARCHAR(50),
										 MDDErpRefText04 NVARCHAR(50),
										 MDDErpRefText05 NVARCHAR(50),
										 MDDErpRefText06 NVARCHAR(50),
										 MDDErpRefText07 NVARCHAR(50),
										 MDDErpRefText08 NVARCHAR(50),
										 MDDErpRefText09 NVARCHAR(50),
										 MDDErpRefText10 NVARCHAR(50),
										 CreateDateTime DATETIMEOFFSET,
										 CreateUserID VARCHAR(20),
										 ChangeDateTime DATETIMEOFFSET,
										 ChangeUserID VARCHAR(20),
										 LineCode NVARCHAR(50),
										  ImportLine NVARCHAR(50),
										 MRMDExtText06 NVARCHAR(50),
										 MDDExtBit01 BIT,
										 MDDExtBit02 BIT,
										 ManufacturerPartNumber NVARCHAR(500),
										 Grade VARCHAR(10),
										 IsCheckCoc BIT
										) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
							 @IUD_FLAG,
							 @OldMaterialDocDetailNo,
							 @MaterialDocDetailNo,
							 @MaterialDocNo,
							 @OrderDetailNo,
							 @MaterialCode,
							 @MaterialStockAttribute,
							 @ManufacturerCode,
							 @WeekCode,
							 @RevisionsVer,
							 @StockAttrib1,
							 @StockAttrib2,
							 @StockAttrib3,
							 @RequestQty,
							 @AllowQty,
							 @PickingAssignQty,
							 @PickingQty,
							 @ProcessFixQty,
							 @UnitPriceQty,
							 @UnitPrice,
							 @InspectionType,
							 @MaterialIqcNo,
							 @BefMaterialStockAttribute,
							 @VendorLotNo,
							 @MRMDExtText01,
							 @MRMDExtText02,
							 @MRMDExtText03,
							 @MRMDExtText04,
							 @MRMDExtText05,
							 @MDDErpRefText01,
							 @MDDErpRefText02,
							 @MDDErpRefText03,
							 @MDDErpRefText04,
							 @MDDErpRefText05,
							 @MDDErpRefText06,
							 @MDDErpRefText07,
							 @MDDErpRefText08,
							 @MDDErpRefText09,
							 @MDDErpRefText10,
							 @CreateDateTime,
							 @CreateUserID,
							 @ChangeDateTime,
							 @ChangeUserID,
							 @LineCode,
							 @ImportLine,
							 @MRMDExtText06,
							 @MDDExtBit01,
							 @MDDExtBit02,
							 @ManufacturerPartNumber,
							 @Grade,
							 @IsCheckCoc


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			IF ISNULL(@MaterialCode,'') <> ''
			BEGIN
				IF (
						SELECT
								COUNT(*)
						FROM
								STB_MaterialMaster MM WITH (NOLOCK)
						WHERE
								MM.MaterialCode = @MaterialCode
					) < 1
				BEGIN
						RAISERROR('존재하지 않는 자재코드 입니다. %s', 16, 1, @MaterialCode)
						RETURN
				END
			END

			IF EXISTS (SELECT 1 FROM STB_BomDetail_Revision WHERE ChildMaterialCode = @MaterialCode AND ValidTo <= GETDATE()) 
			BEGIN
				DECLARE @Message NVARCHAR(200);
				SET @Message = 'This raw material is flagged as "Do Not Input"' + CHAR(10) + + CHAR(10) + 'MaterialCode : ' + @MaterialCode+ CHAR(10) + + CHAR(10);
				RAISERROR(@Message, 16, 1);
				RETURN
			END

			-- Check MaterialCode in BOM (VVT_F4 only)
			SELECT @WorkCenterCode = WorkCenterCode
			  FROM STB_UserInfo
			 WHERE UserID = @pProcessUserID

			IF @WorkCenterCode = 'VVT_F4' BEGIN
				-- Nordex
				exec usp_CheckChildExistenceInBOM '', '', 'EDVTMD-246', @MaterialCode, @IsBOM OUTPUT

				-- If Nordex fail then Check Bloom
				IF @IsBOM = 0 BEGIN 
					exec usp_CheckChildExistenceInBOM '', '', 'EDVTSY-001', @MaterialCode, @IsBOM OUTPUT

					IF @IsBOM = 1 BEGIN
						-- 블룸 BOM에 속하는 원자재이면 추가적으로 3가지를 체크한다. 2026.07.10
						--exec usp_DoCheckBloomEnergyBOMInfo @pProcessLanguage, @pProcessUserID, @MaterialCode, 'Mfr', @ManufacturerCode
						exec usp_DoCheckBloomEnergyBOMInfo @pProcessLanguage, @pProcessUserID, @MaterialCode, 'MfrPartNo', @ManufacturerPartNumber
						exec usp_DoCheckBloomEnergyBOMInfo @pProcessLanguage, @pProcessUserID, @MaterialCode, 'Rev', @RevisionsVer
					END
				END

				-- Both fail
				IF @IsBOM = 0 BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage,'BloomEnergy 또는 Nordex와 관련된 원자재 품목이 아닙니다.'
					RETURN
				END
			END

			--IF @IUD_FLAG = 'INSERT' BEGIN
			--	SELECT
			--			@MaterialDocNo = KeyValue
			--	FROM
			--			#SEQUENCE_TABLE
			--	WHERE
			--			UID_KEY = @MaterialDocNo
			--END
			/*
			  Author:Mr.Triều
			  CreateDate:2026-06-19
			  Desc: Block save when OP/Employee missing select ManufactoreCode or VenderLot with Bắc Giang2
			*/

			--IF EXISTS(SELECT 1 FROM STB_MaterialDocInfo MDI WITH (NOLOCK)
			--	WHERE MDI.MaterialDocNo = @MaterialDocNo 
			--	  AND MDI.TargetWorkCenterCode = 'VVT_F4'  
			-- )
			-- BEGIN
			--    IF ISNULL(@VendorLotNo, '') = '' OR ISNULL(@ManufacturerCode, '') = ''
			--	BEGIN
			--	    DECLARE @ErrorMessage NVARCHAR(250);
			--		SET @ErrorMessage = N'Kho Bắc Giang2 bắt buộc phải nhập số Lot Vendor và Mã nhà sản xuất!' + CHAR(10) 
			--		                    + N'MaterialCode: ' + ISNULL(@MaterialCode, '') + CHAR(10)
			--		                    + N'Vui lòng kiểm tra lại VendorLotNo hoặc ManufacturerCode.';
			--		RAISERROR(@ErrorMessage, 16, 1);
			--		RETURN;
			--	END
			-- END


			IF ISNULL(@MaterialDocNo,'')  <> ''
			BEGIN
					IF  (LEN(@MaterialDocNo) = 36) OR (LEN(@MaterialDocNo) = 20)  --NEWID()로 따진 데이터로 생각함
					BEGIN
							SET @UID_KEY = @MaterialDocNo

							SET @MaterialDocNo = NULL
				
							IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
								SELECT 
										@MaterialDocNo = KeyValue
								FROM 
										#SEQUENCE_TABLE
								WHERE
										UID_KEY = @UID_KEY
				
								IF @MaterialDocNo IS NULL
								BEGIN
									SET @MaterialDocNo = @UID_KEY
								END
							END
					END
			END

			SELECT
					@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
					@CustomerCode = MDI.SourceCustomerCode,
					@MaterialDocType = MDI.MaterialDocType,
					@DocStatus = MDI.DocStatus,			--제품출고요청화면의 출고요청상세내역 삭제 기능 추가로 인해 (CREATE 상태에서만 디테일 삭제 가능) 2016-08-16 by jhpark
					-- 2016-08-28 Kim Han Young(hykim@awoo.co.kr)
					--생산자재불출(MV_WH_ROUTE)일 때 STB_ProdPlanBom 의 요청수량(RequestQty)를 업데이트 하기 위한 생산계획번호
					@FPMainPlanNo = MDI.FPItemWorkNo,
					@IsCancel = MDI.IsCancel	
			FROM
					STB_MaterialDocInfo MDI
			WHERE
					MDI.MaterialDocNo = @MaterialDocNo
					
			/******************************************************************************************/
			-- 2016-09-02 Kim Han Young(hykim@awoo.co.kr)
			-- 취소된 문서 수정 불가
			IF @IsCancel = 1 BEGIN
				RAISERROR('이미 취소된 문서입니다.',16,1)
				RETURN
			END
			/******************************************************************************************/
			-- Modify : 2016-08-20 Park Jong Seob
			-- 문서 상태가 Fix인 경우 수정하거나 삭제할 수 없음.
			--IF @DocStatus IN ('FIX')
			--BEGIN
			--		RAISERROR('확정 처리된 문서는 수정할 수 없습니다.: %s',16,1,@MaterialDocNo)
			--		RETURN
			--END
			
		


			IF (@AUTOFIXQTY_GI = 'Y') AND (@MaterialDocType IN ('GI', 'MOVE' ) AND (@IUD_FLAG = 'INSERT'))
			BEGIN
				SET @AllowQty = @RequestQty
			END

			IF @MaterialDocType = 'GR'
			BEGIN				
			--IF (@AUTOFIXQTY_GR = 'Y') AND (@MaterialDocType = 'GR' AND (@IUD_FLAG = 'INSERT'))
			--BEGIN
				SET @AllowQty = @RequestQty
			--END
			END


			select top 1 * from STB_MaterialDocDetail

			

            IF @IUD_FLAG = 'INSERT' BEGIN

                IF EXISTS (SELECT 1 FROM STB_MaterialDocDetail WHERE MaterialDocDetailNo = @MaterialDocDetailNo) BEGIN
					RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialDocDetailNo)
					RETURN
				END

				-- 2016-08-28 Kim Han Young(hykim@awoo.co.kr)
				-- 입하수량(PickingAssignQty)를 납품요청수량으로 자동처리
				IF (@AUTOARRIVALQTY_GR = 'Y') AND (@MaterialDocType = 'GR')
				BEGIN
					SET @PickingAssignQty = @RequestQty
				END

				IF ISNULL(@MaterialDocDetailNo,'') = ''
				BEGIN
						IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocDetail', @MaterialDocDetailNo OUTPUT
					
							IF OBJECT_ID(N'tempdb..#SEQUENCE_TABLE', N'U') IS NOT NULL BEGIN
								INSERT INTO #SEQUENCE_TABLE
									(KeyValue, UID_KEY)
								VALUES
									(@MaterialDocDetailNo, @OldMaterialDocDetailNo)
							END
						END
				END
                
				-- 임시 SEQUENCE TABLE 사용 버젼

				--IF ISNULL(@MaterialDocNo,'')  <> ''
				--BEGIN
				--		IF  (LEN(@MaterialDocNo) = 36) OR (LEN(@MaterialDocNo) = 20)  --NEWID()로 따진 데이터로 생각함
				--		BEGIN
				--				SET @UID_KEY = @MaterialDocNo

				--				SET @MaterialDocNo = NULL
				
				--				SELECT 
				--						@MaterialDocNo = KeyValue
				--				FROM 
				--						#SEQUENCE_TABLE
				--				WHERE
				--						UID_KEY = @UID_KEY
				
				--				IF @MaterialDocNo IS NULL
				--				BEGIN
				--					SET @MaterialDocNo = @UID_KEY
				--				END
				--		END
				--END
				
				-- IQC 관련 처리
				-- 
				SELECT
						@MaterialDocTypeCode = MDI.MaterialDocTypeCode,
						@CustomerCode = MDI.SourceCustomerCode
				FROM
						STB_MaterialDocInfo MDI
				WHERE
						MDI.MaterialDocNo = @MaterialDocNo
						
				SELECT
						--@MaterialDocType = MDT.MaterialDocType,
						@IsRequireQC = MDT.IsRequireQC
				FROM
						STB_MaterialDocType MDT
				WHERE
						MDT.MaterialDocTypeCode = @MaterialDocTypeCode
						
				
				IF @IsRequireQC IS NULL
				BEGIN
					SET @IsRequireQC = 0
				END
				
				SET @InspectionType = 'NONE'
				
				IF @IsRequireQC = 1
				BEGIN
						SELECT
								TOP 1
								@InspectionType = MVM.InspectionType
						FROM
								STB_MaterialVendorMapping MVM
						WHERE
								MVM.MaterialCode = @MaterialCode AND
								( (ISNULL(MVM.CustomerCode,'') = '') OR (ISNULL(MVM.CustomerCode,'') = @CustomerCode))
						ORDER BY 
								MVM.CustomerCode DESC
								
						IF @InspectionType IS NULL
						BEGIN
								SET @InspectionType = 'NONE'
						END
				END


				IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
					IF @MaterialDocType = 'GR' BEGIN
					
						UPDATE
								STB_MaterialOrderItem
						SET
								MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) - @AllowQty,
								ChangeDateTime =  GETDATE(),
								ChangeUserID = @ProcessUserID
						WHERE
								MaterialOrderItemNo = @OrderDetailNo
					END
				
					IF @MaterialDocType = 'GI' BEGIN
						IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
							UPDATE
									STB_SalesOrderItem
							SET
									GIPlanQty = GIPlanQty + @RequestQty,
									ChangeDateTime =  GETDATE(),
									ChangeUserID = @ProcessUserID
							WHERE
									SOISequence = @OrderDetailNo
						END
					END
				END
					
                INSERT INTO STB_MaterialDocDetail
					(
					    MaterialDocDetailNo,
					    MaterialDocNo,
					    OrderDetailNo,
					    MaterialCode,
					    MaterialStockAttribute,
						ManufacturerCode,
						WeekCode,
						RevisionsVer,
					    StockAttrib1,
					    StockAttrib2,
					    StockAttrib3,
					    RequestQty,
					    AllowQty,
					    PickingAssignQty,
					    PickingQty,
					    ProcessFixQty,
					    UnitPriceQty,
					    UnitPrice,
						InspectionType,
					    MaterialIqcNo,
						BefMaterialStockAttribute,
						VendorLotNo,
					    MRMDExtText01,
					    MRMDExtText02,
					    MRMDExtText03,
					    MRMDExtText04,
					    MRMDExtText05,
						MDDErpRefText01,
						MDDErpRefText02,
						MDDErpRefText03,
						MDDErpRefText04,
						MDDErpRefText05,
						MDDErpRefText06,
						MDDErpRefText07,
						MDDErpRefText08,
						MDDErpRefText09,
						MDDErpRefText10,
					    CreateDateTime,
					    CreateUserID,
					    ChangeDateTime,
					    ChangeUserID,
						--Line,
						Line,
						MRMDExtText06,
						MDDExtBit01,
						MDDExtBit02,
						ManufacturerPartNumber,
						Grade,
						IsCheckCoc
					)
					VALUES
					(
					    @MaterialDocDetailNo,
					    @MaterialDocNo,
					    @OrderDetailNo,
					    @MaterialCode,
					    @MaterialStockAttribute,
						@ManufacturerCode,
						@WeekCode,
						@RevisionsVer,
					    ISNULL(@StockAttrib1,''),
						ISNULL(@StockAttrib2,''),
						ISNULL(@StockAttrib3,''),
					    ISNULL(@RequestQty,@PickingAssignQty),	-- 요청없는 입고의 경우 입하수량만 입력할 수 있다
					    ISNULL(@AllowQty,@PickingAssignQty),	-- 요청없는 입고의 경우 입하수량만 입력할 수 있다.
					    @PickingAssignQty,	-- 입하수량
					    @PickingQty,
					    @ProcessFixQty,
					    @UnitPriceQty,
					    @UnitPrice,
						@InspectionType,
					    @MaterialIqcNo,
						@BefMaterialStockAttribute,
						@VendorLotNo,
					    @MRMDExtText01,
					    @MRMDExtText02,
					    @MRMDExtText03,
					    @MRMDExtText04,
					    @MRMDExtText05,
						@MDDErpRefText01,
						@MDDErpRefText02,
						@MDDErpRefText03,
						@MDDErpRefText04,
						@MDDErpRefText05,
						@MDDErpRefText06,
						@MDDErpRefText07,
						@MDDErpRefText08,
						@MDDErpRefText09,
						@MDDErpRefText10,
					    GETDATE(),
					    @pProcessUserID,
					    @ChangeDateTime,
					    @ChangeUserID,
						--@LineCode,
						@ImportLine,
						@MRMDExtText06,
						@MDDExtBit01,
						@MDDExtBit02,
						@ManufacturerPartNumber,
						@Grade,
						@IsCheckCoc
					)

				/*
					Modify : 2016-08-28 Kim Han Young
					생산자재불출 (MV_WH_ROUTE) 의 경우 생산계획이 지정되었으면 STB_ProdPlanBom 에 요청수량(RequestQty) 를 업데이트 한다.
				*/
				IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') = '' BEGIN
					UPDATE
							STB_ProdPlanBom
					SET
							RequestQty = ISNULL(RequestQty,0) + @RequestQty
					WHERE
							FPMainPlanNo = @FPMainPlanNo AND
							MaterialCode = @MaterialCode
				END

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN			

				SELECT
						@BefRequestQty = MDD.RequestQty,
						@BefAllowQty = MDD.AllowQty,
						@BefPickingAssignQty = MDD.PickingAssignQty
				FROM
						STB_MaterialDocDetail MDD
				WHERE
						MDD.MaterialDocDetailNo = @MaterialDocDetailNo

				--RAISERROR('STEP 1 %s',16, 1, @MaterialDocType)
				--RETURN


				IF @MaterialDocType = 'GR' BEGIN
						

					-- 이전 요청수량과 현재 요청수량이 다르면 납품쪽에서 변경처리
					IF @BefRequestQty <> @RequestQty BEGIN
						/***********************************************************************************************/
						-- 2016-09-02 Kim Han Young(hykim@awoo.co.kr)
						-- 문서 유효성 체크 추가
						-- 입고의 경우 CREATE 상태가 아니면 수정 불가. CREATE 상태에서만 수정 가능
						/***********************************************************************************************/
						-- 문서 유효성 체크
						EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
														@pProcessUserID = @ProcessUserID,											
														@pMaterialDocNo = @MaterialDocNo,
														@pErrorWhenStart = 1		-- 작업이 시작되어도 에러
						/***********************************************************************************************/
						-- 이전 요청수량과 현재 입하수량이 다르면 입고쪽에서 입하수량을 수정한 경우
						-- 입하수량을 수정한 경우엔 요청수량 수정을 못하도록 에러 발생
						IF @BefRequestQty <> @BefPickingAssignQty BEGIN
							RAISERROR('입하가 진행중입니다.',16,1)
							RETURN
						END
						SET @AllowQty = @RequestQty
						SET @PickingAssignQty = @RequestQty							
					END
					
					UPDATE
							STB_MaterialOrderItem
					SET
							MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) + ISNULL(@BefAllowQty,0) - @AllowQty,
							ChangeDateTime =  GETDATE(),
							ChangeUserID = @ProcessUserID
					WHERE
							MaterialOrderItemNo = @OrderDetailNo
				END
				
				IF @MaterialDocType IN ('GI' ,'MOVE') BEGIN
					
					/***********************************************************************************************/
					-- 2016-09-02 Kim Han Young(hykim@awoo.co.kr)
					-- 문서 유효성 체크 추가
					/***********************************************************************************************/
					-- 문서 유효성 체크
					EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
													@pProcessUserID = @ProcessUserID,											
													@pMaterialDocNo = @MaterialDocNo
					/***********************************************************************************************/

					-- 이전 요청수량과 현재 요청수량이 다르면 요청쪽에서 변경처리
					IF @BefRequestQty <> @RequestQty BEGIN
							
						/***********************************************************************************************/
						-- 2016-09-02 Kim Han Young(hykim@awoo.co.kr)
						-- 문서 유효성 체크 추가
						-- 입고의 경우 CREATE 상태가 아니면 수정 불가. CREATE 상태에서만 수정 가능
						/***********************************************************************************************/
						-- 문서 유효성 체크
						EXEC usp_DoValidateMaterialDoc	@pProcessLanguage = @ProcessLanguage,
														@pProcessUserID = @ProcessUserID,											
														@pMaterialDocNo = @MaterialDocNo,
														@pErrorWhenStart = 1		-- 작업이 시작되어도 에러
						/***********************************************************************************************/
						-- 이전 요청수량과 현재 요청수량이 다르면 입고쪽에서 입하수량을 수정한 경우
						-- 승인수량을 수정한 경우엔 요청수량 수정을 못하도록 에러 발생
						IF @BefRequestQty <> @BefAllowQty BEGIN
							RAISERROR('작업이 진행중입니다.',16,1)
							RETURN
						END
						SET @AllowQty = @RequestQty
						SET @PickingAssignQty = @RequestQty							
					END

					IF ISNULL(@OrderDetailNo,'') <> '' BEGIN
							UPDATE
									STB_SalesOrderItem
							SET
									GIPlanQty = GIPlanQty - @BefRequestQty + @RequestQty,
									ChangeDateTime =  GETDATE(),
									ChangeUserID = @ProcessUserID
							WHERE
									SOISequence = @OrderDetailNo
					END
				END


				UPDATE STB_MaterialDocDetail
					SET
						MaterialDocDetailNo =   ISNULL(@MaterialDocDetailNo,MaterialDocDetailNo),
						MaterialDocNo =   ISNULL(@MaterialDocNo,MaterialDocNo),
						OrderDetailNo =   ISNULL(@OrderDetailNo,OrderDetailNo),
						MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						MaterialStockAttribute =   ISNULL(@MaterialStockAttribute,MaterialStockAttribute),
						ManufacturerCode = ISNULL(@ManufacturerCode, ManufacturerCode),
						WeekCode = ISNULL(@WeekCode, WeekCode),
						RevisionsVer = ISNULL(@RevisionsVer, RevisionsVer),
						StockAttrib1 =   ISNULL(@StockAttrib1,StockAttrib1),
						StockAttrib2 =   ISNULL(@StockAttrib2,StockAttrib2),
						StockAttrib3 =   ISNULL(@StockAttrib3,StockAttrib3),
						RequestQty =   ISNULL(@RequestQty,RequestQty),
						AllowQty =   ISNULL(@AllowQty,AllowQty),
						PickingAssignQty =   ISNULL(@PickingAssignQty,PickingAssignQty),
						PickingQty =   ISNULL(@PickingQty,PickingQty),
						ProcessFixQty =   ISNULL(@ProcessFixQty,ProcessFixQty),
						UnitPriceQty =   ISNULL(@UnitPriceQty,UnitPriceQty),
						UnitPrice =   ISNULL(@UnitPrice,UnitPrice),
						InspectionType =   ISNULL(@InspectionType,InspectionType),
						MaterialIqcNo =   ISNULL(@MaterialIqcNo,MaterialIqcNo),
						BefMaterialStockAttribute = ISNULL(@BefMaterialStockAttribute, BefMaterialStockAttribute),
						VendorLotNo = @VendorLotNo,
						MRMDExtText01 =   ISNULL(@MRMDExtText01,MRMDExtText01),
						MRMDExtText02 =   ISNULL(@MRMDExtText02,MRMDExtText02),
						MRMDExtText03 =   ISNULL(@MRMDExtText03,MRMDExtText03),
						MRMDExtText04 =   ISNULL(@MRMDExtText04,MRMDExtText04),
						MRMDExtText05 =   ISNULL(@MRMDExtText05,MRMDExtText05),
						MDDErpRefText01 =   ISNULL(@MDDErpRefText01,MDDErpRefText01),
						MDDErpRefText02 =   ISNULL(@MDDErpRefText02,MDDErpRefText02),
						MDDErpRefText03 =   ISNULL(@MDDErpRefText03,MDDErpRefText03),
						MDDErpRefText04 =   ISNULL(@MDDErpRefText04,MDDErpRefText04),
						MDDErpRefText05 =   ISNULL(@MDDErpRefText05,MDDErpRefText05),
						MDDErpRefText06 =   ISNULL(@MDDErpRefText06,MDDErpRefText06),
						MDDErpRefText07 =   ISNULL(@MDDErpRefText07,MDDErpRefText07),
						MDDErpRefText08 =   ISNULL(@MDDErpRefText08,MDDErpRefText08),
						MDDErpRefText09 =   ISNULL(@MDDErpRefText09,MDDErpRefText09),
						MDDErpRefText10 =   ISNULL(@MDDErpRefText10,MDDErpRefText10),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID,
						--Line =  ISNULL(@LineCode,Line),
						Line =  ISNULL(@ImportLine,Line),
						MRMDExtText06 = ISNULL(@MRMDExtText06,MRMDExtText06),
						MDDExtBit01 =   ISNULL(@MDDExtBit01,MDDExtBit01),
						MDDExtBit02 =   ISNULL(@MDDExtBit02,MDDExtBit02),
						ManufacturerPartNumber = ISNULL(@ManufacturerPartNumber, ManufacturerPartNumber),
						Grade = ISNULL(@Grade, Grade),
						IsCheckCoc = ISNULL(@IsCheckCoc, IsCheckCoc)

					WHERE
						MaterialDocDetailNo = @OldMaterialDocDetailNo

				/*
					Modify : 2016-08-28 Kim Han Young
					생산자재불출 (MV_WH_ROUTE) 의 경우 생산계획이 지정되었으면 STB_ProdPlanBom 에 요청수량(RequestQty) 를 업데이트 한다.
				*/
				IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') <> '' BEGIN
					UPDATE
							STB_ProdPlanBom
					SET
							RequestQty = ISNULL(RequestQty,0) - @BefRequestQty + @RequestQty
					WHERE
							FPMainPlanNo = @FPMainPlanNo AND
							MaterialCode = @MaterialCode
				END
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
				
				------출고요청화면 삭제기능추가---------------------------------------
				--Modify :  Park Jong Seob, 해당 DocDetail에 MaterialDocLot에 있는 경우에만 삭제 못하도록 수정.
				IF (@MaterialDocType = 'GI') BEGIN--AND (@DocStatus <> 'CREATE')) BEGIN
					IF (
							SELECT
									COUNT(*)
							FROM
									STB_MaterialDocLotInfo MDLI
							WHERE
									MDLI.MaterialDocDetailNo = @MaterialDocDetailNo
						) > 0
					BEGIN
							RAISERROR('이미 피킹되어 있는 대상이 있어 삭제할 수 없습니다. 먼저 피킹을 취소해 주세요: %s',16,1,@DocStatus)
							RETURN
					END
				END
				----------------------------------------------------------------------

				IF ISNULL(@OrderDetailNo,'') <> '' BEGIN

					SELECT
							@BefRequestQty = MDD.RequestQty,
							@BefAllowQty = MDD.AllowQty
					FROM
							STB_MaterialDocDetail MDD
					WHERE
							MDD.MaterialDocDetailNo = @MaterialDocDetailNo

					--RAISERROR('STEP 1 %s',16, 1, @MaterialDocType)
					--RETURN


					IF @MaterialDocType = 'GR' BEGIN
					
						UPDATE
								STB_MaterialOrderItem
						SET
								MaterialOrderRemainQty = ISNULL(MaterialOrderRemainQty,0) + ISNULL(@BefAllowQty,0),
								ChangeDateTime =  GETDATE(),
								ChangeUserID = @ProcessUserID
						WHERE
								MaterialOrderItemNo = @OrderDetailNo
					END
				
					IF @MaterialDocType = 'GI' BEGIN
						UPDATE
								STB_SalesOrderItem
						SET
								GIPlanQty = GIPlanQty - @BefRequestQty,
								ChangeDateTime =  GETDATE(),
								ChangeUserID = @ProcessUserID
						WHERE
								SOISequence = @OrderDetailNo
					END
				END						


                DELETE FROM STB_MaterialDocDetail
				WHERE
					    MaterialDocDetailNo = @MaterialDocDetailNo

				/*
					Modify : 2016-08-28 Kim Han Young
					생산자재불출 (MV_WH_ROUTE) 의 경우 생산계획이 지정되었으면 STB_ProdPlanBom 에 요청수량(RequestQty) 를 업데이트 한다.
				*/
				IF @MaterialDocTypeCode = 'MV_WH_ROUTE' AND ISNULL(@FPMainPlanNo,'') <> '' BEGIN
					UPDATE
							STB_ProdPlanBom
					SET
							RequestQty = ISNULL(RequestQty,0) - @BefRequestQty
					WHERE
							FPMainPlanNo = @FPMainPlanNo AND
							MaterialCode = @MaterialCode
				END
            END

			/*
				Modify : 2016-08-20 Park Jong Seob
				만약 Finish된 수불문서의 MaterialDocDetail이 변경된 경우에는 문서의 상태를 이전 상태로 바꿔준다.
			*/
			IF @DocStatus IN ('FINISH')
			BEGIN
					IF @MaterialDocType IN ('GI', 'MOVE')
					BEGIN
							UPDATE STB_MaterialDocInfo
							SET
									DocStatus = 'WORKING'
							WHERE
									MaterialDocNo = @MaterialDocNo
					END
					IF @MaterialDocType IN ('GR') 
					BEGIN
							UPDATE STB_MaterialDocInfo
							SET
									DocStatus = 'ARRIVAL'
							WHERE
									MaterialDocNo = @MaterialDocNo
					END

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
