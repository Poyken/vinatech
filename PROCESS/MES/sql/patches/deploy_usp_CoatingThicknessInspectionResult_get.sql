-- =============================================
-- Deploy Script: usp_CoatingThicknessInspectionResult_get
-- Date: 2026-06-23
-- Author: ducnv
-- Purpose: SP truy vấn kết quả kiểm tra độ dày lớp phủ (Coating Thickness)
--          Dùng STB_MaterialQcInfo system (giống C540)
--          Data từ C5300 input
-- 
-- ★ HƯỚNG DẪN:
--   1. Chạy script này trong SSMS
--   2. Kiểm tra kết quả TEST cuối cùng
--   3. Nếu OK → đổi ROLLBACK thành COMMIT, chạy lại
-- =============================================

BEGIN TRAN

-- 1. Drop nếu đã tồn tại
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'usp_CoatingThicknessInspectionResult_get' AND type = 'P')
BEGIN
    DROP PROCEDURE dbo.usp_CoatingThicknessInspectionResult_get
    PRINT N'✓ Dropped existing SP'
END
ELSE
    PRINT N'→ SP chưa tồn tại, sẽ tạo mới'

GO

-- 2. Tạo SP
-- =============================================
-- Author:      ducnv
-- Create date: 2026-06-23
-- Description: [C5400] Truy vấn kết quả kiểm tra độ dày lớp phủ (Coating Thickness)
--              Cấu trúc tương tự C540 (usp_ProdInspectionHist_get) dùng STB_MaterialQcInfo
--              Data nhập từ C5300
-- Modified:
-- Test:
--   EXEC usp_CoatingThicknessInspectionResult_get 
--     @pProcessUserID='ducnv', @pProcessLanguage='Korean',
--     @pFromDate='2026-01-01', @pToDate='2026-06-23',
--     @pBarcode=NULL, @pMaterialCode=NULL
-- =============================================
CREATE PROCEDURE [dbo].[usp_CoatingThicknessInspectionResult_get]
    @pProcessUserID     VARCHAR(20),
    @pProcessLanguage   VARCHAR(20),
    @pFromDate          DATETIME,
    @pToDate            DATETIME,
    @pBarcode           VARCHAR(20)  = NULL,
    @pMaterialCode      VARCHAR(20)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @FromDate         DATETIME    = @pFromDate,
        @ToDate           DATETIME    = @pToDate,
        @Barcode          VARCHAR(20) = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '*' ELSE @pBarcode END,
        @MaterialCode     VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END,
        @MaterialQcNo     VARCHAR(20) = '*';

    -- Nếu nhập Barcode → tìm MaterialQcNo (giống logic C540)
    IF @pBarcode IS NOT NULL AND @pBarcode <> ''
    BEGIN
        SELECT @MaterialQcNo = LotNumber
        FROM STB_SetInfo WITH(NOLOCK)
        WHERE Barcode = @pBarcode
    END

    ;WITH cte AS (
        SELECT 
              DATEADD(HOUR, 2, CONVERT(DATETIME, MQI.BasicDate))  AS BasicDate
            , MQI.MaterialCode
            , MBI.ModelName
            , RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) AS PartNo
            , CASE WHEN MBI.MBISizeW IS NOT NULL
                   THEN RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
                        + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
                   ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) 
              END AS ModelSize
            , MQI.MaterialQcNo AS ProdQcNo
            , ISNULL(SI.Barcode, lcmh.NewBarcode) AS NewBarcode
            , MQI.DecisionResult
            , MQI.DescText
            , MQI.MIIExtText01                     AS InspWorkerCode
            , PWI.WorkerName                       AS InspWorkerName
            , MQD.QcInspectionItemCode
            , MQD.QcInspectionItemName
            , ROW_NUMBER() OVER(
                PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
                ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC
              ) AS MaterialQcSampleNo
            , MQSR.TestValue
            , MQD.LSL
            , MQD.USL
            , LI.LineCode
            , LI.LineDesc                          AS LineName
            , MQSR.CreateDateTime
        FROM STB_MaterialQcInfo MQI WITH(NOLOCK)
            LEFT JOIN STB_ModelBasicInfo          MBI  WITH(NOLOCK) ON MQI.MaterialCode = MBI.ModelCode
            LEFT JOIN STB_ProdWorkerInfo          PWI  WITH(NOLOCK) ON MQI.MIIExtText01 = PWI.WorkerCode
            LEFT JOIN STB_MaterialQcDetail        MQD  WITH(NOLOCK) ON MQI.MaterialQcNo = MQD.MaterialQcNo
            LEFT JOIN STB_MaterialQcSampleResult  MQSR WITH(NOLOCK) ON MQSR.MaterialQcNo      = MQD.MaterialQcNo
                                                                   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
            LEFT JOIN STB_SetInfo                 SI   WITH(NOLOCK) ON SI.LotNumber     = MQI.MaterialQcNo
            LEFT JOIN STB_LineInfo                LI   WITH(NOLOCK) ON SI.InputLineCode = LI.LineCode
            LEFT JOIN STB_LotChangeMaterialHistory lcmh WITH(NOLOCK) ON MQI.MaterialQcNo = lcmh.OldBarcode
        WHERE 1=1
            AND MQI.CompanyCode = 'VVT'
            -- ★ Filter coating/thickness items:
            AND (
                MQD.QcInspectionItemCode IN ('BE_OQC_001_001','BE_OQC_001_002','o4','G4','p4','P4')
                OR (
                    MQD.QcInspectionItemCode = 'IQC_G1_516'
                    AND (
                        MQD.QcInspectionItemName LIKE N'%Thickness%'
                        OR MQD.QcInspectionItemName LIKE N'%[Dd]%y%'
                    )
                )
            )
            AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
            AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
            AND (@MaterialCode = '*' OR MQI.MaterialCode LIKE @MaterialCode + '%')
    )
    SELECT * FROM cte
    ORDER BY BasicDate DESC, ProdQcNo, QcInspectionItemName, MaterialQcSampleNo;
END

GO

-- 3. Verify
IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'usp_CoatingThicknessInspectionResult_get' AND type = 'P')
    PRINT N'✓ SP tạo thành công'
ELSE
    PRINT N'✗ LỖI: SP không được tạo!'

-- 4. Test
PRINT N''
PRINT N'=== TEST: Data coating thickness 2026 ==='
EXEC usp_CoatingThicknessInspectionResult_get 
    @pProcessUserID   = 'ducnv',
    @pProcessLanguage = 'Korean',
    @pFromDate        = '2026-01-01',
    @pToDate          = '2026-06-23',
    @pBarcode         = NULL,
    @pMaterialCode    = NULL

-- ★ Deployed with COMMIT
COMMIT
