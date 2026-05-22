-- CHECK LOTS TRONG BẢNG PACKING - VVQL143R815703, VVQK253R815701, VVQK273R815705, VVQJ153R815702
-- Vấn đề: Đã chuyển đổi ra bedding nhưng không chốt được công đoạn doping và kiểm tra lại

-- B1: Check trong STB_SavePackingTime_VVT (Bảng packing) - simplified
SELECT TOP 10 *
FROM STB_SavePackingTime_VVT
WHERE LotNo IN ('VVQL143R815703', 'VVQK253R815701', 'VVQK273R815705', 'VVQJ153R815702')
ORDER BY LotNo

-- B2: Check trong STB_MaterialLotInfo (Bảng lot kho)
SELECT 
    LotID,
    MaterialCode,
    CurrentQty,
    MaterialWarehouseCode,
    MaterialLocationCode,
    CreateDateTime
FROM STB_MaterialLotInfo
WHERE LotID IN ('VVQL143R815703', 'VVQK253R815701', 'VVQK273R815705', 'VVQJ153R815702')
ORDER BY LotID
