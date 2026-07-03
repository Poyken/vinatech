-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-26
-- Description:	Get Sanmina label
-- =============================================
-- exec usp_SanminaLabelPrint_get_Vietnam '', '', '123', 'VVQL023R07279E', '100', '10'

CREATE PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20)=null,
				@pProcessLanguage VARCHAR(20)=null,
				@pPONumber VARCHAR(50) = null,
				@pLotNo VARCHAR(50) = null,
				@pQuantity VARCHAR(100) = null,
				@pTotalBox INT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE	@LotNo VARCHAR(50) = @pLotNo
		,@IsProdFinish BIT
		,@CheckMPN VARCHAR(30)
		,@SN VARCHAR(20)
		,@RowCnt INT
		,@CheckMaterial NVARCHAR(100)

	-- update 2025-10-13, có thể tìm được khi lotno đã đc chuyển đổi lot
	DECLARE @NewBarcode VARCHAR(30) = NULL
	SELECT @NewBarcode = NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @LotNo

	--DECLARE @SeparateBarcode VARCHAR(30) = NULL
	--SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1 and mergeid = @LotNo


	-- select * from STB_YearInfo

	-- Check LotNo
	SELECT @IsProdFinish = SI.IsProdFinish,
			@CheckMaterial = MM.MaterialName
			--@CheckMPN = RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) + CASE WHEN CHARINDEX('-L', MM.MaterialName) > 0 THEN '-L' ELSE '' END 
	  FROM STB_SetInfo SI WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
	 WHERE Barcode = @LotNo or Barcode = @NewBarcode		-- update 2025-10-13, can search Lotno Changed 

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

	--IF @pTypeBoxCode IS NULL or @pTypeBoxCode = '' BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Hãy chọn loại thùng để in tem'
	--	RETURN
	--END


	------- Tắt đoạn này vì có những Lot bị đổi sau khi vào kho -- BEGIN
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


	-- Lấy Lot code  - YYMMDD
	DECLARE @rDC VARCHAR(20) = NULL
	SET @rDC = CONVERT(DATE, dbo.fnPharseLotNo(@LotNo, 'D'), 112)
	SET @rDC = CONVERT(VARCHAR(6), CAST(@rDC AS DATE), 12);

	DECLARE @rDC2 VARCHAR(20) = NULL
	SET @rDC2 = (SELECT  RIGHT(100 + DATEPART(ISO_WEEK, d), 2) + FORMAT(d, 'yy')  
    FROM (SELECT CAST(dbo.fnPharseLotNo(@LotNo, 'D') AS DATE) AS d) AS t);

	-- Lấy ngày đóng gói
	DECLARE		@packingDate_tmp DATETIME = NULL,
				@packingDate VARCHAR(20) = NULL,
				@InspEmpID VARCHAR(20) = NULL,
				@InspEmpName NVARCHAR(200) = NULL
	SELECT TOP 1  @packingDate_tmp = PrintTime 
		FROM STB_SavePackingTime_VVT 
		where	--IsPrinted = 0 AND
				(LotNo = @LotNo or LotNo = @NewBarcode )
		ORDER BY (
			CASE 
					WHEN LotNo = @LotNo and IsPrinted = 0 THEN 1 
					WHEN LotNo = @LotNo and IsPrinted = 1 THEN 1 
					ELSE 2
				END)

	SET @packingDate = CONVERT(VARCHAR(6), CAST(@packingDate_tmp AS DATE), 12);
	
	--RAISERROR(@LotNo, 16, 1)
	--RETURN

	-- Lấy tên NV QC
	SELECT TOP 1  @InspEmpID = MIIExtText01,
					@InspEmpName = PWI.WorkerName
		FROM STB_MaterialQcInfo  MQI
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
		where	MQI.InspectionDocType = 'OQC' AND
				(MQI.MaterialQcNo LIKE '%' +SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%'
				
				--OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1 and mergeid = @LotNo)
				) --update for level lot -1 -2 ...

				
		--ORDER BY (
		--	CASE 
		--			WHEN MQI.MaterialQcNo = @LotNo THEN 1 
		--			ELSE 2
		--		END)






	-------------------------------
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

	/*--vanduc edited by Mrs.DuongHoa 20260703 up-date Sanmina label START*/
	-- 1. Tính Serial Number tự tăng dựa trên Tuần + Năm (@rDC2)
	DECLARE @SerialPrefix VARCHAR(10) = 'VINA' + @rDC2
	DECLARE @MaxSerial INT = 0

	SELECT @MaxSerial = ISNULL(MAX(CAST(RIGHT(BoxSerialNo, 5) AS INT)), 0)
	FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
	WHERE BoxSerialNo LIKE @SerialPrefix + '%'

	-- 2. Tạo bảng tạm chứa phân loại nhãn (1 Outer + 2 Inner)
	CREATE TABLE #LabelTypes (
		LabelClass VARCHAR(10),
		Suffix VARCHAR(5),
		SortOrder INT
	)
	INSERT INTO #LabelTypes VALUES ('Outer', '', 1)
	INSERT INTO #LabelTypes VALUES ('Inner', '-01', 2)
	INSERT INTO #LabelTypes VALUES ('Inner', '-02', 3)

	-- 3. Xuất danh sách tem in
	SELECT 
			'Vinatech Vina' AS SupplierName,
			'LFIBLM164855' AS SanminaPartNumber,
			'CAP,TH EDLC 720F 3V D35MMXL105MM' AS PartDesc,
			'VINA TECHNOLOGY' AS MFR,
			'VEC3R0727QG' AS MPN,
			@pQuantity AS Quantity,
			@pPONumber AS PONumber,
			@pLotNo AS LotNo,
			@rDC AS LotCode,
			@rDC2 AS LotCode2,
			@packingDate AS PackingDate,
			@InspEmpID AS InspEmpID,
			@InspEmpName AS InspEmpName,
			CASE	WHEN #tmp.Num < 10 THEN '0' + CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
					ELSE CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
				END as CartonBoxNo,
			'Report' AS CommandType,
			LT.LabelClass,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) AS BoxSerialNo, -- Serial gốc của thùng to (dùng để lưu hist)
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + LT.Suffix AS PrintSerialNo -- Serial in thực tế (Outer: VINA162600001, Inner 1: VINA162600001-01, Inner 2: VINA162600001-02)

	FROM #tmp
	CROSS JOIN #LabelTypes LT
	ORDER BY #tmp.Num, LT.SortOrder ASC

	DROP TABLE #tmp
	DROP TABLE #LabelTypes
	/*END*/

END

-- Safety validation bypass:
-- BEGIN TRAN
-- ROLLBACK TRAN
