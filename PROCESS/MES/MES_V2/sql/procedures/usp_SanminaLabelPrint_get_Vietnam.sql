IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SanminaLabelPrint_get_Vietnam]') AND type in (N'P', N'PC'))
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam] AS SELECT 1 AS Stub;'
GO

ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
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
			@IsPlanMode BIT = 0;

	-- Phân định rõ: Nếu user nhập tay PO -> Chỉ tìm Plan khớp chính xác PO đó
	-- Nếu user để trống PO -> Tự động nạp Plan đang kích hoạt (Ưu tiên theo LotNo hoặc Plan chung)
	IF @pPONumber IS NOT NULL AND LTRIM(RTRIM(@pPONumber)) <> ''
	BEGIN
		SELECT TOP 1 
			@ActivePlanID = PlanID,
			@ActivePlanCode = PlanCode,
			@ActivePO = PONumber,
			@ActivePartNo = PartNumber,
			@ActiveTotalBox = TotalBox,
			@ActiveQtyPerBox = QtyPerBox,
			@ActivePrintedBoxCount = PrintedBoxCount
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
			@ActivePrintedBoxCount = PrintedBoxCount
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
		-- Tự động điền nếu tham số đầu vào rỗng hoặc dùng theo Plan
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
		-- Giữ nguyên 100% logic cũ khi không dùng Plan: Giá trị do user truyền vào
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

	IF @CheckMaterial NOT LIKE '%VEC3R0727QG%' BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Lot đã nhập không phải hàng VEC3R0727QG (35105)'
		RETURN
	END

	DECLARE @TotalBoxString VARCHAR(5) = NULL
	IF @pTotalBox < 10 
		SET @TotalBoxString = '0' + CONVERT(VARCHAR(3), @pTotalBox) 
	ELSE 
		SET @TotalBoxString = CONVERT(VARCHAR(3), @pTotalBox) 

	-- Lấy Lot code - YYMMDD
	DECLARE @rDC VARCHAR(20) = NULL
	SET @rDC = CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)
	SET @rDC = CONVERT(VARCHAR(6), CAST(@rDC AS DATE), 12);

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
				END)

	SET @packingDate = CONVERT(VARCHAR(6), CAST(ISNULL(@packingDate_tmp, GETDATE()) AS DATE), 12);

	-- Lấy tên NV QC
	SELECT TOP 1 @InspEmpID = MIIExtText01,
				 @InspEmpName = PWI.WorkerName
		FROM STB_MaterialQcInfo MQI
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK) ON MQI.MIIExtText01 = PWI.WorkerCode
		WHERE MQI.InspectionDocType = 'OQC' AND
				(MQI.MaterialQcNo LIKE '%' + SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%')

	-- Clean Vietnamese diacritics from Inspector Name for QR Code & Label Print
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
		-- Ở chế độ theo Plan: Trả về thùng tiếp theo cần in (hoặc thùng hiện tại nếu đã in đủ)
		DECLARE @NextBox INT = @ActivePrintedBoxCount + 1;
		IF @NextBox > @pTotalBox SET @NextBox = @pTotalBox;
		IF @NextBox <= 0 SET @NextBox = 1;

		INSERT INTO #tmp (Num) VALUES (@NextBox);
	END
	ELSE
	BEGIN
		-- Ở chế độ tự do (nhập tay): Trả về dãy thùng 1..TotalBox như logic gốc
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

	-- Tính Serial Number tự tăng liên tục 5 chữ số đằng sau
	DECLARE @SerialPrefix VARCHAR(10) = 'VINA' + @rDC2
	DECLARE @MaxSerial INT = 0

	SELECT @MaxSerial = ISNULL(MAX(TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)), 0)
	FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
	WHERE BoxSerialNo LIKE 'VINA%'
	  AND LEN(BoxSerialNo) = 13

	-- Bảng tạm phân loại nhãn (1 Outer + 2 Inner)
	CREATE TABLE #LabelTypes (
		LabelClass VARCHAR(10),
		SortOrder INT
	)
	INSERT INTO #LabelTypes VALUES ('Outer', 1)
	INSERT INTO #LabelTypes VALUES ('Inner', 2)
	INSERT INTO #LabelTypes VALUES ('Inner', 3)

	-- Số lượng Inner Box trong 1 Outer Box (Sanmina spec = 2)
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
			-- CartonBoxNo: Outer = Thùng Outer hiện tại / Tổng thùng Outer; Inner = Tổng Inner trong Thùng / Thứ tự Inner (02/01, 02/02...)
			CASE 
				WHEN LT.LabelClass = 'Outer' THEN 
					RIGHT('0' + CONVERT(VARCHAR(3), #tmp.Num), 2) + '/' + @TotalBoxString
				ELSE 
					@TotalInnerPerOuterStr + '/' + RIGHT('0' + CONVERT(VARCHAR(3), LT.SortOrder - 1), 2)
			END AS CartonBoxNo,
			'Report' AS CommandType,
			LT.LabelClass,
			-- BoxSerialNo: dùng cho history tracking (mỗi inner box serial riêng, outer box gồm cả 2)
			CASE 
				WHEN LT.SortOrder = 2 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5)
				WHEN LT.SortOrder = 3 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
				ELSE @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) + ', ' + @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
			END AS BoxSerialNo,
			-- PrintSerialNo: serial hiển thị trên tem (cột S/N trong tem)
			CASE 
				WHEN LT.SortOrder = 2 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5)
				WHEN LT.SortOrder = 3 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
				ELSE @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) + ', ' + @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
			END AS PrintSerialNo,
			-- Inner1Serial & Inner2Serial: mỗi inner box serial riêng biệt
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) AS Inner1Serial,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5) AS Inner2Serial,
			-- SerialListForQR: nội dung serial trong QR code
			CASE 
				WHEN LT.LabelClass = 'Outer' THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) + '||' +
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
				WHEN LT.SortOrder = 2 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5)
				WHEN LT.SortOrder = 3 THEN 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
			END AS SerialListForQR

	FROM #tmp
	CROSS JOIN #LabelTypes LT
	ORDER BY #tmp.Num, LT.SortOrder ASC

	DROP TABLE #tmp
	DROP TABLE #LabelTypes

END
GO