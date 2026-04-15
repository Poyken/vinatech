UPDATE STB_MaterialDocLotInfo 
SET LotAttr10 = '20260410'
WHERE MaterialCode = '153_SATRAY_VNF' 
  AND (LotAttr10 IS NULL OR REPLACE(LotAttr10, ' ', '') = '');


  -- Ví dụ lệnh cho hạng NORMAL (lặp lại tương tự cho A, B, C, S, W, N)
IF NOT EXISTS (SELECT * FROM STB_MaterialAttribute WHERE MaterialCode = '153_SATRAY_VNF' AND StockAttrib = 'NORMAL')
BEGIN
    INSERT INTO STB_MaterialAttribute (
        MaterialCode, 
        AttribType, 
        StockAttrib, 
        StockAttribDesc, 
        CreateDateTime, 
        CreateUserID
    )
    VALUES (
        '153_SATRAY_VNF', 
        1, 
        'NORMAL', 
        'NORMAL', 
        GETDATE(), 
        'vinaadmin'
    );
END

-----------------------------------------------------

-- 1. Xóa các đặc tính đã thêm cho mã vật tư này trong ngày hôm nay
DELETE FROM STB_MaterialAttribute 
WHERE MaterialCode = '153_SATRAY_VNF' 
  AND CreateUserID = 'vinaadmin'
  AND CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE);

-- 2. Đưa ngày sản xuất (LotAttr10) về lại giá trị trống
-- Lưu ý: Chỉ tác động đến mã 153_SATRAY_VNF và giá trị đã cập nhật hôm nay
UPDATE STB_MaterialDocLotInfo 
SET LotAttr10 = ''
WHERE MaterialCode = '153_SATRAY_VNF' 
  AND LotAttr10 = '20260410'
  AND CAST(CreateDateTime AS DATE) = CAST(GETDATE() AS DATE);
