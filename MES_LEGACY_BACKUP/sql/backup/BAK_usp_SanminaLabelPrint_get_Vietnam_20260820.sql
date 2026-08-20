-- =============================================
-- BACKUP OF usp_SanminaLabelPrint_get_Vietnam
-- DATE: 2026-08-20
-- =============================================
CREATE PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
				@pProcessUserID VARCHAR(20) = null,
				@pProcessLanguage VARCHAR(20) = null,
				@pPONumber VARCHAR(50) = null,
				@pLotNo VARCHAR(50) = null,
				@pQuantity VARCHAR(100) = null,
				@pTotalBox INT = 1,
				@pPartNumber VARCHAR(50) = 'LFIBLM164855'
AS
BEGIN
	SET NOCOUNT ON;

	IF @pProcessLanguage IS NULL SET @pProcessLanguage = 'vi-VN';

	DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMaterial NVARCHAR(100)

	IF @LotNo IS NULL OR RTRIM(LTRIM(@LotNo)) = ''
	BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Vui lòng quét hoặc nhập mã Lot No (Barcode)!';
		RETURN;
	END

	-- =========================================================================
	-- 1. ƯU TIÊN NẠP TỰ ĐỘNG TỪ BẢNG CẤU HÌNH ĐANG KÍCH HOẠT (NẾU CÓ)
	-- =========================================================================
	DECLARE @ActivePlanID INT = NULL,
			@ActivePlanCode VARCHAR(30) = NULL,
			@ActivePO VARCHAR(50) = NULL,
			@ActivePartNo VARCHAR(50) = NULL,
			@ActiveTotalBox INT = NULL,
			@ActiveQtyPerBox INT = NULL,
			@ActivePrintedBoxCount INT = 0,
			@ActiveStartSerial INT = NULL,
			@IsPlanMode BIT = 0;

	IF @pPONumber IS NOT NULL AND LTRIM(RTRIM(@pPONumber)) <> ''
	BEGIN
		SELECT TOP 1 
			@ActivePlanID = PlanID,
			@ActivePlanCode = PlanCode,
			@ActivePO = PONumber,
			@ActivePartNo = PartNumber,
			@ActiveTotalBox = TotalBox,
			@ActiveQtyPerBox = QtyPerBox,
			@ActivePrintedBoxCount = PrintedBoxCount,
			@ActiveStartSerial = StartSerial
		FROM STB_SanminaShipmentPlan WITH(NOLOCK)
		WHERE IsActive = 1
		  AND PONumber = LTRIM(RTRIM(@pPONumber));
	END
	ELSE
	BEGIN
		SELECT TOP 1 
			@ActivePlanID = PlanID,
			@ActivePlanCode = PlanCode,
			@ActivePO = PONumber,
			@ActivePartNo = PartNumber,
			@ActiveTotalBox = TotalBox,
			@ActiveQtyPerBox = QtyPerBox,
			@ActivePrintedBoxCount = PrintedBoxCount,
			@ActiveStartSerial = StartSerial
		FROM STB_SanminaShipmentPlan WITH(NOLOCK)
		WHERE IsActive = 1
		  AND (LotNo = @LotNo OR LotNo IS NULL)
		ORDER BY 
			CASE WHEN LotNo = @LotNo THEN 1 ELSE 2 END,
			UpdateDateTime DESC, CreateDateTime DESC;
	END

	IF @ActivePlanID IS NOT NULL
	BEGIN
		SET @IsPlanMode = 1;
		IF @pPONumber IS NULL OR LTRIM(RTRIM(@pPONumber)) = ''
			SET @pPONumber = @ActivePO;

		IF @pPartNumber IS NULL OR LTRIM(RTRIM(@pPartNumber)) = '' OR @pPartNumber = 'LFIBLM164855'
			SET @pPartNumber = @ActivePartNo;

		IF @pTotalBox IS NULL OR @pTotalBox <= 0 OR @pTotalBox = 1
			SET @pTotalBox = @ActiveTotalBox;

		IF @pQuantity IS NULL OR LTRIM(RTRIM(@pQuantity)) = ''
			SET @pQuantity = CONVERT(VARCHAR(100), @ActiveQtyPerBox);
	END
	ELSE
	BEGIN
		IF @pTotalBox IS NULL OR @pTotalBox <= 0 SET @pTotalBox = 1;
		IF @pPartNumber IS NULL OR LTRIM(RTRIM(@pPartNumber)) = '' SET @pPartNumber = 'LFIBLM164855';
	END

	-- =========================================================================
	-- 2. Kiểm tra LotNo và Thành phẩm
	-- =========================================================================
	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo

	SELECT @IsProdFinish = SI.IsProdFinish,
			@CheckMaterial = MM.MaterialName
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode

	IF @@ROWCOUNT = 0 BEGIN
		SELECT @IsProdFinish = IsProdFinish
		  FROM STB_SetInfo
		 WHERE Barcode = REPLACE(@LotNo, 'VV', 'VV')
	END

	IF @IsProdFinish IS NULL BEGIN 
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Mã Lotno này không tồn tại trên hệ thống.!'
		RETURN
	END

	IF @IsProdFinish <> CONVERT(BIT, 1) BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Kiểm tra màn hình B523 xem đóng gói hay chưa. Gọi sản xuất'
		RETURN
	END

	IF @CheckMaterial NOT LIKE '%VEC3R0727QG%' AND @CheckMaterial NOT LIKE '%727%' BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot đã nhập không phải hàng VEC3R0727QG (35105)'
		RETURN
	END

	DECLARE @TotalBoxString VARCHAR(10) = NULL
	IF @pTotalBox < 10 
		SET @TotalBoxString = '0' + CONVERT(VARCHAR(10), @pTotalBox) 
	ELSE 
		SET @TotalBoxString = CONVERT(VARCHAR(10), @pTotalBox) 

	-- Lấy Lot code - YYMMDD
	DECLARE @rDC VARCHAR(20) = NULL
	SET @rDC = CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)
	SET @rDC = CONVERT(VARCHAR(6), CAST(@rDC AS DATE), 12);

	-- Lấy Lot code 2 - YYWW
	DECLARE @rDC2 VARCHAR(20) = NULL
	SET @rDC2 = (SELECT RIGHT(100 + DATEPART(ISO_WEEK, d), 2) + FORMAT(d, 'yy')  
                 FROM (SELECT CAST(dbo.fnPharseLotNo(@LotNo, 'D') AS DATE) AS d) AS t);

	-- Lấy ngày đóng gói
	DECLARE		@packingDate_tmp DATETIME = NULL,
				@packingDate VARCHAR(20) = NULL,
				@InspEmpID VARCHAR(20) = NULL,
				@InspEmpName NVARCHAR(200) = NULL
	SELECT TOP 1 @packingDate_tmp = PrintTime 
	FROM STB_SavePackingTime_VVT 
	WHERE (LotNo = @LotNo or LotNo = @NewBarcode)
	ORDER BY (
		CASE 
			WHEN LotNo = @LotNo and IsPrinted = 0 THEN 1 
			WHEN LotNo = @LotNo and IsPrinted = 1 THEN 1 
			ELSE 2
		END);

	SET @packingDate = CONVERT(VARCHAR(6), CAST(ISNULL(@packingDate_tmp, GETDATE()) AS DATE), 12);

	-- Lấy tên NV QC
	SELECT TOP 1 @InspEmpID = MIIExtText01,
				 @InspEmpName = PWI.WorkerName
	FROM STB_MaterialQcInfo MQI WITH(NOLOCK)
	LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK) ON MQI.MIIExtText01 = PWI.WorkerCode
	WHERE MQI.InspectionDocType = 'OQC' 
	  AND (MQI.MaterialQcNo LIKE '%' + SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%');

	-- Chuyển đổi tên tiếng Việt có dấu sang không dấu
	IF @InspEmpName IS NOT NULL
	BEGIN
		SET @InspEmpName = UPPER(@InspEmpName)
		SET @InspEmpName = REPLACE(@InspEmpName, N'À', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Á', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ả', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ã', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ạ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ă', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ằ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ắ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẳ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẵ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ặ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Â', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ầ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ấ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẩ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẫ', 'A')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ậ', 'A')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'È', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'É', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẻ', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẽ', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ẹ', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ê', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ề', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ế', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ể', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ễ', 'E')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ệ', 'E')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ì', 'I')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Í', 'I')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỉ', 'I')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ĩ', 'I')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ị', 'I')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ò', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ó', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỏ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Õ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ọ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ô', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ồ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ố', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ổ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỗ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ộ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ơ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ờ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ớ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ở', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỡ', 'O')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ợ', 'O')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ù', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ú', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ủ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ũ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ụ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ư', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ừ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ứ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ử', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ữ', 'U')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ự', 'U')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỳ', 'Y')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ý', 'Y')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỷ', 'Y')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỹ', 'Y')
		SET @InspEmpName = REPLACE(@InspEmpName, N'Ỵ', 'Y')
		
		SET @InspEmpName = REPLACE(@InspEmpName, N'Đ', 'D')
	END
				
	-- =========================================================================
	-- 3. Tạo dữ liệu thùng Outer + Inner
	-- =========================================================================
	CREATE TABLE #tmp (Num INT)

	IF @IsPlanMode = 1
	BEGIN
		DECLARE @NextBox INT = @ActivePrintedBoxCount + 1;
		IF @NextBox > @pTotalBox SET @NextBox = @pTotalBox;
		IF @NextBox <= 0 SET @NextBox = 1;

		INSERT INTO #tmp (Num) VALUES (@NextBox);
	END
	ELSE
	BEGIN
		IF @pTotalBox >= 1 
		BEGIN
			DECLARE @Number INT = 1;
			WHILE @Number <= @pTotalBox
			BEGIN
				INSERT INTO #tmp (Num) VALUES (@Number);
				SET @Number = @Number + 1;
			END
		END
	END

	-- =========================================================================
	-- 4. TÍNH TOÁN SỐ SERIAL LIÊN TỤC (KHÔNG BỊ NGẮT QUÃNG KHI ĐỔI MÃ LOT)
	-- =========================================================================
	DECLARE @SerialPrefix VARCHAR(10) = 'VINA' + @rDC2
	DECLARE @LatestSerial INT = 0

	-- Lấy số serial 5 chữ số lớn nhất gần đây nhất trong lịch sử in
	SELECT TOP 1 @LatestSerial = TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)
	FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
	WHERE LEN(BoxSerialNo) = 13 AND BoxSerialNo LIKE 'VINA%'
	ORDER BY ID DESC;

	-- BaseSerial: Lấy số lớn nhất giữa StartSerial cấu hình và LatestSerial trong DB
	DECLARE @BaseSerial INT = ISNULL(@LatestSerial, 0);
	IF @IsPlanMode = 1 AND @ActiveStartSerial IS NOT NULL AND @ActiveStartSerial > @BaseSerial
	BEGIN
		SET @BaseSerial = @ActiveStartSerial;
	END

	CREATE TABLE #LabelTypes (
		LabelClass VARCHAR(10),
		SortOrder INT
	)
	INSERT INTO #LabelTypes VALUES ('Outer', 1)
	INSERT INTO #LabelTypes VALUES ('Inner', 2)
	INSERT INTO #LabelTypes VALUES ('Inner', 3)

	DECLARE @InnerBoxPerOuter INT = 2
	DECLARE @TotalInnerPerOuterStr VARCHAR(5) = RIGHT('0' + CONVERT(VARCHAR(3), @InnerBoxPerOuter), 2)
	DECLARE @InnerQty VARCHAR(100) = ISNULL(CONVERT(VARCHAR(100), TRY_CAST(@pQuantity AS INT) / @InnerBoxPerOuter), @pQuantity)

	SELECT 
			'Vinatech Vina' AS SupplierName,
			ISNULL(NULLIF(@pPartNumber, ''), 'LFIBLM164855') AS PartNumber,
			ISNULL(NULLIF(@pPartNumber, ''), 'LFIBLM164855') AS SanminaPartNumber,
			'CAP,TH EDLC 720F 3V D35MMXL105MM' AS PartDesc,
			'VINA TECHNOLOGY' AS MFR,
			'VEC3R0727QG' AS MPN,
			CASE WHEN LT.LabelClass = 'Outer' THEN @pQuantity
				 ELSE @InnerQty
			END AS Quantity,
			@pPONumber AS PONumber,
			@pLotNo AS LotNo,
			@rDC AS LotCode,
			@rDC2 AS LotCode2,
			@packingDate AS PackingDate,
			ISNULL(@InspEmpID, '') AS InspEmpID,
			ISNULL(@InspEmpName, '') AS InspEmpName,
			CASE 
				WHEN LT.LabelClass = 'Outer' THEN 
					CASE 
						WHEN #tmp.Num < 10 THEN '0' + CONVERT(VARCHAR(10), #tmp.Num)
						ELSE CONVERT(VARCHAR(10), #tmp.Num)
					END + '/' + @TotalBoxString
				ELSE 
					@TotalInnerPerOuterStr + '/' + RIGHT('0' + CONVERT(VARCHAR(3), LT.SortOrder - 1), 2)
			END AS CartonBoxNo,
			'Report' AS CommandType,
			LT.LabelClass,
			CASE 
				WHEN LT.SortOrder = 2 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5)
				WHEN LT.SortOrder = 3 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
				ELSE 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5) + ', ' + 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
			END AS BoxSerialNo,
			CASE 
				WHEN LT.SortOrder = 2 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5)
				WHEN LT.SortOrder = 3 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
				ELSE 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5) + ', ' + 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
			END AS PrintSerialNo,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
				CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
					 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
				END), 5) AS Inner1Serial,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
				CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
					 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
				END), 5) AS Inner2Serial,
			CASE 
				WHEN LT.LabelClass = 'Outer' THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5) + '||' +
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
				WHEN LT.SortOrder = 2 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 1 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 1 
						END), 5)
				WHEN LT.SortOrder = 3 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, 
						CASE WHEN @IsPlanMode = 1 THEN @BaseSerial + 2 
							 ELSE @BaseSerial + (#tmp.Num-1)*2 + 2 
						END), 5)
			END AS SerialListForQR

	FROM #tmp
	CROSS JOIN #LabelTypes LT
	ORDER BY #tmp.Num, LT.SortOrder ASC

	DROP TABLE #tmp
	DROP TABLE #LabelTypes

END
