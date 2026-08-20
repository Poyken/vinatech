-- ==============================================================================
-- PATCH: CHUYỂN 36 LÔ HÀNG BTP 35105 TỪ BẮC GIANG SANG HƯNG YÊN (LINE 1 & LINE 2)
-- AUTHOR: Vinatech MES Support Team
-- DATE: 2026-08-19
-- TICKET / REQUEST: Trần Thế Trung (Email & Chat 2026-08-19)
-- MÔI TRƯỜNG: SmartFactoryV2 | AN TOÀN: BỌC TRANSACTION
-- ==============================================================================

BEGIN TRANSACTION;

-- Khai báo danh sách 36 Barcode
DECLARE @Line1_Barcodes TABLE (Barcode VARCHAR(30));
DECLARE @Line2_Barcodes TABLE (Barcode VARCHAR(30));

-- 18 Lot gán vào Line 1 (VVHYC-01)
INSERT INTO @Line1_Barcodes VALUES
('VVQO113R072735'),('VVQO153R072709'),('VVQO153R072710'),('VVQO153R072712'),('VVQO153R072713'),
('VVQO153R072719'),('VVQO153R072722'),('VVQO153R072724'),('VVQO153R072727'),('VVQO153R072728'),
('VVQO163R072709'),('VVQO163R072711'),('VVQO173R072716'),('VVQO173R072719'),('VVQO173R072722'),
('VVQO173R072751'),('VVQO173R072761'),('VVQO183R072710');

-- 18 Lot gán vào Line 2 (VVHYC-02)
INSERT INTO @Line2_Barcodes VALUES
('VVQO183R072713'),('VVQO183R072716'),('VVQO183R072718'),('VVQO183R072747'),('VVQO183R072761'),
('VVQO193R072710'),('VVQO193R072711'),('VVQO193R072713'),('VVQO193R072714'),('VVQO193R072715'),
('VVQO193R072716'),('VVQO193R072727'),('VVQO193R072748'),('VVQO193R072758'),('VVQO193R072761'),
('VVQO193R072768'),('VVQO193R072777'),('VVQO203R072743');

-- 1. Cập nhật Line 1 (VVHYC-01) cho 18 Lot nhóm 1
UPDATE STB_SetInfo
SET InputLineCode = 'VVHYC-01', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE Barcode IN (SELECT Barcode FROM @Line1_Barcodes);

-- 2. Cập nhật Line 2 (VVHYC-02) cho 18 Lot nhóm 2
UPDATE STB_SetInfo
SET InputLineCode = 'VVHYC-02', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE Barcode IN (SELECT Barcode FROM @Line2_Barcodes);

-- 3. Cập nhật Routing công đoạn Đóng gói (V-28_HY) và Ủ (V-26_HY) / Ngoại quan (V-27_HY)
DECLARE @All_ControlNos TABLE (ControlNo VARCHAR(30));
INSERT INTO @All_ControlNos
SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode IN (SELECT Barcode FROM @Line1_Barcodes UNION SELECT Barcode FROM @Line2_Barcodes);

UPDATE STB_ProdRouteHist
SET RouteCode = 'V-28_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE RouteCode = 'V-28_BG' AND ControlNo IN (SELECT ControlNo FROM @All_ControlNos);

UPDATE STB_ProdRouteHist
SET RouteCode = 'V-26_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE RouteCode = 'V-26_BG' AND ControlNo IN (SELECT ControlNo FROM @All_ControlNos);

UPDATE STB_ProdRouteHist
SET RouteCode = 'V-27_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE RouteCode = 'V-27_BG' AND ControlNo IN (SELECT ControlNo FROM @All_ControlNos);

COMMIT TRANSACTION;
