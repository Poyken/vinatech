-- ==============================================================================
-- TEMPLATE: FORCE CREATE ELECTRODE ROLL STOCK (TẠO TỒN KHO CƯỠNG CHẾ CUỘN ĐIỆN CỰC)
-- Reference: POP_KB_03 Case 8 & 9 | HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI
-- Author / ChangeUserID: vanduc
-- Created At: {{DATE_CREATED}}
-- Issue Code: {{ISSUE_CODE}}
-- Target: Cấp số nhảy qua STB_SerialRule và chèn STB_MaterialLotInfo cho cuộn rách tem
-- ==============================================================================
USE SmartFactoryV2;
GO

-- ==============================================================================
-- STEP 0: XÁC ĐỊNH CUỘN HỢP LỆ TỪ KẾT QUẢ SLITTING THỰC TẾ
-- ==============================================================================
DECLARE @baseLot VARCHAR(50) = '<BASE_ELECTRODE_LOT>'; -- VD: 'VWQO2720001E03'

SELECT 
    ESR.Barcode, ESR.Seq,
    ESR.SlittingWidth  AS WidthMm,    /* Chiều rộng — thực tích */
    ESR.ElectrodeThick AS ThickUm,    /* Độ dày     — thực tích */
    ESR.GoodQtyLength  AS LengthM,    /* Chiều dài  — thực tích = Tồn kho */
    DPP.MaterialCode   AS BaseCoatingCode, 
    RTRIM(ISNULL(BaseMM.PlusMinus,'')) AS BasePM,
    ESR.SlittingMaterialCode, 
    RTRIM(ISNULL(SlitMM.PlusMinus,'')) AS SlitPM,
    CASE 
        WHEN SlitMM.MaterialCode IS NOT NULL AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')
        THEN ESR.SlittingMaterialCode 
        ELSE DPP.MaterialCode 
    END AS ResolvedMaterialCode,
    CASE 
        WHEN EXISTS (SELECT 1 FROM STB_MaterialLotInfo M2 WITH(NOLOCK) WHERE M2.LotID = ESR.Barcode) 
        THEN 'Y' ELSE 'N' 
    END AS AlreadyInMLI
FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = ESR.ElectrodeLotNumber
INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
LEFT JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode
LEFT JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
WHERE ESR.ElectrodeLotNumber = @baseLot
  AND ESR.CompanyCode = 'VVT'
ORDER BY ESR.Seq;
GO

-- ==============================================================================
-- STEP 1: CƯỠNG CHẾ TẠO TỒN KHO VÀO STB_MaterialLotInfo
-- ==============================================================================
DECLARE @rollBarcode   VARCHAR(50) = '<MÃ_CUỘN_CẦN_TẠO>'; -- VD: 'VWQO2720001E03-001'
DECLARE @warehouseCode VARCHAR(20) = 'ROUTE_VN_WH';       -- Kho đích (Hà Nam: ROUTE_VN_WH, Hưng Yên: ROUTE_HY_WH)

BEGIN TRAN;

DECLARE @matCode VARCHAR(50), @lengthM NUMERIC(13,3), @electrodeLot VARCHAR(50), @wcCode VARCHAR(20);

SELECT TOP 1
    @matCode = CASE 
        WHEN SlitMM.MaterialCode IS NOT NULL AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')
        THEN ESR.SlittingMaterialCode 
        ELSE DPP.MaterialCode 
    END,
    @lengthM = ISNULL(ESR.GoodQtyLength, 0),
    @electrodeLot = ESR.ElectrodeLotNumber,
    @wcCode = ISNULL(W.WorkCenterCode, 'VVT_F1')
FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = ESR.ElectrodeLotNumber
INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
LEFT JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode
LEFT JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
LEFT JOIN STB_MaterialWarehouse W WITH(NOLOCK) ON W.MaterialWarehouseCode = @warehouseCode AND W.CompanyCode = 'VVT'
WHERE ESR.Barcode = @rollBarcode
  AND ESR.CompanyCode = 'VVT'
  AND ESR.TransferDateTime IS NULL
ORDER BY ESR.Seq DESC;

-- Kiểm tra an toàn trước khi nạp
IF @matCode IS NULL
BEGIN
    RAISERROR(N'LỖI: Không tìm thấy thực tích Slitting (ESR)! Bắt buộc xác nhận thực tích trước.', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

IF ISNULL(@lengthM, 0) <= 0
BEGIN
    RAISERROR(N'LỖI: Chiều dài thực tích <= 0! Cần điều chỉnh GoodQtyLength trước khi nạp kho.', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotID = @rollBarcode)
BEGIN
    RAISERROR(N'LỖI: Cuộn này đã tồn tại trong STB_MaterialLotInfo! Không được tạo trùng.', 16, 1);
    ROLLBACK TRAN;
    RETURN;
END

-- Cấp số Serial chuẩn từ SmartFramework.dbo.STB_SerialRule
DECLARE @curDate VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112);
DECLARE @prefix VARCHAR(12), @serialLen INT, @lastNo INT, @lastPrefix VARCHAR(12);

SELECT 
    @prefix = REPLACE(REPLACE(REPLACE(REPLACE(PrefixData,
        'YYYY', SUBSTRING(@curDate,1,4)), 'YY', SUBSTRING(@curDate,3,2)),
        'MM', SUBSTRING(@curDate,5,2)), 'DD', SUBSTRING(@curDate,7,2)),
    @serialLen = SerialLen, @lastNo = LastSerialNo, @lastPrefix = ISNULL(LastPrefixData, '')
FROM SmartFramework.dbo.STB_SerialRule WITH(ROWLOCK, UPDLOCK)
WHERE TableName = 'STB_MaterialLotInfo';

IF @prefix IS NULL 
BEGIN 
    RAISERROR(N'LỖI: Không tìm thấy quy tắc sinh số STB_SerialRule!', 16, 1); 
    ROLLBACK TRAN; 
    RETURN; 
END

IF @prefix != @lastPrefix
BEGIN
    UPDATE SmartFramework.dbo.STB_SerialRule
    SET LastPrefixData = @prefix, LastSerialNo = 1
    WHERE TableName = 'STB_MaterialLotInfo';
    SET @lastNo = 0;
END
ELSE
BEGIN
    UPDATE SmartFramework.dbo.STB_SerialRule
    SET LastSerialNo = LastSerialNo + 1
    WHERE TableName = 'STB_MaterialLotInfo';
END

DECLARE @materialLotNo VARCHAR(20) = @prefix + RIGHT(REPLICATE('0', @serialLen) + CAST(@lastNo + 1 AS VARCHAR(10)), @serialLen);

-- Ghi nhận tồn kho cuộn
INSERT INTO STB_MaterialLotInfo (
    MaterialLotNo, LotID, CompanyCode, WorkCenterCode,
    MaterialWarehouseCode, MaterialLocationCode, MaterialCode, MaterialStockAttribute,
    StockAttrib2, StockAttrib3, GRDate, InitialQty, CurrentQty, PickingQty,
    LotNo, IsSplitLot, LotAttr01, IsSlitting, LengthSlitting,
    CreateDateTime, CreateUserID
)
VALUES (
    @materialLotNo, @rollBarcode, 'VVT', @wcCode,
    @warehouseCode, '', @matCode, 'NORMAL',
    '', '', CONVERT(VARCHAR(10), GETDATE(), 23), @lengthM, @lengthM, 0,
    @electrodeLot, 0, 'SLITTING', 1, @lengthM,
    GETDATE(), 'vanduc'
);

-- ==============================================================================
-- STEP 2: KIỂM TRA ĐIỀU KIỆN HIỂN THỊ TRÊN MODAL POP (ModalVisible = 'Y')
-- ==============================================================================
SELECT 
    MLI.MaterialLotNo, MLI.LotID, MLI.LotNo, MLI.MaterialCode, MLI.CurrentQty, MLI.LengthSlitting,
    MLI.MaterialWarehouseCode, RTRIM(ISNULL(MM.PlusMinus,'')) AS Polarity,
    CASE 
        WHEN MLI.CompanyCode = 'VVT' AND MLI.IsSlitting = 1
             AND RTRIM(ISNULL(MLI.LotAttr01,'')) = 'SLITTING'
             AND MLI.CurrentQty > 0
             AND MLI.MaterialWarehouseCode = @warehouseCode
             AND NULLIF(RTRIM(ISNULL(MM.PlusMinus,'')), '') IS NOT NULL
        THEN 'Y' ELSE 'N' 
    END AS ModalVisible
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = MLI.MaterialCode
WHERE MLI.LotID = @rollBarcode;

-- Đổi ROLLBACK thành COMMIT sau khi xác minh ModalVisible = 'Y'
ROLLBACK TRAN;
-- COMMIT TRAN;
PRINT '-> [XÁC MINH] Nếu ModalVisible = Y, đổi ROLLBACK thành COMMIT TRAN để kích hoạt tồn kho!';
GO
