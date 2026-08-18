-- =============================================
-- Backup of usp_SanminaLabelPrint_get_Vietnam
-- Backup Date: 2026-08-18
-- Original logic before Inner CartonBoxNo update
-- =============================================
CREATE PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pPONumber VARCHAR(50) = null,
				@pLotNo VARCHAR(50) = null,
				@pQuantity VARCHAR(100) = null,
				@pTotalBox INT = 1
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMaterial NVARCHAR(100)

	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo

	SELECT @IsProdFinish = SI.IsProdFinish,
			@CheckMaterial = MM.MaterialName
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode

	DECLARE @TotalBoxString VARCHAR(5) = NULL
	IF	@pTotalBox < 10 
		SET @TotalBoxString = '0' +  CONVERT(VARCHAR(3), @pTotalBox) 
	ELSE 
		SET @TotalBoxString = CONVERT(VARCHAR(3), @pTotalBox) 

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

	DECLARE @rDC VARCHAR(20) = NULL
	SET @rDC = CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)
	SET @rDC = CONVERT(VARCHAR(6), CAST(@rDC AS DATE), 12);

	DECLARE @rDC2 VARCHAR(20) = NULL
	SET @rDC2 = (SELECT  RIGHT(100 + DATEPART(ISO_WEEK, d), 2) + FORMAT(d, 'yy')  
    FROM (SELECT CAST(dbo.fnPharseLotNo(@LotNo, 'D') AS DATE) AS d) AS t);

	DECLARE		@packingDate_tmp DATETIME = NULL,
				@packingDate VARCHAR(20) = NULL,
				@InspEmpID VARCHAR(20) = NULL,
				@InspEmpName NVARCHAR(200) = NULL
	SELECT TOP 1  @packingDate_tmp = PrintTime 
		FROM STB_SavePackingTime_VVT 
		where	(LotNo = @LotNo or LotNo = @NewBarcode )
		ORDER BY (
			CASE 
					WHEN LotNo = @LotNo and IsPrinted = 0 THEN 1 
					WHEN LotNo = @LotNo and IsPrinted = 1 THEN 1 
					ELSE 2
				END)

	SET @packingDate = CONVERT(VARCHAR(6), CAST(ISNULL(@packingDate_tmp, GETDATE()) AS DATE), 12);

	SELECT TOP 1  @InspEmpID = MIIExtText01,
					@InspEmpName = PWI.WorkerName
		FROM STB_MaterialQcInfo  MQI
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
		where	MQI.InspectionDocType = 'OQC' AND
				(MQI.MaterialQcNo LIKE '%' +SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%')

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
				
	CREATE TABLE #tmp (Num INT)

	IF @pTotalBox >= 1 
	BEGIN
		DECLARE @Number INT = 1;
		DECLARE @SUMTotalBox INT = 0
		WHILE @Number <= @pTotalBox
			BEGIN
				SET @SUMTotalBox = @SUMTotalBox + 1;
				INSERT INTO #tmp (Num) VALUES (@Number)
				SET @Number = @Number + 1;
			END
	END

	DECLARE @SerialPrefix VARCHAR(10) = 'VINA' + @rDC2
	DECLARE @MaxSerial INT = 0

	SELECT @MaxSerial = ISNULL(MAX(TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)), 0)
	FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
	WHERE BoxSerialNo LIKE @SerialPrefix + '%'
	  AND LEN(BoxSerialNo) = 13

	CREATE TABLE #LabelTypes (
		LabelClass VARCHAR(10),
		SortOrder INT
	)
	INSERT INTO #LabelTypes VALUES ('Outer', 1)
	INSERT INTO #LabelTypes VALUES ('Inner', 2)
	INSERT INTO #LabelTypes VALUES ('Inner', 3)

	DECLARE @InnerQty VARCHAR(100) = ISNULL(CONVERT(VARCHAR(100), TRY_CAST(@pQuantity AS INT) / 2), @pQuantity)

	SELECT 
			'Vinatech Vina' AS SupplierName,
			'LFIBLM164855' AS SanminaPartNumber,
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
			CASE	WHEN #tmp.Num < 10 THEN '0' + CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
					ELSE CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
				END as CartonBoxNo,
			'Report' AS CommandType,
			LT.LabelClass,
			CASE 
				WHEN LT.SortOrder = 2 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5)
				WHEN LT.SortOrder = 3 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
				ELSE @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) + ', ' + @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
			END AS BoxSerialNo,
			CASE 
				WHEN LT.SortOrder = 2 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5)
				WHEN LT.SortOrder = 3 THEN @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
				ELSE @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) + ', ' + @SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5)
			END AS PrintSerialNo,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 1), 5) AS Inner1Serial,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + (#tmp.Num-1)*2 + 2), 5) AS Inner2Serial,
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
