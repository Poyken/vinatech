# 📓 Vinatech MES Agent — Hotfix Log (Nhật ký lỗi & Giải pháp)

> **Mục đích:** Bảng lưu trữ lịch sử các con bug đã được AI xử lý thành công. File này đóng vai trò là "Bộ nhớ dài hạn" để AI tra cứu trước khi xử lý các sự cố tiếp theo nhằm tự tối ưu bản thân qua thời gian.
> **Quy trình:** Khi hoàn thành fix bất kỳ lỗi nào, AI bắt buộc phải mô tả chi tiết lỗi vào danh sách dưới đây và thực hiện commit.

---

## 📋 Danh sách Lịch sử Sửa lỗi (Hotfix Registry)

### 📌 Mẫu ghi chép (Template)
* **Ngày sửa:** `YYYY-MM-DD`
* **Màn hình liên quan (TCode):** `[TCODE_ID] - Tên màn hình`
* **Triệu chứng lỗi:** `Nội dung lỗi hiển thị trên UI (Tiếng Hàn/Anh/Việt)`
* **Nguyên nhân gốc (Root Cause):** `Giải thích lỗi do code SP hay do dữ liệu CSDL`
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  -- Chèn câu lệnh SQL fix hoặc giải pháp xử lý đã thực hiện
  ```

---

## ⚡ Các Lỗi Đã Được Xử Lý (Resolved Bugs)

*(Chưa có bản ghi mới trong phiên này. Hãy bắt đầu ghi chép khi xử lý con bug tiếp theo!)*

### [K366]/[K366] — 📍 ID_18 screen displays blank Status column (Final conclusion P...
* **Ngay sua:** `2026-07-06`
* **Man hinh lien quan (TCode):** `K366 - Chua xac dinh`
* **Trieu chung loi:** K366 screen displays blank Status column (Final conclusion Pass/Fail)
* **Nguyen nhan goc (Root Cause):** Stored procedure usp_LotTrackingInfo_VVTF4_get does not return the Status column to map to the grid.
* **Phuong an sua loi (SQL Patch / Action):**
  ```sql
-- =============================================
-- Author:		Nguyễn Hải Triều(Mr.Dev)
-- Create date: 2026-06-18
-- Description:	Kiểm tra dữ liệu Lot hoàn thành, tình trạng lỗi và tìm kiếm theo LotNo
-- exec usp_LotTrackingInfo_VVTF4_get '','','','2026-06-01','2026-06-18',''
-- =============================================
ALTER PROCEDURE [dbo].[usp_LotTrackingInfo_VVTF4_get]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pLotNo VARCHAR(100) = NULL        -- Mr.Tuân: Thêm tham số tìm kiếm theo LotNo 
AS
BEGIN
	-- STB_DefectInspectionDetail 재검사, 재작업, 디버깅 관련 테이블

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate   VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00' 
	DECLARE @MilestoneDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2025-05-01')), 120) + ' 10:00:00'
	DECLARE @CheckCompleteRoute BIT = 0
	
	IF @ToDate >= @MilestoneDate
	BEGIN
		SET @CheckCompleteRoute = 1
	END

	CREATE TABLE #TmpBarcodes (Barcode VARCHAR(100) PRIMARY KEY)
	INSERT INTO #TmpBarcodes (Barcode)
	SELECT DISTINCT c.Barcode
	FROM STB_SetInfo c WITH(NOLOCK) 
	INNER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo = b.ControlNo    
	WHERE b.CompanyCode = 'VVT' 
	  AND b.WorkCenterCode = 'VVT_F4'  
	  AND b.ProdDateTime >= @FromDate  
	  AND b.ProdDateTime < @ToDate 
	  AND (@CheckCompleteRoute = 0 OR b.CompleteRoute = 1)
	  AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker')
	  AND c.Barcode = ISNULL(NULLIF(@pLotNo, ''), c.Barcode)
	ORDER BY c.Barcode

	/* 2026-06-21 [김형진] - 성능 최적화: 불량판정/원자재투입일자를 미리 집계 후 LEFT JOIN */

	-- 불량 존재 여부: ControlNo + RouteCode별 1회 집계
	CREATE TABLE #TmpDefect (ControlNo VARCHAR(20), FindRouteCode VARCHAR(20), PRIMARY KEY (ControlNo, FindRouteCode))
	INSERT INTO #TmpDefect (ControlNo, FindRouteCode)
	SELECT DISTINCT dri.ControlNo, dri.FindRouteCode
	FROM STB_DefectRepairInfo dri WITH(NOLOCK)
	INNER JOIN STB_SetInfo si WITH(NOLOCK) ON si.ControlNo = dri.ControlNo
	INNER JOIN #TmpBarcodes tb ON tb.Barcode = si.Barcode
	WHERE ISNULL(dri.IsDelete, '') <> 'Y'


	-- 원자재 마지막 투입일자: Barcode별 1회 집계
	CREATE TABLE #TmpMaterialInput (Barcode VARCHAR(100) PRIMARY KEY, LastMaterialInputDate DATETIME)
	INSERT INTO #TmpMaterialInput (Barcode, LastMaterialInputDate)
	SELECT rmi.Barcode, MAX(rmi.CreateDateTime)
	FROM STB_RawMaterialInputHist rmi WITH(NOLOCK)
	INNER JOIN #TmpBarcodes tb ON tb.Barcode = rmi.Barcode
	WHERE rmi.Status = 'ACTIVE'
	GROUP BY rmi.Barcode

	-- 수선/리워크 성공 여부: Barcode + RouteCode별 1회 집계
	CREATE TABLE #TmpRepair (Barcode VARCHAR(100), RouteCode VARCHAR(20), PRIMARY KEY (Barcode, RouteCode))
	INSERT INTO #TmpRepair (Barcode, RouteCode)
	SELECT DISTINCT ri.Barcode, ri.RouteCode
	FROM STB_RepairInfor ri WITH(NOLOCK)
	INNER JOIN #TmpBarcodes tb ON tb.Barcode = ri.Barcode
	WHERE ri.StatusRepair = 1

	SELECT 
		G.Barcode,
		G.RouteCode,
		G.RouteCode AS FindRouteCode,
		G.ControlNo,
		G.MaterialCode,
		G.InputLineCode,  		
		G.WorkerCode,
		G.ProdQty,		
		G.ProdDateTime,
		G.CreateDateTime,
		G.DefectStatus,		  
		G.LastMaterialInputDate,
		G.InspectionNgType, -- ng타입
		G.InspectionDebugType, -- Debug타입
		G.InspectionDesc, -- 사유
		G.InspectionNgTypeName,
		G.InspectionDebugTypeName,
		G.InspectionSelectType,
		G.GroupOrder,
		G.Status
	FROM
	(	
		SELECT  c.Barcode,
			   b.RouteCode,
			   b.RouteCode AS FindRouteCode,
			   c.ControlNo,
			   c.MaterialCode,
			   c.InputLineCode,  		
			   b.WorkerCode,
			   b.ProdQty,		
			   b.ProdDateTime,
			   b.CreateDateTime,
			   -- [추가] 불량 판정: 동일 ControlNo + 동일 공정 기준
			   -- [추가 - 이용탁] Fail, Pass
			   (
					CASE 
					WHEN df.ControlNo IS NOT NULL THEN 'Fail' 
					ELSE 'Pass' 
					END 
			   ) AS DefectStatus,
			   -- [추가] 원자재 마지막 투입일자
			   mi.LastMaterialInputDate,
				NULL AS InspectionNgType, -- ng타입
				NULL AS InspectionDebugType, -- Debug타입
				NULL AS InspectionDesc, -- 사유
				NULL AS InspectionNgTypeName,
				NULL AS InspectionDebugTypeName,
				'PROCESS' AS InspectionSelectType,
				1 AS GroupOrder,
				(
					CASE 
					WHEN df.ControlNo IS NULL THEN 'PASS'
					WHEN rp.Barcode IS NOT NULL THEN 'PASS'
					ELSE 'FAIL'
					END
				) AS Status
		FROM 
		STB_SetInfo c WITH(NOLOCK) 
		INNER JOIN #TmpBarcodes tb ON c.Barcode = tb.Barcode
		INNER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo = b.ControlNo	
		LEFT OUTER JOIN #TmpDefect df ON df.ControlNo = c.ControlNo AND df.FindRouteCode = b.RouteCode
		LEFT OUTER JOIN #TmpMaterialInput mi ON mi.Barcode = c.Barcode
		LEFT OUTER JOIN #TmpRepair rp ON rp.Barcode = c.Barcode AND rp.RouteCode = b.RouteCode


		WHERE 
		c.CreateDateTime > @FromDate 
		AND c.CreateDateTime < @ToDate
		AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker')
	
	UNION ALL

	SELECT 
		 SI.Barcode
		,PH.RouteCode
		,PH.RouteCode AS FindRouteCode
		,PH.ControlNo
		,SI.MaterialCode
		,SI.InputLineCode
		,DD.CreateUserId AS WorkerCode	
		,PH.ProdQty 		
		,PH.ProdDateTime 
		,DD.CreateDateTime
		,DD.InspectionResult AS DefectStatus -- 11번째 컬럼: 결과 데이터 (VARCHAR)
		,MI.LastMaterialInputDate       -- 12번째 컬럼: 날짜 형식 일치시킴 (NULL로 설정 시 위쪽 DATETIME과 호환 가능)
		,DD.InspectionNgType                 -- 13번째 컬럼: ng타입
		,DD.InspectionDebugType             -- 14번째 컬럼: Debug타입
		,DD.InspectionDesc                   -- 15번째 컬럼: 사유
		,NG.CommInspItemName AS InspectionNgTypeName
		,DE.CommInspItemName AS InspectionDebugTypeName
		,'INSPECTION' AS InspectionSelectType
		,2 AS GroupOrder
		,(
			CASE 
			WHEN ISNULL(DD.InspectionResult, '') <> 'Fail' THEN 'PASS'
			WHEN rp.Barcode IS NOT NULL THEN 'PASS'
			ELSE 'FAIL'
			END
		) AS Status
	FROM
		STB_DefectInspectionDetail AS DD WITH(NOLOCK)
		INNER JOIN
		STB_SetInfo AS SI WITH(NOLOCK) 
		ON
		SI.ControlNo = DD.ControlNo
		AND
		DD.ControlNo IS NOT NULL
		INNER JOIN
		#TmpBarcodes AS TB 
		ON 
		SI.Barcode = TB.Barcode
		INNER JOIN 
		STB_ProdRouteHist AS PH WITH(NOLOCK) 
		ON 
		PH.ControlNo = SI.ControlNo
		AND
		PH.RouteCode = DD.RouteCode
		LEFT OUTER JOIN
		STB_CommInspItem AS NG WITH(NOLOCK) 
		ON
		NG.CommInspItemCode = DD.InspectionNgType 
		LEFT OUTER JOIN
		STB_CommInspItem AS DE WITH(NOLOCK) 
		ON
		DE.CommInspItemCode = DD.InspectionDebugType 
		LEFT OUTER JOIN 
		#TmpMaterialInput AS MI 		
		ON 
		MI.Barcode = SI.Barcode
		LEFT OUTER JOIN
		#TmpRepair AS rp
		ON
		rp.Barcode = SI.Barcode
		AND
		rp.RouteCode = PH.RouteCode

	WHERE
		DD.CreateDateTime >= @FromDate
		AND 
		DD.CreateDateTime < @ToDate

	) AS G
	ORDER BY G.Barcode, G.RouteCode, G.GroupOrder, G.CreateDateTime


	DROP TABLE #TmpBarcodes
	DROP TABLE #TmpDefect
	DROP TABLE #TmpMaterialInput
	DROP TABLE #TmpRepair
END
  ```

### [B523] — 📍 ID_19 Sanmina QR code has redundant quantities and serials on inne...
* **Ngay sua:** `2026-07-06`
* **Man hinh lien quan (TCode):** `B523 - Đóng gói`
* **Trieu chung loi:** Sanmina QR code has redundant quantities and serials on inner labels
* **Nguyen nhan goc (Root Cause):** Stored procedure usp_SanminaLabelPrint_get_Vietnam did not return a filtered list of serials and quantities for inner labels.
* **Phuong an sua loi (SQL Patch / Action):**
  ```sql
-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-26
-- Description:	Get Sanmina label
-- =============================================
-- exec usp_SanminaLabelPrint_get_Vietnam '', '', '123', 'VVQL023R07279E', '100', '10'

ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam]
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

	SET @packingDate = CONVERT(VARCHAR(6), CAST(ISNULL(@packingDate_tmp, GETDATE()) AS DATE), 12);
	
	--RAISERROR(@LotNo, 16, 1)
	--RETURN

	-- Lấy tên NV QC
	SELECT TOP 1  @InspEmpID = MIIExtText01,
					@InspEmpName = PWI.WorkerName
		FROM STB_MaterialQcInfo  MQI
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
		where	MQI.InspectionDocType = 'OQC' AND
				(MQI.MaterialQcNo LIKE '%' +SUBSTRING(@LotNo, 1, 14) + '%' or MQI.MaterialQcNo LIKE '%' + SUBSTRING(@NewBarcode, 1, 14) + '%')

				
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

	SELECT @MaxSerial = ISNULL(MAX(TRY_CAST(RIGHT(BoxSerialNo, 5) AS INT)), 0)
	FROM STB_SanminaIndiaLabelPrintHist WITH(NOLOCK)
	WHERE BoxSerialNo LIKE @SerialPrefix + '%'
	  AND BoxSerialNo NOT LIKE '%-%'
	  AND LEN(BoxSerialNo) = 13

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
	-- Mỗi dòng đều chứa đủ 3 serial + số lượng tương ứng để QR code trên cả 3 tem đều hiển thị đầy đủ
	DECLARE @BaseSerial VARCHAR(20)
	DECLARE @OuterQty VARCHAR(100) = @pQuantity
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
			@InspEmpID AS InspEmpID,
			@InspEmpName AS InspEmpName,
			CASE	WHEN #tmp.Num < 10 THEN '0' + CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
					ELSE CONVERT(VARCHAR(3), #tmp.Num) + '/' + @TotalBoxString
				END as CartonBoxNo,
			'Report' AS CommandType,
			LT.LabelClass,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) AS BoxSerialNo, -- Serial gốc (dùng để lưu hist)
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + LT.Suffix AS PrintSerialNo, -- Serial in trên tem hiện tại
			-- 3 cột serial cho QR code (mỗi dòng đều có đủ cả 3 serial cùng thùng)
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) AS OuterSerial,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + '-01' AS Inner1Serial,
			@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + '-02' AS Inner2Serial,
			-- Số lượng cho QR (hiển thị đủ thông tin cả 3 tem)
			@OuterQty AS OuterQty,
			@InnerQty AS InnerQty,
			/*--vanduc edited by Mr.Bach QC 20260706 START*/
			CASE 
				WHEN LT.LabelClass = 'Outer' THEN 
					(@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5)) + '||' + 
					(@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + '-01') + '||' + 
					(@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + '-02')
				ELSE 
					@SerialPrefix + RIGHT('00000' + CONVERT(VARCHAR, @MaxSerial + #tmp.Num), 5) + LT.Suffix
			END AS SerialListForQR
			/*END*/

	FROM #tmp
	CROSS JOIN #LabelTypes LT
	ORDER BY #tmp.Num, LT.SortOrder ASC

	DROP TABLE #tmp
	DROP TABLE #LabelTypes
	/*END*/

END
  ```

### 📍 ID_20 - B767 - S/N of the first label (Outer label) is blank on Sanmina lab...
* **Ngay sua:** `2026-07-16`
* **Man hinh lien quan (TCode):** `B767 - Chua xac dinh`
* **Trieu chung loi:** S/N of the first label (Outer label) is blank on Sanmina label print
* **Nguyen nhan goc (Root Cause):** Stored procedure usp_SanminaLabelPrint_get_Vietnam set PrintSerialNo to empty and BoxSerialNo to first inner serial for Outer label. Changed it to output comma-separated list of inner box serials for both.
* **Phuong an sua loi (SQL Patch / Action):**
  ```sql
-- 1. Cap nhat stored procedure lay du lieu in tem:
ALTER PROCEDURE [dbo].[usp_SanminaLabelPrint_get_Vietnam] ... (BoxSerialNo and PrintSerialNo case expressions changed to combine Inner1Serial and Inner2Serial with comma-separated values for Outer label class)

-- 2. Thay doi do dai cot BoxSerialNo trong bang lich su in de phu hop voi chuoi gop cua tem Outer:
ALTER TABLE STB_SanminaIndiaLabelPrintHist ALTER COLUMN BoxSerialNo VARCHAR(50);

-- 3. Cap nhat tham so @pBoxSerialNo trong stored procedure insert lich su:
ALTER PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud] ... (@pBoxSerialNo VARCHAR(50) = NULL)
  ```
