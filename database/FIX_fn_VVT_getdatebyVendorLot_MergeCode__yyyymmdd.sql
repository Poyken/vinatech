/*
Mục tiêu:
- Hỗ trợ đọc VendorLot dạng 8 chữ số YYYYMMDD (vd: 20260507) → '2026-05-07'
- Giúp LotAttr10 không bị default '1900-01-01' khi nhập kho (F330/F312) cho các NVL như TRAY1030-DC050.

Lưu ý an toàn:
- KHÔNG chạy trực tiếp trên production nếu chưa verify.
- Hãy FETCH bản function mới nhất từ DB trước khi sửa (theo AI_OPERATIONAL_RULES.md).
*/

/* === PATCH GỢI Ý (chèn vào ĐẦU function, sau khi trim @vendorlot) ===

-- Sau các dòng:
--   set @materialcode=rtrim(ltrim(@materialcode))
--   set @vendorlot=rtrim(ltrim(@vendorlot))
--   ... (xử lý '#')

DECLARE @d date;

-- VendorLot = YYYYMMDD (8 digits) => parse date style 112
IF @vendorlot IS NOT NULL
   AND LEN(@vendorlot) = 8
   AND @vendorlot NOT LIKE '%[^0-9]%'   -- chỉ chứa số
BEGIN
    SET @d = TRY_CONVERT(date, @vendorlot, 112);
    IF @d IS NOT NULL
    BEGIN
        SET @date = CONVERT(varchar(10), @d, 120); -- YYYY-MM-DD
        RETURN @date;
    END
END

*/

