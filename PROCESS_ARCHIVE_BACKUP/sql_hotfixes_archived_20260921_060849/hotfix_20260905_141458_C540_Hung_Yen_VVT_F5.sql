-- ====================================================================================================
-- HOTFIX SCRIPT: SỬA LỖI C540 KHÔNG LINK DỮ LIỆU TỪ C530 CHO NHÀ MÁY HƯNG YÊN (VVT_F5)
-- File: hotfix_20260905_141458_C540_Hung_Yen_VVT_F5.sql
-- Date: 2026-09-05
-- Author: DinhManh (MES Team)
-- Target Database: SmartFactoryV2
-- Target Screen: [C540] VNT_ProdInspectionHist (Lịch sử kiểm tra sản xuất OQC)
-- Target Procedure: [dbo].[usp_ProdInspectionHist_get]
-- Single Source of Truth: Follows .agents Master Rules (UTF-8 BOM, Safety Checks, Pre/Post Verification)
-- ====================================================================================================
-- NGUYÊN NHÂN GỐC (ROOT CAUSE):
-- 1. Đoạn code cũ của usp_ProdInspectionHist_get (dòng 151-154) chỉ xét 2 trường hợp:
--      - Hà Nam: @workcentercode = 'VVT_F3' -> chỉ lấy MQI.WorkCenterCode = 'VVT_F3'
--      - Còn lại: @workcentercode <> 'VVT_F3' -> chỉ lấy MQI.WorkCenterCode IN ('VVT_F1', 'VVT_F2')
--    -> Nhà máy Hưng Yên mới triển khai (VVT_F5) bị loại bỏ hoàn toàn khỏi kết quả truy vấn.
-- 2. Khi tìm kiếm đích danh @Barcode hoặc @MaterialQcNo, điều kiện xưởng vẫn bị áp đặt cứng,
--    khiến các lô sản xuất ở chuyền Hưng Yên nhưng do nhân viên xưởng khác thao tác C530
--    (hoặc ngược lại) không thể hiển thị trên C540.
--
-- GIẢI PHÁP KHẮC PHỤC (SOLUTION):
-- 1. Bổ sung nhánh xử lý cho Hưng Yên: @workcentercode = 'VVT_F5'
--    -> Hiển thị các lô có MQI.WorkCenterCode = 'VVT_F5' HOẶC chuyền sản xuất Hưng Yên (SI.InputLineCode LIKE '%HY%').
-- 2. Tài khoản Bắc Ninh / Tổng (VVT_F1, VVT_F2): Cho phép xem bổ sung VVT_F5 để phục vụ kiểm soát chất lượng liên xưởng.
-- 3. Bổ sung ưu tiên: Khi người dùng gõ đích danh @Barcode hoặc @MaterialQcNo thì bỏ qua giới hạn xưởng,
--    trả về đúng kết quả của lô đó.
-- ====================================================================================================

USE SmartFactoryV2;
GO

-- ====================================================================================================
-- BƯỚC 1: KIỂM CHỨNG TRƯỚC KHI DEPLOY (PRE-FLIGHT CHECK)
-- ====================================================================================================
PRINT N'>>> [BƯỚC 1] Kiểm tra kết quả truy vấn của Lô Hưng Yên VVQQ093R072726 TRƯỚC khi sửa SP:';

-- Test với user Hưng Yên pqcluan
EXEC usp_ProdInspectionHist_get 
    @pProcessUserID = 'pqcluan', 
    @pProcessLanguage = 'VI', 
    @pFromDate = '2026-09-01', 
    @pToDate = '2026-09-05', 
    @pMaterialQcNo = 'VVQQ093R072726', 
    @pCompanyCode = 'VVT';
GO

-- ====================================================================================================
-- BƯỚC 2: CẬP NHẬT STORED PROCEDURE VỚI COMMENT CHI TIẾT
-- ====================================================================================================
PRINT N'>>> [BƯỚC 2] Bắt đầu ALTER PROCEDURE [dbo].[usp_ProdInspectionHist_get]...';
GO

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-10-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C540] 제품검사이력
-- Modified:
--                2020.01.07  사이즈 추가 (Mr.꾸엔 요청사항)
--                라인정보 추가. 채민수대리 요청. By Jackaroe #200903
--                2021.04.30 판정결과 추가 이미정 요청
--                조회기간 제한 (35일) By Jackaroe #211118
--                2026.09.05  Hưng Yên (VVT_F5) Hotfix:
--                            1. Bổ sung phân quyền hiển thị OQC C540 cho nhà máy Hưng Yên (VVT_F5).
--                            2. Hỗ trợ hiển thị các lô chuyền Hưng Yên (InputLineCode LIKE '%HY%') kể cả khi thao tác C530 ở F1.
--                            3. Ưu tiên tìm kiếm đích danh Barcode / Lot không bị chặn phân xưởng.
--                            By DinhManh (MES Team)
-- =================================================================================================================================
ALTER PROCEDURE [dbo].[usp_ProdInspectionHist_get]
	@pProcessUserID       VARCHAR(20),
	@pProcessLanguage     VARCHAR(20),
	@pFromDate            DATETIME,
	@pToDate              DATETIME,
	@pMaterialQcNo        VARCHAR(20) = NULL,
	@pQcInspectionItemCode VARCHAR(20) = NULL,
	@pBarcode             VARCHAR(20) = NULL,
	@pCompanyCode         VARCHAR(20) = NULL,                                         -- 사업장 추가 (2019.12.22, kilee)
	@pSizeCode            VARCHAR(20) = NULL,                                         -- 사이즈 추가 (2020.01.07, kilee)
	@pDecisionResult      VARCHAR(20) = NULL                                         -- 판정결과 추가 -> 이미정님 요청 (2021.04.30, kilee)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @FromDate           DATETIME     = @pFromDate
		   ,@ToDate             DATETIME     = @pToDate
		   ,@MaterialQcNo       VARCHAR(20)  = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
		   ,@QcInspectionItemCode VARCHAR(20)= CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
		   ,@Barcode            VARCHAR(20)  = @pBarcode
		   ,@SizeCode           VARCHAR(20)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '*' ELSE  @pSizeCode  END
		   ,@DecisionResult     VARCHAR(20)  = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '*' ELSE @pDecisionResult END
		   ,@workcentercode     VARCHAR(50)
			 
    -- Lấy mã xưởng (WorkCenterCode) của user đăng nhập: VVT_F1/F2 (Bắc Ninh), VVT_F3 (Hà Nam), VVT_F5 (Hưng Yên)
    SELECT @workcentercode = Workcentercode FROM STB_UserInfo WITH(NOLOCK) WHERE UserID = @pProcessUserID

	DECLARE @PeriodCnt INT
	SELECT @PeriodCnt = DATEDIFF(day, @FromDate, @ToDate)

	-- Nếu truyền Barcode thì tự động map sang LotNumber tương ứng trong STB_SetInfo
	IF @Barcode IS NOT NULL 	
	BEGIN
		SELECT @MaterialQcNo = LotNumber
		  FROM STB_SetInfo WITH(NOLOCK) 
		 WHERE Barcode = @Barcode
	END

	-- ==============================================================================================
	-- NHÁNH 1: CÔNG TY VINATECH VIỆT NAM (@CompanyCode = 'VVT')
	-- ==============================================================================================
	IF @CompanyCode = 'VVT' BEGIN

		;WITH mqi AS (
		SELECT  DATEADD(hour, 2, CONVERT(DATETIME, MQI.BasicDate)) BasicDate   -- Mr.Tung add date, avoid decrease 1 day 
			  ,MQI.MaterialCode
			  ,CASE 
				WHEN MQI.MaterialQcNo IN (
				  'VVQP143R033514',	
				  'VVQP143R033515',	
				  'VVQP143R033516',	
				  'VVQP143R033524',	
				  'VVQP153R033501',	
				  'VVQP153R033510',	
				  'VVQP153R033511',	
				  'VVQP143R033517',	
				  'VVQP143R033518'
				 ) THEN 'HY-CAP WEC3R0335QG-NS (0820)'
				ELSE MBI.ModelName END AS ModelName

			  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) AS PartNo  -- modified by Mr.Tung on 07-May-2021, due SUBSTRING whenever ModelName length to short
			  ,CASE WHEN MBI.MBISizeW IS NOT NULL
					 THEN RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
			  ,MQI.MaterialQcNo AS ProdQcNo 
		  	 ,CASE WHEN MQI.MaterialQcNo = 'VVPM212R750625' THEN ISNULL(lcmh.NewBarcode, si.Barcode)
					ELSE ISNULL(si.Barcode, lcmh.NewBarcode) END AS NewBarcode 
			 , lcmh.AftMaterialCode
			 , REPLACE(SUBSTRING(spt.PackingID, 1, 15), '-', '') AS KoreaLabel
			  ,MQI.DecisionResult
			  ,MQI.DescText
			  ,MQI.QcMarking
			  ,MQI.CapDungLuong
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,MQD.LSL	-- update 2026-01-28 add LSL and USL following Ms.Hanh's request
			  ,MQD.USL	--
			  ,LI.LineCode --#200903
			  ,LI.LineDesc AS LineName --#200903
		  
			  -- this STUFF and XML PATH for Vietnam Classify Only (Mr.Tung add on 17-March-2021)
			  ,STUFF(
				  (SELECT 
					 ', ' + levelB
					 FROM VVT_OQC_REFER WITH(NOLOCK) 
					 WHERE mergeid = (SELECT TOP 1 mergeid FROM vvt_oqc_refer WITH(NOLOCK) WHERE lotid = MQI.MaterialQcNo)  
					 FOR XML PATH ('')
				  ), 1, 2, ''
				) AS Classify

			  ,STUFF(
				  (SELECT 
					', ' + Lotid 
					 FROM VVT_OQC_REFER WITH(NOLOCK)  
					 WHERE mergeid = (SELECT TOP 1 mergeid FROM vvt_oqc_refer WITH(NOLOCK) WHERE lotid = MQI.MaterialQcNo)  
					 FOR XML PATH ('')
				  ), 1, 2, ''
				 ) AS LotID_list
			 ,MQI.VendorLotNo AS Holding_Hist
			 ,MQSR.CreateDateTime

		  FROM STB_MaterialQcInfo MQI WITH(NOLOCK) 
				  LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) 		ON MQI.MaterialCode = MBI.ModelCode
				  LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK) 		ON MQI.MIIExtText01 = PWI.WorkerCode
				  LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) 	ON MQI.MaterialQcNo = MQD.MaterialQcNo
				  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR WITH(NOLOCK) ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
																				AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
				  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)               ON SI.LotNumber = MQI.MaterialQcNo --#200903
				  LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)              ON SI.InputLineCode = LI.LineCode --#200903
				  LEFT OUTER JOIN STB_LotChangeMaterialHistory lcmh WITH(NOLOCK) ON MQI.MaterialQcNo = lcmh.OldBarcode
				  OUTER APPLY ( 
					SELECT TOP 1 *
					FROM STB_SavePackingTime_VVT WITH(NOLOCK)  
					WHERE LotNo = MQI.MaterialQcNo AND PackingID LIKE 'VJ%'
				  ) spt
		 WHERE 1=1
		   AND MQI.InspectionDocType = 'OQC'
		   AND MQD.QcInspectionItemCode IN (SELECT QcInspectionItemCode FROM STB_QcInspectionItem WHERE IsHideOrShowHistory = 1) -- Mr.Duy cấu hình dòng này ở C121 cột Ẩn/Hiển thị 
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
		   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   

		  -- ==========================================================================================
		  -- [HOTFIX 2026-09-05 DINHMANH]: PHÂN QUYỀN LỌC DỮ LIỆU THEO NHÀ MÁY (BẮC NINH / HÀ NAM / HƯNG YÊN)
		  -- ------------------------------------------------------------------------------------------
		  -- 1. Ưu tiên tra cứu đích danh: Nếu user nhập Barcode hoặc Lot Number (@MaterialQcNo <> '*'),
		  --    cho phép hiển thị ngay mà không bị chặn phân xưởng (hỗ trợ kiểm tra chéo liên xưởng).
		  -- 2. Nhà máy Hà Nam (@workcentercode = 'VVT_F3'): Chỉ xem dữ liệu xưởng VVT_F3.
		  -- 3. Nhà máy Hưng Yên (@workcentercode = 'VVT_F5'): Xem dữ liệu xưởng VVT_F5 HOẶC các lô
		  --    thuộc chuyền sản xuất Hưng Yên (SI.InputLineCode LIKE '%HY%').
		  -- 4. Nhà máy Bắc Ninh / Khác (@workcentercode NOT IN ('VVT_F3', 'VVT_F5')):
		  --    Xem dữ liệu xưởng Bắc Ninh (VVT_F1, VVT_F2) và hỗ trợ xem cả xưởng Hưng Yên (VVT_F5).
		  -- ==========================================================================================
		  AND (
				-- TH1: Tìm kiếm đích danh theo Mã Barcode hoặc Số Lot
				(@MaterialQcNo <> '*' OR @Barcode IS NOT NULL)

				-- TH2: Lọc theo phân xưởng Hà Nam (VVT_F3)
				OR (@workcentercode = 'VVT_F3' AND MQI.WorkCenterCode = 'VVT_F3')

				-- TH3: Lọc theo phân xưởng Hưng Yên (VVT_F5)
				OR (@workcentercode = 'VVT_F5' AND (MQI.WorkCenterCode = 'VVT_F5' OR SI.InputLineCode LIKE '%HY%'))

				-- TH4: Lọc theo phân xưởng Bắc Ninh & Tổng (VVT_F1, VVT_F2, VVT_F5)
				OR (@workcentercode NOT IN ('VVT_F3', 'VVT_F5') AND MQI.WorkCenterCode IN ('VVT_F1', 'VVT_F2', 'VVT_F5'))
		  )

		   AND (@SizeCode = '*' OR RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) LIKE '%' + @SizeCode + '%') -- Condition modify (using index)
		   AND ((@DecisionResult = '*') OR (MQI.DecisionResult = @DecisionResult))    -- 이미정님 요청 (2021.04.30, kilee)
	    )

	    SELECT * FROM mqi
		ORDER BY BasicDate, ProdQcNo, QcInspectionItemName, MaterialQcSampleNo;

    -- ==============================================================================================
	-- NHÁNH 2: CÔNG TY VINATECH HÀN QUỐC (@CompanyCode <> 'VVT')
	-- ==============================================================================================
    END ELSE BEGIN

		;WITH mqi AS (
		SELECT MQI.BasicDate
			  ,MQI.MaterialCode
			  ,MBI.ModelName
			  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) AS PartNo  -- modified by Mr.Tung on 07-May-2021, due SUBSTRING whenever ModelName length to short
			  ,CASE WHEN MBI.MBISizeW IS NOT NULL
					 THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
			  ,MQI.MaterialQcNo AS ProdQcNo 
		  	 ,ISNULL(si.Barcode, lcmh.NewBarcode) AS NewBarcode
			 ,lcmh.AftMaterialCode
			 ,'' AS KoreaLabel
			  ,MQI.DecisionResult
			  ,MQI.DescText
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,LI.LineCode --#200903
			  ,LI.LineDesc AS LineName --#200903
			  ,'' AS Classify
			  ,'' AS LotID_list
			 ,MQI.VendorLotNo AS Holding_Hist
			 ,MQSR.CreateDateTime

		  FROM STB_MaterialQcInfo MQI WITH(NOLOCK) 
				  LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) 		ON MQI.MaterialCode = MBI.ModelCode
				  LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK) 		ON MQI.MIIExtText01 = PWI.WorkerCode
				  LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) 	ON MQI.MaterialQcNo = MQD.MaterialQcNo
				  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR WITH(NOLOCK) ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
																				AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
				  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)               ON SI.LotNumber = MQI.MaterialQcNo --#200903
				  LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)              ON SI.InputLineCode = LI.LineCode --#200903
				  LEFT OUTER JOIN STB_LotChangeMaterialHistory lcmh WITH(NOLOCK) ON MQI.MaterialQcNo = lcmh.OldBarcode
		 WHERE 1=1
		   AND MQI.InspectionDocType = 'OQC'
			AND (MQD.QcInspectionItemCode IN ('IQC_GPD_18', 'IQC_GPD_19', 'IQC_GPD_20', 'PQC_V01_01', 'PQC_V01_02'
										  , 'PQC_V01_03', 'PQC_V01_04', 'PQC_V01_05','PQC_V01_07','PQC_V01_08'
										  ,'PQC_V01_09','PQC_M01_001')
					OR MQD.QcInspectionItemCode LIKE 'IQC_G36%'
				)
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
		   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
		   AND (@SizeCode = '*' OR RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) LIKE '%' + @SizeCode + '%') -- Condition modify (using index)
		   AND ((@DecisionResult = '*') OR (MQI.DecisionResult = @DecisionResult))    -- 이미정님 요청 (2021.04.30, kilee)
	    )

	    SELECT * FROM mqi
	    ORDER BY BasicDate, ProdQcNo, QcInspectionItemName, MaterialQcSampleNo;
    END

END;
GO

-- ====================================================================================================
-- BƯỚC 3: KIỂM TRA LẠI KẾT QUẢ SAU KHI SỬA (POST-DEPLOY VERIFICATION)
-- ====================================================================================================
PRINT N'>>> [BƯỚC 3] Kiểm tra kết quả truy vấn SAU KHI sửa SP:';

-- 1. Kiểm tra Lô Hưng Yên VVQQ093R072726 với tài khoản Hưng Yên (pqcluan)
PRINT N'--- Test 1: User pqcluan (VVT_F5) tra cứu Lô Hưng Yên VVQQ093R072726:';
EXEC usp_ProdInspectionHist_get 
    @pProcessUserID = 'pqcluan', 
    @pProcessLanguage = 'VI', 
    @pFromDate = '2026-09-01', 
    @pToDate = '2026-09-05', 
    @pMaterialQcNo = 'VVQQ093R072726', 
    @pCompanyCode = 'VVT';

-- 2. Kiểm tra Lô VVQQ093R072716 với tài khoản Hưng Yên (pqcluan)
PRINT N'--- Test 2: User pqcluan (VVT_F5) tra cứu Lô chuyền Hưng Yên VVQQ093R072716 (BasicDate 2026-08-26):';
EXEC usp_ProdInspectionHist_get 
    @pProcessUserID = 'pqcluan', 
    @pProcessLanguage = 'VI', 
    @pFromDate = '2026-08-20', 
    @pToDate = '2026-08-30', 
    @pMaterialQcNo = 'VVQQ093R072716', 
    @pCompanyCode = 'VVT';
GO
